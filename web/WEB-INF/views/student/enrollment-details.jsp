<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
<body class="sv-page lh-shell-page">
<c:set var="topbarTitle" value="Learning Hub"/>
<c:set var="topbarSubtitle" value="Continue your course flow with a focused workspace"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <aside class="sv-sidebar lh-course-sidebar" id="svSidebar" aria-label="Course flow navigation">
        <div class="lh-course-sidebar__header">
            <h2 class="lh-course-sidebar__title">${enrollment.courseName}</h2>
            <div class="lh-sidebar-progress">
                <div class="lh-sidebar-progress__row">
                    <span>Progress</span>
                    <strong id="edProgressPercent">${progressPercent}%</strong>
                </div>
                <div class="sv-progress lh-sidebar-progress__bar">
                    <div class="sv-progress-bar" id="lhSidebarProgressBar" style="width:${progressPercent}%;"></div>
                </div>
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
                        </span>
                    </a>
                </c:forEach>
            </nav>
        </div>
    </aside>

    <main class="sv-main lh-main">
        <div class="lh-progress-strip">
            <h3 class="lh-progress-strip__title">${enrollment.courseName}</h3>
            <div class="lh-progress-strip__bar">
                <div class="sv-progress">
                    <div class="sv-progress-bar" style="width:${progressPercent}%;"></div>
                </div>
                <span class="lh-progress-strip__pct" id="edProgressPercent">${progressPercent}%</span>
            </div>
        </div>


        <c:if test="${not empty param.error or not empty param.success}">
            <section class="lh-feedback ${not empty param.error ? 'is-error' : 'is-success'}" aria-live="polite">
                <div class="lh-feedback__icon">
                    <i class="fas fa-${not empty param.error ? 'circle-exclamation' : 'circle-check'}"></i>
                </div>
                <div class="lh-feedback__copy">
                    <p>
                        <c:choose>
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
                            <c:when test="${param.error == 'submitFailed'}">
                                Submission could not be saved. Please try again.
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
                    <span class="lh-stage-eyebrow">${workspaceEyebrow}</span>
                    <h2>${workspaceTitle}</h2>
                    <p>${workspaceDescription}</p>
                </div>
                <div class="lh-stage-head__status">
                    <span class="status-badge ${workspaceStatusClass}" id="lhItemStatusBadge">${workspaceStatusLabel}</span>
                    <span class="lh-stage-access ${courseAccessGranted ? 'is-ready' : 'is-locked'}" id="lhAccessStatusBadge">
                        <i class="fas fa-${workspaceAccessIcon}"></i>
                        ${workspaceAccessLabel}
                    </span>
                </div>
            </header>

            <div class="lh-stage-meta">
                <c:forEach var="chip" items="${workspaceChips}">
                    <span class="lh-stage-chip"><i class="fas ${chip.iconClass}"></i> ${chip.label}</span>
                </c:forEach>
            </div>

            <div class="lh-stage-body">
                <c:choose>
                    <c:when test="${not empty assessmentResultSubmission and not empty assessmentResultAssessment}">
                        <section class="sa-shell" style="margin: 0;">
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

                                <div class="sa-note ${not empty assessmentResultSubmission.score ? 'success' : 'warning'}" style="margin-top: 18px;">
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
                            </article>

                            <c:if test="${assessmentResultObjective and not empty assessmentResultQuestions}">
                                <article class="sa-panel" style="margin-top: 18px;">
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

                            <article class="sa-panel" style="margin-top: 18px;">
                                <div class="sa-panel-head">
                                    <div>
                                        <h3>Submission details</h3>
                                    </div>
                                </div>

                                <div class="sa-detail-grid">
                                    <div class="sa-detail-list">
                                        <div class="sa-detail-item">
                                            <span>Status</span>
                                            <strong>${assessmentResultStatusLabel}</strong>
                                        </div>
                                        <div class="sa-detail-item">
                                            <span>Submitted by</span>
                                            <strong>${sessionScope.userName}</strong>
                                        </div>
                                    </div>
                                    <div class="sa-detail-list">
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

                                <div class="sa-footer-actions" style="margin-top: 18px;">
                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments"><i class="fas fa-arrow-left"></i> Back to Assessments</a>
                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=history&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-clock-rotate-left"></i> View History</a>
                                </div>
                            </article>
                        </section>
                    </c:when>
                    <c:when test="${selectedMode == 'assessment' and not empty selectedAssessment}">
                        <section class="lh-assessment-card">
                            <div class="lh-assessment-card__grid">
                                <div class="lh-assessment-block">
                                    <span>Assessment Type</span>
                                    <strong>${selectedAssessment.type}</strong>
                                </div>
                                <div class="lh-assessment-block">
                                    <span>Duration</span>
                                    <strong>${selectedAssessment.duration != null ? selectedAssessment.duration : 30} minutes</strong>
                                </div>
                                <div class="lh-assessment-block">
                                    <span>Attempts</span>
                                    <strong>${selectedAssessmentUsedAttempts} used / ${selectedAssessmentAllowedAttempts} allowed</strong>
                                </div>
                                <div class="lh-assessment-block">
                                    <span>Submission</span>
                                    <strong>${selectedAssessment.submissionMode == 'file' ? 'File Upload' : (selectedAssessment.submissionMode == 'text' ? 'Written Response' : (selectedAssessment.submissionMode == 'both' ? 'Text + File' : 'Objective Responses'))}</strong>
                                </div>
                            </div>

                            <div class="lh-assessment-card__content">
                                <div class="lh-assessment-block is-wide">
                                    <span>Instructions</span>
                                    <p>${not empty selectedAssessment.instructions ? selectedAssessment.instructions : 'Open the assessment when you are ready.'}</p>
                                </div>

                                <div class="lh-assessment-block is-wide">
                                    <span>Current Status</span>
                                    <p>
                                        <strong>${selectedAssessmentStatusLabel}</strong>
                                        <c:if test="${not empty selectedAssessmentLatest}">
                                            <span aria-hidden="true">&middot;</span>
                                            Latest attempt #${selectedAssessmentLatest.attemptNumber}
                                            <c:if test="${not empty selectedAssessmentLatest.score}">
                                                <span aria-hidden="true">&middot;</span>
                                                Score ${selectedAssessmentLatest.score}
                                            </c:if>
                                        </c:if>
                                    </p>
                                </div>

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
                                    <section class="lh-material-stage" style="margin-top: 18px;">
                                        <div class="lh-stage-card">
                                            <h3 style="margin:0 0 8px;">Assignment Workspace</h3>
                                            <p style="margin:0 0 16px; color: var(--sv-muted);">Upload your assignment file here without leaving the learning hub.</p>

                                            <c:if test="${not empty selectedAssessmentLatest}">
                                                <div class="assignment-latest" style="margin-bottom: 16px;">
                                                    Latest submission: ${selectedAssessmentLatest.status} on ${selectedAssessmentLatest.submitDate}
                                                </div>
                                            </c:if>

                                            <form id="assignmentHubForm" method="post" action="${pageContext.request.contextPath}/student/assessments" enctype="multipart/form-data" style="display:grid; gap:14px;">
                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                                                <div class="assignment-upload-box">
                                                    <label for="answerFileHub"><strong>Upload Assignment File</strong></label>
                                                    <input id="answerFileHub" name="answerFile" type="file" required>
                                                    <p class="assignment-upload-note">Accepted formats include PDF, DOC, DOCX, PPT, PPTX, ZIP, and image files. Maximum file size: 50MB.</p>
                                                </div>

                                                <div class="assessment-actions" style="margin-top: 8px;">
                                                    <button class="sv-btn primary" type="submit">
                                                        <i class="fas fa-upload"></i>&nbsp;Submit Assignment
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                                    </section>
                                </c:if>

                                <section class="lh-material-stage">
                                    <div class="lh-stage-card">
                                        <h3 style="margin:0 0 8px;">Open assessment</h3>
                                        <p style="margin:0 0 16px; color: var(--sv-muted);">Objective assessments still use the secure attempt page.</p>
                                        <a class="sv-btn primary" href="${selectedAssessmentPrimaryUrl}">
                                            <i class="fas fa-${workspacePrimaryActionIcon}"></i>
                                            <span>${selectedAssessmentPrimaryLabel}</span>
                                        </a>
                                    </div>
                                </section>
                            </div>
                        </section>
                    </c:when>

                    <c:when test="${not empty selectedMaterial}">
                                <section class="lh-material-stage">
                                    <iframe
                                        class="lh-workspace-frame"
                                        id="lhMaterialFrame"
                                        title="Learning material viewer"
                                        src="${pageContext.request.contextPath}/student/materials?action=preview&id=${selectedMaterial.materialId}&enrollmentId=${enrollment.enrollmentId}&fragment=true"></iframe>
                                </section>
                    </c:when>

                    <c:otherwise>
                        <div class="lh-stage-empty">
                            <i class="fas fa-book-open-reader"></i>
                            <h3>No learning item selected</h3>
                            <p>Select a material or assessment from the course flow.</p>
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
                        <c:when test="${selectedMode == 'assessment' and not empty selectedAssessment and not empty selectedAssessmentPrimaryUrl}">
                            <c:choose>
                                <c:when test="${selectedAssessment.type == 'Assignment'}">
                                    <button class="sv-btn primary" id="lhSubmitAction" type="submit" form="assignmentHubForm">
                                        <i class="fas fa-upload"></i>
                                        <span>Submit Assignment</span>
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <a class="sv-btn primary" id="lhSubmitAction" href="${selectedAssessmentPrimaryUrl}">
                                        <i class="fas fa-${workspacePrimaryActionIcon}"></i>
                                        <span>${selectedAssessmentPrimaryLabel}</span>
                                    </a>
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
                                <c:if test="${selectedMaterialStatus == 'completed'}">disabled="disabled"</c:if>>
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
<script>
(function () {
    var body = document.body;
    var flowLinks = Array.prototype.slice.call(document.querySelectorAll('.lh-flow-link'));
    var prevAction = document.getElementById('lhPrevAction');
    var nextAction = document.getElementById('lhNextAction');
    var completeButton = document.getElementById('edMarkCompleted');
    var actionNote = null; /* removed from DOM; kept as null so guarded checks are safe */
    var itemStatusBadge = document.getElementById('lhItemStatusBadge');
    var progressPercentNode = document.getElementById('edProgressPercent');
    var progressBar = document.querySelector('.lh-progress-strip .sv-progress-bar');
    var materialsViewedNode = document.getElementById('edMaterialsViewedCount');
    var currentMaterialType = '${not empty selectedMaterial ? selectedMaterial.materialType : ""}';
    var currentSelectionMode = '${selectedMode}';
    var viewerState = {
        completionRule: '',
        unlocked: '${selectedMaterialStatus == "completed"}' === 'true',
        completed: '${selectedMaterialStatus == "completed"}' === 'true'
    };

    function findActiveLink() {
        for (var i = 0; i < flowLinks.length; i++) {
            if (flowLinks[i].classList.contains('is-active')) {
                return i;
            }
        }
        return -1;
    }

    function updatePager() {
        var activeIndex = findActiveLink();
        var previousLink = activeIndex > 0 ? flowLinks[activeIndex - 1] : null;
        var nextLink = activeIndex >= 0 && activeIndex < flowLinks.length - 1 ? flowLinks[activeIndex + 1] : null;

        if (prevAction) {
            if (previousLink) {
                prevAction.href = previousLink.href;
                prevAction.classList.remove('is-hidden');
            } else {
                prevAction.classList.add('is-hidden');
            }
        }

        if (nextAction) {
            if (nextLink) {
                nextAction.href = nextLink.href;
                nextAction.classList.remove('is-hidden');
            } else {
                nextAction.classList.add('is-hidden');
            }
        }
    }

    function setProgress(progressPercent) {
        if (typeof progressPercent !== 'number' || isNaN(progressPercent)) {
            return;
        }
        if (progressPercentNode) {
            progressPercentNode.textContent = progressPercent + '%';
        }
        if (progressBar) {
            progressBar.style.width = progressPercent + '%';
        }
    }

    function setMaterialsViewed(viewed, total) {
        if (!materialsViewedNode || typeof viewed !== 'number') {
            return;
        }
        var totalValue = typeof total === 'number' ? total : ${materialCount};
        materialsViewedNode.textContent = viewed + ' / ' + totalValue;
    }

    function setCompletionButton(disabled, label) {
        if (!completeButton) {
            return;
        }
        completeButton.disabled = !!disabled;
        if (label) {
            completeButton.innerHTML = '<i class="fas fa-check-circle"></i><span>' + label + '</span>';
        }
    }

    function updateCompletionSidebarState() {
        var activeIndex = findActiveLink();
        if (activeIndex < 0) {
            return;
        }
        var activeLink = flowLinks[activeIndex];
        activeLink.classList.add('is-completed');
        activeLink.classList.remove('is-locked');
    }

    function applyCompletedState(note) {
        viewerState.completed = true;
        viewerState.unlocked = true;
        if (itemStatusBadge) {
            itemStatusBadge.className = 'status-badge status-Approved';
            itemStatusBadge.textContent = 'Completed';
        }
        setCompletionButton(true, 'Completed');
        updateCompletionSidebarState();
        if (actionNote && note) {
            actionNote.textContent = note;
        }
    }

    function setWaitingState() {
        if (!completeButton || viewerState.completed || currentSelectionMode !== 'material') {
            return;
        }

        var label = 'Mark Complete';
        var note = 'Review the current material, then mark it complete from the action bar.';

        if (currentMaterialType === 'Video' || currentMaterialType === 'Audio') {
            label = 'Complete After Playback';
            note = 'Playback unlocks completion once you reach the required threshold.';
        } else if (currentMaterialType === 'Link') {
            label = 'Open Resource First';
            note = 'Open the external resource in the viewer, then mark it complete here.';
        } else {
            label = 'Review In Progress';
            note = 'Review the current material, then mark it complete from the action bar.';
        }

        setCompletionButton(true, label);
        if (actionNote) {
            actionNote.textContent = note;
        }
    }

    function unlockCompletion(note) {
        if (!completeButton || viewerState.completed || currentSelectionMode !== 'material') {
            return;
        }
        viewerState.unlocked = true;
        setCompletionButton(false, 'Mark Complete');
        if (actionNote && note) {
            actionNote.textContent = note;
        }
    }

    updatePager();

    if (completeButton) {
        if (viewerState.completed) {
            setCompletionButton(true, 'Completed');
        } else {
            setWaitingState();
            if (currentMaterialType !== 'Video' && currentMaterialType !== 'Audio' && currentMaterialType !== 'Link') {
                window.setTimeout(function () {
                    if (!viewerState.unlocked && !viewerState.completed) {
                        unlockCompletion('Review complete. You can mark this material complete now.');
                    }
                }, 5500);
            }
        }

        completeButton.addEventListener('click', function () {
            if (completeButton.disabled || viewerState.completed) {
                return;
            }

            var materialId = completeButton.getAttribute('data-material-id');
            var enrollmentId = completeButton.getAttribute('data-enrollment-id');
            if (!materialId || !enrollmentId) {
                return;
            }

            setCompletionButton(true, 'Saving...');
            var payload = 'materialId=' + encodeURIComponent(materialId) + '&enrollmentId=' + encodeURIComponent(enrollmentId);

            fetch('${pageContext.request.contextPath}/student/mark-material-completed', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: payload
            })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('Unable to save completion.');
                }
                return response.json();
            })
            .then(function (data) {
                if (!data.success) {
                    throw new Error(data.message || 'Unable to save completion.');
                }
                applyCompletedState('This material is now part of your course progress.');
                if (typeof data.progressPercent === 'number') {
                    setProgress(data.progressPercent);
                }
                if (typeof data.viewedMaterials === 'number') {
                    setMaterialsViewed(data.viewedMaterials, data.totalMaterials);
                }
            })
            .catch(function (error) {
                viewerState.unlocked = false;
                setWaitingState();
                unlockCompletion(error.message || 'Unable to save completion right now.');
            });
        });
    }

    window.addEventListener('message', function (event) {
        if (event.origin !== window.location.origin || !event.data || currentSelectionMode !== 'material') {
            return;
        }

        if (event.data.type === 'lhViewerState') {
            viewerState.completionRule = event.data.completionRule || '';
            if (event.data.completed) {
                applyCompletedState('This material is already part of your course progress.');
                return;
            }
            if (event.data.note && actionNote) {
                actionNote.textContent = event.data.note;
            }
        }

        if (event.data.type === 'lhViewerUnlock') {
            unlockCompletion(event.data.note || 'You can mark this material complete now.');
        }
    });
})();
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
