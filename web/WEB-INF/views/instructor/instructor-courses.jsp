<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
<body>
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
            <div class="user-menu">
                <div class="user-info">
                    <span class="user-name"><c:out value="${empty user ? sessionScope.user.fullName : user.fullName}"/></span>
                    <span class="user-role">Instructor</span>
                </div>
                <div class="user-avatar"><i class="fas fa-user"></i></div>
            </div>
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
            <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item active">
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
            <a href="${pageContext.request.contextPath}/profile" class="nav-item">
                <i class="fas fa-user"></i>
                <span>Profile / Settings</span>
            </a>
        </nav>
    </aside>

    <!-- Main Content Area -->
    <main class="app-main">
        <div class="content-wrapper">
            <!-- Page Actions -->
            <div class="page-actions">
                <a href="${pageContext.request.contextPath}/instructor/courses?action=create" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Create New Course
                </a>
            </div>

            <!-- Success/Error Messages -->
            <c:if test="${param.success == 'created'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Course created successfully! Pending admin approval.
                </div>
            </c:if>
            <c:if test="${param.success == 'updated'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Course updated successfully!
                </div>
            </c:if>
            <c:if test="${param.success == 'deleted'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Course deleted successfully!
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> An error occurred. Please try again.
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <!-- Courses Grid -->
            <c:choose>
                <c:when test="${empty courses}">
                    <div class="empty-state-box">
                        <i class="fas fa-book"></i>
                        <p>You haven't created any courses yet.</p>
                        <a href="${pageContext.request.contextPath}/instructor/courses?action=create" class="btn btn-primary">Create Your First Course</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="courses-grid">
                        <c:forEach var="course" items="${courses}">
                            <div class="course-card">
                                <div class="course-header">
                                    <h3 class="course-title"><c:out value="${course.courseName}"/></h3>
                                    <span class="status-badge status-${course.status}"><c:out value="${course.status}"/></span>
                                </div>
                                <p class="course-description">
                                    <c:choose>
                                        <c:when test="${not empty course.description && course.description.length() > 120}">
                                            <c:out value="${course.description.substring(0, 120)}"/>...
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${course.description}"/>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <div class="course-meta">
                                    <div class="meta-item">
                                        <i class="fas fa-layer-group"></i>
                                        <span><c:out value="${course.category}"/></span>
                                    </div>
                                    <div class="meta-item">
                                        <i class="fas fa-signal"></i>
                                        <span><c:out value="${course.level}"/></span>
                                    </div>
                                    <c:if test="${not empty course.duration}">
                                        <div class="meta-item">
                                            <i class="fas fa-clock"></i>
                                            <span><c:out value="${course.duration}"/> hours</span>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty course.courseFee}">
                                        <div class="meta-item">
                                            <i class="fas fa-money-bill"></i>
                                            <span>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                                        </div>
                                    </c:if>
                                </div>
                                <div class="course-actions">
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=students&courseId=${course.courseId}" class="btn btn-primary btn-sm">
                                        <i class="fas fa-users"></i> Students
                                    </a>
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=edit&id=${course.courseId}" class="btn btn-secondary btn-sm">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=delete&id=${course.courseId}" 
                                       class="btn btn-danger btn-sm" 
                                       onclick="return confirm('Are you sure you want to delete this course?');">
                                        <i class="fas fa-trash"></i> Delete
                                    </a>
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
