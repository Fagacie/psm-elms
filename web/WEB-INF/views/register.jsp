<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px 0;
        }
        .register-container {
            max-width: 800px;
            width: 100%;
            margin: 20px;
        }
        .register-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .register-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .register-body {
            padding: 40px;
        }
        .form-section {
            margin-bottom: 30px;
        }
        .section-title {
            color: #667eea;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }
        .form-label {
            font-weight: 500;
            color: #333;
            margin-bottom: 8px;
        }
        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        .btn-register {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 12px 40px;
            font-weight: 600;
            letter-spacing: 0.5px;
            transition: transform 0.3s;
        }
        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .login-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-card">
            <div class="register-header">
                <h2><i class="fas fa-user-plus"></i> Student Registration</h2>
                <p class="mb-0">Join PSM E-Learning Platform</p>
                    <small>Your registration number will be generated automatically (starting from PSM1783) and shown after successful registration. Use it or your email to log in.</small>
            </div>
            <div class="register-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/register" method="post">
                    <!-- Personal Information -->
                    <div class="form-section">
                        <h5 class="section-title"><i class="fas fa-user"></i> Personal Information</h5>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="fullName" class="form-label">Full Name *</label>
                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                       value="${param.fullName}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label">Email Address *</label>
                                <input type="email" class="form-control" id="email" name="email" 
                                       value="${param.email}" required>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="phone" class="form-label">Phone Number *</label>
                                <input type="tel" class="form-control" id="phone" name="phone" 
                                       value="${param.phone}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="dob" class="form-label">Date of Birth <span class="text-muted small">(optional)</span></label>
                                <input type="date" class="form-control" id="dob" name="dob" 
                                       value="${param.dob}">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="gender" class="form-label">Gender <span class="text-muted small">(optional)</span></label>
                            <select class="form-select" id="gender" name="gender">
                                <option value="">Prefer not to say</option>
                                <option value="Male" ${param.gender == 'Male' ? 'selected' : ''}>Male</option>
                                <option value="Female" ${param.gender == 'Female' ? 'selected' : ''}>Female</option>
                                <option value="Other" ${param.gender == 'Other' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                    </div>

                    <!-- Student Information -->
                    <div class="form-section">
                        <h5 class="section-title"><i class="fas fa-graduation-cap"></i> Student Information</h5>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Registration Number</label>
                                <div class="form-text">Automatically assigned after submission (e.g. PSM1783). You will see it in the success message and can use it to log in.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="qualification" class="form-label">Qualification <span class="text-muted small">(optional)</span></label>
                                <input type="text" class="form-control" id="qualification" name="qualification" 
                                       value="${param.qualification}" placeholder="e.g., Bachelor's Degree">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="country" class="form-label">Country *</label>
                                <input type="text" class="form-control" id="country" name="country" 
                                       value="${param.country}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="state" class="form-label">State/Province <span class="text-muted small">(optional)</span></label>
                                <input type="text" class="form-control" id="state" name="state" 
                                       value="${param.state}">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="emergencyContact" class="form-label">Emergency Contact <span class="text-muted small">(optional)</span></label>
                                <input type="tel" class="form-control" id="emergencyContact" name="emergencyContact" 
                                       value="${param.emergencyContact}" placeholder="Contact number">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="passport" class="form-label">Passport/ID Photo <span class="text-muted small">(optional)</span></label>
                                <input type="file" class="form-control" id="passport" name="passport" accept="image/*">
                                <small class="text-muted">Upload a passport-sized photo if available.</small>
                            </div>
                        </div>
                    </div>

                    <!-- Security -->
                    <div class="form-section">
                        <h5 class="section-title"><i class="fas fa-lock"></i> Security</h5>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="password" class="form-label">Password *</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                                <small class="text-muted">Min 8 chars incl. uppercase, lowercase, digit & special character</small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="confirmPassword" class="form-label">Confirm Password *</label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                            </div>
                        </div>
                    </div>

                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary btn-register">
                            <i class="fas fa-user-plus"></i> Register
                        </button>
                    </div>
                </form>

                <div class="login-link">
                    Already have an account? <a href="${pageContext.request.contextPath}/login">Login here</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Client-side password match validation
        document.querySelector('form').addEventListener('submit', function(e) {
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
