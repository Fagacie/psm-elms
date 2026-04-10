<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${activeInstructorPage == 'dashboard' ? 'active' : ''}">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item ${activeInstructorPage == 'courses' ? 'active' : ''}">
            <i class="fas fa-book"></i><span>Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item ${activeInstructorPage == 'materials' ? 'active' : ''}">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item ${activeInstructorPage == 'assessments' ? 'active' : ''}">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item ${activeInstructorPage == 'certificates' ? 'active' : ''}">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item ${activeInstructorPage == 'profile' ? 'active' : ''}">
            <i class="fas fa-user"></i><span>Profile / Settings</span>
        </a>
    </nav>
</aside>
