<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedInstructorPage" value="${activeInstructorPage}"/>
<c:if test="${empty resolvedInstructorPage}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/instructor/courses')}"><c:set var="resolvedInstructorPage" value="courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/instructor/materials')}"><c:set var="resolvedInstructorPage" value="materials"/></c:when>
        <c:when test="${fn:contains(currentPath, '/instructor/assessments')}"><c:set var="resolvedInstructorPage" value="assessments"/></c:when>
        <c:when test="${fn:contains(currentPath, '/instructor/certificates')}"><c:set var="resolvedInstructorPage" value="certificates"/></c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedInstructorPage" value="profile"/></c:when>
        <c:otherwise><c:set var="resolvedInstructorPage" value="dashboard"/></c:otherwise>
    </c:choose>
</c:if>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${resolvedInstructorPage == 'dashboard' ? 'active' : ''}">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item ${resolvedInstructorPage == 'courses' ? 'active' : ''}">
            <i class="fas fa-book"></i><span>Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item ${resolvedInstructorPage == 'materials' ? 'active' : ''}">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item ${resolvedInstructorPage == 'assessments' ? 'active' : ''}">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item ${resolvedInstructorPage == 'certificates' ? 'active' : ''}">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item ${resolvedInstructorPage == 'profile' ? 'active' : ''}">
            <i class="fas fa-user"></i><span>Profile / Settings</span>
        </a>
    </nav>
</aside>
