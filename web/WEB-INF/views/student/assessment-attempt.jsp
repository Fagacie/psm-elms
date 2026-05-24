<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${assessment.title} - Active Assessment</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-experience.css">
</head>
<body class="sv-page ax-page">
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

    <main class="sv-main ax-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">Assessments</a>
            <span>/</span>
            <span>Active</span>
        </div>

        <section class="ax-shell" data-attempt-shell>
            <article class="ax-frame ax-focus__hero">
                <div>
                    <span class="ax-overview__eyebrow"><i class="fas fa-shield-halved"></i> Active Assessment</span>
                    <h1 class="ax-focus__title">${assessment.title}</h1>
                    <p class="ax-focus__body">
                        <c:choose>
                            <c:when test="${objectiveAssessment}">Move through each question using the stepper, review your progress, and submit when you are satisfied with your answers.</c:when>
                            <c:otherwise>Upload your files, complete the written response if needed, and submit from the sticky action bar below.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <c:if test="${objectiveAssessment}">
                    <div class="ax-timer" data-timer>
                        <i class="fas fa-clock"></i>
                        <span data-timer-text>00:00</span>
                    </div>
                </c:if>
            </article>

            <c:choose>
                <c:when test="${objectiveAssessment}">
                    <div class="ax-layout">
                        <section class="ax-panel">
                            <div class="ax-progress">
                                <div class="ax-progress__meta">
                                    <span>Question <strong data-current-question>1</strong> of ${questions.size()}</span>
                                    <span>Completion progress</span>
                                </div>
                                <div class="ax-progress__bar">
                                    <div class="ax-progress__fill" data-progress-fill></div>
                                </div>
                            </div>

                            <div class="ax-stepper" style="margin-top: 20px;">
                                <c:forEach var="q" items="${questions}" varStatus="loop">
                                    <button type="button" class="ax-stepper__item ${loop.first ? 'is-active' : ''}" data-step-index="${loop.index}">${loop.index + 1}</button>
                                </c:forEach>
                            </div>

                            <form method="post"
                                  action="${pageContext.request.contextPath}/student/assessments"
                                  data-attempt-form
                                  data-timer-start="${timerStartTime}"
                                  data-timer-duration="${timerDurationSeconds}"
                                  style="display: grid; gap: 24px; margin-top: 24px;">
                                <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                <input type="hidden" name="timerStart" value="${timerStartTime}">
                                <input type="hidden" name="timerDuration" value="${timerDurationSeconds}">
                                <input type="hidden" name="exitSubmission" value="0">

                                <c:forEach var="q" items="${questions}" varStatus="loop">
                                    <article class="ax-question ${loop.first ? 'is-active' : ''}" data-question-index="${loop.index}">
                                        <div class="ax-question__head">
                                            <div class="ax-question__index">${loop.index + 1}</div>
                                            <h2 class="ax-question__title">${q.questionText}</h2>
                                        </div>
                                        <div class="ax-answer-grid">
                                            <label class="ax-answer-card">
                                                <input type="radio" name="q_${q.questionId}" value="A" required>
                                                <span class="ax-answer-card__bullet"></span>
                                                <span class="ax-answer-card__label">A</span>
                                                <span class="ax-answer-card__text">${q.optionA}</span>
                                            </label>
                                            <label class="ax-answer-card">
                                                <input type="radio" name="q_${q.questionId}" value="B" required>
                                                <span class="ax-answer-card__bullet"></span>
                                                <span class="ax-answer-card__label">B</span>
                                                <span class="ax-answer-card__text">${q.optionB}</span>
                                            </label>
                                            <label class="ax-answer-card">
                                                <input type="radio" name="q_${q.questionId}" value="C" required>
                                                <span class="ax-answer-card__bullet"></span>
                                                <span class="ax-answer-card__label">C</span>
                                                <span class="ax-answer-card__text">${q.optionC}</span>
                                            </label>
                                            <label class="ax-answer-card">
                                                <input type="radio" name="q_${q.questionId}" value="D" required>
                                                <span class="ax-answer-card__bullet"></span>
                                                <span class="ax-answer-card__label">D</span>
                                                <span class="ax-answer-card__text">${q.optionD}</span>
                                            </label>
                                        </div>
                                    </article>
                                </c:forEach>

                                <div class="ax-sticky-bar">
                                    <div class="ax-sticky-bar__summary">
                                        <strong style="color: var(--ax-heading);">Submit when your answers are ready</strong>
                                        <span style="color: var(--ax-muted);">The button locks and shows a grading state immediately after submission.</span>
                                    </div>
                                    <div class="ax-actions">
                                        <button type="button" class="ax-btn ax-btn--secondary" data-prev-question>
                                            <i class="fas fa-arrow-left"></i>
                                            <span>Previous</span>
                                        </button>
                                        <button type="button" class="ax-btn ax-btn--secondary" data-next-question>
                                            <span>Next</span>
                                            <i class="fas fa-arrow-right"></i>
                                        </button>
                                        <button type="button" class="ax-btn ax-btn--danger" data-exit-attempt>
                                            <i class="fas fa-door-open"></i>
                                            <span>Save & Exit</span>
                                        </button>
                                        <button type="submit"
                                                class="ax-btn ax-btn--primary"
                                                data-submit-button>
                                            <i class="fas fa-paper-plane"></i>
                                            <span>Submit Assessment</span>
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </section>

                        <aside class="ax-side-panel">
                            <h2 class="ax-side-panel__title">Assessment Snapshot</h2>
                            <p class="ax-side-panel__copy">Keep an eye on timing, completion, and attempt context while you work.</p>
                            <div class="ax-review-list" style="margin-top: 20px;">
                                <div class="ax-inline-card">
                                    <i class="fas fa-clock"></i>
                                    <div>
                                        <span>Time Limit</span>
                                        <strong>${assessment.duration != null ? assessment.duration : '--'}${assessment.duration != null ? ' min' : ''}</strong>
                                    </div>
                                </div>
                                <div class="ax-inline-card">
                                    <i class="fas fa-list-check"></i>
                                    <div>
                                        <span>Questions</span>
                                        <strong>${questions.size()}</strong>
                                    </div>
                                </div>
                                <div class="ax-inline-card">
                                    <i class="fas fa-repeat"></i>
                                    <div>
                                        <span>Attempt</span>
                                        <strong>${usedAttempts + 1} of ${allowedAttempts}</strong>
                                    </div>
                                </div>
                                <div class="ax-inline-card">
                                    <i class="fas fa-bullseye"></i>
                                    <div>
                                        <span>Passing Score</span>
                                        <strong>70%</strong>
                                    </div>
                                </div>
                            </div>
                        </aside>
                    </div>
                </c:when>

                <c:otherwise>
                    <article class="ax-frame ax-overview">
                        <span class="ax-overview__eyebrow"><i class="fas fa-folder-open"></i> Submission Workspace</span>
                        <h2 class="ax-focus__title" style="font-size: clamp(1.8rem, 3vw, 2.5rem);">${assessment.title}</h2>
                        <p class="ax-focus__body">Use the upgraded upload area and written-answer panel below. Everything still posts through the current submission endpoint and payload.</p>

                        <c:if test="${not empty questions}">
                            <div class="ax-review-list" style="margin-top: 22px;">
                                <c:forEach var="q" items="${questions}" varStatus="loop">
                                    <div class="ax-inline-card">
                                        <i class="fas fa-book-open"></i>
                                        <div>
                                            <span>Prompt ${loop.index + 1}</span>
                                            <strong>${q.questionText}</strong>
                                            <c:if test="${not empty q.attachmentUrl}">
                                                <div style="margin-top: 10px;">
                                                    <a class="ax-btn ax-btn--secondary" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                                        <i class="fas fa-file-pdf"></i>
                                                        <span>Open PDF Brief</span>
                                                    </a>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>

                        <form method="post"
                              action="${pageContext.request.contextPath}/student/assessments"
                              enctype="multipart/form-data"
                              data-loading-submit
                              style="display: grid; gap: 24px; margin-top: 24px;">
                            <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                            <div class="ax-composer__grid">
                                <div class="ax-panel" style="padding: 22px;">
                                    <span class="ax-section-label"><i class="fas fa-cloud-arrow-up"></i> Upload Zone</span>
                                    <div class="ax-upload-zone" data-upload-zone style="margin-top: 16px;">
                                        <input name="answerFile" type="file">
                                        <div class="ax-upload-zone__icon"><i class="fas fa-file-arrow-up"></i></div>
                                        <h3 class="ax-upload-zone__title">Drop your PDF or supporting files here</h3>
                                        <p class="ax-upload-zone__copy">Accepted formats include PDF, DOC, DOCX, PPT, PPTX, ZIP, and image files. Maximum file size: 50MB.</p>
                                    </div>
                                    <div class="ax-file-list" data-file-list style="margin-top: 14px;"></div>
                                </div>

                                <div class="ax-panel" style="padding: 22px;">
                                    <span class="ax-section-label"><i class="fas fa-pen"></i> Written Answer</span>
                                    <div style="margin-top: 16px;">
                                        <textarea class="ax-textarea" name="answerText" maxlength="255" placeholder="Write a concise response if this assessment accepts text input."></textarea>
                                    </div>
                                    <div class="ax-field-meta">
                                        <span>Clean writing area with the existing plain-text payload.</span>
                                        <span>255 character limit</span>
                                    </div>
                                </div>
                            </div>

                            <div class="ax-sticky-bar">
                                <div class="ax-sticky-bar__summary">
                                    <strong style="color: var(--ax-heading);">Ready to submit?</strong>
                                    <span style="color: var(--ax-muted);">Submission will lock and show a loading state immediately.</span>
                                </div>
                                <div class="ax-actions">
                                    <a class="ax-btn ax-btn--secondary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                                        <i class="fas fa-arrow-left"></i>
                                        <span>Back</span>
                                    </a>
                                    <button type="submit"
                                            class="ax-btn ax-btn--primary"
                                            data-submit-button
                                            data-loading-label="Submitting your work...">
                                        <i class="fas fa-paper-plane"></i>
                                        <span>Submit Assessment</span>
                                    </button>
                                </div>
                            </div>
                        </form>
                    </article>
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
