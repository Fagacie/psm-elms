<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${assessment.title} - Assessment Overview</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AssessmentLayout.module.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Assessment Overview"/>
<c:set var="topbarSubtitle" value="Review the format, timing, and submission requirements"/>
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
            <span>Overview</span>
        </div>

        <section class="container" id="overviewStage" data-stage-current="true">
            <div class="pre_assessment_container">
                <h1 class="title">${assessment.title}</h1>
                
                <div class="metadata_row">
                    <c:choose>
                        <c:when test="${assessment.totalMarks != null && assessment.totalMarks > 0}">
                            <span class="metadata_pill">Total Points: ${assessment.totalMarks}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="metadata_pill">Total Points: ${fn:length(questions)}</span>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${assessment.duration != null}">
                        <span class="metadata_pill">Time Limit: ${assessment.duration} Minutes</span>
                    </c:if>
                    <c:if test="${assessment.duration == null}">
                        <span class="metadata_pill">No Time Limit</span>
                    </c:if>
                </div>

                <p class="instructions">
                    <c:choose>
                        <c:when test="${not empty displayInstructions}">${displayInstructions}</c:when>
                        <c:when test="${objectiveAssessment}">This assessment is timed and graded from the current question payload. Review the brief below before starting.</c:when>
                        <c:otherwise>Prepare your file or written response using the current submission mode shown below.</c:otherwise>
                    </c:choose>
                </p>

                <div class="submit_action_container">
                    <a class="secondary_button" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments" style="margin-right: 12px;">
                        <i class="fas fa-arrow-left"></i>
                        <span>Back to Course</span>
                    </a>
                    <c:choose>
                        <c:when test="${enrollment.daysRemaining < 0 && enrollment.courseDuration != null && enrollment.courseDuration > 0}">
                            <button type="button" class="danger_button" disabled="disabled">
                                <i class="fas fa-calendar-times"></i>
                                <span>Course Expired</span>
                            </button>
                        </c:when>
                        <c:when test="${canAttempt and objectiveAssessment}">
                            <a class="primary_button"
                               href="${pageContext.request.contextPath}/student/assessments?view=take&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&mode=attempt"
                               data-load-attempt-url="${pageContext.request.contextPath}/student/assessments?view=take&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&mode=attempt">
                                <i class="fas fa-play"></i>
                                <span>Start Assessment</span>
                            </a>
                        </c:when>
                        <c:when test="${canAttempt}">
                            <button type="button" class="primary_button" data-stage-target="assignmentWorkspace">
                                <i class="fas fa-pen-ruler"></i>
                                <span>Start Assessment</span>
                            </button>
                        </c:when>
                        <c:otherwise>
                            <c:set var="totalPoints" value="${(assessment.totalMarks != null && assessment.totalMarks > 0) ? assessment.totalMarks : fn:length(questions)}"/>
                            <c:set var="hasPassed" value="${not empty latestSubmission and not empty latestSubmission.score and (latestSubmission.score >= (totalPoints * 0.7))}"/>
                            <c:choose>
                                <c:when test="${not empty latestSubmission and not empty latestSubmission.score and not hasPassed}">
                                    <c:choose>
                                        <c:when test="${hasPendingRetakeRequest}">
                                            <button type="button" class="warning_button" disabled="disabled" style="background-color: #fef3c7; border: 1px solid #fcd34d; color: #d97706; padding: 10px 20px; border-radius: 6px; font-weight: 500; font-size: 0.875rem; display: inline-flex; align-items: center; gap: 8px;">
                                                <i class="fas fa-hourglass-half"></i>
                                                <span>Retake Request Pending</span>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <form method="post" action="${pageContext.request.contextPath}/student/assessments" style="display: inline-block; margin: 0;">
                                                <input type="hidden" name="action" value="requestRetake">
                                                <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                <button type="submit" class="warning_button" style="background-color: #f59e0b; color: #ffffff; padding: 10px 20px; border: none; border-radius: 6px; font-weight: 500; font-size: 0.875rem; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                                                    <i class="fas fa-envelope"></i>
                                                    <span>Request Retake</span>
                                                </button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="danger_button" disabled="disabled">
                                        <i class="fas fa-ban"></i>
                                        <span>No Attempts Remaining</span>
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </section>

        <c:if test="${not objectiveAssessment}">
            <section class="container" id="assignmentWorkspace" style="display: none;">
                <div class="active_assessment_container">
                    <h1 class="title">Active Assessment: ${assessment.title}</h1>
                    
                    <%-- Explicitly check for assessment attachment url or file url to render download anchor --%>
                    <c:set var="attachmentUrl" value="${assessment.attachmentUrl}"/>
                    <c:if test="${empty attachmentUrl}">
                        <c:set var="attachmentUrl" value="${assessment.fileUrl}"/>
                    </c:if>
                    <c:if test="${empty attachmentUrl and not empty questions}">
                        <c:set var="attachmentUrl" value="${questions[0].attachmentUrl}"/>
                    </c:if>
                    
                    <c:if test="${not empty attachmentUrl}">
                        <a class="file_download_anchor" href="${attachmentUrl}" target="_blank" rel="noopener noreferrer">
                            <i class="fas fa-file-pdf"></i>
                            <span>Download Project Brief / Instructions PDF</span>
                        </a>
                    </c:if>

                    <form method="post"
                          id="assignmentHubForm"
                          action="${pageContext.request.contextPath}/student/assessments"
                          enctype="multipart/form-data"
                          data-loading-submit
                          class="ax-composer">
                        <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                        <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                        <div class="dropzone" data-upload-zone>
                            <input name="answerFile" type="file" style="display: none;">
                            <div class="dropzone_content">
                                <i class="fas fa-cloud-arrow-up dropzone_icon"></i>
                                <div class="dropzone_text">Click to browse or drag your PDF answer file here</div>
                                <div class="dropzone_subtext">Supports PDF up to 50MB</div>
                            </div>
                        </div>

                        <div style="margin-top: 24px; text-align: left;">
                            <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #0f172a;">Written Answer (Optional)</label>
                            <textarea class="ax-textarea" name="answerText" maxlength="255" placeholder="Add a concise response if required by the instructor."></textarea>
                            <div style="display: flex; justify-content: space-between; font-size: 0.875rem; color: #64748b; margin-top: 4px;">
                                <span>Maximum 255 characters</span>
                            </div>
                        </div>

                        <div class="submit_action_container">
                            <button type="button" class="secondary_button" data-stage-target="overviewStage">
                                <i class="fas fa-arrow-left"></i>
                                <span>Back to Overview</span>
                            </button>
                            <button type="submit" class="primary_button" data-submit-button data-loading-label="Submitting your work...">
                                <i class="fas fa-paper-plane"></i>
                                <span>Submit Assessment</span>
                            </button>
                        </div>
                    </form>
                </div>
            </section>
        </c:if>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
</body>
</html>
