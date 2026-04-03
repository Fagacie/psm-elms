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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="instructor-ui">
<header class="app-header">
    <div class="header-left">
        <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
            <span class="dashboard-brand-main">PSM</span>
            <span class="dashboard-brand-sub">E-Learning</span>
        </a>
        <div class="dashboard-title-copy">
            <h1 class="page-title">Course Students</h1>
            <p>View learners, status, and participation for the course</p>
        </div>
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
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item active">
            <i class="fas fa-book"></i><span>Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>

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
                        <strong><c:out value="${course.duration}" default="0"/></strong>
                        <span>Duration in hours</span>
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
                <strong>${course.duration} hours</strong>
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

