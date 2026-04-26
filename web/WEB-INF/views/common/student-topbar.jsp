<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="topbarProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedStudentTitle" value="${not empty topbarTitle ? topbarTitle : 'Your Learning Hub'}"/>
<c:set var="resolvedStudentSubtitle" value="${not empty topbarSubtitle ? topbarSubtitle : 'Navigate your learning flow'}"/>
<c:set var="resolvedTopbarContext" value="${not empty navContext ? navContext : 'default'}"/>
<c:set var="topbarSearchQuery" value="${not empty param.keyword ? param.keyword : not empty param.search ? param.search : ''}"/>
<c:set var="topbarNotificationCount" value="${not empty sessionScope.unreadNotifications ? sessionScope.unreadNotifications : 0}"/>
<c:set var="topbarShowSearchResolved" value="${topbarShowSearch != false and resolvedTopbarContext != 'assessment'}"/>
<c:set var="topbarUserName" value="${not empty sessionScope.userName ? sessionScope.userName : 'Student'}"/>
<c:set var="topbarInitialOne" value="${fn:length(topbarUserName) > 0 ? fn:substring(topbarUserName, 0, 1) : 'S'}"/>
<c:set var="topbarInitialTwo" value="${fn:length(topbarUserName) > 1 ? fn:substring(topbarUserName, 1, 2) : ''}"/>
<c:set var="topbarInitials" value="${fn:toUpperCase(topbarInitialOne)}"/>
<c:set var="isDashboardPage" value="${fn:contains(currentPath, '/dashboard')}"/>
<c:set var="isMyCoursesPage" value="${fn:contains(currentPath, '/student/my-enrollments') or fn:contains(currentPath, '/student/enrollment-details') or fn:contains(currentPath, '/student/materials')}"/>
<c:set var="isExplorePage" value="${fn:contains(currentPath, '/student/courses')}"/>
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

<c:if test="${empty topbarSubtitle}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/student/my-enrollments')}"><c:set var="resolvedStudentSubtitle" value="Track active courses and resume what matters next."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/enrollment-details')}"><c:set var="resolvedStudentSubtitle" value="Move through the course with clear progress and learning context."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/materials')}"><c:set var="resolvedStudentSubtitle" value="Stay focused on the current material and mark completion without leaving the flow."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/enrollment-summary')}"><c:set var="resolvedStudentSubtitle" value="Review course details before checkout."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-success')}"><c:set var="resolvedStudentSubtitle" value="Enrollment confirmed and ready for learning."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment-failed')}"><c:set var="resolvedStudentSubtitle" value="Resolve payment and continue securely."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/payment')}"><c:set var="resolvedStudentSubtitle" value="Complete secure checkout to continue."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/courses')}"><c:set var="resolvedStudentSubtitle" value="Find the next course that fits your goals."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/assessments')}"><c:set var="resolvedStudentSubtitle" value="Manage attempts, track outcomes, and finish strong."/></c:when>
        <c:when test="${fn:contains(currentPath, '/student/certificates') or fn:contains(currentPath, '/student/certificate')}"><c:set var="resolvedStudentSubtitle" value="Access and verify your earned credentials."/></c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedStudentSubtitle" value="Manage your account details and preferences."/></c:when>
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

        <nav class="sv-top-links" aria-label="Primary destinations">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-top-link ${isDashboardPage ? 'active' : ''}">Dashboard</a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-top-link ${isMyCoursesPage ? 'active' : ''}">My Courses</a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-top-link ${isExplorePage ? 'active' : ''}">Explore</a>
        </nav>

        <div class="sv-page-title">
            <h1>${resolvedStudentTitle}</h1>
        </div>
    </div>

    <div class="sv-top-right">
        <c:if test="${topbarShowSearchResolved}">
            <form class="sv-search-form" action="${pageContext.request.contextPath}/student/courses" method="get" role="search" aria-label="Search courses">
                <i class="fas fa-magnifying-glass" aria-hidden="true"></i>
                <label for="svTopSearchInput" class="sv-visually-hidden">Search courses</label>
                <input id="svTopSearchInput"
                       class="sv-search-input"
                       type="search"
                       name="keyword"
                       value="${topbarSearchQuery}"
                       placeholder="Search courses"
                       autocomplete="off">
            </form>
        </c:if>

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
                    <small>${topbarNotificationCount > 0 ? 'Unread updates available' : 'You are all caught up'}</small>
                </div>
                <div class="sv-popover-body">
                    <p>${topbarNotificationCount > 0 ? 'New course and progress notifications will appear here.' : 'No new alerts right now. Keep learning.'}</p>
                </div>
            </div>
        </div>

        <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false">
            <i class="fas fa-circle-half-stroke" aria-hidden="true"></i>
            <span class="theme-toggle-label">Dark mode</span>
        </button>

        <div class="sv-profile-dropdown sv-popover" id="svProfileDropdown">
            <button type="button" class="sv-profile-trigger" id="svProfileMenuBtn" aria-haspopup="true" aria-expanded="false">
                <span class="sv-profile-copy">
                    <span class="sv-profile-name">${topbarUserName}</span>
                </span>
                <span class="sv-avatar-shell">
                    <c:choose>
                        <c:when test="${not empty topbarProfilePicture}">
                            <c:choose>
                                <c:when test="${fn:startsWith(topbarProfilePicture, 'http')}"><img src="${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:when>
                                <c:otherwise><img src="${pageContext.request.contextPath}${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise><span class="sv-avatar-fallback">${topbarInitials}</span></c:otherwise>
                    </c:choose>
                </span>
                <i class="fas fa-chevron-down" aria-hidden="true"></i>
            </button>

            <div class="sv-profile-menu sv-popover-panel" id="svProfileMenu" role="menu" aria-label="Profile menu">
                <div class="sv-popover-head">
                    <strong>${topbarUserName}</strong>
                    <small>Student account</small>
                </div>
                <a href="${pageContext.request.contextPath}/dashboard" role="menuitem"><i class="fas fa-table-columns"></i> Dashboard</a>
                <a href="${pageContext.request.contextPath}/profile" role="menuitem"><i class="fas fa-user"></i> Profile</a>
                <a href="${pageContext.request.contextPath}/logout" role="menuitem"><i class="fas fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </div>
</header>
