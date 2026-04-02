<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-v2.css">
</head>
<body class="av2-page">
    <main class="av2-shell">
        <section class="av2-panel av2-brand" aria-hidden="true">
            <p class="av2-kicker">Account Security</p>
            <h1>Set New Password</h1>
            <div class="av2-scene" role="presentation">
                <span class="av2-obj av2-book" data-depth="16"></span>
                <span class="av2-obj av2-pen" data-depth="24"></span>
                <span class="av2-obj av2-cap" data-depth="12"></span>
                <span class="av2-obj av2-paper" data-depth="20"></span>
                <span class="av2-obj av2-ring" data-depth="28"></span>
            </div>
            <a class="av2-link" href="${pageContext.request.contextPath}/login">Back to Login</a>
        </section>

        <section class="av2-panel av2-form-panel">
            <div class="av2-form-wrap">
                <header class="av2-form-head">
                    <h2>Reset Password</h2>
                    <p>Choose a strong new password for your account.</p>
                </header>

                <% if (request.getAttribute("success") != null) { %>
                    <div class="av2-alert av2-alert-success"><%= request.getAttribute("success") %></div>
                    <div class="av2-switch">
                        <a href="${pageContext.request.contextPath}/login">Go to Login</a>
                    </div>
                <% } else { %>

                    <% if (request.getAttribute("error") != null) { %>
                        <div class="av2-alert av2-alert-error"><%= request.getAttribute("error") %></div>
                    <% } %>

                    <% if (request.getAttribute("token") != null) { %>
                        <form method="post" action="${pageContext.request.contextPath}/reset-password" id="resetForm" class="av2-form" novalidate>
                            <input type="hidden" name="token" value="<%= request.getAttribute("token") %>">

                            <div class="av2-group">
                                <label for="newPassword">New Password</label>
                                <input type="password" id="newPassword" name="newPassword" minlength="8" required>
                                <small>Minimum 8 chars with uppercase, lowercase, number and special character.</small>
                            </div>

                            <div class="av2-group">
                                <label for="confirmPassword">Confirm Password</label>
                                <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" required>
                                <small id="matchError" style="display:none;color:#b0182a;">Passwords do not match.</small>
                            </div>

                            <button type="submit" class="av2-btn av2-btn-solid">Reset Password</button>
                        </form>
                    <% } %>
                <% } %>

                <div class="av2-switch">
                    <a href="${pageContext.request.contextPath}/login">Back to Login</a>
                </div>
            </div>
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
                    matchError.style.display = 'block';
                }
            });

            var confirmField = document.getElementById('confirmPassword');
            if (confirmField) {
                confirmField.addEventListener('input', function () {
                    var matchError = document.getElementById('matchError');
                    matchError.style.display = 'none';
                });
            }
        })();
    </script>
    <script src="${pageContext.request.contextPath}/js/auth-v2.js"></script></body>
</html>


