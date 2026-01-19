<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PSM E-Learning</title>
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
            max-width: 900px;
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
        }
        .auth-header h2 {
            margin: 0 0 var(--spacing-xs) 0;
            font-size: 1.75rem;
        }
        .auth-header p {
            margin: 0 0 var(--spacing-sm) 0;
            opacity: 0.9;
        }
        .auth-body {
            padding: var(--spacing-xl) var(--spacing-lg);
        }
        .form-section {
            margin-bottom: var(--spacing-xl);
            padding-bottom: var(--spacing-xl);
            border-bottom: 1px solid var(--color-light-grey);
        }
        .form-section:last-of-type {
            border-bottom: none;
            padding-bottom: 0;
            margin-bottom: var(--spacing-lg);
        }
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--color-text);
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1rem;
        }
        .auth-link {
            text-align: center;
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid var(--color-light-grey);
            color: var(--color-text-light);
        }
        .auth-link a { color: var(--color-primary); text-decoration: none; font-weight: 500; }
        .auth-link a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h2>Student Registration</h2>
                <p>Join PSM E-Learning Platform</p>
                <small style="color: rgba(255,255,255,0.85);">Your registration number will be generated automatically (starting from PSM1783) and shown after successful registration.</small>
            </div>
            <div class="auth-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-error">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/register" method="post" enctype="multipart/form-data">
                    <div class="form-section">
                        <h5 class="section-title">Personal Information</h5>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="fullName">Full Name *</label>
                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                       value="${param.fullName}" required>
                            </div>
                            <div class="form-group">
                                <label for="email">Email Address *</label>
                                <input type="email" class="form-control" id="email" name="email" 
                                       value="${param.email}" required>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="phone">Phone Number *</label>
                                <input type="tel" class="form-control" id="phone" name="phone" 
                                       value="${param.phone}" required>
                            </div>
                            <div class="form-group">
                                <label for="dob">Date of Birth <span style="color: var(--color-text-light); font-size: 0.875rem;">(optional)</span></label>
                                <input type="date" class="form-control" id="dob" name="dob" 
                                       value="${param.dob}">
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="gender">Gender <span style="color: var(--text-secondary); font-size: 0.875rem;">(optional)</span></label>
                            <select class="form-control" id="gender" name="gender">
                                <option value="">Prefer not to say</option>
                                <option value="Male" ${param.gender == 'Male' ? 'selected' : ''}>Male</option>
                                <option value="Female" ${param.gender == 'Female' ? 'selected' : ''}>Female</option>
                                <option value="Other" ${param.gender == 'Other' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-section">
                        <h5 class="section-title">Student Information</h5>
                        <div class="form-row">
                            <div class="form-group">
                                <label>Registration Number</label>
                                <input type="text" class="form-control" value="Auto-generated after submission" disabled>
                                <small class="form-text">e.g., PSM1783. You'll receive it after registration.</small>
                            </div>
                            <div class="form-group">
                                <label for="qualification">Qualification <span style="color: var(--color-text-light); font-size: 0.875rem;">(optional)</span></label>
                                <input type="text" class="form-control" id="qualification" name="qualification" 
                                       value="${param.qualification}" placeholder="e.g., Bachelor's Degree">
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="country">Country *</label>
                                <input type="text" class="form-control" id="country" name="country" 
                                       value="${param.country}" required>
                            </div>
                            <div class="form-group">
                                <label for="state">State/Province <span style="color: var(--color-text-light); font-size: 0.875rem;">(optional)</span></label>
                                <input type="text" class="form-control" id="state" name="state" 
                                       value="${param.state}">
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="emergencyContact">Emergency Contact <span style="color: var(--color-text-light); font-size: 0.875rem;">(optional)</span></label>
                                <input type="tel" class="form-control" id="emergencyContact" name="emergencyContact" 
                                       value="${param.emergencyContact}" placeholder="Contact number">
                            </div>
                            <div class="form-group">
                                <label for="passport">Passport/ID Photo <span style="color: var(--color-text-light); font-size: 0.875rem;">(optional)</span></label>
                                <input type="file" class="form-control" id="passport" name="passport" accept="image/*">
                                <small class="form-text">Upload a passport-sized photo if available.</small>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h5 class="section-title">Security</h5>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="password">Password *</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                                <small class="form-text">Min 8 chars incl. uppercase, lowercase, digit & special character</small>
                            </div>
                            <div class="form-group">
                                <label for="confirmPassword">Confirm Password *</label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-full">Register</button>
                </form>

                <div class="auth-link">
                    Already have an account? <a href="${pageContext.request.contextPath}/login">Login here</a>
                </div>
            </div>
        </div>
    </div>
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
