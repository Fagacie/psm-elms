<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .reset-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 500px;
            width: 100%;
        }
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0 !important;
            padding: 2rem;
        }
        .password-strength {
            height: 5px;
            margin-top: 5px;
            background: #e9ecef;
            border-radius: 3px;
            overflow: hidden;
        }
        .password-strength-bar {
            height: 100%;
            transition: all 0.3s;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="reset-card mx-auto">
            <div class="card-header text-center">
                <i class="fas fa-lock fa-3x mb-3"></i>
                <h3>Reset Your Password</h3>
                <p class="mb-0">Enter your new password below</p>
            </div>
            <div class="card-body p-4">
                
                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle"></i> <%= request.getAttribute("success") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <div class="text-center mt-3">
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                            <i class="fas fa-sign-in-alt"></i> Go to Login
                        </a>
                    </div>
                <% } else { %>
                
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>
                    
                    <% if (request.getAttribute("token") != null) { %>
                        <form method="post" action="${pageContext.request.contextPath}/reset-password" id="resetForm">
                            <input type="hidden" name="token" value="<%= request.getAttribute("token") %>">
                            
                            <div class="mb-3">
                                <label for="newPassword" class="form-label">
                                    <i class="fas fa-key"></i> New Password
                                </label>
                                <div class="input-group">
                                    <input type="password" 
                                           class="form-control" 
                                           id="newPassword" 
                                           name="newPassword" 
                                           placeholder="Enter new password"
                                           minlength="8"
                                           required>
                                    <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                                <div class="password-strength">
                                    <div class="password-strength-bar" id="strengthBar"></div>
                                </div>
                                <div class="form-text" id="strengthText">
                                    Password strength: <span id="strengthLabel">-</span>
                                </div>
                            </div>
                            
                            <div class="mb-4">
                                <label for="confirmPassword" class="form-label">
                                    <i class="fas fa-check-double"></i> Confirm Password
                                </label>
                                <input type="password" 
                                       class="form-control" 
                                       id="confirmPassword" 
                                       name="confirmPassword" 
                                       placeholder="Confirm new password"
                                       minlength="8"
                                       required>
                                <div class="invalid-feedback" id="matchError">
                                    Passwords do not match
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-primary btn-lg w-100 mb-3" id="submitBtn">
                                <i class="fas fa-check"></i> Reset Password
                            </button>
                        </form>
                        
                        <div class="alert alert-info mt-3">
                            <h6><i class="fas fa-lightbulb"></i> Password Requirements</h6>
                            <ul class="mb-0 small">
                                <li>At least 8 characters long</li>
                                <li>Mix of uppercase and lowercase letters recommended</li>
                                <li>Include numbers and special characters for stronger security</li>
                            </ul>
                        </div>
                    <% } %>
                <% } %>
                
                <hr>
                
                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/login" class="text-decoration-none">
                        <i class="fas fa-arrow-left"></i> Back to Login
                    </a>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Toggle password visibility
        document.getElementById('togglePassword')?.addEventListener('click', function() {
            const password = document.getElementById('newPassword');
            const icon = this.querySelector('i');
            if (password.type === 'password') {
                password.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                password.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
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
            
            const colors = ['#dc3545', '#fd7e14', '#ffc107', '#28a745'];
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
            const confirmInput = document.getElementById('confirmPassword');
            
            if (password !== confirm) {
                e.preventDefault();
                confirmInput.classList.add('is-invalid');
                matchError.style.display = 'block';
            }
        });
        
        document.getElementById('confirmPassword')?.addEventListener('input', function() {
            this.classList.remove('is-invalid');
        });
    </script>
</body>
</html>
