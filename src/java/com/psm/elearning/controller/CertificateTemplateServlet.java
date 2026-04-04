package com.psm.elearning.controller;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.model.CertificateView;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;

public class CertificateTemplateServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer certificateId = parseInt(request.getParameter("certificateId"));
        CertificateView certificateView;
        if (certificateId != null) {
            certificateView = certificateDAO.findDetailedById(certificateId);
            if (certificateView == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=certificate");
                return;
            }
            if (!canViewCertificate(session, certificateView)) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=permission");
                return;
            }
        } else {
            certificateView = buildPreviewTemplate();
            request.setAttribute("previewMode", true);
        }

        String backUrl = sanitizeBackUrl(request, request.getParameter("back"));

        request.setAttribute("certificate", certificateView);
        request.setAttribute("backUrl", backUrl);
        request.getRequestDispatcher("/WEB-INF/views/certificate-template.jsp").forward(request, response);
    }

    private CertificateView buildPreviewTemplate() {
        CertificateView c = new CertificateView();
        c.setCertificateNo("PSM-CERT-20260216-PREVIEW");
        c.setCourseName("Advanced Database Systems");
        c.setStudentName("Student Full Name");
        c.setRegNumber("PSM/STU/2026/0001");
        c.setGeneratedBy("System Auto");
        c.setIssueDate(LocalDateTime.now());
        c.setVerificationURL("https://example.com/certificate/verify?code=PSM-CERT-20260216-PREVIEW");
        return c;
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String sanitizeBackUrl(HttpServletRequest request, String rawBackUrl) {
        String defaultBack = request.getContextPath() + "/dashboard";
        if (rawBackUrl == null) {
            return defaultBack;
        }

        String back = rawBackUrl.trim();
        if (back.isEmpty()) {
            return defaultBack;
        }

        String contextPath = request.getContextPath();
        if (back.startsWith(contextPath + "/") || back.equals(contextPath)) {
            return back;
        }
        if (back.startsWith("/") && !back.startsWith("//")) {
            return contextPath + back;
        }
        return defaultBack;
    }

    private boolean canViewCertificate(HttpSession session, CertificateView certificate) {
        if (session == null) return false;
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) return false;
        String role = (String) session.getAttribute("userRole");
        if (role == null) role = (String) session.getAttribute("role");

        if ("Admin".equals(role)) return true;
        if ("Instructor".equals(role)) {
            return certificate.getCourseCreatedBy() != null && certificate.getCourseCreatedBy().equals(userId);
        }
        if ("Student".equals(role)) {
            return certificate.getStudentUserId() != null && certificate.getStudentUserId().equals(userId);
        }
        return false;
    }
}
