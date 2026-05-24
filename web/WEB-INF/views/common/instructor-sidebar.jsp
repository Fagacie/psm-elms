<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedInstructorPage" value="${activeInstructorPage}"/>
<c:if test="${empty resolvedInstructorPage}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/instructor/courses')}"><c:set var="resolvedInstructorPage" value="courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedInstructorPage" value="profile"/></c:when>
        <c:otherwise><c:set var="resolvedInstructorPage" value="dashboard"/></c:otherwise>
    </c:choose>
</c:if>

<aside class="app-sidebar" id="insSidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${resolvedInstructorPage == 'dashboard' ? 'active' : ''}" title="Dashboard">
            <i class="fas fa-table-columns"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item ${resolvedInstructorPage == 'courses' ? 'active' : ''}" title="My Assigned Courses">
            <i class="fas fa-book"></i><span>My Assigned Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item ${resolvedInstructorPage == 'profile' ? 'active' : ''}" title="Profile">
            <i class="fas fa-user-gear"></i><span>Profile</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-item nav-item-danger" title="Logout">
            <i class="fas fa-right-from-bracket"></i><span>Logout</span>
        </a>
    </nav>
</aside>
