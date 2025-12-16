<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PSM E-Learning Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 0;
        }
        .register-container {
            max-width: 600px;
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
        .password-strength {
            font-size: 0.875rem;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="register-container">
            <div class="card">
                <div class="card-header text-center">
                    <h3 class="mb-0"><i class="fas fa-user-plus"></i> Create Account</h3>
                    <p class="mb-0 mt-2">Join PSM E-Learning Platform</p>
                </div>
                <div class="card-body p-4">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle"></i> ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="post" id="registerForm">
                        <h6 class="text-muted mb-3"><i class="fas fa-user"></i> Personal Information</h6>
                        
                        <div class="mb-3">
                            <label for="fullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="fullName" name="fullName" 
                                   value="${fullName}" placeholder="Enter your full name" required>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" id="email" name="email" 
                                       value="${email}" placeholder="your.email@example.com" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="phoneNumber" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="phoneNumber" name="phoneNumber" 
                                       value="${phoneNumber}" placeholder="e.g., +60123456789">
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="dateOfBirth" class="form-label">Date of Birth</label>
                                <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth" 
                                       value="${dateOfBirth}">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="gender" class="form-label">Gender</label>
                                <select class="form-select" id="gender" name="gender">
                                    <option value="">Select gender</option>
                                    <option value="Male" ${gender == 'Male' ? 'selected' : ''}>Male</option>
                                    <option value="Female" ${gender == 'Female' ? 'selected' : ''}>Female</option>
                                    <option value="Other" ${gender == 'Other' ? 'selected' : ''}>Other</option>
                                </select>
                            </div>
                        </div>

                        <hr class="my-4">
                        <h6 class="text-muted mb-3"><i class="fas fa-id-card"></i> Student Information</h6>

                        <div class="mb-3">
                            <label for="registrationNumber" class="form-label">Registration Number</label>
                            <input type="text" class="form-control" id="registrationNumber" name="registrationNumber" 
                                   value="${registrationNumber}" placeholder="e.g., S2025001">
                        </div>

                        <div class="row">
                            <div class="col-md-8 mb-3">
                                <label for="program" class="form-label">Program</label>
                                <input type="text" class="form-control" id="program" name="program" 
                                       value="${program}" placeholder="e.g., Computer Science">
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="enrollmentYear" class="form-label">Enrollment Year</label>
                                <input type="number" class="form-control" id="enrollmentYear" name="enrollmentYear" 
                                       value="${enrollmentYear}" placeholder="2025" min="2000" max="2100">
                            </div>
                        </div>

                        <hr class="my-4">
                        <h6 class="text-muted mb-3"><i class="fas fa-lock"></i> Security</h6>

                        <div class="mb-3">
                            <label for="password" class="form-label">Password <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Create a strong password" required>
                            <div class="password-strength text-muted">
                                <small>Must be at least 8 characters with uppercase, lowercase, digit, and special character.</small>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="confirmPassword" class="form-label">Confirm Password <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                   placeholder="Re-enter your password" required>
                        </div>

                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="terms" required>
                            <label class="form-check-label" for="terms">
                                I agree to the <a href="#" target="_blank">Terms of Service</a> and 
                                <a href="#" target="_blank">Privacy Policy</a>
                            </label>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fas fa-user-plus"></i> Create Account
                            </button>
                        </div>

                        <div class="text-center mt-3">
                            <p class="mb-0">Already have an account?</p>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-secondary mt-2">
                                <i class="fas fa-sign-in-alt"></i> Sign In
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
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                return false;
            }
        });
    </script>
</body>
</html>
