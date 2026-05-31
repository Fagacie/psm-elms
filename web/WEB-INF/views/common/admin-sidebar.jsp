<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<aside class="app-sidebar">
    <div class="sidebar-section-label">Admin Console</div>
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${fn:contains(currentPath, '/dashboard') ? 'active' : ''}">
            <i data-lucide="layout-dashboard"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/users" class="nav-item ${fn:contains(currentPath, '/admin/users') ? 'active' : ''}">
            <i data-lucide="users"></i><span>Users</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/courses" class="nav-item ${fn:contains(currentPath, 'admin/courses') ? 'active' : ''}">
            <i data-lucide="book-open"></i><span>Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/enrollments" class="nav-item ${fn:contains(currentPath, 'admin/enrollments') or fn:contains(currentPath, 'admin/enrollment-details') ? 'active' : ''}">
            <i data-lucide="graduation-cap"></i><span>Enrollments</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/payments" class="nav-item ${fn:contains(currentPath, 'admin/payments') ? 'active' : ''}">
            <i data-lucide="credit-card"></i><span>Payments</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/certificates" class="nav-item ${fn:contains(currentPath, 'admin/certificates') ? 'active' : ''}">
            <i data-lucide="award"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-item ${fn:contains(currentPath, 'reports') ? 'active' : ''}">
            <i data-lucide="bar-chart-2"></i><span>Reports</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item ${fn:contains(currentPath, '/profile') ? 'active' : ''}">
            <i data-lucide="user-circle"></i><span>Profile</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/settings" class="nav-item ${fn:contains(currentPath, 'admin/settings') ? 'active' : ''}">
            <i data-lucide="settings"></i><span>Settings</span>
        </a>
    </nav>
</aside>
