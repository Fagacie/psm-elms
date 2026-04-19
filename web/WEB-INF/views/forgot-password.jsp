<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-premium.css?v=20260417-1">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="auth-page">
<main class="auth-shell">
    <section class="auth-layout auth-layout-recovery" aria-labelledby="forgot-title">
        <aside class="auth-visual" aria-hidden="true">
            <p class="auth-kicker">Account Recovery</p>
            <h2>Regain access without friction.</h2>
            <p class="auth-visual-text">We will send a secure reset link to the email address attached to your account so you can return to learning quickly.</p>

            <ul class="auth-visual-list">
                <li>One-hour secure reset link</li>
                <li>Email-based account verification</li>
                <li>Fast return to your learning workspace</li>
            </ul>

            <div class="auth-scene" data-auth-scene>
                <span class="auth-shape auth-shape-a" data-depth="10"></span>
                <span class="auth-shape auth-shape-b" data-depth="18"></span>
                <span class="auth-shape auth-shape-c" data-depth="14"></span>
                <span class="auth-shape auth-shape-d" data-depth="12"></span>
            </div>
        </aside>

        <section class="auth-card">
            <header class="auth-head">
                <h1 id="forgot-title">Forgot Password</h1>
                <p>Enter your email address and we will send you a password reset link.</p>
            </header>

            <div class="theme-toolbar theme-toolbar-compact">
                <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false">
                    <span class="theme-toggle-label">Dark mode</span>
                </button>
            </div>

            <% if (request.getAttribute("success") != null) { %>
                <div class="auth-alert auth-alert-success"><%= request.getAttribute("success") %></div>
            <% } %>

            <% if (request.getAttribute("error") != null) { %>
                <div class="auth-alert auth-alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% if (request.getAttribute("warning") != null) { %>
                <div class="auth-alert auth-alert-error"><%= request.getAttribute("warning") %></div>
            <% } %>

            <form method="post" action="${pageContext.request.contextPath}/forgot-password" class="auth-form" novalidate>
                <div class="auth-field">
                    <label for="email">Email Address</label>
                    <input id="email" name="email" type="email" placeholder="Enter your email address" required>
                </div>

                <div class="auth-help-card">
                    <strong>Security note</strong>
                    <p>The reset link expires in 1 hour and can only be used once.</p>
                </div>

                <button type="submit" class="auth-btn">Send Reset Link</button>
            </form>

            <p class="auth-switch">
                Remembered your password?
                <a href="${pageContext.request.contextPath}/login" class="auth-link">Back to Login</a>
            </p>
        </section>
    </section>
</main>
<script src="${pageContext.request.contextPath}/js/auth-v2.js"></script>
</body>
</html>
