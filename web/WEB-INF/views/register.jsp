<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-premium.css">
</head>
<body class="auth-page">
<main class="auth-shell">
    <section class="auth-card-simple" aria-labelledby="register-title">
        <header class="auth-head">
            <h1 id="register-title">Create Account</h1>
            <p>Join PSM E-Learning and start learning today.</p>
        </header>

        <c:if test="${not empty error}">
            <div class="auth-alert auth-alert-error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="post" class="auth-form" novalidate>
                <div class="auth-field">
                    <label for="fullName">Full Name</label>
                    <input id="fullName" name="fullName" type="text" value="${param.fullName}" required>
                </div>

                <div class="auth-field">
                    <label for="email">Email</label>
                    <input id="email" name="email" type="email" value="${param.email}" required>
                </div>

                <div class="auth-field">
                    <label for="phone">Phone Number</label>
                    <input id="phone" name="phone" type="tel" value="${param.phone}" placeholder="e.g. +255712345678" required>
                </div>

                <div class="auth-field">
                    <label for="country">Country</label>
                    <input id="country" name="country" type="text" value="${param.country}" required>
                </div>

                <div class="auth-field">
                    <label for="password">Password</label>
                    <input id="password" name="password" type="password" required>
                </div>

                <div class="auth-field">
                    <label for="confirmPassword">Confirm Password</label>
                    <input id="confirmPassword" name="confirmPassword" type="password" required>
                </div>

                <p class="auth-note">Registration number is generated automatically after successful account creation.</p>

                <button type="submit" class="auth-btn">Create Account</button>
            </form>

            <p class="auth-switch">
                Already have an account?
                <a href="${pageContext.request.contextPath}/login" class="auth-link">Login</a>
            </p>
        </section>
    </section>
</main>

    <script>
        (function () {
            var form = document.querySelector('.auth-form');
            if (!form) return;
            form.addEventListener('submit', function (e) {
                var password = document.getElementById('password').value;
                var confirmPassword = document.getElementById('confirmPassword').value;
                if (password !== confirmPassword) {
                    e.preventDefault();
                    alert('Passwords do not match.');
                }
            });
        })();
    </script>
    <script src="${pageContext.request.contextPath}/js/auth-v2.js"></script>
</body>
</html>


