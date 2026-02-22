<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="student-page">
<!-- Top Navigation Bar -->
<header class="app-header">
    <div class="header-left">
        <div class="logo-section">
            <i class="fas fa-graduation-cap"></i>
            <span>PSM E-Learning</span>
        </div>
        <h1 class="page-title">My Courses</h1>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i>
            Logout
        </a>
    </div>
</header>

<!-- Left Sidebar Navigation -->
<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="fas fa-home"></i>
            <span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item active">
            <i class="fas fa-graduation-cap"></i>
            <span>My Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/courses" class="nav-item">
            <i class="fas fa-book"></i>
            <span>Browse Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="nav-item">
            <i class="fas fa-clipboard-list"></i>
            <span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="nav-item">
            <i class="fas fa-certificate"></i>
            <span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i>
            <span>Profile</span>
        </a>
    </nav>
</aside>

<!-- Main Content Area -->
<main class="app-main">
    <div class="content-wrapper">
        <div class="page-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <span>/</span>
            <span>My Courses</span>
        </div>

        <!-- Page Actions -->
        <div class="page-actions student-page-actions">
            <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                <i class="fas fa-search"></i> Browse Courses
            </a>
        </div>

        <!-- Courses Grid -->
        <c:choose>
            <c:when test="${empty enrollments}">
                <div class="empty-state-box">
                    <i class="fas fa-graduation-cap"></i>
                    <p>Start your learning journey by enrolling in your first course.</p>
                    <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">Browse Courses</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="courses-grid">
                    <c:forEach var="enrollment" items="${enrollments}">
                        <c:set var="progress" value="${enrollment.completionStatus == 'Completed' ? 100 : (enrollment.completionStatus == 'In Progress' ? 65 : 20)}"/>
                        <c:set var="courseState" value="${enrollment.completionStatus == 'Completed' ? 'Completed' : (enrollment.paymentStatus == 'Pending' ? 'Pending' : 'In Progress')}"/>
                        
                        <div class="course-card">
                            <div class="course-header">
                                <h3 class="course-title">${enrollment.courseName}</h3>
                                <span class="status-badge status-${courseState}">${courseState}</span>
                            </div>
                            <p class="course-description">
                                <i class="fas fa-chalkboard-teacher"></i> Instructor: ${enrollment.instructorName}
                            </p>
                            <div class="course-meta">
                                <div class="meta-item">
                                    <i class="fas fa-folder-open"></i>
                                    <span>${materialCountByCourse[enrollment.courseId]} Materials</span>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-clipboard-list"></i>
                                    <span>${assessmentCountByCourse[enrollment.courseId]} Assessments</span>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-chart-line"></i>
                                    <span>${progress}% Progress</span>
                                </div>
                                <c:if test="${not empty enrollment.enrollmentDate}">
                                    <div class="meta-item">
                                        <i class="fas fa-calendar"></i>
                                        <span>Enrolled: ${enrollment.enrollmentDate.toLocalDate()}</span>
                                    </div>
                                </c:if>
                            </div>
                            <div class="course-actions">
                                <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" class="btn btn-primary btn-sm">
                                    <i class="fas fa-arrow-right"></i> Continue
                                </a>
                                <c:if test="${enrollment.completionStatus == 'Completed'}">
                                    <a href="${pageContext.request.contextPath}/student/certificates?enrollmentId=${enrollment.enrollmentId}" class="btn btn-secondary btn-sm">
                                        <i class="fas fa-certificate"></i> Certificate
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>
</body>
</html>
