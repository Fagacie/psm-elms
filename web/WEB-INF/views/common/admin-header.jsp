<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="headerUser" value="${empty user ? sessionScope.user : user}"/>
<c:set var="headerProfilePicture" value="${not empty headerUser ? headerUser.profilePicture : null}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedAdminTitle" value="Admin"/>
<c:set var="resolvedAdminSubtitle" value="Manage platform operations and governance"/>

<c:choose>
    <c:when test="${not empty param.pageTitle}">
        <c:set var="resolvedAdminTitle" value="${param.pageTitle}"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/users')}">
        <c:set var="resolvedAdminTitle" value="Users"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/courses')}">
        <c:set var="resolvedAdminTitle" value="Courses"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/payments')}">
        <c:set var="resolvedAdminTitle" value="Payments"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/payment')}">
        <c:set var="resolvedAdminTitle" value="Payments"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/enrollments')}">
        <c:set var="resolvedAdminTitle" value="Enrollments"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/enrollment-details')}">
        <c:set var="resolvedAdminTitle" value="Enrollments"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/certificates')}">
        <c:set var="resolvedAdminTitle" value="Certificates"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/admin/settings')}">
        <c:set var="resolvedAdminTitle" value="Settings"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/reports')}">
        <c:set var="resolvedAdminTitle" value="Reports"/>
    </c:when>
    <c:when test="${fn:contains(currentPath, '/profile')}">
        <c:set var="resolvedAdminTitle" value="Profile"/>
    </c:when>
</c:choose>

<c:if test="${not empty param.pageSubtitle}">
    <c:set var="resolvedAdminSubtitle" value="${param.pageSubtitle}"/>
</c:if>

<c:set var="adminContextCourse" value="${not empty selectedCourse ? selectedCourse.courseName : not empty course ? course.courseName : ''}"/>
<c:set var="adminContextAssessment" value="${not empty selectedAssessment ? selectedAssessment.title : ''}"/>

<header class="app-header">
    <div class="header-left">
        <button type="button" class="sidebar-toggle-btn" id="sidebarToggle" aria-label="Toggle Navigation Sidebar">
            <i class="fas fa-bars"></i>
        </button>
        <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
            <span class="dashboard-brand-main">PSM</span>
            <span class="dashboard-brand-sub">E-Learning</span>
        </a>
        <div class="dashboard-title-copy">
            <h1 class="page-title"><c:out value="${resolvedAdminTitle}"/></h1>
            <p><c:out value="${resolvedAdminSubtitle}"/></p>
            <c:if test="${not empty adminContextCourse or not empty adminContextAssessment}">
                <div class="header-context-row">
                    <c:if test="${not empty adminContextCourse}"><span class="header-context-chip"><i class="fas fa-book-open"></i><c:out value="${adminContextCourse}"/></span></c:if>
                    <c:if test="${not empty adminContextAssessment}"><span class="header-context-chip"><i class="fas fa-clipboard-check"></i><c:out value="${adminContextAssessment}"/></span></c:if>
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
                <span class="user-role">Administrator</span>
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
                        <i class="fas fa-user-shield"></i>
                    </c:otherwise>
                </c:choose>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const toggleBtn = document.getElementById('sidebarToggle');
        if (toggleBtn) {
            const sidebarState = localStorage.getItem('adminSidebarCollapsed');
            if (sidebarState === 'true') {
                document.body.classList.add('sidebar-collapsed');
            }
            toggleBtn.addEventListener('click', function() {
                const isCollapsed = document.body.classList.toggle('sidebar-collapsed');
                localStorage.setItem('adminSidebarCollapsed', isCollapsed);
            });
        }
    });
</script>
