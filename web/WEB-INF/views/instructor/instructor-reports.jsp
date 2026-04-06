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
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Instructor Reports"/>
    <jsp:param name="pageSubtitle" value="Performance insights across your own courses"/>
</jsp:include>

<c:set var="activeInstructorPage" value="reports"/>
<c:set var="showInstructorReports" value="true"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

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
