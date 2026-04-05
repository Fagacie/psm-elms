<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports | Student</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-dashboard-v3.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/report-module.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand">
            <span class="sv-brand-main">PSM</span>
            <span class="sv-brand-sub">E-Learning</span>
        </a>
        <div class="sv-page-title">
            <h1>My Reports</h1>
            <p>Personal learning analytics</p>
        </div>
    </div>
    <div class="sv-top-right">
        <a href="${pageContext.request.contextPath}/profile" class="sd3-user">
            <div class="sd3-avatar"><i class="fas fa-user"></i></div>
            <div class="sd3-user-copy">
                <strong>${sessionScope.userName}</strong>
                <span>Student workspace</span>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a>
    </div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/reports" class="sv-nav-link active"><i class="fas fa-chart-column"></i><span>Reports</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main sd3-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>My Reports</span>
        </div>

        <c:if test="${not empty error}">
            <div class="empty-state-box"><p>${error}</p></div>
        </c:if>

        <section class="sv-card">
            <div class="sv-card-head">
                <h2>Personal Snapshot</h2>
                <span class="report-badge">Student Scope</span>
            </div>
            <div class="sv-card-body">
                <div class="report-grid">
                    <article class="report-card"><p>Total Enrollments</p><strong><c:out value="${reportSummary['totalEnrollments'] != null ? reportSummary['totalEnrollments'] : 0}"/></strong></article>
                    <article class="report-card"><p>Active Enrollments</p><strong><c:out value="${reportSummary['activeEnrollments'] != null ? reportSummary['activeEnrollments'] : 0}"/></strong></article>
                    <article class="report-card"><p>Completed</p><strong><c:out value="${reportSummary['completedEnrollments'] != null ? reportSummary['completedEnrollments'] : 0}"/></strong></article>
                    <article class="report-card"><p>Average Progress</p><strong><c:out value="${reportSummary['avgProgress'] != null ? reportSummary['avgProgress'] : 0}"/>%</strong></article>
                    <article class="report-card"><p>Paid Enrollments</p><strong><c:out value="${reportSummary['paidEnrollments'] != null ? reportSummary['paidEnrollments'] : 0}"/></strong></article>
                    <article class="report-card"><p>Certificates</p><strong><c:out value="${reportSummary['certificates'] != null ? reportSummary['certificates'] : 0}"/></strong></article>
                </div>
            </div>
        </section>

        <section class="sv-card">
            <div class="sv-card-head">
                <h2>Course Progress Detail</h2>
            </div>
            <div class="sv-card-body">
                <div class="table-wrapper">
                    <table class="report-table">
                        <thead>
                        <tr>
                            <th>Course</th>
                            <th>Level</th>
                            <th>Status</th>
                            <th>Completion</th>
                            <th>Progress</th>
                            <th>Payment</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="row" items="${progressRows}">
                            <tr>
                                <td><c:out value="${row['title']}"/></td>
                                <td><c:out value="${row['level']}"/></td>
                                <td><c:out value="${row['status']}"/></td>
                                <td><c:out value="${row['completionStatus']}"/></td>
                                <td><c:out value="${row['progress']}"/>%</td>
                                <td><c:out value="${row['paymentStatus']}"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
