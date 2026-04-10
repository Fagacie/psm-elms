package com.psm.elearning.filter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Normalizes trailing-slash request paths to avoid duplicate route variants
 * returning 404 when only the non-slash mapping exists.
 */
public class TrailingSlashRedirectFilter implements Filter {

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
        String requestUri = httpRequest.getRequestURI();

        // Keep root context untouched, but normalize any other trailing-slash path.
        if (requestUri != null
                && requestUri.endsWith("/")
                && requestUri.length() > contextPath.length() + 1) {
            String target = requestUri.substring(0, requestUri.length() - 1);
            String query = httpRequest.getQueryString();
            if (query != null && !query.trim().isEmpty()) {
                target = target + "?" + query;
            }
            httpResponse.sendRedirect(target);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no-op
    }
}