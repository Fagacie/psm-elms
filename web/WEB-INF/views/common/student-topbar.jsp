<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="topbarProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>

<header class="sv-topbar">
    <div class="sv-top-left">
        <c:if test="${topbarShowMenu != false}">
            <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        </c:if>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>${topbarTitle}</h1><p>${topbarSubtitle}</p></div>
    </div>
    <div class="sv-top-right">
        <a href="${pageContext.request.contextPath}/profile" class="sv-profile-link">
            <c:choose>
                <c:when test="${not empty topbarProfilePicture}">
                    <c:choose>
                        <c:when test="${fn:startsWith(topbarProfilePicture, 'http')}"><img src="${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:when>
                        <c:otherwise><img src="${pageContext.request.contextPath}${topbarProfilePicture}" alt="Profile" class="sv-avatar-img"></c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise><i class="fas fa-user"></i></c:otherwise>
            </c:choose>
            <span>${sessionScope.userName}</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a>
    </div>
</header>