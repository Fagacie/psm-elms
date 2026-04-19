<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessments - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-module.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Assessment Dashboard"/>
<c:set var="topbarSubtitle" value="Track what is available, in progress, and ready for review"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="course"/>
<c:set var="navContextPage" value="assessments"/>
<c:set var="navCourseEnrollmentId" value="${enrollment.enrollmentId}"/>
<c:set var="navCourseTitle" value="${enrollment.courseName}"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>Assessments</span>
        </div>

        <section class="sa-shell">
            <article class="sa-hero">
                <div class="sa-hero-top">
                    <div>
                        <h2>${enrollment.courseName}</h2>
                        <p>${enrollment.courseDescription}</p>
                    </div>
                    <div class="sa-badges">
                        <span class="sa-chip"><i class="fas fa-clipboard-list"></i> ${assessmentSummaries.size()} assessments</span>
                        <span class="sa-chip"><i class="fas fa-credit-card"></i> ${paidAccess ? 'Paid access' : 'Payment required'}</span>
                    </div>
                </div>
            </article>

            <section class="sa-summary-grid">
                <article class="sa-summary-card">
                    <span>Upcoming Assessments</span>
                    <strong>${upcomingCount}</strong>
                </article>
                <article class="sa-summary-card">
                    <span>Pending Review</span>
                    <strong>${pendingReviewCount}</strong>
                </article>
                <article class="sa-summary-card">
                    <span>Completed</span>
                    <strong>${completedCount}</strong>
                </article>
                <article class="sa-summary-card">
                    <span>Average Score</span>
                    <strong><c:choose><c:when test="${not empty averageScore}"><fmt:formatNumber value="${averageScore}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                </article>
            </section>

            <article class="sa-panel">
                <div class="sa-panel-head">
                    <div>
                        <h3>Assessment list</h3>
                        <p>View what is available, continue open attempts, or open details before you start.</p>
                    </div>
                    <div class="sa-search-row">
                        <input id="assSearch" type="search" placeholder="Search by title or course" autocomplete="off">
                        <select id="assStatusFilter" aria-label="Filter by status">
                            <option value="all">All statuses</option>
                            <option value="Available">Available</option>
                            <option value="In Progress">In Progress</option>
                            <option value="Awaiting Review">Awaiting Review</option>
                            <option value="Graded">Graded</option>
                            <option value="Closed">Closed</option>
                        </select>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty assessmentSummaries}">
                        <div class="sa-empty">
                            <h3>No assessments yet</h3>
                            <p>There are no published assessments in this course.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="sa-table-wrap">
                            <table class="sa-table" id="assessmentDashboardTable">
                                <thead>
                                    <tr>
                                        <th>Assessment</th>
                                        <th>Course</th>
                                        <th>Type</th>
                                        <th>Due Date</th>
                                        <th>Duration</th>
                                        <th>Total Marks</th>
                                        <th>Attempts Left</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="item" items="${assessmentSummaries}">
                                    <tr data-search="${fn:toLowerCase(item.assessmentTitle)} ${fn:toLowerCase(item.courseName)}" data-status="${item.statusLabel}">
                                        <td data-label="Assessment">
                                            <strong>${item.assessmentTitle}</strong>
                                            <div class="sa-subtle">${item.questionCount} question(s)</div>
                                        </td>
                                        <td data-label="Course">${item.courseName}</td>
                                        <td data-label="Type"><span class="sa-chip">${item.assessmentType}</span></td>
                                        <td data-label="Due Date">${item.dueDateLabel}</td>
                                        <td data-label="Duration">${item.assessment.duration != null ? item.assessment.duration : '--'}${item.assessment.duration != null ? ' min' : ''}</td>
                                        <td data-label="Total Marks">${item.assessment.totalMarks != null ? item.assessment.totalMarks : '--'}</td>
                                        <td data-label="Attempts Left">
                                            ${item.attemptsRemaining}
                                            <c:if test="${item.attemptsRemaining <= 0 and not item.activeAttempt}">
                                                <div class="sa-subtle">No attempts left</div>
                                            </c:if>
                                        </td>
                                        <td data-label="Status"><span class="sa-status sa-status-${fn:toLowerCase(fn:replace(item.statusLabel, ' ', ''))}">${item.statusLabel}</span></td>
                                        <td data-label="Action">
                                            <c:choose>
                                                <c:when test="${item.activeAttempt}">
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=take&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}&mode=attempt">
                                                        <i class="fas fa-play"></i> Continue
                                                    </a>
                                                </c:when>
                                                <c:when test="${item.attemptsRemaining > 0 and paidAccess}">
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=details&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}">
                                                        <i class="fas fa-eye"></i> Start
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=details&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}">
                                                        <i class="fas fa-eye"></i> View
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty item.latestSubmission}">
                                                <a class="sa-subtle ass-inline-link" href="${pageContext.request.contextPath}/student/assessments?view=result&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}&submissionId=${item.latestSubmission.submissionId}">Latest result</a>
                                            </c:if>
                                            <c:if test="${item.attemptsRemaining <= 0 and not empty item.latestSubmission}">
                                                <a class="sa-subtle ass-inline-link" href="${pageContext.request.contextPath}/student/assessments?view=history&enrollmentId=${enrollment.enrollmentId}">View full history</a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </article>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script>
(function () {
    const search = document.getElementById('assSearch');
    const statusFilter = document.getElementById('assStatusFilter');
    const rows = Array.from(document.querySelectorAll('#assessmentDashboardTable tbody tr'));

    function applyFilters() {
        const term = (search && search.value ? search.value : '').trim().toLowerCase();
        const status = statusFilter ? statusFilter.value : 'all';
        rows.forEach(function (row) {
            const haystack = (row.dataset.search || '').toLowerCase();
            const rowStatus = row.dataset.status || '';
            const matchTerm = !term || haystack.indexOf(term) !== -1;
            const matchStatus = status === 'all' || rowStatus === status;
            row.style.display = matchTerm && matchStatus ? '' : 'none';
        });
    }

    if (search) search.addEventListener('input', applyFilters);
    if (statusFilter) statusFilter.addEventListener('change', applyFilters);
})();
</script>
</body>
</html>
