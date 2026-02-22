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
    <title>Student Dashboard - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <!-- Top Navigation Bar (Global) -->
    <nav class="top-navbar">
        <div class="top-navbar-inner">
            <div class="top-navbar-left">
                <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                    <span class="logo-text">PSM</span>
                    <span class="logo-subtext">E-Learning</span>
                </a>
                <h1 class="page-title-nav">Student Dashboard</h1>
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

    <!-- Sidebar Navigation (Primary) -->
    <aside class="sidebar-nav">
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-link active">
                    <i class="fas fa-th-large"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/student/courses" class="sidebar-link">
                    <i class="fas fa-book"></i>
                    <span>Browse Courses</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sidebar-link">
                    <i class="fas fa-graduation-cap"></i>
                    <span>My Courses</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/student/certificates" class="sidebar-link">
                    <i class="fas fa-certificate"></i>
                    <span>Certificates</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/profile" class="sidebar-link">
                    <i class="fas fa-user-circle"></i>
                    <span>Profile</span>
                </a>
            </li>
        </ul>
    </aside>
    <!-- Main Content Area (Dynamic) -->
    <main class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <h1>Welcome, ${sessionScope.userName}</h1>
            <p>Overview of your academic progress and activities</p>
        </div>

        <!-- A. Summary Metrics (Top Section) -->
        <div class="metrics-grid">
            <c:if test="${sessionScope.userRole == 'Student'}">
                <div class="metric-block">
                    <div class="metric-icon primary">
                        <i class="fas fa-book"></i>
                    </div>
                    <div class="metric-value">${not empty enrolledCoursesCount ? enrolledCoursesCount : 0}</div>
                    <p class="metric-label">Enrolled Courses</p>
                </div>
                
                <div class="metric-block">
                    <div class="metric-icon warning">
                        <i class="fas fa-clipboard-list"></i>
                    </div>
                    <div class="metric-value">${not empty pendingAssignmentsCount ? pendingAssignmentsCount : 0}</div>
                    <p class="metric-label">Pending Assignments</p>
                </div>
                
                <div class="metric-block">
                    <div class="metric-icon info">
                        <i class="fas fa-question-circle"></i>
                    </div>
                    <div class="metric-value">${not empty upcomingQuizzesCount ? upcomingQuizzesCount : 0}</div>
                    <p class="metric-label">Upcoming Quizzes</p>
                </div>
                
                <div class="metric-block">
                    <div class="metric-icon success">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="metric-value">${not empty overallProgress ? overallProgress : 0}%</div>
                    <p class="metric-label">Overall Progress</p>
                </div>
            </c:if>
        </div>

        <!-- B. My Courses (Core Section) -->
        <c:if test="${sessionScope.userRole == 'Student'}">
            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">My Courses</h2>
                    <a href="${pageContext.request.contextPath}/student/courses" class="section-action">View All →</a>
                </div>
                <div class="section-body">
                    <c:choose>
                        <c:when test="${not empty enrolledCourses}">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Course Code</th>
                                        <th>Course Title</th>
                                        <th>Instructor</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="course" items="${enrolledCourses}" varStatus="status">
                                        <c:if test="${status.index < 5}">
                                            <tr>
                                                <td>${course.courseId}</td>
                                                <td>${course.courseName}</td>
                                                <td>${course.instructorName}</td>
                                                <td>${course.completionStatus}</td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/student/course/${course.courseId}" class="btn-action">View Course</a>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-book"></i>
                                <p>No enrolled courses yet. Browse available courses to get started.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- C. Upcoming Tasks (High Priority) -->
            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Upcoming Tasks</h2>
                </div>
                <div class="section-body">
                    <c:choose>
                        <c:when test="${not empty upcomingTasks}">
                            <ul class="task-list">
                                <c:forEach var="task" items="${upcomingTasks}" varStatus="status">
                                    <c:if test="${status.index < 4}">
                                        <li class="task-item">
                                            <div class="task-info">
                                                <h3 class="task-title">${task.title}</h3>
                                                <div class="task-meta">
                                                    <strong>${task.courseName}</strong> • Due: ${task.dueDate}
                                                </div>
                                            </div>
                                            <span class="task-urgency ${task.priority}">${task.priorityLabel}</span>
                                        </li>
                                    </c:if>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-clipboard-check"></i>
                                <p>No pending tasks at the moment.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- D. Announcements -->
            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Announcements</h2>
                </div>
                <div class="section-body">
                    <c:choose>
                        <c:when test="${not empty announcements}">
                            <ul class="announcement-list">
                                <c:forEach var="announcement" items="${announcements}" varStatus="status">
                                    <c:if test="${status.index < 3}">
                                        <li class="announcement-item">
                                            <h3 class="announcement-title">${announcement.title}</h3>
                                            <p class="announcement-body">${announcement.content}</p>
                                            <div class="announcement-meta">
                                                Posted by <strong>${announcement.authorName}</strong> • ${announcement.postedDate}
                                            </div>
                                        </li>
                                    </c:if>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-bullhorn"></i>
                                <p>No announcements at this time.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>
    </main>
</body>
</html>
