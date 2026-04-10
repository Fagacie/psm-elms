<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<aside class="sv-sidebar" id="svSidebar">
    <nav class="sv-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link ${activePage == 'dashboard' ? 'active' : ''}"><i class="fas fa-house"></i><span>Dashboard</span></a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link ${activePage == 'my-courses' ? 'active' : ''}"><i class="fas fa-book-open"></i><span>My Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link ${activePage == 'browse-courses' ? 'active' : ''}"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link ${activePage == 'certificates' ? 'active' : ''}"><i class="fas fa-certificate"></i><span>Certificates</span></a>
        <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link ${activePage == 'profile' ? 'active' : ''}"><i class="fas fa-user-gear"></i><span>Profile</span></a>
    </nav>
</aside>