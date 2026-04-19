<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand">
            <span class="sv-brand-main">PSM</span>
            <span class="sv-brand-sub">E-Learning</span>
        </a>
        <div class="sv-page-title">
            <h1>${topbarTitle}</h1>
            <p>${topbarSubtitle}</p>
        </div>
    </div>
    <div class="sv-top-right">
        <a href="${pageContext.request.contextPath}/profile" class="sd3-user">
            <div class="sd3-avatar">
                <c:choose>
                    <c:when test="${not empty topbarProfilePath}">
                        <c:choose>
                            <c:when test="${fn:startsWith(topbarProfilePath, 'http')}">
                                <img src="${topbarProfilePath}" alt="Profile">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/${topbarProfilePath}" alt="Profile">
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <i class="fas fa-user"></i>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="sd3-user-copy">
                <strong>${sessionScope.userName}</strong>
                <span>Your learning hub</span>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a>
    </div>
</header>