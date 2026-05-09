<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports | Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/report-module.css" />
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Reports"/>
    <jsp:param name="pageSubtitle" value="Professional reporting workspace for platform-level insights"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper report-shell">
        <c:set var="hasDateFilter" value="${not empty selectedStartDate and not empty selectedEndDate}"/>

        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Reports</span>
            </div>
        </section>

        <section class="section-card report-toolbar-card">
            <div class="section-header">
                <h2>Report Controls</h2>
                <span class="report-badge">Admin Only</span>
            </div>
            <form method="get" action="${pageContext.request.contextPath}/reports" class="report-toolbar">
                <div class="report-filter-field">
                    <label for="startDate">From</label>
                    <input id="startDate" name="startDate" type="date" value="${selectedStartDate}" />
                </div>
                <div class="report-filter-field">
                    <label for="endDate">To</label>
                    <input id="endDate" name="endDate" type="date" value="${selectedEndDate}" />
                </div>
                <div class="report-toolbar-actions">
                    <button type="submit" class="admin-btn">Apply Filter</button>
                    <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/reports">Reset</a>
                    <a class="admin-btn" href="${pageContext.request.contextPath}/reports?startDate=${selectedStartDate}&endDate=${selectedEndDate}&export=csv">Export CSV</a>
                    <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/reports?startDate=${selectedStartDate}&endDate=${selectedEndDate}&export=pdf" target="_blank">Print / PDF</a>
                </div>
                <div class="report-toolbar-presets" aria-label="Quick date filters">
                    <button type="button" class="admin-btn admin-btn-tertiary js-quick-range" data-range="7">Last 7 Days</button>
                    <button type="button" class="admin-btn admin-btn-tertiary js-quick-range" data-range="30">Last 30 Days</button>
                    <button type="button" class="admin-btn admin-btn-tertiary js-quick-range" data-range="90">Last 90 Days</button>
                </div>
            </form>
            <div class="report-filter-summary">
                <c:choose>
                    <c:when test="${hasDateFilter}">
                        <span class="report-chip">Range: <c:out value="${selectedStartDate}"/> to <c:out value="${selectedEndDate}"/></span>
                        <span class="report-chip report-chip-soft">Filtered view enabled</span>
                    </c:when>
                    <c:otherwise>
                        <span class="report-chip report-chip-soft">Showing full history</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <c:if test="${not empty error}">
            <div class="alert alert-error"><span>${error}</span></div>
        </c:if>

        <c:set var="completionRate" value="${reportSummary['filteredEnrollments'] > 0 ? (reportSummary['filteredCompletedEnrollments'] * 100) / reportSummary['filteredEnrollments'] : 0}"/>
        <c:set var="avgRevenuePerEnrollment" value="${reportSummary['filteredEnrollments'] > 0 ? reportSummary['filteredRevenue'] / reportSummary['filteredEnrollments'] : 0}"/>

        <section class="section-card">
            <div class="section-header">
                <h2>Insight Highlights</h2>
            </div>
            <div class="report-grid report-grid-3">
                <article class="report-card">
                    <p>Completion Rate (Filtered)</p>
                    <strong>${completionRate}%</strong>
                    <div class="report-meter"><span class="report-meter-fill" data-rate="${completionRate}"></span></div>
                </article>
                <article class="report-card">
                    <p>Revenue per Enrollment</p>
                    <strong>NGN <fmt:formatNumber value="${avgRevenuePerEnrollment}" type="number" minFractionDigits="0" maxFractionDigits="0"/></strong>
                    <small class="report-mini">Based on filtered revenue and filtered enrollments</small>
                </article>
                <article class="report-card">
                    <p>New Users in Range</p>
                    <strong><c:out value="${reportSummary['newUsersInRange'] != null ? reportSummary['newUsersInRange'] : 0}"/></strong>
                    <small class="report-mini">Accounts created in selected period</small>
                </article>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Platform Snapshot</h2>
                <span class="report-badge">Admin Access</span>
            </div>
            <div class="report-grid">
                <article class="report-card"><p>Total Users</p><strong><c:out value="${reportSummary['totalUsers'] != null ? reportSummary['totalUsers'] : 0}"/></strong></article>
                <article class="report-card"><p>Total Students</p><strong><c:out value="${reportSummary['totalStudents'] != null ? reportSummary['totalStudents'] : 0}"/></strong></article>
                <article class="report-card"><p>Total Instructors</p><strong><c:out value="${reportSummary['totalInstructors'] != null ? reportSummary['totalInstructors'] : 0}"/></strong></article>
                <article class="report-card"><p>Total Courses</p><strong><c:out value="${reportSummary['totalCourses'] != null ? reportSummary['totalCourses'] : 0}"/></strong></article>
                <article class="report-card"><p>Total Enrollments</p><strong><c:out value="${reportSummary['totalEnrollments'] != null ? reportSummary['totalEnrollments'] : 0}"/></strong></article>
                <article class="report-card"><p>Completed Enrollments</p><strong><c:out value="${reportSummary['completedEnrollments'] != null ? reportSummary['completedEnrollments'] : 0}"/></strong></article>
                <article class="report-card"><p>Active Certificates</p><strong><c:out value="${reportSummary['activeCertificates'] != null ? reportSummary['activeCertificates'] : 0}"/></strong></article>
                <article class="report-card"><p>Total Revenue</p><strong>NGN <fmt:formatNumber value="${reportSummary['totalRevenue'] != null ? reportSummary['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></strong></article>
                <article class="report-card"><p>Filtered Enrollments</p><strong><c:out value="${reportSummary['filteredEnrollments'] != null ? reportSummary['filteredEnrollments'] : 0}"/></strong></article>
                <article class="report-card"><p>Filtered Completed</p><strong><c:out value="${reportSummary['filteredCompletedEnrollments'] != null ? reportSummary['filteredCompletedEnrollments'] : 0}"/></strong></article>
                <article class="report-card"><p>Filtered Revenue</p><strong>NGN <fmt:formatNumber value="${reportSummary['filteredRevenue'] != null ? reportSummary['filteredRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></strong></article>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Top Courses by Enrollment</h2>
                <span id="topCoursesCount" class="report-count-pill">0 records</span>
            </div>
            <div class="report-search-wrap">
                <input id="topCoursesSearch" class="report-search" type="text" placeholder="Search course in this table..." />
            </div>
            <div class="table-wrapper">
                <table class="report-table" id="topCoursesTable">
                    <thead>
                    <tr>
                        <th>Course</th>
                        <th>Enrollments</th>
                        <th>Completions</th>
                        <th>Avg Progress</th>
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
                            <td>
                                <span class="report-rate-label"><c:out value="${row['completionRate']}"/>%</span>
                                <span class="report-rate-bar"><span class="report-rate-fill" data-rate="${row['completionRate']}"></span></span>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr id="topCoursesEmpty" class="report-empty-row" hidden>
                        <td colspan="5">No matching courses found for your current search.</td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <p class="report-hint">Use this list to prioritize course quality reviews and intervention planning.</p>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Revenue by Course</h2>
                <span id="revenueCount" class="report-count-pill">0 records</span>
            </div>
            <div class="report-search-wrap">
                <input id="revenueSearch" class="report-search" type="text" placeholder="Search course in this table..." />
            </div>
            <div class="table-wrapper">
                <table class="report-table" id="revenueTable">
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
                    <tr id="revenueEmpty" class="report-empty-row" hidden>
                        <td colspan="3">No matching revenue rows found for your current search.</td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <p class="report-hint">This report uses paid/success/completed payments as recognized revenue.</p>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Recent Exports</h2>
            </div>
            <div class="table-wrapper">
                <table class="report-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Format</th>
                        <th>Filters</th>
                        <th>Created</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="row" items="${recentExports}">
                        <tr>
                            <td><c:out value="${row['exportId']}"/></td>
                            <td><c:out value="${row['reportType']}"/></td>
                            <td><c:out value="${row['exportFormat']}"/></td>
                            <td><c:out value="${row['filtersJson']}"/></td>
                            <td><c:out value="${row['createdAt']}"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</main>

<script>
    (function () {
        function updateCountLabel(label, count) {
            if (!label) {
                return;
            }
            label.textContent = count + (count === 1 ? ' record' : ' records');
        }

        function bindTableSearch(inputId, tableId, countId, emptyRowId) {
            var input = document.getElementById(inputId);
            var table = document.getElementById(tableId);
            var countLabel = document.getElementById(countId);
            var emptyRow = document.getElementById(emptyRowId);
            if (!input || !table || !table.tBodies.length) {
                return;
            }

            function applyFilter() {
                var q = input.value.toLowerCase();
                var rows = table.tBodies[0].rows;
                var visibleCount = 0;
                for (var i = 0; i < rows.length; i++) {
                    if (rows[i].id === emptyRowId) {
                        continue;
                    }
                    var text = rows[i].innerText.toLowerCase();
                    var isMatch = text.indexOf(q) >= 0;
                    rows[i].style.display = isMatch ? '' : 'none';
                    if (isMatch) {
                        visibleCount++;
                    }
                }

                if (emptyRow) {
                    emptyRow.hidden = visibleCount > 0;
                    emptyRow.style.display = visibleCount > 0 ? 'none' : '';
                }

                updateCountLabel(countLabel, visibleCount);
            }

            input.addEventListener('input', function () {
                applyFilter();
            });

            applyFilter();
        }

        bindTableSearch('topCoursesSearch', 'topCoursesTable', 'topCoursesCount', 'topCoursesEmpty');
        bindTableSearch('revenueSearch', 'revenueTable', 'revenueCount', 'revenueEmpty');

        function toIsoDate(d) {
            var month = String(d.getMonth() + 1).padStart(2, '0');
            var day = String(d.getDate()).padStart(2, '0');
            return d.getFullYear() + '-' + month + '-' + day;
        }

        var quickButtons = document.querySelectorAll('.js-quick-range');
        for (var qb = 0; qb < quickButtons.length; qb++) {
            quickButtons[qb].addEventListener('click', function () {
                var days = parseInt(this.getAttribute('data-range'), 10);
                if (isNaN(days) || days < 1) {
                    return;
                }

                var startDateInput = document.getElementById('startDate');
                var endDateInput = document.getElementById('endDate');
                if (!startDateInput || !endDateInput) {
                    return;
                }

                var end = new Date();
                var start = new Date();
                start.setDate(end.getDate() - (days - 1));

                startDateInput.value = toIsoDate(start);
                endDateInput.value = toIsoDate(end);
            });
        }

        var meterFills = document.querySelectorAll('.report-meter-fill, .report-rate-fill');
        for (var i = 0; i < meterFills.length; i++) {
            var raw = meterFills[i].getAttribute('data-rate');
            var value = parseFloat(raw);
            if (isNaN(value)) {
                value = 0;
            }
            if (value < 0) {
                value = 0;
            }
            if (value > 100) {
                value = 100;
            }
            meterFills[i].style.width = value + '%';
        }
    })();
</script>
</body>
</html>
