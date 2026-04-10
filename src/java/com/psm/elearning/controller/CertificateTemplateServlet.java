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
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class CertificateTemplateServlet extends HttpServlet {

    private static final Set<String> ALLOWED_BACK_PATHS = new HashSet<>(Arrays.asList(
            "/dashboard",
            "/admin/certificates",
            "/instructor/certificates"
    ));

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
        c.setInstructorName("Lead Instructor");
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

    private String resolveRole(HttpSession session) {
        if (session == null) return null;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        if (role == null) return null;
        
        String roleStr = role.toString().trim();
        if ("Admin".equalsIgnoreCase(roleStr)) return "Admin";
        if ("Student".equalsIgnoreCase(roleStr)) return "Student";
        if ("Instructor".equalsIgnoreCase(roleStr)) return "Instructor";
        return null;
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
        if (back.startsWith(contextPath + "/")) {
            String relativePath = back.substring(contextPath.length());
            if (ALLOWED_BACK_PATHS.contains(relativePath)) {
                return back;
            }
            return defaultBack;
        }
        if (back.startsWith("/") && !back.startsWith("//") && ALLOWED_BACK_PATHS.contains(back)) {
            return contextPath + back;
        }
        return defaultBack;
    }

    private boolean canViewCertificate(HttpSession session, CertificateView certificate) {
        if (session == null) return false;
        Integer userId = resolveUserId(session);
        if (userId == null) return false;
        String role = resolveRole(session);

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
