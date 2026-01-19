<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
            <a href="${pageContext.request.contextPath}/profile" class="nav-item">
                <i class="fas fa-user"></i>
                <span>Profile / Settings</span>
            </a>
        </nav>
    </aside>

    <!-- Main Content Area -->
    <main class="app-main">
        <div class="content-wrapper">
            <!-- Instructor Summary Section (only if backend provides summary) -->
            <c:if test="${not empty summary}">
                <section class="section-card">
                    <h3 class="section-title">Overview</h3>
                    <div class="summary-grid">
                        <c:if test="${not empty summary.totalCourses}">
                            <div class="summary-item">
                                <div class="summary-label">Total Courses</div>
                                <div class="summary-value"><c:out value="${summary.totalCourses}"/></div>
                            </div>
                        </c:if>
                        <c:if test="${not empty summary.totalStudents}">
                            <div class="summary-item">
                                <div class="summary-label">Total Students</div>
                                <div class="summary-value"><c:out value="${summary.totalStudents}"/></div>
                            </div>
                        </c:if>
                        <c:if test="${not empty summary.pendingSubmissions}">
                            <div class="summary-item">
                                <div class="summary-label">Pending Submissions</div>
                                <div class="summary-value"><c:out value="${summary.pendingSubmissions}"/></div>
                            </div>
                        </c:if>
                    </div>
                    <c:if test="${empty summary.totalCourses && empty summary.totalStudents && empty summary.pendingSubmissions}">
                        <p class="muted">No data available.</p>
                    </c:if>
                </section>
            </c:if>

            <div class="grid two-column">
                <!-- My Courses Section -->
                <section class="section-card">
                    <h3 class="section-title">My Courses</h3>
                    <c:choose>
                        <c:when test="${not empty courses}">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Course Code</th>
                                        <th>Course Title</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${courses}">
                                        <tr>
                                            <td><c:out value="${c.courseId}"/></td>
                                            <td><c:out value="${c.courseName}"/></td>
                                            <td><c:out value="${c.status}"/></td>
                                            <td>
                                                <a class="link-action" href="${pageContext.request.contextPath}/instructor/courses?action=edit&id=${c.courseId}">Manage</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">No records found.</div>
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
