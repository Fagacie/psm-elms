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
                <div class="sa-panel-head">
                    <div>
                        <h3>Submitted successfully</h3>
                    </div>
                    <span class="sa-status ${statusClass}">${submissionStatusLabel}</span>
                </div>

                <div class="sa-result-score">
                    <div class="sa-score-card">
                        <span>Assessment</span>
                        <strong>${assessment.title}</strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Submitted at</span>
                        <strong>${submission.submitDate}</strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Attempt</span>
                        <strong>#${submission.attemptNumber}</strong>
                    </div>
                    <div class="sa-score-card">
                        <span>Score</span>
                        <strong><c:choose><c:when test="${not empty submission.score}">${submission.score}</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                    </div>
                </div>

                <div class="sa-note ${not empty submission.score ? 'success' : 'warning'}" style="margin-top: 18px;">
                    <c:choose>
                        <c:when test="${not empty submission.score}">Your submission has been auto graded.</c:when>
                        <c:otherwise>Your submission is awaiting instructor review.</c:otherwise>
                    </c:choose>
                </div>

                <div class="sa-footer-actions" style="margin-top: 20px;">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
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
