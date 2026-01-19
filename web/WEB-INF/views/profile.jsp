<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">
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
                <h1 class="page-title-nav">My Profile</h1>
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
            <c:choose>
                <c:when test="${sessionScope.userRole == 'Instructor'}">
                    <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item">
                        <i class="fas fa-book"></i>
                        <span>My Courses</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/assignments" class="nav-item">
                        <i class="fas fa-tasks"></i>
                        <span>Assignments</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/quizzes" class="nav-item">
                        <i class="fas fa-clipboard-question"></i>
                        <span>Quizzes / Exams</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/submissions" class="nav-item">
                        <i class="fas fa-inbox"></i>
                        <span>Student Submissions</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/grades" class="nav-item">
                        <i class="fas fa-chart-line"></i>
                        <span>Grades / Evaluation</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/announcements" class="nav-item">
                        <i class="fas fa-bullhorn"></i>
                        <span>Announcements</span>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/student/courses" class="nav-item">
                        <i class="fas fa-book"></i>
                        <span>Browse Courses</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item">
                        <i class="fas fa-graduation-cap"></i>
                        <span>My Enrollments</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/materials" class="nav-item">
                        <i class="fas fa-folder-open"></i>
                        <span>Materials</span>
                    </a>
                </c:otherwise>
            </c:choose>
            <a href="${pageContext.request.contextPath}/profile" class="nav-item active">
                <i class="fas fa-user"></i>
                <span>Profile</span>
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="app-main">
        <div class="content-wrapper">
            <!-- Page Header -->
            <div class="profile-header">
                <h1>My Profile</h1>
                <p>View and manage your personal information and account settings</p>
            </div>

            <!-- Alert Messages -->
            <c:if test="${not empty sessionScope.profileSuccess}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${sessionScope.profileSuccess}
                </div>
                <c:remove var="profileSuccess" scope="session"/>
            </c:if>
            
            <c:if test="${not empty sessionScope.profileError}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> ${sessionScope.profileError}
                </div>
                <c:remove var="profileError" scope="session"/>
            </c:if>

            <!-- Profile Grid -->
            <div class="profile-grid">
                <!-- Left Sidebar: Profile Photo & Quick Info -->
                <div class="profile-sidebar">
                    <div class="profile-photo-section">
                        <div class="profile-photo">
                            <c:choose>
                                <c:when test="${not empty student.passportPath}">
                                    <c:choose>
                                        <c:when test="${student.passportPath.startsWith('http')}">
                                            <img src="${student.passportPath}" alt="Profile Picture">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/${student.passportPath}" alt="Profile Picture">
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <i class="fas fa-user"></i>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <c:if test="${sessionScope.userRole == 'Student'}">
                            <form action="${pageContext.request.contextPath}/profile-picture" method="post" enctype="multipart/form-data" id="photoUploadForm">
                                <input type="file" name="passportPhoto" id="photoInput" accept="image/jpeg,image/png,image/gif" required>
                                <label for="photoInput" class="btn btn-secondary upload-photo-btn">
                                    <i class="fas fa-camera"></i> Upload Photo
                                </label>
                            </form>
                        </c:if>
                    </div>
                    
                    <div class="profile-quick-info">
                        <div class="quick-info-item">
                            <div class="quick-info-label">Full Name</div>
                            <div class="quick-info-value">${user.fullName}</div>
                        </div>
                        <c:if test="${sessionScope.userRole == 'Student'}">
                            <div class="quick-info-item">
                                <div class="quick-info-label">Student ID</div>
                                <div class="quick-info-value">${student.regNumber}</div>
                            </div>
                            <div class="quick-info-item">
                                <div class="quick-info-label">Status</div>
                                <div class="quick-info-value">
                                    <span class="status-badge">Active</span>
                                </div>
                            </div>
                        </c:if>
                        <c:if test="${sessionScope.userRole == 'Instructor'}">
                            <c:if test="${not empty instructor.specialization}">
                                <div class="quick-info-item">
                                    <div class="quick-info-label">Specialization</div>
                                    <div class="quick-info-value">${instructor.specialization}</div>
                                </div>
                            </c:if>
                            <c:if test="${not empty instructor.yearsOfExperience}">
                                <div class="quick-info-item">
                                    <div class="quick-info-label">Years of Experience</div>
                                    <div class="quick-info-value">${instructor.yearsOfExperience}</div>
                                </div>
                            </c:if>
                        </c:if>
                    </div>
                </div>

                <!-- Right Main: Profile Sections -->
                <div class="profile-main">
                    <form action="${pageContext.request.contextPath}/profile" method="post">
                        <!-- Personal Information Section -->
                        <div class="profile-section">
                            <h2 class="section-title">Personal Information</h2>
                            <div class="info-grid">
                                <div class="info-item">
                                    <label class="info-label">Full Name *</label>
                                    <input type="text" name="fullName" value="${user.fullName}" class="form-input" required>
                                </div>
                                
                                <div class="info-item">
                                    <label class="info-label">Email Address</label>
                                    <input type="email" value="${user.email}" class="form-input" readonly>
                                </div>
                                
                                <div class="info-item">
                                    <label class="info-label">Phone Number</label>
                                    <input type="tel" name="phone" value="${user.phone}" class="form-input">
                                </div>
                                
                                <c:if test="${sessionScope.userRole == 'Student'}">
                                    <div class="info-item">
                                        <label class="info-label">Date of Birth</label>
                                        <input type="date" name="dob" value="${student.dob}" class="form-input">
                                    </div>
                                    
                                    <div class="info-item">
                                        <label class="info-label">Gender</label>
                                        <select name="gender" class="form-input">
                                            <option value="">Select Gender</option>
                                            <option value="Male" ${student.gender == 'Male' ? 'selected' : ''}>Male</option>
                                            <option value="Female" ${student.gender == 'Female' ? 'selected' : ''}>Female</option>
                                        </select>
                                    </div>
                                    
                                    <div class="info-item">
                                        <label class="info-label">Country</label>
                                        <input type="text" name="country" value="${student.country}" class="form-input">
                                    </div>
                                    
                                    <div class="info-item">
                                        <label class="info-label">State / Province</label>
                                        <input type="text" name="state" value="${student.state}" class="form-input">
                                    </div>
                                    
                                    <div class="info-item">
                                        <label class="info-label">Emergency Contact</label>
                                        <input type="tel" name="emergencyContact" value="${student.emergencyContact}" class="form-input">
                                    </div>
                                </c:if>
                            </div>
                        </div>

                            <!-- Academic Information Section (Student) -->
                        <c:if test="${sessionScope.userRole == 'Student'}">
                            <div class="profile-section">
                                <h2 class="section-title">Academic Information</h2>
                                <div class="info-grid">
                                    <div class="info-item">
                                        <label class="info-label">Registration Number</label>
                                        <div class="info-value readonly">${student.regNumber}</div>
                                    </div>
                                    
                                    <div class="info-item">
                                        <label class="info-label">Qualification</label>
                                        <input type="text" name="qualification" value="${student.qualification}" class="form-input">
                                    </div>
                                </div>
                            </div>
                        </c:if>

                            <!-- Instructor Information (read-only) -->
                            <c:if test="${sessionScope.userRole == 'Instructor'}">
                                <div class="profile-section">
                                    <h2 class="section-title">Instructor Information</h2>
                                    <div class="info-grid">
                                        <c:if test="${not empty instructor.specialization}">
                                            <div class="info-item">
                                                <label class="info-label">Specialization</label>
                                                <div class="info-value readonly">${instructor.specialization}</div>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty instructor.certification}">
                                            <div class="info-item">
                                                <label class="info-label">Certification</label>
                                                <div class="info-value readonly">${instructor.certification}</div>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty instructor.yearsOfExperience}">
                                            <div class="info-item">
                                                <label class="info-label">Years of Experience</label>
                                                <div class="info-value readonly">${instructor.yearsOfExperience}</div>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty instructor.hireDate}">
                                            <div class="info-item">
                                                <label class="info-label">Hire Date</label>
                                                <div class="info-value readonly">${instructor.hireDate}</div>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </c:if>

                        <!-- Account Settings Section -->
                        <div class="profile-section">
                            <h2 class="section-title">Account Settings</h2>
                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save"></i>
                                    Save Changes
                                </button>
                                <a href="${pageContext.request.contextPath}/change-password" class="btn btn-secondary">
                                    <i class="fas fa-key"></i>
                                    Change Password
                                </a>
                                <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i>
                                    Back to Dashboard
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>

    <script>
        // Auto-submit photo upload form when file is selected
        document.getElementById('photoInput')?.addEventListener('change', function() {
            if (this.files && this.files[0]) {
                document.getElementById('photoUploadForm').submit();
            }
        });
    </script>
</body>
</html>
