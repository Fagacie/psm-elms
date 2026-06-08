package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.MaterialProgressDAO;
import com.psm.elearning.dao.MaterialProgressDAOImpl;
import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAOImpl;
import com.psm.elearning.dao.AssessmentQuestionDAO;
import com.psm.elearning.dao.AssessmentQuestionDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Certificate;
import com.psm.elearning.model.CertificateView;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class StudentCertificatesServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final MaterialProgressDAO materialProgressDAO = new MaterialProgressDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();
    private final AssessmentQuestionDAO assessmentQuestionDAO = new AssessmentQuestionDAOImpl();
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();
    private final StudentAccessService studentAccessService = new StudentAccessService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!studentAccessService.isStudentSession(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<CertificateView> issuedCertificates = certificateDAO.findByUserDetailed(userId);
        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) enrollments = new ArrayList<>();
        List<Enrollment> readyToGenerate = new ArrayList<>();
        List<ReadinessItem> blockedEnrollments = new ArrayList<>();
        List<Enrollment> nonCertificateEnrollments = new ArrayList<>();

        List<Integer> courseIds = new ArrayList<>();
        List<Integer> enrollmentIds = new ArrayList<>();
        for (Enrollment e : enrollments) {
            if (issuesCertificate(e)) {
                if (e.getCourseId() != null) {
                    courseIds.add(e.getCourseId());
                }
                if (e.getEnrollmentId() != null) {
                    enrollmentIds.add(e.getEnrollmentId());
                }
            }
        }

        List<Material> allMaterials = new ArrayList<>();
        List<Assessment> allAssessments = new ArrayList<>();
        List<Payment> allPayments = new ArrayList<>();
        List<AssessmentQuestion> allQuestions = new ArrayList<>();
        Map<Integer, Integer> viewedMaterialsCountMap = new HashMap<>();

        if (!courseIds.isEmpty()) {
            allMaterials = materialDAO.findByCourseIds(courseIds);
            allAssessments = assessmentDAO.findByCourseIds(courseIds);
            viewedMaterialsCountMap = materialProgressDAO.countViewedByCourses(userId, courseIds);
        }
        if (!enrollmentIds.isEmpty()) {
            allPayments = paymentDAO.getPaymentsByEnrollmentIds(enrollmentIds);
        }
        List<AssessmentSubmission> allSubmissions = submissionDAO.findByUser(userId);
        if (allSubmissions == null) allSubmissions = new ArrayList<>();

        List<Integer> assessmentIds = new ArrayList<>();
        for (Assessment a : allAssessments) {
            if (a != null && a.getAssessmentId() != null) {
                assessmentIds.add(a.getAssessmentId());
            }
        }
        if (!assessmentIds.isEmpty()) {
            allQuestions = assessmentQuestionDAO.findByAssessmentIds(assessmentIds);
        }
        if (allQuestions == null) allQuestions = new ArrayList<>();

        Map<Integer, List<Material>> materialsByCourse = new HashMap<>();
        for (Material m : allMaterials) {
            if (m != null && m.getCourseId() != null) {
                materialsByCourse.computeIfAbsent(m.getCourseId(), k -> new ArrayList<>()).add(m);
            }
        }

        Map<Integer, List<Assessment>> assessmentsByCourse = new HashMap<>();
        for (Assessment a : allAssessments) {
            if (a != null && a.getCourseId() != null) {
                assessmentsByCourse.computeIfAbsent(a.getCourseId(), k -> new ArrayList<>()).add(a);
            }
        }

        Map<Integer, Payment> paymentsByEnrollment = new HashMap<>();
        for (Payment p : allPayments) {
            if (p != null && p.getEnrollmentId() != null) {
                paymentsByEnrollment.put(p.getEnrollmentId(), p);
            }
        }

        for (Enrollment enrollment : enrollments) {
            if (!issuesCertificate(enrollment)) {
                nonCertificateEnrollments.add(enrollment);
                continue;
            }

            List<Material> materials = materialsByCourse.getOrDefault(enrollment.getCourseId(), new ArrayList<>());
            List<Assessment> assessments = assessmentsByCourse.getOrDefault(enrollment.getCourseId(), new ArrayList<>());
            Payment payment = paymentsByEnrollment.get(enrollment.getEnrollmentId());
            int viewedMaterials = viewedMaterialsCountMap.getOrDefault(enrollment.getCourseId(), 0);

            EnrollmentStateSyncService.SyncResult syncResult = enrollmentStateSyncService.syncEnrollmentState(
                enrollment,
                payment,
                materials,
                viewedMaterials,
                assessments,
                allSubmissions,
                allQuestions
            );
            boolean hasCertificate = false;
            if (issuedCertificates != null) {
                for (CertificateView cv : issuedCertificates) {
                    if (cv != null && cv.getEnrollmentId() == enrollment.getEnrollmentId()) {
                        hasCertificate = true;
                        break;
                    }
                }
            }
            if (hasCertificate) {
                continue;
            }

            if (syncResult.isEligibleForCertificate()) {
                readyToGenerate.add(enrollment);
            } else {
                blockedEnrollments.add(new ReadinessItem(enrollment, syncResult));
            }
        }

        request.setAttribute("issuedCertificates", issuedCertificates);
        request.setAttribute("readyToGenerate", readyToGenerate);
        request.setAttribute("blockedEnrollments", blockedEnrollments);
        request.setAttribute("nonCertificateEnrollments", nonCertificateEnrollments);
        request.getRequestDispatcher("/WEB-INF/views/student/certificates.jsp").forward(request, response);
    }

    public static class ReadinessItem {
        private final Enrollment enrollment;
        private final EnrollmentStateSyncService.SyncResult syncResult;

        public ReadinessItem(Enrollment enrollment, EnrollmentStateSyncService.SyncResult syncResult) {
            this.enrollment = enrollment;
            this.syncResult = syncResult;
        }

        public Enrollment getEnrollment() {
            return enrollment;
        }

        public EnrollmentStateSyncService.SyncResult getSyncResult() {
            return syncResult;
        }
    }

    private boolean issuesCertificate(Enrollment enrollment) {
        return enrollment != null
                && !studentAccessService.isFreeEnrollment(enrollment);
    }
}
