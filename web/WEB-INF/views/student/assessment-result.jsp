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
            <article class="sa-result-card sa-panel">
                <div class="sa-panel-head">
                    <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                        <h3 style="margin: 0; font-size: 1.4rem;">${assessment.title}</h3>
                        <span class="sa-status ${statusClass}">${submissionStatusLabel}</span>
                    </div>
                </div>

                <div class="sa-result-score">
                    <div class="sa-score-card">
                        <span>Score</span>
                        <strong><c:choose><c:when test="${not empty submission.score}"><fmt:formatNumber value="${submission.score}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Percentage</span>
                        <strong><c:choose><c:when test="${not empty submission.score}"><fmt:formatNumber value="${percentage}" maxFractionDigits="1"/>%</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Graded date</span>
                        <strong><c:choose><c:when test="${not empty submissionAudits}">${fn:replace(submissionAudits[0].gradedAt, 'T', ' ')}</c:when><c:when test="${not empty submission.endedAt}">${fn:replace(submission.endedAt, 'T', ' ')}</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Attempt</span>
                        <strong>#${submission.attemptNumber}</strong>
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

            <article class="sa-panel">
                <div class="sa-panel-head">
                    <div>
                        <h3>Question breakdown</h3>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not objectiveAssessment || empty questions}">
                        <div class="sa-empty">
                            <h3>No breakdown available</h3>
                            <p>This assessment was submitted as a file or the question set is not available.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="sa-breakdown">
                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <c:set var="studAns" value="${empty studentAnswerByQuestionId[q.questionId] ? '' : studentAnswerByQuestionId[q.questionId]}" />
                                <c:set var="corrAns" value="${empty correctAnswerByQuestionId[q.questionId] ? '' : correctAnswerByQuestionId[q.questionId]}" />
                                <c:set var="isCorrect" value="${not empty studAns and studAns == corrAns}" />
                                <div class="sa-breakdown-item ${isCorrect ? 'correct' : 'incorrect'}" style="padding: 12px; margin-bottom: 8px;">
                                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
                                        <span class="sa-badge-flat ${isCorrect ? 'success' : 'danger'}" style="margin: 0;">
                                        <i class="fas ${isCorrect ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                                        ${isCorrect ? 'Correct' : 'Incorrect'}
                                    </div>
                                    <h4 style="margin: 0 0 8px 0; font-size: 1rem;">Q${loop.index + 1}. ${q.questionText}</h4>
                                    <div style="display: flex; gap: 24px; font-size: 0.9rem;">
                                        <p style="margin: 0;"><strong>Your answer:</strong> <c:out value="${empty studAns ? '--' : studAns}"/></p>
                                        <p style="margin: 0;"><strong>Correct answer:</strong> <c:out value="${empty corrAns ? '--' : corrAns}"/></p>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </article>

                <div class="sa-footer-actions" style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--sv-border);">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-arrow-left"></i> Back to Assessments</a>
                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=history&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-clock-rotate-left"></i> View Attempts</a>
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
