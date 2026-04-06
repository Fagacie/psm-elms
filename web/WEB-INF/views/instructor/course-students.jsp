<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Students - ${course.courseName}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-students.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Students"/>
    <jsp:param name="pageSubtitle" value="View learners, status, and participation for the course"/>
</jsp:include>

<c:set var="activeInstructorPage" value="courses"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Students</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Course Roster</p>
                <h2>Monitor who is enrolled and where learner progress stands</h2>
                <p>This roster page now matches the instructor workspace, making it easier to review active learners, enrollment dates, and course completion status without leaving the course flow.</p>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Courses
                </a>
            </div>
        </section>

        <section class="ins-hero-card students-hero">
            <div class="ins-hero-grid">
                <div>
                    <h3>${course.courseName}</h3>
                    <p>Use this page to understand who is inside the course right now, which learners are still active, and who has already completed the learning journey.</p>
                </div>
                <div class="ins-hero-metrics">
                    <div class="ins-metric">
                        <strong>${studentCount}</strong>
                        <span>Total enrolled students</span>
                    </div>
                    <div class="ins-metric">
                        <strong><c:out value="${course.category}" default="General"/></strong>
                        <span>Course category</span>
                    </div>
                    <div class="ins-metric">
                        <strong><c:out value="${course.level}" default="Standard"/></strong>
                        <span>Course level</span>
                    </div>
                    <div class="ins-metric">
                        <strong><c:out value="${course.displayDuration}" default="-"/></strong>
                        <span>Course duration</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="course-context-grid" aria-label="Course context summary">
            <div class="context-card">
                <span class="context-label">Category</span>
                <strong>${course.category}</strong>
            </div>
            <div class="context-card">
                <span class="context-label">Level</span>
                <strong>${course.level}</strong>
            </div>
            <div class="context-card">
                <span class="context-label">Duration</span>
                <strong>${course.displayDuration}</strong>
            </div>
            <div class="context-card">
                <span class="context-label">Roster Size</span>
                <strong>${studentCount} student<c:if test="${studentCount != 1}">s</c:if></strong>
            </div>
        </section>

        <section class="section-card students-section">
            <div class="section-header">
                <div>
                    <h3 class="section-title">Enrolled Students</h3>
                    <p class="section-caption">Review active course members and the enrollment state attached to each learner.</p>
                </div>
                <div class="student-count-badge">${studentCount} Students</div>
            </div>

            <c:choose>
                <c:when test="${not empty enrollments && enrollments.size() > 0}">
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Student</th>
                                    <th>Email Address</th>
                                    <th>Enrollment Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="enrollment" items="${enrollments}" varStatus="status">
                                    <tr>
                                        <td class="student-index">${status.count}</td>
                                        <td>
                                            <div class="student-name">${enrollment.studentName}</div>
                                        </td>
                                        <td class="student-email">${enrollment.studentEmail}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty enrollment.enrollmentDate}">
                                                    ${enrollment.enrollmentDate}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="table-muted">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${enrollment.status == 'Pending'}">
                                                    <span class="status-badge status-pending">Pending</span>
                                                </c:when>
                                                <c:when test="${enrollment.status == 'Active'}">
                                                    <span class="status-badge status-active">Active</span>
                                                </c:when>
                                                <c:when test="${enrollment.status == 'Completed'}">
                                                    <span class="status-badge status-completed">Completed</span>
                                                </c:when>
                                                <c:when test="${enrollment.status == 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">Cancelled</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-pending">${enrollment.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state-box">
                        <i class="fas fa-user-slash"></i>
                        <p>No students are enrolled in this course yet.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>
</body>
</html>

