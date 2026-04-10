package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
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

public class AdminCertificateServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<CertificateView> certificates = certificateDAO.findAllDetailed();
        request.setAttribute("certificates", certificates);
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-certificates.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("revoke".equalsIgnoreCase(action)) {
            handleRevoke(request, response, session);
            return;
        }
        if ("backfill".equalsIgnoreCase(action)) {
            handleBackfill(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/certificates?error=invalid");
    }

    private void handleRevoke(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        Integer userId = resolveUserId(session);
        Integer certificateId = parseInt(request.getParameter("certificateId"));
        if (certificateId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/certificates?error=invalid");
            return;
        }

        boolean revoked = certificateDAO.revoke(certificateId, userId);
        response.sendRedirect(request.getContextPath() + "/admin/certificates" + (revoked ? "?success=revoked" : "?error=revoke"));
    }

    private void handleBackfill(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int updated = 0;
        int errors = 0;

        List<Enrollment> enrollments = enrollmentDAO.getAllEnrollments();
        if (enrollments == null) enrollments = new ArrayList<>();

        for (Enrollment enrollment : enrollments) {
            try {
                if (enrollment.getEnrollmentId() == null || enrollment.getCourseId() == null || enrollment.getUserId() == null) {
                    continue;
                }
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
                updated++;
            } catch (Exception ex) {
                errors++;
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/certificates?success=backfill&updated=" + updated + "&errors=" + errors);
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Admin".equals(role);
    }

    private Integer resolveUserId(HttpSession session) {
        if (session == null) return null;
        Object userId = session.getAttribute("userId");
        if (userId == null) return null;
        
        if (userId instanceof Integer) {
            int id = (Integer) userId;
            return id > 0 ? id : null;
        }
        
        if (userId instanceof String) {
            try {
                int id = Integer.parseInt((String) userId);
                return id > 0 ? id : null;
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
}
