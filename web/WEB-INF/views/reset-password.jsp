<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/reset-password.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="reset-password-page">
    <div class="reset-container">
        <div class="reset-card">
            <div class="reset-header">
                <div class="logo-icon">
                    <i class="fas fa-graduation-cap"></i>
                </div>
                <h1>PSM E-Learning</h1>
                <p>Reset Your Password</p>
            </div>

            <div class="reset-body">
                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i>
                        <span><%= request.getAttribute("success") %></span>
                    </div>
                    <div class="success-action">
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                            <i class="fas fa-sign-in-alt"></i>
                            Go to Login
                        </a>
                    </div>
                <% } else { %>
                    
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-error">
                            <i class="fas fa-exclamation-circle"></i>
                            <span><%= request.getAttribute("error") %></span>
                        </div>
                    <% } %>
                    
                    <% if (request.getAttribute("token") != null) { %>
                        <form method="post" action="${pageContext.request.contextPath}/reset-password" id="resetForm" class="reset-form">
                            <input type="hidden" name="token" value="<%= request.getAttribute("token") %>">
                            
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
                                        minlength="8"
                                        required>
                                    <button type="button" class="toggle-password" data-target="newPassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                                <div class="password-strength">
                                    <div class="password-strength-bar" id="strengthBar"></div>
                                </div>
                                <div class="strength-text">
                                    Password strength: <span id="strengthLabel">-</span>
                                </div>
                            </div>

                            <!-- Confirm Password -->
                            <div class="form-group">
                                <label for="confirmPassword" class="form-label">
                                    Confirm Password <span class="required">*</span>
                                </label>
                                <div class="password-input-wrapper">
                                    <input 
                                        type="password" 
                                        id="confirmPassword" 
                                        name="confirmPassword" 
                                        class="form-control" 
                                        placeholder="Confirm your new password"
                                        minlength="8"
                                        required>
                                    <button type="button" class="toggle-password" data-target="confirmPassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                                <div class="match-error" id="matchError">
                                    Passwords do not match
                                </div>
                            </div>

                            <!-- Password Requirements -->
                            <div class="password-requirements">
                                <h4>Password Requirements</h4>
                                <ul class="requirements-list">
                                    <li>
                                        <span class="requirement-icon">
                                            <i class="fas fa-check"></i>
                                        </span>
                                        <span>At least 8 characters long</span>
                                    </li>
                                    <li>
                                        <span class="requirement-icon">
                                            <i class="fas fa-check"></i>
                                        </span>
                                        <span>Mix of uppercase and lowercase letters</span>
                                    </li>
                                    <li>
                                        <span class="requirement-icon">
                                            <i class="fas fa-check"></i>
                                        </span>
                                        <span>At least one number (0-9)</span>
                                    </li>
                                    <li>
                                        <span class="requirement-icon">
                                            <i class="fas fa-check"></i>
                                        </span>
                                        <span>Special characters for stronger security</span>
                                    </li>
                                </ul>
                            </div>

                            <!-- Submit Button -->
                            <button type="submit" class="btn btn-primary btn-block" id="submitBtn">
                                <i class="fas fa-lock"></i>
                                Reset Password
                            </button>
                        </form>
                    <% } %>
                <% } %>
                <div class="reset-footer">
                    <a href="${pageContext.request.contextPath}/login" class="back-link">
                        <i class="fas fa-arrow-left"></i>
                        Back to Login
                    </a>
                </div>
            </div>
        </div>
    </div>

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

        // Password strength checker
        document.getElementById('newPassword')?.addEventListener('input', function() {
            const password = this.value;
            const strengthBar = document.getElementById('strengthBar');
            const strengthLabel = document.getElementById('strengthLabel');
            
            let strength = 0;
            if (password.length >= 8) strength++;
            if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
            if (password.match(/[0-9]/)) strength++;
            if (password.match(/[^a-zA-Z0-9]/)) strength++;
            
            const colors = ['#E74C3C', '#F39C12', '#F1C40F', '#27AE60'];
            const labels = ['Weak', 'Fair', 'Good', 'Strong'];
            const widths = ['25%', '50%', '75%', '100%'];
            
            if (password.length > 0) {
                strengthBar.style.width = widths[strength - 1];
                strengthBar.style.backgroundColor = colors[strength - 1];
                strengthLabel.textContent = labels[strength - 1];
                strengthLabel.style.color = colors[strength - 1];
            } else {
                strengthBar.style.width = '0%';
                strengthLabel.textContent = '-';
            }
        });

        // Password match validation
        document.getElementById('resetForm')?.addEventListener('submit', function(e) {
            const password = document.getElementById('newPassword').value;
            const confirm = document.getElementById('confirmPassword').value;
            const matchError = document.getElementById('matchError');
            
            if (password !== confirm) {
                e.preventDefault();
                matchError.style.display = 'block';
                document.getElementById('confirmPassword').focus();
                return false;
            }
        });

        document.getElementById('confirmPassword')?.addEventListener('input', function() {
            document.getElementById('matchError').style.display = 'none';
        });
    </script>
</body>
</html>
