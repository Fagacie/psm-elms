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
    <style>
        body {
            background: var(--color-background);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: var(--spacing-lg);
        }
        .auth-container {
            max-width: 480px;
            width: 100%;
        }
        .auth-card {
            background: var(--color-white);
            border: 1px solid var(--color-light-grey);
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .auth-header {
            background: var(--color-primary);
            color: var(--color-white);
            padding: var(--spacing-xl) var(--spacing-lg);
            text-align: center;
        }
        .auth-logo {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: var(--spacing-xs);
        }
        .auth-subtitle {
            font-size: 1rem;
            opacity: 0.9;
        }
        .auth-body {
            padding: var(--spacing-xl) var(--spacing-lg);
        }
        .auth-footer {
            padding: var(--spacing-lg);
            background: var(--color-background);
            text-align: center;
            border-top: 1px solid var(--color-light-grey);
        }
        .auth-link {
            color: var(--color-primary);
            text-decoration: none;
            font-weight: 500;
        }
        .auth-link:hover {
            text-decoration: underline;
        }
        .divider {
            text-align: center;
            margin: var(--spacing-lg) 0;
            position: relative;
        }
        .divider::before {
            content: "";
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 1px;
            background: var(--color-light-grey);
        }
        .divider-text {
            background: var(--color-white);
            padding: 0 var(--spacing-sm);
            position: relative;
            color: var(--color-text-light);
            font-size: 0.875rem;
        }
    </style>
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <div class="auth-logo">PSM E-Learning</div>
                <div class="auth-subtitle">Sign in to your account</div>
            </div>
            
            <div class="auth-body">
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success">
                        ${sessionScope.successMessage}
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        ${error}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="post">
                    <div class="form-group">
                        <label for="role" class="form-label">Role</label>
                        <select class="form-control" id="role" name="role" required>
                            <option value="Student" ${param.role == 'Student' ? 'selected' : ''}>Student</option>
                            <option value="Instructor" ${param.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                            <option value="Admin" ${param.role == 'Admin' ? 'selected' : ''}>Admin</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="identifier" class="form-label" id="identifierLabel">Student Reg Number or Email</label>
                        <input type="text" class="form-control" id="identifier" name="identifier"
                               placeholder="e.g. PSM1783 or email@example.com" required autofocus>
                        <div class="form-helper" id="identifierHelp">
                            Students may use their generated registration number (e.g. PSM1783). Other roles use email only.
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" class="form-control" id="password" name="password" 
                               placeholder="Enter your password" required>
                    </div>

                    <div class="form-group">
                        <div class="form-check">
                            <input type="checkbox" class="form-check-input" id="remember" name="remember">
                            <label class="form-check-label" for="remember">Remember me</label>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-full btn-large">
                        Sign In
                    </button>
                </form>
                
                <div class="divider">
                    <span class="divider-text">OR</span>
                </div>
                
                <div style="text-align: center;">
                    <a href="${pageContext.request.contextPath}/forgot-password" class="auth-link">
                        Forgot your password?
                    </a>
                </div>
            </div>
            
            <div class="auth-footer">
                Don't have an account? 
                <a href="${pageContext.request.contextPath}/register" class="auth-link">Register here</a>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: var(--spacing-lg);">
            <a href="${pageContext.request.contextPath}/" class="auth-link">← Back to Home</a>
        </div>
    </div>

    <script>
        const roleSelect = document.getElementById('role');
        const identifierLabel = document.getElementById('identifierLabel');
        const identifierHelp = document.getElementById('identifierHelp');
        roleSelect.addEventListener('change', function(){
            if(this.value === 'Student') {
                identifierLabel.textContent = 'Student Reg Number or Email';
                identifierHelp.textContent = 'Students may use their registration number (e.g. PSM1783) or email.';
            } else {
                identifierLabel.textContent = 'Email Address';
                identifierHelp.textContent = 'Enter your account email.';
            }
        });
    </script>
</body>
</html>
