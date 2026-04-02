-- Certificate Eligibility Matrix
-- Purpose: Validate certificate gating against real states:
--   1) payment confirmed
--   2) all course materials viewed
--   3) all required assessments passed
--
-- Usage:
--   Option A) Run as-is to inspect all enrollments
--   Option B) Set @target_enrollment_id or @target_user_id to scope checks

SET @target_enrollment_id := NULL;  -- example: 12
SET @target_user_id := NULL;        -- example: 7

WITH latest_payment AS (
    SELECT p1.EnrollmentID, p1.PaymentStatus, p1.PaystackReference, p1.Reference, p1.PaymentID
    FROM Payment p1
    INNER JOIN (
        SELECT EnrollmentID, MAX(PaymentID) AS MaxPaymentID
        FROM Payment
        GROUP BY EnrollmentID
    ) p2 ON p1.EnrollmentID = p2.EnrollmentID AND p1.PaymentID = p2.MaxPaymentID
),
material_totals AS (
    SELECT m.CourseID, COUNT(*) AS TotalMaterials
    FROM Material m
    GROUP BY m.CourseID
),
viewed_materials AS (
    SELECT mp.UserID, m.CourseID, COUNT(*) AS ViewedMaterials
    FROM MaterialProgress mp
    INNER JOIN Material m ON m.MaterialID = mp.MaterialID
    GROUP BY mp.UserID, m.CourseID
),
assessment_totals AS (
    SELECT a.CourseID, COUNT(*) AS TotalAssessments
    FROM Assessment a
    GROUP BY a.CourseID
),
assessment_passes AS (
    SELECT e.EnrollmentID, COUNT(*) AS PassedAssessments
    FROM Enrollment e
    INNER JOIN Assessment a ON a.CourseID = e.CourseID
    WHERE EXISTS (
        SELECT 1
        FROM AssessmentSubmission s
        WHERE s.AssessmentID = a.AssessmentID
          AND s.UserID = e.UserID
          AND s.Status <> 'TimedOut'
          AND s.Score IS NOT NULL
          AND s.Score >= (CASE WHEN a.TotalMarks IS NULL OR a.TotalMarks <= 0 THEN 50 ELSE a.TotalMarks * 0.5 END)
    )
    GROUP BY e.EnrollmentID
),
eligibility AS (
    SELECT
        e.EnrollmentID,
        e.UserID,
        e.CourseID,
        c.Title AS CourseTitle,
        COALESCE(lp.PaymentStatus, e.PaymentStatus, 'Pending') AS EffectivePaymentStatus,
        COALESCE(lp.PaystackReference, lp.Reference, e.PaymentRef) AS EffectivePaymentRef,
        COALESCE(mt.TotalMaterials, 0) AS TotalMaterials,
        COALESCE(vm.ViewedMaterials, 0) AS ViewedMaterials,
        COALESCE(at.TotalAssessments, 0) AS TotalAssessments,
        COALESCE(ap.PassedAssessments, 0) AS PassedAssessments,
        CASE WHEN COALESCE(lp.PaymentStatus, e.PaymentStatus, 'Pending') = 'Paid' THEN 1 ELSE 0 END AS IsPaid,
        CASE WHEN COALESCE(vm.ViewedMaterials, 0) >= COALESCE(mt.TotalMaterials, 0) THEN 1 ELSE 0 END AS HasViewedAllMaterials,
        CASE WHEN COALESCE(ap.PassedAssessments, 0) >= COALESCE(at.TotalAssessments, 0) THEN 1 ELSE 0 END AS HasPassedAllRequiredAssessments,
        CASE
            WHEN COALESCE(lp.PaymentStatus, e.PaymentStatus, 'Pending') = 'Paid'
             AND COALESCE(vm.ViewedMaterials, 0) >= COALESCE(mt.TotalMaterials, 0)
             AND COALESCE(ap.PassedAssessments, 0) >= COALESCE(at.TotalAssessments, 0)
            THEN 1 ELSE 0
        END AS EligibleForCertificate,
        cert.CertificateID,
        cert.CertificateNo,
        cert.Status AS CertificateStatus
    FROM Enrollment e
    INNER JOIN Course c ON c.CourseID = e.CourseID
    LEFT JOIN latest_payment lp ON lp.EnrollmentID = e.EnrollmentID
    LEFT JOIN material_totals mt ON mt.CourseID = e.CourseID
    LEFT JOIN viewed_materials vm ON vm.UserID = e.UserID AND vm.CourseID = e.CourseID
    LEFT JOIN assessment_totals at ON at.CourseID = e.CourseID
    LEFT JOIN assessment_passes ap ON ap.EnrollmentID = e.EnrollmentID
    LEFT JOIN Certificate cert ON cert.EnrollmentID = e.EnrollmentID
    WHERE (@target_enrollment_id IS NULL OR e.EnrollmentID = @target_enrollment_id)
      AND (@target_user_id IS NULL OR e.UserID = @target_user_id)
)
SELECT
    EnrollmentID,
    UserID,
    CourseID,
    CourseTitle,
    EffectivePaymentStatus,
    EffectivePaymentRef,
    ViewedMaterials,
    TotalMaterials,
    PassedAssessments,
    TotalAssessments,
    IsPaid,
    HasViewedAllMaterials,
    HasPassedAllRequiredAssessments,
    EligibleForCertificate,
    CASE
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 1 THEN 'READY'
        ELSE 'BLOCKED'
    END AS EligibilityState,
    TRIM(BOTH ', ' FROM CONCAT(
        CASE WHEN IsPaid = 0 THEN 'payment, ' ELSE '' END,
        CASE WHEN HasViewedAllMaterials = 0 THEN 'materials, ' ELSE '' END,
        CASE WHEN HasPassedAllRequiredAssessments = 0 THEN 'assessments, ' ELSE '' END
    )) AS MissingRequirements,
    CASE
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 1 THEN 'Can generate certificate'
        ELSE 'Cannot generate certificate'
    END AS ExpectedOutcome,
    CASE
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 1 THEN 'A: Paid + Materials + Assessments'
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 0 THEN 'B: Paid + Materials only'
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 0 AND HasPassedAllRequiredAssessments = 1 THEN 'C: Paid + Assessments only'
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 0 AND HasPassedAllRequiredAssessments = 0 THEN 'D: Paid only'
        WHEN IsPaid = 0 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 1 THEN 'E: Unpaid + Materials + Assessments'
        WHEN IsPaid = 0 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 0 THEN 'F: Unpaid + Materials only'
        WHEN IsPaid = 0 AND HasViewedAllMaterials = 0 AND HasPassedAllRequiredAssessments = 1 THEN 'G: Unpaid + Assessments only'
        ELSE 'H: None'
    END AS MatrixBucket,
    CertificateID,
    CertificateNo,
    CertificateStatus,
    CASE
        WHEN EligibleForCertificate = 0 AND CertificateID IS NOT NULL AND (CertificateStatus IS NULL OR CertificateStatus <> 'Revoked')
            THEN 'ANOMALY: certificate exists for ineligible enrollment'
        WHEN EligibleForCertificate = 1 AND CertificateID IS NULL
            THEN 'Expected: eligible but not generated yet'
        ELSE ''
    END AS DataQualityNote
FROM eligibility
ORDER BY EnrollmentID;

-- Optional summary by matrix bucket
WITH latest_payment AS (
    SELECT p1.EnrollmentID, p1.PaymentStatus, p1.PaymentID
    FROM Payment p1
    INNER JOIN (
        SELECT EnrollmentID, MAX(PaymentID) AS MaxPaymentID
        FROM Payment
        GROUP BY EnrollmentID
    ) p2 ON p1.EnrollmentID = p2.EnrollmentID AND p1.PaymentID = p2.MaxPaymentID
),
material_totals AS (
    SELECT m.CourseID, COUNT(*) AS TotalMaterials
    FROM Material m
    GROUP BY m.CourseID
),
viewed_materials AS (
    SELECT mp.UserID, m.CourseID, COUNT(*) AS ViewedMaterials
    FROM MaterialProgress mp
    INNER JOIN Material m ON m.MaterialID = mp.MaterialID
    GROUP BY mp.UserID, m.CourseID
),
assessment_totals AS (
    SELECT a.CourseID, COUNT(*) AS TotalAssessments
    FROM Assessment a
    GROUP BY a.CourseID
),
assessment_passes AS (
    SELECT e.EnrollmentID, COUNT(*) AS PassedAssessments
    FROM Enrollment e
    INNER JOIN Assessment a ON a.CourseID = e.CourseID
    WHERE EXISTS (
        SELECT 1
        FROM AssessmentSubmission s
        WHERE s.AssessmentID = a.AssessmentID
          AND s.UserID = e.UserID
          AND s.Status <> 'TimedOut'
          AND s.Score IS NOT NULL
          AND s.Score >= (CASE WHEN a.TotalMarks IS NULL OR a.TotalMarks <= 0 THEN 50 ELSE a.TotalMarks * 0.5 END)
    )
    GROUP BY e.EnrollmentID
),
eligibility AS (
    SELECT
        e.EnrollmentID,
        CASE WHEN COALESCE(lp.PaymentStatus, e.PaymentStatus, 'Pending') = 'Paid' THEN 1 ELSE 0 END AS IsPaid,
        CASE WHEN COALESCE(vm.ViewedMaterials, 0) >= COALESCE(mt.TotalMaterials, 0) THEN 1 ELSE 0 END AS HasViewedAllMaterials,
        CASE WHEN COALESCE(ap.PassedAssessments, 0) >= COALESCE(at.TotalAssessments, 0) THEN 1 ELSE 0 END AS HasPassedAllRequiredAssessments,
        cert.CertificateID
    FROM Enrollment e
    LEFT JOIN latest_payment lp ON lp.EnrollmentID = e.EnrollmentID
    LEFT JOIN material_totals mt ON mt.CourseID = e.CourseID
    LEFT JOIN viewed_materials vm ON vm.UserID = e.UserID AND vm.CourseID = e.CourseID
    LEFT JOIN assessment_totals at ON at.CourseID = e.CourseID
    LEFT JOIN assessment_passes ap ON ap.EnrollmentID = e.EnrollmentID
    LEFT JOIN Certificate cert ON cert.EnrollmentID = e.EnrollmentID
    WHERE (@target_enrollment_id IS NULL OR e.EnrollmentID = @target_enrollment_id)
      AND (@target_user_id IS NULL OR e.UserID = @target_user_id)
)
SELECT
    CASE
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 1 THEN 'A: Paid + Materials + Assessments'
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 0 THEN 'B: Paid + Materials only'
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 0 AND HasPassedAllRequiredAssessments = 1 THEN 'C: Paid + Assessments only'
        WHEN IsPaid = 1 AND HasViewedAllMaterials = 0 AND HasPassedAllRequiredAssessments = 0 THEN 'D: Paid only'
        WHEN IsPaid = 0 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 1 THEN 'E: Unpaid + Materials + Assessments'
        WHEN IsPaid = 0 AND HasViewedAllMaterials = 1 AND HasPassedAllRequiredAssessments = 0 THEN 'F: Unpaid + Materials only'
        WHEN IsPaid = 0 AND HasViewedAllMaterials = 0 AND HasPassedAllRequiredAssessments = 1 THEN 'G: Unpaid + Assessments only'
        ELSE 'H: None'
    END AS MatrixBucket,
    COUNT(*) AS EnrollmentCount,
    SUM(CASE WHEN CertificateID IS NOT NULL THEN 1 ELSE 0 END) AS CertificatesPresent
FROM eligibility
GROUP BY MatrixBucket
ORDER BY MatrixBucket;
