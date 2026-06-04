<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="headerUser" value="${empty user ? sessionScope.user : user}"/>
<c:set var="headerProfilePicture" value="${not empty headerUser ? headerUser.profilePicture : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="topbarNotificationCount" value="${not empty notificationCount ? notificationCount : 0}"/>
<c:set var="topbarUserName" value="${not empty headerUser.fullName ? headerUser.fullName : 'Admin'}"/>
<c:set var="topbarInitialOne" value="${fn:length(topbarUserName) > 0 ? fn:substring(topbarUserName, 0, 1) : 'A'}"/>
<c:set var="topbarInitialTwo" value="${fn:length(topbarUserName) > 1 ? fn:substring(topbarUserName, 1, 2) : ''}"/>
<c:set var="topbarInitials" value="${fn:toUpperCase(topbarInitialOne)}"/>
<c:if test="${not empty topbarInitialTwo}">
    <c:set var="topbarInitials" value="${topbarInitials}${fn:toUpperCase(topbarInitialTwo)}"/>
</c:if>

<!-- Resolve page title from route -->
<c:set var="resolvedAdminTitle" value="Admin Console"/>
<c:choose>
    <c:when test="${not empty param.pageTitle}"><c:set var="resolvedAdminTitle" value="${param.pageTitle}"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/users')}"><c:set var="resolvedAdminTitle" value="Users"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/courses')}"><c:set var="resolvedAdminTitle" value="Courses"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/payments') or fn:contains(currentPath, '/admin/payment')}"><c:set var="resolvedAdminTitle" value="Payments"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/enrollments') or fn:contains(currentPath, '/admin/enrollment-details')}"><c:set var="resolvedAdminTitle" value="Enrollments"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/certificates')}"><c:set var="resolvedAdminTitle" value="Certificates"/></c:when>
    <c:when test="${fn:contains(currentPath, '/admin/settings')}"><c:set var="resolvedAdminTitle" value="Settings"/></c:when>
    <c:when test="${fn:contains(currentPath, '/reports')}"><c:set var="resolvedAdminTitle" value="Reports"/></c:when>
    <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedAdminTitle" value="Profile"/></c:when>
    <c:when test="${fn:contains(currentPath, '/dashboard')}"><c:set var="resolvedAdminTitle" value="Dashboard"/></c:when>
</c:choose>

<header class="adm_nav_topbar">
    <div class="adm_nav_top_left">
        <button class="adm_nav_toggle" id="admShellToggle" type="button" aria-label="Toggle navigation" aria-expanded="false">
            <i class="fas fa-bars" aria-hidden="true"></i>
        </button>

        <a href="${pageContext.request.contextPath}/dashboard" class="adm_nav_brand" aria-label="PSM E-Learning admin home">
            <span class="adm_nav_brand_main">PSM</span>
            <span class="adm_nav_brand_sub">Admin</span>
        </a>

        <div class="adm_nav_page_title">
            <h1><c:out value="${resolvedAdminTitle}"/></h1>
        </div>
    </div>

    <div class="adm_nav_top_right">
        <div class="adm_nav_popover" id="admNotificationWrap">
            <button type="button" class="adm_nav_icon_btn" id="admNotificationBtn" aria-haspopup="true" aria-expanded="false" aria-label="Notifications">
                <i class="fas fa-bell" aria-hidden="true"></i>
                <c:if test="${topbarNotificationCount > 0}">
                    <span class="adm_nav_badge">${topbarNotificationCount}</span>
                </c:if>
            </button>
            <div class="adm_nav_popover_panel" id="admNotificationPanel" role="menu" aria-label="Notifications">
                <div class="adm_nav_popover_head">
                    <strong>Notifications</strong>
                    <small><c:out value="${topbarNotificationCount > 0 ? 'Unread updates available' : 'You are all caught up'}"/></small>
                </div>
                <div class="adm_nav_popover_body">
                    <p><c:out value="${topbarNotificationCount > 0 ? 'New platform alerts will appear here.' : 'No new alerts right now.'}"/></p>
                </div>
            </div>
        </div>

        <button type="button" class="adm_nav_theme_toggle" data-theme-toggle aria-pressed="false" aria-label="Switch to dark mode" title="Switch to dark mode">
            <i class="fas fa-moon" aria-hidden="true"></i>
            <span class="theme-toggle-label">Dark mode</span>
        </button>

        <div class="adm_nav_profile_dropdown" id="admProfileDropdown">
            <button type="button" class="adm_nav_profile_trigger" id="admProfileMenuBtn" aria-haspopup="true" aria-expanded="false">
                <span class="adm_nav_avatar">
                    <c:choose>
                        <c:when test="${not empty headerProfilePicture}">
                            <c:choose>
                                <c:when test="${fn:startsWith(headerProfilePicture, 'http')}"><img src="${headerProfilePicture}" alt="Profile"></c:when>
                                <c:otherwise><img src="${pageContext.request.contextPath}/${headerProfilePicture}" alt="Profile"></c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise><span class="adm_nav_avatar_fallback"><c:out value="${topbarInitials}"/></span></c:otherwise>
                    </c:choose>
                </span>
                <span class="adm_nav_profile_copy">
                    <span class="adm_nav_profile_name"><c:out value="${topbarUserName}"/></span>
                </span>
                <i class="fas fa-angle-down" aria-hidden="true"></i>
            </button>

            <div class="adm_nav_profile_menu" id="admProfileMenu" role="menu" aria-label="Profile menu">
                <a href="${pageContext.request.contextPath}/profile" role="menuitem"><i class="fas fa-user"></i> Profile</a>
                <a href="${pageContext.request.contextPath}/admin/settings" role="menuitem"><i class="fas fa-gear"></i> Settings</a>
                <a href="${pageContext.request.contextPath}/logout" role="menuitem" class="adm_nav_logout_link"><i class="fas fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<!-- Mobile overlay -->
<div class="adm_nav_overlay" id="admNavOverlay"></div>

<script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Lucide icons
    if (window.lucide) {
        window.lucide.createIcons();
    }

    /* === Sidebar Toggle === */
    var toggleBtn = document.getElementById('admShellToggle');
    var sidebar = document.querySelector('.adm_nav_sidebar');
    var overlay = document.getElementById('admNavOverlay');
    var isMobile = function() { return window.innerWidth <= 1100; };

    if (toggleBtn) {
        // Restore collapsed state on desktop
        if (!isMobile()) {
            var sidebarState = localStorage.getItem('adminSidebarCollapsed');
            if (sidebarState === 'true') {
                document.body.classList.add('sidebar-collapsed');
            }
        }

        toggleBtn.addEventListener('click', function() {
            if (isMobile()) {
                document.body.classList.toggle('adm-mobile-nav-open');
            } else {
                var isCollapsed = document.body.classList.toggle('sidebar-collapsed');
                localStorage.setItem('adminSidebarCollapsed', isCollapsed);
            }
        });
    }

    if (overlay) {
        overlay.addEventListener('click', function() {
            document.body.classList.remove('adm-mobile-nav-open');
        });
    }

    /* === Notification Popover === */
    var notifBtn = document.getElementById('admNotificationBtn');
    var notifPanel = document.getElementById('admNotificationPanel');

    if (notifBtn && notifPanel) {
        notifBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            notifPanel.classList.toggle('open');
            // Close profile menu if open
            var profMenu = document.getElementById('admProfileMenu');
            if (profMenu) profMenu.classList.remove('open');
        });
    }

    /* === Profile Dropdown === */
    var profBtn = document.getElementById('admProfileMenuBtn');
    var profMenu = document.getElementById('admProfileMenu');

    if (profBtn && profMenu) {
        profBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            profMenu.classList.toggle('open');
            // Close notification panel if open
            if (notifPanel) notifPanel.classList.remove('open');
        });
    }

    /* === Close all popovers on outside click === */
    document.addEventListener('click', function() {
        if (notifPanel) notifPanel.classList.remove('open');
        if (profMenu) profMenu.classList.remove('open');
    });

    /* === Responsive cleanup on resize === */
    window.addEventListener('resize', function() {
        if (!isMobile()) {
            document.body.classList.remove('adm-mobile-nav-open');
        }
    });
});
</script>
