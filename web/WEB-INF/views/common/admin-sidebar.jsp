<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<aside class="app-sidebar">
    <div class="sidebar-section-label">Admin</div>
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${fn:contains(currentPath, 'dashboard') ? 'active' : ''}">
            <i class="fas fa-chart-line"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/users" class="nav-item ${fn:contains(currentPath, 'admin/users') and not fn:contains(currentPath, 'admin/user-form') ? 'active' : ''}">
            <i class="fas fa-users"></i><span>Users</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/instructor-applications" class="nav-item ${fn:contains(currentPath, 'admin/instructor-applications') ? 'active' : ''}">
            <i class="fas fa-file-signature"></i><span>Applications</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/courses" class="nav-item ${fn:contains(currentPath, 'admin/courses') ? 'active' : ''}">
            <i class="fas fa-book"></i><span>Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/users?role=Instructor" class="nav-item ${fn:contains(currentPath, 'admin/instructors') ? 'active' : ''}">
            <i class="fas fa-chalkboard-teacher"></i><span>Instructors</span>
        </a>
        <a href="${pageContext.request.contextPath}/dashboard#analytics" class="nav-item">
            <i class="fas fa-chart-bar"></i><span>Analytics</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/settings" class="nav-item ${fn:contains(currentPath, 'admin/settings') ? 'active' : ''}">
            <i class="fas fa-cog"></i><span>Settings</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/payments" class="nav-item ${fn:contains(currentPath, 'admin/payments') ? 'active' : ''}">
            <i class="fas fa-credit-card"></i><span>Payment</span>
        </a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-item ${fn:contains(currentPath, 'reports') ? 'active' : ''}">
            <i class="fas fa-chart-column"></i><span>Reports</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/certificates" class="nav-item ${fn:contains(currentPath, 'admin/certificates') ? 'active' : ''}">
            <i class="fas fa-certificate"></i><span>Certificate</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/enrollments" class="nav-item ${fn:contains(currentPath, 'admin/enrollments') ? 'active' : ''}">
            <i class="fas fa-id-card"></i><span>Enrollment</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item ${fn:contains(currentPath, '/profile') and not fn:contains(currentPath, 'admin') ? 'active' : ''}">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>
