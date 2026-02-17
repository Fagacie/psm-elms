package com.psm.elearning.controller.admin;

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

public class AdminCertificateServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();

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

    private boolean isAdmin(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Admin".equals(role);
    }
}
