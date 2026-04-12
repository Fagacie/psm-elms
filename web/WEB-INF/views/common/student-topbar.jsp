<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="topbarProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedStudentTitle" value="${not empty topbarTitle ? topbarTitle : 'Student Workspace'}"/>
<c:set var="resolvedStudentSubtitle" value="${not empty topbarSubtitle ? topbarSubtitle : 'Navigate your learning flow'}"/>
<c:set var="topbarSearchQuery" value="${not empty param.keyword ? param.keyword : not empty param.search ? param.search : ''}"/>
<c:set var="topbarNotificationCount" value="${not empty sessionScope.unreadNotifications ? sessionScope.unreadNotifications : 0}"/>

<c:if test="${empty topbarTitle}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/student/my-enrollments')}"><c:set var="resolvedStudentTitle" value="My Courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/courses')}"><c:set var="resolvedStudentTitle" value="Browse Courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/enrollment-summary')}"><c:set var="resolvedStudentTitle" value="Enrollment Summary"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-success')}"><c:set var="resolvedStudentTitle" value="Payment Success"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-failed')}"><c:set var="resolvedStudentTitle" value="Payment Failed"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment')}"><c:set var="resolvedStudentTitle" value="Payment"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/assessments')}"><c:set var="resolvedStudentTitle" value="Assessments"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/materials')}"><c:set var="resolvedStudentTitle" value="Material Viewer"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/certificates') or fn:contains(currentPath, '/student/certificate')}"><c:set var="resolvedStudentTitle" value="Certificates"/></c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedStudentTitle" value="Profile"/></c:when>
    </c:choose>
</c:if>

<c:if test="${empty topbarSubtitle}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/student/my-enrollments')}"><c:set var="resolvedStudentSubtitle" value="Track progress and continue your active courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/enrollment-details')}"><c:set var="resolvedStudentSubtitle" value="Follow your learning and assessment plan"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/materials')}"><c:set var="resolvedStudentSubtitle" value="Study course materials in sequence"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/enrollment-summary')}"><c:set var="resolvedStudentSubtitle" value="Review course details before checkout"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-success')}"><c:set var="resolvedStudentSubtitle" value="Enrollment confirmed - access your learning hub"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-failed')}"><c:set var="resolvedStudentSubtitle" value="Resolve payment to unlock course access"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment')}"><c:set var="resolvedStudentSubtitle" value="Complete secure checkout to continue"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/courses')}"><c:set var="resolvedStudentSubtitle" value="Discover and compare available courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/assessments')}"><c:set var="resolvedStudentSubtitle" value="Submit, track, and review assessment attempts"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/certificates') or fn:contains(currentPath, '/student/certificate')}"><c:set var="resolvedStudentSubtitle" value="View and verify your earned certificates"/></c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedStudentSubtitle" value="Manage your account details and preferences"/></c:when>
    </c:choose>
</c:if>

<header class="sv-topbar">
    <div class="sv-top-left">
        <c:if test="${topbarShowMenu != false}">
            <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        </c:if>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title">
            <h1>${resolvedStudentTitle}</h1>
            <p>${resolvedStudentSubtitle}</p>
        </div>
    </div>
    <div class="sv-top-right">
        <form class="sv-search-form" action="${pageContext.request.contextPath}/student/courses" method="get" role="search" aria-label="Search courses and content">
            <i class="fas fa-magnifying-glass" aria-hidden="true"></i>
            <label for="svTopSearchInput" class="sv-visually-hidden">Search courses and content</label>
            <input id="svTopSearchInput" class="sv-search-input" type="search" name="keyword" value="${topbarSearchQuery}" placeholder="Search courses or content" autocomplete="off">
        </form>

        <button type="button" class="sv-top-icon-btn" aria-label="Notifications">
            <i class="fas fa-bell" aria-hidden="true"></i>
            <c:if test="${topbarNotificationCount > 0}">
                <span class="sv-top-badge">${topbarNotificationCount}</span>
            </c:if>
        </button>

        <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false">
            <i class="fas fa-circle-half-stroke" aria-hidden="true"></i>
            <span class="theme-toggle-label">Dark mode</span>
        </button>

        <div class="sv-profile-dropdown" id="svProfileDropdown">
            <button type="button" class="sv-profile-trigger" id="svProfileMenuBtn" aria-haspopup="true" aria-expanded="false">
                <c:choose>
                    <c:when test="${not empty topbarProfilePicture}">
                        <c:choose>
                            <c:when test="${fn:startsWith(topbarProfilePicture, 'http')}"><img src="${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:when>
                            <c:otherwise><img src="${pageContext.request.contextPath}${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise><i class="fas fa-user"></i></c:otherwise>
                </c:choose>
                <span>${sessionScope.userName}</span>
                <i class="fas fa-chevron-down" aria-hidden="true"></i>
            </button>
            <div class="sv-profile-menu" id="svProfileMenu" role="menu" aria-label="Profile menu">
                <a href="${pageContext.request.contextPath}/profile" role="menuitem"><i class="fas fa-user"></i> Profile</a>
                <a href="${pageContext.request.contextPath}/logout" role="menuitem"><i class="fas fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </div>
</header>