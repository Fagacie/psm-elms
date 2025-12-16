<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - PSM E-Learning Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
        }
        .login-container {
            max-width: 450px;
            margin: 0 auto;
        }
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0 !important;
            padding: 30px;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="login-container">
            <div class="card">
                <div class="card-header text-center">
                    <h3 class="mb-0"><i class="fas fa-graduation-cap"></i> PSM E-Learning</h3>
                    <p class="mb-0 mt-2">Sign in to your account</p>
                </div>
                <div class="card-body p-4">
                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="successMessage" scope="session"/>
                    </c:if>
                    
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle"></i> ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="post">
                        <div class="mb-3">
                            <label for="role" class="form-label"><i class="fas fa-user-tag"></i> Role</label>
                            <select class="form-select" id="role" name="role" required>
                                <option value="Student" ${param.role == 'Student' ? 'selected' : ''}>Student</option>
                                <option value="Instructor" ${param.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                                <option value="Admin" ${param.role == 'Admin' ? 'selected' : ''}>Admin</option>
                            </select>
                        </div>
                        <div class="mb-3" id="identifierBlock">
                            <label for="identifier" class="form-label" id="identifierLabel">
                                <i class="fas fa-id-card"></i> Student Reg Number or Email
                            </label>
                            <input type="text" class="form-control" id="identifier" name="identifier"
                                   placeholder="e.g. PSM1783 or email@example.com" required autofocus>
                            <small class="text-muted" id="identifierHelp">Students may use their generated registration number (e.g. PSM1783). Other roles use email only.</small>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">
                                <i class="fas fa-lock"></i> Password
                            </label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Enter your password" required>
                        </div>

                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="remember" name="remember">
                            <label class="form-check-label" for="remember">Remember me</label>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fas fa-sign-in-alt"></i> Sign In
                            </button>
                        </div>

                        <div class="text-center mt-3">
                            <a href="${pageContext.request.contextPath}/forgot-password" class="text-muted">
                                <i class="fas fa-question-circle"></i> Forgot Password?
                            </a>
                        </div>

                        <hr class="my-4">

                        <div class="text-center">
                            <p class="mb-0">Don't have an account?</p>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-outline-primary mt-2">
                                <i class="fas fa-user-plus"></i> Create Account
                            </a>
                        </div>
                    </form>
                </div>
            </div>
            
            <div class="text-center mt-3">
                <p class="text-white">
                    <small>&copy; 2025 PSM E-Learning Platform. All rights reserved.</small>
                </p>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const roleSelect = document.getElementById('role');
        const identifierLabel = document.getElementById('identifierLabel');
        const identifierHelp = document.getElementById('identifierHelp');
        roleSelect.addEventListener('change', function(){
            if(this.value === 'Student') {
                identifierLabel.innerHTML = '<i class="fas fa-id-card"></i> Student Reg Number or Email';
                identifierHelp.textContent = 'Students may use their registration number (e.g. PSM1783) or email.';
            } else {
                identifierLabel.innerHTML = '<i class="fas fa-envelope"></i> Email Address';
                identifierHelp.textContent = 'Enter your account email.';
            }
        });
    </script>
</body>
</html>
