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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/focus-mode.css">
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

<%-- Learning Hub Shell — Coursera-Grade Redesign --%>
<header class="lh-focus-topbar" role="banner" id="lhTopbar">
    <button class="lh-focus-topbar__toggle" id="hubMobileToggle" type="button" aria-label="Toggle syllabus sidebar" aria-expanded="false">
        <i class="fas fa-bars"></i>
    </button>
    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="lh-focus-topbar__back" aria-label="Return to Dashboard">
        <i class="fas fa-chevron-left" aria-hidden="true"></i>
        <span>Back</span>
    </a>
    <h1 class="lh-focus-topbar__title" title="${enrollment.courseName}">${enrollment.courseName}</h1>
    <div class="lh-focus-topbar__progress" aria-label="Course progress: ${progressPercent}%">
        <span class="lh-focus-topbar__pct" id="lhTopbarPct">${progressPercent}%</span>
        <div class="lh-focus-topbar__bar">
            <div class="lh-focus-topbar__bar-fill" id="lhTopbarFill" style="width: ${progressPercent}%"></div>
        </div>
    </div>
    <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false" aria-label="Toggle dark mode" title="Toggle dark mode" style="padding: 0; width: 2.5rem; height: 2.5rem; border-radius: 50%;">
        <i class="fas fa-moon" aria-hidden="true"></i>
    </button>
</header>

<%-- Sidebar overlay for mobile --%>
<div class="sv-overlay" id="hubMobileOverlay" aria-hidden="true"></div>

<%-- Sticky Sidebar Syllabus --%>
<aside class="lh-course-sidebar" id="svSidebar" aria-label="Course syllabus">
    <div class="lh-course-sidebar__header">
        <h2 style="font-size: 1.25rem; font-weight: 800; color: var(--text-primary); margin: 0; display: flex; align-items: center; gap: 8px;">
            <i class="fas fa-graduation-cap" style="color: var(--accent);"></i>
            Learning Hub
        </h2>
    </div>
    <div class="lh-course-sidebar__scroll">
        <div class="lh-flat-items" style="display: flex; flex-direction: column; gap: var(--lh-space-2);">
        <c:forEach var="item" items="${learningItems}" varStatus="loop">

            <a href="${item.navigationUrl}"
               class="lh-chapter-item ${item.active ? 'is-active' : ''} ${item.completedForProgress ? 'is-completed' : ''} ${item.locked ? 'is-locked' : ''}"
               data-kind="${item.itemKind}"
               <c:if test="${item.locked}">aria-disabled="true" tabindex="-1"</c:if>>
                <span class="lh-ci-icon" aria-hidden="true">
                    <c:choose>
                        <c:when test="${item.itemKind == 'assessment'}">
                            <i class="fas fa-clipboard-check" style="color: hsl(270 80% 60%);"></i>
                        </c:when>
                        <c:when test="${item.iconClass == 'fa-play-circle'}">
                            <i class="fas fa-play-circle" style="color: #3b82f6;"></i>
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-file-lines"></i>
                        </c:otherwise>
                    </c:choose>
                </span>
                <div class="lh-ci-copy">
                    <span class="lh-ci-title">${item.title}</span>
                    <span class="lh-ci-sub">
                        <c:choose>
                            <c:when test="${item.completedForProgress}"><i class="fas fa-check-circle" style="color: var(--success); margin-right: 3px;"></i>Completed</c:when>
                            <c:when test="${item.locked}"><i class="fas fa-lock" style="margin-right: 3px;"></i>Locked</c:when>
                            <c:when test="${item.itemKind == 'assessment'}">Assessment</c:when>
                            <c:otherwise>Lesson</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <span class="lh-ci-state" aria-hidden="true">
                    <c:choose>
                        <c:when test="${item.completedForProgress}">
                            <span role="button" class="hub_completionToggle hub_completionToggleComplete"
                                    onclick="toggleSidebarMaterial(event, '${item.itemId}', '${enrollment.enrollmentId}', this)"
                                    aria-disabled="true" aria-label="Completed">
                                <i class="fas fa-check-circle" style="color: var(--success);"></i>
                            </span>
                        </c:when>
                        <c:when test="${item.locked}">
                            <i class="fas fa-lock" style="color: var(--text-muted); font-size: 0.8rem;"></i>
                        </c:when>
                        <c:when test="${item.itemKind == 'assessment'}">
                            <i class="fas fa-chevron-right" style="font-size: 0.75rem; color: var(--text-muted);"></i>
                        </c:when>
                        <c:otherwise>
                            <span role="button" class="hub_completionToggle"
                                    onclick="toggleSidebarMaterial(event, '${item.itemId}', '${enrollment.enrollmentId}', this)"
                                    aria-label="Mark as complete">
                                <i class="far fa-circle" style="font-size: 1rem;"></i>
                            </span>
                        </c:otherwise>
                    </c:choose>
                </span>
            </a>

        </c:forEach>
        </div>
    </div>
</aside>

<%-- Main Content Stage --%>
<main class="lh-main" id="lhStage">
    <div class="lh-content-stage">

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

                        <div>
                            <div class="lh-result-hero">
                                <h1 class="title" style="margin-bottom: var(--lh-space-2);">${assessment.title}</h1>
                                
                                <div class="lh-result-hero-score">
                                    <c:choose>
                                        <c:when test="${not empty submission.score}"><fmt:formatNumber value="${percentage}" maxFractionDigits="0"/>%</c:when>
                                        <c:otherwise>--</c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="lh-result-hero-status ${empty submission.score ? 'is-pending' : (passedAssessment ? 'is-passed' : 'is-failed')}">
                                    <i class="fas ${empty submission.score ? 'fa-clock' : (passedAssessment ? 'fa-circle-check' : 'fa-circle-xmark')}"></i>
                                    <span>
                                        <c:choose>
                                            <c:when test="${empty submission.score}">Awaiting Grade</c:when>
                                            <c:when test="${passedAssessment}">Passed</c:when>
                                            <c:otherwise>Failed</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <p style="color: var(--text-secondary); line-height: 1.6; max-width: 50ch; margin: var(--lh-space-4) auto 0;">
                                    <c:choose>
                                        <c:when test="${empty submission.score}">Your submission has been received and is currently awaiting grading by your instructor.</c:when>
                                        <c:when test="${passedAssessment}">Great work! You have successfully passed this assessment milestone.</c:when>
                                        <c:otherwise>Your score did not meet the 70% passing threshold. You can review the details below and try again if attempts remain.</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>

                            <%-- Transparent Question Review Grid --%>
                            <div class="lh-review-list">
                                <c:choose>
                                    <c:when test="${not objectiveAssessment || empty questions}">
                                        <div style="text-align: center; padding: var(--lh-space-8); background-color: var(--surface-primary); border: 1px solid var(--border-subtle); border-radius: var(--lh-radius-lg); color: var(--text-muted);">
                                            <i class="fas fa-folder-open" style="font-size: 3rem; margin-bottom: var(--lh-space-4); color: var(--accent-soft);"></i>
                                            <p style="margin: 0; font-size: var(--lh-font-size-lg);">No question-level review is available for this submission.</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="q" items="${questions}" varStatus="loop">
                                            <c:set var="studAns" value="${empty studentAnswerByQuestionId[q.questionId] ? '' : studentAnswerByQuestionId[q.questionId]}" />
                                            <c:set var="corrAns" value="${empty correctAnswerByQuestionId[q.questionId] ? '' : correctAnswerByQuestionId[q.questionId]}" />
                                            <c:set var="isCorrect" value="${not empty studAns and studAns == corrAns}" />
                                            
                                            <div class="lh-review-item">
                                                <div class="lh-review-item__question">${loop.index + 1}. ${q.questionText}</div>
                                                <div class="lh-review-item__answer-box ${isCorrect ? 'is-correct' : 'is-error'}">
                                                    <i class="fas ${isCorrect ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                                                    <span>Your Answer: <strong>${empty studAns ? 'None' : studAns}</strong></span>
                                                </div>
                                                <c:if test="${not isCorrect}">
                                                    <div class="lh-review-item__correct-box">
                                                        <i class="fas fa-arrow-turn-down fa-rotate-90"></i>
                                                        <span>Correct Answer: <strong>${corrAns}</strong></span>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="lh-post-actions">
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning" data-complete-and-continue>
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
                                    <span class="sa-badge-flat success"><i class="fas fa-chart-column"></i> Performance Analytics</span>
                                    <h3>${enrollment.courseName}</h3>
                                </div>
                            </div>

                            <%-- Performance Summary KPI Cards --%>
                            <div class="lh-perf-summary">
                                <div class="lh-perf-summary-card ${overallPerformance >= 70 ? 'is-pass' : (overallPerformance > 0 ? 'is-warn' : '')}">
                                    <span>Overall Score</span>
                                    <strong><c:choose><c:when test="${overallPerformance > 0}"><fmt:formatNumber value="${overallPerformance}" maxFractionDigits="1"/>%</c:when><c:otherwise>—</c:otherwise></c:choose></strong>
                                </div>
                                <div class="lh-perf-summary-card ${passedAssessmentsCount >= assessmentCount and assessmentCount > 0 ? 'is-pass' : ''}">
                                    <span>Assessments Passed</span>
                                    <strong>${passedAssessmentsCount} <span style="font-size: 1rem; color: var(--text-muted);">/ ${assessmentCount}</span></strong>
                                </div>
                                <div class="lh-perf-summary-card">
                                    <span>Materials Progress</span>
                                    <strong>${progressPercent}<span style="font-size: 1rem; color: var(--text-muted);">%</span></strong>
                                </div>
                            </div>

                            <div class="lh-table-scroll">
                                <table class="lh-performance-table">
                                    <thead>
                                        <tr>
                                            <th>Assessment</th>
                                            <th>Attempts</th>
                                            <th>Score</th>
                                            <th>Performance</th>
                                            <th>Mastery</th>
                                            <th>Status</th>
                                            <th>Action</th>
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
                                                <td>
                                                    <strong>${assessment.title}</strong>
                                                    <span class="lh-table-meta"><i class="fas fa-clipboard-check" style="color: hsl(270 80% 60%); margin-right: 3px;"></i>${assessment.type}</span>
                                                </td>
                                                <td><strong>${usedAttempts} / ${allowedAttempts}</strong></td>
                                                <td>
                                                    <strong>
                                                        <c:choose>
                                                            <c:when test="${not empty bestScore}"><fmt:formatNumber value="${bestScore}" maxFractionDigits="1"/></c:when>
                                                            <c:otherwise>—</c:otherwise>
                                                        </c:choose>
                                                    </strong>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty bestPercent}">
                                                            <div class="lh-score-bar-container">
                                                                <div class="lh-score-bar">
                                                                    <div class="lh-score-bar-fill ${bestPercent >= 70 ? '' : (bestPercent >= 50 ? 'is-warn' : 'is-fail')}"
                                                                         style="width: <fmt:formatNumber value="${bestPercent}" maxFractionDigits="0"/>%"></div>
                                                                </div>
                                                                <span class="lh-score-bar-label"><fmt:formatNumber value="${bestPercent}" maxFractionDigits="1"/>%</span>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise><span class="lh-table-meta">Not graded</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 85}"><span class="sa-status status-Approved">Excellent</span></c:when>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 70}"><span class="sa-status status-Approved">Passed</span></c:when>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 50}"><span class="sa-status status-Pending">Developing</span></c:when>
                                                        <c:when test="${not empty bestPercent}"><span class="sa-status status-Archived">Needs Review</span></c:when>
                                                        <c:otherwise><span class="sa-status">—</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${hasActiveAttempt}"><span class="sa-status status-Pending">Active</span></c:when>
                                                        <c:when test="${not empty latestSubmission and not empty latestSubmission.score}"><span class="sa-status status-Approved">Graded</span></c:when>
                                                        <c:when test="${not empty latestSubmission}"><span class="sa-status status-Pending">Awaiting Review</span></c:when>
                                                        <c:otherwise><span class="sa-status status-Archived">Not Started</span></c:otherwise>
                                                    </c:choose>
                                                </td>
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
                                <section class="container" data-attempt-shell style="padding: 0; background: #ffffff;">
                                    <div style="width: 100%; padding: 24px 0 16px 0;">
                                        <div style="display: flex; justify-content: space-between; align-items: center; max-width: 800px; margin: 0 auto; padding: 0 24px;">
                                            <div>
                                                <div class="focus_course_name"><i class="fas fa-shield-halved" style="margin-right: 4px;"></i> Active Assessment</div>
                                                <div class="focus_question_count">Question <span data-current-question>1</span> of ${fn:length(selectedAssessmentQuestions)}</div>
                                            </div>
                                            <div class="focus_timer_box" data-timer>
                                                <i class="fas fa-clock"></i>
                                                <span data-timer-text>00:00</span>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="focus_progress_bar_bg">
                                        <div class="focus_progress_bar_fill" data-progress-fill style="width: 0%;"></div>
                                    </div>

                                    <div class="focus_main_container" style="padding-top: 40px; padding-bottom: 80px;">
                                        <div class="focus_assessment_container">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/student/assessments"
                                                  data-attempt-form
                                                  data-timer-start="${selectedAssessmentTimerStartTime}"
                                                  data-timer-duration="${selectedAssessmentTimerDurationSeconds}"
                                                  class="ax-attempt-form"
                                                  style="width: 100%;">
                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                <input type="hidden" name="timerStart" value="${selectedAssessmentTimerStartTime}">
                                                <input type="hidden" name="timerDuration" value="${selectedAssessmentTimerDurationSeconds}">
                                                <input type="hidden" name="exitSubmission" value="0">

                                                <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                    <article class="ax-question ${loop.first ? 'is-active' : ''}" data-question-index="${loop.index}" style="display: ${loop.first ? 'block' : 'none'};">
                                                        <div class="focus_question_badge">${selectedAssessment.title}</div>
                                                        <h2 class="focus_question_statement">${q.questionText}</h2>
                                                        
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
                                                    <div style="display: flex; gap: 16px; margin-left: auto;">
                                                        <button type="button" class="focus_btn_prev" data-exit-attempt style="color: var(--danger); border-color: var(--danger-soft);">
                                                            <i class="fas fa-door-open" style="margin-right: 6px;"></i> Save & Exit
                                                        </button>
                                                        
                                                        <button type="button" class="focus_btn_next" data-next-question style="margin-left: 0; gap: 8px;">
                                                            <span class="focus_next_label">Next Question</span> <i class="fas fa-arrow-right"></i>
                                                        </button>
                                                        
                                                        <button type="submit" class="focus_btn_next" data-submit-button style="display: none; background-color: var(--success); box-shadow: 0 4px 12px rgba(34, 197, 94, 0.2); gap: 8px;">
                                                            <span>Submit Quiz</span> <i class="fas fa-paper-plane"></i>
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </section>
                            </c:when>
                            <c:otherwise>
                                <c:if test="${not courseAccessGranted}">
                                    <div class="lh-pre-assessment-container">
                                        <div class="lh-pre-assessment-hero" style="text-align: center; max-width: 500px; margin: 0 auto;">
                                            <div style="color: var(--danger); font-size: 3rem; margin-bottom: 1rem;">
                                                <i class="fas fa-lock"></i>
                                            </div>
                                            <h2 class="lh-pre-assessment-title">Assessment Locked</h2>
                                            <p class="lh-pre-assessment-desc">Complete course payment first to unlock and start this evaluation milestone.</p>
                                            <div class="lh-pre-assessment-actions" style="justify-content: center; margin-top: 1.5rem;">
                                                <c:choose>
                                                    <c:when test="${enrollment.coursePrice > 0}">
                                                        <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${enrollment.courseId}" class="sv-btn primary sv-btn--lg">Pay Now to Unlock</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="sv-btn danger sv-btn--lg" disabled="disabled">Awaiting Approval</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>

                                <c:if test="${courseAccessGranted and selectedAssessment.type == 'Assignment'}">
                                    <div class="lh-assessment-intro-card" style="max-width: 800px; text-align: left;">
                                        <div class="lh-aic-icon" style="margin: 0 0 24px 0; background: color-mix(in srgb, var(--accent) 15%, transparent);"><i class="fas fa-file-signature"></i></div>
                                        <h2 class="lh-aic-title" style="text-align: left;">${selectedAssessment.title}</h2>
                                        <p class="lh-aic-desc" style="text-align: left; margin-bottom: 32px;">Review the assignment prompt and upload your completed work below.</p>
                                        
                                        <c:if test="${not empty selectedAssessmentQuestions}">
                                            <div class="lh-aic-tasks">
                                                <h3 style="font-size: 1.15rem; font-weight: 700; color: var(--text-primary); margin-bottom: 20px;">Assignment Prompt & Tasks</h3>
                                                <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                    <div class="lh-aic-task">
                                                        <div class="lh-aic-task-num">${loop.index + 1}</div>
                                                        <div class="lh-aic-task-content">
                                                            <div class="lh-aic-task-text"><c:out value="${q.questionText}"/></div>
                                                            <c:if test="${not empty q.attachmentUrl}">
                                                                <a class="lh-aic-task-link" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                                                    <i class="fas fa-file-pdf"></i> Open PDF Brief
                                                                </a>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>

                                        <c:choose>
                                            <c:when test="${not empty selectedAssessmentLatest and empty selectedAssessmentLatest.score}">
                                                <div class="lh-post-assessment-card" style="max-width: 800px; padding: 40px; display: flex; align-items: flex-start; gap: 24px; text-align: left;">
                                                    <div class="lh-post-status-icon" style="background: var(--warning-soft); color: var(--warning); margin: 0; flex-shrink: 0;">
                                                            <i class="fas fa-clock-rotate-left"></i>
                                                        </div>
                                                        <div style="flex-grow: 1;">
                                                            <h2 class="lh-post-title" style="margin-bottom: 8px;">Assignment Awaiting Review</h2>
                                                            <p class="lh-post-desc" style="margin-bottom: 24px;">Your work has been submitted successfully and is currently awaiting grading by your instructor. You do not need to upload anything again.</p>
                                                            
                                                            <div style="padding: 16px; background: var(--surface-secondary); border-radius: var(--lh-radius-md); border: 1px solid var(--border-subtle);">
                                                                <div style="font-weight: 600; color: var(--text-primary); margin-bottom: 8px;">
                                                                    <i class="fas fa-file-alt" style="margin-right: 6px;"></i> Submitted File
                                                                </div>
                                                                <c:choose>
                                                                    <c:when test="${not empty selectedAssessmentLatest.answersFilePath}">
                                                                        <a href="${fn:escapeXml(selectedAssessmentLatest.answersFilePath)}" target="_blank" class="lh-aic-task-link" style="display: inline-flex;">
                                                                            <i class="fas fa-download"></i> Download Submitted File
                                                                        </a>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div style="color: var(--text-muted);">No attachment path found</div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <div style="margin-top: 12px; font-size: 0.9rem; color: var(--text-muted);">
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
                                                    
                                                    <div class="lh-post-assessment-card" style="max-width: 800px; padding: 40px; text-align: left;">
                                                        <div style="display: flex; align-items: flex-start; gap: 24px; margin-bottom: 32px;">
                                                            <div class="lh-post-status-icon ${hasPassedAssignment ? 'is-success' : 'is-error'}" style="margin: 0; flex-shrink: 0; width: 64px; height: 64px; font-size: 28px;">
                                                                <i class="fas ${hasPassedAssignment ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                                                            </div>
                                                            <div>
                                                                <h2 class="lh-post-title" style="margin-bottom: 8px;">Assignment Graded: ${hasPassedAssignment ? 'Passed' : 'Needs Improvement'}</h2>
                                                                <p class="lh-post-desc" style="margin-bottom: 0;">${hasPassedAssignment ? 'Excellent job! You have successfully cleared this assignment milestone.' : 'Your submission did not meet the required passing mark. Please review the instructor feedback below and resubmit if attempts are available.'}</p>
                                                            </div>
                                                        </div>
                                                        
                                                        <div class="lh-post-score-section" style="justify-content: flex-start; padding: 24px 0;">
                                                            <div class="lh-post-score-metric" style="align-items: flex-start;">
                                                                <span>Your Score</span>
                                                                <strong>${selectedAssessmentLatest.score} <span style="font-size: 1rem; color: var(--text-muted);">/ ${totalPoints}</span></strong>
                                                            </div>
                                                            <div style="width: 1px; height: 3rem; background: var(--border-subtle);"></div>
                                                            <div class="lh-post-score-metric" style="align-items: flex-start;">
                                                                <span>Percentage</span>
                                                                <strong style="color: ${hasPassedAssignment ? 'var(--success)' : 'var(--text-primary)'};"><fmt:formatNumber value="${(selectedAssessmentLatest.score / totalPoints) * 100}" maxFractionDigits="1"/>%</strong>
                                                            </div>
                                                            <div style="width: 1px; height: 3rem; background: var(--border-subtle);"></div>
                                                            <div class="lh-post-score-metric" style="align-items: flex-start;">
                                                                <span>Status</span>
                                                                <strong style="color: ${hasPassedAssignment ? 'var(--success)' : 'var(--danger)'};">${hasPassedAssignment ? 'PASSED' : 'RETAKE REQUIRED'}</strong>
                                                            </div>
                                                        </div>

                                                        <c:if test="${not empty selectedAssessmentLatest.feedback}">
                                                            <div style="margin-top: 24px; padding: 24px; background: color-mix(in srgb, var(--accent) 5%, transparent); border-left: 4px solid var(--accent); border-radius: 0 var(--lh-radius-md) var(--lh-radius-md) 0;">
                                                                <h5 style="font-size: 1.1rem; font-weight: 700; color: var(--text-primary); margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                                                                    <i class="fas fa-comment-dots" style="color: var(--accent);"></i> Instructor Feedback
                                                                </h5>
                                                                <p style="color: var(--text-secondary); line-height: 1.6; font-style: italic; margin: 0;">"<c:out value="${selectedAssessmentLatest.feedback}"/>"</p>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                    
                                                    <c:if test="${not hasPassedAssignment and selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                        <div style="width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; background-color: #ffffff; margin-top: 24px;">
                                                            <h3 style="font-size: 1.25rem; font-weight: 600; color: #0f172a; margin: 0 0 8px 0;"><i class="fas fa-rotate-left" style="color: #2563eb; margin-right: 6px;"></i> Submit Assignment Retake</h3>
                                                            <p style="color: #475569; margin: 0 0 24px 0; font-size: 0.9375rem;">Upload an updated file to improve your score. You have ${selectedAssessmentAllowedAttempts - selectedAssessmentUsedAttempts} attempt(s) remaining.</p>
                                                            
                                                            <form id="assignmentHubForm" method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" class="lh-upload-wrapper">
                                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                                                <div class="lh-upload-zone" data-upload-zone>
                                                                    <input name="answerFile" type="file" style="display: none;" required>
                                                                    <i class="fas fa-cloud-arrow-up lh-upload-zone__icon"></i>
                                                                    <h4 class="lh-upload-zone__text">Click to browse or drag your PDF answer file here</h4>
                                                                    <p class="lh-upload-zone__subtext">Supports PDF up to 50MB</p>
                                                                </div>

                                                                <button class="sv-btn primary" type="submit" data-submit-button data-loading-label="Submitting retake..." style="width: 100%;">
                                                                    <i class="fas fa-upload"></i><span>Submit Retake</span>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </c:if>

                                                    <c:if test="${not hasPassedAssignment and selectedAssessmentUsedAttempts >= selectedAssessmentAllowedAttempts}">
                                                         <div style="width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; background-color: #ffffff; margin-top: 24px;">
                                                             <h3 style="font-size: 1.25rem; font-weight: 600; color: #0f172a; margin: 0 0 8px 0;"><i class="fas fa-envelope" style="color: #d97706; margin-right: 6px;"></i> Request Assignment Retake</h3>
                                                             <p style="color: #475569; margin: 0 0 24px 0; font-size: 0.9375rem;">You have exhausted all allowed attempts for this assignment. If you failed to meet the passing threshold, you can request an additional attempt from your instructor.</p>
                                                             
                                                             <c:choose>
                                                                 <c:when test="${hasPendingRetakeRequest}">
                                                                     <button type="button" class="sv-btn" disabled="disabled" style="width: 100%; border-color: var(--warning); color: var(--warning);">
                                                                         <i class="fas fa-hourglass-half"></i>
                                                                         <span>Retake Request Pending</span>
                                                                     </button>
                                                                 </c:when>
                                                                 <c:otherwise>
                                                                     <form method="post" action="${pageContext.request.contextPath}/student/assessments" style="display: block; width: 100%; margin: 0;">
                                                                         <input type="hidden" name="action" value="requestRetake">
                                                                         <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                         <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                                         <button type="submit" class="sv-btn warning" style="width: 100%;">
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
                                                    <form id="assignmentHubForm" method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" class="lh-upload-wrapper" style="width: 100%;">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                                        <div class="lh-upload-zone" data-upload-zone>
                                                            <input name="answerFile" type="file" style="display: none;" required>
                                                            <i class="fas fa-cloud-arrow-up lh-upload-zone__icon"></i>
                                                            <h4 class="lh-upload-zone__text">Click to browse or drag your PDF answer file here</h4>
                                                            <p class="lh-upload-zone__subtext">Supports PDF up to 50MB</p>
                                                        </div>

                                                        <button class="sv-btn primary" type="submit" data-submit-button data-loading-label="Submitting assignment..." style="width: 100%;">
                                                                <i class="fas fa-upload"></i><span>Submit Assignment</span>
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:if>

                                <c:if test="${selectedAssessment.type != 'Assignment'}">
                                    <c:choose>
                                        <c:when test="${not empty selectedAssessmentLatest}">
                                            <c:set var="passThreshold" value="${totalPoints * 0.7}"/>
                                            <c:set var="hasPassedQuiz" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                            
                                            <div class="lh-post-assessment-container">
                                                <div class="lh-post-assessment-card">
                                                    <div class="lh-post-status-icon ${hasPassedQuiz ? 'is-success' : 'is-error'}">
                                                        <i class="fas ${hasPassedQuiz ? 'fa-medal' : 'fa-triangle-exclamation'}"></i>
                                                    </div>
                                                    
                                                    <h2 class="lh-post-title">${hasPassedQuiz ? 'Assessment Passed!' : 'Assessment Failed'}</h2>
                                                    
                                                    <p class="lh-post-desc">
                                                        <c:choose>
                                                            <c:when test="${hasPassedQuiz}">
                                                                Great work! You have successfully passed this assessment milestone. Review your score breakdown below or continue forward.
                                                            </c:when>
                                                            <c:otherwise>
                                                                Your score did not meet the 70% passing threshold for this milestone. Review the breakdown below and try again.
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </p>

                                                    <div class="lh-post-score-section">
                                                        <div class="lh-post-score-metric">
                                                            <span>Points Scored</span>
                                                            <strong>${selectedAssessmentLatest.score} <span style="font-size: 1rem; color: var(--text-muted);">/ ${totalPoints}</span></strong>
                                                        </div>
                                                        <div style="width: 1px; height: 3rem; background: var(--border-subtle);"></div>
                                                        <div class="lh-post-score-metric">
                                                            <span>Final Score</span>
                                                            <strong style="color: ${hasPassedQuiz ? 'var(--success)' : 'var(--text-primary)'};"><fmt:formatNumber value="${(selectedAssessmentLatest.score / totalPoints) * 100.0}" maxFractionDigits="0"/>%</strong>
                                                        </div>
                                                        <div style="width: 1px; height: 3rem; background: var(--border-subtle);"></div>
                                                        <div class="lh-post-score-metric">
                                                            <span>Attempts Used</span>
                                                            <strong>${selectedAssessmentUsedAttempts} <span style="font-size: 1rem; color: var(--text-muted);">/ ${selectedAssessmentAllowedAttempts}</span></strong>
                                                        </div>
                                                    </div>

                                                    <div class="lh-post-actions">
                                                        <a class="sv-btn secondary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${selectedAssessment.assessmentId}&submissionId=${selectedAssessmentLatest.submissionId}">
                                                            <i class="fas fa-chart-column"></i>
                                                            <span>View Details Breakdown</span>
                                                        </a>
                                                        
                                                        <c:choose>
                                                            <c:when test="${hasPassedQuiz}">
                                                                <button type="button" class="sv-btn primary" data-complete-and-continue>
                                                                    <span>Complete &amp; Continue</span>
                                                                    <i class="fas fa-arrow-right"></i>
                                                                </button>
                                                                <c:if test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                                    <a class="sv-btn secondary" href="${pageContext.request.contextPath}/student/assessments?assessmentId=${selectedAssessment.assessmentId}&enrollmentId=${enrollment.enrollmentId}&mode=attempt">
                                                                        <i class="fas fa-rotate-left"></i>
                                                                        <span>Retake Assessment</span>
                                                                    </a>
                                                                </c:if>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:choose>
                                                                    <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?assessmentId=${selectedAssessment.assessmentId}&enrollmentId=${enrollment.enrollmentId}&mode=attempt">
                                                                            <i class="fas fa-rotate-left"></i>
                                                                            <span>Retake Assessment</span>
                                                                        </a>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:choose>
                                                                            <c:when test="${hasPendingRetakeRequest}">
                                                                                <button type="button" class="sv-btn warning" disabled="disabled">
                                                                                    <i class="fas fa-hourglass-half"></i>
                                                                                    <span>Retake Request Pending</span>
                                                                                </button>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <form method="post" action="${pageContext.request.contextPath}/student/assessments" style="display: inline-block; margin: 0;">
                                                                                    <input type="hidden" name="action" value="requestRetake">
                                                                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                                    <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                                                    <button type="submit" class="sv-btn warning">
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
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="lh-assessment-intro-card">
                                                <div class="lh-aic-icon"><i class="fas fa-clipboard-question"></i></div>
                                                <h2 class="lh-aic-title">${selectedAssessment.title}</h2>
                                                
                                                <p class="lh-aic-desc">
                                                    <c:choose>
                                                        <c:when test="${not empty selectedAssessmentInstructions}">${selectedAssessmentInstructions}</c:when>
                                                        <c:otherwise>This is a timed objective evaluation. Ensure you have a stable connection before beginning.</c:otherwise>
                                                    </c:choose>
                                                </p>
                                                
                                                <div class="lh-aic-stats">
                                                    <div class="lh-aic-stat">
                                                        <span class="lh-aic-stat-val">${fn:length(selectedAssessmentQuestions)}</span>
                                                        <span class="lh-aic-stat-lbl">Questions</span>
                                                    </div>
                                                    <div class="lh-aic-stat">
                                                        <span class="lh-aic-stat-val">${selectedAssessment.duration != null ? selectedAssessment.duration : '30'}m</span>
                                                        <span class="lh-aic-stat-lbl">Time Limit</span>
                                                    </div>
                                                    <div class="lh-aic-stat">
                                                        <span class="lh-aic-stat-val">70%</span>
                                                        <span class="lh-aic-stat-lbl">Passing</span>
                                                    </div>
                                                    <div class="lh-aic-stat">
                                                        <span class="lh-aic-stat-val">${selectedAssessmentAllowedAttempts - selectedAssessmentUsedAttempts}</span>
                                                        <span class="lh-aic-stat-lbl">Attempts Left</span>
                                                    </div>
                                                </div>

                                                <c:choose>
                                                    <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                        <a class="lh-aic-start-btn" 
                                                           href="${pageContext.request.contextPath}/student/assessments?assessmentId=${selectedAssessment.assessmentId}&enrollmentId=${enrollment.enrollmentId}&mode=attempt">
                                                            <span>${selectedAssessmentPrimaryLabel}</span>
                                                            <i class="fas fa-arrow-right"></i>
                                                        </a>
                                                        <div class="lh-aic-note"><i class="fas fa-info-circle"></i> Do not refresh the page or close your browser once started.</div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="lh-aic-start-btn is-disabled" disabled="disabled">
                                                            <i class="fas fa-ban"></i>
                                                            <span>No Attempts Remaining</span>
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
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
                                <%-- Course Overview Dashboard (Modern Coursera-like UI) --%>
                                <c:otherwise>
                                    <div class="lh-overview">
                                        <div class="lh-overview-hero" style="background: linear-gradient(135deg, var(--surface-secondary), var(--surface-primary)); padding: var(--lh-space-6); border-radius: var(--lh-radius-lg); border: 1px solid var(--border-subtle); display: flex; flex-direction: column; gap: var(--lh-space-4);">
                                            <h2 class="lh-overview-hero__title" style="margin: 0; font-family: var(--lh-font-display); font-size: clamp(1.5rem, 2vw, 2.25rem); font-weight: 800; color: var(--text-primary); letter-spacing: -0.02em;">Welcome back to <span style="color: var(--accent);">${enrollment.courseName}</span></h2>
                                            <p class="lh-overview-hero__desc" style="margin: 0; font-size: 1.1rem; color: var(--text-secondary); max-width: 65ch; line-height: 1.6;">Resume your learning journey. You're making great progress towards your certificate!</p>
                                            
                                            <div class="lh-overview-stats" style="display: flex; gap: var(--lh-space-6); margin-top: var(--lh-space-4); flex-wrap: wrap;">
                                                <div class="lh-overview-stat" style="display: flex; flex-direction: column; gap: var(--lh-space-2);">
                                                    <span style="font-size: var(--lh-font-size-xs); color: var(--text-muted); text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Materials Viewed</span>
                                                    <strong style="font-size: 1.75rem; font-family: var(--lh-font-display); font-weight: 800; line-height: 1;"><span style="${materialsViewedCount >= materialCount ? 'color: var(--success);' : ''}">${materialsViewedCount}</span> <span style="font-size: 1rem; color: var(--text-muted);">/ ${materialCount}</span></strong>
                                                </div>
                                                <div class="lh-overview-stat" style="display: flex; flex-direction: column; gap: var(--lh-space-2);">
                                                    <span style="font-size: var(--lh-font-size-xs); color: var(--text-muted); text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Assessments Passed</span>
                                                    <strong style="font-size: 1.75rem; font-family: var(--lh-font-display); font-weight: 800; line-height: 1;"><span style="${passedAssessmentsCount >= assessmentCount ? 'color: var(--success);' : ''}">${passedAssessmentsCount}</span> <span style="font-size: 1rem; color: var(--text-muted);">/ ${assessmentCount}</span></strong>
                                                </div>
                                                <div class="lh-overview-stat" style="display: flex; flex-direction: column; gap: var(--lh-space-2);">
                                                    <span style="font-size: var(--lh-font-size-xs); color: var(--text-muted); text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Current Grade</span>
                                                    <strong style="font-size: 1.75rem; font-family: var(--lh-font-display); font-weight: 800; line-height: 1; color: ${overallPerformance >= 70 ? 'var(--success)' : 'var(--text-primary)'};"><fmt:formatNumber value="${overallPerformance}" maxFractionDigits="1"/>%</strong>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="lh-cert-overview-card">
                                            <div class="lh-cert-overview-card__content">
                                                <div class="lh-cert-icon" style="width: 3.5rem; height: 3.5rem; display: flex; align-items: center; justify-content: center; border-radius: 50%; background: ${progressPercent >= 100 ? 'var(--success-soft)' : 'var(--surface-tertiary)'}; color: ${progressPercent >= 100 ? 'var(--success)' : 'var(--text-muted)'}; font-size: 1.5rem;">
                                                    <i class="fas ${progressPercent >= 100 ? 'fa-medal' : 'fa-lock'}"></i>
                                                </div>
                                                <div class="lh-status-copy">
                                                    <h4>Course Certificate</h4>
                                                    <p>Complete all modules and assessments to earn your official credential.</p>
                                                </div>
                                            </div>
                                            <div class="lh-cert-overview-card__actions">
                                                <c:choose>
                                                    <c:when test="${not empty userCertificate}">
                                                        <a href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${enrollment.enrollmentId}" class="sv-btn primary">
                                                            <i class="fas fa-download"></i> View Certificate
                                                        </a>
                                                    </c:when>
                                                    <c:when test="${certificateEligible}">
                                                        <form method="post" action="${pageContext.request.contextPath}/student/certificate" style="margin: 0;">
                                                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                            <button type="submit" class="sv-btn primary">
                                                                <i class="fas fa-award"></i> Claim Certificate
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="lh-score-bar-container" style="min-width: 12rem;">
                                                            <div class="lh-score-bar">
                                                                <div class="lh-score-bar-fill" style="width: ${progressPercent}%;"></div>
                                                            </div>
                                                            <span class="lh-score-bar-label">${progressPercent}%</span>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>

                            </c:choose>
                        </div>
                    </c:otherwise>
                </c:choose>
        </div><%-- /lh-content-stage --%>
</main><%-- /lh-main --%>


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
    
    if (btn.getAttribute('aria-disabled') === 'true') return;
    
    btn.setAttribute('aria-disabled', 'true');
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

// Mobile sidebar toggle logic is handled by learning-hub.js

document.addEventListener('DOMContentLoaded', function() {
    // Universal Sidebar Toggle
    var toggleBtn = document.getElementById('hubMobileToggle');
    var overlay = document.getElementById('hubMobileOverlay');
    
    function toggleSidebar() {
        if (window.innerWidth <= 1100) {
            document.body.classList.toggle('lh-sidebar-open');
            var isOpen = document.body.classList.contains('lh-sidebar-open');
            if (overlay) {
                overlay.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
                overlay.style.display = isOpen ? 'block' : 'none';
            }
        } else {
            document.body.classList.toggle('lh-sidebar-desktop-closed');
        }
    }
    
    if (toggleBtn) {
        toggleBtn.addEventListener('click', toggleSidebar);
    }
    if (overlay) {
        overlay.addEventListener('click', function() {
            document.body.classList.remove('lh-sidebar-open');
            overlay.setAttribute('aria-hidden', 'true');
            overlay.style.display = 'none';
        });
    }

    // Scroll active item into view
    var activeItem = document.querySelector('.lh-chapter-item.is-active');
    if (activeItem) {
        setTimeout(function() { activeItem.scrollIntoView({ block: 'nearest', behavior: 'smooth' }); }, 200);
    }
});
</script>
<script src="${pageContext.request.contextPath}/js/learning-hub.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
