<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.psm.elearning.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - PSM E-Learning Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .sidebar .nav-link {
            color: rgba(255,255,255,0.8);
            padding: 12px 20px;
            margin: 5px 0;
            border-radius: 8px;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: rgba(255,255,255,0.2);
            color: white;
        }
        .navbar {
            background-color: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-card {
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            color: white;
        }
        .stat-card.primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .stat-card.success { background: linear-gradient(135deg, #56ab2f 0%, #a8e063 100%); }
        .stat-card.warning { background: linear-gradient(135deg, #f12711 0%, #f5af19 100%); }
        .stat-card.info { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
        
        .hover-card {
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .hover-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.15) !important;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 col-lg-2 sidebar p-0">
                <div class="p-4">
                    <h4 class="text-center mb-4">
                        <i class="fas fa-graduation-cap"></i> PSM E-Learning
                    </h4>
                    
                    <div class="user-profile text-center mb-4">
                        <c:choose>
                            <c:when test="${not empty student.passportPath}">
                                <c:choose>
                                    <c:when test="${student.passportPath.startsWith('http')}">
                                        <img src="${student.passportPath}" alt="Profile" class="rounded-circle" style="width: 80px; height: 80px; object-fit: cover; border: 3px solid white;">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/${student.passportPath}" alt="Profile" class="rounded-circle" style="width: 80px; height: 80px; object-fit: cover; border: 3px solid white;">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <div class="avatar bg-white text-primary rounded-circle d-inline-flex align-items-center justify-content-center" 
                                     style="width: 80px; height: 80px; font-size: 32px;">
                                    <i class="fas fa-user"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <h6 class="mt-3 mb-1">${sessionScope.userName}</h6>
                        <small class="text-white-50">
                            <c:choose>
                                <c:when test="${sessionScope.userRole == 'Student'}">
                                    <i class="fas fa-user-graduate"></i> Student
                                </c:when>
                                <c:when test="${sessionScope.userRole == 'Instructor'}">
                                    <i class="fas fa-chalkboard-teacher"></i> Instructor
                                </c:when>
                                <c:when test="${sessionScope.userRole == 'Admin'}">
                                    <i class="fas fa-user-shield"></i> Administrator
                                </c:when>
                            </c:choose>
                        </small>
                    </div>

                    <nav class="nav flex-column">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/dashboard">
                            <i class="fas fa-tachometer-alt"></i> Dashboard
                        </a>
                        
                        <c:if test="${sessionScope.userRole == 'Student'}">
                            <a class="nav-link" href="${pageContext.request.contextPath}/student/courses">
                                <i class="fas fa-book"></i> My Courses
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/student/my-enrollments">
                                <i class="fas fa-clipboard-list"></i> Enrollments
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/student/assessments">
                                <i class="fas fa-tasks"></i> Assessments
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/student/certificates">
                                <i class="fas fa-certificate"></i> Certificates
                            </a>
                        </c:if>
                        
                        <c:if test="${sessionScope.userRole == 'Instructor'}">
                            <a class="nav-link" href="${pageContext.request.contextPath}/instructor/courses">
                                <i class="fas fa-book-open"></i> My Courses
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/instructor/materials">
                                <i class="fas fa-file-alt"></i> Materials
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/instructor/assessments">
                                <i class="fas fa-edit"></i> Assessments
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/instructor/students">
                                <i class="fas fa-users"></i> Students
                            </a>
                        </c:if>
                        
                        <c:if test="${sessionScope.userRole == 'Admin'}">
                            <a class="nav-link" href="${pageContext.request.contextPath}/admin/users">
                                <i class="fas fa-users-cog"></i> Users
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/admin/courses">
                                <i class="fas fa-book"></i> Courses
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/admin/payments">
                                <i class="fas fa-dollar-sign"></i> Payments
                            </a>
                            <a class="nav-link" href="${pageContext.request.contextPath}/admin/reports">
                                <i class="fas fa-chart-bar"></i> Reports
                            </a>
                        </c:if>

                        <hr class="bg-white">
                        
                        <a class="nav-link" href="${pageContext.request.contextPath}/profile">
                            <i class="fas fa-user-circle"></i> Profile
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/change-password">
                            <i class="fas fa-key"></i> Change Password
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/settings">
                            <i class="fas fa-cog"></i> Settings
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 col-lg-10 p-0">
                <!-- Top Navbar -->
                <nav class="navbar navbar-expand-lg navbar-light">
                    <div class="container-fluid">
                        <h5 class="mb-0">Dashboard</h5>
                        <div class="d-flex align-items-center">
                            <button class="btn btn-link position-relative me-3">
                                <i class="fas fa-bell fa-lg text-muted"></i>
                                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                    3
                                </span>
                            </button>
                            <div class="dropdown">
                                <button class="btn btn-link dropdown-toggle text-decoration-none" type="button" 
                                        data-bs-toggle="dropdown">
                                    <i class="fas fa-user-circle fa-lg"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                        <i class="fas fa-user"></i> Profile
                                    </a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/change-password">
                                        <i class="fas fa-key"></i> Change Password
                                    </a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/settings">
                                        <i class="fas fa-cog"></i> Settings
                                    </a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">
                                        <i class="fas fa-sign-out-alt"></i> Logout
                                    </a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </nav>

                <!-- Dashboard Content -->
                <div class="container-fluid p-4">
                    <div class="row mb-4">
                        <div class="col-12">
                            <h4>Welcome back, ${sessionScope.userName}!</h4>
                            <p class="text-muted">Here's what's happening with your account today.</p>
                        </div>
                    </div>

                    <!-- Statistics Cards -->
                    <div class="row">
                        <c:if test="${sessionScope.userRole == 'Student'}">
                            <div class="col-md-3">
                                <div class="stat-card primary">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Enrolled Courses</h6>
                                            <h2 class="mb-0">5</h2>
                                        </div>
                                        <i class="fas fa-book fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card success">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Completed</h6>
                                            <h2 class="mb-0">3</h2>
                                        </div>
                                        <i class="fas fa-check-circle fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card warning">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Pending Assessments</h6>
                                            <h2 class="mb-0">2</h2>
                                        </div>
                                        <i class="fas fa-tasks fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card info">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Certificates</h6>
                                            <h2 class="mb-0">3</h2>
                                        </div>
                                        <i class="fas fa-certificate fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${sessionScope.userRole == 'Instructor'}">
                            <div class="col-md-3">
                                <div class="stat-card primary">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>My Courses</h6>
                                            <h2 class="mb-0">8</h2>
                                        </div>
                                        <i class="fas fa-book-open fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card success">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Total Students</h6>
                                            <h2 class="mb-0">156</h2>
                                        </div>
                                        <i class="fas fa-users fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card warning">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Pending Reviews</h6>
                                            <h2 class="mb-0">12</h2>
                                        </div>
                                        <i class="fas fa-clipboard-check fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card info">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Materials</h6>
                                            <h2 class="mb-0">45</h2>
                                        </div>
                                        <i class="fas fa-file-alt fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${sessionScope.userRole == 'Admin'}">
                            <div class="col-md-3">
                                <div class="stat-card primary">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Total Users</h6>
                                            <h2 class="mb-0">342</h2>
                                        </div>
                                        <i class="fas fa-users fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card success">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Active Courses</h6>
                                            <h2 class="mb-0">28</h2>
                                        </div>
                                        <i class="fas fa-book fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card warning">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Pending Approvals</h6>
                                            <h2 class="mb-0">7</h2>
                                        </div>
                                        <i class="fas fa-hourglass-half fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card info">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>Revenue</h6>
                                            <h2 class="mb-0">$15.2K</h2>
                                        </div>
                                        <i class="fas fa-dollar-sign fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </div>

                    <!-- Quick Access Cards -->
                    <div class="row mt-4">
                        <div class="col-12">
                            <h5 class="mb-3"><i class="fas fa-th-large"></i> Quick Access</h5>
                        </div>
                        
                        <c:if test="${sessionScope.userRole == 'Student'}">
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/student/courses" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-book fa-3x text-primary"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Browse Courses</h5>
                                            <p class="card-text text-muted small">Explore and enroll in available courses</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-clipboard-list fa-3x text-success"></i>
                                            </div>
                                            <h5 class="card-title text-dark">My Enrollments</h5>
                                            <p class="card-text text-muted small">View your enrolled courses</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/student/assessments" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-tasks fa-3x text-warning"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Assessments</h5>
                                            <p class="card-text text-muted small">Take and view assessments</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/student/certificates" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-certificate fa-3x text-info"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Certificates</h5>
                                            <p class="card-text text-muted small">View your earned certificates</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </c:if>

                        <c:if test="${sessionScope.userRole == 'Instructor'}">
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/instructor/courses" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-book-open fa-3x text-primary"></i>
                                            </div>
                                            <h5 class="card-title text-dark">My Courses</h5>
                                            <p class="card-text text-muted small">Manage your courses</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/instructor/materials" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-file-alt fa-3x text-success"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Course Materials</h5>
                                            <p class="card-text text-muted small">Upload and manage materials</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/instructor/assessments" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-edit fa-3x text-warning"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Assessments</h5>
                                            <p class="card-text text-muted small">Create and grade assessments</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/instructor/students" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-users fa-3x text-info"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Students</h5>
                                            <p class="card-text text-muted small">View enrolled students</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </c:if>

                        <c:if test="${sessionScope.userRole == 'Admin'}">
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/admin/users" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-users-cog fa-3x text-primary"></i>
                                            </div>
                                            <h5 class="card-title text-dark">User Management</h5>
                                            <p class="card-text text-muted small">Manage all system users</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/admin/courses" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-book fa-3x text-success"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Course Management</h5>
                                            <p class="card-text text-muted small">Approve and manage courses</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/admin/payments" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-dollar-sign fa-3x text-warning"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Payments</h5>
                                            <p class="card-text text-muted small">View payment transactions</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="${pageContext.request.contextPath}/admin/reports" class="text-decoration-none">
                                    <div class="card border-0 shadow-sm h-100 hover-card">
                                        <div class="card-body text-center p-4">
                                            <div class="mb-3">
                                                <i class="fas fa-chart-bar fa-3x text-info"></i>
                                            </div>
                                            <h5 class="card-title text-dark">Reports</h5>
                                            <p class="card-text text-muted small">View system reports</p>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </c:if>
                    </div>

                    <!-- Recent Activity -->
                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card border-0 shadow-sm">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0"><i class="fas fa-clock"></i> Recent Activity</h5>
                                </div>
                                <div class="card-body">
                                    <p class="text-muted">Recent activities will appear here...</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
