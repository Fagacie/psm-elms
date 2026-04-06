<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports | Student</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-dashboard-v3.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/report-module.css" />
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="My Reports"/>
<c:set var="topbarSubtitle" value="Personal learning analytics"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="reports"/>
    <c:set var="showReports" value="true"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

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
