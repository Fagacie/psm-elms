<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <style>
        body {
            background-color: var(--bg-color);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 1rem;
        }
        .info-box {
            background-color: var(--light-grey);
            padding: 1rem;
            margin-top: 1.5rem;
        }
        .info-box h6 {
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        .info-box small {
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
    </style>
</head>
<body>
    <div class="auth-container" style="max-width: 500px;">
        <div class="auth-card">
            <div class="auth-header">
                <h2>Forgot Password?</h2>
                <p>Enter your email to receive a password reset link</p>
            </div>
            <div class="auth-body">
                
                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success">
                        <%= request.getAttribute("success") %>
                    </div>
                <% } %>
                
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-error">
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                
                <% if (request.getAttribute("warning") != null) { %>
                    <div class="alert alert-warning">
                        <%= request.getAttribute("warning") %>
                    </div>
                <% } %>
                
                <form method="post" action="${pageContext.request.contextPath}/forgot-password">
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" 
                               class="form-control" 
                               id="email" 
                               name="email" 
                               placeholder="Enter your email"
                               required>
                        <small class="form-text">We'll send a password reset link to this email</small>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-full">Send Reset Link</button>
                </form>
                
                <hr style="border: none; border-top: 1px solid var(--border-color); margin: 1.5rem 0;">
                
                <div style="text-align: center;">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">Back to Login</a>
                </div>
                
                <div class="info-box">
                    <h6>Security Note</h6>
                    <small>
                        For your security, the reset link will expire in 1 hour.
                        If you didn't request this, you can safely ignore this page.
                    </small>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
