<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - PSM E-Learning Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <div class="auth-page">
        <div class="auth-wrapper">
            <div class="split-card">
                <section class="left-panel">
                    <div class="brand-section">
                        <div class="brand-icon">
                            <i class="fas fa-graduation-cap"></i>
                        </div>
                        <h1 class="brand-title">PSM E-Learning</h1>
                        <p class="brand-tagline">Empowering Education Through Innovation</p>
                        <div class="brand-features">
                            <div class="feature-item">
                                <i class="fas fa-book-open"></i>
                                <span>Comprehensive Courses</span>
                            </div>
                            <div class="feature-item">
                                <i class="fas fa-chart-line"></i>
                                <span>Track Progress</span>
                            </div>
                            <div class="feature-item">
                                <i class="fas fa-users"></i>
                                <span>Expert Instructors</span>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="right-panel">
                    <div class="form-container">
                        <header class="form-header">
                            <h2 class="form-title">Welcome Back</h2>
                            <p class="form-subtitle">Sign in to your account</p>
                        </header>

                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-icon">
                        <i class="fas fa-check-circle"></i>
                        ${sessionScope.successMessage}
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-icon">
                        <i class="fas fa-exclamation-circle"></i>
                        ${error}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="post" class="login-form">
                    <div class="form-group">
                        <label for="identifier" class="form-label">
                            <i class="fas fa-user-circle"></i> Student Reg Number or Email
                        </label>
                        <input type="text" class="form-control" id="identifier" name="identifier"
                               placeholder="e.g. PSM1783 or email@example.com" required autofocus>
                        <div class="form-helper" id="identifierHelp">
                            <i class="fas fa-info-circle"></i>
                            Students use registration number (e.g. PSM1783). Others use email.
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password" class="form-label">
                            <i class="fas fa-lock"></i> Password
                        </label>
                        <input type="password" class="form-control" id="password" name="password" 
                               placeholder="Enter your password" required>
                    </div>

                    <div class="form-options">
                        <div class="form-check">
                            <input type="checkbox" class="form-check-input" id="remember" name="remember">
                            <label class="form-check-label" for="remember">Remember me</label>
                        </div>
                        <a href="${pageContext.request.contextPath}/forgot-password" class="forgot-link">
                            <i class="fas fa-question-circle"></i> Forgot password?
                        </a>
                    </div>

                    <button type="submit" class="btn btn-primary btn-full btn-large btn-sign-in">
                        <i class="fas fa-sign-in-alt"></i> Sign In
                    </button>
                </form>
                
                <div class="auth-divider">
                    <span class="divider-text">Don't have an account?</span>
                </div>
                
                <a href="${pageContext.request.contextPath}/register" class="btn btn-secondary btn-full">
                    <i class="fas fa-user-plus"></i> Create Account
                </a>

                    <footer class="form-footer">
                        <a href="${pageContext.request.contextPath}/" class="back-home-link">
                            <i class="fas fa-arrow-left"></i> Back to Home
                        </a>
                    </footer>
                    </div>
                </section>
            </div>
        </div>
    </div>
</body>
</html>
