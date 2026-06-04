<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="headerUser" value="${empty user ? sessionScope.user : user}"/>
<c:set var="headerProfilePicture" value="${not empty headerUser ? headerUser.profilePicture : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedInstructorTitle" value="Instructor"/>
<c:set var="resolvedInstructorSubtitle" value="Manage your courses and student progress"/>

<c:choose>
    <c:when test="${not empty param.pageTitle}">
        <c:set var="resolvedInstructorTitle" value="${param.pageTitle}"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/courses')}">
        <c:set var="resolvedInstructorTitle" value="My Courses"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/materials')}">
        <c:set var="resolvedInstructorTitle" value="Material Hub"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/assessments')}">
        <c:set var="resolvedInstructorTitle" value="Assessment Hub"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/instructor/certificates')}">
        <c:set var="resolvedInstructorTitle" value="Certificates"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/profile')}">
        <c:set var="resolvedInstructorTitle" value="Profile"/>
    </c:when>
    <c:otherwise>
        <c:set var="resolvedInstructorTitle" value="Dashboard"/>
    </c:otherwise>
</c:choose>

<c:if test="${not empty param.pageSubtitle}">
    <c:set var="resolvedInstructorSubtitle" value="${param.pageSubtitle}"/>
</c:if>

<c:set var="topbarUserName" value="${not empty headerUser.fullName ? headerUser.fullName : 'Instructor'}"/>
<c:set var="topbarInitialOne" value="${fn:length(topbarUserName) > 0 ? fn:substring(topbarUserName, 0, 1) : 'I'}"/>
<c:set var="topbarInitialTwo" value="${fn:length(topbarUserName) > 1 ? fn:substring(topbarUserName, 1, 2) : ''}"/>
<c:set var="topbarInitials" value="${fn:toUpperCase(topbarInitialOne)}"/>
<c:if test="${not empty topbarInitialTwo}">
    <c:set var="topbarInitials" value="${topbarInitials}${fn:toUpperCase(topbarInitialTwo)}"/>
</c:if>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/InstructorNav.module.css">

<header class="nav_mod_topbar">
    <div class="nav_mod_top_left">
        <button class="nav_mod_toggle" id="insToggleBtn" type="button" aria-label="Toggle navigation" aria-expanded="false">
            <i class="fas fa-bars" aria-hidden="true"></i>
        </button>

        <a href="${pageContext.request.contextPath}/dashboard" class="nav_mod_brand" aria-label="PSM E-Learning home">
            <span class="nav_mod_brand_main">PSM</span>
            <span class="nav_mod_brand_sub">E-Learning</span>
        </a>

        <div class="nav_mod_page_title">
            <h1><c:out value="${resolvedInstructorTitle}"/></h1>
        </div>
    </div>

    <div class="nav_mod_top_right">
        <!-- Notification Popover -->
        <div class="nav_mod_popover" id="insNotificationWrap">
            <button type="button" class="nav_mod_icon_btn" id="insNotificationBtn" aria-haspopup="true" aria-expanded="false" aria-label="Notifications">
                <i class="fas fa-bell" aria-hidden="true"></i>
                <c:if test="${not empty unreadNotificationCount and unreadNotificationCount > 0}">
                    <span class="nav_mod_badge">${unreadNotificationCount}</span>
                </c:if>
            </button>
            <div class="nav_mod_popover_panel" id="insNotificationPanel" role="menu" aria-label="Notifications">
                <div class="nav_mod_popover_head">
                    <strong>Notifications</strong>
                    <c:choose>
                        <c:when test="${not empty unreadNotificationCount and unreadNotificationCount > 0}">
                            <small>You have unread updates</small>
                        </c:when>
                        <c:otherwise>
                            <small>You are all caught up</small>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="nav_mod_popover_body">
                    <p>New student submissions or course updates will appear here.</p>
                </div>
            </div>
        </div>

        <!-- Dark Mode Toggle -->
        <button type="button" class="nav_mod_theme_toggle" data-theme-toggle aria-pressed="false" aria-label="Switch to dark mode" title="Switch to dark mode">
            <i class="fas fa-moon" aria-hidden="true"></i>
            <span class="theme-toggle-label">Dark mode</span>
        </button>

        <!-- Profile Dropdown -->
        <div class="nav_mod_profile_dropdown" id="insProfileDropdown">
            <button type="button" class="nav_mod_profile_trigger" id="insProfileMenuBtn" aria-haspopup="true" aria-expanded="false">
                <span class="nav_mod_avatar">
                    <c:choose>
                        <c:when test="${not empty headerProfilePicture}">
                            <c:choose>
                                <c:when test="${fn:startsWith(headerProfilePicture, 'http')}">
                                    <img src="${headerProfilePicture}" alt="Profile">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/${headerProfilePicture}" alt="Profile">
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <span class="nav_mod_avatar_fallback"><c:out value="${topbarInitials}"/></span>
                        </c:otherwise>
                    </c:choose>
                </span>
                <span class="nav_mod_profile_copy">
                    <span class="nav_mod_profile_name"><c:out value="${topbarUserName}"/></span>
                </span>
                <i class="fas fa-angle-down" aria-hidden="true"></i>
            </button>

            <div class="nav_mod_profile_menu" id="insProfileMenu" role="menu" aria-label="Profile menu">
                <a href="${pageContext.request.contextPath}/profile" role="menuitem"><i class="fas fa-user"></i> Profile</a>
                <a href="${pageContext.request.contextPath}/dashboard" role="menuitem"><i class="fas fa-table-columns"></i> Dashboard</a>
                <a href="${pageContext.request.contextPath}/logout" role="menuitem" class="nav_mod_logout_link"><i class="fas fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<script>
(function () {
    var body = document.body;
    var STORAGE_KEY = 'insShellCollapsed';
    var toggleBtn = document.getElementById('insToggleBtn');
    var profileBtn = document.getElementById('insProfileMenuBtn');
    var profileMenu = document.getElementById('insProfileMenu');
    var profileDropdown = document.getElementById('insProfileDropdown');
    var notificationBtn = document.getElementById('insNotificationBtn');
    var notificationPanel = document.getElementById('insNotificationPanel');
    var notificationWrap = document.getElementById('insNotificationWrap');
    var desktopMedia = window.matchMedia('(max-width: 1100px)');

    function isMobileShell() {
        return desktopMedia.matches;
    }

    function syncToggleState() {
        if (!toggleBtn) return;
        if (isMobileShell()) {
            toggleBtn.setAttribute('aria-expanded', body.classList.contains('ins-mobile-nav-open') ? 'true' : 'false');
        } else {
            toggleBtn.setAttribute('aria-expanded', body.classList.contains('ins-shell-collapsed') ? 'true' : 'false');
        }
    }

    function applyState(collapsed) {
        if (isMobileShell()) {
            body.classList.remove('ins-shell-collapsed');
            return;
        }
        if (collapsed) {
            body.classList.add('ins-shell-collapsed');
        } else {
            body.classList.remove('ins-shell-collapsed');
        }
        syncToggleState();
    }

    // Restore state
    applyState(localStorage.getItem(STORAGE_KEY) === 'true');

    if (toggleBtn) {
        toggleBtn.addEventListener('click', function () {
            if (isMobileShell()) {
                var mobileOpen = body.classList.toggle('ins-mobile-nav-open');
                syncToggleState();
            } else {
                var collapsed = body.classList.toggle('ins-shell-collapsed');
                localStorage.setItem(STORAGE_KEY, collapsed);
                syncToggleState();
            }
        });
    }

    function closePopover(button, panel) {
        if (!button || !panel) return;
        button.setAttribute('aria-expanded', 'false');
        panel.classList.remove('open');
    }

    function togglePopover(button, panel) {
        if (!button || !panel) return;
        var expanded = button.getAttribute('aria-expanded') === 'true';
        button.setAttribute('aria-expanded', expanded ? 'false' : 'true');
        panel.classList.toggle('open', !expanded);
    }

    if (profileBtn && profileMenu) {
        profileBtn.addEventListener('click', function (e) {
            e.stopPropagation();
            closePopover(notificationBtn, notificationPanel);
            togglePopover(profileBtn, profileMenu);
        });
    }

    if (notificationBtn && notificationPanel) {
        notificationBtn.addEventListener('click', function (e) {
            e.stopPropagation();
            closePopover(profileBtn, profileMenu);
            togglePopover(notificationBtn, notificationPanel);
        });
    }

    document.addEventListener('click', function (event) {
        if (profileDropdown && !profileDropdown.contains(event.target)) {
            closePopover(profileBtn, profileMenu);
        }
        if (notificationWrap && !notificationWrap.contains(event.target)) {
            closePopover(notificationBtn, notificationPanel);
        }
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closePopover(profileBtn, profileMenu);
            closePopover(notificationBtn, notificationPanel);
            if (isMobileShell()) {
                body.classList.remove('ins-mobile-nav-open');
                syncToggleState();
            }
        }
    });

    window.addEventListener('resize', function() {
        if (isMobileShell()) {
            body.classList.remove('ins-shell-collapsed');
        } else {
            body.classList.remove('ins-mobile-nav-open');
            applyState(localStorage.getItem(STORAGE_KEY) === 'true');
        }
        syncToggleState();
    });
})();
</script>
