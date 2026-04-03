<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
        <div class="user-menu">
            <div class="user-info">
                <span class="user-name"><c:out value="${sessionScope.user.fullName}"/></span>
                <span class="user-role">Administrator</span>
            </div>
            <div class="user-avatar"><i class="fas fa-user-shield"></i></div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>
