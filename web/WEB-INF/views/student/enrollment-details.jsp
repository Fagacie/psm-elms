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
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/learning-hub.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-module.css">
</head>
<body class="sv-page lh-shell-page"
      data-context-path="${pageContext.request.contextPath}"
      data-progress-percent="${progressPercent}"
      data-material-count="${materialCount}"
      data-current-material-type="${not empty selectedMaterial ? selectedMaterial.materialType : ''}"
      data-current-selection-mode="${selectedMode}"
      data-material-completed="${selectedMaterialStatus == 'completed'}"
      data-course-expired="${courseExpired}">
<c:set var="topbarTitle" value="Learning Hub"/>
<c:set var="topbarSubtitle" value=""/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <aside class="sv-sidebar lh-course-sidebar" id="svSidebar" aria-label="Course flow navigation">
        <div class="lh-course-sidebar__header">
            <div class="lh-sidebar-back-row">
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="lh-sidebar-back-link">
                    <i class="fas fa-arrow-left lh-sidebar-back-link__icon"></i> <span>My Courses</span>
                </a>
            </div>
            <h2 class="lh-course-sidebar__title">${enrollment.courseName}</h2>
            <div class="lh-sidebar-progress">
                <div class="lh-sidebar-progress__row">
                    <span>Progress</span>
                    <strong id="lhSidebarProgressPercent">${progressPercent}%</strong>
                </div>
                <div class="sv-progress lh-sidebar-progress__bar">
                    <div class="sv-progress-bar" id="lhSidebarProgressBar" data-progress="${progressPercent}"></div>
                </div>
            </div>
            
            <div class="lh-sidebar-duration">
                <div class="lh-sidebar-duration__row">
                    <span class="lh-sidebar-duration__label"><i class="far fa-clock lh-sidebar-duration__icon"></i> Course Duration:</span>
                    <strong class="lh-sidebar-duration__value">${courseDuration}</strong>
                </div>
                <c:if test="${not empty courseEndDate && courseEndDate != '-'}">
                    <div class="lh-sidebar-duration__row">
                        <span class="lh-sidebar-duration__label"><i class="far fa-calendar lh-sidebar-duration__icon"></i> Ends On:</span>
                        <strong class="lh-sidebar-duration__value">${courseEndDate}</strong>
                    </div>
                </c:if>
                <c:if test="${daysRemaining >= 0}">
                    <div class="lh-sidebar-duration__row">
                        <span class="lh-sidebar-duration__label"><i class="fas fa-hourglass-half lh-sidebar-duration__icon"></i> Time Left:</span>
                        <strong class="lh-sidebar-duration__value ${daysRemaining <= 2 ? 'is-urgent' : 'is-calm'}">${daysRemaining} Days</strong>
                    </div>
                </c:if>
                <c:if test="${courseExpired}">
                    <div class="lh-sidebar-duration__alert">
                        <i class="fas fa-exclamation-triangle"></i> Course Expired
                    </div>
                </c:if>
            </div>
        </div>

        <div class="lh-course-sidebar__scroll">
            <nav class="lh-course-flow" id="lhCourseFlow">

                
                <c:forEach var="item" items="${learningItems}">
                    <a href="${item.navigationUrl}"
                       class="lh-flow-link ${item.active ? 'is-active' : ''} ${item.completedForProgress ? 'is-completed' : ''} ${item.locked ? 'is-locked' : ''}"
                       data-flow-kind="${item.itemKind}">
                        <span class="lh-flow-icon">
                            <i class="fas ${item.iconClass}"></i>
                        </span>
                        <span class="lh-flow-copy">
                            <strong class="lh-flow-title">${item.title}</strong>
                            <span class="lh-flow-meta">
                                <span>${item.itemKind}</span>
                                <c:if test="${item.completedForProgress}">
                                    <span>Completed</span>
                                </c:if>
                                <c:if test="${item.locked}">
                                    <span>Locked</span>
                                </c:if>
                            </span>
                        </span>
                        <span class="lh-flow-state ${item.completedForProgress ? 'is-done' : (item.locked ? 'is-locked' : 'is-open')}">
                            <i class="fas fa-${item.completedForProgress ? 'check' : (item.locked ? 'lock' : 'arrow-right')}"></i>
                        </span>
                    </a>
                </c:forEach>
            </nav>
        </div>
    </aside>

    <main class="sv-main lh-main">
        <div class="sv-breadcrumb lh-breadcrumb">
            <div class="lh-breadcrumb__trail">
                <a href="${pageContext.request.contextPath}/dashboard" class="lh-breadcrumb__link">Dashboard</a>
                <span class="lh-breadcrumb__separator">/</span>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="lh-breadcrumb__link">My Courses</a>
                <span class="lh-breadcrumb__separator">/</span>
                <span class="lh-breadcrumb__current">Learning Hub</span>
            </div>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn lh-breadcrumb__action">
                <i class="fas fa-arrow-left"></i>
                <span>Back to Courses</span>
            </a>
        </div>

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

        <section class="lh-workspace">
            <header class="lh-stage-head">
                <div class="lh-stage-head__copy">
                    <span class="lh-stage-eyebrow"><c:out value="${workspaceEyebrow}"/></span>
                    <h2><c:out value="${workspaceTitle}"/></h2>
                    <p><c:out value="${workspaceDescription}"/></p>
                </div>
                <div class="lh-stage-head__status">
                    <span class="status-badge ${workspaceStatusClass}" id="lhItemStatusBadge"><c:out value="${workspaceStatusLabel}"/></span>
                    <span class="lh-stage-access ${workspaceAccessStateClass}" id="lhAccessStatusBadge">
                        <i class="fas fa-${workspaceAccessIcon}"></i>
                        <c:out value="${workspaceAccessLabel}"/>
                    </span>
                </div>
            </header>

            <div class="lh-stage-body">
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
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=history&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-clock-rotate-left"></i> View History</a>
                            </div>
                        </section>
                    </c:when>
                    <c:when test="${selectedMode == 'performance'}">
                        <section class="sa-panel lh-performance-shell" style="padding: 24px; border-radius: 18px; border: 1px solid var(--sv-border); background: var(--sv-surface);">
                            <div class="sa-panel-head" style="display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; align-items: start; margin-bottom: 18px;">
                                <div>
                                    <span class="sa-badge-flat success" style="margin-bottom: 10px;"><i class="fas fa-chart-column"></i> Course performance</span>
                                    <h3 style="margin: 0; font-size: 1.5rem; color: var(--sv-foreground);">Course overview</h3>
                                    <p style="margin: 8px 0 0; color: var(--sv-muted); max-width: 760px; line-height: 1.65;">Compare attempts, best scores, and mastery at a glance.</p>
                                </div>
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=history&enrollmentId=${enrollment.enrollmentId}" style="height: 40px; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px; font-size: 0.88rem;"><i class="fas fa-table-list"></i> Full Table</a>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 18px;">
                                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 16px;"><span style="display: block; font-size: 0.68rem; text-transform: uppercase; color: var(--sv-muted); letter-spacing: 0.08em; margin-bottom: 6px;">Assessments</span><strong style="font-size: 1.3rem; color: var(--sv-foreground);">${assessmentCount}</strong></div>
                                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(59,130,246,0.06); padding: 16px;"><span style="display: block; font-size: 0.68rem; text-transform: uppercase; color: var(--sv-muted); letter-spacing: 0.08em; margin-bottom: 6px;">Attempted</span><strong style="font-size: 1.3rem; color: #2563eb;">${performanceAttemptedCount}</strong></div>
                                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(16,185,129,0.06); padding: 16px;"><span style="display: block; font-size: 0.68rem; text-transform: uppercase; color: var(--sv-muted); letter-spacing: 0.08em; margin-bottom: 6px;">Graded</span><strong style="font-size: 1.3rem; color: #10b981;">${performanceGradedCount}</strong></div>
                                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(245,158,11,0.08); padding: 16px;"><span style="display: block; font-size: 0.68rem; text-transform: uppercase; color: var(--sv-muted); letter-spacing: 0.08em; margin-bottom: 6px;">Average best score</span><strong style="font-size: 1.3rem; color: #d97706;"><c:choose><c:when test="${not empty performanceAverageBestScore}"><fmt:formatNumber value="${performanceAverageBestScore}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></strong></div>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; margin-bottom: 18px;">
                                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(16,185,129,0.06); padding: 16px;">
                                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Highest performing assessment</span>
                                    <strong style="display: block; font-size: 1.02rem; color: var(--sv-foreground); margin-bottom: 4px;"><c:choose><c:when test="${not empty performanceHighestAssessmentTitle}">${performanceHighestAssessmentTitle}</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                                    <span style="color: #10b981; font-weight: 700;"><c:choose><c:when test="${not empty performanceHighestAssessmentPercent}"><fmt:formatNumber value="${performanceHighestAssessmentPercent}" maxFractionDigits="1"/>%</c:when><c:otherwise>--</c:otherwise></c:choose></span>
                                </div>
                                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(239,68,68,0.06); padding: 16px;">
                                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Lowest performing assessment</span>
                                    <strong style="display: block; font-size: 1.02rem; color: var(--sv-foreground); margin-bottom: 4px;"><c:choose><c:when test="${not empty performanceLowestAssessmentTitle}">${performanceLowestAssessmentTitle}</c:when><c:otherwise>--</c:otherwise></c:choose></strong>
                                    <span style="color: #ef4444; font-weight: 700;"><c:choose><c:when test="${not empty performanceLowestAssessmentPercent}"><fmt:formatNumber value="${performanceLowestAssessmentPercent}" maxFractionDigits="1"/>%</c:when><c:otherwise>--</c:otherwise></c:choose></span>
                                </div>
                            </div>

                            <div style="overflow-x: auto;">
                                <table style="width: 100%; border-collapse: collapse; min-width: 940px;">
                                    <thead>
                                        <tr style="text-align: left; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em;">
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Assessment</th>
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Attempts</th>
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Best Score</th>
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Best %</th>
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Mastery</th>
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Latest Submission</th>
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Status</th>
                                            <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Open</th>
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
                                            <tr style="border-bottom: 1px solid var(--sv-border);">
                                                <td style="padding: 16px 10px; vertical-align: top;"><strong style="display: block; color: var(--sv-foreground);">${assessment.title}</strong><span style="display: block; margin-top: 4px; color: var(--sv-muted); font-size: 0.82rem;">${assessment.type}</span></td>
                                                <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap; color: var(--sv-foreground); font-weight: 600;">${usedAttempts} / ${allowedAttempts}</td>
                                                <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap; color: var(--sv-foreground); font-weight: 600;"><c:choose><c:when test="${not empty bestScore}"><fmt:formatNumber value="${bestScore}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></td>
                                                <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap; color: var(--sv-foreground); font-weight: 600;"><c:choose><c:when test="${not empty bestPercent}"><fmt:formatNumber value="${bestPercent}" maxFractionDigits="1"/>%</c:when><c:otherwise>--</c:otherwise></c:choose></td>
                                                <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap;">
                                                    <c:choose>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 85}"><span class="sa-status status-Approved" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Excellent</span></c:when>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 70}"><span class="sa-status status-Pending" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px; background: rgba(59, 130, 246, 0.1); color: #2563eb;">Strong</span></c:when>
                                                        <c:when test="${not empty bestPercent and bestPercent >= 50}"><span class="sa-status status-Pending" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px; background: rgba(245, 158, 11, 0.12); color: #d97706;">Developing</span></c:when>
                                                        <c:otherwise><span class="sa-status status-Archived" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Needs Review</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 16px 10px; vertical-align: top; color: var(--sv-muted); white-space: nowrap;"><c:choose><c:when test="${not empty latestSubmission}">${fn:replace(latestSubmission.submitDate, 'T', ' ')}</c:when><c:otherwise>--</c:otherwise></c:choose></td>
                                                <td style="padding: 16px 10px; vertical-align: top;"><c:choose><c:when test="${hasActiveAttempt}"><span class="sa-status status-Pending" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Active</span></c:when><c:when test="${not empty latestSubmission and not empty latestSubmission.score}"><span class="sa-status status-Approved" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Graded</span></c:when><c:when test="${not empty latestSubmission}"><span class="sa-status status-Pending" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Awaiting Review</span></c:when><c:otherwise><span class="sa-status status-Archived" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Not Started</span></c:otherwise></c:choose></td>
                                                <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap;">
                                                    <c:choose>
                                                        <c:when test="${not empty latestSubmission}"><a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=result&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&submissionId=${latestSubmission.submissionId}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem;"><i class="fas fa-chart-column"></i> Result</a></c:when>
                                                        <c:otherwise><a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=details&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; border: 1px solid var(--sv-border);"><i class="fas fa-eye"></i> Open</a></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </c:when>
                    <c:when test="${selectedMode == 'assessment' and not empty selectedAssessment}">
                        <c:set var="isAttempting" value="${(param.attempt == 'true' || selectedAssessmentStatusLabel == 'Active') && selectedAssessment.type != 'Assignment'}"/>
                        <c:choose>
                            <c:when test="${isAttempting}">
                                <section class="lh-assessment-focus">
                                    <div class="lh-focus-icon">
                                        <i class="fas fa-shield-halved"></i>
                                    </div>
                                    <h3>Continue in the secure assessment workspace</h3>
                                    <p>This assessment opens as a dedicated page to keep timing, question navigation, and submission handling stable.</p>
                                    <a class="sv-btn primary" href="${selectedAssessmentPrimaryUrl}">
                                        <i class="fas fa-arrow-up-right-from-square"></i>
                                        <span>Open Assessment</span>
                                    </a>
                                </section>
                            </c:when>
                            <c:otherwise>
                                <section class="lh-assessment-card lh-assessment-card--flush">
                                    <div class="lh-assessment-card__content lh-assessment-card__content--flush">

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
                                            <section class="lh-material-stage lh-mt-18">
                                                <div class="lh-stage-card">
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
                                                                            <label for="answerFileHub"><strong>Upload Assignment File</strong></label>
                                                                            <input id="answerFileHub" name="answerFile" type="file" required>
                                                                            <p class="assignment-upload-note">Accepted formats include PDF, DOC, DOCX, PPT, PPTX, ZIP, and image files. Maximum file size: 50MB.</p>
                                                                        </div>

                                                                        <div class="assessment-actions lh-assessment-actions">
                                                                            <button class="sv-btn primary" type="submit">
                                                                                <i class="fas fa-upload"></i>&nbsp;Submit Assignment Retake
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
                                                                    <label for="answerFileHub"><strong>Upload Assignment File</strong></label>
                                                                    <input id="answerFileHub" name="answerFile" type="file" required>
                                                                    <p class="assignment-upload-note">Accepted formats include PDF, DOC, DOCX, PPT, PPTX, ZIP, and image files. Maximum file size: 50MB.</p>
                                                                </div>

                                                                <div class="assessment-actions lh-assessment-actions">
                                                                    <button class="sv-btn primary" type="submit">
                                                                        <i class="fas fa-upload"></i>&nbsp;Submit Assignment
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </section>
                                        </c:if>

                                        <c:if test="${selectedAssessment.type != 'Assignment'}">
                                            <section class="lh-material-stage">
                                                <div class="lh-stage-card lh-quiz-panel">
                                                    <c:choose>
                                                        <c:when test="${not empty selectedAssessmentLatest}">
                                                            <c:set var="passThreshold" value="${selectedAssessment.totalMarks * 0.7}"/>
                                                            <c:set var="hasPassedQuiz" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                                            <c:choose>
                                                                <c:when test="${hasPassedQuiz}">
                                                                    <div class="quiz-result-header">
                                                                        <div class="lh-result-icon is-success">
                                                                            <i class="fas fa-circle-check"></i>
                                                                        </div>
                                                                        <h3 class="lh-result-title is-success">Assessment Passed!</h3>
                                                                        <p class="lh-result-copy">Congratulations, you completed this course milestone successfully!</p>
                                                                    </div>
                                                                    
                                                                    <div class="lh-result-score-card">
                                                                        <div class="lh-result-score-label">Your Highest Score</div>
                                                                        <div class="lh-result-score-value">
                                                                            <fmt:formatNumber value="${selectedAssessmentLatest.score}" maxFractionDigits="1"/> <span>/ ${selectedAssessment.totalMarks}</span>
                                                                        </div>
                                                                        <div class="lh-result-score-pill is-success">
                                                                            Score: <fmt:formatNumber value="${(selectedAssessmentLatest.score / selectedAssessment.totalMarks) * 100.0}" maxFractionDigits="0"/>%
                                                                        </div>
                                                                    </div>

                                                                    <a class="sv-btn primary lh-success-action" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${selectedAssessment.assessmentId}&submissionId=${selectedAssessmentLatest.submissionId}">
                                                                        <i class="fas fa-chart-column"></i>
                                                                        <span>View Results Breakdown</span>
                                                                    </a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="quiz-result-header">
                                                                        <div class="lh-result-icon is-error">
                                                                            <i class="fas fa-circle-xmark"></i>
                                                                        </div>
                                                                        <h3 class="lh-result-title is-error">Retake Required</h3>
                                                                        <p class="lh-result-copy">Your score was below the required 70% passing threshold.</p>
                                                                    </div>

                                                                    <div class="lh-result-score-card">
                                                                        <div class="lh-result-score-label">Last Attempt Score</div>
                                                                        <div class="lh-result-score-value">
                                                                            <fmt:formatNumber value="${selectedAssessmentLatest.score}" maxFractionDigits="1"/> <span>/ ${selectedAssessment.totalMarks}</span>
                                                                        </div>
                                                                        <div class="lh-result-attempts">
                                                                            Attempts used: <strong>${selectedAssessmentUsedAttempts} / ${selectedAssessmentAllowedAttempts}</strong>
                                                                        </div>
                                                                    </div>

                                                                    <c:choose>
                                                                        <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                                            <a class="sv-btn primary lh-primary-action" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                                <i class="fas fa-rotate-left"></i>
                                                                                <span>Retake Assessment</span>
                                                                            </a>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <button class="sv-btn primary lh-primary-action" disabled="disabled">
                                                                                <i class="fas fa-ban"></i>
                                                                                <span>No Attempts Remaining</span>
                                                                            </button>
                                                                            <p class="lh-help-text">Please contact your course administrator to request an attempt reset.</p>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <h3 class="lh-result-title">Start Assessment</h3>
                                                            <p class="lh-result-copy">Take this objective assessment inside the secure Learning Hub workspace to satisfy your course milestones.</p>
                                                            <a class="sv-btn primary lh-primary-action" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                <i class="fas fa-play"></i>
                                                                <span>${selectedAssessmentPrimaryLabel}</span>
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </section>
                                        </c:if>
                                    </div>
                                </section>
                            </c:otherwise>
                        </c:choose>
                    </c:when>

                    <c:when test="${not empty selectedMaterial}">
                        <c:set var="materialType" value="${fn:toLowerCase(selectedMaterial.materialType)}"/>
                        <c:set var="materialPath" value="${selectedMaterial.filePath}"/>
                        <c:set var="materialViewUrl" value="${pageContext.request.contextPath}/student/materials?action=view&id=${selectedMaterial.materialId}"/>
                        <section class="lh-material-stage">
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
                        </section>
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
                                                            <a href="${pageContext.request.contextPath}/student/payment?enrollmentId=${enrollment.enrollmentId}" class="sv-btn primary btn-sm">Pay Now</a>
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
            </div>

            <footer class="lh-action-bar">
                <div class="lh-action-bar__actions">
                    <a class="sv-btn lh-nav-action is-hidden" id="lhPrevAction" href="#">
                        <i class="fas fa-arrow-left"></i>
                        <span>Previous</span>
                    </a>

                    <c:choose>
                        <c:when test="${courseExpired and (not empty selectedAssessment or not empty selectedMaterial)}">
                            <button class="sv-btn primary" id="lhSubmitAction" disabled="disabled">
                                <i class="fas fa-hourglass-end"></i>
                                <span>Course Expired</span>
                            </button>
                        </c:when>
                        <c:when test="${selectedMode == 'assessment' and not empty selectedAssessment and not isAttempting}">
                            <c:choose>
                                <c:when test="${selectedAssessment.type == 'Assignment'}">
                                    <c:choose>
                                        <c:when test="${empty selectedAssessmentLatest}">
                                            <button class="sv-btn primary" id="lhSubmitAction" type="submit" form="assignmentHubForm">
                                                <i class="fas fa-upload"></i>
                                                <span>Submit Assignment</span>
                                            </button>
                                        </c:when>
                                        <c:when test="${empty selectedAssessmentLatest.score}">
                                            <button class="sv-btn primary" id="lhSubmitAction" disabled="disabled">
                                                <i class="fas fa-clock-rotate-left"></i>
                                                <span>Awaiting Review</span>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="passThreshold" value="${selectedAssessment.totalMarks * 0.7}"/>
                                            <c:set var="hasPassedAssignment" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                            <c:choose>
                                                <c:when test="${hasPassedAssignment}">
                                                    <button class="sv-btn primary lh-success-action" id="lhSubmitAction" disabled="disabled">
                                                        <i class="fas fa-circle-check"></i>
                                                        <span>Passed &amp; Completed</span>
                                                    </button>
                                                </c:when>
                                                <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                    <button class="sv-btn primary" id="lhSubmitAction" type="submit" form="assignmentHubForm">
                                                        <i class="fas fa-rotate-left"></i>
                                                        <span>Submit Retake</span>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="sv-btn primary" id="lhSubmitAction" disabled="disabled">
                                                        <i class="fas fa-ban"></i>
                                                        <span>No Attempts Left</span>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${selectedAssessmentPrimaryLabel == 'View Result'}">
                                            <a class="sv-btn primary" id="lhSubmitAction" href="${selectedAssessmentPrimaryUrl}">
                                                <i class="fas fa-chart-column"></i>
                                                <span>View Result</span>
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <c:choose>
                                                <c:when test="${not empty selectedAssessmentLatest}">
                                                    <c:set var="passThreshold" value="${selectedAssessment.totalMarks * 0.7}"/>
                                                    <c:set var="hasPassedQuiz" value="${selectedAssessmentLatest.score >= passThreshold}"/>
                                                    <c:choose>
                                                        <c:when test="${hasPassedQuiz}">
                                                            <a class="sv-btn primary lh-success-action" id="lhSubmitAction" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${selectedAssessment.assessmentId}&submissionId=${selectedAssessmentLatest.submissionId}">
                                                                <i class="fas fa-circle-check"></i>
                                                                <span>View Result (Passed)</span>
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts}">
                                                            <a class="sv-btn primary" id="lhSubmitAction" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                                <i class="fas fa-rotate-left"></i>
                                                                <span>Retake Quiz</span>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="sv-btn primary" id="lhSubmitAction" disabled="disabled">
                                                                <i class="fas fa-ban"></i>
                                                                <span>No Attempts Left</span>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="sv-btn primary" id="lhSubmitAction" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&assessmentId=${selectedAssessment.assessmentId}&attempt=true">
                                                        <i class="fas fa-play"></i>
                                                        <span>Start Quiz</span>
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:otherwise>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:when test="${not empty selectedMaterial}">
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
                        </c:when>
                    </c:choose>

                    <a class="sv-btn lh-nav-action is-hidden" id="lhNextAction" href="#">
                        <span>Next</span>
                        <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
            </footer>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/learning-hub.js"></script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
