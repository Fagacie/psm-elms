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
                    <div>
                        <h3>${assessment.title}</h3>
                        <p>
                            Submission date:
                            <c:choose>
                                <c:when test="${not empty submission.submitDate}">${fn:replace(submission.submitDate, 'T', ' ')}</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                            <c:if test="${not empty submission.endedAt}">
                                | Ended: ${fn:replace(submission.endedAt, 'T', ' ')}
                            </c:if>
                        </p>
                    </div>
                    <span class="sa-status ${statusClass}">${submissionStatusLabel}</span>
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
                            This submission has been graded automatically.
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
                        <h3>Performance breakdown</h3>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not objectiveAssessment || empty questions}">
                        <div class="sa-empty">
                            <h3>No breakdown available</h3>
                            <p>This assessment was submitted as a file or the question set is unavailable.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="sa-breakdown">
                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <div class="sa-breakdown-item">
                                    <h4>Q${loop.index + 1}. ${q.questionText}</h4>
                                    <p><strong>Your answer:</strong> <c:out value="${empty studentAnswerByQuestionId[q.questionId] ? '--' : studentAnswerByQuestionId[q.questionId]}"/></p>
                                    <p><strong>Correct answer:</strong> <c:out value="${empty correctAnswerByQuestionId[q.questionId] ? '--' : correctAnswerByQuestionId[q.questionId]}"/></p>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </article>

            <article class="sa-panel">
                <div class="sa-panel-head">
                    <div>
                        <h3>Submission details</h3>
                    </div>
                </div>

                <div class="sa-detail-grid">
                    <div class="sa-detail-list">
                        <div class="sa-detail-item">
                            <span>Raw submission</span>
                            <p>
                                <c:choose>
                                    <c:when test="${not empty submission.answersFilePath}">${submission.answersFilePath}</c:when>
                                    <c:otherwise>--</c:otherwise>
                                </c:choose>
                            </p>
                            <c:if test="${not empty submission.answersFilePath and (fn:startsWith(submission.answersFilePath, 'http://') or fn:startsWith(submission.answersFilePath, 'https://'))}">
                                <div class="sa-footer-actions" style="margin-top: 10px; gap: 8px;">
                                    <a class="sv-btn" href="${submission.answersFilePath}" target="_blank" rel="noopener noreferrer">
                                        <i class="fas fa-up-right-from-square"></i> Open Submission
                                    </a>
                                    <button type="button" class="sv-btn" data-copy-url="${submission.answersFilePath}">
                                        <i class="fas fa-copy"></i> Copy Link
                                    </button>
                                </div>
                            </c:if>
                        </div>
                        <div class="sa-detail-item">
                            <span>Status</span>
                            <strong>${submissionStatusLabel}</strong>
                        </div>
                        <div class="sa-detail-item">
                            <span>Submitted by</span>
                            <strong><c:choose><c:when test="${not empty submission.studentName}">${submission.studentName}</c:when><c:otherwise>${sessionScope.userName}</c:otherwise></c:choose></strong>
                        </div>
                    </div>

                    <div class="sa-detail-list">
                        <div class="sa-detail-item">
                            <span>Audit trail</span>
                            <c:choose>
                                <c:when test="${empty submissionAudits}"><p>No grading audit entries yet.</p></c:when>
                                <c:otherwise>
                                    <c:forEach var="audit" items="${submissionAudits}">
                                        <p>${audit.actionType} by ${audit.gradedByName} on ${fn:replace(audit.gradedAt, 'T', ' ')}</p>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="sa-footer-actions" style="margin-top: 18px;">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=history&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-clock-rotate-left"></i> View History</a>
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
