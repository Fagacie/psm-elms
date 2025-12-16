<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Enrollments - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .main-content {
            min-height: 100vh;
            background-color: #f8f9fa;
        }
        .enrollment-card {
            transition: all 0.3s;
            border: 1px solid #dee2e6;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }
        .enrollment-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .status-badge {
            font-size: 0.875rem;
            padding: 0.5rem 1rem;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-2 d-md-block sidebar p-0">
                <div class="position-sticky pt-3">
                    <div class="text-center mb-4">
                        <h4 class="text-white">PSM Student</h4>
                        <p class="text-white-50">${sessionScope.userName}</p>
                    </div>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">
                                <i class="fas fa-home me-2"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/student/courses">
                                <i class="fas fa-book me-2"></i> Browse Courses
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white active bg-white bg-opacity-25" href="${pageContext.request.contextPath}/student/my-enrollments">
                                <i class="fas fa-graduation-cap me-2"></i> My Enrollments
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">
                                <i class="fas fa-user me-2"></i> Profile
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/logout">
                                <i class="fas fa-sign-out-alt me-2"></i> Logout
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-10 ms-sm-auto px-md-4 main-content">
                <div class="py-4">
    
    <div class="container mt-4 mb-5">
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col">
                <h2><i class="fas fa-graduation-cap me-2"></i>My Enrollments</h2>
                <p class="text-muted">Track and access your enrolled courses</p>
            </div>
        </div>
        
        <!-- Success/Error Messages -->
        <c:if test="${param.error != null}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <c:choose>
                    <c:when test="${param.error == 'already'}">You are already enrolled in this course.</c:when>
                    <c:when test="${param.error == 'notfound'}">Enrollment not found.</c:when>
                    <c:when test="${param.error == 'unauthorized'}">You don't have permission to access this enrollment.</c:when>
                    <c:when test="${param.error == 'invalid'}">Invalid enrollment ID.</c:when>
                    <c:otherwise>An error occurred. Please try again.</c:otherwise>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <c:if test="${param.message != null}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="fas fa-info-circle me-2"></i>
                <c:choose>
                    <c:when test="${param.message == 'alreadypaid'}">This enrollment is already paid.</c:when>
                    <c:otherwise>Operation completed successfully.</c:otherwise>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <!-- Enrollments List -->
        <c:choose>
            <c:when test="${empty enrollments}">
                <div class="card text-center p-5">
                    <div class="card-body">
                        <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                        <h5>No Enrollments Yet</h5>
                        <p class="text-muted">Start your learning journey by enrolling in a course!</p>
                        <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                            <i class="fas fa-search me-2"></i>Browse Courses
                        </a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="row g-4">
                    <c:forEach items="${enrollments}" var="enrollment">
                        <div class="col-lg-6">
                            <div class="card enrollment-card h-100">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <h5 class="card-title mb-0">${enrollment.courseName}</h5>
                                        <c:choose>
                                            <c:when test="${enrollment.status == 'Enrolled' && enrollment.paymentStatus == 'Paid'}">
                                                <span class="badge bg-success status-badge">Enrolled</span>
                                            </c:when>
                                            <c:when test="${enrollment.status == 'Pending'}">
                                                <span class="badge bg-warning text-dark status-badge">Pending Payment</span>
                                            </c:when>
                                            <c:when test="${enrollment.status == 'Cancelled'}">
                                                <span class="badge bg-danger status-badge">Cancelled</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary status-badge">${enrollment.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <p class="card-text text-muted mb-3">${enrollment.courseDescription}</p>
                                    
                                    <div class="row mb-3">
                                        <div class="col-6">
                                            <small class="text-muted">Instructor</small>
                                            <div class="fw-bold">${enrollment.instructorName}</div>
                                        </div>
                                        <div class="col-6">
                                            <small class="text-muted">Enrolled Date</small>
                                            <div class="fw-bold">
                                                <c:choose>
                                                    <c:when test="${enrollment.enrollmentDate != null}">
                                                        ${enrollment.enrollmentDate.toString().substring(0, 10)}
                                                    </c:when>
                                                    <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row mb-3">
                                        <div class="col-6">
                                            <small class="text-muted">Payment Status</small>
                                            <div>
                                                <c:choose>
                                                    <c:when test="${enrollment.paymentStatus == 'Paid'}">
                                                        <span class="badge bg-success">Paid</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.paymentStatus == 'Pending'}">
                                                        <span class="badge bg-warning text-dark">Pending</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${enrollment.paymentStatus}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <small class="text-muted">Progress</small>
                                            <div class="fw-bold">${enrollment.completionStatus}</div>
                                        </div>
                                    </div>
                                    
                                    <div class="d-flex gap-2">
                                        <c:choose>
                                            <c:when test="${enrollment.paymentStatus == 'Paid'}">
                                                <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" 
                                                   class="btn btn-primary flex-grow-1">
                                                    <i class="fas fa-play-circle me-2"></i>Access Course
                                                </a>
                                            </c:when>
                                            <c:when test="${enrollment.paymentStatus == 'Pending'}">
                                                <a href="${pageContext.request.contextPath}/student/payment?enrollmentId=${enrollment.enrollmentId}" 
                                                   class="btn btn-success flex-grow-1">
                                                    <i class="fas fa-credit-card me-2"></i>Complete Payment
                                                </a>
                                            </c:when>
                                        </c:choose>
                                        <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" 
                                           class="btn btn-outline-secondary">
                                            <i class="fas fa-info-circle"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
                </div>
            </main>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
