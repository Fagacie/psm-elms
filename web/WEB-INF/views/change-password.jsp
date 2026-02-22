<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/change-password.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <!-- Top Navigation Bar (Dashboard style) -->
    <nav class="top-navbar">
        <div class="top-navbar-inner">
            <div class="top-navbar-left">
                <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                    <span class="logo-text">PSM</span>
                    <span class="logo-subtext">E-Learning</span>
                </a>
                <h1 class="page-title-nav">Change Password</h1>
            </div>
            <div class="top-navbar-right">
                <button class="notification-btn" aria-label="Notifications">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge">3</span>
                </button>
                <div class="user-display">
                    <div class="user-avatar-small">
                        <c:choose>
                            <c:when test="${not empty student.passportPath}">
                                <c:choose>
                                    <c:when test="${student.passportPath.startsWith('http')}">
                                        <img src="${student.passportPath}" alt="Profile">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/${student.passportPath}" alt="Profile">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-user"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <span class="user-name-display">${sessionScope.userName}</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- Left Sidebar -->
    <aside class="app-sidebar">
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/courses" class="nav-item">
                <i class="fas fa-book"></i>
                <span>Browse Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item">
                <i class="fas fa-graduation-cap"></i>
                <span>My Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="nav-item">
                <i class="fas fa-user"></i>
                <span>Profile</span>
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="app-main">
        <div class="content-wrapper">
            <!-- Page Header -->
            <div class="password-header">
                <h1>Change Password</h1>
                <p>Update your account password to keep your account secure.</p>
            </div>

            <!-- Feedback Messages -->
            <c:if test="${not empty sessionScope.passwordSuccess}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <span>${sessionScope.passwordSuccess}</span>
                </div>
                <c:remove var="passwordSuccess" scope="session"/>
            </c:if>
            
            <c:if test="${not empty sessionScope.passwordError}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>${sessionScope.passwordError}</span>
                </div>
                <c:remove var="passwordError" scope="session"/>
            </c:if>

            <!-- Password Change Form -->
            <div class="password-container">
                <!-- Left: Form -->
                <div class="password-form-section">
                    <div class="form-card">
                        <h2 class="form-title">Update Your Password</h2>
                        
                        <form action="${pageContext.request.contextPath}/change-password" method="post" id="passwordForm">
                            <!-- Current Password -->
                            <div class="form-group">
                                <label for="currentPassword" class="form-label">
                                    Current Password <span class="required">*</span>
                                </label>
                                <div class="password-input-wrapper">
                                    <input 
                                        type="password" 
                                        id="currentPassword" 
                                        name="currentPassword" 
                                        class="form-control" 
                                        placeholder="Enter your current password"
                                        required>
                                    <button type="button" class="toggle-password" data-target="currentPassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- New Password -->
                            <div class="form-group">
                                <label for="newPassword" class="form-label">
                                    New Password <span class="required">*</span>
                                </label>
                                <div class="password-input-wrapper">
                                    <input 
                                        type="password" 
                                        id="newPassword" 
                                        name="newPassword" 
                                        class="form-control" 
                                        placeholder="Enter your new password"
                                        required>
                                    <button type="button" class="toggle-password" data-target="newPassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- Confirm New Password -->
                            <div class="form-group">
                                <label for="confirmPassword" class="form-label">
                                    Confirm New Password <span class="required">*</span>
                                </label>
                                <div class="password-input-wrapper">
                                    <input 
                                        type="password" 
                                        id="confirmPassword" 
                                        name="confirmPassword" 
                                        class="form-control" 
                                        placeholder="Re-enter your new password"
                                        required>
                                    <button type="button" class="toggle-password" data-target="confirmPassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-lock"></i>
                                    Update Password
                                </button>
                                <a href="${pageContext.request.contextPath}/profile" class="btn btn-secondary">
                                    <i class="fas fa-times"></i>
                                    Cancel
                                </a>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Right: Password Guidelines -->
                <div class="password-guidelines-section">
                    <div class="guidelines-card">
                        <h3 class="guidelines-title">
                            <i class="fas fa-shield-alt"></i>
                            Password Security Guidelines
                        </h3>
                        <p class="guidelines-intro">Your password should include:</p>
                        
                        <ul class="guidelines-list">
                            <li class="guideline-item">
                                <span class="guideline-icon">
                                    <i class="fas fa-check"></i>
                                </span>
                                <span class="guideline-text">At least 8 characters long</span>
                            </li>
                            <li class="guideline-item">
                                <span class="guideline-icon">
                                    <i class="fas fa-check"></i>
                                </span>
                                <span class="guideline-text">Mix of uppercase and lowercase letters</span>
                            </li>
                            <li class="guideline-item">
                                <span class="guideline-icon">
                                    <i class="fas fa-check"></i>
                                </span>
                                <span class="guideline-text">At least one number (0-9)</span>
                            </li>
                            <li class="guideline-item">
                                <span class="guideline-icon">
                                    <i class="fas fa-check"></i>
                                </span>
                                <span class="guideline-text">At least one special character (!@#$%^&*)</span>
                            </li>
                        </ul>

                        <div class="guidelines-note">
                            <p><strong>Important:</strong></p>
                            <ul>
                                <li>Your new password must be different from your current password</li>
                                <li>Do not share your password with anyone</li>
                                <li>Use a unique password for your account</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        // Toggle password visibility
        document.querySelectorAll('.toggle-password').forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const targetId = this.dataset.target;
                const input = document.getElementById(targetId);
                const icon = this.querySelector('i');
                
                if (input.type === 'password') {
                    input.type = 'text';
                    icon.classList.remove('fa-eye');
                    icon.classList.add('fa-eye-slash');
                } else {
                    input.type = 'password';
                    icon.classList.remove('fa-eye-slash');
                    icon.classList.add('fa-eye');
                }
            });
        });

        // Form validation
        document.getElementById('passwordForm').addEventListener('submit', function(e) {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('New password and confirmation password do not match. Please try again.');
                return false;
            }
        });
    </script>
</body>
</html>
