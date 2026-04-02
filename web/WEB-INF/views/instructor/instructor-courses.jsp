<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Sora:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="instructor-ui">
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
                <span>Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item">
                <i class="fas fa-folder-open"></i>
                <span>Materials</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item">
                <i class="fas fa-clipboard-list"></i>
                <span>Assessments</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item">
                <i class="fas fa-certificate"></i>
                <span>Certificates</span>
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
            <section class="ins-page-head">
                <div>
                    <p class="ins-page-kicker">Course Management</p>
                    <h2>Build, review, and operate your learning catalog</h2>
                    <p>This workspace should feel like a professional course studio. Each course card now acts like an operational hub with banner, status, context, and the main actions you actually use.</p>
                </div>
                <div class="ins-hero-actions">
                    <a href="${pageContext.request.contextPath}/instructor/courses?action=create" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Create New Course
                    </a>
                </div>
            </section>

            <section class="ins-hero-card">
                <div class="ins-hero-grid">
                    <div>
                        <h3>Your course portfolio at a glance</h3>
                        <p>Use this page to monitor approval state, keep banners and metadata clean, and jump into materials, assessments, and roster management from one place.</p>
                    </div>
                    <div class="ins-hero-metrics">
                        <div class="ins-metric">
                            <strong>${not empty courses ? courses.size() : 0}</strong>
                            <span>Total courses</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${fn:length(courses)}</strong>
                            <span>Managed in this workspace</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${param.success == 'created' ? 'New' : 'Live'}</strong>
                            <span>Latest workspace state</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${param.error != null ? 'Check' : 'Ready'}</strong>
                            <span>Status signal</span>
                        </div>
                    </div>
                </div>
            </section>

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
                                <div class="course-banner-wrap">
                                    <c:choose>
                                        <c:when test="${not empty course.courseBanner}">
                                            <img class="course-banner" src="${course.courseBanner}" alt="${course.courseName} banner">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="course-banner course-banner-placeholder">
                                                <i class="fas fa-image"></i>
                                                <span>No banner uploaded</span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
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
                                    <a href="${pageContext.request.contextPath}/instructor/materials?courseId=${course.courseId}" class="btn btn-secondary btn-sm">
                                        <i class="fas fa-folder-open"></i> Materials
                                    </a>
                                    <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${course.courseId}" class="btn btn-secondary btn-sm">
                                        <i class="fas fa-clipboard-list"></i> Assessments
                                    </a>
                                    <a href="${pageContext.request.contextPath}/instructor/content-organizer?courseId=${course.courseId}" class="btn btn-primary btn-sm">
                                        <i class="fas fa-layer-group"></i> Organize
                                    </a>
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=students&courseId=${course.courseId}" class="btn btn-secondary btn-sm">
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

