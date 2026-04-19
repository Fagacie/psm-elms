<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-premium.css?v=20260417-1">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="auth-page">
<main class="auth-shell">
    <section class="auth-layout auth-layout-recovery" aria-labelledby="reset-title">
        <aside class="auth-visual" aria-hidden="true">
            <p class="auth-kicker">Account Recovery</p>
            <h2>Create a fresh password and get back in.</h2>
            <p class="auth-visual-text">Use a strong password you have not used elsewhere. We will activate it for your account as soon as you submit it.</p>

            <ul class="auth-visual-list">
                <li>Secure token-based reset flow</li>
                <li>Real-time password confirmation</li>
                <li>Fast return to login after update</li>
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
                <h1 id="reset-title">Reset Password</h1>
                <p>Choose a new password for your account and confirm it before submitting.</p>
            </header>

            <div class="theme-toolbar theme-toolbar-compact">
                <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false">
                    <span class="theme-toggle-label">Dark mode</span>
                </button>
            </div>

            <% if (request.getAttribute("success") != null) { %>
                <div class="auth-alert auth-alert-success"><c:out value="${requestScope.success}" /></div>
                <a href="${pageContext.request.contextPath}/login" class="auth-btn auth-btn-link">Go to Login</a>
            <% } else { %>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="auth-alert auth-alert-error"><c:out value="${requestScope.error}" /></div>
                <% } %>

                <% if (request.getAttribute("token") != null) { %>
                    <form method="post" action="${pageContext.request.contextPath}/reset-password" id="resetForm" class="auth-form" novalidate>
                        <input type="hidden" name="token" value="<c:out value='${requestScope.token}'/>">

                        <div class="auth-field">
                            <label for="newPassword">New Password</label>
                            <input type="password" id="newPassword" name="newPassword" minlength="8" placeholder="Create a strong password" required>
                        </div>

                        <div class="auth-field">
                            <label for="confirmPassword">Confirm Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" placeholder="Re-enter your password" required>
                            <small id="matchError" class="auth-inline-error" hidden>Passwords do not match.</small>
                        </div>

                        <div class="auth-help-card">
                            <strong>Password requirements</strong>
                            <ul class="auth-checklist">
                                <li>At least 8 characters</li>
                                <li>Uppercase and lowercase letters</li>
                                <li>At least one number and one special character</li>
                            </ul>
                        </div>

                        <button type="submit" class="auth-btn">Reset Password</button>
                    </form>
                <% } %>
            <% } %>

            <p class="auth-switch">
                Need to sign in instead?
                <a href="${pageContext.request.contextPath}/login" class="auth-link">Back to Login</a>
            </p>
        </section>
    </section>
</main>

<script>
    (function () {
        var form = document.getElementById('resetForm');
        if (!form) return;

        form.addEventListener('submit', function (e) {
            var password = document.getElementById('newPassword').value;
            var confirm = document.getElementById('confirmPassword').value;
            var matchError = document.getElementById('matchError');
            if (password !== confirm) {
                e.preventDefault();
                matchError.hidden = false;
            }
        });

        var confirmField = document.getElementById('confirmPassword');
        if (confirmField) {
            confirmField.addEventListener('input', function () {
                var matchError = document.getElementById('matchError');
                matchError.hidden = true;
            });
        }
    })();
</script>
<script src="${pageContext.request.contextPath}/js/auth-v2.js"></script>
</body>
</html>
