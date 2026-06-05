<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<aside id="svSidebar" class="sv-sidebar">
    <nav class="sv-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link ${activePage == 'dashboard' ? 'active' : ''}">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>

        <c:choose>
            <c:when test="${sessionScope.userRole == 'Instructor'}">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="sv-nav-link ${activePage == 'courses' ? 'active' : ''}">
                    <i class="fas fa-book"></i><span>Courses</span>
                </a>
                <a href="${pageContext.request.contextPath}/instructor/materials" class="sv-nav-link ${activePage == 'materials' ? 'active' : ''}">
                    <i class="fas fa-folder-open"></i><span>Materials</span>
                </a>
                <a href="${pageContext.request.contextPath}/instructor/certificates" class="sv-nav-link ${activePage == 'certificates' ? 'active' : ''}">
                    <i class="fas fa-certificate"></i><span>Certificates</span>
                </a>
            </c:when>
            <c:when test="${sessionScope.userRole == 'Admin'}">
                <a href="${pageContext.request.contextPath}/admin/users" class="sv-nav-link ${activePage == 'users' ? 'active' : ''}">
                    <i class="fas fa-users"></i><span>Users</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/courses" class="sv-nav-link ${activePage == 'courses' ? 'active' : ''}">
                    <i class="fas fa-book"></i><span>Courses</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/payments" class="sv-nav-link ${activePage == 'payments' ? 'active' : ''}">
                    <i class="fas fa-credit-card"></i><span>Payments</span>
                </a>
                <a href="${pageContext.request.contextPath}/reports" class="sv-nav-link ${activePage == 'reports' ? 'active' : ''}">
                    <i class="fas fa-chart-column"></i><span>Reports</span>
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link ${activePage == 'browse-courses' ? 'active' : ''}">
                    <i class="fas fa-book"></i><span>Browse Courses</span>
                </a>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link ${activePage == 'my-courses' ? 'active' : ''}">
                    <i class="fas fa-graduation-cap"></i><span>My Courses</span>
                </a>
                <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link ${activePage == 'certificates' ? 'active' : ''}">
                    <i class="fas fa-certificate"></i><span>Certificates</span>
                </a>
            </c:otherwise>
        </c:choose>

        <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link ${activePage == 'profile' ? 'active' : ''}">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>
