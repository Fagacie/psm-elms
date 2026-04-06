<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Details - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-details.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body>
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
            <div class="user-menu">
                <div class="user-info">
                    <span class="user-name"><c:out value="${user.fullName}"/></span>
                    <span class="user-role">Student</span>
                </div>
                <div class="user-avatar">
                    <i class="fas fa-user"></i>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/profile" class="btn btn-secondary btn-sm">
                <i class="fas fa-user"></i>
                Profile
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
                <i class="fas fa-sign-out-alt"></i>
                Logout
            </a>
        </div>
    </header>

    <!-- Left Sidebar -->
    <aside class="app-sidebar">
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/courses" class="nav-item">
                <i class="fas fa-book"></i>
                <span>My Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/assignments" class="nav-item">
                <i class="fas fa-tasks"></i>
                <span>Assignments</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/quizzes" class="nav-item">
                <i class="fas fa-clipboard-question"></i>
                <span>Quizzes</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/materials" class="nav-item">
                <i class="fas fa-folder-open"></i>
                <span>Materials</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/grades" class="nav-item">
                <i class="fas fa-chart-line"></i>
                <span>Grades</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/announcements" class="nav-item">
                <i class="fas fa-bullhorn"></i>
                <span>Announcements</span>
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
            <!-- 1. Page Header (Course Title + Code + Term) -->
            <section class="section-card page-header">
                <div class="page-header-top">
                    <h2 class="course-title">
                        <c:out value="${course.courseName}"/>
                    </h2>
                    <div class="course-meta">
                        <span class="meta-item">
                            <span class="meta-label">Code:</span>
                            <span class="meta-value">
                                <c:choose>
                                    <c:when test="${not empty course.courseCode}"><c:out value="${course.courseCode}"/></c:when>
                                    <c:otherwise><c:out value="${course.courseId}"/></c:otherwise>
                                </c:choose>
                            </span>
                        </span>
                        <c:if test="${not empty course.term || not empty course.semester}">
                            <span class="meta-item">
                                <span class="meta-label">Term:</span>
                                <span class="meta-value">
                                    <c:out value="${empty course.term ? course.semester : course.term}"/>
                                </span>
                            </span>
                        </c:if>
                    </div>
                </div>
                <p class="course-subtext">Review high-level course information, expectations, and navigate to assessments.</p>
            </section>

            <div class="grid two-column">
                <!-- 2. Course Overview -->
                <section class="section-card">
                    <h3 class="section-title">Course Overview</h3>
                    <div class="overview-grid">
                        <div class="overview-block description">
                            <h4 class="block-title">Description</h4>
                            <p class="block-text">
                                <c:out value="${course.courseDescription}"/>
                            </p>
                        </div>
                        <div class="overview-block facts">
                            <div class="fact-row">
                                <span class="fact-label">Instructor</span>
                                <span class="fact-value"><c:out value="${course.instructorName != null ? course.instructorName : instructor.fullName}"/></span>
                            </div>
                            <div class="fact-row">
                                <span class="fact-label">Department</span>
                                <span class="fact-value"><c:out value="${empty course.department ? course.category : course.department}"/></span>
                            </div>
                            <div class="fact-row">
                                <span class="fact-label">Duration</span>
                                <span class="fact-value"><c:out value="${course.displayDuration}"/></span>
                            </div>
                            <div class="fact-row">
                                <span class="fact-label">Status</span>
                                <span class="fact-value">
                                    <c:choose>
                                        <c:when test="${not empty course.status}"><c:out value="${course.status}"/></c:when>
                                        <c:when test="${not empty enrollment.completionStatus}"><c:out value="${enrollment.completionStatus}"/></c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- 3. Key Course Information -->
                <section class="section-card">
                    <h3 class="section-title">Key Course Information</h3>
                    <table class="data-table">
                        <tbody>
                            <tr>
                                <th>Course Code</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty course.courseCode}"><c:out value="${course.courseCode}"/></c:when>
                                        <c:otherwise><c:out value="${course.courseId}"/></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <tr>
                                <th>Course Level</th>
                                <td><c:out value="${course.level}" default="—"/></td>
                            </tr>
                            <tr>
                                <th>Duration</th>
                                <td><c:out value="${course.displayDuration}"/></td>
                            </tr>
                            <tr>
                                <th>Class Schedule</th>
                                <td><c:out value="${course.schedule}" default="—"/></td>
                            </tr>
                            <tr>
                                <th>Enrollment Status</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty enrollment.enrollmentStatus}"><c:out value="${enrollment.enrollmentStatus}"/></c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </section>
            </div>

            <div class="grid two-column">
                <!-- 4. Instructor Information -->
                <section class="section-card">
                    <h3 class="section-title">Instructor</h3>
                    <table class="data-table">
                        <tbody>
                            <tr>
                                <th>Name</th>
                                <td><c:out value="${course.instructorName != null ? course.instructorName : instructor.fullName}"/></td>
                            </tr>
                            <c:if test="${not empty instructor.email || not empty course.instructorEmail}">
                                <tr>
                                    <th>Email</th>
                                    <td><c:out value="${empty instructor.email ? course.instructorEmail : instructor.email}"/></td>
                                </tr>
                            </c:if>
                            <c:if test="${not empty instructor.officeHours}">
                                <tr>
                                    <th>Office Hours</th>
                                    <td><c:out value="${instructor.officeHours}"/></td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </section>

                <!-- 5. Assessment Overview -->
                <section class="section-card">
                    <h3 class="section-title">Assessment Overview</h3>
                    <div class="assessment-grid">
                        <div class="assessment-item">
                            <div class="assessment-label">Total Assignments</div>
                            <div class="assessment-value"><c:out value="${empty assessmentSummary.totalAssignments ? 0 : assessmentSummary.totalAssignments}"/></div>
                        </div>
                        <div class="assessment-item">
                            <div class="assessment-label">Total Quizzes/Exams</div>
                            <div class="assessment-value"><c:out value="${empty assessmentSummary.totalQuizzes ? 0 : assessmentSummary.totalQuizzes}"/></div>
                        </div>
                        <div class="assessment-item">
                            <div class="assessment-label">Assessment Weighting</div>
                            <div class="assessment-value"><c:out value="${assessmentSummary.weighting}" default="—"/></div>
                        </div>
                    </div>
                    <div class="assessment-links">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/student/assignments<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>">
                            <i class="fas fa-tasks"></i>
                            View Assignments
                        </a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/student/quizzes<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>">
                            <i class="fas fa-clipboard-question"></i>
                            View Quizzes
                        </a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/student/grades<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>">
                            <i class="fas fa-chart-line"></i>
                            View Grades
                        </a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/student/announcements<c:if test='${not empty course.courseId}'>?courseId=${course.courseId}</c:if>">
                            <i class="fas fa-bullhorn"></i>
                            View Announcements
                        </a>
                    </div>
                </section>
            </div>

            <!-- 7. System Messages / Notices (Optional) -->
            <c:if test="${not empty courseAnnouncements}">
            <section class="section-card">
                <h3 class="section-title">Recent Notices</h3>
                <ul class="notice-list">
                    <c:forEach var="note" items="${courseAnnouncements}" varStatus="loop">
                        <c:if test="${loop.index < 3}">
                            <li class="notice-item">
                                <div class="notice-title"><c:out value="${note.title}"/></div>
                                <div class="notice-meta">
                                    <span class="notice-date"><c:out value="${note.date}"/></span>
                                </div>
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