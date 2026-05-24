<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${assessment.title} - Results</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-experience.css">
</head>
<body class="sv-page ax-page">
<c:set var="topbarTitle" value="Assessment Result"/>
<c:set var="topbarSubtitle" value="Review your outcome and next steps"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="course"/>
<c:set var="navContextPage" value="assessments"/>
<c:set var="navCourseEnrollmentId" value="${enrollment.enrollmentId}"/>
<c:set var="navCourseTitle" value="${enrollment.courseName}"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<c:set var="scorePercent" value="${empty submission.score ? 0 : (percentage > 100 ? 100 : (percentage < 0 ? 0 : percentage))}"/>
<c:set var="passedAssessment" value="${not empty submission.score and percentage >= 70}"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main ax-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">Assessments</a>
            <span>/</span>
            <span>Results</span>
        </div>

        <section class="ax-shell">
            <article class="ax-frame ax-result-hero">
                <div class="ax-result-hero__copy">
                    <span class="ax-overview__eyebrow"><i class="fas fa-chart-pie"></i> Results Dashboard</span>
                    <h1 class="ax-result-hero__title">${assessment.title}</h1>
                    <p class="ax-result-hero__body">
                        <c:choose>
                            <c:when test="${empty submission.score}">Your submission has been received and is still awaiting review. The dashboard below reflects the current grading status from the existing payload.</c:when>
                            <c:when test="${passedAssessment}">Your latest submission met the current passing threshold. Review the breakdown below and continue to the next learning step when ready.</c:when>
                            <c:otherwise>Your latest submission is below the current passing threshold. Use the review section below to focus your next revision or retake.</c:otherwise>
                        </c:choose>
                    </p>

                    <div class="ax-chip-row" style="margin-top: 20px;">
                        <span class="ax-badge ${empty submission.score ? 'ax-badge--pending' : (passedAssessment ? 'ax-badge--pass' : 'ax-badge--fail')}">
                            <i class="fas ${empty submission.score ? 'fa-clock' : (passedAssessment ? 'fa-circle-check' : 'fa-circle-xmark')}"></i>
                            <c:choose>
                                <c:when test="${empty submission.score}">Awaiting Grade</c:when>
                                <c:when test="${passedAssessment}">Passed</c:when>
                                <c:otherwise>Failed</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="ax-chip"><i class="fas fa-repeat"></i> Attempt #${submission.attemptNumber}</span>
                        <span class="ax-chip"><i class="fas fa-layer-group"></i> ${objectiveAssessment ? 'Objective Assessment' : 'Assignment Submission'}</span>
                    </div>
                </div>

                <div class="ax-score-ring" style="--score-angle: ${scorePercent * 3.6}deg;">
                    <div class="ax-score-ring__inner">
                        <div class="ax-score-ring__value">
                            <c:choose>
                                <c:when test="${not empty submission.score}"><fmt:formatNumber value="${percentage}" maxFractionDigits="0"/>%</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="ax-score-ring__label">Score</div>
                    </div>
                </div>
            </article>

            <div class="ax-result-kpis">
                <article class="ax-meta-card ax-kpi">
                    <i class="fas fa-star"></i>
                    <div>
                        <span>Raw Score</span>
                        <strong><c:choose><c:when test="${not empty submission.score}"><fmt:formatNumber value="${submission.score}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                    </div>
                </article>
                <article class="ax-meta-card ax-kpi">
                    <i class="fas fa-bullseye"></i>
                    <div>
                        <span>Passing Threshold</span>
                        <strong>70%</strong>
                    </div>
                </article>
                <article class="ax-meta-card ax-kpi">
                    <i class="fas fa-calendar-check"></i>
                    <div>
                        <span>Graded Date</span>
                        <strong>
                            <c:choose>
                                <c:when test="${not empty submissionAudits and not empty submissionAudits[0].gradedAt}">${fn:replace(submissionAudits[0].gradedAt, 'T', ' ')}</c:when>
                                <c:when test="${not empty submission.endedAt}">${fn:replace(submission.endedAt, 'T', ' ')}</c:when>
                                <c:otherwise>Pending</c:otherwise>
                            </c:choose>
                        </strong>
                    </div>
                </article>
                <article class="ax-meta-card ax-kpi">
                    <i class="fas fa-wave-square"></i>
                    <div>
                        <span>Status</span>
                        <strong>${submissionStatusLabel}</strong>
                    </div>
                </article>
            </div>

            <article class="ax-panel">
                <h2 class="ax-panel__title">Feedback</h2>
                <p class="ax-panel__copy">
                    <c:choose>
                        <c:when test="${not empty submission.feedback}">${submission.feedback}</c:when>
                        <c:when test="${not empty submission.score}">This submission was graded using the current assessment workflow. No extra written feedback was provided.</c:when>
                        <c:otherwise>Your submission is still under review. Come back to this page for the final score and feedback.</c:otherwise>
                    </c:choose>
                </p>
            </article>

            <article class="ax-panel">
                <div class="ax-result-meta">
                    <div>
                        <h2 class="ax-panel__title">Review Answers</h2>
                        <p class="ax-panel__copy">When correct-answer data is available, each response is shown with clear pass/fail styling.</p>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${not objectiveAssessment || empty questions}">
                        <div class="ax-empty">
                            <h3 class="ax-section-title">No question review available</h3>
                            <p class="ax-section-copy">This assessment was submitted as an assignment or the current payload does not include per-question review data.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="ax-review-list">
                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <c:set var="studAns" value="${empty studentAnswerByQuestionId[q.questionId] ? '' : studentAnswerByQuestionId[q.questionId]}" />
                                <c:set var="corrAns" value="${empty correctAnswerByQuestionId[q.questionId] ? '' : correctAnswerByQuestionId[q.questionId]}" />
                                <c:set var="isCorrect" value="${not empty studAns and studAns == corrAns}" />
                                <article class="ax-review-card ${isCorrect ? 'ax-review-card--correct' : 'ax-review-card--incorrect'}">
                                    <div class="ax-review-card__head">
                                        <span class="ax-badge ${isCorrect ? 'ax-badge--pass' : 'ax-badge--fail'}">
                                            <i class="fas ${isCorrect ? 'fa-check' : 'fa-xmark'}"></i>
                                            ${isCorrect ? 'Correct' : 'Incorrect'}
                                        </span>
                                        <span class="ax-chip">Question ${loop.index + 1}</span>
                                    </div>
                                    <p class="ax-review-card__question">${q.questionText}</p>
                                    <div class="ax-review-card__answers">
                                        <div class="ax-inline-card">
                                            <i class="fas fa-user"></i>
                                            <div>
                                                <span>Your Answer</span>
                                                <strong><c:out value="${empty studAns ? '--' : studAns}"/></strong>
                                            </div>
                                        </div>
                                        <div class="ax-inline-card">
                                            <i class="fas fa-key"></i>
                                            <div>
                                                <span>Correct Answer</span>
                                                <strong><c:out value="${empty corrAns ? '--' : corrAns}"/></strong>
                                            </div>
                                        </div>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </article>

            <article class="ax-panel">
                <h2 class="ax-panel__title">Submission Record</h2>
                <div class="ax-review-card__answers" style="margin-top: 18px;">
                    <div class="ax-inline-card">
                        <i class="fas fa-user-graduate"></i>
                        <div>
                            <span>Submitted By</span>
                            <strong>${sessionScope.userName}</strong>
                        </div>
                    </div>
                    <div class="ax-inline-card">
                        <i class="fas fa-calendar-day"></i>
                        <div>
                            <span>Submitted At</span>
                            <strong><c:choose><c:when test="${not empty submission.submitDate}">${fn:replace(submission.submitDate, 'T', ' ')}</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                        </div>
                    </div>
                    <div class="ax-inline-card">
                        <i class="fas fa-paperclip"></i>
                        <div>
                            <span>Submission Payload</span>
                            <strong><c:choose><c:when test="${not empty submission.answersFilePath}">${submission.answersFilePath}</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                        </div>
                    </div>
                    <div class="ax-inline-card">
                        <i class="fas fa-flag"></i>
                        <div>
                            <span>Next Step</span>
                            <strong><c:choose><c:when test="${passedAssessment}">Continue learning</c:when><c:otherwise>Review and retry if allowed</c:otherwise></c:choose></strong>
                        </div>
                    </div>
                </div>

                <div class="ax-result-actions" style="margin-top: 24px;">
                    <a class="ax-btn ax-btn--secondary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                        <i class="fas fa-arrow-left"></i>
                        <span>Return to Course</span>
                    </a>
                    <a class="ax-btn ax-btn--primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning">
                        <i class="fas fa-arrow-right"></i>
                        <span>Proceed to Next Module</span>
                    </a>
                </div>
            </article>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
