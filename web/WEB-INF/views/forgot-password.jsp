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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Login.module.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="log_page">

<div class="log_container">
    <aside class="log_visual">
        <a href="${pageContext.request.contextPath}/landing" class="log_brand">PSM E-Learning</a>
        <div class="log_quote_wrap">
            <h2 class="log_quote">Regain access without friction.</h2>
            <p class="log_quote_sub">We will send a secure reset link to your email so you can return to your learning workspace quickly.</p>
        </div>
    </aside>

    <main class="log_form_panel">
        <header class="log_head">
            <h1>Account Recovery</h1>
            <p>Enter your email address to receive a secure reset link.</p>
        </header>

        <% if (request.getAttribute("success") != null) { %>
            <div class="log_alert log_alert_success"><%= request.getAttribute("success") %></div>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
            <div class="log_alert log_alert_error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (request.getAttribute("warning") != null) { %>
            <div class="log_alert log_alert_error"><%= request.getAttribute("warning") %></div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/forgot-password" novalidate>
            <div class="log_field">
                <div class="log_label_row">
                    <label class="log_label" for="email">Email Address</label>
                </div>
                <input
                        id="email"
                        name="email"
                        class="log_input"
                        type="email"
                        placeholder="Enter your email address"
                        required
                        autofocus>
            </div>

            <div class="log_field" style="margin-top: 16px; margin-bottom: 24px; padding: 12px 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px;">
                <span style="display: block; font-size: 0.8rem; font-weight: 700; color: #475569; text-transform: uppercase; margin-bottom: 4px;">Security Note</span>
                <span style="font-size: 0.85rem; color: #64748b;">The reset link expires in 1 hour and can only be used once.</span>
            </div>

            <button type="submit" class="log_btn">Send Reset Link</button>
        </form>

        <p class="log_switch">
            Remembered your password?
            <a href="${pageContext.request.contextPath}/login" class="log_link">Back to Login</a>
        </p>
    </main>
</div>

</body>
</html>
