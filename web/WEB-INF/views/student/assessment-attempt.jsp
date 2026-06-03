<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${assessment.title} - Active Assessment</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AssessmentLayout.module.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Active Assessment"/>
<c:set var="topbarSubtitle" value="Stay focused and submit when ready"/>
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
            <span>Active</span>
        </div>

        <section class="container" data-attempt-shell>
            <c:choose>
                <c:when test="${objectiveAssessment}">
                    <div class="active_assessment_container">
                        
                        <div class="active_question_header">
                            <div>
                                <span style="font-size: 0.875rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;"><i class="fas fa-shield-halved"></i> Active Assessment</span>
                                <h1 class="title" style="margin-top: 4px; font-size: 1.75rem; text-align: left;">${assessment.title}</h1>
                            </div>
                            <div class="timer_box" data-timer>
                                <i class="fas fa-clock"></i>
                                <span data-timer-text>00:00</span>
                            </div>
                        </div>

                        <div class="progress_row">
                            <span class="progress_text">Question <strong data-current-question>1</strong> of ${questions.size()}</span>
                            <span class="progress_text">Progress</span>
                        </div>
                        <div class="progress_bar_bg">
                            <div class="progress_bar_fill" data-progress-fill></div>
                        </div>

                        <div class="stepper_row">
                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <button type="button" class="stepper_item ${loop.first ? 'stepper_item_active' : ''}" data-step-index="${loop.index}">${loop.index + 1}</button>
                            </c:forEach>
                        </div>

                        <form method="post"
                              action="${pageContext.request.contextPath}/student/assessments"
                              data-attempt-form
                              data-timer-start="${timerStartTime}"
                              data-timer-duration="${timerDurationSeconds}"
                              class="ax-attempt-form">
                            <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                            <input type="hidden" name="timerStart" value="${timerStartTime}">
                            <input type="hidden" name="timerDuration" value="${timerDurationSeconds}">
                            <input type="hidden" name="exitSubmission" value="0">

                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <article class="ax-question ${loop.first ? 'is-active' : ''}" data-question-index="${loop.index}" style="display: ${loop.first ? 'block' : 'none'};">
                                    <h2 class="question_statement">${loop.index + 1}. ${q.questionText}</h2>
                                    
                                    <div class="choices_container">
                                        <label class="choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="A" style="display: none;" required>
                                            <span class="choice_badge">A</span>
                                            <span class="choice_text">${q.optionA}</span>
                                        </label>
                                        <label class="choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="B" style="display: none;" required>
                                            <span class="choice_badge">B</span>
                                            <span class="choice_text">${q.optionB}</span>
                                        </label>
                                        <label class="choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="C" style="display: none;" required>
                                            <span class="choice_badge">C</span>
                                            <span class="choice_text">${q.optionC}</span>
                                        </label>
                                        <label class="choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="D" style="display: none;" required>
                                            <span class="choice_badge">D</span>
                                            <span class="choice_text">${q.optionD}</span>
                                        </label>
                                    </div>
                                </article>
                            </c:forEach>

                            <div class="submit_action_container" style="justify-content: space-between; border-top: 1px solid #e2e8f0; padding-top: 24px;">
                                <div style="display: flex; gap: 8px;">
                                    <button type="button" class="secondary_button" data-prev-question>
                                        <i class="fas fa-arrow-left"></i>
                                        <span>Previous</span>
                                    </button>
                                    <button type="button" class="secondary_button" data-next-question>
                                        <span>Next</span>
                                        <i class="fas fa-arrow-right"></i>
                                    </button>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <button type="button" class="danger_button" data-exit-attempt>
                                        <i class="fas fa-door-open"></i>
                                        <span>Save & Exit</span>
                                    </button>
                                    <button type="submit" class="primary_button" data-submit-button>
                                        <i class="fas fa-paper-plane"></i>
                                        <span>Submit Assessment</span>
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="active_assessment_container">
                        <h1 class="title">${assessment.title}</h1>
                        
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

                        <c:if test="${not empty questions}">
                            <div style="margin-top: 20px; margin-bottom: 24px; text-align: left;">
                                <c:forEach var="q" items="${questions}" varStatus="loop">
                                    <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; margin-bottom: 12px;">
                                        <strong style="color: #64748b; font-size: 0.875rem;">Prompt ${loop.index + 1}</strong>
                                        <p style="margin: 4px 0 0 0; color: #0f172a; font-weight: 600;">${q.questionText}</p>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>

                        <form method="post"
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
                                <textarea class="ax-textarea" name="answerText" maxlength="255" placeholder="Add a concise written answer if required."></textarea>
                                <div style="display: flex; justify-content: space-between; font-size: 0.875rem; color: #64748b; margin-top: 4px;">
                                    <span>Maximum 255 characters</span>
                                </div>
                            </div>

                            <div class="submit_action_container" style="justify-content: space-between; border-top: 1px solid #e2e8f0; padding-top: 24px;">
                                <a class="secondary_button" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                                    <i class="fas fa-arrow-left"></i>
                                    <span>Back to Course</span>
                                </a>
                                <button type="submit" class="primary_button" data-submit-button data-loading-label="Submitting your work...">
                                    <i class="fas fa-paper-plane"></i>
                                    <span>Submit Assessment</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
</body>
</html>
