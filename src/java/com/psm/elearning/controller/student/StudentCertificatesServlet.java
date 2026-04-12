package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.model.Certificate;
import com.psm.elearning.model.CertificateView;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class StudentCertificatesServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
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

        for (Enrollment enrollment : enrollments) {
            if (enrollment.getCoursePrice() == null || enrollment.getCoursePrice() <= 0) {
                continue;
            }
            EnrollmentStateSyncService.SyncResult syncResult = enrollmentStateSyncService.syncEnrollmentState(enrollment);
            Certificate existing = certificateDAO.findByEnrollment(enrollment.getEnrollmentId());
            if (existing != null) {
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

    private boolean isStudent(HttpSession session) {
        return SessionUtil.resolveUserId(session) != null && "Student".equals(SessionUtil.resolveRole(session));
    }
}
