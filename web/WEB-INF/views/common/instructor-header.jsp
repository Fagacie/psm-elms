<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="headerUser" value="${empty user ? sessionScope.user : user}"/>
<c:set var="headerProfilePicture" value="${not empty headerUser ? headerUser.profilePicture : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedInstructorTitle" value="Instructor"/>
<c:set var="resolvedInstructorSubtitle" value="Manage your teaching workspace and course activity"/>

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

<c:if test="${not empty param.pageSubtitle}">
    <c:set var="resolvedInstructorSubtitle" value="${param.pageSubtitle}"/>
</c:if>

<c:set var="instructorContextCourse" value="${not empty selectedCourse ? selectedCourse.courseName : not empty course ? course.courseName : ''}"/>
<c:set var="instructorContextAssessment" value="${not empty selectedAssessment ? selectedAssessment.title : ''}"/>

<header class="app-header">
    <div class="header-left">
        <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
            <span class="dashboard-brand-main">PSM</span>
            <span class="dashboard-brand-sub">E-Learning</span>
        </a>
        <div class="dashboard-title-copy">
            <h1 class="page-title"><c:out value="${resolvedInstructorTitle}"/></h1>
            <p><c:out value="${resolvedInstructorSubtitle}"/></p>
            <c:if test="${not empty instructorContextCourse or not empty instructorContextAssessment}">
                <div class="header-context-row">
                    <c:if test="${not empty instructorContextCourse}"><span class="header-context-chip"><i class="fas fa-book-open"></i><c:out value="${instructorContextCourse}"/></span></c:if>
                    <c:if test="${not empty instructorContextAssessment}"><span class="header-context-chip"><i class="fas fa-clipboard-check"></i><c:out value="${instructorContextAssessment}"/></span></c:if>
                </div>
            </c:if>
        </div>
    </div>
    <div class="header-right">
        <c:if test="${param.showNotifications == 'true' and not empty notificationCount and notificationCount > 0}">
            <div class="notifications" aria-label="Notifications">
                <i class="fas fa-bell"></i>
                <span class="badge"><c:out value="${notificationCount}"/></span>
            </div>
        </c:if>
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
