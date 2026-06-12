<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${enrollment.courseName} - Learning Hub</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
    <%@ include file="/WEB-INF/views/common/theme-bootstrap.jspf" %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AssessmentLayout.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/learning-hub-modern.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/LearningHub.module.css">
    <script defer src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
</head>
<body class="sv-page lh-shell-page"
      data-context-path="${pageContext.request.contextPath}"
      data-progress-percent="${progressPercent}"
      data-material-count="${materialCount}"
      data-current-material-type="${not empty selectedMaterial ? selectedMaterial.materialType : ''}"
      data-current-selection-mode="${selectedMode}"
      data-material-completed="${selectedMaterialStatus == 'completed'}"
      data-course-expired="${courseExpired}">

<div class="hub_container">
    <%-- Minimalist Top Bar (Task 2) --%>
    <header class="hub_topBar" role="banner">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button class="hub_mobileToggle" id="hubMobileToggle" type="button" aria-label="Toggle syllabus sidebar">
                <i class="fas fa-bars"></i>
            </button>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="hub_backBtn" aria-label="Return to My Courses">
                <i class="fas fa-arrow-left" aria-hidden="true"></i>
                <span class="hub_backBtn_text">Back to Dashboard</span>
            </a>
            <h1 class="hub_courseTitle" title="${enrollment.courseName}">${enrollment.courseName}</h1>
        </div>
        <div class="hub_progressContainer" aria-label="Course progress: ${progressPercent}%">
            <span class="hub_progressText" id="lhTopbarPct">${progressPercent}% Modules</span>
            <div class="hub_progressIndicator">
                <div class="hub_progressFill" id="lhTopbarFill" style="width: ${progressPercent}%"></div>
            </div>
            <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false" aria-label="Switch to dark mode" title="Switch to dark mode" style="background: transparent; border: none; color: #64748b; padding: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center;">
                <i class="fas fa-moon" aria-hidden="true"></i>
            </button>
        </div>
    </header>

    <div class="hub_mobileOverlay" id="hubMobileOverlay"></div>

    <%-- Split View (Task 3) --%>
    <div class="hub_splitView">
        <%-- Sidebar Syllabus UI (Task 4) --%>
        <aside class="hub_sidebar" id="svSidebar" aria-label="Course syllabus">
            <div class="hub_sidebarHeader">
                <h2 class="hub_sidebarTitle">Course Content</h2>
                <%-- Hidden legacy elements for JS progress binder backwards compatibility --%>
                <div style="display: none;">
                    <div id="lhSidebarProgressBar" style="width: ${progressPercent}%;"></div>
                    <span id="lhSidebarProgressPercent">${progressPercent}%</span>
                </div>
            </div>
            <div class="hub_syllabusList">
                <c:set var="prevChapterLabel" value=""/>
                <c:forEach var="item" items="${learningItems}" varStatus="loop">
                    <c:if test="${item.groupLabel != prevChapterLabel}">
                        <div class="hub_chapterHeader">${item.groupLabel}</div>
                    </c:if>

                    <a href="${item.navigationUrl}"
                       class="hub_moduleItem lh-chapter-item ${item.active ? 'hub_moduleItemActive is-active' : ''} ${item.completedForProgress ? 'is-completed' : ''}"
                       data-kind="${item.itemKind}"
                       <c:if test="${item.locked}">aria-disabled="true" style="pointer-events: none; opacity: 0.65;"</c:if>>
                        <div class="hub_moduleLeft">
                            <span class="hub_moduleIcon">
                                <c:choose>
                                    <c:when test="${item.itemKind == 'material'}">
                                        <c:choose>
                                            <c:when test="${item.iconClass == 'fa-play-circle'}">
                                                <i class="fas fa-play-circle" style="font-size: 1.1rem;"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-file-text" style="font-size: 1.1rem;"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fas fa-question-circle" style="font-size: 1.1rem;"></i>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                            <div class="hub_moduleText">
                                <span class="hub_moduleTitle">${item.title}</span>
                                <span class="hub_moduleKind">
                                    <c:choose>
                                        <c:when test="${item.completedForProgress}">Completed</c:when>
                                        <c:otherwise>${item.itemKind}</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                        <div class="hub_moduleRight">
                            <button class="hub_completionToggle ${item.completedForProgress ? 'hub_completionToggleComplete' : ''}"
                                    onclick="toggleSidebarMaterial(event, '${item.itemId}', '${enrollment.enrollmentId}', this)"
                                    type="button"
                                    ${item.itemKind == 'assessment' or item.completedForProgress or item.locked ? 'disabled="disabled"' : ''}>
                                <c:choose>
                                    <c:when test="${item.completedForProgress}">
                                        <i class="fas fa-check-circle" style="font-size: 1.1rem;"></i>
                                    </c:when>
                                    <c:when test="${item.locked}">
                                        <i class="fas fa-lock" style="color: #cbd5e1; font-size: 0.85rem;"></i>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="far fa-circle" style="font-size: 1.1rem;"></i>
                                    </c:otherwise>
                                </c:choose>
                            </button>
                        </div>
                    </a>
                    <c:set var="prevChapterLabel" value="${item.groupLabel}"/>
                </c:forEach>
            </div>
        </aside>

        <%-- Main Stage Container (Task 3) --%>
        <main class="hub_stage">
            <div class="hub_stageCanvas">

        <c:if test="${not empty param.error or not empty param.success or not empty param.message}">
            <section class="lh-feedback ${not empty param.error ? 'is-error' : 'is-success'}" aria-live="polite">
                <div class="lh-feedback__icon">
                    <i class="fas fa-${not empty param.error ? 'circle-exclamation' : 'circle-check'}"></i>
                </div>
                <div class="lh-feedback__copy">
                    <p>
                        <c:choose>
                            <c:when test="${param.message == 'freeenrolled'}">
                                <strong>Welcome to your Free Course!</strong>
                                You have successfully enrolled. Dive into the learning materials and assessments below!
                            </c:when>
                            <c:when test="${param.error == 'paymentRequired'}">
                                Access is still locked for this course item.
                            </c:when>
                            <c:when test="${param.error == 'blocked'}">
                                ${not empty param.reason ? param.reason : 'Complete the required learning step before starting this assessment.'}
                            </c:when>
                            <c:when test="${param.error == 'maxAttempts'}">
                                You have already used all allowed attempts for this assessment.
                            </c:when>
                            <c:when test="${param.error == 'noQuestions'}">
                                This assessment is not available yet because no questions have been published.
                            </c:when>
                            <c:when test="${param.error == 'invalidAssessment'}">
                                The selected assessment does not belong to this enrollment.
                            </c:when>
                            <c:when test="${param.error == 'assignmentFileTooLarge'}">
                                The uploaded file exceeds the 50MB size limit. Please upload a smaller file.
                            </c:when>
                            <c:when test="${param.error == 'assignmentUploadFailed'}">
                                File upload failed. Please try again.
                            </c:when>
                            <c:when test="${param.error == 'missingAnswerFile'}">
                                Please upload a file or write a response before submitting.
                            </c:when>
                            <c:when test="${param.error == 'answerTooLong'}">
                                Your response is too long (maximum 255 characters).
                            </c:when>
                            <c:when test="${param.error == 'submitFailed'}">
                                Submission could not be saved. Please try again.
                            </c:when>
                            <c:when test="${param.error == 'expired'}">
                                This course duration has ended. The learning hub is now in read-only mode.
                            </c:when>
                            <c:when test="${param.success == 'submitted'}">
                                Assessment submitted successfully.
                            </c:when>
                            <c:when test="${param.success == 'timed-out'}">
                                Time expired and the attempt was submitted automatically.
                            </c:when>
                            <c:when test="${param.success == 'exited'}">
                                Assessment saved and closed.
                            </c:when>
                            <c:when test="${param.success == 'retakeRequested'}">
                                Your retake request has been submitted successfully and is awaiting instructor approval.
                            </c:when>
                            <c:when test="${param.error == 'retakePending'}">
                                You already have a pending retake request for this assessment.
                            </c:when>
                            <c:when test="${param.error == 'retakeRequestFailed'}">
                                Failed to submit retake request. Please try again.
                            </c:when>
                            <c:otherwise>
                                Learning workspace updated.
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </section>
        </c:if>

        <div class="lh-content-stage">
                <c:choose>
                    <c:when test="${not empty assessmentResultSubmission and not empty assessmentResultAssessment}">
                        <c:set var="assessment" value="${assessmentResultAssessment}"/>
                        <c:set var="submission" value="${assessmentResultSubmission}"/>
                        <c:set var="percentage" value="${assessmentResultPercentage}"/>
                        <c:set var="passedAssessment" value="${not empty submission.score and percentage >= 70}"/>
                        <c:set var="objectiveAssessment" value="${assessmentResultObjective}"/>
                        <c:set var="questions" value="${assessmentResultQuestions}"/>
                        <c:set var="studentAnswerByQuestionId" value="${assessmentResultStudentAnswers}"/>
                        <c:set var="correctAnswerByQuestionId" value="${assessmentResultCorrectAnswers}"/>
                        <c:set var="submissionStatusLabel" value="${assessmentResultStatusLabel}"/>
                        <c:set var="submissionStatusClass" value="${assessmentResultStatusClass}"/>
                        <c:set var="scorePercent" value="${percentage}"/>

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
                    </c:when>
                    <c:when test="${selectedMode == 'overview'}">
                        <section class="lh-overview">
                            <div class="lh-overview__header">
                                <div class="lh-overview__header-left">
                                    <span class="lh-overview__kicker"><i class="fas fa-layer-group"></i> Course Overview</span>
                                    <h2 class="lh-overview__title"><c:out value="${enrollment.courseName}"/></h2>
                                    <c:if test="${not empty enrollment.instructorName}">
                                        <p class="lh-overview__instructor"><i class="fas fa-chalkboard-user"></i> Instructor: <strong><c:out value="${enrollment.instructorName}"/></strong></p>
                                    </c:if>
                                </div>
                                <div class="lh-overview__header-actions">
                                    <a class="sv-btn primary" href="${not empty recommendedItem ? recommendedItem.navigationUrl : pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrollment.enrollmentId).concat('&tab=assessments')}">
                                        <i class="fas fa-play"></i> Continue Learning
                                    </a>
                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=performance">
                                        <i class="fas fa-chart-column"></i> Performance
                                    </a>
                                </div>
                            </div>

                            <div class="lh-overview__description">
                                <c:choose>
                                    <c:when test="${not empty enrollment.courseDescription}"><c:out value="${enrollment.courseDescription}"/></c:when>
                                    <c:otherwise>Your course home for materials, assessments, progress tracking, and performance analytics.</c:otherwise>
                                </c:choose>
                            </div>

                            <div class="lh-overview__stats">
                                <div class="lh-overview__stat">
                                    <div class="lh-overview__stat-icon"><i class="fas fa-chart-line"></i></div>
                                    <div class="lh-overview__stat-data">
                                        <strong>${progressPercent}%</strong>
                                        <span>Progress</span>
                                    </div>
                                </div>
                                <div class="lh-overview__stat">
                                    <div class="lh-overview__stat-icon lh-overview__stat-icon--blue"><i class="fas fa-file-lines"></i></div>
                                    <div class="lh-overview__stat-data">
                                        <strong>${materialCount}</strong>
                                        <span>Materials</span>
                                    </div>
                                </div>
                                <div class="lh-overview__stat">
                                    <div class="lh-overview__stat-icon lh-overview__stat-icon--purple"><i class="fas fa-clipboard-check"></i></div>
                                    <div class="lh-overview__stat-data">
                                        <strong>${assessmentCount}</strong>
                                        <span>Assessments</span>
                                    </div>
                                </div>
                                <c:if test="${not empty courseDuration}">
                                    <div class="lh-overview__stat">
                                        <div class="lh-overview__stat-icon lh-overview__stat-icon--amber"><i class="fas fa-clock"></i></div>
                                        <div class="lh-overview__stat-data">
                                            <strong>${courseDuration}</strong>
                                            <span>Duration</span>
                                        </div>
                                    </div>
                                </c:if>
                            </div>

                            <div class="lh-overview__milestones">
                                <h3 class="lh-overview__section-title">Completion Milestones</h3>
                                <div class="lh-overview__milestone-list">
                                    <div class="lh-overview__milestone ${enrollment.paymentStatus == 'Paid' || enrollment.paymentStatus == 'Free' ? 'is-done' : ''}">
                                        <i class="fas fa-${enrollment.paymentStatus == 'Paid' || enrollment.paymentStatus == 'Free' ? 'circle-check' : 'circle'} lh-overview__milestone-icon"></i>
                                        <div class="lh-overview__milestone-copy">
                                            <strong>Payment</strong>
                                            <span>${enrollment.paymentStatus == 'Paid' ? 'Paid' : (enrollment.paymentStatus == 'Free' ? 'Free Course' : 'Pending')}</span>
                                        </div>
                                    </div>
                                    <div class="lh-overview__milestone ${progressPercent >= 100 ? 'is-done' : ''}">
                                        <i class="fas fa-${progressPercent >= 100 ? 'circle-check' : 'circle'} lh-overview__milestone-icon"></i>
                                        <div class="lh-overview__milestone-copy">
                                            <strong>Materials</strong>
                                            <span>${progressPercent >= 100 ? 'All viewed' : progressPercent.concat('% complete')}</span>
                                        </div>
                                    </div>
                                    <div class="lh-overview__milestone ${enrollment.completionStatus == 'Completed' ? 'is-done' : ''}">
                                        <i class="fas fa-${enrollment.completionStatus == 'Completed' ? 'circle-check' : 'circle'} lh-overview__milestone-icon"></i>
                                        <div class="lh-overview__milestone-copy">
                                            <strong>Course Completion</strong>
                                            <span>${enrollment.completionStatus}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <%-- Certificate Claim Card in Overview --%>
                            <c:if test="${enrollment.coursePrice > 0}">
                                <div class="lh-overview__section">
                                    <h3 class="lh-overview__section-title"><i class="fas fa-certificate"></i> Course Certificate</h3>
                                    <div class="lh-cert-overview-card ${not empty userCertificate ? 'is-earned' : (progressPercent == 100 and overallPerformance >= passingGrade ? 'is-ready' : 'is-locked')}">
                                        <div class="lh-cert-overview-card__content">
                                            <c:choose>
                                                <c:when test="${not empty userCertificate}">
                                                    <div class="lh-status-icon">
                                                        <i class="fas fa-medal"></i>
                                                    </div>
                                                    <div class="lh-status-copy">
                                                        <h4>Credential Issued</h4>
                                                        <p>Congratulations! Your official certificate has been successfully issued for this course.</p>
                                                    </div>
                                                </c:when>
                                                <c:when test="${progressPercent == 100 and overallPerformance >= passingGrade}">
                                                    <div class="lh-status-icon">
                                                        <i class="fas fa-award"></i>
                                                    </div>
                                                    <div class="lh-status-copy">
                                                        <h4>Certificate Unlocked</h4>
                                                        <p>All checkpoints satisfied! You are now eligible to claim your completion credential.</p>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="lh-status-icon">
                                                        <i class="fas fa-lock"></i>
                                                    </div>
                                                    <div class="lh-status-copy">
                                                        <h4>Certificate Locked</h4>
                                                        <p>Complete all lesson materials and achieve at least ${passingGrade}% average performance to unlock.</p>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="lh-cert-overview-card__actions">
                                            <c:choose>
                                                <c:when test="${not empty userCertificate}">
                                                    <a href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${enrollment.enrollmentId}" class="sv-btn primary">
                                                        <i class="fas fa-download"></i> Download Certificate
                                                    </a>
                                                </c:when>
                                                <c:when test="${progressPercent == 100 and overallPerformance >= passingGrade}">
                                                    <form method="post" action="${pageContext.request.contextPath}/student/certificate">
                                                        <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                        <button type="submit" class="sv-btn primary">
                                                            <i class="fas fa-bolt"></i> Generate Certificate
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="tooltipText" value="" />
                                                    <c:choose>
                                                        <c:when test="${progressPercent < 100 and overallPerformance < passingGrade}">
                                                            <c:set var="tooltipText" value="You must complete 100% of materials (current: ${progressPercent}%) and achieve an average score of at least ${passingGrade}% (current: ${overallPerformance}%)." />
                                                        </c:when>
                                                        <c:when test="${progressPercent < 100}">
                                                            <c:set var="tooltipText" value="You must complete 100% of materials (current: ${progressPercent}%)." />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:set var="tooltipText" value="You must achieve an average score of at least ${passingGrade}% (current: ${overallPerformance}%)." />
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <div class="lh-tooltip-container">
                                                        <button class="sv-btn" disabled="disabled" title="${tooltipText}">
                                                            <i class="fas fa-lock"></i> Generate Certificate
                                                        </button>
                                                        <span class="lh-tooltip-bubble">
                                                            ${tooltipText}
                                                        </span>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </section>
                    </c:when>

                    <c:when test="${selectedMode == 'performance'}">
                        <section class="sa-panel lh-performance-shell">
                            <div class="sa-panel-head">
                                <div>
                                    <span class="sa-badge-flat success"><i class="fas fa-chart-column"></i> Performance</span>
                                    <h3>${enrollment.courseName}</h3>
                                </div>
                            </div>

                            <div class="lh-table-scroll">
                                <table class="lh-performance-table">
                                    <thead>
                                        <tr>
                                            <th>Assessment</th>
                                            <th>Attempts</th>
                                            <th>Best Score</th>
                                            <th>Best %</th>
                                            <th>Mastery</th>
                                            <th>Latest Submission</th>
                                            <th>Status</th>
                                            <th>Open</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="assessment" items="${assessments}">
                                            <c:set var="assessmentId" value="${assessment.assessmentId}"/>
                                            <c:set var="bestScore" value="${bestScoreByAssessment[assessmentId]}"/>
                                            <c:set var="bestPercent" value="${bestPercentageByAssessment[assessmentId]}"/>
                                            <c:set var="latestSubmission" value="${latestSubmissionByAssessment[assessmentId]}"/>
                                            <c:set var="usedAttempts" value="${usedAttemptsByAssessment[assessmentId]}"/>
                                            <c:set var="allowedAttempts" value="${allowedAttemptsByAssessment[assessmentId]}"/>
                                            <c:set var="hasActiveAttempt" value="${activeAttemptByAssessment[assessmentId]}"/>
                                            <tr>
                                                <td><strong>${assessment.title}</strong><span class="lh-table-meta">${assessment.type}</span></td>
                                                <td><strong>${usedAttempts} / ${allowedAttempts}</strong></td>
                                                <td><strong><c:choose><c:when test="${not empty bestScore}"><fmt:formatNumber value="${bestScore}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></strong></td>
                                                <td><strong><c:choose><c:when test="${not empty bestPercent}"><fmt:formatNumber value="${bestPercent}" maxFractionDigits="1"/>%</c:when><c:otherwise>--</c:otherwise></c:choose></strong></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 85}"><span class="sa-status status-Approved">Excellent</span></c:when>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 70}"><span class="sa-status">Strong</span></c:when>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 50}"><span class="sa-status status-Pending">Developing</span></c:when>
                                                        <c:otherwise><span class="sa-status status-Archived">Needs Review</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><span class="lh-table-meta"><c:choose><c:when test="${not empty latestSubmission}">${fn:replace(latestSubmission.submitDate, 'T', ' ')}</c:when><c:otherwise>--</c:otherwise></c:choose></span></td>
                                                <td><c:choose><c:when test="${hasActiveAttempt}"><span class="sa-status status-Pending">Active</span></c:when><c:when test="${not empty latestSubmission and not empty latestSubmission.score}"><span class="sa-status status-Approved">Graded</span></c:when><c:when test="${not empty latestSubmission}"><span class="sa-status status-Pending">Awaiting Review</span></c:when><c:otherwise><span class="sa-status status-Archived">Not Started</span></c:otherwise></c:choose></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty latestSubmission}"><a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=result&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&submissionId=${latestSubmission.submissionId}"><i class="fas fa-chart-column"></i> Result</a></c:when>
                                                        <c:otherwise><a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=details&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}"><i class="fas fa-eye"></i> Open</a></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <%-- Certificate Claim Card inside Performance Tab --%>
                            <c:if test="${enrollment.coursePrice > 0}">
                                <div class="lh-cert-performance-card ${not empty userCertificate ? 'is-earned' : (progressPercent == 100 and overallPerformance >= passingGrade ? 'is-ready' : 'is-locked')}">
                                    <c:choose>
                                        <c:when test="${not empty userCertificate}">
                                            <div class="lh-status-icon">
                                                <i class="fas fa-medal"></i>
                                            </div>
                                            <h4 class="lh-overview__section-title">Credential Earned!</h4>
                                            <p>Congratulations! You have completed all syllabus requirements and earned your official certificate.</p>
                                            <div class="lh-cert-performance-card__meta">
                                                <div class="lh-cert-stat">
                                                    <span>Certificate ID</span>
                                                    <strong>${userCertificate.certificateNumber}</strong>
                                                </div>
                                                <div class="lh-cert-stat">
                                                    <span>Issued On</span>
                                                    <strong><fmt:formatDate value="${userCertificate.issueDate}" pattern="MMM dd, yyyy"/></strong>
                                                </div>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${enrollment.enrollmentId}" class="sv-btn primary">
                                                <i class="fas fa-download"></i> Download Certificate
                                            </a>
                                        </c:when>

                                        <c:when test="${progressPercent == 100 and overallPerformance >= passingGrade}">
                                            <div class="lh-status-icon">
                                                <i class="fas fa-award"></i>
                                            </div>
                                            <h4 class="lh-overview__section-title">Certificate Unlocked!</h4>
                                            <p>Excellent work! You have completed all syllabus milestones and satisfied the performance requirements. You can now generate your certificate.</p>
                                            <form method="post" action="${pageContext.request.contextPath}/student/certificate">
                                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                <button type="submit" class="sv-btn primary">
                                                    <i class="fas fa-bolt"></i> Generate Certificate
                                                </button>
                                            </form>
                                        </c:when>

                                        <c:otherwise>
                                            <div class="lh-status-icon">
                                                <i class="fas fa-lock"></i>
                                            </div>
                                            <h4 class="lh-overview__section-title">Course Certificate</h4>
                                            <p>Your completion certificate is currently locked. Complete 100% of course materials and maintain an average grade above ${passingGrade}% to unlock it.</p>
                                            
                                            <c:set var="tooltipText" value="" />
                                            <c:choose>
                                                <c:when test="${progressPercent < 100 and overallPerformance < passingGrade}">
                                                    <c:set var="tooltipText" value="You must complete 100% of materials (current: ${progressPercent}%) and achieve an average score of at least ${passingGrade}% (current: ${overallPerformance}%)." />
                                                </c:when>
                                                <c:when test="${progressPercent < 100}">
                                                    <c:set var="tooltipText" value="You must complete 100% of materials (current: ${progressPercent}%)." />
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="tooltipText" value="You must achieve an average score of at least ${passingGrade}% (current: ${overallPerformance}%)." />
                                                </c:otherwise>
                                            </c:choose>

                                            <div class="lh-tooltip-container">
                                                <button class="sv-btn" disabled="disabled" title="${tooltipText}">
                                                    <i class="fas fa-lock"></i> Generate Certificate
                                                </button>
                                                <span class="lh-tooltip-bubble">
                                                    ${tooltipText}
                                                </span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:if>
                        </section>
                    </c:when>
                    <c:when test="${selectedMode == 'assessment' and not empty selectedAssessment}">
                        <c:set var="totalPoints" value="${selectedAssessmentTotalPossible != null ? selectedAssessmentTotalPossible : ((selectedAssessment.totalMarks != null && selectedAssessment.totalMarks > 0) ? selectedAssessment.totalMarks : (fn:length(selectedAssessmentQuestions) > 0 ? fn:length(selectedAssessmentQuestions) : 1))}"/>
                        <c:set var="isAttempting" value="${(param.attempt == 'true' || selectedAssessmentStatusLabel == 'Active') && selectedAssessment.type != 'Assignment'}"/>
                        <c:choose>
                            <c:when test="${isAttempting}">
                                <section class="container" data-attempt-shell>
                                    <div class="active_assessment_container">
                                        <div class="active_question_header">
                                            <div>
                                                <span style="font-size: 0.875rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;"><i class="fas fa-shield-halved"></i> Active Assessment</span>
                                                <h1 class="title" style="margin-top: 4px; font-size: 1.75rem; text-align: left;">${selectedAssessment.title}</h1>
                                            </div>
                                            <div class="timer_box" data-timer>
                                                <i class="fas fa-clock"></i>
                                                <span data-timer-text>00:00</span>
                                            </div>
                                        </div>

                                        <div class="progress_row">
                                            <span class="progress_text">Question <strong data-current-question>1</strong> of ${fn:length(selectedAssessmentQuestions)}</span>
                                            <span class="progress_text">Progress</span>
                                        </div>
                                        <div class="progress_bar_bg">
                                            <div class="progress_bar_fill" data-progress-fill></div>
                                        </div>

                                        <div class="stepper_row">
                                            <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                <button type="button" class="stepper_item ${loop.first ? 'stepper_item_active' : ''}" data-step-index="${loop.index}">${loop.index + 1}</button>
                                            </c:forEach>
                                        </div>

                                        <form method="post"
                                              action="${pageContext.request.contextPath}/student/assessments"
                                              data-attempt-form
                                              data-timer-start="${selectedAssessmentTimerStartTime}"
                                              data-timer-duration="${selectedAssessmentTimerDurationSeconds}"
                                              class="ax-attempt-form">
                                            <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                            <input type="hidden" name="timerStart" value="${selectedAssessmentTimerStartTime}">
                                            <input type="hidden" name="timerDuration" value="${selectedAssessmentTimerDurationSeconds}">
                                            <input type="hidden" name="exitSubmission" value="0">

                                            <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
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
                                </section>
                            </c:when>
                            <c:otherwise>
                                <c:if test="${not courseAccessGranted}">
                                    <section class="container">
                                        <div class="pre_assessment_container">
                                            <div style="color: #ea580c; font-size: 2.5rem; margin-bottom: 16px;">
                                                <i class="fas fa-lock"></i>
                                            </div>
                                            <h1 class="title">Assessment Locked</h1>
                                            <p class="instructions">Complete course payment first to unlock and start this evaluation milestone.</p>
                                            <div class="submit_action_container">
                                                <c:choose>
                                                    <c:when test="${enrollment.coursePrice > 0}">
                                                        <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${enrollment.courseId}" class="primary_button">Pay Now</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="primary_button" disabled="disabled">Awaiting Approval</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </section>
                                </c:if>

                                <c:if test="${courseAccessGranted and selectedAssessment.type == 'Assignment'}">
                                    <section class="container">
                                        <div class="pre_assessment_container" style="text-align: left; align-items: flex-start; max-width: 700px;">
                                            <h1 class="title">${selectedAssessment.title}</h1>
                                            <p class="instructions" style="margin-bottom: 24px;">Submit and review your assignment materials directly from the learning hub workspace.</p>
                                            
                                            <c:if test="${not empty selectedAssessmentQuestions}">
                                                <div style="width: 100%; margin-bottom: 32px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;">
                                                    <h3 style="font-size: 1.125rem; font-weight: 600; color: #0f172a; margin: 0 0 16px 0; display: flex; align-items: center; gap: 8px;">
                                                        <i class="fas fa-file-signature" style="color: #2563eb;"></i> Assignment Prompt & Tasks
                                                    </h3>
                                                    <div style="display: flex; flex-direction: column; gap: 16px;">
                                                        <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                            <div style="border-bottom: 1px solid #e2e8f0; padding-bottom: 16px; margin-bottom: 0;">
                                                                <strong style="display: block; font-size: 0.875rem; color: #475569; margin-bottom: 4px;">Task ${loop.index + 1}</strong>
                                                                <div style="font-size: 1rem; color: #0f172a; line-height: 1.5;"><c:out value="${q.questionText}"/></div>
                                                                <c:if test="${not empty q.attachmentUrl}">
                                                                    <div style="margin-top: 12px;">
                                                                        <a class="file_download_anchor" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                                                            <i class="fas fa-file-pdf"></i> Open PDF Brief
                                                                        </a>
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <c:choose>
                                                <c:when test="${not empty selectedAssessmentLatest and empty selectedAssessmentLatest.score}">
                                                    <div style="width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; background-color: #f8fafc; display: flex; gap: 20px; align-items: flex-start;">
                                                        <div style="font-size: 2rem; color: #d97706; background-color: #fef3c7; width: 48px; height: 48px; border-radius: 9999px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                                            <i class="fas fa-clock-rotate-left"></i>
                                                        </div>
                                                        <div style="flex-grow: 1;">
                                                            <h4 style="font-size: 1.125rem; font-weight: 600; color: #0f172a; margin: 0 0 8px 0;">Assignment Awaiting Review</h4>
                                                            <p style="color: #475569; margin: 0 0 16px 0; font-size: 0.9375rem; line-height: 1.5;">Your work has been submitted successfully and is currently awaiting grading by your instructor. You do not need to upload anything again.</p>
                                                            <div style="display: flex; flex-direction: column; gap: 8px; font-size: 0.875rem; color: #64748b;">
                                                                <div>
                                                                    <i class="fas fa-file-alt" style="margin-right: 6px;"></i> Submitted File:
                                                                </div>
                                                                <c:choose>
                                                                    <c:when test="${not empty selectedAssessmentLatest.answersFilePath}">
                                                                        <div style="margin-top: 4px;">
                                                                            <a href="${fn:escapeXml(selectedAssessmentLatest.answersFilePath)}" target="_blank" class="file_download_anchor" style="margin: 0; display: inline-flex;">
                                                                                Download Submitted File <i class="fas fa-arrow-up-right-from-square" style="font-size: 0.75rem; margin-left: 6px;"></i>
                                                                            </a>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div style="color: #94a3b8; margin-top: 4px;">No attachment path found</div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <div>
                                                                    <i class="fas fa-calendar-day" style="margin-right: 6px;"></i> Submitted On: 
                                                                    <strong>${fn:replace(selectedAssessmentLatest.submitDate, 'T', ' ')}</strong>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:when>

                                                <c:when test="${not empty selectedAssessmentLatest and not empty selectedAssessmentLatest.score}">
                                                    <c:set var="passThreshold" value="${totalPoints * 0.7}"/>
                                                    <c:set var="hasPassedAssignment" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                                    
                                                    <div style="width: 100%; border: 1px solid ${hasPassedAssignment ? '#bbf7d0' : '#fecaca'}; border-radius: 8px; padding: 24px; background-color: ${hasPassedAssignment ? '#f0fdf4' : '#fdf2f2'}; display: flex; gap: 20px; align-items: flex-start; margin-bottom: 24px;">
                                                        <div style="font-size: 2rem; color: ${hasPassedAssignment ? '#16a34a' : '#dc2626'}; background-color: ${hasPassedAssignment ? '#dcfce7' : '#fee2e2'}; width: 48px; height: 48px; border-radius: 9999px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                                            <i class="fas ${hasPassedAssignment ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                                                        </div>
                                                        <div style="flex-grow: 1;">
                                                            <h4 style="font-size: 1.125rem; font-weight: 600; color: #0f172a; margin: 0 0 8px 0;">Assignment Graded: ${hasPassedAssignment ? 'Passed' : 'Needs Improvement'}</h4>
                                                            <p style="color: #475569; margin: 0 0 16px 0; font-size: 0.9375rem; line-height: 1.5;">${hasPassedAssignment ? 'Excellent job! You have successfully cleared this assignment milestone.' : 'Your submission did not meet the required passing mark. Please review the instructor feedback below and resubmit if attempts are available.'}</p>
                                                            
                                                            <div style="display: flex; gap: 16px; margin-bottom: 16px; flex-wrap: wrap;">
                                                                <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 8px 16px; min-width: 120px;">
                                                                    <span style="display: block; font-size: 0.75rem; color: #64748b; text-transform: uppercase;">Your Score</span>
                                                                    <strong style="font-size: 1.125rem; color: #0f172a;">${selectedAssessmentLatest.score} / ${totalPoints}</strong>
                                                                </div>
                                                                <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 8px 16px; min-width: 120px;">
                                                                    <span style="display: block; font-size: 0.75rem; color: #64748b; text-transform: uppercase;">Percentage</span>
                                                                    <strong style="font-size: 1.125rem; color: #0f172a;"><fmt:formatNumber value="${(selectedAssessmentLatest.score / totalPoints) * 100}" maxFractionDigits="1"/>%</strong>
                                                                </div>
                                                                <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 8px 16px; min-width: 120px;">
                                                                    <span style="display: block; font-size: 0.75rem; color: #64748b; text-transform: uppercase;">Status</span>
                                                                    <strong style="font-size: 1.125rem; color: ${hasPassedAssignment ? '#16a34a' : '#dc2626'};">${hasPassedAssignment ? 'PASSED' : 'RETAKE REQUIRED'}</strong>
                                                                </div>
                                                            </div>

                                                            <c:if test="${not empty selectedAssessmentLatest.feedback}">
                                                                <div style="background-color: #ffffff; border-left: 4px solid #2563eb; border-radius: 0 6px 6px 0; padding: 12px 16px; margin-top: 16px; border-top: 1px solid #e2e8f0; border-right: 1px solid #e2e8f0; border-bottom: 1px solid #e2e8f0;">
                                                                    <h5 style="font-size: 0.875rem; font-weight: 600; color: #0f172a; margin: 0 0 6px 0; display: flex; align-items: center; gap: 6px;">
                                                                        <i class="fas fa-comment-dots" style="color: #2563eb;"></i> Instructor Feedback
                                                                    </h5>
                                                                    <p style="margin: 0; color: #475569; font-style: italic; font-size: 0.9375rem;">"<c:out value="${selectedAssessmentLatest.feedback}"/>"</p>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    
                                                    <c:if test="${not hasPassedAssignment and selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                        <div style="width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; background-color: #ffffff; margin-top: 24px;">
                                                            <h3 style="font-size: 1.25rem; font-weight: 600; color: #0f172a; margin: 0 0 8px 0;"><i class="fas fa-rotate-left" style="color: #2563eb; margin-right: 6px;"></i> Submit Assignment Retake</h3>
                                                            <p style="color: #475569; margin: 0 0 24px 0; font-size: 0.9375rem;">Upload an updated file to improve your score. You have ${selectedAssessmentAllowedAttempts - selectedAssessmentUsedAttempts} attempt(s) remaining.</p>
                                                            
                                                            <form id="assignmentHubForm" method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" class="ax-composer">
                                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                                                <div class="dropzone" data-upload-zone>
                                                                    <input name="answerFile" type="file" style="display: none;" required>
                                                                    <div class="dropzone_content">
                                                                        <i class="fas fa-cloud-arrow-up dropzone_icon"></i>
                                                                        <div class="dropzone_text">Click to browse or drag your PDF answer file here</div>
                                                                        <div class="dropzone_subtext">Supports PDF up to 50MB</div>
                                                                    </div>
                                                                </div>

                                                                <div class="submit_action_container" style="justify-content: flex-start;">
                                                                    <button class="primary_button" type="submit" data-submit-button data-loading-label="Submitting retake...">
                                                                        <i class="fas fa-upload"></i><span>Submit Retake</span>
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </c:if>

                                                    <c:if test="${not hasPassedAssignment and selectedAssessmentUsedAttempts >= selectedAssessmentAllowedAttempts}">
                                                         <div style="width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; background-color: #ffffff; margin-top: 24px;">
                                                             <h3 style="font-size: 1.25rem; font-weight: 600; color: #0f172a; margin: 0 0 8px 0;"><i class="fas fa-envelope" style="color: #d97706; margin-right: 6px;"></i> Request Assignment Retake</h3>
                                                             <p style="color: #475569; margin: 0 0 24px 0; font-size: 0.9375rem;">You have exhausted all allowed attempts for this assignment. If you failed to meet the passing threshold, you can request an additional attempt from your instructor.</p>
                                                             
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
                                                                         <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                         <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                                         <button type="submit" class="warning_button" style="background-color: #f59e0b; color: #ffffff; padding: 10px 20px; border: none; border-radius: 6px; font-weight: 500; font-size: 0.875rem; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                                                                             <i class="fas fa-paper-plane"></i>
                                                                             <span>Submit Retake Request</span>
                                                                         </button>
                                                                     </form>
                                                                 </c:otherwise>
                                                             </c:choose>
                                                         </div>
                                                     </c:if>
                                                </c:when>

                                                <c:otherwise>
                                                    <form id="assignmentHubForm" method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" class="ax-composer" style="width: 100%;">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                                        <div class="dropzone" data-upload-zone>
                                                            <input name="answerFile" type="file" style="display: none;" required>
                                                            <div class="dropzone_content">
                                                                <i class="fas fa-cloud-arrow-up dropzone_icon"></i>
                                                                <div class="dropzone_text">Click to browse or drag your PDF answer file here</div>
                                                                <div class="dropzone_subtext">Supports PDF up to 50MB</div>
                                                            </div>
                                                        </div>

                                                        <div class="submit_action_container" style="justify-content: flex-start;">
                                                            <button class="primary_button" type="submit" data-submit-button data-loading-label="Submitting assignment...">
                                                                    <i class="fas fa-upload"></i><span>Submit Assignment</span>
                                                            </button>
                                                        </div>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </section>
                                </c:if>

                                <c:if test="${selectedAssessment.type != 'Assignment'}">
                                    <c:choose>
                                        <c:when test="${not empty selectedAssessmentLatest}">
                                            <c:set var="passThreshold" value="${totalPoints * 0.7}"/>
                                            <c:set var="hasPassedQuiz" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                            <section class="container">
                                                <div class="result_container">
                                                    <h1 class="title">${selectedAssessment.title}</h1>
                                                    
                                                    <div class="result_score_hero">
                                                        <fmt:formatNumber value="${(selectedAssessmentLatest.score / totalPoints) * 100.0}" maxFractionDigits="0"/>%
                                                    </div>

                                                    <div class="status_pill ${hasPassedQuiz ? 'status_pill_passed' : 'status_pill_failed'}">
                                                        <i class="fas ${hasPassedQuiz ? 'fa-circle-check' : 'fa-circle-xmark'}" style="margin-right: 8px;"></i>
                                                        <c:choose>
                                                            <c:when test="${hasPassedQuiz}">Passed</c:when>
                                                            <c:otherwise>Failed (Retake Required)</c:otherwise>
                                                        </c:choose>
                                                    </div>

                                                    <p style="color: #64748b; line-height: 1.6; max-width: 50ch; margin: 0 auto 24px; text-align: center;">
                                                        <c:choose>
                                                            <c:when test="${hasPassedQuiz}">
                                                                Great work! You have successfully passed this assessment milestone. Review your score breakdown below or continue forward.
                                                            </c:when>
                                                            <c:otherwise>
                                                                Your score did not meet the 70% passing threshold for this milestone. Review the breakdown below and try again.
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </p>

                                                    <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px 24px; width: 100%; display: flex; justify-content: space-around; margin-bottom: 32px;">
                                                        <div>
                                                            <span style="display: block; font-size: 0.75rem; color: #64748b; text-transform: uppercase;">Points Scored</span>
                                                            <strong style="font-size: 1.25rem; color: #0f172a;">${selectedAssessmentLatest.score} / ${totalPoints}</strong>
                                                        </div>
                                                        <div style="border-left: 1px solid #e2e8f0;"></div>
                                                        <div>
                                                            <span style="display: block; font-size: 0.75rem; color: #64748b; text-transform: uppercase;">Attempts Used</span>
                                                            <strong style="font-size: 1.25rem; color: #0f172a;">${selectedAssessmentUsedAttempts} / ${selectedAssessmentAllowedAttempts}</strong>
                                                        </div>
                                                    </div>

                                                    <div class="submit_action_container" style="width: 100%; justify-content: center; gap: 12px;">
                                                        <a class="secondary_button" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${selectedAssessment.assessmentId}&submissionId=${selectedAssessmentLatest.submissionId}">
                                                            <i class="fas fa-chart-column"></i>
                                                            <span>View Details Breakdown</span>
                                                        </a>
                                                        <c:choose>
                                                            <c:when test="${hasPassedQuiz}">
                                                                <button type="button" class="primary_button" data-complete-and-continue>
                                                                    <span>Complete &amp; Continue</span>
                                                                    <i class="fas fa-arrow-right"></i>
                                                                </button>
                                                                <c:if test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                                    <a class="primary_button" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                        <i class="fas fa-rotate-left"></i>
                                                                        <span>Retake Assessment</span>
                                                                    </a>
                                                                </c:if>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:choose>
                                                                    <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                                        <a class="primary_button" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                            <i class="fas fa-rotate-left"></i>
                                                                            <span>Retake Assessment</span>
                                                                        </a>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:choose>
                                                                            <c:when test="${hasPendingRetakeRequest}">
                                                                                <button type="button" class="warning_button" disabled="disabled" style="background-color: #fef3c7; border: 1px solid #fcd34d; color: #d97706; padding: 10px 20px; border-radius: 6px; font-weight: 500; font-size: 0.875rem; display: inline-flex; align-items: center; gap: 8px;">
                                                                                    <i class="fas fa-hourglass-half"></i>
                                                                                    <span>Retake Pending</span>
                                                                                </button>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <form method="post" action="${pageContext.request.contextPath}/student/assessments" style="display: inline-block; margin: 0;">
                                                                                    <input type="hidden" name="action" value="requestRetake">
                                                                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                                    <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                                                    <button type="submit" class="warning_button" style="background-color: #f59e0b; color: #ffffff; padding: 10px 20px; border: none; border-radius: 6px; font-weight: 500; font-size: 0.875rem; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                                                                                        <i class="fas fa-envelope"></i>
                                                                                        <span>Request Retake</span>
                                                                                    </button>
                                                                                </form>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </section>
                                        </c:when>
                                        <c:otherwise>
                                            <section class="container">
                                                <div class="pre_assessment_container">
                                                    <h1 class="title">${selectedAssessment.title}</h1>
                                                    
                                                    <div class="metadata_row">
                                                        <span class="metadata_pill">Questions: ${fn:length(selectedAssessmentQuestions)} Items</span>
                                                        <span class="metadata_pill">Time Limit: ${selectedAssessment.duration != null ? selectedAssessment.duration : '30'} Minutes</span>
                                                        <span class="metadata_pill">Passing Grade: 70% Score</span>
                                                        <span class="metadata_pill">Attempts: ${selectedAssessmentUsedAttempts} / ${selectedAssessmentAllowedAttempts} Used</span>
                                                    </div>

                                                    <p class="instructions">
                                                        <c:choose>
                                                            <c:when test="${not empty selectedAssessmentInstructions}">${selectedAssessmentInstructions}</c:when>
                                                            <c:otherwise>Take this objective evaluation within the secure Learning Hub interface. Once started, the timer will begin and your attempts will count toward course milestones.</c:otherwise>
                                                        </c:choose>
                                                    </p>

                                                    <div style="background-color: #fffbeb; border: 1px solid #fef3c7; border-radius: 8px; padding: 16px; margin-bottom: 32px; display: flex; gap: 12px; align-items: flex-start; text-align: left; max-width: 500px;">
                                                        <i class="fas fa-circle-info" style="color: #d97706; font-size: 1.25rem; margin-top: 2px;"></i>
                                                        <div style="font-size: 0.875rem; color: #b45309; line-height: 1.5;">
                                                            <strong>Important Rules:</strong> Do not refresh the page, close the browser window, or switch tabs while the assessment is running. Your answers are auto-saved, but leaving the workspace unexpectedly may cause the attempt to submit immediately.
                                                        </div>
                                                    </div>

                                                    <div class="submit_action_container">
                                                        <c:choose>
                                                            <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                                <a class="primary_button" 
                                                                   href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true"
                                                                   data-load-attempt-url="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                    <i class="fas fa-play"></i>
                                                                    <span>${selectedAssessmentPrimaryLabel}</span>
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button class="danger_button" disabled="disabled">
                                                                    <i class="fas fa-ban"></i>
                                                                    <span>No Attempts Remaining</span>
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </section>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </c:when>

                    <c:when test="${not empty selectedMaterial}">
                        <c:set var="materialType" value="${fn:toLowerCase(selectedMaterial.materialType)}"/>
                        <c:set var="materialPath" value="${selectedMaterial.filePath}"/>
                        <c:set var="materialViewUrl" value="${pageContext.request.contextPath}/student/materials?action=view&id=${selectedMaterial.materialId}"/>
                        <c:choose>
                            <c:when test="${isYouTubeMaterial}">
                                <c:choose>
                                    <c:when test="${not empty youtubeVideoId}">
                                        <div class="lh-video-shell lh-video-shell--spaced">
                                            <iframe 
                                                class="lh-video-embed"
                                                src="https://www.youtube.com/embed/${youtubeVideoId}"
                                                allowfullscreen>
                                            </iframe>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="lh-link-preview">
                                            <span class="lh-link-preview__type"><i class="fab fa-youtube lh-link-preview__type-icon lh-link-preview__type-icon--youtube"></i> YouTube Video</span>
                                            <h3><c:out value="${selectedMaterial.title}"/></h3>
                                            <p>The YouTube URL for this material could not be embedded. Please update the link format so it can stay inside the page.</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:when test="${materialType == 'pdf' or fn:endsWith(fn:toLowerCase(materialPath), '.pdf')}">
                                <div class="lh-viewer-toolbar">
                                    <span><i class="fas fa-file-pdf"></i> PDF Material</span>
                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=download&id=${selectedMaterial.materialId}&enrollmentId=${enrollment.enrollmentId}">
                                        <i class="fas fa-download"></i>
                                        <span>Download</span>
                                    </a>
                                </div>
                                <object class="lh-pdf-viewer" data="${materialViewUrl}" type="application/pdf">
                                    <div class="lh-link-preview">
                                        <h3>PDF preview is unavailable</h3>
                                        <p>Open or download the material to continue reviewing it.</p>
                                        <a class="sv-btn primary" href="${materialViewUrl}" target="_blank" rel="noopener">
                                            <i class="fas fa-arrow-up-right-from-square"></i>
                                            <span>Open PDF</span>
                                        </a>
                                    </div>
                                </object>
                            </c:when>
                            <c:when test="${materialType == 'video' or fn:endsWith(fn:toLowerCase(materialPath), '.mp4') or fn:endsWith(fn:toLowerCase(materialPath), '.webm') or fn:endsWith(fn:toLowerCase(materialPath), '.mov') or fn:endsWith(fn:toLowerCase(materialPath), '.m4v')}">
                                <div class="lh-video-shell">
                                    <video class="lh-video-player" controls preload="metadata">
                                        <source src="${materialViewUrl}">
                                    </video>
                                </div>
                            </c:when>
                            <c:when test="${materialType == 'audio' or fn:endsWith(fn:toLowerCase(materialPath), '.mp3')}">
                                <div class="lh-link-preview">
                                    <span class="lh-link-preview__type"><i class="fas fa-volume-high"></i> Audio Material</span>
                                    <h3><c:out value="${selectedMaterial.title}"/></h3>
                                    <audio class="lh-audio-player" controls src="${materialViewUrl}"></audio>
                                </div>
                            </c:when>
                            <c:when test="${materialType == 'link'}">
                                <div class="lh-link-preview">
                                    <span class="lh-link-preview__type"><i class="fas fa-link"></i> External Resource</span>
                                    <h3><c:out value="${selectedMaterial.title}"/></h3>
                                    <p><c:out value="${not empty selectedMaterial.description ? selectedMaterial.description : 'Open this resource in a new tab, then return here to mark it complete.'}"/></p>
                                    <a class="sv-btn primary" href="${fn:escapeXml(selectedMaterial.filePath)}" target="_blank" rel="noopener">
                                        <i class="fas fa-arrow-up-right-from-square"></i>
                                        <span>Open Resource</span>
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="lh-link-preview">
                                    <span class="lh-link-preview__type"><i class="fas fa-file-lines"></i> Learning Resource</span>
                                    <h3><c:out value="${selectedMaterial.title}"/></h3>
                                    <p><c:out value="${not empty selectedMaterial.description ? selectedMaterial.description : 'Download or open this material to continue.'}"/></p>
                                    <div class="lh-inline-actions">
                                        <a class="sv-btn primary" href="${materialViewUrl}" target="_blank" rel="noopener">
                                            <i class="fas fa-arrow-up-right-from-square"></i>
                                            <span>Open Material</span>
                                        </a>
                                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=download&id=${selectedMaterial.materialId}&enrollmentId=${enrollment.enrollmentId}">
                                            <i class="fas fa-download"></i>
                                            <span>Download</span>
                                        </a>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <%-- Manual Completion Block at the bottom of the material --%>
                        <div class="lh-material-completion-block">
                            <div class="lh-material-completion-block__copy">
                                <div>
                                    <h4>Material Progress</h4>
                                    <p><c:out value="${workspaceActionNote}"/></p>
                                </div>
                            </div>
                            <button
                                id="edMarkCompleted"
                                type="button"
                                class="sv-btn primary"
                                data-material-id="${selectedMaterial.materialId}"
                                data-enrollment-id="${enrollment.enrollmentId}"
                                data-completed="${selectedMaterialStatus == 'completed'}"
                                <c:if test="${selectedMaterialStatus == 'completed' or courseExpired}">disabled="disabled"</c:if>>
                                <i class="fas fa-check-circle"></i>
                                <span>${materialCompletionButtonLabel}</span>
                            </button>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="lh-certificate-hub">
                            <c:choose>
                                <%-- Case 1: Certificate already generated --%>
                                <c:when test="${not empty userCertificate}">
                                    <div class="lh-cert-card is-earned">
                                        <div class="lh-cert-badge-wrapper">
                                            <i class="fas fa-medal lh-cert-icon-glowing"></i>
                                        </div>
                                        <h3>Credential Earned!</h3>
                                        <p>Congratulations! You have completed all curriculum milestones, passed all required evaluations, and earned your official e-learning credential.</p>
                                        
                                        <div class="lh-cert-meta-grid">
                                            <div class="lh-cert-meta-item">
                                                <span>Certificate ID</span>
                                                <strong>${userCertificate.certificateNumber}</strong>
                                            </div>
                                            <div class="lh-cert-meta-item">
                                                <span>Issued On</span>
                                                <strong><fmt:formatDate value="${userCertificate.issueDate}" pattern="MMM dd, yyyy"/></strong>
                                            </div>
                                        </div>

                                        <a href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${enrollment.enrollmentId}" class="sv-btn primary lh-cert-download-action">
                                            <i class="fas fa-download"></i> Download Certificate
                                        </a>
                                    </div>
                                </c:when>

                                <%-- Case 2: Eligible for certificate but not yet generated --%>
                                <c:when test="${certificateEligible}">
                                    <div class="lh-cert-card is-claimable">
                                        <div class="lh-cert-badge-wrapper">
                                            <i class="fas fa-award lh-cert-icon-glowing"></i>
                                        </div>
                                        <h3>Claim Your Certificate!</h3>
                                        <p>Congratulations! You have successfully completed all lessons, satisfied payment requirements, and passed all course assessments. You are now eligible to claim your official credential.</p>
                                        
                                        <form method="post" action="${pageContext.request.contextPath}/student/certificate">
                                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                            <button type="submit" class="sv-btn primary lh-cert-generate-action">
                                                <i class="fas fa-bolt"></i> Generate Credential
                                            </button>
                                        </form>
                                    </div>
                                </c:when>

                                <%-- Case 3: Course In Progress --%>
                                <c:otherwise>
                                    <div class="lh-progress-dashboard">
                                        <h3 class="lh-dashboard-title">Welcome to the Learning Hub!</h3>
                                        <p class="lh-dashboard-subtitle">Track your milestones below. Satisfy all checkpoints to unlock your completion certificate.</p>
                                        
                                        <div class="lh-milestones">
                                            <%-- Milestone 1: Payment Check --%>
                                            <div class="lh-milestone-item">
                                                <div class="lh-milestone-icon ${certificatePaidReady ? 'is-completed' : 'is-pending'}">
                                                    <i class="fas ${certificatePaidReady ? 'fa-check-circle' : 'fa-circle'}"></i>
                                                </div>
                                                <div class="lh-milestone-copy">
                                                    <strong class="lh-milestone-name">Tuition Payment</strong>
                                                    <span class="lh-milestone-desc">
                                                        <c:choose>
                                                            <c:when test="${enrollment.coursePrice <= 0}">
                                                                Free course (No payment required).
                                                            </c:when>
                                                            <c:when test="${certificatePaidReady}">
                                                                Verified and cleared.
                                                            </c:when>
                                                            <c:otherwise>
                                                                Requires successful payment verification.
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <div class="lh-milestone-action">
                                                    <c:choose>
                                                        <c:when test="${certificatePaidReady}">
                                                            <span class="lh-milestone-badge is-completed">Paid</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${enrollment.courseId}" class="sv-btn primary btn-sm">Pay Now</a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <%-- Milestone 2: Materials Viewed Check --%>
                                            <div class="lh-milestone-item">
                                                <div class="lh-milestone-icon ${certificateCompletedReady ? 'is-completed' : 'is-pending'}">
                                                    <i class="fas ${certificateCompletedReady ? 'fa-check-circle' : 'fa-circle'}"></i>
                                                </div>
                                                <div class="lh-milestone-copy">
                                                    <strong class="lh-milestone-name">Lesson Materials</strong>
                                                    <span class="lh-milestone-desc">Complete all lesson files and review slides (${materialsViewedCount} of ${materialCount} viewed).</span>
                                                </div>
                                                <div class="lh-milestone-action">
                                                    <span class="lh-milestone-badge ${certificateCompletedReady ? 'is-completed' : 'is-pending'}">
                                                        ${materialsViewedCount}/${materialCount}
                                                    </span>
                                                </div>
                                            </div>

                                            <%-- Milestone 3: Assessments Passed Check --%>
                                            <div class="lh-milestone-item">
                                                <div class="lh-milestone-icon ${certificateAssessmentsReady ? 'is-completed' : 'is-pending'}">
                                                    <i class="fas ${certificateAssessmentsReady ? 'fa-check-circle' : 'fa-circle'}"></i>
                                                </div>
                                                <div class="lh-milestone-copy">
                                                    <strong class="lh-milestone-name">Course Evaluations</strong>
                                                    <span class="lh-milestone-desc">Pass all required sequential assessments (${passedAssessmentsCount} of ${assessmentCount} cleared).</span>
                                                </div>
                                                <div class="lh-milestone-action">
                                                    <span class="lh-milestone-badge ${certificateAssessmentsReady ? 'is-completed' : 'is-pending'}">
                                                        ${passedAssessmentsCount}/${assessmentCount}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:otherwise>
                </c:choose>
        </div><%-- /lh-content-stage --%>

                </div>
            </footer>
        </main>
    </div> <%-- /hub_splitView --%>
</div> <%-- /hub_container --%>

<div class="sv-overlay" id="svOverlay"></div>
<script>
function updateHubFileName(input, isRetake) {
    var suffix = isRetake ? 'Retake' : 'Initial';
    var fileBox = document.getElementById('selectedFileHubName' + suffix);
    var textSpan = document.getElementById('fileNameHubText' + suffix);
    if (input.files && input.files.length > 0) {
        textSpan.textContent = input.files[0].name;
        fileBox.style.display = 'flex';
    } else {
        fileBox.style.display = 'none';
    }
}

function toggleSidebarMaterial(event, materialId, enrollmentId, btn) {
    event.preventDefault();
    event.stopPropagation();
    
    if (btn.disabled) return;
    
    btn.disabled = true;
    var icon = btn.querySelector('i');
    var originalClass = icon.className;
    icon.className = 'fas fa-spinner fa-spin';
    
    var payload = 'materialId=' + encodeURIComponent(materialId) + '&enrollmentId=' + encodeURIComponent(enrollmentId);
    
    fetch('${pageContext.request.contextPath}/student/mark-material-completed', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: payload
    })
    .then(function (response) {
        if (!response.ok) throw new Error('Error');
        return response.json();
    })
    .then(function (data) {
        if (data.success) {
            btn.classList.add('hub_completionToggleComplete');
            icon.className = 'fas fa-check-circle';
            
            // Sync progress elements
            var progressPercentNode = document.getElementById('lhSidebarProgressPercent');
            var topbarPct = document.getElementById('lhTopbarPct');
            var topbarFill = document.getElementById('lhTopbarFill');
            var progressBar = document.getElementById('lhSidebarProgressBar');
            
            var pctText = data.progressPercent + '%';
            if (progressPercentNode) progressPercentNode.textContent = pctText;
            if (topbarPct) {
                if (topbarPct.textContent.indexOf('Modules') !== -1) {
                    topbarPct.textContent = data.progressPercent + '% Modules';
                } else {
                    topbarPct.textContent = pctText;
                }
            }
            if (topbarFill) topbarFill.style.width = data.progressPercent + '%';
            if (progressBar) progressBar.style.width = data.progressPercent + '%';
            
            // Sync active sidebar item state
            var row = btn.closest('.hub_moduleItem');
            if (row) {
                row.classList.add('is-completed');
                var kindSub = row.querySelector('.hub_moduleKind');
                if (kindSub) kindSub.textContent = 'Completed';
            }
            
            // Sync page data bridge
            document.body.dataset.progressPercent = data.progressPercent;
            
            // If the active material on main stage is this one, sync complete button & badge
            var mainCompleteBtn = document.getElementById('edMarkCompleted');
            if (mainCompleteBtn && mainCompleteBtn.getAttribute('data-material-id') === materialId) {
                mainCompleteBtn.disabled = true;
                mainCompleteBtn.innerHTML = '<i class="fas fa-check-circle"></i><span>Completed</span>';
                var badge = document.getElementById('lhItemStatusBadge');
                if (badge) {
                    badge.className = 'status-badge status-Approved';
                    badge.textContent = 'Completed';
                }
            }
        } else {
            icon.className = originalClass;
            btn.disabled = false;
        }
    })
    .catch(function () {
        icon.className = originalClass;
        btn.disabled = false;
    });
}

// Mobile sidebar toggle logic
document.addEventListener('DOMContentLoaded', function() {
    var mobileToggle = document.getElementById('hubMobileToggle');
    var mobileOverlay = document.getElementById('hubMobileOverlay');
    var body = document.body;
    
    if (mobileToggle && mobileOverlay) {
        mobileToggle.addEventListener('click', function() {
            body.classList.toggle('hub-mobile-open');
        });
        
        mobileOverlay.addEventListener('click', function() {
            body.classList.remove('hub-mobile-open');
        });
    }
});
</script>
<script src="${pageContext.request.contextPath}/js/learning-hub.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
