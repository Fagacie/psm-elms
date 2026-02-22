package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.model.Certificate;
import com.psm.elearning.model.CertificateView;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.service.EnrollmentStateSyncService;

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

        Integer userId = (Integer) session.getAttribute("userId");
        List<CertificateView> issuedCertificates = certificateDAO.findByUserDetailed(userId);
        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) enrollments = new ArrayList<>();
        List<Enrollment> readyToGenerate = new ArrayList<>();

        for (Enrollment enrollment : enrollments) {
            EnrollmentStateSyncService.SyncResult syncResult = enrollmentStateSyncService.syncEnrollmentState(enrollment);
            if (!syncResult.isEligibleForCertificate()) continue;

            Certificate existing = certificateDAO.findByEnrollment(enrollment.getEnrollmentId());
            if (existing == null) {
                readyToGenerate.add(enrollment);
            }
        }

        request.setAttribute("issuedCertificates", issuedCertificates);
        request.setAttribute("readyToGenerate", readyToGenerate);
        request.getRequestDispatcher("/WEB-INF/views/student/certificates.jsp").forward(request, response);
    }

    private boolean isStudent(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Student".equals(role);
    }
}
