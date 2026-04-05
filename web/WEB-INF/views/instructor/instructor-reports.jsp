<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports | Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/report-module.css" />
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
            <h1 class="page-title">Instructor Reports</h1>
            <p>Performance insights across your own courses</p>
        </div>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/profile" class="user-menu user-menu-link">
            <div class="user-info">
                <span class="user-name"><c:out value="${empty user ? sessionScope.user.fullName : user.fullName}"/></span>
                <span class="user-role">Instructor</span>
            </div>
            <div class="user-avatar"><i class="fas fa-user"></i></div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i>
            Logout
        </a>
    </div>
</header>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item"><i class="fas fa-home"></i><span>Dashboard</span></a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item"><i class="fas fa-book"></i><span>Courses</span></a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item"><i class="fas fa-folder-open"></i><span>Materials</span></a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item"><i class="fas fa-clipboard-list"></i><span>Assessments</span></a>
        <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item"><i class="fas fa-certificate"></i><span>Certificates</span></a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-item active"><i class="fas fa-chart-column"></i><span>Reports</span></a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item"><i class="fas fa-user"></i><span>Profile / Settings</span></a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper report-shell">
        <c:if test="${not empty error}">
            <div class="alert alert-error"><span>${error}</span></div>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Instructor Snapshot</h2>
                <span class="report-badge">Instructor Scope</span>
            </div>
            <div class="report-grid">
                <article class="report-card"><p>Total Courses</p><strong><c:out value="${reportSummary['totalCourses'] != null ? reportSummary['totalCourses'] : 0}"/></strong></article>
                <article class="report-card"><p>Total Enrollments</p><strong><c:out value="${reportSummary['totalEnrollments'] != null ? reportSummary['totalEnrollments'] : 0}"/></strong></article>
                <article class="report-card"><p>Completed Enrollments</p><strong><c:out value="${reportSummary['completedEnrollments'] != null ? reportSummary['completedEnrollments'] : 0}"/></strong></article>
                <article class="report-card"><p>Average Progress</p><strong><c:out value="${reportSummary['avgProgress'] != null ? reportSummary['avgProgress'] : 0}"/>%</strong></article>
                <article class="report-card"><p>Revenue (Own Courses)</p><strong>NGN <fmt:formatNumber value="${reportSummary['totalRevenue'] != null ? reportSummary['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></strong></article>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Course Performance</h2>
            </div>
            <div class="table-wrapper">
                <table class="report-table">
                    <thead>
                    <tr>
                        <th>Course</th>
                        <th>Enrollments</th>
                        <th>Completions</th>
                        <th>Avg Progress</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="row" items="${courseRows}">
                        <tr>
                            <td><c:out value="${row['title']}"/></td>
                            <td><c:out value="${row['enrollments']}"/></td>
                            <td><c:out value="${row['completions']}"/></td>
                            <td><c:out value="${row['avgProgress']}"/>%</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
            <p class="report-hint">Only your owned courses are included in this report view.</p>
        </section>
    </div>
</main>
</body>
</html>
