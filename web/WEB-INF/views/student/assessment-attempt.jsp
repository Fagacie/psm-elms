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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/focus-mode.css">
</head>
<body class="sv-page sv-focus-mode" style="background-color: #fcfcfc;">

    <%-- FOCUS TOPBAR --%>
    <header class="focus_topbar">
        <div class="focus_topbar_left">
            <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments" class="focus_topbar_btn" title="Save and Exit">
                <i class="fas fa-xmark"></i> Save & Exit
            </a>
        </div>
        <div class="focus_topbar_center">
            <div class="focus_course_name">${enrollment.courseName}</div>
            <div class="focus_question_count">Question <span id="currentQText">1</span> of ${questions.size()}</div>
        </div>
        <div class="focus_topbar_right">
            <div class="focus_timer_box" data-timer>
                <i class="far fa-clock"></i>
                <span data-timer-text>00:00</span>
            </div>
        </div>
    </header>
    <div class="focus_progress_bar_bg">
        <div class="focus_progress_bar_fill" id="focusProgressFill" style="width: 0%;"></div>
    </div>

    <%-- MAIN CONTENT --%>
    <main class="focus_main_container">
        <section data-attempt-shell>
            <c:choose>
                <c:when test="${objectiveAssessment}">
                    <div class="focus_assessment_container">
                        <form method="post"
                              action="${pageContext.request.contextPath}/student/assessments"
                              data-attempt-form
                              data-timer-start="${timerStartTime}"
                              data-timer-duration="${timerDurationSeconds}"
                              class="ax-attempt-form"
                              style="width: 100%;">
                            <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                            <input type="hidden" name="timerStart" value="${timerStartTime}">
                            <input type="hidden" name="timerDuration" value="${timerDurationSeconds}">
                            <input type="hidden" name="exitSubmission" value="0">

                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                <article class="ax-question ${loop.first ? 'is-active' : ''}" data-question-index="${loop.index}" style="display: ${loop.first ? 'block' : 'none'};">
                                    <div class="focus_question_badge">${assessment.title}</div>
                                    <div class="focus_question_statement">${q.questionText}</div>
                                    
                                    <div class="focus_choices_container">
                                        <label class="focus_choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="A" style="display: none;" required>
                                            <span class="focus_choice_badge">A</span>
                                            <span class="focus_choice_text">${q.optionA}</span>
                                            <i class="fas fa-check-circle focus_choice_check"></i>
                                        </label>
                                        <label class="focus_choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="B" style="display: none;" required>
                                            <span class="focus_choice_badge">B</span>
                                            <span class="focus_choice_text">${q.optionB}</span>
                                            <i class="fas fa-check-circle focus_choice_check"></i>
                                        </label>
                                        <label class="focus_choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="C" style="display: none;" required>
                                            <span class="focus_choice_badge">C</span>
                                            <span class="focus_choice_text">${q.optionC}</span>
                                            <i class="fas fa-check-circle focus_choice_check"></i>
                                        </label>
                                        <label class="focus_choice_block">
                                            <input type="radio" name="q_${q.questionId}" value="D" style="display: none;" required>
                                            <span class="focus_choice_badge">D</span>
                                            <span class="focus_choice_text">${q.optionD}</span>
                                            <i class="fas fa-check-circle focus_choice_check"></i>
                                        </label>
                                    </div>
                                </article>
                            </c:forEach>

                            <div class="focus_bottom_nav">
                                <button type="button" class="focus_btn_prev" data-prev-question style="display: none; gap: 8px;">
                                    <i class="fas fa-arrow-left"></i> Previous
                                </button>
                                <button type="button" class="focus_btn_next" data-next-question style="gap: 8px;">
                                    <span class="focus_next_label">Next Question</span> <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="focus_assessment_container">
                        <div class="focus_question_badge">Assignment</div>
                        <div class="focus_question_statement" style="text-align: center;">${assessment.title}</div>
                        
                        <c:set var="attachmentUrl" value="${assessment.attachmentUrl}"/>
                        <c:if test="${empty attachmentUrl}">
                            <c:set var="attachmentUrl" value="${assessment.fileUrl}"/>
                        </c:if>
                        <c:if test="${empty attachmentUrl and not empty questions}">
                            <c:set var="attachmentUrl" value="${questions[0].attachmentUrl}"/>
                        </c:if>
                        
                        <c:if test="${not empty attachmentUrl}">
                            <a class="focus_file_download" href="${attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                <i class="fas fa-file-pdf"></i>
                                <span>Download Project Brief / Instructions PDF</span>
                            </a>
                        </c:if>

                        <c:if test="${not empty questions}">
                            <div class="focus_prompts_container">
                                <c:forEach var="q" items="${questions}" varStatus="loop">
                                    <div class="focus_prompt_box">
                                        <strong>Prompt ${loop.index + 1}</strong>
                                        <p>${q.questionText}</p>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>

                        <form method="post"
                              action="${pageContext.request.contextPath}/student/assessments"
                              enctype="multipart/form-data"
                              data-loading-submit
                              class="ax-composer"
                              style="width: 100%;">
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

                            <div class="focus_textarea_group">
                                <label>Written Answer (Optional)</label>
                                <textarea class="ax-textarea" name="answerText" maxlength="255" placeholder="Add a concise written answer if required."></textarea>
                                <span>Maximum 255 characters</span>
                            </div>

                            <div class="focus_bottom_nav" style="justify-content: flex-end;">
                                <button type="submit" class="focus_btn_next" data-submit-button data-loading-label="Submitting your work...">
                                    <span>Submit Assignment</span> <i class="fas fa-paper-plane" style="margin-left: 6px;"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </main>

<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
</body>
</html>
