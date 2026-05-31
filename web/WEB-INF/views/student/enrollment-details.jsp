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
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="hub_backBtn" aria-label="Return to My Courses">
            <i class="fas fa-arrow-left" aria-hidden="true"></i>
            <span>Back to Dashboard</span>
        </a>
        <h1 class="hub_courseTitle" title="${enrollment.courseName}">${enrollment.courseName}</h1>
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
                        <section class="sa-shell lh-result-shell">
                            <article class="sa-result-card sa-panel">
                                <div class="sa-panel-head">
                                    <div>
                                        <h3>${assessmentResultAssessment.title}</h3>
                                        <p>
                                            Submission date:
                                            <c:choose>
                                                <c:when test="${not empty assessmentResultSubmission.submitDate}">${fn:replace(assessmentResultSubmission.submitDate, 'T', ' ')}</c:when>
                                                <c:otherwise>--</c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty assessmentResultSubmission.endedAt}">
                                                | Ended: ${fn:replace(assessmentResultSubmission.endedAt, 'T', ' ')}
                                            </c:if>
                                        </p>
                                    </div>
                                    <span class="sa-status ${assessmentResultStatusClass}">${assessmentResultStatusLabel}</span>
                                </div>

                                <div class="sa-result-score">
                                    <div class="sa-score-card">
                                        <span>Score</span>
                                        <strong><c:choose><c:when test="${not empty assessmentResultSubmission.score}">${assessmentResultSubmission.score}</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                                    </div>
                                    <div class="sa-score-card">
                                        <span>Percentage</span>
                                        <strong><c:choose><c:when test="${assessmentResultPercentage > 0}">${assessmentResultPercentage}%</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                                    </div>
                                    <div class="sa-score-card">
                                        <span>Attempt</span>
                                        <strong>#${assessmentResultSubmission.attemptNumber}</strong>
                                    </div>
                                    <div class="sa-score-card">
                                        <span>Format</span>
                                        <strong><c:choose><c:when test="${assessmentResultObjective}">Multiple Choice</c:when><c:otherwise>Assignment</c:otherwise></c:choose></strong>
                                    </div>
                                </div>

                                <div class="sa-note ${not empty assessmentResultSubmission.score ? 'success' : 'warning'} lh-mt-18">
                                    <c:choose>
                                        <c:when test="${not empty assessmentResultSubmission.feedback}">
                                            <strong>Instructor feedback:</strong> ${assessmentResultSubmission.feedback}
                                        </c:when>
                                        <c:when test="${not empty assessmentResultSubmission.score}">
                                            This submission has been graded automatically.
                                        </c:when>
                                        <c:otherwise>
                                            The submission is awaiting instructor review.
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="sa-detail-grid lh-mt-18">
                                    <div class="sa-detail-list">
                                        <div class="sa-detail-item">
                                            <span>Status</span>
                                            <strong>${assessmentResultStatusLabel}</strong>
                                        </div>
                                        <div class="sa-detail-item">
                                            <span>Attempt</span>
                                            <strong>#${assessmentResultSubmission.attemptNumber}</strong>
                                        </div>
                                        <div class="sa-detail-item">
                                            <span>Submitted</span>
                                            <strong>
                                                <c:choose>
                                                    <c:when test="${not empty assessmentResultSubmission.submitDate}">${fn:replace(assessmentResultSubmission.submitDate, 'T', ' ')}</c:when>
                                                    <c:otherwise>--</c:otherwise>
                                                </c:choose>
                                            </strong>
                                        </div>
                                    </div>
                                    <div class="sa-detail-list">
                                        <div class="sa-detail-item">
                                            <span>Result format</span>
                                            <strong><c:choose><c:when test="${assessmentResultObjective}">Multiple Choice</c:when><c:otherwise>Assignment</c:otherwise></c:choose></strong>
                                        </div>
                                        <div class="sa-detail-item">
                                            <span>Graded date</span>
                                            <strong>
                                                <c:choose>
                                                    <c:when test="${not empty assessmentResultSubmission.endedAt}">${fn:replace(assessmentResultSubmission.endedAt, 'T', ' ')}</c:when>
                                                    <c:otherwise>--</c:otherwise>
                                                </c:choose>
                                            </strong>
                                        </div>
                                        <div class="sa-detail-item">
                                            <span>Submission payload</span>
                                            <p>
                                                <c:choose>
                                                    <c:when test="${not empty assessmentResultSubmission.answersFilePath}">${assessmentResultSubmission.answersFilePath}</c:when>
                                                    <c:otherwise>--</c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </article>

                            <c:if test="${assessmentResultObjective and not empty assessmentResultQuestions}">
                                <article class="sa-panel lh-mt-18">
                                    <div class="sa-panel-head">
                                        <div>
                                            <h3>Performance breakdown</h3>
                                        </div>
                                    </div>

                                    <div class="sa-breakdown">
                                        <c:forEach var="q" items="${assessmentResultQuestions}" varStatus="loop">
                                            <div class="sa-breakdown-item">
                                                <h4>Q${loop.index + 1}. ${q.questionText}</h4>
                                                <p><strong>Your answer:</strong> <c:out value="${empty assessmentResultStudentAnswers[q.questionId] ? '--' : assessmentResultStudentAnswers[q.questionId]}"/></p>
                                                <p><strong>Correct answer:</strong> <c:out value="${empty assessmentResultCorrectAnswers[q.questionId] ? '--' : assessmentResultCorrectAnswers[q.questionId]}"/></p>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </article>
                            </c:if>

                            <div class="sa-footer-actions lh-mt-18">
                                <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments"><i class="fas fa-arrow-left"></i> Back to Assessments</a>
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=performance"><i class="fas fa-chart-column"></i> Performance</a>
                            </div>
                        </section>
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
                        <c:set var="isAttempting" value="${(param.attempt == 'true' || selectedAssessmentStatusLabel == 'Active') && selectedAssessment.type != 'Assignment'}"/>
                        <c:choose>
                            <c:when test="${isAttempting}">
                                <section class="ax-shell" data-attempt-shell>
                                    <article class="ax-frame ax-focus__hero">
                                        <div>
                                            <span class="ax-overview__eyebrow"><i class="fas fa-shield-halved"></i> Active Assessment</span>
                                            <h1 class="ax-focus__title">${selectedAssessment.title}</h1>
                                            <p class="ax-focus__body">
                                                <c:choose>
                                                    <c:when test="${not empty selectedAssessmentInstructions}">${selectedAssessmentInstructions}</c:when>
                                                    <c:otherwise>Move through each question using the stepper, keep the syllabus visible, and submit without leaving the Learning Hub.</c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                        <div class="ax-timer" data-timer>
                                            <i class="fas fa-clock"></i>
                                            <span data-timer-text>00:00</span>
                                        </div>
                                    </article>

                                    <div class="ax-layout">
                                        <section class="ax-panel">
                                            <div class="ax-progress">
                                                <div class="ax-progress__meta">
                                                    <span>Question <strong data-current-question>1</strong> of ${fn:length(selectedAssessmentQuestions)}</span>
                                                    <span>Completion progress</span>
                                                </div>
                                                <div class="ax-progress__bar">
                                                    <div class="ax-progress__fill" data-progress-fill></div>
                                                </div>
                                            </div>

                                            <div class="ax-stepper">
                                                <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                    <button type="button" class="ax-stepper__item ${loop.first ? 'is-active' : ''}" data-step-index="${loop.index}">${loop.index + 1}</button>
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
                                                        <strong>Submit when your answers are ready</strong>
                                                        <span>The timer, sidebar, and Learning Hub navigation remain visible while you work.</span>
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
                                                        <button type="submit" class="ax-btn ax-btn--primary" data-submit-button>
                                                            <i class="fas fa-paper-plane"></i>
                                                            <span>Submit Assessment</span>
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </section>

                                        <aside class="ax-side-panel">
                                            <h2 class="ax-side-panel__title">Assessment Snapshot</h2>
                                            <p class="ax-side-panel__copy">This attempt is nested directly inside the Learning Hub main content area.</p>
                                            <div class="ax-review-list ax-review-list--offset">
                                                <div class="ax-inline-card">
                                                    <i class="fas fa-clock"></i>
                                                    <div><span>Time Limit</span><strong>${selectedAssessment.duration != null ? selectedAssessment.duration : '--'}${selectedAssessment.duration != null ? ' min' : ''}</strong></div>
                                                </div>
                                                <div class="ax-inline-card">
                                                    <i class="fas fa-list-check"></i>
                                                    <div><span>Questions</span><strong>${fn:length(selectedAssessmentQuestions)}</strong></div>
                                                </div>
                                                <div class="ax-inline-card">
                                                    <i class="fas fa-repeat"></i>
                                                    <div><span>Attempt</span><strong>${selectedAssessmentUsedAttempts + 1} of ${selectedAssessmentAllowedAttempts}</strong></div>
                                                </div>
                                                <div class="ax-inline-card">
                                                    <i class="fas fa-bullseye"></i>
                                                    <div><span>Passing Score</span><strong>70%</strong></div>
                                                </div>
                                            </div>
                                        </aside>
                                    </div>
                                </section>
                            </c:when>
                            <c:otherwise>
                                        <c:if test="${not courseAccessGranted}">
                                            <div class="lh-stage-notice is-warning">
                                                <i class="fas fa-lock"></i>
                                                <div>
                                                    <strong>Assessment access is locked.</strong>
                                                    <p>Complete payment first to continue through the assessment flow.</p>
                                                </div>
                                            </div>
                                        </c:if>

                                        <c:if test="${courseAccessGranted and selectedAssessment.type == 'Assignment'}">
                                            <h3 class="lh-card-title">Assignment Workspace</h3>
                                            <p class="lh-card-copy">Submit and review your assignment materials directly from the learning hub workspace.</p>

                                            <c:if test="${not empty selectedAssessmentQuestions}">
                                                <div class="lh-assignment-prompt-box">
                                                    <h4 class="lh-assignment-prompt-box__title"><i class="fas fa-file-signature"></i> Assignment Prompt & Tasks</h4>
                                                    <div class="lh-assignment-prompt-box__items">
                                                        <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                            <div class="lh-assignment-prompt-box__item">
                                                                <strong class="lh-assignment-prompt-box__task-label">Task ${loop.index + 1}</strong>
                                                                <div class="lh-assignment-prompt-box__text"><c:out value="${q.questionText}"/></div>
                                                                <c:if test="${not empty q.attachmentUrl}">
                                                                    <div class="lh-assignment-prompt-box__attachment">
                                                                        <a class="sv-btn" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
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
                                                    <div class="lh-assignment-status-card is-pending">
                                                        <div class="status-icon-wrapper">
                                                            <i class="fas fa-clock-rotate-left fa-spin-hover"></i>
                                                        </div>
                                                        <div class="status-details">
                                                            <h4>Assignment Awaiting Review</h4>
                                                            <p>Your work has been submitted successfully and is currently awaiting grading by your instructor. You do not need to upload anything again.</p>
                                                            <div class="submission-file-meta">
                                                                <span><i class="fas fa-file-alt"></i> Submitted File:</span>
                                                                <c:choose>
                                                                    <c:when test="${not empty selectedAssessmentLatest.answersFilePath}">
                                                                        <a href="${fn:escapeXml(selectedAssessmentLatest.answersFilePath)}" target="_blank" class="file-download-link">
                                                                            Download Submitted File
                                                                            <i class="fas fa-arrow-up-right-from-square lh-icon-gap"></i>
                                                                        </a>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted">No attachment path found</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <div class="submission-date-meta">
                                                                <span><i class="fas fa-calendar-day"></i> Submitted On:</span>
                                                                <strong>${fn:replace(selectedAssessmentLatest.submitDate, 'T', ' ')}</strong>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:when>

                                                <c:when test="${not empty selectedAssessmentLatest and not empty selectedAssessmentLatest.score}">
                                                    <c:set var="passThreshold" value="${selectedAssessment.totalMarks * 0.7}"/>
                                                    <c:set var="hasPassedAssignment" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                                    
                                                    <div class="lh-assignment-status-card ${hasPassedAssignment ? 'is-success' : 'is-error'}">
                                                        <div class="status-icon-wrapper">
                                                            <i class="fas fa-${hasPassedAssignment ? 'circle-check' : 'circle-xmark'}"></i>
                                                        </div>
                                                        <div class="status-details">
                                                            <h4>Assignment Graded: ${hasPassedAssignment ? 'Passed' : 'Needs Improvement'}</h4>
                                                            <p>${hasPassedAssignment ? 'Excellent job! You have successfully cleared this assignment milestone.' : 'Your submission did not meet the required passing mark. Please review the instructor feedback below and resubmit if attempts are available.'}</p>
                                                            
                                                            <div class="assignment-score-strip">
                                                                <div class="score-pill">
                                                                    <span>Your Score</span>
                                                                    <strong>${selectedAssessmentLatest.score} / ${selectedAssessment.totalMarks}</strong>
                                                                </div>
                                                                <div class="score-pill">
                                                                    <span>Percentage</span>
                                                                    <strong><fmt:formatNumber value="${(selectedAssessmentLatest.score / selectedAssessment.totalMarks) * 100}" maxFractionDigits="1"/>%</strong>
                                                                </div>
                                                                <div class="score-pill">
                                                                    <span>Status</span>
                                                                    <strong class="status-${hasPassedAssignment ? 'pass' : 'fail'}">${hasPassedAssignment ? 'PASSED' : 'RETAKE REQUIRED'}</strong>
                                                                </div>
                                                            </div>

                                                            <c:if test="${not empty selectedAssessmentLatest.feedback}">
                                                                <div class="instructor-feedback-box">
                                                                    <h5><i class="fas fa-comment-dots"></i> Instructor Feedback</h5>
                                                                    <p>"<c:out value="${selectedAssessmentLatest.feedback}"/>"</p>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    
                                                    <c:if test="${not hasPassedAssignment and selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                        <div class="lh-stage-card is-retry lh-stage-card--outlined lh-mt-20">
                                                            <h3 class="lh-card-title"><i class="fas fa-rotate-left"></i> Submit Assignment Retake</h3>
                                                            <p class="lh-card-copy">Upload an updated file to improve your score. You have ${selectedAssessmentAllowedAttempts - selectedAssessmentUsedAttempts} attempt(s) remaining.</p>
                                                            
                                                            <form id="assignmentHubForm" method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" class="lh-assignment-form">
                                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                                                <div class="assignment-upload-box">
                                                                    <c:if test="${not empty selectedAssessmentQuestions}">
                                                                        <div class="lh-assignment-prompt-box__items">
                                                                            <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                                                <c:if test="${not empty q.attachmentUrl}">
                                                                                    <div class="lh-assignment-prompt-box__attachment">
                                                                                        <a class="sv-btn" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                                                                            <i class="fas fa-file-pdf"></i> Open Brief for Task ${loop.index + 1}
                                                                                        </a>
                                                                                    </div>
                                                                                </c:if>
                                                                            </c:forEach>
                                                                        </div>
                                                                    </c:if>
                                                                    <div class="lh-upload-zone" onclick="document.getElementById('answerFileHubRetake').click()">
                                                                        <div class="lh-upload-zone__icon">
                                                                            <i class="fas fa-cloud-arrow-up"></i>
                                                                        </div>
                                                                        <div class="lh-upload-zone__copy">
                                                                            <strong>Drag &amp; drop file here or <span class="lh-upload-zone__highlight">browse</span></strong>
                                                                            <p class="lh-upload-zone__specs">Supports PDF, DOCX, ZIP, PPTX (Max 50MB)</p>
                                                                        </div>
                                                                        <input id="answerFileHubRetake" name="answerFile" type="file" required class="lh-visually-hidden-input" onchange="updateHubFileName(this, true)">
                                                                        <div class="lh-upload-zone__selected-file is-hidden" id="selectedFileHubNameRetake">
                                                                            <i class="fas fa-file-circle-check"></i>
                                                                            <span id="fileNameHubTextRetake"></span>
                                                                        </div>
                                                                    </div>
                                                                </div>

                                                                <div class="assessment-actions lh-assessment-actions">
                                                                    <button class="sv-btn primary" type="submit">
                                                                        <i class="fas fa-upload"></i>&nbsp;Submit Retake Submission
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </c:if>
                                                </c:when>

                                                <c:otherwise>
                                                    <form id="assignmentHubForm" method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" class="lh-assignment-form">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                                        <div class="assignment-upload-box">
                                                            <c:if test="${not empty selectedAssessmentQuestions}">
                                                                <div class="lh-assignment-prompt-box__items">
                                                                    <c:forEach var="q" items="${selectedAssessmentQuestions}" varStatus="loop">
                                                                        <c:if test="${not empty q.attachmentUrl}">
                                                                            <div class="lh-assignment-prompt-box__attachment">
                                                                                <a class="sv-btn" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                                                                    <i class="fas fa-file-pdf"></i> Open Brief for Task ${loop.index + 1}
                                                                                </a>
                                                                            </div>
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </div>
                                                            </c:if>
                                                            <div class="lh-upload-zone" onclick="document.getElementById('answerFileHubInitial').click()">
                                                                <div class="lh-upload-zone__icon">
                                                                    <i class="fas fa-cloud-arrow-up"></i>
                                                                </div>
                                                                <div class="lh-upload-zone__copy">
                                                                    <strong>Drag &amp; drop file here or <span class="lh-upload-zone__highlight">browse</span></strong>
                                                                    <p class="lh-upload-zone__specs">Supports PDF, DOCX, ZIP, PPTX (Max 50MB)</p>
                                                                </div>
                                                                <input id="answerFileHubInitial" name="answerFile" type="file" required class="lh-visually-hidden-input" onchange="updateHubFileName(this, false)">
                                                                <div class="lh-upload-zone__selected-file is-hidden" id="selectedFileHubNameInitial">
                                                                    <i class="fas fa-file-circle-check"></i>
                                                                    <span id="fileNameHubTextInitial"></span>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="assessment-actions lh-assessment-actions">
                                                            <button class="sv-btn primary" type="submit">
                                                                <i class="fas fa-upload"></i>&nbsp;Submit Assignment
                                                            </button>
                                                        </div>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>

                                        <c:if test="${selectedAssessment.type != 'Assignment'}">
                                            <c:choose>
                                                <c:when test="${not empty selectedAssessmentLatest}">
                                                    <c:set var="passThreshold" value="${selectedAssessment.totalMarks * 0.7}"/>
                                                    <c:set var="hasPassedQuiz" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                                    <c:choose>
                                                        <c:when test="${hasPassedQuiz}">
                                                            <div class="lh-post-assessment-container">
                                                                <div class="lh-post-assessment-card is-passed">
                                                                    <div class="lh-post-status-icon">
                                                                        <i class="fas fa-circle-check"></i>
                                                                    </div>
                                                                    <h3 class="lh-post-title">Assessment Cleared!</h3>
                                                                    <p class="lh-post-desc">Congratulations! You achieved the required score to clear this milestone. Review your breakdown below or continue forward.</p>
                                                                    
                                                                    <div class="lh-post-score-section">
                                                                        <div class="lh-post-score-dial">
                                                                            <span class="lh-dial-score"><fmt:formatNumber value="${selectedAssessmentLatest.score}" maxFractionDigits="1"/></span>
                                                                            <span class="lh-dial-total">/ ${selectedAssessment.totalMarks}</span>
                                                                        </div>
                                                                        
                                                                        <div class="lh-post-score-meta">
                                                                            <div class="lh-score-percentage is-success">
                                                                                Score: <fmt:formatNumber value="${(selectedAssessmentLatest.score / selectedAssessment.totalMarks) * 100.0}" maxFractionDigits="0"/>%
                                                                            </div>
                                                                            <div class="lh-score-attempts">
                                                                                Attempts Used: <strong>${selectedAssessmentUsedAttempts} / ${selectedAssessmentAllowedAttempts}</strong>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    
                                                                    <div class="lh-post-actions">
                                                                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${selectedAssessment.assessmentId}&submissionId=${selectedAssessmentLatest.submissionId}">
                                                                            <i class="fas fa-chart-column"></i>
                                                                            <span>View Results Breakdown</span>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="lh-post-assessment-container">
                                                                <div class="lh-post-assessment-card is-failed">
                                                                    <div class="lh-post-status-icon">
                                                                        <i class="fas fa-circle-xmark"></i>
                                                                    </div>
                                                                    <h3 class="lh-post-title">Retake Required</h3>
                                                                    <p class="lh-post-desc">Your score did not meet the required 70% passing threshold for this milestone. Review the breakdown and try again if attempts remain.</p>
                                                                    
                                                                    <div class="lh-post-score-section">
                                                                        <div class="lh-post-score-dial">
                                                                            <span class="lh-dial-score"><fmt:formatNumber value="${selectedAssessmentLatest.score}" maxFractionDigits="1"/></span>
                                                                            <span class="lh-dial-total">/ ${selectedAssessment.totalMarks}</span>
                                                                        </div>
                                                                        
                                                                        <div class="lh-post-score-meta">
                                                                            <div class="lh-score-percentage is-error">
                                                                                Score: <fmt:formatNumber value="${(selectedAssessmentLatest.score / selectedAssessment.totalMarks) * 100.0}" maxFractionDigits="0"/>%
                                                                            </div>
                                                                            <div class="lh-score-attempts">
                                                                                Attempts Used: <strong>${selectedAssessmentUsedAttempts} / ${selectedAssessmentAllowedAttempts}</strong>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    
                                                                    <div class="lh-post-actions">
                                                                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${selectedAssessment.assessmentId}&submissionId=${selectedAssessmentLatest.submissionId}">
                                                                            <i class="fas fa-chart-column"></i>
                                                                            <span>View Results Breakdown</span>
                                                                        </a>
                                                                        <c:choose>
                                                                            <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                                                <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                                    <i class="fas fa-rotate-left"></i>
                                                                                    <span>Retake Assessment</span>
                                                                                </a>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <button class="sv-btn" disabled="disabled" title="No attempts remaining">
                                                                                    <i class="fas fa-ban"></i>
                                                                                    <span>No Attempts Left</span>
                                                                                </button>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <c:if test="${selectedAssessmentUsedAttempts >= selectedAssessmentAllowedAttempts}">
                                                                        <p class="lh-help-text">Please contact your course administrator to request an attempt reset.</p>
                                                                    </c:if>
                                                                </div>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="lh-pre-assessment-container">
                                                        <div class="lh-pre-assessment-hero">
                                                            <div class="lh-pre-assessment-badge">
                                                                <i class="fas fa-list-check"></i>
                                                            </div>
                                                            <h3 class="lh-pre-assessment-title">${selectedAssessment.title}</h3>
                                                            <p class="lh-pre-assessment-desc">
                                                                <c:choose>
                                                                    <c:when test="${not empty selectedAssessmentInstructions}">${selectedAssessmentInstructions}</c:when>
                                                                    <c:otherwise>Take this objective evaluation within the secure Learning Hub interface. Once started, the timer will begin and your attempts will count toward course milestones.</c:otherwise>
                                                                </c:choose>
                                                            </p>
                                                        </div>
                                                        
                                                        <div class="lh-pre-assessment-meta-grid">
                                                            <div class="lh-pre-assessment-meta-card">
                                                                <div class="lh-meta-icon"><i class="fas fa-clock"></i></div>
                                                                <div class="lh-meta-details">
                                                                    <span>Time Limit</span>
                                                                    <strong>${selectedAssessment.duration != null ? selectedAssessment.duration : '30'} minutes</strong>
                                                                </div>
                                                            </div>
                                                            <div class="lh-pre-assessment-meta-card">
                                                                <div class="lh-meta-icon"><i class="fas fa-clipboard-question"></i></div>
                                                                <div class="lh-meta-details">
                                                                    <span>Questions</span>
                                                                    <strong>${fn:length(selectedAssessmentQuestions)} Items</strong>
                                                                </div>
                                                            </div>
                                                            <div class="lh-pre-assessment-meta-card">
                                                                <div class="lh-meta-icon"><i class="fas fa-bullseye"></i></div>
                                                                <div class="lh-meta-details">
                                                                    <span>Passing Grade</span>
                                                                    <strong>70% Score</strong>
                                                                </div>
                                                            </div>
                                                            <div class="lh-pre-assessment-meta-card">
                                                                <div class="lh-meta-icon"><i class="fas fa-arrows-spin"></i></div>
                                                                <div class="lh-meta-details">
                                                                    <span>Attempts</span>
                                                                    <strong>${selectedAssessmentUsedAttempts} / ${selectedAssessmentAllowedAttempts} Used</strong>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        
                                                        <div class="lh-pre-assessment-alert">
                                                            <i class="fas fa-circle-info"></i>
                                                            <div class="lh-alert-text">
                                                                <strong>Important Rules:</strong> Do not refresh the page, close the browser window, or switch tabs while the assessment is running. Your answers are auto-saved, but leaving the workspace unexpectedly may cause the attempt to submit immediately.
                                                            </div>
                                                        </div>
                                                        
                                                        <div class="lh-pre-assessment-actions">
                                                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                <i class="fas fa-play"></i>
                                                                <span>${selectedAssessmentPrimaryLabel}</span>
                                                            </a>
                                                        </div>
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
</script>
<script src="${pageContext.request.contextPath}/js/learning-hub.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
</body>
</html>
