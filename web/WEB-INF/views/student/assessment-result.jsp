<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessment Results - PSM E-Learning</title>
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
<c:set var="topbarTitle" value="Results & Feedback"/>
<c:set var="topbarSubtitle" value="Review your score and instructor feedback"/>
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
            <span>Results</span>
        </div>

        <section class="sa-shell">
            <article class="sa-result-card sa-panel" style="padding: 28px;">
                <div class="sa-panel-head" style="align-items: start; gap: 16px;">
                    <div>
                        <span class="sa-badge-flat ${statusClass}" style="margin-bottom: 10px;"><i class="fas fa-chart-line"></i> Result overview</span>
                        <h3 style="margin: 0; font-size: 1.7rem; letter-spacing: -0.03em;">${assessment.title}</h3>
                        <p style="margin: 8px 0 0; color: var(--sv-muted); line-height: 1.6; max-width: 760px;">
                            <c:choose>
                                <c:when test="${not empty submission.score}">Your result is ready. Review the performance summary, the per-question breakdown, and the next steps below.</c:when>
                                <c:otherwise>Your submission is still under review. The grading summary below shows the current status and submission details.</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <span class="sa-status ${statusClass}" style="white-space: nowrap;">${submissionStatusLabel}</span>
                </div>

                <div style="display: grid; grid-template-columns: minmax(0, 1.25fr) minmax(280px, 0.9fr); gap: 18px; margin-top: 22px;">
                    <div style="border: 1px solid var(--sv-border); border-radius: 18px; padding: 22px; background: linear-gradient(180deg, rgba(59,130,246,0.06), rgba(255,255,255,0));">
                        <div style="display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; align-items: end; margin-bottom: 14px;">
                            <div>
                                <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Performance</span>
                                <strong style="display: block; font-size: 2.2rem; line-height: 1; color: var(--sv-foreground);">
                                    <c:choose><c:when test="${not empty submission.score}"><fmt:formatNumber value="${percentage}" maxFractionDigits="1"/>%</c:when><c:otherwise>--</c:otherwise></c:choose>
                                </strong>
                            </div>
                            <div style="text-align: right;">
                                <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Interpretation</span>
                                <strong style="font-size: 1rem; color: var(--sv-foreground);">
                                    <c:choose>
                                        <c:when test="${empty submission.score}">Awaiting grade</c:when>
                                        <c:when test="${percentage >= 85}">Excellent mastery</c:when>
                                        <c:when test="${percentage >= 70}">Strong performance</c:when>
                                        <c:when test="${percentage >= 50}">Developing performance</c:when>
                                        <c:otherwise>Needs review</c:otherwise>
                                    </c:choose>
                                </strong>
                            </div>
                        </div>

                        <div style="height: 12px; border-radius: 999px; background: rgba(148, 163, 184, 0.22); overflow: hidden; margin-bottom: 10px;">
                            <div style="height: 100%; border-radius: inherit; background: linear-gradient(90deg, #2563eb, #0ea5e9); width: <c:choose><c:when test='${not empty submission.score}'><fmt:formatNumber value="${percentage > 100 ? 100 : (percentage < 0 ? 0 : percentage)}" maxFractionDigits="0"/></c:when><c:otherwise>0</c:otherwise></c:choose>%;"></div>
                        </div>

                        <p style="margin: 0; color: var(--sv-muted); line-height: 1.7;">
                            <c:choose>
                                <c:when test="${empty submission.score}">Your submission is saved and awaiting grading. Check back here for the final score and feedback.</c:when>
                                <c:when test="${percentage >= 85}">You are performing at a very high level. Keep the same revision pattern and move to the next topic once you are confident.</c:when>
                                <c:when test="${percentage >= 70}">You are on solid footing. Review the missed questions, then retake notes on the weak areas before the next attempt.</c:when>
                                <c:when test="${percentage >= 50}">The result shows partial understanding. Focus on the questions listed below and revisit the related lesson content.</c:when>
                                <c:otherwise>This score suggests gaps in key concepts. Use the breakdown below to identify what to revise before attempting again.</c:otherwise>
                            </c:choose>
                        </p>
                    </div>

                    <div style="display: grid; gap: 12px;">
                        <div style="border: 1px solid var(--sv-border); border-radius: 16px; background: var(--sv-surface-soft); padding: 16px;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Score</span>
                            <strong style="font-size: 1.3rem; color: var(--sv-foreground);">
                                <c:choose><c:when test="${not empty submission.score}"><fmt:formatNumber value="${submission.score}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose>
                            </strong>
                        </div>
                        <div style="border: 1px solid var(--sv-border); border-radius: 16px; background: var(--sv-surface-soft); padding: 16px;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Attempt</span>
                            <strong style="font-size: 1.3rem; color: var(--sv-foreground);">#${submission.attemptNumber}</strong>
                        </div>
                        <div style="border: 1px solid var(--sv-border); border-radius: 16px; background: var(--sv-surface-soft); padding: 16px;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Graded date</span>
                            <strong style="font-size: 0.95rem; color: var(--sv-foreground); line-height: 1.5; display: block;">
                                <c:choose>
                                    <c:when test="${not empty submissionAudits and not empty submissionAudits[0].gradedAt}">${fn:replace(submissionAudits[0].gradedAt, 'T', ' ')}</c:when>
                                    <c:when test="${not empty submission.endedAt}">${fn:replace(submission.endedAt, 'T', ' ')}</c:when>
                                    <c:otherwise>--</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>
                        <div style="border: 1px solid var(--sv-border); border-radius: 16px; background: var(--sv-surface-soft); padding: 16px;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Result type</span>
                            <strong style="font-size: 0.95rem; color: var(--sv-foreground); line-height: 1.5; display: block;">
                                <c:choose><c:when test="${objectiveAssessment}">Multiple Choice</c:when><c:otherwise>Assignment</c:otherwise></c:choose>
                            </strong>
                        </div>
                    </div>
                </div>

                <div class="sa-note ${not empty submission.feedback ? 'success' : 'warning'}" style="margin-top: 18px;">
                    <c:choose>
                        <c:when test="${not empty submission.feedback}">
                            <strong>Instructor feedback:</strong> ${submission.feedback}
                        </c:when>
                        <c:when test="${not empty submission.score}">
                            This submission was graded automatically.
                        </c:when>
                        <c:otherwise>
                            The submission is awaiting instructor review.
                        </c:otherwise>
                    </c:choose>
                </div>
            </article>

            <article class="sa-panel" style="margin-top: 18px;">
                <div class="sa-panel-head">
                    <div>
                        <h3>Question breakdown</h3>
                        <p style="margin: 4px 0 0; color: var(--sv-muted); font-size: 0.88rem;">Use this section to review each answer and identify what to revise next.</p>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not objectiveAssessment || empty questions}">
                        <div class="sa-empty">
                            <h3>No breakdown available</h3>
                            <p>This assessment was submitted as a file or the question set is not available for per-question review.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="sa-breakdown" style="display: grid; gap: 12px;">
                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <c:set var="studAns" value="${empty studentAnswerByQuestionId[q.questionId] ? '' : studentAnswerByQuestionId[q.questionId]}" />
                                <c:set var="corrAns" value="${empty correctAnswerByQuestionId[q.questionId] ? '' : correctAnswerByQuestionId[q.questionId]}" />
                                <c:set var="isCorrect" value="${not empty studAns and studAns == corrAns}" />
                                <div class="sa-breakdown-item ${isCorrect ? 'correct' : 'incorrect'}" style="padding: 16px; border: 1px solid var(--sv-border); border-radius: 14px; background: var(--sv-surface-soft);">
                                    <div style="display: flex; justify-content: space-between; gap: 10px; align-items: center; margin-bottom: 10px; flex-wrap: wrap;">
                                        <span class="sa-badge-flat ${isCorrect ? 'success' : 'danger'}" style="margin: 0;">
                                            <i class="fas ${isCorrect ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                                            ${isCorrect ? 'Correct' : 'Incorrect'}
                                        </span>
                                        <span style="color: var(--sv-muted); font-size: 0.8rem;">Question ${loop.index + 1}</span>
                                    </div>
                                    <h4 style="margin: 0 0 10px 0; font-size: 1rem; line-height: 1.5;">${q.questionText}</h4>
                                    <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; font-size: 0.9rem;">
                                        <p style="margin: 0;"><strong>Your answer:</strong> <c:out value="${empty studAns ? '--' : studAns}"/></p>
                                        <p style="margin: 0;"><strong>Correct answer:</strong> <c:out value="${empty corrAns ? '--' : corrAns}"/></p>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </article>

            <article class="sa-panel" style="margin-top: 18px;">
                <div class="sa-panel-head">
                    <div>
                        <h3>Submission details</h3>
                        <p style="margin: 4px 0 0; color: var(--sv-muted); font-size: 0.88rem;">Reference data for your records and instructor follow-up.</p>
                    </div>
                </div>

                <div class="sa-detail-grid">
                    <div class="sa-detail-list">
                        <div class="sa-detail-item">
                            <span>Status</span>
                            <strong>${submissionStatusLabel}</strong>
                        </div>
                        <div class="sa-detail-item">
                            <span>Submitted by</span>
                            <strong>${sessionScope.userName}</strong>
                        </div>
                    </div>
                    <div class="sa-detail-list">
                        <div class="sa-detail-item">
                            <span>Submission payload</span>
                            <p>
                                <c:choose>
                                    <c:when test="${not empty submission.answersFilePath}">${submission.answersFilePath}</c:when>
                                    <c:otherwise>--</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                </div>

                <div class="sa-footer-actions lh-mt-18" style="display: flex; gap: 10px; flex-wrap: wrap;">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments"><i class="fas fa-arrow-left"></i> Back to Assessments</a>
                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=performance"><i class="fas fa-chart-column"></i> Performance</a>
                </div>
            </article>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script>
(function () {
    var copyButtons = document.querySelectorAll('[data-copy-url]');
    copyButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            var url = button.getAttribute('data-copy-url');
            if (!url || !navigator.clipboard) {
                return;
            }
            navigator.clipboard.writeText(url).then(function () {
                button.textContent = 'Copied';
                setTimeout(function () {
                    button.innerHTML = '<i class="fas fa-copy"></i> Copy Link';
                }, 1200);
            }).catch(function () {
                // Keep silent to avoid disrupting the page if clipboard is blocked.
            });
        });
    });
})();
</script>
</body>
</html>
