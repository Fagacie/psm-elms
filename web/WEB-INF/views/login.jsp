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
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-v2.css">
</head>
<body class="av2-page">
    <main class="av2-shell">
        <section class="av2-panel av2-brand" aria-hidden="true">
            <p class="av2-kicker">PSM E-Learning</p>
            <h1>Welcome Back</h1>
            <div class="av2-scene" role="presentation">
                <span class="av2-obj av2-book" data-depth="16"></span>
                <span class="av2-obj av2-pen" data-depth="24"></span>
                <span class="av2-obj av2-cap" data-depth="12"></span>
                <span class="av2-obj av2-paper" data-depth="20"></span>
                <span class="av2-obj av2-ring" data-depth="28"></span>
            </div>
            <a class="av2-link" href="${pageContext.request.contextPath}/">Back to Home</a>
        </section>

        <section class="av2-panel av2-form-panel">
            <div class="av2-form-wrap">
                <header class="av2-form-head">
                    <h2>Sign In</h2>
                    <p>Enter your account credentials to continue.</p>
                </header>

                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="av2-alert av2-alert-success">${sessionScope.successMessage}</div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="av2-alert av2-alert-error">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="post" class="av2-form" novalidate>
                    <div class="av2-group">
                        <label for="identifier">Registration Number or Email</label>
                        <input
                            id="identifier"
                            name="identifier"
                            type="text"
                            value="${identifier}"
                            placeholder="e.g. PSM1783 or user@example.com"
                            required
                            autofocus>
                        <small>Students can use registration number. All users can use email.</small>
                    </div>

                    <div class="av2-group">
                        <label for="password">Password</label>
                        <input id="password" name="password" type="password" placeholder="Enter your password" required>
                    </div>

                    <div class="av2-row">
                        <a href="${pageContext.request.contextPath}/forgot-password" class="av2-link-inline">Forgot password?</a>
                    </div>

                    <button type="submit" class="av2-btn av2-btn-solid">Login</button>
                </form>

                <div class="av2-switch">
                    <span>New student?</span>
                    <a href="${pageContext.request.contextPath}/register">Create account</a>
                </div>
            </div>
        </section>
    </main>
    <script src="${pageContext.request.contextPath}/js/auth-v2.js"></script></body>
</html>


