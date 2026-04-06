<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="headerUser" value="${empty user ? sessionScope.user : user}"/>
<c:set var="headerProfilePicture" value="${not empty headerUser ? headerUser.profilePicture : null}"/>

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
                    <h1 class="page-title">Instructor</h1>
                </c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${not empty param.pageSubtitle}">
                    <p><c:out value="${param.pageSubtitle}"/></p>
                </c:when>
                <c:otherwise>
                    <p>Manage your teaching workspace and course activity</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="header-right">
        <c:if test="${param.showNotifications == 'true' and not empty notificationCount and notificationCount > 0}">
            <div class="notifications" aria-label="Notifications">
                <i class="fas fa-bell"></i>
                <span class="badge"><c:out value="${notificationCount}"/></span>
            </div>
        </c:if>
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
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>
