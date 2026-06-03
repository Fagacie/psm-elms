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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AssessmentLayout.module.css">
</head>
<body class="sv-page">
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

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">Assessments</a>
            <span>/</span>
            <span>Results</span>
        </div>

        <section class="container">
            <div class="result_container">
                
                <h1 class="title">${assessment.title}</h1>
                
                <div class="result_score_hero">
                    <c:choose>
                        <c:when test="${not empty submission.score}"><fmt:formatNumber value="${percentage}" maxFractionDigits="0"/>%</c:when>
                        <c:otherwise>--</c:otherwise>
                    </c:choose>
                </div>

                <div class="status_pill ${empty submission.score ? 'status_pill_failed' : (passedAssessment ? 'status_pill_passed' : 'status_pill_failed')}">
                    <i class="fas ${empty submission.score ? 'fa-clock' : (passedAssessment ? 'fa-circle-check' : 'fa-circle-xmark')}" style="margin-right: 8px;"></i>
                    <c:choose>
                        <c:when test="${empty submission.score}">Awaiting Grade</c:when>
                        <c:when test="${passedAssessment}">Passed</c:when>
                        <c:otherwise>Failed</c:otherwise>
                    </c:choose>
                </div>

                <p style="color: #64748b; line-height: 1.6; max-width: 50ch; margin: 0 auto 24px;">
                    <c:choose>
                        <c:when test="${empty submission.score}">Your submission has been received and is currently awaiting grading by your instructor.</c:when>
                        <c:when test="${passedAssessment}">Great work! You have successfully passed this assessment milestone.</c:when>
                        <c:otherwise>Your score did not meet the 70% passing threshold. You can review the details below and try again if attempts remain.</c:otherwise>
                    </c:choose>
                </p>

                <%-- Transparent Question Review Grid --%>
                <div class="review_grid">
                    <c:choose>
                        <c:when test="${not objectiveAssessment || empty questions}">
                            <div style="text-align: center; padding: 24px; background-color: #f8fafc; border-radius: 8px; color: #64748b;">
                                <i class="fas fa-folder-open" style="font-size: 2rem; margin-bottom: 8px;"></i>
                                <p style="margin: 0;">No question-level review is available for this submission.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <c:set var="studAns" value="${empty studentAnswerByQuestionId[q.questionId] ? '' : studentAnswerByQuestionId[q.questionId]}" />
                                <c:set var="corrAns" value="${empty correctAnswerByQuestionId[q.questionId] ? '' : correctAnswerByQuestionId[q.questionId]}" />
                                <c:set var="isCorrect" value="${not empty studAns and studAns == corrAns}" />
                                
                                <div class="review_row">
                                    <div class="review_question_text">${loop.index + 1}. ${q.questionText}</div>
                                    <div class="student_choice">
                                        <c:choose>
                                            <c:when test="${isCorrect}">
                                                <i class="fas fa-circle-check icon_correct"></i>
                                                <span>Your Answer: <strong>${studAns}</strong></span>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-circle-xmark icon_incorrect"></i>
                                                <span>Your Answer: <strong>${empty studAns ? 'None' : studAns}</strong></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not isCorrect}">
                                        <div class="correct_answer_block">
                                            <span>Correct Answer: <strong>${corrAns}</strong></span>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="exit_button_container">
                    <a class="primary_button" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning" data-complete-and-continue>
                        <span>Complete &amp; Continue</span>
                        <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
                
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
</body>
</html>
