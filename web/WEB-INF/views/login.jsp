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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Login.module.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="log_page">

<div class="log_container">
    <aside class="log_visual">
        <a href="${pageContext.request.contextPath}/landing" class="log_brand">PSM E-Learning</a>
        <div class="log_quote_wrap">
            <h2 class="log_quote">Welcome back. Let's pick up where you left off.</h2>
            <p class="log_quote_sub">Sign in to access your courses, track your progress, and manage your learning journey.</p>
        </div>
    </aside>

    <main class="log_form_panel">
        <header class="log_head">
            <h1>Login</h1>
            <p>Access your account using your registration number or email.</p>
        </header>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="log_alert log_alert_success">${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <c:if test="${not empty error}">
            <div class="log_alert log_alert_error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post" novalidate>
            <div class="log_field">
                <div class="log_label_row">
                    <label class="log_label" for="identifier">Registration Number or Email</label>
                </div>
                <input
                        id="identifier"
                        name="identifier"
                        class="log_input"
                        type="text"
                        value="${identifier}"
                        placeholder="e.g. PSM1783 or user@example.com"
                        required
                        autofocus>
            </div>

            <div class="log_field">
                <div class="log_label_row">
                    <label class="log_label" for="password">Password</label>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="log_link">Forgot password?</a>
                </div>
                <input 
                        id="password" 
                        name="password" 
                        class="log_input" 
                        type="password" 
                        placeholder="Enter your password" 
                        required>
            </div>

            <button type="submit" class="log_btn">Login</button>
        </form>

        <p class="log_switch">
            New student?
            <a href="${pageContext.request.contextPath}/register" class="log_link">Create Account</a>
        </p>
    </main>
</div>

</body>
</html>
