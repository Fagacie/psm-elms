<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="headerUser" value="${empty user ? sessionScope.user : user}"/>
<c:set var="headerProfilePicture" value="${not empty headerUser ? headerUser.profilePicture : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedInstructorTitle" value="Instructor"/>

<c:choose>
    <c:when test="${not empty param.pageTitle}">
        <c:set var="resolvedInstructorTitle" value="${param.pageTitle}"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/courses')}">
        <c:set var="resolvedInstructorTitle" value="My Courses"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/materials')}">
        <c:set var="resolvedInstructorTitle" value="Course Materials"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/assessments')}">
        <c:set var="resolvedInstructorTitle" value="Course Assessments"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/certificates')}">
        <c:set var="resolvedInstructorTitle" value="Certificates"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/profile')}">
        <c:set var="resolvedInstructorTitle" value="Profile"/>
    </c:when>
</c:choose>

<header class="app-header">
    <div class="header-left">
        <button type="button" class="ins-menu-btn" id="insMenuBtn" aria-label="Toggle sidebar">
            <i class="fas fa-bars"></i>
        </button>
        <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
            <span class="dashboard-brand-main">PSM</span>
            <span class="dashboard-brand-sub">E-Learning</span>
        </a>
        <h1 class="page-title"><c:out value="${resolvedInstructorTitle}"/></h1>
    </div>
    <div class="header-right">
        <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false">
            <span class="theme-toggle-label">Dark mode</span>
        </button>
        <a href="${pageContext.request.contextPath}/profile" class="user-menu user-menu-link">
            <div class="user-info">
                <span class="user-name"><c:out value="${headerUser.fullName}"/></span>
                <span class="user-role">Instructor</span>
            </div>
            <div class="user-avatar">
                <c:choose>
                    <c:when test="${not empty headerProfilePicture}">
                        <c:choose>
                            <c:when test="${fn:startsWith(headerProfilePicture, 'http')}">
                                <img src="${headerProfilePicture}" alt="Profile picture">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/${headerProfilePicture}" alt="Profile picture">
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <i class="fas fa-user"></i>
                    </c:otherwise>
                </c:choose>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>
