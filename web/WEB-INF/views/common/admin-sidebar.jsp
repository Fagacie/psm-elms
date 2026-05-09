<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="currentQuery" value="${empty pageContext.request.queryString ? '' : pageContext.request.queryString}"/>
<c:set var="isInstructorUsersView" value="${fn:contains(currentPath, '/admin/users') and fn:contains(currentQuery, 'role=Instructor')}"/>
<aside class="app-sidebar">
    <div class="sidebar-section-label">Admin</div>
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${fn:contains(currentPath, '/dashboard') ? 'active' : ''}">
            <i class="fas fa-chart-line"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/users" class="nav-item ${fn:contains(currentPath, '/admin/users') and not isInstructorUsersView ? 'active' : ''}">
            <i class="fas fa-users"></i><span>Users</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/courses" class="nav-item ${fn:contains(currentPath, 'admin/courses') ? 'active' : ''}">
            <i class="fas fa-book"></i><span>Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/enrollments" class="nav-item ${fn:contains(currentPath, 'admin/enrollments') or fn:contains(currentPath, 'admin/enrollment-details') ? 'active' : ''}">
            <i class="fas fa-id-card"></i><span>Enrollments</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/payments" class="nav-item ${fn:contains(currentPath, 'admin/payments') or fn:contains(currentPath, 'admin/payment') ? 'active' : ''}">
            <i class="fas fa-credit-card"></i><span>Payments</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/certificates" class="nav-item ${fn:contains(currentPath, 'admin/certificates') ? 'active' : ''}">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-item ${fn:contains(currentPath, 'reports') ? 'active' : ''}">
            <i class="fas fa-chart-column"></i><span>Reports</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/settings" class="nav-item ${fn:contains(currentPath, 'admin/settings') ? 'active' : ''}">
            <i class="fas fa-cog"></i><span>Settings</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item ${fn:contains(currentPath, '/profile') and not fn:contains(currentPath, 'admin') ? 'active' : ''}">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>
