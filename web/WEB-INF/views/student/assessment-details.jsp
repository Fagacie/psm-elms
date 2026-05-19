<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${assessment.title} - Assessment Details</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-module.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Assessment Details"/>
<c:set var="topbarSubtitle" value="Review the requirements before starting"/>
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
            <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">Assessments</a>
            <span>/</span>
            <span>Details</span>
        </div>

        <section class="sa-shell">
            <section class="sa-detail-grid" style="grid-template-columns: 1fr; max-width: 800px;">
                <article class="sa-panel">
                    <div class="sa-panel-head">
                        <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                            <h2 style="margin: 0; font-size: 1.4rem;">${assessment.title}</h2>
                            <span class="sa-status sa-status-${fn:toLowerCase(assessmentSummary.statusLabel)}">${assessmentSummary.statusLabel}</span>
                        </div>
                        <div class="sa-badges" style="display: flex; gap: 8px; margin-top: 12px;">
                            <span class="sa-chip"><i class="fas fa-clock"></i> ${assessment.duration != null ? assessment.duration : '--'}${assessment.duration != null ? ' min' : ''}</span>
                            <span class="sa-chip"><i class="fas fa-layer-group"></i> ${assessment.totalMarks != null ? assessment.totalMarks : '--'} marks</span>
                            <span class="sa-chip"><i class="fas fa-repeat"></i> ${remainingAttempts} attempt(s) left</span>
                        </div>
                    </div>

                    <div class="sa-detail-list" style="margin-top: 16px;">
                        <c:if test="${not empty displayInstructions}">
                            <div class="sa-detail-item">
                                <span>Instructions</span>
                                <p style="margin: 0;">${displayInstructions}</p>
                            </div>
                        </c:if>
                        <c:if test="${not objectiveAssessment and not empty questions}">
                            <div class="sa-detail-item">
                                <span>Assignment prompt</span>
                                <div style="display:grid; gap:10px; margin-top: 6px;">
                                    <c:forEach var="q" items="${questions}" varStatus="loop">
                                        <div class="sa-note warning" style="margin: 0;">
                                            <strong>Item ${loop.index + 1}:</strong> ${q.questionText}
                                            <c:if test="${not empty q.attachmentUrl}">
                                                <div style="margin-top: 8px;">
                                                    <a class="sv-btn" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                                        <i class="fas fa-file-pdf"></i> Open PDF Brief
                                                    </a>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>
                        <div class="sa-detail-item" style="grid-column: span 1;">
                            <span>Attempts</span>
                            <strong>${usedAttempts} used of ${allowedAttempts} allowed</strong>
                        </div>
                        <div class="sa-detail-item" style="grid-column: span 1;">
                            <span>Question count</span>
                            <strong>${assessmentSummary.questionCount}</strong>
                        </div>
                        <div class="sa-detail-item" style="grid-column: span 1;">
                            <span>Submission mode</span>
                            <strong>${objectiveAssessment ? 'MCQ / objective' : (submissionMode == 'file' ? 'File upload' : (submissionMode == 'text' ? 'Short text response' : 'Text + file'))}</strong>
                        </div>
                    </div>

                    <div class="sa-footer-actions" style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--sv-border);">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments"><i class="fas fa-arrow-left"></i> Back</a>
                        <c:choose>
                            <c:when test="${enrollment.daysRemaining < 0 && enrollment.courseDuration != null && enrollment.courseDuration > 0}">
                                <span class="sa-status sa-status-closed" style="background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3);">
                                    <i class="fas fa-calendar-times"></i> Course expired
                                </span>
                            </c:when>
                            <c:when test="${canAttempt}">
                                <a class="sv-btn primary" href="${assessment.type == 'Assignment' ? pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrollment.enrollmentId).concat('&tab=assessments&assessmentId=').concat(assessment.assessmentId) : pageContext.request.contextPath.concat('/courses/').concat(enrollment.courseId).concat('/assessments/').concat(assessment.assessmentId).concat('/attempt')}">
                                    <i class="fas fa-play"></i> ${objectiveAssessment ? 'Start Assessment' : 'Open Submission'}
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="sa-status sa-status-closed">No attempts left</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </article>
            </section>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
