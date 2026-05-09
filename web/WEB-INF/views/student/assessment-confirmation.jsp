<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submission Confirmed - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-module.css">
    <script>
        if (window.self !== window.top) {
            document.documentElement.classList.add('sv-page-embedded');
            document.addEventListener('DOMContentLoaded', function() {
                document.body.classList.add('sv-page-embedded');
            });
        }
    </script>
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Submission Confirmation"/>
<c:set var="topbarSubtitle" value="Your work has been saved successfully"/>
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
            <span>Confirmation</span>
        </div>

        <section class="sa-shell">
            <article class="sa-confirm-card sa-panel">
                <div class="sa-panel-head" style="border-bottom: 2px dashed var(--sa-border); padding-bottom: 18px; margin-bottom: 24px;">
                    <div>
                        <span class="sa-chip" style="background: var(--sa-primary); color: #ffffff; border: none; font-size: 0.72rem; padding: 4px 10px; margin-bottom: 8px;">Official Academic Record</span>
                        <h3>Submission Receipt</h3>
                        <p>Your work has been safely recorded by the institution</p>
                    </div>
                    <span class="sa-status ${statusClass}">${submissionStatusLabel}</span>
                </div>

                <div class="sa-result-score" style="margin-bottom: 20px;">
                    <div class="sa-score-card">
                        <span>Assessment</span>
                        <strong>${assessment.title}</strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Submitted at</span>
                        <strong>${fn:replace(submission.submitDate, 'T', ' ')}</strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Attempt</span>
                        <strong>#${submission.attemptNumber}</strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Score</span>
                        <strong><c:choose><c:when test="${not empty submission.score}">${submission.score}</c:when><c:otherwise>Awaiting Grading</c:otherwise></c:choose></strong>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; align-items: start; margin-bottom: 24px;">
                    <div class="sa-note ${not empty submission.score ? 'success' : 'warning'}" style="margin: 0; min-height: 80px; display: flex; align-items: center;">
                        <c:choose>
                            <c:when test="${not empty submission.score}">
                                <div><strong>Grading status:</strong> Your submission has been evaluated and graded automatically by the learning engine.</div>
                            </c:when>
                            <c:otherwise>
                                <div><strong>Review queued:</strong> Your submission is pending and has been queued for manual inspection by the course registrar/instructor.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="sa-detail-item" style="border: 1px dashed var(--sa-border); background: var(--sa-surface-soft); padding: 14px 18px;">
                        <span>Receipt ID</span>
                        <strong style="font-family: monospace; font-size: 0.95rem; letter-spacing: 0.05em; color: var(--sa-heading);">SUB-REC-${submission.submissionId != null ? submission.submissionId : '8839'}-${fn:substring(submission.submitDate, 11, 16)}</strong>
                    </div>
                </div>

                <div class="sa-footer-actions" style="margin-top: 24px; border-top: 1px solid var(--sa-border); padding-top: 18px;">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                    <button class="sv-btn" onclick="window.print()"><i class="fas fa-print"></i> Print Record</button>
                    <c:choose>
                        <c:when test="${not empty submission.score}">
                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${assessment.assessmentId}&submissionId=${submission.submissionId}"><i class="fas fa-chart-column"></i> View Results</a>
                        </c:when>
                        <c:otherwise>
                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${assessment.assessmentId}&submissionId=${submission.submissionId}"><i class="fas fa-comment-dots"></i> Open Feedback</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </article>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
