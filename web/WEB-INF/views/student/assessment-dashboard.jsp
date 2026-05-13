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
            <article class="sa-hero sv-card" style="border: 1px solid var(--sv-border); border-radius: 16px !important; background: linear-gradient(135deg, var(--sv-surface) 0%, var(--sv-surface-soft) 100%) !important; color: var(--sv-foreground); padding: 24px 28px; box-shadow: var(--sv-shadow-sm) !important; margin-bottom: 4px;">
                <div class="sa-hero-top" style="display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap;">
                    <div style="display: flex; align-items: center; gap: 14px;">
                        <div style="width: 44px; height: 44px; border-radius: 12px; background: var(--sv-accent-soft); display: flex; align-items: center; justify-content: center; color: var(--sv-accent); font-size: 1.3rem;">
                            <i class="fas fa-clipboard-check"></i>
                        </div>
                        <div style="display: flex; flex-direction: column;">
                            <h2 style="font-family: 'Outfit', 'Inter', sans-serif; font-size: 1.5rem; font-weight: 800; margin: 0; color: var(--sv-foreground) !important; letter-spacing: -0.03em;"><c:out value="${enrollment.courseName}"/></h2>
                            <span style="font-size: 0.8rem; color: var(--sv-muted);">Assessments, attempts, and results</span>
                        </div>
                    </div>
                    <div class="sa-badges" style="display: flex; gap: 10px; align-items: center;">
                        <span class="sa-chip" style="background: var(--sv-surface); border: 1px solid var(--sv-border); color: var(--sv-foreground); font-size: 0.72rem; padding: 6px 12px; border-radius: 8px;"><i class="fas fa-clipboard-list" style="color: var(--sv-accent);"></i> ${assessmentSummaries.size()} Assessments</span>
                        <span class="sa-chip" style="background: var(--sv-surface); border: 1px solid var(--sv-border); color: var(--sv-foreground); font-size: 0.72rem; padding: 6px 12px; border-radius: 8px;"><i class="fas fa-lock-open" style="color: #10b981;"></i> ${paidAccess ? 'Paid Access' : 'Payment Required'}</span>
                    </div>
                </div>
            </article>

            <article class="sa-panel sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 24px !important; margin-top: 24px;">
                <div class="sa-panel-head" style="display: flex; justify-content: flex-end; align-items: center; gap: 16px; margin-bottom: 24px;">
                    <div class="sa-search-row" style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                        <div style="position: relative; display: flex; align-items: center;">
                            <i class="fas fa-search" style="position: absolute; left: 14px; color: var(--sv-muted); font-size: 0.9rem;"></i>
                            <input id="assSearch" type="search" placeholder="Search assessments..." autocomplete="off" style="padding-left: 36px; border-radius: 10px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground); height: 40px; font-size: 0.88rem; width: 220px; transition: all 0.2s;">
                        </div>
                        <select id="assStatusFilter" aria-label="Filter by status" style="border-radius: 10px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground); height: 40px; font-size: 0.88rem; padding: 0 14px; cursor: pointer;">
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
                        <div class="sa-empty" style="text-align: center; padding: 48px 24px; border: 1px dashed var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft);">
                            <div style="width: 56px; height: 56px; border-radius: 50%; background: var(--sv-accent-soft); display: inline-flex; align-items: center; justify-content: center; color: var(--sv-accent); font-size: 1.5rem; margin-bottom: 14px;"><i class="fas fa-folder-open"></i></div>
                            <h3 style="margin: 0 0 6px; font-size: 1.1rem; font-weight: 700; color: var(--sv-foreground);">No assessments published</h3>
                            <p style="margin: 0; font-size: 0.88rem; color: var(--sv-muted);">There are no active assessments assigned to this course syllabus yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display: flex; flex-direction: column; gap: 14px;" id="assessmentListContainer">
                            <c:forEach var="item" items="${assessmentSummaries}">
                                <div class="sa-row-card" data-search="${fn:toLowerCase(item.assessmentTitle)} ${fn:toLowerCase(item.courseName)}" data-status="${item.statusLabel}" style="display: flex; align-items: center; justify-content: space-between; gap: 20px; padding: 18px 0; border-bottom: 1px solid var(--sv-border); transition: all 0.25s ease; position: relative; overflow: hidden;">
                                    <div style="display: flex; align-items: center; gap: 16px; flex: 1; min-width: 0;">
                                        <div style="width: 44px; height: 44px; border-radius: 10px; background: var(--sv-surface-soft); border: 1px solid var(--sv-border); display: flex; align-items: center; justify-content: center; color: var(--sv-accent); font-size: 1.15rem; flex-shrink: 0;">
                                            <c:choose>
                                                <c:when test="${item.assessmentType == 'Quiz'}"><i class="fas fa-question-circle" style="color: #3b82f6;"></i></c:when>
                                                <c:otherwise><i class="fas fa-file-alt" style="color: #8b5cf6;"></i></c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div style="display: flex; flex-direction: column; gap: 4px; min-width: 0;">
                                            <strong style="font-size: 1.02rem; font-weight: 700; color: var(--sv-foreground); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block;"><c:out value="${item.assessmentTitle}"/></strong>
                                            <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap; font-size: 0.82rem; color: var(--sv-muted);">
                                                <span style="display: inline-flex; align-items: center; gap: 4px;"><i class="far fa-clock"></i> ${item.assessment.duration != null ? item.assessment.duration : '--'} min</span>
                                                <span style="display: inline-flex; align-items: center; gap: 4px;"><i class="far fa-user"></i> Attempts Left: <strong>${item.attemptsRemaining}</strong></span>
                                                <span style="font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600; color: var(--sv-muted);">${item.assessmentType}</span>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div style="display: flex; align-items: center; gap: 14px; flex-shrink: 0; flex-wrap: wrap;">
                                        <span class="sa-status sa-status-${fn:toLowerCase(fn:replace(item.statusLabel, ' ', ''))}" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">${item.statusLabel}</span>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <c:choose>
                                                <c:when test="${item.activeAttempt}">
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/courses/${enrollment.courseId}/assessments/${item.assessment.assessmentId}/attempt" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem;">
                                                        <i class="fas fa-play"></i> Continue
                                                    </a>
                                                </c:when>
                                                <c:when test="${item.attemptsRemaining > 0 and paidAccess}">
                                                    <a class="sv-btn primary" href="${item.assessment.type == 'Assignment' ? pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrollment.enrollmentId).concat('&tab=assessments&assessmentId=').concat(item.assessment.assessmentId) : pageContext.request.contextPath.concat('/courses/').concat(enrollment.courseId).concat('/assessments/').concat(item.assessment.assessmentId).concat('/attempt')}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem;">
                                                        <i class="fas fa-play"></i> Start
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="sv-btn" href="${item.assessment.type == 'Assignment' ? pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrollment.enrollmentId).concat('&tab=assessments&assessmentId=').concat(item.assessment.assessmentId) : pageContext.request.contextPath.concat('/courses/').concat(enrollment.courseId).concat('/assessments/').concat(item.assessment.assessmentId).concat('/attempt')}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; border: 1px solid var(--sv-border);">
                                                        <i class="fas fa-eye"></i> View
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty item.latestSubmission}">
                                                <a class="sv-btn" style="height: 36px; padding: 0 14px; border-radius: 8px; font-size: 0.85rem; background: rgba(59, 130, 246, 0.08); color: #3b82f6; border: 1px solid rgba(59, 130, 246, 0.15);" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${item.assessment.assessmentId}&submissionId=${item.latestSubmission.submissionId}">Result</a>
                                            </c:if>
                                            <c:if test="${item.attemptsRemaining <= 0 and not empty item.latestSubmission}">
                                                <a class="sv-btn" style="height: 36px; padding: 0 14px; border-radius: 8px; font-size: 0.85rem; background: rgba(100, 116, 139, 0.08); color: #64748b; border: 1px solid rgba(100, 116, 139, 0.15);" href="${pageContext.request.contextPath}/student/assessments?view=history&enrollmentId=${enrollment.enrollmentId}">History</a>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
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
    const rows = Array.from(document.querySelectorAll('.sa-row-card'));

    function applyFilters() {
        const term = (search && search.value ? search.value : '').trim().toLowerCase();
        const status = statusFilter ? statusFilter.value : 'all';
        rows.forEach(function (row) {
            const haystack = (row.dataset.search || '').toLowerCase();
            const rowStatus = row.dataset.status || '';
            const matchTerm = !term || haystack.indexOf(term) !== -1;
            const matchStatus = status === 'all' || rowStatus === status;
            row.style.display = matchTerm && matchStatus ? 'flex' : 'none';
        });
    }

    if (search) search.addEventListener('input', applyFilters);
    if (statusFilter) statusFilter.addEventListener('change', applyFilters);
})();
</script>

</body>
</html>
