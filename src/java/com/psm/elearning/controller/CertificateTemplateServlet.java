package com.psm.elearning.controller;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.model.CertificateView;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class CertificateTemplateServlet extends HttpServlet {

    private static final Set<String> ALLOWED_BACK_PATHS = new HashSet<>(Arrays.asList(
            "/dashboard",
            "/admin/certificates",
            "/instructor/certificates",
            "/student/certificates",
            "/student/my-enrollments"
    ));

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer certificateId = parseInt(request.getParameter("certificateId"));
        Integer enrollmentId = parseInt(request.getParameter("enrollmentId"));
        CertificateView certificateView;
        if (certificateId != null) {
            certificateView = certificateDAO.findDetailedById(certificateId);
            if (certificateView == null) {
                redirectToWorkspace(request, response, "certificate");
                return;
            }
            if (!canViewCertificate(session, certificateView)) {
                redirectToWorkspace(request, response, "permission");
                return;
            }
        } else if (enrollmentId != null) {
            certificateView = certificateDAO.findDetailedByEnrollment(enrollmentId);
            if (certificateView == null) {
                redirectToWorkspace(request, response, "certificate");
                return;
            }
            if (!canViewCertificate(session, certificateView)) {
                redirectToWorkspace(request, response, "permission");
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

    private String sanitizeBackUrl(HttpServletRequest request, String rawBackUrl) {
        String defaultBack = resolveDefaultBackUrl(request);
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

    private void redirectToWorkspace(HttpServletRequest request,
                                     HttpServletResponse response,
                                     String errorCode) throws IOException {
        String baseUrl = sanitizeBackUrl(request, request.getParameter("back"));
        response.sendRedirect(appendQueryParam(baseUrl, "error", errorCode));
    }

    private String resolveDefaultBackUrl(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        String role = SessionUtil.resolveRole(session);
        String contextPath = request.getContextPath();
        if ("Admin".equals(role)) {
            return contextPath + "/admin/certificates";
        }
        if ("Instructor".equals(role)) {
            return contextPath + "/instructor/certificates";
        }
        if ("Student".equals(role)) {
            return contextPath + "/student/certificates";
        }
        return contextPath + "/dashboard";
    }

    private String appendQueryParam(String baseUrl, String key, String value) {
        String separator = baseUrl.contains("?") ? "&" : "?";
        return baseUrl + separator
                + URLEncoder.encode(key, StandardCharsets.UTF_8)
                + "="
                + URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private boolean canViewCertificate(HttpSession session, CertificateView certificate) {
        if (session == null) return false;
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) return false;
        String role = SessionUtil.resolveRole(session);

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
