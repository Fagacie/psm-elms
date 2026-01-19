<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Enrollments - PSM E-Learning</title>
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
    <!-- Top Navigation Bar (Dashboard style) -->
    <nav class="top-navbar">
        <div class="top-navbar-inner">
            <div class="top-navbar-left">
                <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                    <span class="logo-text">PSM</span>
                    <span class="logo-subtext">E-Learning</span>
                </a>
                <h1 class="page-title-nav">My Enrollments</h1>
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
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/courses" class="nav-item">
                <i class="fas fa-book"></i>
                <span>Browse Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item active">
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
    <main class="app-main">
        <div class="content-wrapper">
            <div class="page-header">
                <div>
                    <h2>My Enrolled Courses</h2>
                    <p class="text-muted">Track your active courses and manage your enrollments</p>
                </div>
                <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                    <i class="fas fa-plus"></i>
                    Enroll in Course
                </a>
            </div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon primary">
                        <i class="fas fa-book-open"></i>
                    </div>
                    <div class="stat-content">
                        <h3>${fn:length(enrollments)}</h3>
                        <p>Total Enrollments</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon success">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-content">
                        <c:set var="activeCount" value="0" />
                        <c:forEach var="enrollment" items="${enrollments}">
                            <c:if test="${enrollment.status == 'Active'}">
                                <c:set var="activeCount" value="${activeCount + 1}" />
                            </c:if>
                        </c:forEach>
                        <h3>${activeCount}</h3>
                        <p>Active Courses</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon warning">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-content">
                        <c:set var="pendingCount" value="0" />
                        <c:forEach var="enrollment" items="${enrollments}">
                            <c:if test="${enrollment.paymentStatus == 'Pending'}">
                                <c:set var="pendingCount" value="${pendingCount + 1}" />
                            </c:if>
                        </c:forEach>
                        <h3>${pendingCount}</h3>
                        <p>Pending Payments</p>
                    </div>
                </div>
            </div>
            <div class="enrollments-table">
                <div class="table-header">
                    <h3>Enrollment History</h3>
                </div>
                <c:if test="${empty enrollments}">
                    <div class="empty-state">
                        <i class="fas fa-graduation-cap"></i>
                        <h3>No Enrollments Yet</h3>
                        <p>Start your learning journey by enrolling in your first course</p>
                        <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                            <i class="fas fa-search"></i>
                            Browse Courses
                        </a>
                    </div>
                </c:if>
                <c:if test="${not empty enrollments}">
                    <table>
                        <thead>
                            <tr>
                                <th>Course</th>
                                <th>Instructor</th>
                                <th>Status</th>
                                <th>Payment</th>
                                <th>Enrolled Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="enrollment" items="${enrollments}">
                                <tr>
                                    <td>
                                        <div class="course-info">
                                            <h4>${enrollment.courseName}</h4>
                                            <p>₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></p>
                                        </div>
                                    </td>
                                    <td>${enrollment.instructorName}</td>
                                    <td>
                                        <span class="badge ${enrollment.status == 'Active' ? 'badge-success' : ''} ${enrollment.status == 'Completed' ? 'badge-primary' : ''} ${enrollment.status == 'Pending' ? 'badge-warning' : ''} ${enrollment.status == 'Cancelled' ? 'badge-danger' : ''}">
                                            ${enrollment.status}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge ${enrollment.paymentStatus == 'Paid' ? 'badge-success' : ''} ${enrollment.paymentStatus == 'Pending' ? 'badge-warning' : ''} ${enrollment.paymentStatus == 'Failed' ? 'badge-danger' : ''}">
                                            ${enrollment.paymentStatus}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty enrollment.enrollmentDate}">
                                                ${enrollment.enrollmentDate.toLocalDate()}
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <a href="${pageContext.request.contextPath}/student/course-details?id=${enrollment.courseId}" class="btn btn-secondary btn-sm" title="View Course">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <c:if test="${enrollment.paymentStatus == 'Pending'}">
                                                <form action="${pageContext.request.contextPath}/student/start-payment" method="post" class="inline-form">
                                                    <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}"/>
                                                    <button type="submit" class="btn btn-primary btn-sm">
                                                        <i class="fas fa-credit-card"></i> Pay Now
                                                    </button>
                                                </form>
                                            </c:if>
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
</body>
</html>
