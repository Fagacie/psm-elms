<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-premium.css">
</head>
<body class="auth-page">
<main class="auth-shell">
    <section class="auth-layout auth-layout-login" aria-labelledby="login-title">
        <aside class="auth-visual" aria-hidden="true">
            <p class="auth-kicker">PSM E-Learning</p>
            <h2>Learn Smarter, Anywhere</h2>
            <p class="auth-visual-text">Pick up where you left off. Your courses, progress, and certificates await.</p>
            
            <ul class="auth-visual-list">
                <li>Access courses instantly</li>
                <li>Track your progress in real-time</li>
                <li>Earn recognized certificates</li>
            </ul>
            
            <div class="auth-scene">
                <lottie-player
                        class="auth-lottie"
                        src="${pageContext.request.contextPath}/img/auth/login-circle-animation.json"
                        background="transparent"
                        speed="1"
                        loop
                        autoplay>
                </lottie-player>
            </div>
        </aside>

        <section class="auth-card">
            <header class="auth-head">
                <h1 id="login-title">Login</h1>
                <p>Access your account using your registration number or email.</p>
            </header>

            <c:if test="${not empty sessionScope.successMessage}">
                <div class="auth-alert auth-alert-success">${sessionScope.successMessage}</div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty error}">
                <div class="auth-alert auth-alert-error">${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="post" class="auth-form" novalidate>
                <div class="auth-field">
                    <label for="identifier">Registration Number or Email</label>
                    <input
                            id="identifier"
                            name="identifier"
                            type="text"
                            value="${identifier}"
                            placeholder="e.g. PSM1783 or user@example.com"
                            required
                            autofocus>
                </div>

                <div class="auth-field">
                    <label for="password">Password</label>
                    <input id="password" name="password" type="password" placeholder="Enter your password" required>
                </div>

                <div class="auth-row">
                    <a href="${pageContext.request.contextPath}/forgot-password" class="auth-link">Forgot password?</a>
                </div>

                <button type="submit" class="auth-btn">Login</button>
            </form>

            <p class="auth-switch">
                New student?
                <a href="${pageContext.request.contextPath}/register" class="auth-link">Create Account</a>
            </p>
        </section>
    </section>
</main>
<script src="${pageContext.request.contextPath}/js/auth-v2.js"></script>
</body>
</html>


