<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="currentPath" value="${pageContext.request.requestURI}"/>

<!-- Resolve active page from URL -->
<c:set var="resolvedActivePage" value="dashboard"/>
<c:choose>
    <c:when test="${fn:contains(currentPath, '/admin/users')}"><c:set var="resolvedActivePage" value="users"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/courses')}"><c:set var="resolvedActivePage" value="courses"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/enrollments') or fn:contains(currentPath, '/admin/enrollment-details')}"><c:set var="resolvedActivePage" value="enrollments"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/payments') or fn:contains(currentPath, '/admin/payment')}"><c:set var="resolvedActivePage" value="payments"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/certificates')}"><c:set var="resolvedActivePage" value="certificates"/></c:when>
    <c:when test="${fn:contains(currentPath, '/reports')}"><c:set var="resolvedActivePage" value="reports"/></c:when>
    <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedActivePage" value="profile"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/settings')}"><c:set var="resolvedActivePage" value="settings"/></c:when>
</c:choose>

<aside class="adm_nav_sidebar" id="admSidebar" aria-label="Admin sidebar navigation">
    <div class="adm_nav_sidebar_shell">
        <nav class="adm_nav_nav" aria-label="Admin navigation">
            <%-- Platform Section --%>
            <span class="adm_nav_section_label">Platform</span>
            <a href="${pageContext.request.contextPath}/dashboard"
               class="adm_nav_link ${resolvedActivePage == 'dashboard' ? 'active' : ''}"
               title="Dashboard">
                <i data-lucide="layout-dashboard" aria-hidden="true"></i>
                <span class="adm_nav_label">Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/users"
               class="adm_nav_link ${resolvedActivePage == 'users' ? 'active' : ''}"
               title="Users">
                <i data-lucide="users" aria-hidden="true"></i>
                <span class="adm_nav_label">Users</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/courses"
               class="adm_nav_link ${resolvedActivePage == 'courses' ? 'active' : ''}"
               title="Courses">
                <i data-lucide="book-open" aria-hidden="true"></i>
                <span class="adm_nav_label">Courses</span>
            </a>

            <%-- Operations Section --%>
            <div class="adm_nav_divider" aria-hidden="true"></div>
            <span class="adm_nav_section_label">Operations</span>
            <a href="${pageContext.request.contextPath}/admin/enrollments"
               class="adm_nav_link ${resolvedActivePage == 'enrollments' ? 'active' : ''}"
               title="Enrollments">
                <i data-lucide="graduation-cap" aria-hidden="true"></i>
                <span class="adm_nav_label">Enrollments</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/payments"
               class="adm_nav_link ${resolvedActivePage == 'payments' ? 'active' : ''}"
               title="Payments">
                <i data-lucide="credit-card" aria-hidden="true"></i>
                <span class="adm_nav_label">Payments</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/certificates"
               class="adm_nav_link ${resolvedActivePage == 'certificates' ? 'active' : ''}"
               title="Certificates">
                <i data-lucide="award" aria-hidden="true"></i>
                <span class="adm_nav_label">Certificates</span>
            </a>
            <a href="${pageContext.request.contextPath}/reports"
               class="adm_nav_link ${resolvedActivePage == 'reports' ? 'active' : ''}"
               title="Reports">
                <i data-lucide="bar-chart-2" aria-hidden="true"></i>
                <span class="adm_nav_label">Reports</span>
            </a>

            <%-- Account Section --%>
            <div class="adm_nav_divider" aria-hidden="true"></div>
            <span class="adm_nav_section_label">Account</span>
            <a href="${pageContext.request.contextPath}/profile"
               class="adm_nav_link ${resolvedActivePage == 'profile' ? 'active' : ''}"
               title="Profile">
                <i data-lucide="user-circle" aria-hidden="true"></i>
                <span class="adm_nav_label">Profile</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/settings"
               class="adm_nav_link ${resolvedActivePage == 'settings' ? 'active' : ''}"
               title="Settings">
                <i data-lucide="settings" aria-hidden="true"></i>
                <span class="adm_nav_label">Settings</span>
            </a>

            <div class="adm_nav_spacer" aria-hidden="true"></div>

            <a href="${pageContext.request.contextPath}/logout"
               class="adm_nav_link adm_nav_link_danger"
               title="Logout">
                <i data-lucide="log-out" aria-hidden="true"></i>
                <span class="adm_nav_label">Logout</span>
            </a>
        </nav>
    </div>
</aside>
