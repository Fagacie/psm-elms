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

<header class="app-header ins-light-header">
    <div class="header-left">
        <button type="button" class="ins-toggle-btn" id="insToggleBtn" aria-label="Toggle sidebar navigation">
            <i class="fas fa-bars"></i>
        </button>
        <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
            <span class="dashboard-brand-main">PSM</span>
            <span class="dashboard-brand-sub">E-Learning</span>
        </a>
        <div class="dashboard-title-copy">
            <h1 class="page-title"><c:out value="${resolvedInstructorTitle}"/></h1>
            <p><c:out value="${resolvedInstructorSubtitle}"/></p>
        </div>
    </div>
    <div class="header-right">
        <!-- Notification Bell -->
        <div class="ins-notif-btn" id="insNotifBtn" aria-label="Notifications">
            <i class="fas fa-bell"></i>
            <c:if test="${not empty unreadNotificationCount and unreadNotificationCount > 0}">
                <span class="ins-notif-badge"><c:out value="${unreadNotificationCount}"/></span>
            </c:if>
        </div>
        <!-- User Menu -->
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
        <a href="${pageContext.request.contextPath}/logout" class="ins-logout-btn" title="Logout">
            <i class="fas fa-sign-out-alt"></i>
        </a>
    </div>
</header>

<script>
(function () {
    var STORAGE_KEY = 'insShellCollapsed';
    var toggleBtn = document.getElementById('insToggleBtn');

    function applyState(collapsed) {
        if (collapsed) {
            document.body.classList.add('ins-shell-collapsed');
        } else {
            document.body.classList.remove('ins-shell-collapsed');
        }
    }

    // Restore previous state
    applyState(localStorage.getItem(STORAGE_KEY) === 'true');

    if (toggleBtn) {
        toggleBtn.addEventListener('click', function () {
            var nowCollapsed = document.body.classList.toggle('ins-shell-collapsed');
            localStorage.setItem(STORAGE_KEY, nowCollapsed);
        });
    }

    // Sync dark mode button icon
    function syncDarkIcon() {
        var theme = document.documentElement.getAttribute('data-theme');
        var btn = document.querySelector('.ins-dark-toggle i');
        if (btn) {
            btn.className = theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
        }
    }
    syncDarkIcon();
    var observer = new MutationObserver(syncDarkIcon);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
})();
</script>
