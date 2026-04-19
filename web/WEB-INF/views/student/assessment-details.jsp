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
            <a href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}">Assessments</a>
            <span>/</span>
            <span>Details</span>
        </div>

        <section class="sa-shell">
            <article class="sa-hero">
                <div class="sa-hero-top">
                    <div>
                        <h2>${assessment.title}</h2>
                        <p>${fn:trim(displayInstructions)}</p>
                    </div>
                    <div class="sa-badges">
                        <span class="sa-chip"><i class="fas fa-clock"></i> ${assessment.duration != null ? assessment.duration : '--'}${assessment.duration != null ? ' min' : ''}</span>
                        <span class="sa-chip"><i class="fas fa-layer-group"></i> ${assessment.totalMarks != null ? assessment.totalMarks : '--'} marks</span>
                        <span class="sa-chip"><i class="fas fa-repeat"></i> ${remainingAttempts} attempt(s) left</span>
                    </div>
                </div>
            </article>

            <section class="sa-detail-grid">
                <article class="sa-panel">
                    <div class="sa-panel-head">
                        <div>
                            <h3>Assessment overview</h3>
                            <p>Everything you need before you start the timer.</p>
                        </div>
                        <span class="sa-status sa-status-${fn:toLowerCase(assessmentSummary.statusLabel)}">${assessmentSummary.statusLabel}</span>
                    </div>

                    <div class="sa-detail-list">
                        <div class="sa-detail-item">
                            <span>Instructions</span>
                            <p><c:choose><c:when test="${not empty displayInstructions}">${displayInstructions}</c:when><c:otherwise>No instructions provided.</c:otherwise></c:choose></p>
                        </div>
                        <div class="sa-detail-item">
                            <span>Deadline</span>
                            <strong>${assessmentSummary.dueDateLabel}</strong>
                        </div>
                        <div class="sa-detail-item">
                            <span>Attempts</span>
                            <strong>${usedAttempts} used of ${allowedAttempts} allowed</strong>
                        </div>
                        <div class="sa-detail-item">
                            <span>Question count</span>
                            <strong>${assessmentSummary.questionCount}</strong>
                        </div>
                        <div class="sa-detail-item">
                            <span>Submission mode</span>
                            <strong>${objectiveAssessment ? 'MCQ / objective' : (submissionMode == 'file' ? 'File upload' : (submissionMode == 'text' ? 'Short text response' : 'Text + file'))}</strong>
                        </div>
                    </div>
                </article>

                <article class="sa-panel">
                    <div class="sa-panel-head">
                        <div>
                            <h3>What happens next</h3>
                            <p>
                                <c:choose>
                                    <c:when test="${objectiveAssessment}">Start when you are ready. The timer begins immediately for timed assessments.</c:when>
                                    <c:otherwise>Submit your response when ready. Your submission will be queued for instructor review.</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>

                    <div class="sa-detail-list">
                        <c:if test="${objectiveAssessment}">
                            <div class="sa-note warning">
                                Once started, the timer will run until you submit or time expires.
                            </div>
                        </c:if>

                        <div class="sa-detail-item">
                            <span>Course</span>
                            <strong>${enrollment.courseName}</strong>
                        </div>
                        <div class="sa-detail-item">
                            <span>Type</span>
                            <strong>${assessment.type}</strong>
                        </div>
                        <div class="sa-detail-item">
                            <span>Latest status</span>
                            <strong>${assessmentSummary.latestSubmission != null ? assessmentSummary.latestSubmission.status : 'Not started'}</strong>
                        </div>
                    </div>

                    <div class="sa-footer-actions" style="margin-top: 18px;">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-arrow-left"></i> Back</a>
                        <c:choose>
                            <c:when test="${canAttempt}">
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=take&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&mode=attempt">
                                    <i class="fas fa-play"></i> Start Assessment
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
