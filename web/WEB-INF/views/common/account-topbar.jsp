<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="sv-topbar">
    <div class="sv-top-left">
        <button id="svMenuBtn" class="sv-menu-btn" type="button" aria-label="Open menu">
            <i class="fas fa-bars"></i>
        </button>
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
        <a href="${pageContext.request.contextPath}/profile" class="sv-profile-link">
            <i class="fas fa-user-circle"></i>
            <span>${sessionScope.userName}</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sv-logout">
            <i class="fas fa-sign-out-alt"></i>
            <span>Logout</span>
        </a>
    </div>
</nav>
