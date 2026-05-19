<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="topbarProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedStudentTitle" value="${not empty topbarTitle ? topbarTitle : 'Student Workspace'}"/>
<c:set var="resolvedTopbarContext" value="${not empty navContext ? navContext : 'default'}"/>
<c:set var="topbarNotificationCount" value="${not empty unreadNotificationCount ? unreadNotificationCount : (not empty sessionScope.unreadNotifications ? sessionScope.unreadNotifications : 0)}"/>
<c:set var="topbarUserName" value="${not empty sessionScope.userName ? sessionScope.userName : 'Student'}"/>
<c:set var="topbarInitialOne" value="${fn:length(topbarUserName) > 0 ? fn:substring(topbarUserName, 0, 1) : 'S'}"/>
<c:set var="topbarInitialTwo" value="${fn:length(topbarUserName) > 1 ? fn:substring(topbarUserName, 1, 2) : ''}"/>
<c:set var="topbarInitials" value="${fn:toUpperCase(topbarInitialOne)}"/>
<c:if test="${not empty topbarInitialTwo}">
    <c:set var="topbarInitials" value="${topbarInitials}${fn:toUpperCase(topbarInitialTwo)}"/>
</c:if>

<c:if test="${empty topbarTitle}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/student/my-enrollments')}"><c:set var="resolvedStudentTitle" value="My Courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/courses')}"><c:set var="resolvedStudentTitle" value="Browse Courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/enrollment-summary')}"><c:set var="resolvedStudentTitle" value="Enrollment Summary"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-success')}"><c:set var="resolvedStudentTitle" value="Payment Success"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-failed')}"><c:set var="resolvedStudentTitle" value="Payment Failed"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment')}"><c:set var="resolvedStudentTitle" value="Payment"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/assessments')}"><c:set var="resolvedStudentTitle" value="Assessments"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/materials')}"><c:set var="resolvedStudentTitle" value="Material Preview"/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/certificates') or fn:contains(currentPath, '/student/certificate')}"><c:set var="resolvedStudentTitle" value="Certificates"/></c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedStudentTitle" value="Profile"/></c:when>
    </c:choose>
</c:if>

<header class="sv-topbar">
    <div class="sv-top-left">
        <c:if test="${topbarShowMenu != false}">
            <button class="sv-shell-toggle" id="svShellToggle" type="button" aria-label="Toggle navigation" aria-expanded="false">
                <i class="fas fa-bars-staggered" aria-hidden="true"></i>
            </button>
        </c:if>

        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand" aria-label="PSM E-Learning home">
            <span class="sv-brand-main">PSM</span>
            <span class="sv-brand-sub">E-Learning</span>
        </a>

        <div class="sv-page-title">
            <h1><c:out value="${resolvedStudentTitle}"/></h1>
        </div>
    </div>

    <div class="sv-top-right">
        <div class="sv-popover sv-notification-wrap" id="svNotificationWrap">
            <button type="button" class="sv-top-icon-btn" id="svNotificationBtn" aria-haspopup="true" aria-expanded="false" aria-label="Notifications">
                <i class="fas fa-bell" aria-hidden="true"></i>
                <c:if test="${topbarNotificationCount > 0}">
                    <span class="sv-top-badge">${topbarNotificationCount}</span>
                </c:if>
            </button>
            <div class="sv-popover-panel sv-notification-panel" id="svNotificationPanel" role="menu" aria-label="Notifications">
                <div class="sv-popover-head">
                    <strong>Notifications</strong>
                    <small><c:out value="${topbarNotificationCount > 0 ? 'Unread updates available' : 'You are all caught up'}"/></small>
                </div>
                <div class="sv-popover-body">
                    <p><c:out value="${topbarNotificationCount > 0 ? 'New course and progress notifications will appear here.' : 'No new alerts right now. Keep learning.'}"/></p>
                </div>
            </div>
        </div>

        <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false" aria-label="Switch to dark mode" title="Switch to dark mode">
            <i class="fas fa-moon" aria-hidden="true"></i>
            <span class="theme-toggle-label">Dark mode</span>
        </button>

        <div class="sv-profile-dropdown" id="svProfileDropdown">
            <button type="button" class="sv-profile-trigger" id="svProfileMenuBtn" aria-haspopup="true" aria-expanded="false">
                <span class="sv-profile-copy">
                    <span class="sv-profile-name"><c:out value="${topbarUserName}"/></span>
                </span>
                <span class="sv-avatar-shell">
                    <c:choose>
                        <c:when test="${not empty topbarProfilePicture}">
                            <c:choose>
                                <c:when test="${fn:startsWith(topbarProfilePicture, 'http')}"><img src="${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:when>
                                <c:otherwise><img src="${pageContext.request.contextPath}${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise><span class="sv-avatar-fallback"><c:out value="${topbarInitials}"/></span></c:otherwise>
                    </c:choose>
                </span>
                <i class="fas fa-angle-down" aria-hidden="true"></i>
            </button>

            <div class="sv-profile-menu" id="svProfileMenu" role="menu" aria-label="Profile menu">
                <a href="${pageContext.request.contextPath}/profile" role="menuitem"><i class="fas fa-user"></i> Profile</a>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" role="menuitem"><i class="fas fa-book-open"></i> My Courses</a>
                <a href="${pageContext.request.contextPath}/logout" role="menuitem" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </div>
</header>
