<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="topbarProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<c:set var="currentPath" value="${requestScope['javax.servlet.forward.request_uri']}"/>
<c:if test="${empty currentPath}">
    <c:set var="currentPath" value="${pageContext.request.requestURI}"/>
</c:if>
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
        <c:when test="${fn:contains(currentPath, '/student/payments')}"><c:set var="resolvedStudentTitle" value="Payments"/></c:when>
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

<header class="nav_mod_topbar">
    <div class="nav_mod_top_left">
        <c:if test="${topbarShowMenu != false}">
            <button class="nav_mod_toggle" id="svShellToggle" type="button" aria-label="Toggle navigation" aria-expanded="false">
                <i class="fas fa-bars" aria-hidden="true"></i>
            </button>
        </c:if>

        <a href="${pageContext.request.contextPath}/dashboard" class="nav_mod_brand" aria-label="PSM E-Learning home">
            <img src="${pageContext.request.contextPath}/img/psm-logo.svg" alt="PSM E-Learning" class="nav_mod_logo_img" style="height:34px;width:auto;display:block;">
        </a>

        <div class="nav_mod_page_title">
            <h1><c:out value="${resolvedStudentTitle}"/></h1>
        </div>
    </div>

    <div class="nav_mod_top_right">
        <div class="nav_mod_popover" id="svNotificationWrap">
            <button type="button" class="nav_mod_icon_btn" id="svNotificationBtn" aria-haspopup="true" aria-expanded="false" aria-label="Notifications">
                <i class="fas fa-bell" aria-hidden="true"></i>
                <c:if test="${topbarNotificationCount > 0}">
                    <span class="nav_mod_badge">${topbarNotificationCount}</span>
                </c:if>
            </button>
            <div class="nav_mod_popover_panel" id="svNotificationPanel" role="menu" aria-label="Notifications">
                <div class="nav_mod_popover_head">
                    <strong>Notifications</strong>
                    <small><c:out value="${topbarNotificationCount > 0 ? 'Unread updates available' : 'You are all caught up'}"/></small>
                </div>
                <div class="nav_mod_popover_body">
                    <p><c:out value="${topbarNotificationCount > 0 ? 'New course and progress notifications will appear here.' : 'No new alerts right now. Keep learning.'}"/></p>
                </div>
            </div>
        </div>

        <c:if test="${fn:contains(currentPath, '/student/enrollment-details') or fn:contains(currentPath, '/student/materials')}">
            <button type="button" class="nav_mod_theme_toggle" id="theaterModeToggle" aria-pressed="false" aria-label="Toggle theater mode" title="Toggle theater mode">
                <i class="fas fa-expand" aria-hidden="true"></i>
                <span class="theme-toggle-label">Theater</span>
            </button>
        </c:if>

        <button type="button" class="nav_mod_theme_toggle" data-theme-toggle aria-pressed="false" aria-label="Switch to dark mode" title="Switch to dark mode">
            <i class="fas fa-moon" aria-hidden="true"></i>
            <span class="theme-toggle-label">Dark mode</span>
        </button>

        <div class="nav_mod_profile_dropdown" id="svProfileDropdown">
            <button type="button" class="nav_mod_profile_trigger" id="svProfileMenuBtn" aria-haspopup="true" aria-expanded="false">
                <span class="nav_mod_avatar">
                    <c:choose>
                        <c:when test="${not empty topbarProfilePicture}">
                            <c:choose>
                                <c:when test="${fn:startsWith(topbarProfilePicture, 'http')}"><img src="${topbarProfilePicture}" alt="Profile"></c:when>
                                <c:otherwise><img src="${pageContext.request.contextPath}${topbarProfilePicture}" alt="Profile"></c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise><span class="nav_mod_avatar_fallback"><c:out value="${topbarInitials}"/></span></c:otherwise>
                    </c:choose>
                </span>
                <span class="nav_mod_profile_copy">
                    <span class="nav_mod_profile_name"><c:out value="${topbarUserName}"/></span>
                </span>
                <i class="fas fa-angle-down" aria-hidden="true"></i>
            </button>

            <div class="nav_mod_profile_menu" id="svProfileMenu" role="menu" aria-label="Profile menu">
                <a href="${pageContext.request.contextPath}/profile" role="menuitem"><i class="fas fa-user"></i> Profile</a>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" role="menuitem"><i class="fas fa-book-open"></i> My Courses</a>
                <a href="${pageContext.request.contextPath}/logout" role="menuitem" class="nav_mod_logout_link"><i class="fas fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </div>
</header>
