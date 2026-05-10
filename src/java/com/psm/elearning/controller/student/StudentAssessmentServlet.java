package com.psm.elearning.controller.student;

import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.AssessmentQuestionDAO;
import com.psm.elearning.dao.AssessmentQuestionDAOImpl;
import com.psm.elearning.dao.AssessmentGradeAuditDAO;
import com.psm.elearning.dao.AssessmentGradeAuditDAOImpl;
import com.psm.elearning.dao.AssessmentRetakeRequestDAO;
import com.psm.elearning.dao.AssessmentRetakeRequestDAOImpl;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.MaterialProgressDAO;
import com.psm.elearning.dao.MaterialProgressDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentGradeAudit;
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.util.AssessmentPlacementUtil;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@MultipartConfig(maxFileSize = 52428800)
public class StudentAssessmentServlet extends HttpServlet {

    private static final long MAX_ASSIGNMENT_FILE_SIZE = 50L * 1024L * 1024L;

    private static final class RouteContext {
        private final Integer courseId;
        private final Integer assessmentId;
        private final String view;
        private final boolean attemptRequested;

        private RouteContext(Integer courseId, Integer assessmentId, String view, boolean attemptRequested) {
            this.courseId = courseId;
            this.assessmentId = assessmentId;
            this.view = view;
            this.attemptRequested = attemptRequested;
        }
    }

    private EnrollmentDAO enrollmentDAO;
    private AssessmentDAO assessmentDAO;
    private AssessmentQuestionDAO assessmentQuestionDAO;
    private AssessmentSubmissionDAO assessmentSubmissionDAO;
    private AssessmentGradeAuditDAO assessmentGradeAuditDAO;
    private AssessmentRetakeRequestDAO retakeRequestDAO;
    private MaterialDAO materialDAO;
    private MaterialProgressDAO materialProgressDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
        assessmentQuestionDAO = new AssessmentQuestionDAOImpl();
        assessmentSubmissionDAO = new AssessmentSubmissionDAOImpl();
        assessmentGradeAuditDAO = new AssessmentGradeAuditDAOImpl();
        retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
        materialDAO = new MaterialDAOImpl();
        materialProgressDAO = new MaterialProgressDAOImpl();
        paymentDAO = new PaymentDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (!isStudent(session) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        RouteContext routeContext = resolveRouteContext(request.getPathInfo());

        Integer enrollmentId = parseInt(request.getParameter("enrollmentId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer submissionId = parseInt(request.getParameter("submissionId"));
        Integer courseIdParam = parseInt(request.getParameter("courseId"));
        String view = routeContext != null
                ? routeContext.view
                : normalizeView(request.getParameter("view"), request.getParameter("mode"), request.getParameter("action"), assessmentId, submissionId);

        if (routeContext != null) {
            if (assessmentId == null) {
                assessmentId = routeContext.assessmentId;
            }
            if (courseIdParam == null) {
                courseIdParam = routeContext.courseId;
            }
            if (enrollmentId == null && routeContext.courseId != null) {
                Enrollment routeEnrollment = enrollmentDAO.findLatestEnrollmentByUserAndCourse(userId, routeContext.courseId);
                if (routeEnrollment != null) {
                    enrollmentId = routeEnrollment.getEnrollmentId();
                }
            }
        }

        boolean requestedAttemptMode = routeContext != null && routeContext.attemptRequested
                || "attempt".equalsIgnoreCase(request.getParameter("mode"))
                || "start".equalsIgnoreCase(request.getParameter("action"));

        if ("dashboard".equals(view) || "history".equals(view)) {
            if (enrollmentId == null) {
                redirectToLearningHub(request, response);
                return;
            }
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null || enrollment.getUserId() == null || !enrollment.getUserId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }
            if (!hasCourseAccess(enrollment)) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=learning&error=paymentRequired");
                return;
            }
            if ("dashboard".equals(view)) {
                renderDashboard(request, response, session, userId, enrollment);
            } else {
                renderHistory(request, response, session, userId, enrollment);
            }
            return;
        }

        if ("confirmation".equals(view)) {
            if (enrollmentId == null || assessmentId == null || submissionId == null) {
                redirectToLearningHub(request, response);
                return;
            }
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null || enrollment.getUserId() == null || !enrollment.getUserId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }
            if (!hasCourseAccess(enrollment)) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=learning&error=paymentRequired");
                return;
            }
            renderConfirmation(request, response, userId, enrollment, assessmentId, submissionId);
            return;
        }

        if ("result".equals(view)) {
            if (enrollmentId == null || assessmentId == null || submissionId == null) {
                redirectToLearningHub(request, response);
                return;
            }
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null || enrollment.getUserId() == null || !enrollment.getUserId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }
            if (!hasCourseAccess(enrollment)) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=learning&error=paymentRequired");
                return;
            }
            renderResult(request, response, session, userId, enrollment, assessmentId, submissionId);
            return;
        }

        if (assessmentId == null || enrollmentId == null) {
            redirectToLearningHub(request, response);
            return;
        }

        Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
        if (enrollment == null || enrollment.getUserId() == null || !enrollment.getUserId().equals(userId)) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
            return;
        }
        if (!hasCourseAccess(enrollment)) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=learning&error=paymentRequired");
            return;
        }

        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (assessment == null
                || assessment.getCourseId() == null
                || !assessment.getCourseId().equals(enrollment.getCourseId())
                || (courseIdParam != null && !assessment.getCourseId().equals(courseIdParam))) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=invalidAssessment");
            return;
        }

        String materialBlockReason = null;
        Material prerequisiteMaterial = null;
        boolean materialCompleted = true;

        AssessmentPlacementUtil.Placement placement = AssessmentPlacementUtil.parsePlacement(assessment.getInstructions());
        if ("afterMaterial".equals(placement.type) && placement.materialId != null) {
            prerequisiteMaterial = materialDAO.findById(placement.materialId);
            if (prerequisiteMaterial == null) {
                materialBlockReason = "Prerequisites for this assessment are not available.";
            } else if (!prerequisiteMaterial.getCourseId().equals(enrollment.getCourseId())) {
                materialBlockReason = "Prerequisites are not valid for this course.";
            } else {
                Map<Integer, String> statusMap = materialProgressDAO.findMaterialStatusByCourse(userId, enrollment.getCourseId());
                String materialStatus = statusMap != null ? statusMap.get(placement.materialId) : null;
                materialCompleted = "completed".equals(materialStatus);
                if (!materialCompleted) {
                    materialBlockReason = "You must complete '" + prerequisiteMaterial.getTitle() + "' before attempting this assessment.";
                }
            }
        }

        List<AssessmentQuestion> questions = assessmentQuestionDAO.findByAssessment(assessmentId);
        if (questions == null) {
            questions = Collections.emptyList();
        }
        boolean objectiveAssessment = isObjectiveAssessment(assessment);
        String submissionMode = objectiveAssessment ? normalizeSubmissionMode(assessment.getSubmissionMode()) : "file";
        String displayInstructions = AssessmentPlacementUtil.stripPlacement(assessment.getInstructions());

        List<AssessmentSubmission> submissions = assessmentSubmissionDAO.findByAssessmentAndUser(assessmentId, userId);
        int usedAttempts = submissions != null ? submissions.size() : 0;
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        Integer maxAttemptsValue = assessment.getMaxAttempts();
        int baseAttempts = maxAttemptsValue != null && maxAttemptsValue > 0
            ? maxAttemptsValue
            : defaultMaxAttempts;
        int allowedAttempts = baseAttempts + retakeRequestDAO.countApproved(assessmentId, userId);
        boolean isCourseExpired = enrollment.getDaysRemaining() < 0 && enrollment.getCourseDuration() != null && enrollment.getCourseDuration() > 0;
        boolean canAttempt = usedAttempts < Math.max(allowedAttempts, 1) && materialCompleted && materialBlockReason == null && !isCourseExpired;

        boolean attemptMode = requestedAttemptMode && objectiveAssessment;

        if (attemptMode && !canAttempt) {
            if (isCourseExpired) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=expired");
            } else if (materialBlockReason != null) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=blocked&reason=" + java.net.URLEncoder.encode(materialBlockReason, "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=maxAttempts");
            }
            return;
        }

        if (attemptMode && objectiveAssessment && questions.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=noQuestions");
            return;
        }

        if (attemptMode) {
            response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            response.setHeader("X-Frame-Options", "SAMEORIGIN");
            response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        }

        request.setAttribute("assessment", assessment);
        request.setAttribute("questions", questions);
        request.setAttribute("enrollment", enrollment);
        request.setAttribute("usedAttempts", usedAttempts);
        request.setAttribute("allowedAttempts", allowedAttempts);
        request.setAttribute("remainingAttempts", Math.max(allowedAttempts - usedAttempts, 0));
        request.setAttribute("canAttempt", canAttempt);
        request.setAttribute("attemptMode", attemptMode);
        request.setAttribute("latestSubmission", (submissions != null && !submissions.isEmpty()) ? submissions.get(0) : null);
        request.setAttribute("materialBlockReason", materialBlockReason);
        request.setAttribute("prerequisiteMaterial", prerequisiteMaterial);
        request.setAttribute("objectiveAssessment", objectiveAssessment);
        request.setAttribute("submissionMode", submissionMode);
        request.setAttribute("displayInstructions", displayInstructions);
        request.setAttribute("timerStartTime", System.currentTimeMillis());
        request.setAttribute("timerDurationSeconds", assessment.getDuration() != null ? assessment.getDuration() * 60 : 30 * 60);
        request.setAttribute("assessmentSummary", buildAssessmentSummary(enrollment, assessment, submissions, session));

        boolean isFragment = "true".equalsIgnoreCase(request.getParameter("fragment"));
        String targetView;
        if (isFragment) {
            targetView = "details".equals(view) ? "/WEB-INF/views/student/fragments/assessment-details-fragment.jsp" : "/WEB-INF/views/student/fragments/assessment-attempt-fragment.jsp";
        } else {
            targetView = "details".equals(view) ? "/WEB-INF/views/student/assessment-details.jsp" : "/WEB-INF/views/student/assessment-attempt.jsp";
        }
        request.getRequestDispatcher(targetView).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (!isStudent(session) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer enrollmentId = parseInt(request.getParameter("enrollmentId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        String timerStartParam = request.getParameter("timerStart");
        String timerDurationParam = request.getParameter("timerDuration");
        boolean exitSubmission = "1".equals(request.getParameter("exitSubmission"));

        if (enrollmentId == null || assessmentId == null) {
            redirectToLearningHub(request, response);
            return;
        }

        Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (enrollment == null
                || assessment == null
                || enrollment.getUserId() == null
                || !enrollment.getUserId().equals(userId)
                || assessment.getCourseId() == null
                || !assessment.getCourseId().equals(enrollment.getCourseId())) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
            return;
        }
        if (!hasCourseAccess(enrollment)) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=learning&error=paymentRequired");
            return;
        }

        // Check timer expiration
        boolean timedOut = false;
        if (timerStartParam != null && timerDurationParam != null) {
            try {
                long timerStart = Long.parseLong(timerStartParam);
                long timerDuration = Long.parseLong(timerDurationParam);
                long elapsedMillis = System.currentTimeMillis() - timerStart;
                if (elapsedMillis > (timerDuration * 1000)) {
                    timedOut = true;
                }
            } catch (NumberFormatException ex) {
                // Continue processing
            }
        }

        boolean objectiveAssessment = isObjectiveAssessment(assessment);
        String submissionMode = objectiveAssessment ? normalizeSubmissionMode(assessment.getSubmissionMode()) : "file";

        List<AssessmentQuestion> questions = assessmentQuestionDAO.findByAssessment(assessmentId);
        if (questions == null) {
            questions = Collections.emptyList();
        }
        if (objectiveAssessment && questions.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=noQuestions");
            return;
        }

        List<AssessmentSubmission> submissions = assessmentSubmissionDAO.findByAssessmentAndUser(assessmentId, userId);
        int usedAttempts = submissions != null ? submissions.size() : 0;
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        Integer maxAttemptsValue = assessment.getMaxAttempts();
        int baseAttempts = maxAttemptsValue != null && maxAttemptsValue > 0
            ? maxAttemptsValue
            : defaultMaxAttempts;
        int allowedAttempts = baseAttempts + retakeRequestDAO.countApproved(assessmentId, userId);
        boolean isCourseExpired = enrollment.getDaysRemaining() < 0 && enrollment.getCourseDuration() != null && enrollment.getCourseDuration() > 0;
        if (isCourseExpired) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=expired");
            return;
        }
        if (usedAttempts >= Math.max(allowedAttempts, 1)) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=maxAttempts");
            return;
        }

        double totalPossible = 0.0;
        double earned = 0.0;
        StringBuilder answerPayload = new StringBuilder();
        Double finalScore = null;
        boolean autoGraded = objectiveAssessment && "auto".equalsIgnoreCase(assessment.getGradingMode());

        if (objectiveAssessment) {
            for (AssessmentQuestion question : questions) {
                Double questionMarks = question.getMarks();
                double marks = questionMarks != null && questionMarks > 0 ? questionMarks : 1.0;
                totalPossible += marks;
                String key = "q_" + question.getQuestionId();
                String selected = request.getParameter(key);
                if (selected == null) {
                    selected = "";
                }
                String normalized = selected.trim().toUpperCase();
                answerPayload.append("Q").append(question.getQuestionId()).append(":").append(normalized).append(";");
                if (!normalized.isEmpty()
                        && question.getCorrectOption() != null
                        && normalized.equalsIgnoreCase(question.getCorrectOption().trim())) {
                    earned += marks;
                }
            }

            if (autoGraded) {
                if (totalPossible > 0) {
                    double achievedRatio = earned / totalPossible;
                        Integer totalMarksValue = assessment.getTotalMarks();
                        double scoreScale = (totalMarksValue != null && totalMarksValue > 0)
                            ? totalMarksValue
                            : totalPossible;
                    finalScore = round2(achievedRatio * scoreScale);
                } else {
                    finalScore = 0.0;
                }
            }
        } else {
            String answerText = safeTrim(request.getParameter("answerText"));
            String uploadedFileUrl = null;

            try {
                Part answerFilePart = request.getPart("answerFile");
                if (answerFilePart != null && answerFilePart.getSize() > 0) {
                    if (answerFilePart.getSize() > MAX_ASSIGNMENT_FILE_SIZE) {
                        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + assessment.getCourseId() + "&assessmentId=" + assessmentId + "&enrollmentId=" + enrollmentId + "&error=assignmentFileTooLarge");
                        return;
                    }

                    String submittedName = answerFilePart.getSubmittedFileName();
                    String fileName = submittedName != null && !submittedName.trim().isEmpty()
                            ? Paths.get(submittedName).getFileName().toString()
                            : "assignment-submission";
                    String resourceType = resolveCloudinaryResourceType(fileName);

                    try (InputStream in = answerFilePart.getInputStream()) {
                        uploadedFileUrl = CloudinaryUtil.uploadFile(in.readAllBytes(), fileName, CloudinaryUtil.getAssessmentAnswersFolder(), resourceType);
                    }

                    if (uploadedFileUrl == null || uploadedFileUrl.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + assessment.getCourseId() + "&assessmentId=" + assessmentId + "&enrollmentId=" + enrollmentId + "&error=assignmentUploadFailed");
                        return;
                    }
                }
            } catch (IllegalStateException ex) {
                response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + assessment.getCourseId() + "&assessmentId=" + assessmentId + "&enrollmentId=" + enrollmentId + "&error=assignmentFileTooLarge");
                return;
            } catch (ServletException ex) {
                // Continue and fail with missing file validation below when needed.
            }

            boolean shouldValidateContent = !exitSubmission && !timedOut;
            String resolvedFileValue = safeTrim(uploadedFileUrl);

            if (shouldValidateContent) {
                if (resolvedFileValue.isEmpty() && answerText.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + assessment.getCourseId() + "&assessmentId=" + assessmentId + "&enrollmentId=" + enrollmentId + "&error=missingAnswerFile");
                    return;
                }
                if (!answerText.isEmpty() && answerText.length() > 255) {
                    response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + assessment.getCourseId() + "&assessmentId=" + assessmentId + "&enrollmentId=" + enrollmentId + "&error=answerTooLong");
                    return;
                }
            }

            if (!resolvedFileValue.isEmpty()) {
                answerPayload.append(resolvedFileValue);
            } else if (!answerText.isEmpty()) {
                answerPayload.append(answerText);
            }
            finalScore = null;
        }

        AssessmentSubmission submission = new AssessmentSubmission();
        submission.setAssessmentId(assessmentId);
        submission.setUserId(userId);
        submission.setAnswersFilePath(answerPayload.toString());
        submission.setAttemptNumber(usedAttempts + 1);
        // Auto-graded objective assessments should land in Graded state immediately.
        submission.setStatus(timedOut ? "TimedOut" : (autoGraded ? "Graded" : "Submitted"));
        submission.setStartedAt(LocalDateTime.now());
        submission.setEndedAt(LocalDateTime.now());
        submission.setScore(finalScore);

        AssessmentSubmission saved = assessmentSubmissionDAO.submit(submission);
        if (saved == null) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&error=submitFailed");
            return;
        }

        // Centralized enrollment state synchronization on assessment submission
        try {
            new com.psm.elearning.service.EnrollmentStateSyncService().syncEnrollmentState(enrollment);
        } catch (Exception syncEx) {
            java.util.logging.Logger.getLogger(StudentAssessmentServlet.class.getName())
                .log(java.util.logging.Level.WARNING, "StudentAssessmentServlet: sync failed on submit", syncEx);
        }

        String successParam = timedOut ? "timed-out" : (exitSubmission ? "exited" : "submitted");
        response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&success=" + successParam + "&assessmentId=" + assessmentId);
    }

    private void redirectToLearningHub(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String enrollmentId = request.getParameter("enrollmentId");
        if (enrollmentId != null && !enrollmentId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/student/my-enrollments");
    }

    private Integer parseInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private double round2(double value) {
        return Math.round(value * 100.0) / 100.0;
    }

    private boolean isStudent(HttpSession session) {
        return session != null && session.getAttribute("student") != null;
    }

    private boolean isObjectiveAssessment(Assessment assessment) {
        if (assessment == null || assessment.getType() == null) {
            return false;
        }
        String type = assessment.getType().trim();
        return "Quiz".equalsIgnoreCase(type) || "Exam".equalsIgnoreCase(type);
    }

    private String normalizeSubmissionMode(String submissionMode) {
        if (submissionMode == null || submissionMode.trim().isEmpty()) {
            return "both";
        }
        String normalized = submissionMode.trim().toLowerCase();
        if ("file".equals(normalized) || "text".equals(normalized) || "both".equals(normalized)) {
            return normalized;
        }
        return "both";
    }

    private String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeView(String view, String mode, String action, Integer assessmentId, Integer submissionId) {
        if (view != null && !view.trim().isEmpty()) {
            return view.trim().toLowerCase();
        }
        if (submissionId != null) {
            return "result";
        }
        if (assessmentId == null) {
            return "dashboard";
        }
        if ("attempt".equalsIgnoreCase(mode) || "start".equalsIgnoreCase(action)) {
            return "take";
        }
        return "details";
    }

    private RouteContext resolveRouteContext(String pathInfo) {
        if (pathInfo == null || pathInfo.trim().isEmpty() || "/".equals(pathInfo.trim())) {
            return null;
        }

        String[] parts = pathInfo.split("/");
        List<String> tokens = new ArrayList<>();
        for (String part : parts) {
            if (part != null && !part.trim().isEmpty()) {
                tokens.add(part.trim());
            }
        }

        if (tokens.size() < 3) {
            return null;
        }

        Integer courseId = parseInt(tokens.get(0));
        if (courseId == null) {
            return null;
        }

        String resourceType = tokens.get(1).toLowerCase();
        Integer assessmentId = parseInt(tokens.get(2));
        if (assessmentId == null) {
            return null;
        }

        if ("assessments".equals(resourceType)) {
            boolean attemptRequested = tokens.size() >= 4 && "attempt".equalsIgnoreCase(tokens.get(3));
            return new RouteContext(courseId, assessmentId, attemptRequested ? "take" : "details", attemptRequested);
        }

        if ("assignments".equals(resourceType)) {
            return new RouteContext(courseId, assessmentId, "take", false);
        }

        return null;
    }

    private List<StudentAssessmentSummary> buildAssessmentSummaries(Enrollment enrollment, Integer userId, HttpSession session) {
        if (enrollment == null || enrollment.getCourseId() == null) {
            return Collections.emptyList();
        }

        List<Assessment> assessments = assessmentDAO.findByCourse(enrollment.getCourseId());
        if (assessments == null || assessments.isEmpty()) {
            return Collections.emptyList();
        }

        List<StudentAssessmentSummary> summaries = new ArrayList<>();
        for (Assessment assessment : assessments) {
            List<AssessmentSubmission> submissions = assessmentSubmissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), userId);
            summaries.add(buildAssessmentSummary(enrollment, assessment, submissions, session));
        }

        summaries.sort(Comparator.comparing(StudentAssessmentSummary::getCourseName, Comparator.nullsLast(String::compareToIgnoreCase))
                .thenComparing(StudentAssessmentSummary::getAssessmentTitle, Comparator.nullsLast(String::compareToIgnoreCase)));
        return summaries;
    }

    private StudentAssessmentSummary buildAssessmentSummary(Enrollment enrollment, Assessment assessment, List<AssessmentSubmission> submissions, HttpSession session) {
        StudentAssessmentSummary summary = new StudentAssessmentSummary();
        summary.setEnrollment(enrollment);
        summary.setAssessment(assessment);
        summary.setCourseName(enrollment != null ? enrollment.getCourseName() : null);
        summary.setCourseBanner(enrollment != null ? enrollment.getCourseBanner() : null);

        int usedAttempts = submissions != null ? submissions.size() : 0;
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        int baseAttempts = assessment.getMaxAttempts() != null && assessment.getMaxAttempts() > 0 ? assessment.getMaxAttempts() : defaultMaxAttempts;
        int allowedAttempts = baseAttempts + retakeRequestDAO.countApproved(assessment.getAssessmentId(), enrollment.getUserId());
        summary.setUsedAttempts(usedAttempts);
        summary.setAllowedAttempts(allowedAttempts);
        summary.setAttemptsRemaining(Math.max(allowedAttempts - usedAttempts, 0));

        AssessmentSubmission latest = (submissions != null && !submissions.isEmpty()) ? submissions.get(0) : null;
        summary.setLatestSubmission(latest);

        double bestScore = 0.0;
        boolean hasScore = false;
        if (submissions != null) {
            for (AssessmentSubmission submission : submissions) {
                if (submission.getScore() != null) {
                    hasScore = true;
                    bestScore = Math.max(bestScore, submission.getScore());
                }
            }
        }
        summary.setBestScore(hasScore ? bestScore : null);

        List<AssessmentQuestion> questions = assessmentQuestionDAO.findByAssessment(assessment.getAssessmentId());
        summary.setQuestionCount(questions != null ? questions.size() : 0);

        Object activeAttemptState = session != null ? session.getAttribute("assessmentAttempt_" + assessment.getAssessmentId()) : null;
        boolean activeAttempt = false;
        if (activeAttemptState != null) {
            try {
                java.lang.reflect.Field deadlineField = activeAttemptState.getClass().getDeclaredField("deadlineMillis");
                deadlineField.setAccessible(true);
                long deadlineMillis = deadlineField.getLong(activeAttemptState);
                activeAttempt = System.currentTimeMillis() < deadlineMillis;
                if (!activeAttempt && session != null) {
                    session.removeAttribute("assessmentAttempt_" + assessment.getAssessmentId());
                }
            } catch (Exception ignored) {
                activeAttempt = true;
            }
        }
        summary.setActiveAttempt(activeAttempt);

        boolean objectiveAssessment = isObjectiveAssessment(assessment);
        boolean autoGraded = objectiveAssessment && "auto".equalsIgnoreCase(assessment.getGradingMode());
        String statusLabel;
        String statusClass;
        if (activeAttempt) {
            statusLabel = "In Progress";
            statusClass = "status-progress";
        } else if (latest == null) {
            statusLabel = canAttempt(summary) ? "Available" : "Closed";
            statusClass = canAttempt(summary) ? "status-available" : "status-closed";
        } else if (latest.getScore() != null && (autoGraded || "Graded".equalsIgnoreCase(latest.getStatus()))) {
            statusLabel = "Graded";
            statusClass = "status-graded";
        } else if ("TimedOut".equalsIgnoreCase(latest.getStatus())) {
            statusLabel = "Closed";
            statusClass = "status-closed";
        } else if ("Submitted".equalsIgnoreCase(latest.getStatus()) || "AutoSubmitted".equalsIgnoreCase(latest.getStatus())) {
            statusLabel = objectiveAssessment ? (autoGraded ? "Graded" : "Awaiting Review") : "Awaiting Review";
            statusClass = autoGraded ? "status-graded" : "status-awaiting";
        } else {
            statusLabel = canAttempt(summary) ? "Available" : "Closed";
            statusClass = canAttempt(summary) ? "status-available" : "status-closed";
        }
        summary.setStatusLabel(statusLabel);
        summary.setStatusClass(statusClass);
        summary.setAssessmentTitle(assessment.getTitle());
        summary.setAssessmentType(assessment.getType());
        return summary;
    }

    private boolean canAttempt(StudentAssessmentSummary summary) {
        return summary != null && summary.getAttemptsRemaining() != null && summary.getAttemptsRemaining() > 0;
    }

    private boolean hasCourseAccess(Enrollment enrollment) {
        if (enrollment == null) {
            return false;
        }
        if (isFreeEnrollment(enrollment)) {
            return true;
        }
        if (enrollment.getEnrollmentId() == null) {
            return false;
        }
        Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
        if (payment != null && isPaymentComplete(payment.getStatus())) {
            return true;
        }
        return isPaymentComplete(enrollment.getPaymentStatus());
    }

    private boolean isFreeEnrollment(Enrollment enrollment) {
        return enrollment != null
                && enrollment.getCoursePrice() != null
                && enrollment.getCoursePrice() <= 0.0;
    }

    private boolean isPaymentComplete(String paymentStatus) {
        if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
            return false;
        }
        String normalized = paymentStatus.trim();
        return "Paid".equalsIgnoreCase(normalized)
                || "Completed".equalsIgnoreCase(normalized)
                || "Success".equalsIgnoreCase(normalized);
    }

    private Map<Integer, String> parseObjectiveAnswers(String answerPayload) {
        Map<Integer, String> answerMap = new LinkedHashMap<>();
        if (answerPayload == null || answerPayload.trim().isEmpty()) {
            return answerMap;
        }
        String[] parts = answerPayload.split(";");
        for (String part : parts) {
            String trimmed = part == null ? "" : part.trim();
            if (trimmed.isEmpty() || !trimmed.startsWith("Q") || !trimmed.contains(":")) {
                continue;
            }
            int colonIndex = trimmed.indexOf(':');
            String questionPart = trimmed.substring(1, colonIndex);
            String answerPart = trimmed.substring(colonIndex + 1).trim();
            try {
                answerMap.put(Integer.parseInt(questionPart), answerPart);
            } catch (NumberFormatException ignored) {
            }
        }
        return answerMap;
    }

    private void renderDashboard(HttpServletRequest request, HttpServletResponse response, HttpSession session, Integer userId, Enrollment enrollment)
            throws ServletException, IOException {
        List<StudentAssessmentSummary> summaries = buildAssessmentSummaries(enrollment, userId, session);
        int availableCount = 0;
        int pendingCount = 0;
        int completedCount = 0;
        double scoreSum = 0.0;
        int scoreCount = 0;
        for (StudentAssessmentSummary summary : summaries) {
            if ("Graded".equalsIgnoreCase(summary.getStatusLabel())) {
                completedCount++;
            } else if ("Awaiting Review".equalsIgnoreCase(summary.getStatusLabel())) {
                pendingCount++;
            } else if ("Available".equalsIgnoreCase(summary.getStatusLabel()) || "In Progress".equalsIgnoreCase(summary.getStatusLabel())) {
                availableCount++;
            }
            if (summary.getBestScore() != null) {
                scoreSum += summary.getBestScore();
                scoreCount++;
            }
        }

        request.setAttribute("enrollment", enrollment);
        request.setAttribute("assessmentSummaries", summaries);
        request.setAttribute("paidAccess", hasCourseAccess(enrollment));
        request.setAttribute("upcomingCount", availableCount);
        request.setAttribute("pendingReviewCount", pendingCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("averageScore", scoreCount > 0 ? round2(scoreSum / scoreCount) : null);
        request.setAttribute("searchQuery", safeTrim(request.getParameter("q")));
        request.setAttribute("statusFilter", safeTrim(request.getParameter("status")));
        request.getRequestDispatcher("/WEB-INF/views/student/assessment-dashboard.jsp").forward(request, response);
    }

    private void renderHistory(HttpServletRequest request, HttpServletResponse response, HttpSession session, Integer userId, Enrollment enrollment)
            throws ServletException, IOException {
        List<StudentAssessmentSummary> summaries = buildAssessmentSummaries(enrollment, userId, session);
        request.setAttribute("enrollment", enrollment);
        request.setAttribute("assessmentSummaries", summaries);
        request.getRequestDispatcher("/WEB-INF/views/student/assessment-history.jsp").forward(request, response);
    }

    private void renderConfirmation(HttpServletRequest request, HttpServletResponse response, Integer userId, Enrollment enrollment, Integer assessmentId, Integer submissionId)
            throws ServletException, IOException {
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentSubmission submission = assessmentSubmissionDAO.findById(submissionId);
        if (assessment == null || submission == null || !submission.getUserId().equals(userId) || !submission.getAssessmentId().equals(assessmentId)) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&tab=assessments&error=invalidSubmission");
            return;
        }

        List<AssessmentGradeAudit> audits = assessmentGradeAuditDAO.findBySubmission(submissionId);
        request.setAttribute("assessment", assessment);
        request.setAttribute("enrollment", enrollment);
        request.setAttribute("submission", submission);
        request.setAttribute("submissionAudits", audits);
        request.setAttribute("submissionStatusLabel", humanizeSubmissionStatus(submission));
        request.setAttribute("statusClass", statusClassForSubmission(submission));
        request.getRequestDispatcher("/WEB-INF/views/student/assessment-confirmation.jsp").forward(request, response);
    }

    private void renderResult(HttpServletRequest request, HttpServletResponse response, HttpSession session, Integer userId, Enrollment enrollment, Integer assessmentId, Integer submissionId)
            throws ServletException, IOException {
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentSubmission submission = assessmentSubmissionDAO.findById(submissionId);
        if (assessment == null || submission == null || !submission.getUserId().equals(userId) || !submission.getAssessmentId().equals(assessmentId)) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&tab=assessments&error=invalidSubmission");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id="
                + enrollment.getEnrollmentId()
                + "&tab=assessments&view=result&assessmentId=" + assessmentId
                + "&submissionId=" + submissionId);
    }

    private double computePercentage(Double score, Integer totalMarks) {
        if (score == null || totalMarks == null || totalMarks <= 0) {
            return 0.0;
        }
        return round2((score / totalMarks) * 100.0);
    }

    private String humanizeSubmissionStatus(AssessmentSubmission submission) {
        if (submission == null || submission.getStatus() == null || submission.getStatus().trim().isEmpty()) {
            return "Awaiting Review";
        }
        String status = submission.getStatus().trim();
        if ("Graded".equalsIgnoreCase(status)) {
            return "Graded";
        }
        if ("TimedOut".equalsIgnoreCase(status)) {
            return "Timed Out";
        }
        if ("AutoSubmitted".equalsIgnoreCase(status)) {
            return "Submitted";
        }
        return "Awaiting Review";
    }

    private String statusClassForSubmission(AssessmentSubmission submission) {
        if (submission == null || submission.getStatus() == null) {
            return "status-awaiting";
        }
        String status = submission.getStatus().trim();
        if ("Graded".equalsIgnoreCase(status)) {
            return "status-graded";
        }
        if ("TimedOut".equalsIgnoreCase(status)) {
            return "status-closed";
        }
        return "status-awaiting";
    }

    public static class StudentAssessmentSummary {
        private Enrollment enrollment;
        private Assessment assessment;
        private String courseName;
        private String courseBanner;
        private String assessmentTitle;
        private String assessmentType;
        private Integer usedAttempts;
        private Integer allowedAttempts;
        private Integer attemptsRemaining;
        private Integer questionCount;
        private Double bestScore;
        private AssessmentSubmission latestSubmission;
        private boolean activeAttempt;
        private String statusLabel;
        private String statusClass;

        public Enrollment getEnrollment() { return enrollment; }
        public void setEnrollment(Enrollment enrollment) { this.enrollment = enrollment; }
        public Assessment getAssessment() { return assessment; }
        public void setAssessment(Assessment assessment) { this.assessment = assessment; }
        public String getCourseName() { return courseName; }
        public void setCourseName(String courseName) { this.courseName = courseName; }
        public String getCourseBanner() { return courseBanner; }
        public void setCourseBanner(String courseBanner) { this.courseBanner = courseBanner; }
        public String getAssessmentTitle() { return assessmentTitle; }
        public void setAssessmentTitle(String assessmentTitle) { this.assessmentTitle = assessmentTitle; }
        public String getAssessmentType() { return assessmentType; }
        public void setAssessmentType(String assessmentType) { this.assessmentType = assessmentType; }
        public Integer getUsedAttempts() { return usedAttempts; }
        public void setUsedAttempts(Integer usedAttempts) { this.usedAttempts = usedAttempts; }
        public Integer getAllowedAttempts() { return allowedAttempts; }
        public void setAllowedAttempts(Integer allowedAttempts) { this.allowedAttempts = allowedAttempts; }
        public Integer getAttemptsRemaining() { return attemptsRemaining; }
        public void setAttemptsRemaining(Integer attemptsRemaining) { this.attemptsRemaining = attemptsRemaining; }
        public Integer getQuestionCount() { return questionCount; }
        public void setQuestionCount(Integer questionCount) { this.questionCount = questionCount; }
        public Double getBestScore() { return bestScore; }
        public void setBestScore(Double bestScore) { this.bestScore = bestScore; }
        public AssessmentSubmission getLatestSubmission() { return latestSubmission; }
        public void setLatestSubmission(AssessmentSubmission latestSubmission) { this.latestSubmission = latestSubmission; }
        public boolean isActiveAttempt() { return activeAttempt; }
        public void setActiveAttempt(boolean activeAttempt) { this.activeAttempt = activeAttempt; }
        public String getStatusLabel() { return statusLabel; }
        public void setStatusLabel(String statusLabel) { this.statusLabel = statusLabel; }
        public String getStatusClass() { return statusClass; }
        public void setStatusClass(String statusClass) { this.statusClass = statusClass; }
    }

    private String resolveCloudinaryResourceType(String fileName) {
        String extension = "";
        if (fileName != null) {
            int dotIndex = fileName.lastIndexOf('.');
            if (dotIndex >= 0 && dotIndex < fileName.length() - 1) {
                extension = fileName.substring(dotIndex + 1).toLowerCase();
            }
        }

        if ("jpg".equals(extension) || "jpeg".equals(extension) || "png".equals(extension)
                || "gif".equals(extension) || "webp".equals(extension)) {
            return "image";
        }
        if ("mp4".equals(extension) || "mov".equals(extension) || "webm".equals(extension)
                || "m4v".equals(extension)) {
            return "video";
        }
        return "raw";
    }
}

