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
            background: radial-gradient(circle at 15% 10%, #eef4ff 0%, #f7f9fc 35%, #ffffff 100%);
            color: #1f2937;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
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
            border-radius: 14px;
            border: 1px solid #dbe5f2;
            background: linear-gradient(90deg, #0f172a 0%, #1d3557 100%);
            color: #f8fafc;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.18);
        }

        .assessment-focus-title {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
        }

        .assessment-focus-note {
            margin: 2px 0 0;
            font-size: 13px;
            color: rgba(248, 250, 252, 0.82);
        }

        .assessment-focus-lock {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 12px;
            border-radius: 999px;
            background: rgba(248, 250, 252, 0.16);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.02em;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .focus-assessment-card {
            border-radius: 16px;
            border: 1px solid #dbe5f2;
            background: #ffffff;
            box-shadow: 0 16px 36px rgba(15, 23, 42, 0.08);
            padding: 20px;
        }

        .assessment-shell-card {
            border-radius: 18px;
            border: 1px solid #dbe5f2;
            background: linear-gradient(180deg, #ffffff 0%, #f8fbff 100%);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.06);
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
            border-top: 1px solid #dbe5f2;
            flex-wrap: wrap;
        }

        .focus-status {
            font-size: 13px;
            color: #475569;
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
            color: #1e293b;
        }

        .submission-field textarea,
        .submission-field input[type="url"] {
            width: 100%;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 12px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            font-family: inherit;
            background: #fff;
        }

        .submission-field textarea:focus,
        .submission-field input[type="url"]:focus {
            border-color: #1a73e8;
            box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.15);
        }

        .assignment-workspace {
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            background: #ffffff;
            padding: 20px;
            display: grid;
            gap: 16px;
            box-shadow: 0 8px 20px rgba(15, 23, 42, 0.05);
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
            color: #111827;
        }

        .assignment-badge {
            border-radius: 999px;
            padding: 5px 10px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            background: #eaf2ff;
            color: #1e40af;
            letter-spacing: 0.03em;
        }

        .assignment-intro {
            margin: 0;
            color: #475569;
            font-size: 14px;
            line-height: 1.55;
        }

        .assignment-upload-box {
            border: 1px dashed #bfdbfe;
            border-radius: 12px;
            padding: 16px;
            background: #f8fbff;
            display: grid;
            gap: 10px;
        }

        .assignment-upload-box input[type="file"] {
            width: 100%;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 8px;
            background: #fff;
        }

        .assignment-upload-note {
            margin: 0;
            font-size: 12px;
            color: #64748b;
        }

        .assignment-alert {
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 13px;
            font-weight: 600;
        }

        .assignment-alert.error {
            background: #fff1f2;
            border: 1px solid #fecdd3;
            color: #be123c;
        }

        .assignment-alert.success {
            background: #ecfdf3;
            border: 1px solid #a7f3d0;
            color: #047857;
        }

        .assignment-latest {
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            background: #f8fafc;
            padding: 10px 12px;
            font-size: 13px;
            color: #334155;
        }

        .focus-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .sv-btn.alert {
            background: #fff5f5;
            color: #b42318;
            border: 1px solid #fda29b;
        }

        .sv-btn.alert:hover {
            background: #ffeceb;
        }

        .assessment-timer {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 16px;
            background: #f5f5f5;
            border: 2px solid #ccc;
            border-radius: 6px;
            font-weight: 600;
            font-size: 16px;
            font-family: 'Courier New', monospace;
        }

        .assessment-timer.warning {
            background: #fff3cd;
            border-color: #ffc107;
            color: #856404;
        }

        .assessment-timer.critical {
            background: #f8d7da;
            border-color: #dc3545;
            color: #721c24;
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
            border-bottom: 1px solid #e2e8f0;
        }

        .assessment-header-left h3 {
            margin: 0;
            font-size: 26px;
            color: #0f172a;
            letter-spacing: -0.02em;
        }

        .assessment-header-left p {
            margin: 6px 0 0;
            font-size: 14px;
            color: #64748b;
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
            background: #ffffff;
            border: 1px solid #dbe5f2;
            border-radius: 12px;
            padding: 14px 12px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04);
        }

        .metric-label {
            font-size: 12px;
            color: #64748b;
            text-transform: uppercase;
            font-weight: 600;
            margin-bottom: 4px;
            letter-spacing: 0.04em;
        }

        .metric-value {
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
        }

        .material-block-alert {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 16px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: flex;
            gap: 12px;
            align-items: flex-start;
        }

        .material-block-alert i {
            color: #ffc107;
            margin-top: 2px;
            flex-shrink: 0;
        }

        .material-block-alert-content h4 {
            margin: 0 0 6px 0;
            color: #856404;
            font-size: 14px;
        }

        .material-block-alert-content p {
            margin: 0;
            color: #856404;
            font-size: 13px;
            line-height: 1.5;
        }

        .question-container {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 18px;
            margin-bottom: 16px;
            transition: box-shadow 0.2s;
        }

        .question-container:hover {
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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
            background: #1a73e8;
            color: white;
            border-radius: 50%;
            font-weight: 700;
            font-size: 14px;
        }

        .question-header h4 {
            margin: 0;
            font-size: 16px;
            font-weight: 600;
            color: #202124;
            flex: 1;
        }

        .question-text {
            margin: 12px 0;
            font-size: 14px;
            line-height: 1.6;
            color: #202124;
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
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            background: white;
        }

        .option-label:hover {
            border-color: #1a73e8;
            background: #f0f7ff;
        }

        .option-label input[type="radio"] {
            margin: 0;
            cursor: pointer;
            width: 18px;
            height: 18px;
        }

        .option-label input[type="radio"]:checked + span {
            color: #1a73e8;
            font-weight: 600;
        }

        .option-label input[type="radio"]:checked {
            accent-color: #1a73e8;
        }

        .option-text {
            font-size: 14px;
            color: #555;
        }

        .assessment-actions {
            display: flex;
            gap: 12px;
            margin-top: 24px;
            padding-top: 16px;
            border-top: 1px solid #e0e0e0;
        }

        .sv-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-block;
        }

        .sv-btn.primary {
            background: #1a73e8;
            color: white;
        }

        .sv-btn.primary:hover {
            background: #1765cc;
            box-shadow: 0 2px 8px rgba(26, 115, 232, 0.3);
        }

        .sv-btn.primary:disabled {
            background: #ccc;
            color: #999;
            cursor: not-allowed;
            box-shadow: none;
        }

        .sv-btn:not(.primary) {
            background: #f0f0f0;
            color: #202124;
            border: 1px solid #dadce0;
        }

        .sv-btn:not(.primary):hover {
            background: #e8e8e8;
        }

        .instructions-box {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            padding: 13px 14px;
            margin-bottom: 16px;
            border-radius: 10px;
            font-size: 13px;
            color: #1d4ed8;
            line-height: 1.6;
        }

        .attempt-cta-card {
            border: 1px solid #dbe5f2;
            border-radius: 14px;
            background: #ffffff;
            padding: 16px;
            margin-bottom: 8px;
        }

        .attempt-cta-card p {
            color: #475569;
            margin: 0 0 14px;
            font-size: 14px;
        }

        .no-attempt-card {
            border-radius: 14px;
            border: 1px solid #fecaca;
            background: linear-gradient(180deg, #fff5f5 0%, #fff1f2 100%);
            color: #9f1239;
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
            border-top: 1px solid #e2e8f0;
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
            background: #fff3cd;
            color: #856404;
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
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-module.css">
</head>
<body class="${attemptMode ? 'assessment-focus-page' : 'sv-page'}">
<c:set var="topbarTitle" value="Assessment Workspace"/>
<c:set var="topbarSubtitle" value="Complete your assessment"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="course"/>
<c:set var="navContextPage" value="assessments"/>
<c:set var="navCourseEnrollmentId" value="${enrollment.enrollmentId}"/>
<c:set var="navCourseTitle" value="${enrollment.courseName}"/>
<c:if test="${not attemptMode}">
    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>
</c:if>

<c:if test="${not attemptMode}">
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
                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?courseId=${assessment.courseId}&assessmentId=${assessment.assessmentId}&mode=attempt&enrollmentId=${enrollment.enrollmentId}" style="text-decoration: none;">
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

                                    <form method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" style="display:grid; gap:14px;">
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
                <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                    <i class="fas fa-arrow-left"></i> Back to Assessment List
                </a>
            </div>
            </div>
        </section>
    </main>
</div>
</c:if>

<c:if test="${attemptMode}">
    <div class="assessment-focus-shell">
        <div class="assessment-focus-topbar">
            <div>
                <h1 class="assessment-focus-title">${assessment.title}</h1>
            </div>
            <div class="assessment-focus-lock">
                <i class="fas fa-shield-alt"></i>
                Secure Attempt Mode
            </div>
        </div>

        <section class="focus-assessment-card">
            <!-- Assessment Header -->
            <div class="assessment-header" style="margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #e0e0e0;">
                <div class="assessment-header-left">
                    <h3>${assessment.title}</h3>
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
                    <div class="metric-label">Questions</div>
                    <div class="metric-value">${questions.size()}</div>
                </div>
            </div>

            <c:if test="${not empty displayInstructions}">
                <div class="instructions-box">
                    <i class="fas fa-info-circle" style="margin-right: 6px;"></i>
                    <strong>Instructions:</strong> ${displayInstructions}
                </div>
            </c:if>

            <form method="post" id="assessmentForm" action="${pageContext.request.contextPath}/student/assessments" style="display: grid; gap: 16px;">
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
                const shouldExit = window.confirm('Exit now? Your current attempt will be submitted immediately.');
                if (!shouldExit) {
                    return;
                }
                isSubmitting = true;
                exitSubmissionField.value = '1';
                submitWithoutValidation('Submitting...');
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
