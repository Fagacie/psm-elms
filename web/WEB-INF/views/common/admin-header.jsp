<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<header class="app-header">
    <div class="header-left">
        <div class="logo-section">
            <i class="fas fa-university"></i>
            <span>PSM E-Learning</span>
        </div>
        <c:choose>
            <c:when test="${not empty param.pageTitle}">
                <h1 class="page-title"><c:out value="${param.pageTitle}"/></h1>
            </c:when>
            <c:otherwise>
                <h1 class="page-title">Admin</h1>
            </c:otherwise>
        </c:choose>
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
