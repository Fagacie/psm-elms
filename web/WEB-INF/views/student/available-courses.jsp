<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Courses - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
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
                <h1 class="page-title-nav">Browse Courses</h1>
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
            <a href="${pageContext.request.contextPath}/student/courses" class="nav-item active">
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
            <div class="page-header">
                <div>
                    <h2>Browse Available Courses</h2>
                    <p class="text-muted">Explore and enroll in courses that match your interests</p>
                </div>
            </div>

            <!-- Messages -->
            <c:if test="${not empty param.success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <c:choose>
                        <c:when test="${param.success == 'enrolled'}">Successfully enrolled in course!</c:when>
                        <c:otherwise>Operation completed successfully.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            
            <c:if test="${not empty param.error}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <c:choose>
                        <c:when test="${param.error == 'already'}">You are already enrolled in this course.</c:when>
                        <c:when test="${param.error == 'notfound'}">Course not found.</c:when>
                        <c:when test="${param.error == 'failed'}">Enrollment failed. Please try again.</c:when>
                        <c:otherwise>An error occurred. Please try again.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- Search and Filter Section -->
            <div class="card" style="margin-bottom: 24px;">
                <div class="card-body">
                    <h3 style="margin-bottom: 20px;">Search & Filter Courses</h3>
                    <form method="get" action="${pageContext.request.contextPath}/student/courses">
                        <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 16px;">
                            <!-- Search -->
                            <div class="form-group">
                                <label class="form-label">Search Courses</label>
                                <div style="display: flex; gap: 8px;">
                                    <input type="text" class="form-input" name="keyword" 
                                           placeholder="Search by name, category..." value="${searchKeyword}">
                                    <button class="btn btn-primary" type="submit" name="action" value="search">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- Category -->
                            <div class="form-group">
                                <label class="form-label">Category</label>
                                <input type="text" class="form-input" name="category" 
                                       placeholder="e.g., Programming" value="${filterCategory}">
                            </div>

                            <!-- Level -->
                            <div class="form-group">
                                <label class="form-label">Level</label>
                                <select class="form-input" name="level">
                                    <option value="">All Levels</option>
                                    <option value="Beginner" ${filterLevel == 'Beginner' ? 'selected' : ''}>Beginner</option>
                                    <option value="Intermediate" ${filterLevel == 'Intermediate' ? 'selected' : ''}>Intermediate</option>
                                    <option value="Advanced" ${filterLevel == 'Advanced' ? 'selected' : ''}>Advanced</option>
                                </select>
                            </div>

                            <!-- Min Fee -->
                            <div class="form-group">
                                <label class="form-label">Min Fee (₦)</label>
                                <input type="number" class="form-input" name="minFee" 
                                       step="0.01" min="0" value="${filterMinFee}">
                            </div>

                            <!-- Max Fee -->
                            <div class="form-group">
                                <label class="form-label">Max Fee (₦)</label>
                                <input type="number" class="form-input" name="maxFee" 
                                       step="0.01" min="0" value="${filterMaxFee}">
                            </div>
                        </div>
                        
                        <div style="display: flex; gap: 12px; justify-content: flex-end;">
                            <button type="submit" name="action" value="filter" class="btn btn-primary">
                                <i class="fas fa-filter"></i>
                                Apply Filters
                            </button>
                            <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-secondary">
                                <i class="fas fa-redo"></i>
                                Clear
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Courses Grid -->
            <c:choose>
                <c:when test="${empty courses}">
                    <div class="empty-state">
                        <i class="fas fa-book-open"></i>
                        <h3>No Courses Found</h3>
                        <p>No courses match your search criteria. Try adjusting your filters.</p>
                        <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                            <i class="fas fa-redo"></i>
                            View All Courses
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px;">
                        <c:forEach var="course" items="${courses}">
                            <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}"/>
                            <div class="card course-card">
                                <div class="course-media">
                                    <div class="media-fallback">
                                        <i class="fas fa-book"></i>
                                    </div>
                                </div>
                                <div class="course-header">
                                    <div class="header-left">
                                        <span class="badge badge-${course.level == 'Beginner' ? 'success' : (course.level == 'Intermediate' ? 'warning' : 'error')}">${course.level}</span>
                                        <span class="chip"><i class="fas fa-layer-group"></i> ${course.category}</span>
                                        <c:if test="${isEnrolled}">
                                            <span class="pill pill-success">Enrolled</span>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <h3 class="course-title">${course.courseName}</h3>
                                    <p class="course-description">
                                        <c:choose>
                                            <c:when test="${not empty course.description && course.description.length() > 140}">
                                                ${course.description.substring(0, 140)}...
                                            </c:when>
                                            <c:otherwise>
                                                ${course.description}
                                            </c:otherwise>
                                        </c:choose>
                                    </p>

                                    <div class="course-meta">
                                        <div class="meta-item">
                                            <i class="fas fa-clock"></i>
                                            <span>${course.duration} hours</span>
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-signal"></i>
                                            <span>${course.level}</span>
                                        </div>
                                    </div>

                                    <div class="course-footer">
                                        <div class="course-price">
                                            ₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                        </div>
                                        <div class="course-actions">
                                            <c:choose>
                                                <c:when test="${isEnrolled}">
                                                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-secondary">
                                                        View Enrollment
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="btn btn-primary">
                                                        Enroll Now
                                                        <i class="fas fa-credit-card"></i>
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                            <a href="${pageContext.request.contextPath}/student/courses?action=details&id=${course.courseId}" class="btn btn-secondary">
                                                View Details
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
    </main>

    <style>
        .course-card {
            height: 100%;
            display: flex;
            flex-direction: column;
            border: 1px solid var(--color-border, #e5e7eb);
            background: var(--color-background, #ffffff);
            transition: transform 0.2s ease, border-color 0.2s ease;
        }
        .course-media {
            height: 160px;
            background: linear-gradient(180deg, #f8fafc 0%, #eef2f7 100%);
            border-bottom: 1px solid var(--color-border, #e5e7eb);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .media-fallback {
            width: 64px;
            height: 64px;
            border: 1px solid var(--color-border, #e5e7eb);
            display: grid;
            place-items: center;
            color: var(--color-primary, #1e3a8a);
            font-size: 28px;
        }

        .course-card:hover {
            transform: translateY(-1px);
            border-color: var(--color-primary);
        }

        .course-header {
            padding: 12px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--color-border);
        }

        .header-left { display: flex; gap: 8px; align-items: center; }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            padding: 4px 8px;
            border: 1px solid var(--color-border);
            color: var(--color-text-secondary);
        }

        .course-price-top {
            font-size: 18px;
            font-weight: 700;
            color: var(--color-success);
        }

        .course-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--color-text-primary);
            margin-bottom: 12px;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .course-description {
            color: var(--color-text-secondary);
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 16px;
            flex-grow: 1;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .course-meta {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: var(--color-text-secondary);
        }

        .meta-item i {
            width: 16px;
            color: var(--color-primary);
        }

        .course-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 16px;
            border-top: 1px solid var(--color-border);
        }

        .course-actions { display: flex; gap: 10px; }

        .badge-warning { background-color: var(--color-warning); color: #000; }
    </style>
</body>
</html>