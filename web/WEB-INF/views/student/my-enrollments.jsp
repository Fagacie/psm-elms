<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollments.css">
</head>
<body>
<nav class="top-navbar">
    <div class="top-navbar-inner">
        <div class="top-navbar-left">
            <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                <span class="logo-text">PSM</span>
                <span class="logo-subtext">E-Learning</span>
            </a>
            <h1 class="page-title-nav">My Courses</h1>
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

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item active">
            <i class="fas fa-graduation-cap"></i><span>My Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/courses" class="nav-item">
            <i class="fas fa-book"></i><span>Browse Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/materials" class="nav-item">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="nav-item">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="nav-item">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="page-header">
            <div>
                <h2>My Courses</h2>
                <p class="text-muted">Manage and continue your enrolled courses</p>
            </div>
            <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                <i class="fas fa-search"></i> Browse Courses
            </a>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon primary"><i class="fas fa-book-open"></i></div>
                <div class="stat-content">
                    <h3>${fn:length(enrollments)}</h3>
                    <p>Total Enrolled</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon warning"><i class="fas fa-clock"></i></div>
                <div class="stat-content">
                    <h3>${inProgressCount}</h3>
                    <p>In Progress</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon success"><i class="fas fa-check-circle"></i></div>
                <div class="stat-content">
                    <h3>${completedCount}</h3>
                    <p>Completed</p>
                </div>
            </div>
        </div>

        <div class="enrollments-table">
            <div class="table-header table-header-flex">
                <h3>Course List</h3>
                <select id="courseStatusFilter" class="course-filter">
                    <option value="all">All Courses</option>
                    <option value="in-progress">In Progress</option>
                    <option value="completed">Completed</option>
                    <option value="pending">Pending Payment</option>
                </select>
            </div>

            <c:if test="${empty enrollments}">
                <div class="empty-state">
                    <i class="fas fa-graduation-cap"></i>
                    <h3>No Courses Yet</h3>
                    <p>Start your learning journey by enrolling in your first course.</p>
                    <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                        <i class="fas fa-search"></i> Browse Courses
                    </a>
                </div>
            </c:if>

            <c:if test="${not empty enrollments}">
                <table>
                    <thead>
                    <tr>
                        <th>Course Name</th>
                        <th>Instructor</th>
                        <th>Progress</th>
                        <th>Resources</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="enrollment" items="${enrollments}">
                        <c:set var="progress" value="${enrollment.completionStatus == 'Completed' ? 100 : (enrollment.completionStatus == 'In Progress' ? 65 : 20)}"/>
                        <c:set var="courseState" value="${enrollment.completionStatus == 'Completed' ? 'completed' : (enrollment.paymentStatus == 'Pending' ? 'pending' : 'in-progress')}"/>
                        <tr data-status="${courseState}">
                            <td>
                                <div class="course-info">
                                    <h4>${enrollment.courseName}</h4>
                                    <p>
                                        Enrolled:
                                        <c:choose>
                                            <c:when test="${not empty enrollment.enrollmentDate}">
                                                ${enrollment.enrollmentDate.toLocalDate()}
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </td>
                            <td>${enrollment.instructorName}</td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-track">
                                        <div class="progress-fill" style="width:${progress}%"></div>
                                    </div>
                                    <small>${progress}%</small>
                                </div>
                            </td>
                            <td>
                                <div>${materialCountByCourse[enrollment.courseId]} materials</div>
                                <small class="text-muted">${assessmentCountByCourse[enrollment.courseId]} assessments</small>
                            </td>
                            <td>
                                <span class="badge ${courseState == 'completed' ? 'badge-success' : (courseState == 'pending' ? 'badge-warning' : 'badge-primary')}">
                                    ${courseState == 'completed' ? 'Completed' : (courseState == 'pending' ? 'Pending Payment' : 'In Progress')}
                                </span>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" class="btn btn-primary btn-sm">
                                        Continue
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>
    </div>
</main>

<script>
    (function () {
        const filter = document.getElementById('courseStatusFilter');
        if (!filter) return;
        filter.addEventListener('change', function () {
            const value = this.value;
            document.querySelectorAll('tbody tr[data-status]').forEach(function (row) {
                row.style.display = (value === 'all' || row.getAttribute('data-status') === value) ? '' : 'none';
            });
        });
    })();
</script>
</body>
</html>
