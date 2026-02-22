<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.courseName}"/> - PSM E-Learning</title>
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
        <h1 class="page-title">Course Details</h1>
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
            <a href="${pageContext.request.contextPath}/student/courses" class="nav-item active">
                <i class="fas fa-book"></i>
                <span>Browse Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item">
                <i class="fas fa-graduation-cap"></i>
                <span>My Courses</span>
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

    <!-- Main Content -->
    <main class="app-main">
        <div class="content-wrapper">
            <div class="page-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">
                    <i class="fas fa-home"></i> Dashboard
                </a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
                <span>/</span>
                <span><c:out value="${course.courseName}"/></span>
            </div>

            <!-- Page Actions -->
            <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}"/>
            <div class="page-actions student-page-actions">
                <c:choose>
                    <c:when test="${isEnrolled}">
                        <span class="status-badge status-Approved">
                            <i class="fas fa-check-circle"></i> Enrolled
                        </span>
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-secondary">
                            <i class="fas fa-list"></i> View My Courses
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="btn btn-primary">
                            <i class="fas fa-credit-card"></i> Enroll Now
                        </a>
                    </c:otherwise>
                </c:choose>
                <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Courses
                </a>
            </div>

            <!-- Course Details Card -->
            <div class="course-card">
                <div class="course-header">
                    <h2 class="course-title"><c:out value="${course.courseName}"/></h2>
                </div>
                
                <p class="course-description"><c:out value="${course.description}"/></p>
                
                <div class="course-meta">
                    <div class="meta-item">
                        <i class="fas fa-folder"></i>
                        <span><c:out value="${course.category}"/></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-signal"></i>
                        <span><c:out value="${course.level}"/></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-clock"></i>
                        <span><c:out value="${course.duration}"/> hours</span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-money-bill-wave"></i>
                        <span>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                    </div>
                    <c:if test="${not empty instructor}">
                        <div class="meta-item">
                            <i class="fas fa-chalkboard-teacher"></i>
                            <span><c:out value="${instructor.fullName}"/></span>
                        </div>
                    </c:if>
                    <div class="meta-item">
                        <i class="fas fa-file-alt"></i>
                        <span>
                            <c:choose>
                                <c:when test="${empty assessmentSummary}">0</c:when>
                                <c:otherwise><c:out value="${assessmentSummary.totalAssignments}"/></c:otherwise>
                            </c:choose>
                            Assignments
                        </span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-clipboard-list"></i>
                        <span>
                            <c:choose>
                                <c:when test="${empty assessmentSummary}">0</c:when>
                                <c:otherwise><c:out value="${assessmentSummary.totalQuizzes}"/></c:otherwise>
                            </c:choose>
                            Quizzes
                        </span>
                    </div>
                </div>

                <div class="course-actions">
                    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/materials<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>">
                        <i class="fas fa-folder-open"></i> View Materials
                    </a>
                    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/assessments<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>">
                        <i class="fas fa-clipboard-list"></i> View Assessments
                    </a>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
