package com.psm.elearning.controller.instructor;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.model.CertificateView;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class InstructorCertificateServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        List<CertificateView> certificates = certificateDAO.findByInstructorDetailed(userId);
        request.setAttribute("certificates", certificates);
        request.getRequestDispatcher("/WEB-INF/views/instructor/course-certificates.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (!"revoke".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/instructor/certificates?error=invalid");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        Integer certificateId = parseInt(request.getParameter("certificateId"));
        if (certificateId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/certificates?error=invalid");
            return;
        }

        boolean revoked = certificateDAO.revoke(certificateId, userId);
        response.sendRedirect(request.getContextPath() + "/instructor/certificates" + (revoked ? "?success=revoked" : "?error=revoke"));
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isInstructor(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Instructor".equals(role);
    }
}
