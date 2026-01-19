<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Enrollment Summary</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
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
                <h1 class="page-title-nav">Enrollment Summary</h1>
            </div>
            <div class="top-navbar-right">
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
            <div class="page-header">
                <div>
                    <h2>Confirm Enrollment</h2>
                    <p class="text-muted">Review course details before proceeding to payment</p>
                </div>
            </div>

            <c:if test="${empty course}">
                <div class="empty-state">
                    <i class="fas fa-folder-open"></i>
                    <h3>Course details not available</h3>
                    <p>Return to the catalog to pick a course</p>
                    <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary">
                        <i class="fas fa-search"></i>
                        Browse Courses
                    </a>
                </div>
            </c:if>

            <c:if test="${not empty course}">
                <section class="summary-block">
                    <table class="summary-table">
                        <tbody>
                            <tr>
                                <th>Course</th>
                                <td>${course.courseName}</td>
                            </tr>
                            <tr>
                                <th>Description</th>
                                <td>${course.description}</td>
                            </tr>
                            <tr>
                                <th>Fee</th>
                                <td>₦<c:out value="${course.courseFee}"/></td>
                            </tr>
                        </tbody>
                    </table>

                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" class="inline-form">
                        <input type="hidden" name="courseId" value="${course.courseId}" />
                        <div class="actions">
                            <button type="submit" class="btn btn-primary">Proceed to Payment</button>
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/student/courses">Cancel</a>
                        </div>
                    </form>
                </section>
            </c:if>
        </div>
    </main>
</body>
</html>