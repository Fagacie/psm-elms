<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="adminProfilePicture" value="${not empty sessionScope.user.profilePicture ? sessionScope.user.profilePicture : null}"/>
<header class="app-header">
    <div class="header-left">
        <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
            <span class="dashboard-brand-main">PSM</span>
            <span class="dashboard-brand-sub">E-Learning</span>
        </a>
        <div class="dashboard-title-copy">
            <c:choose>
                <c:when test="${not empty param.pageTitle}">
                    <h1 class="page-title"><c:out value="${param.pageTitle}"/></h1>
                </c:when>
                <c:otherwise>
                    <h1 class="page-title">Admin</h1>
                </c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${not empty param.pageSubtitle}">
                    <p><c:out value="${param.pageSubtitle}"/></p>
                </c:when>
                <c:otherwise>
                    <p>Manage platform operations and governance</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/profile" class="user-menu user-menu-link">
            <div class="user-info">
                <span class="user-name"><c:out value="${sessionScope.user.fullName}"/></span>
                <span class="user-role">Administrator</span>
            </div>
            <div class="user-avatar"><c:choose><c:when test="${not empty adminProfilePicture}"><c:choose><c:when test="${fn:startsWith(adminProfilePicture, 'http')}"><img src="${adminProfilePicture}" alt="Profile" class="admin-avatar-img"></c:when><c:otherwise><img src="${pageContext.request.contextPath}${adminProfilePicture}" alt="Profile" class="admin-avatar-img"></c:otherwise></c:choose></c:when><c:otherwise><i class="fas fa-user-shield"></i></c:otherwise></c:choose></div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>
