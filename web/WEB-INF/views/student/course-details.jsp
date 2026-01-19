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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-details.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
                <h1 class="page-title-nav">Course Details</h1>
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
            <!-- Page Header Block with Course Meta -->
            <section class="section-card page-header">
                <div class="page-header-top">
                    <h2 class="course-title"><c:out value="${course.courseName}"/></h2>
                    <div class="course-meta">
                        <span class="meta-item">
                            <span class="meta-label">Category:</span>
                            <span class="meta-value"><c:out value="${course.category}"/></span>
                        </span>
                        <span class="meta-item">
                            <span class="meta-label">Level:</span>
                            <span class="meta-value"><c:out value="${course.level}"/></span>
                        </span>
                        <span class="meta-item">
                            <span class="meta-label">Fee:</span>
                            <span class="meta-value">₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                        </span>
                    </div>
                </div>
                <div class="page-header-actions">
                    <p class="course-subtext">Enroll to unlock access to materials, assessments, and grades.</p>
                        <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}"/>
                        <div class="course-actions">
                            <c:choose>
                                <c:when test="${isEnrolled}">
                                    <span class="pill pill-success">You are enrolled</span>
                                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-secondary">
                                        <i class="fas fa-list"></i> View My Enrollments
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
                </div>
            </section>

            <div class="grid two-column">
                <!-- Course Overview -->
                <section class="section-card">
                    <h3 class="section-title">Course Overview</h3>
                    <div class="overview-grid">
                        <div class="overview-block description">
                            <h4 class="block-title">Description</h4>
                            <p class="block-text"><c:out value="${course.description}"/></p>
                        </div>
                        <div class="overview-block facts">
                            <div class="fact-row">
                                <span class="fact-label">Duration</span>
                                <span class="fact-value"><c:out value="${course.duration}"/> hours</span>
                            </div>
                            <div class="fact-row">
                                <span class="fact-label">Level</span>
                                <span class="fact-value"><c:out value="${course.level}"/></span>
                            </div>
                            <div class="fact-row">
                                <span class="fact-label">Category</span>
                                <span class="fact-value"><c:out value="${course.category}"/></span>
                            </div>
                            
                        </div>
                    </div>
                </section>

                <!-- Key Course Information -->
                <section class="section-card">
                    <h3 class="section-title">Key Course Information</h3>
                    <table class="data-table">
                        <tbody>
                            <tr>
                                <th>Course Code</th>
                                <td><c:out value="${course.courseId}"/></td>
                            </tr>
                            <tr>
                                <th>Course Level</th>
                                <td><c:out value="${course.level}"/></td>
                            </tr>
                            
                        </tbody>
                    </table>
                </section>
            </div>

            <div class="grid two-column">
                <!-- Instructor Information -->
                <section class="section-card">
                    <h3 class="section-title">Instructor</h3>
                    <c:choose>
                        <c:when test="${not empty instructor}">
                            <table class="data-table">
                                <tbody>
                                    <tr>
                                        <th>Name</th>
                                        <td><c:out value="${instructor.fullName}"/></td>
                                    </tr>
                                    <c:if test="${not empty instructor.email}">
                                        <tr>
                                            <th>Email</th>
                                            <td><c:out value="${instructor.email}"/></td>
                                        </tr>
                                    </c:if>
                                    <c:if test="${not empty instructor.phone}">
                                        <tr>
                                            <th>Phone</th>
                                            <td><c:out value="${instructor.phone}"/></td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <p class="block-text">Instructor information is not available.</p>
                        </c:otherwise>
                    </c:choose>
                </section>

                <!-- Assessment Overview & Navigation -->
                <section class="section-card">
                    <h3 class="section-title">Assessment Overview</h3>
                    <div class="assessment-grid">
                        <div class="assessment-item">
                            <div class="assessment-label">Total Assignments</div>
                            <div class="assessment-value">
                                <c:choose>
                                    <c:when test="${empty assessmentSummary}">0</c:when>
                                    <c:otherwise><c:out value="${assessmentSummary.totalAssignments}"/></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="assessment-item">
                            <div class="assessment-label">Total Quizzes/Exams</div>
                            <div class="assessment-value">
                                <c:choose>
                                    <c:when test="${empty assessmentSummary}">0</c:when>
                                    <c:otherwise><c:out value="${assessmentSummary.totalQuizzes}"/></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="assessment-item">
                            <div class="assessment-label">Assessment Weighting</div>
                            <div class="assessment-value">
                                <c:choose>
                                    <c:when test="${empty assessmentSummary}">—</c:when>
                                    <c:otherwise><c:out value="${assessmentSummary.weighting}"/></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    <div class="assessment-links">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/student/assignments<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>"><i class="fas fa-tasks"></i> View Assignments</a>
                        <a class="btn" href="${pageContext.request.contextPath}/student/quizzes<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>"><i class="fas fa-clipboard-question"></i> View Quizzes</a>
                        <a class="btn" href="${pageContext.request.contextPath}/student/grades<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>"><i class="fas fa-chart-line"></i> View Grades</a>
                        <a class="btn" href="${pageContext.request.contextPath}/student/announcements<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>"><i class="fas fa-bullhorn"></i> View Announcements</a>
                        <a class="btn" href="${pageContext.request.contextPath}/student/materials<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>"><i class="fas fa-folder-open"></i> View Materials</a>
                    </div>
                </section>
            </div>

            <!-- Optional Notices -->
            <c:if test="${not empty courseAnnouncements}">
                <section class="section-card">
                    <h3 class="section-title">Recent Notices</h3>
                    <ul class="notice-list">
                        <c:forEach var="note" items="${courseAnnouncements}" varStatus="loop">
                            <c:if test="${loop.index < 3}">
                                <li class="notice-item">
                                    <div class="notice-title"><c:out value="${note.title}"/></div>
                                    <div class="notice-meta"><span class="notice-date"><c:out value="${note.date}"/></span></div>
                                    <p class="notice-text"><c:out value="${note.summary}"/></p>
                                </li>
                            </c:if>
                        </c:forEach>
                    </ul>
                </section>
            </c:if>
        </div>
    </main>
</body>
</html>
