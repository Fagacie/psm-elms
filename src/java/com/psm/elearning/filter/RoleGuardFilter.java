package com.psm.elearning.filter;

import com.psm.elearning.model.User;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Centralized route guard for role-based sections.
 */
public class RoleGuardFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
        // no-op
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String contextPath = httpRequest.getContextPath();
        String uri = httpRequest.getRequestURI();
        String path = uri.substring(contextPath.length());

        HttpSession session = httpRequest.getSession(false);
        String role = resolveRole(session);

        if (isProtectedPath(path) && role == null) {
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }

        if (role != null && !isAuthorized(path, role)) {
            httpResponse.sendRedirect(contextPath + "/dashboard");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no-op
    }

    private boolean isProtectedPath(String path) {
        return path.startsWith("/admin/")
                || path.startsWith("/student/")
                || path.startsWith("/instructor/")
                || "/reports".equals(path);
    }

    private boolean isAuthorized(String path, String role) {
        if (path.startsWith("/admin/")) {
            return User.ROLE_ADMIN.equals(role);
        }
        if (path.startsWith("/student/")) {
            return User.ROLE_STUDENT.equals(role);
        }
        if (path.startsWith("/instructor/")) {
            return User.ROLE_INSTRUCTOR.equals(role);
        }
        if ("/reports".equals(path)) {
            return User.ROLE_ADMIN.equals(role);
        }
        return true;
    }

    private String resolveRole(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object role = session.getAttribute("role");
        if (role == null) {
            role = session.getAttribute("userRole");
        }
        return role != null ? String.valueOf(role) : null;
    }
}