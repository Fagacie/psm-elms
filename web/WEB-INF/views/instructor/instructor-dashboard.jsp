<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructor Dashboard - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-dashboard.css">
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
            <h1 class="page-title">Instructor Dashboard</h1>
        </div>
        <div class="header-right">
            <c:if test="${not empty notificationCount && notificationCount > 0}">
                <div class="notifications" aria-label="Notifications">
                    <i class="fas fa-bell"></i>
                    <span class="badge">${notificationCount}</span>
                </div>
            </c:if>
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
            <a href="${pageContext.request.contextPath}/instructor/dashboard" class="nav-item active">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
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
            <!-- Dashboard Statistics Section -->
            <section class="dashboard-stats">
                <div class="stat-card">
                    <div class="stat-icon courses-icon">
                        <i class="fas fa-book"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-label">Total Courses</div>
                        <div class="stat-value">${not empty totalCourses ? totalCourses : 0}</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon students-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-label">Total Students</div>
                        <div class="stat-value">${not empty totalStudents ? totalStudents : 0}</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon enrollments-icon">
                        <i class="fas fa-clipboard-list"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-label">Total Enrollments</div>
                        <div class="stat-value">${not empty totalEnrollments ? totalEnrollments : 0}</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon pending-icon">
                        <i class="fas fa-hourglass-half"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-label">Pending Enrollments</div>
                        <div class="stat-value">${not empty pendingEnrollments ? pendingEnrollments : 0}</div>
                    </div>
                </div>
            </section>

            <div class="grid two-column">
                <!-- My Courses Section -->
                <section class="section-card courses-section">
                    <div class="section-header">
                        <h3 class="section-title">My Courses</h3>
                        <span class="course-count">${not empty courses ? courses.size() : 0} Courses</span>
                    </div>
                    <c:choose>
                        <c:when test="${not empty courses}">
                            <div class="courses-list">
                                <c:forEach var="c" items="${courses}" varStatus="loop">
                                    <div class="course-item">
                                        <div class="course-item-header">
                                            <div class="course-item-title"><c:out value="${c.courseName}"/></div>
                                            <span class="course-status-badge status-${fn:toLowerCase(c.status)}"><c:out value="${c.status}"/></span>
                                        </div>
                                        <div class="course-item-footer">
                                            <small class="course-category"><c:out value="${c.category}"/></small>
                                            <a class="link-action" href="${pageContext.request.contextPath}/instructor/courses?action=edit&id=${c.courseId}">
                                                <i class="fas fa-pencil-alt"></i> Manage
                                            </a>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-book"></i>
                                <p>No courses created yet.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>

                <!-- Pending Instructor Tasks -->
                <section class="section-card">
                    <h3 class="section-title">Pending Tasks</h3>
                    <c:choose>
                        <c:when test="${not empty pendingTasks}">
                            <ul class="task-list">
                                <c:forEach var="task" items="${pendingTasks}" varStatus="loop">
                                    <li class="task-item">
                                        <div class="task-title"><c:out value="${task.title}"/></div>
                                        <div class="task-meta">
                                            <c:if test="${not empty task.type}"><span class="task-type"><c:out value="${task.type}"/></span></c:if>
                                            <c:if test="${not empty task.dueDate}"><span class="task-date"><c:out value="${task.dueDate}"/></span></c:if>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">No data available.</div>
                        </c:otherwise>
                    </c:choose>
                </section>
            </div>

            <!-- Announcements Preview -->
            <section class="section-card">
                <h3 class="section-title">Announcements</h3>
                <c:choose>
                    <c:when test="${not empty announcements}">
                        <ul class="announcement-list">
                            <c:forEach var="ann" items="${announcements}">
                                <li class="announcement-item">
                                    <div class="announcement-title"><c:out value="${ann.title}"/></div>
                                    <div class="announcement-meta">
                                        <c:if test="${not empty ann.date}"><span class="announcement-date"><c:out value="${ann.date}"/></span></c:if>
                                    </div>
                                    <c:if test="${not empty ann.summary}"><p class="announcement-text"><c:out value="${ann.summary}"/></p></c:if>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">No announcements.</div>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </main>
</body>
</html>
