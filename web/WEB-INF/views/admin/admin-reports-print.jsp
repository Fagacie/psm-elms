<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin Report Print View</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; color: #111827; }
        h1, h2 { margin: 0 0 12px; }
        .meta { margin-bottom: 18px; color: #6b7280; font-size: 12px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 18px; }
        th, td { border: 1px solid #e5e7eb; padding: 8px; font-size: 12px; text-align: left; }
        th { background: #f9fafb; }
        .section { margin-top: 22px; }
        @media print { .print-actions { display: none; } }
    </style>
</head>
<body>
<div class="print-actions" style="margin-bottom:16px;">
    <button onclick="window.print()">Print / Save as PDF</button>
</div>

<h1>PSME Admin Report</h1>
<div class="meta">
    Range: <c:out value="${selectedStartDate}"/> to <c:out value="${selectedEndDate}"/>
</div>

<div class="section">
    <h2>Snapshot</h2>
    <table>
        <tbody>
        <tr><th>Total Users</th><td><c:out value="${reportSummary['totalUsers'] != null ? reportSummary['totalUsers'] : 0}"/></td></tr>
        <tr><th>Total Students</th><td><c:out value="${reportSummary['totalStudents'] != null ? reportSummary['totalStudents'] : 0}"/></td></tr>
        <tr><th>Total Instructors</th><td><c:out value="${reportSummary['totalInstructors'] != null ? reportSummary['totalInstructors'] : 0}"/></td></tr>
        <tr><th>Total Courses</th><td><c:out value="${reportSummary['totalCourses'] != null ? reportSummary['totalCourses'] : 0}"/></td></tr>
        <tr><th>Total Enrollments</th><td><c:out value="${reportSummary['totalEnrollments'] != null ? reportSummary['totalEnrollments'] : 0}"/></td></tr>
        <tr><th>Completed Enrollments</th><td><c:out value="${reportSummary['completedEnrollments'] != null ? reportSummary['completedEnrollments'] : 0}"/></td></tr>
        <tr><th>Total Revenue</th><td>NGN <fmt:formatNumber value="${reportSummary['totalRevenue'] != null ? reportSummary['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></td></tr>
        </tbody>
    </table>
</div>

<div class="section">
    <h2>Top Courses by Enrollment</h2>
    <table>
        <thead>
        <tr>
            <th>Course</th>
            <th>Enrollments</th>
            <th>Completions</th>
            <th>Average Progress</th>
            <th>Completion Rate</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="row" items="${topCourses}">
            <tr>
                <td><c:out value="${row['title']}"/></td>
                <td><c:out value="${row['enrollments']}"/></td>
                <td><c:out value="${row['completions']}"/></td>
                <td><c:out value="${row['avgProgress']}"/>%</td>
                <td><c:out value="${row['completionRate']}"/>%</td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>

<div class="section">
    <h2>Revenue by Course</h2>
    <table>
        <thead>
        <tr>
            <th>Course</th>
            <th>Enrollments</th>
            <th>Revenue</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="row" items="${revenueRows}">
            <tr>
                <td><c:out value="${row['title']}"/></td>
                <td><c:out value="${row['enrollments']}"/></td>
                <td>NGN <fmt:formatNumber value="${row['revenue']}" type="number" minFractionDigits="0" maxFractionDigits="0"/></td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>
</body>
</html>
