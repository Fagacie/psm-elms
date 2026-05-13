<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessment Workspace - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <style>
        .assessment-focus-page {
            margin: 0;
            min-height: 100vh;
            background: var(--sv-bg);
            background-image: var(--sv-bg-accent);
            color: var(--sv-text);
            font-family: "Manrope", "Segoe UI", sans-serif;
        }

        .assessment-focus-shell {
            max-width: 1080px;
            margin: 0 auto;
            padding: 20px 16px 36px;
        }

        .assessment-focus-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 16px;
            padding: 14px 16px;
            border-radius: 8px;
            border: 1px solid var(--sv-border);
            background: var(--sv-surface);
            color: var(--sv-heading);
            box-shadow: var(--sv-shadow-sm);
        }

        .assessment-focus-title {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
        }

        .assessment-focus-note {
            margin: 2px 0 0;
            font-size: 13px;
            color: var(--sv-muted);
        }

        .assessment-focus-lock {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 12px;
            border-radius: 999px;
            background: var(--sv-accent-soft);
            color: var(--sv-accent);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.02em;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .focus-assessment-card {
            border-radius: 8px;
            border: 1px solid var(--sv-border);
            background: var(--sv-surface);
            box-shadow: var(--sv-shadow-sm);
            padding: 20px;
        }

        .assessment-shell-card {
            border-radius: 8px;
            border: 1px solid var(--sv-border);
            background: var(--sv-surface);
            box-shadow: var(--sv-shadow-sm);
        }

        .assessment-shell-body {
            padding: 22px;
        }

        .focus-controls {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-top: 18px;
            padding-top: 14px;
            border-top: 1px solid var(--sv-border);
            flex-wrap: wrap;
        }

        .focus-status {
            font-size: 13px;
            color: var(--sv-muted);
        }

        .submission-panel {
            display: grid;
            gap: 14px;
        }

        .submission-field {
            display: grid;
            gap: 8px;
        }

        .submission-field label {
            font-size: 13px;
            font-weight: 700;
            color: var(--sv-heading);
        }

        .submission-field textarea,
        .submission-field input[type="url"] {
            width: 100%;
            border: 1px solid var(--sv-border);
            border-radius: 6px;
            padding: 12px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            font-family: inherit;
            background: var(--sv-surface-soft);
            color: var(--sv-text);
        }

        .submission-field textarea:focus,
        .submission-field input[type="url"]:focus {
            border-color: var(--sv-accent-border);
            box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.12);
        }

        .assignment-workspace {
            border: 1px solid var(--sv-border);
            border-radius: 8px;
            background: var(--sv-surface);
            padding: 20px;
            display: grid;
            gap: 16px;
            box-shadow: var(--sv-shadow-sm);
        }

        .assignment-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        .assignment-head h4 {
            margin: 0;
            font-size: 18px;
            color: var(--sv-heading);
        }

        .assignment-badge {
            border-radius: 999px;
            padding: 5px 10px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            background: var(--sv-accent-soft);
            color: var(--sv-accent);
            letter-spacing: 0.03em;
        }

        .assignment-intro {
            margin: 0;
            color: var(--sv-muted);
            font-size: 14px;
            line-height: 1.55;
        }

        .assignment-upload-box {
            border: 1px dashed var(--sv-accent-border);
            border-radius: 8px;
            padding: 16px;
            background: var(--sv-surface-soft);
            display: grid;
            gap: 10px;
        }

        .assignment-upload-box input[type="file"] {
            width: 100%;
            border: 1px solid var(--sv-border);
            border-radius: 6px;
            padding: 8px;
            background: var(--sv-surface-soft);
            color: var(--sv-text);
        }

        .assignment-upload-note {
            margin: 0;
            font-size: 12px;
            color: var(--sv-muted);
        }

        .assignment-alert {
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 13px;
            font-weight: 600;
        }

        .assignment-alert.error {
            background: rgba(239, 68, 68, 0.08);
            border: 1px solid rgba(239, 68, 68, 0.16);
            color: #b91c1c;
        }

        .assignment-alert.success {
            background: rgba(34, 197, 94, 0.08);
            border: 1px solid rgba(34, 197, 94, 0.16);
            color: #166534;
        }

        .assignment-latest {
            border: 1px solid var(--sv-border);
            border-radius: 6px;
            background: var(--sv-surface-soft);
            padding: 10px 12px;
            font-size: 13px;
            color: var(--sv-text);
        }

        .focus-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .sv-btn.alert {
            background: rgba(239, 68, 68, 0.08);
            color: #b42318;
            border: 1px solid rgba(239, 68, 68, 0.18);
        }

        .sv-btn.alert:hover {
            background: rgba(239, 68, 68, 0.12);
        }

        .assessment-timer {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 16px;
            background: var(--sv-surface-soft);
            border: 1px solid var(--sv-border);
            border-radius: 6px;
            font-weight: 600;
            font-size: 16px;
            font-family: 'Courier New', monospace;
            color: var(--sv-heading);
        }

        .assessment-timer.warning {
            background: rgba(245, 158, 11, 0.12);
            border-color: rgba(245, 158, 11, 0.22);
            color: #92400e;
        }

        .assessment-timer.critical {
            background: rgba(239, 68, 68, 0.12);
            border-color: rgba(239, 68, 68, 0.22);
            color: #b91c1c;
            animation: pulse 1s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }

        .assessment-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 1px solid var(--sv-border);
        }

        .assessment-header-left h3 {
            margin: 0;
            font-size: 22px;
            color: var(--sv-heading);
            letter-spacing: -0.02em;
        }

        .assessment-header-left p {
            margin: 6px 0 0;
            font-size: 14px;
            color: var(--sv-muted);
        }

        .assessment-header-right {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .assessment-metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 12px;
            margin-bottom: 20px;
        }

        .metric-card {
            background: var(--sv-surface-soft);
            border: 1px solid var(--sv-border);
            border-radius: 6px;
            padding: 14px 12px;
            text-align: center;
            box-shadow: none;
        }

        .metric-label {
            font-size: 12px;
            color: var(--sv-muted);
            text-transform: uppercase;
            font-weight: 600;
            margin-bottom: 4px;
            letter-spacing: 0.04em;
        }

        .metric-value {
            font-size: 18px;
            font-weight: 700;
            color: var(--sv-heading);
        }

        .material-block-alert {
            background: rgba(245, 158, 11, 0.1);
            border: 1px solid rgba(245, 158, 11, 0.2);
            border-left: 4px solid #f59e0b;
            padding: 16px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: flex;
            gap: 12px;
            align-items: flex-start;
        }

        .material-block-alert i {
            color: #d97706;
            margin-top: 2px;
            flex-shrink: 0;
        }

        .material-block-alert-content h4 {
            margin: 0 0 6px 0;
            color: #92400e;
            font-size: 14px;
        }

        .material-block-alert-content p {
            margin: 0;
            color: #92400e;
            font-size: 13px;
            line-height: 1.5;
        }

        .question-container {
            background: var(--sv-surface);
            border: 1px solid var(--sv-border);
            border-radius: 8px;
            padding: 18px;
            margin-bottom: 16px;
            transition: box-shadow 0.2s, transform 0.2s;
        }

        .question-container:hover {
            box-shadow: var(--sv-shadow-sm);
            transform: translateY(-1px);
        }

        .question-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
        }

        .question-number {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            background: var(--sv-accent);
            color: white;
            border-radius: 50%;
            font-weight: 700;
            font-size: 14px;
        }

        .question-header h4 {
            margin: 0;
            font-size: 16px;
            font-weight: 600;
            color: var(--sv-heading);
            flex: 1;
        }

        .question-text {
            margin: 12px 0;
            font-size: 14px;
            line-height: 1.6;
            color: var(--sv-text);
        }

        .question-options {
            display: grid;
            gap: 10px;
            margin-top: 12px;
        }

        .option-label {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            border: 1px solid var(--sv-border);
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            background: var(--sv-surface-soft);
            color: var(--sv-text);
        }

        .option-label:hover {
            border-color: var(--sv-accent-border);
            background: var(--sv-accent-soft);
        }

        .option-label input[type="radio"] {
            margin: 0;
            cursor: pointer;
            width: 18px;
            height: 18px;
        }

        .option-label input[type="radio"]:checked + span {
            color: var(--sv-accent);
            font-weight: 600;
        }

        .option-label input[type="radio"]:checked {
            accent-color: var(--sv-accent);
        }

        .option-text {
            font-size: 14px;
            color: var(--sv-text);
        }

        .assessment-actions {
            display: flex;
            gap: 12px;
            margin-top: 24px;
            padding-top: 16px;
            border-top: 1px solid var(--sv-border);
        }

        .sv-btn {
            padding: 10px 20px;
            border: 1px solid transparent;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-block;
        }

        .sv-btn.primary {
            background: var(--sv-accent);
            color: white;
        }

        .sv-btn.primary:hover {
            background: var(--sv-accent-strong);
            box-shadow: 0 2px 8px rgba(34, 197, 94, 0.18);
        }

        .sv-btn.primary:disabled {
            background: #d1d5db;
            color: #6b7280;
            cursor: not-allowed;
            box-shadow: none;
        }

        .sv-btn:not(.primary) {
            background: var(--sv-surface-soft);
            color: var(--sv-text);
            border: 1px solid var(--sv-border);
        }

        .sv-btn:not(.primary):hover {
            background: var(--sv-accent-soft);
        }

        .instructions-box {
            background: var(--sv-accent-soft);
            border: 1px solid var(--sv-accent-border);
            padding: 13px 14px;
            margin-bottom: 16px;
            border-radius: 6px;
            font-size: 13px;
            color: var(--sv-accent);
            line-height: 1.6;
        }

        .attempt-cta-card {
            border: 1px solid var(--sv-border);
            border-radius: 8px;
            background: #ffffff;
            padding: 16px;
            margin-bottom: 8px;
            box-shadow: var(--sv-shadow-sm);
        }

        .attempt-cta-card p {
            color: var(--sv-muted);
            margin: 0 0 14px;
            font-size: 14px;
        }

        .no-attempt-card {
            border-radius: 8px;
            border: 1px solid rgba(239, 68, 68, 0.16);
            background: rgba(239, 68, 68, 0.08);
            color: #b91c1c;
            padding: 14px 15px;
            margin-bottom: 10px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
        }

        .assessment-footer-nav {
            margin-top: 16px;
            padding-top: 14px;
            border-top: 1px solid var(--sv-border);
        }

        .timer-container {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }

        .time-warning {
            font-size: 12px;
            padding: 4px 8px;
            border-radius: 4px;
            background: rgba(245, 158, 11, 0.12);
            color: #92400e;
            display: none;
        }

        .time-warning.show {
            display: block;
        }

        @media (max-width: 760px) {
            .assessment-shell-body {
                padding: 16px;
            }

            .assessment-header {
                flex-direction: column;
                align-items: stretch;
            }

            .assessment-header-right {
                justify-content: flex-start;
            }

            .assessment-focus-topbar {
                flex-direction: column;
                align-items: flex-start;
            }
        }

        /* Enforce subtle rounded system globally on this page */
        * {
            border-radius: 6px !important;
            box-shadow: none !important;
            text-shadow: none !important;
        }

        /* Protect perfect circular elements (radio selections) */
        input[type="radio"],
        input[type="checkbox"],
        .fa-circle-check,
        .fa-circle-xmark {
            border-radius: 50% !important;
        }
    </style>
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
<c:set var="isEmbedded" value="${param.embed == 'true' || param.iframe == 'true'}"/>
<body class="${attemptMode ? 'assessment-focus-page' : (isEmbedded ? 'sv-page sv-page-embedded' : 'sv-page')}">
<c:set var="topbarTitle" value="Assessment Workspace"/>
<c:set var="topbarSubtitle" value="Complete your assessment"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="course"/>
<c:set var="navContextPage" value="assessments"/>
<c:set var="navCourseEnrollmentId" value="${enrollment.enrollmentId}"/>
<c:set var="navCourseTitle" value="${enrollment.courseName}"/>

<c:if test="${not attemptMode and not isEmbedded}">
    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>
</c:if>

<c:if test="${not attemptMode}">
    <c:choose>
        <c:when test="${isEmbedded}">
            <main class="sv-main" style="margin: 0 !important; padding: 12px !important; background: transparent !important;">
                <section class="sv-card assessment-shell-card" style="box-shadow: none !important; border: 1px solid var(--sv-border);">
                    <div class="assessment-shell-body" style="padding: 16px !important;">
        </c:when>
        <c:otherwise>
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
                        <span>${assessment.title}</span>
                    </div>

                    <section class="sv-card assessment-shell-card">
                        <div class="assessment-shell-body">
        </c:otherwise>
    </c:choose>

            <!-- Assessment Header -->
            <div class="assessment-header">
                <div class="assessment-header-left">
                    <h3>${assessment.title}</h3>
                    <p><c:out value="${objectiveAssessment ? 'Objective assessment with secure attempt mode.' : 'Assignment submission with guided upload workflow.'}"/></p>
                </div>
                <div class="assessment-header-right">
                    <c:if test="${attemptMode}">
                        <div class="timer-container">
                            <div class="assessment-timer" id="timerDisplay">
                                <i class="fas fa-hourglass-end"></i>
                                <span id="timerText">00:00</span>
                            </div>
                            <div class="time-warning" id="timeWarning">
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Metrics -->
            <div class="assessment-metrics">
                <div class="metric-card">
                    <div class="metric-label">Type</div>
                    <div class="metric-value">${assessment.type}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Duration</div>
                    <div class="metric-value">${assessment.duration != null ? assessment.duration : '-'}${assessment.duration != null ? ' min' : ''}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Attempts</div>
                    <div class="metric-value">${usedAttempts} / ${allowedAttempts}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label"><c:out value="${objectiveAssessment ? 'Questions' : 'Submission'}"/></div>
                    <div class="metric-value">
                        <c:choose>
                            <c:when test="${objectiveAssessment}">${questions.size()}</c:when>
                            <c:when test="${submissionMode == 'file'}">File</c:when>
                            <c:when test="${submissionMode == 'text'}">Text</c:when>
                            <c:otherwise>File + Text</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Material Block Alert -->
            <c:if test="${not empty materialBlockReason}">
                <div class="material-block-alert">
                    <i class="fas fa-lock"></i>
                    <div class="material-block-alert-content">
                        <h4>Assessment Locked</h4>
                        <p>${materialBlockReason}</p>
                        <c:if test="${not empty prerequisiteMaterial}">
                            <p style="margin-top: 8px;">
                                <strong>Required Material:</strong> ${prerequisiteMaterial.title}
                            </p>
                        </c:if>
                    </div>
                </div>
            </c:if>

            <!-- Instructions -->
            <c:if test="${not empty displayInstructions}">
                <div class="instructions-box">
                    <i class="fas fa-info-circle" style="margin-right: 6px;"></i>
                    <strong>Instructions:</strong> ${displayInstructions}
                </div>
            </c:if>

            <!-- Details Mode -->
            <c:if test="${not attemptMode}">
                <div style="padding: 20px 0;">
                    <c:if test="${canAttempt}">
                        <c:choose>
                            <c:when test="${objectiveAssessment}">
                                <div class="attempt-cta-card">
                                    <p>Ready to take this assessment? You have <strong>${remainingAttempts} attempt(s)</strong> remaining.</p>
                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?courseId=${assessment.courseId}&assessmentId=${assessment.assessmentId}&mode=attempt&enrollmentId=${enrollment.enrollmentId}${isEmbedded ? '&embed=true' : ''}" style="text-decoration: none;">
                                        <i class="fas fa-play"></i>&nbsp;Open Secure Attempt
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="assignment-workspace">
                                    <div class="assignment-head">
                                        <h4>Submit Assignment</h4>
                                        <span class="assignment-badge">File Upload</span>
                                    </div>
                                    <c:if test="${not empty questions}">
                                        <div style="display:grid; gap: 10px;">
                                            <c:forEach var="q" items="${questions}" varStatus="loop">
                                                <div class="assignment-latest">
                                                    <strong>Prompt ${loop.index + 1}:</strong> ${q.questionText}
                                                    <c:if test="${not empty q.attachmentUrl}">
                                                        <div style="margin-top: 8px;">
                                                            <a class="sv-btn" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                                                <i class="fas fa-file-pdf"></i> Open PDF Brief
                                                            </a>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                    <p class="assignment-intro">Upload your completed assignment file below. Text responses are not required for this assessment.</p>

                                    <c:if test="${param.success == 'submitted'}">
                                        <div class="assignment-alert success">Assignment submitted successfully.</div>
                                    </c:if>
                                    <c:if test="${param.error == 'missingAnswerFile'}">
                                        <div class="assignment-alert error">Please upload a file to submit this assignment.</div>
                                    </c:if>
                                    <c:if test="${param.error == 'assignmentFileTooLarge'}">
                                        <div class="assignment-alert error">Uploaded file is too large. Maximum allowed file size is 50MB.</div>
                                    </c:if>
                                    <c:if test="${param.error == 'assignmentUploadFailed'}">
                                        <div class="assignment-alert error">File upload failed. Please try again.</div>
                                    </c:if>

                                    <c:if test="${not empty latestSubmission}">
                                        <div class="assignment-latest">
                                            Latest submission: ${latestSubmission.status} on ${latestSubmission.submitDate}
                                        </div>
                                    </c:if>

                                    <form method="post" target="_parent" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" style="display:grid; gap:14px;">
                                        <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                                        <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                        <div class="assignment-upload-box">
                                            <label for="answerFileInline"><strong>Upload Assignment File</strong></label>
                                            <input id="answerFileInline" name="answerFile" type="file" required>
                                            <p class="assignment-upload-note">Accepted formats include PDF, DOC, DOCX, PPT, PPTX, ZIP, and image files. Maximum file size: 50MB.</p>
                                        </div>

                                        <div class="assessment-actions" style="margin-top: 8px;">
                                            <button class="sv-btn primary" type="submit">
                                                <i class="fas fa-upload"></i>&nbsp;Submit Assignment
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <c:if test="${not canAttempt and empty materialBlockReason}">
                        <div class="no-attempt-card">
                            <i class="fas fa-times-circle"></i>
                            <span>No attempts remaining for this assessment.</span>
                        </div>
                    </c:if>
                </div>
            </c:if>

            <div class="assessment-footer-nav">
                <a class="sv-btn" target="_parent" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                    <i class="fas fa-arrow-left"></i> Back to Assessment List
                </a>
            </div>
            </div>
        </section>
    </main>
    <c:if test="${not isEmbedded}">
        </div>
    </c:if>
</c:if>

<c:if test="${attemptMode}">
    <div class="assessment-focus-shell" style="${isEmbedded ? 'padding: 0 !important; max-width: 100% !important; margin: 0 !important;' : ''}">
        <c:if test="${not isEmbedded}">
            <div class="assessment-focus-topbar">
                <div>
                    <h1 class="assessment-focus-title">${assessment.title}</h1>
                </div>
                <div class="assessment-focus-lock">
                    <i class="fas fa-shield-alt"></i>
                    Secure Attempt Mode
                </div>
            </div>
        </c:if>

        <section class="focus-assessment-card" style="${isEmbedded ? 'box-shadow: none !important; border: 1px solid var(--sv-border) !important; background: rgba(30, 41, 59, 0.4) !important; padding: 16px !important;' : ''}">
            <!-- Assessment Header -->
            <div class="assessment-header" style="margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #e0e0e0;">
                <div class="assessment-header-left">
                    <h3 style="margin: 0;">${assessment.title}</h3>
                </div>
                <div class="assessment-header-right">
                    <div class="timer-container">
                        <div class="assessment-timer" id="timerDisplay">
                            <i class="fas fa-hourglass-end"></i>
                            <span id="timerText">00:00</span>
                        </div>
                        <div class="time-warning" id="timeWarning">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                    </div>
                </div>
            </div>

            <form method="post" id="assessmentForm" target="_parent" action="${pageContext.request.contextPath}/student/assessments" style="display: grid; gap: 16px;">
                <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                <input type="hidden" name="timerStart" id="timerStart" value="${timerStartTime}">
                <input type="hidden" name="timerDuration" id="timerDuration" value="${timerDurationSeconds}">
                <input type="hidden" name="exitSubmission" id="exitSubmission" value="0">

                <c:forEach var="q" items="${questions}" varStatus="loop">
                    <div class="question-container">
                        <div class="question-header">
                            <div class="question-number">${loop.index + 1}</div>
                            <h4>${q.questionText}</h4>
                        </div>
                        <div class="question-options" style="margin-left: 44px;">
                            <label class="option-label">
                                <input type="radio" name="q_${q.questionId}" value="A" required>
                                <span class="option-text"><strong>A.</strong> ${q.optionA}</span>
                            </label>
                            <label class="option-label">
                                <input type="radio" name="q_${q.questionId}" value="B" required>
                                <span class="option-text"><strong>B.</strong> ${q.optionB}</span>
                            </label>
                            <label class="option-label">
                                <input type="radio" name="q_${q.questionId}" value="C" required>
                                <span class="option-text"><strong>C.</strong> ${q.optionC}</span>
                            </label>
                            <label class="option-label">
                                <input type="radio" name="q_${q.questionId}" value="D" required>
                                <span class="option-text"><strong>D.</strong> ${q.optionD}</span>
                            </label>
                        </div>
                    </div>
                </c:forEach>

                <div class="focus-controls">
                    <div class="focus-status"></div>
                    <div class="focus-actions">
                        <button class="sv-btn primary" id="submitBtn" type="submit">
                            <i class="fas fa-check"></i>&nbsp;Submit Attempt
                        </button>
                        <button class="sv-btn alert" id="exitAttemptBtn" type="button">
                            <i class="fas fa-sign-out-alt"></i>&nbsp;Exit & Submit
                        </button>
                    </div>
                </div>
            </form>
        </section>
    </div>
</c:if>

<div class="sv-overlay" id="svOverlay"></div>

<script>
    <c:if test="${attemptMode}">
    (function() {
        const timerStartTime = ${timerStartTime};
        const timerDurationSeconds = ${timerDurationSeconds};
        const timerDisplay = document.getElementById('timerDisplay');
        const timerText = document.getElementById('timerText');
        const timeWarning = document.getElementById('timeWarning');
        const submitBtn = document.getElementById('submitBtn');
        const assessmentForm = document.getElementById('assessmentForm');
        const exitSubmissionField = document.getElementById('exitSubmission');
        const exitAttemptBtn = document.getElementById('exitAttemptBtn');

        let isSubmitting = false;

        function submitWithoutValidation(buttonText) {
            isSubmitting = true;
            assessmentForm.setAttribute('novalidate', 'novalidate');
            assessmentForm.querySelectorAll('input[required]').forEach(function (el) {
                el.required = false;
            });
            if (submitBtn) {
                submitBtn.disabled = true;
                if (buttonText) {
                    submitBtn.textContent = buttonText;
                }
            }
            assessmentForm.submit();
        }

        let timerInterval;
        
        function updateTimer() {
            const elapsedMillis = Date.now() - timerStartTime;
            const remainingMillis = (timerDurationSeconds * 1000) - elapsedMillis;
            
            if (remainingMillis <= 0) {
                clearInterval(timerInterval);
                timerText.textContent = '00:00';
                timerDisplay.classList.remove('warning', 'critical');
                timerDisplay.classList.add('critical');
                timeWarning.classList.add('show');
                isSubmitting = true;
                
                // Auto-submit after 2 seconds
                setTimeout(() => {
                    submitWithoutValidation('Time Expired - Auto Submitting...');
                }, 2000);
                return;
            }
            
            const totalSeconds = Math.floor(remainingMillis / 1000);
            const minutes = Math.floor(totalSeconds / 60);
            const seconds = totalSeconds % 60;
            
            timerText.textContent = String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
            
            // Update styling based on time remaining
            timerDisplay.classList.remove('warning', 'critical');
            if (remainingMillis <= 30000) {
                timerDisplay.classList.add('critical');
                timeWarning.classList.add('show');
            } else if (remainingMillis <= 120000) {
                timerDisplay.classList.add('warning');
                timeWarning.classList.remove('show');
            } else {
                timeWarning.classList.remove('show');
            }
        }
        
        // Initial update
        updateTimer();
        
        // Update every 100ms for smooth countdown
        timerInterval = setInterval(updateTimer, 100);
        
        // Prevent accidental navigation and block browser shortcuts that can navigate away.
        window.addEventListener('beforeunload', (e) => {
            if (isSubmitting) {
                return;
            }
            e.preventDefault();
            e.returnValue = 'Assessment in progress. Leaving may end your attempt.';
        });

        document.addEventListener('contextmenu', function (e) { e.preventDefault(); });
        document.addEventListener('keydown', function (e) {
            const blocked = e.key === 'F12'
                || (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J' || e.key === 'C'))
                || (e.ctrlKey && (e.key === 'u' || e.key === 'U'));
            if (blocked) {
                e.preventDefault();
            }
        });

        if (exitAttemptBtn) {
            exitAttemptBtn.addEventListener('click', function () {
                StudentUX.confirm(
                    'Confirm Exit',
                    'Exit now? Your current attempt will be submitted immediately.',
                    function() {
                        isSubmitting = true;
                        exitSubmissionField.value = '1';
                        submitWithoutValidation('Submitting...');
                    }
                );
            });
        }

        assessmentForm.addEventListener('submit', function () {
            isSubmitting = true;
        });
    })();
    </c:if>
</script>

<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
