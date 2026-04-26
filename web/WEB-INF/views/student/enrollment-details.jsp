<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${enrollment.courseName} - Learning Hub</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/learning-hub.css">
</head>
<body class="sv-page lh-shell-page">
<c:set var="topbarTitle" value="Learning Hub"/>
<c:set var="topbarSubtitle" value="Continue your course flow with a focused workspace"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <aside class="sv-sidebar lh-course-sidebar" id="svSidebar" aria-label="Course flow navigation">
        <div class="lh-course-sidebar__header">
            <span class="lh-course-sidebar__eyebrow">Course Flow</span>
            <h2 class="lh-course-sidebar__title">${enrollment.courseName}</h2>
            <p class="lh-course-sidebar__summary">
                ${materialsViewedCount} of ${materialCount} materials completed
                <span aria-hidden="true">&middot;</span>
                ${passedAssessmentsCount} of ${totalAssessmentsCount} assessments passed
            </p>
            <div class="lh-sidebar-progress">
                <div class="lh-sidebar-progress__row">
                    <span>Progress</span>
                    <strong id="edProgressPercent">${progressPercent}%</strong>
                </div>
                <div class="sv-progress lh-sidebar-progress__bar">
                    <div class="sv-progress-bar" id="lhSidebarProgressBar" style="width:${progressPercent}%;"></div>
                </div>
            </div>
            <span class="lh-course-sidebar__badge ${courseAccessGranted ? 'is-ready' : 'is-locked'}">
                <i class="fas fa-${courseAccessGranted ? (enrollment.coursePrice <= 0 ? 'gift' : 'check-circle') : 'lock'}"></i>
                <c:choose>
                    <c:when test="${enrollment.coursePrice <= 0}">Free Access</c:when>
                    <c:when test="${courseAccessGranted}">Paid Access</c:when>
                    <c:otherwise>Payment Pending</c:otherwise>
                </c:choose>
            </span>
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
                            <span class="lh-flow-kicker">${item.badgeText}</span>
                            <strong class="lh-flow-title">${item.title}</strong>
                            <span class="lh-flow-meta">
                                <span>${item.type}</span>
                                <c:if test="${not empty item.metaPrimary}">
                                    <span>${item.metaPrimary}</span>
                                </c:if>
                                <c:if test="${not empty item.metaSecondary}">
                                    <span>${item.metaSecondary}</span>
                                </c:if>
                            </span>
                        </span>
                        <span class="lh-flow-state ${item.completedForProgress ? 'is-done' : (item.locked ? 'is-locked' : 'is-open')}">
                            <i class="fas fa-${item.completedForProgress ? 'check' : (item.locked ? 'lock' : ('In Progress' == item.statusLabel ? 'pen' : 'arrow-right'))}"></i>
                            <span class="lh-flow-state-text">${item.statusLabel}</span>
                        </span>
                    </a>
                </c:forEach>
            </nav>
        </div>
    </aside>

    <main class="sv-main lh-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>Learning Hub</span>
        </div>

        <section class="lh-course-summary">
            <div class="lh-course-summary__copy">
                <span class="lh-course-summary__eyebrow">Student Learning Hub</span>
                <h1>${enrollment.courseName}</h1>
                <p>${not empty enrollment.courseDescription ? enrollment.courseDescription : 'Continue through your learning sequence with one focused workspace.'}</p>
            </div>
            <div class="lh-course-summary__stats">
                <div class="lh-summary-stat">
                    <span>Course Progress</span>
                    <strong id="edProgressPercentSummary">${progressPercent}%</strong>
                </div>
                <div class="lh-summary-stat">
                    <span>Materials Completed</span>
                    <strong id="edMaterialsViewedCount">${materialsViewedCount} / ${materialCount}</strong>
                </div>
                <div class="lh-summary-stat">
                    <span>Assessments Passed</span>
                    <strong>${passedAssessmentsCount} / ${totalAssessmentsCount}</strong>
                </div>
                <div class="lh-summary-stat">
                    <span>Access</span>
                    <strong>
                        <c:choose>
                            <c:when test="${enrollment.coursePrice <= 0}">Free</c:when>
                            <c:when test="${courseAccessGranted}">Unlocked</c:when>
                            <c:otherwise>Pending</c:otherwise>
                        </c:choose>
                    </strong>
                </div>
            </div>
            <div class="lh-course-summary__progress">
                <div class="sv-progress">
                    <div class="sv-progress-bar" id="lhSummaryProgressBar" style="width:${progressPercent}%;"></div>
                </div>
            </div>
        </section>

        <c:if test="${not empty param.error or not empty param.success}">
            <section class="lh-feedback ${not empty param.error ? 'is-error' : 'is-success'}" aria-live="polite">
                <div class="lh-feedback__icon">
                    <i class="fas fa-${not empty param.error ? 'circle-exclamation' : 'circle-check'}"></i>
                </div>
                <div class="lh-feedback__copy">
                    <strong>
                        <c:choose>
                            <c:when test="${not empty param.error}">
                                Action needed
                            </c:when>
                            <c:otherwise>
                                Update saved
                            </c:otherwise>
                        </c:choose>
                    </strong>
                    <p>
                        <c:choose>
                            <c:when test="${param.error == 'paymentRequired'}">
                                This course item is locked until course access is confirmed.
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
                                We could not save the submission. Please try again.
                            </c:when>
                            <c:when test="${param.success == 'submitted'}">
                                Your assessment was submitted successfully.
                            </c:when>
                            <c:when test="${param.success == 'timed-out'}">
                                Time expired and your assessment attempt was submitted automatically.
                            </c:when>
                            <c:when test="${param.success == 'exited'}">
                                Your assessment was saved and closed.
                            </c:when>
                            <c:otherwise>
                                Your learning workspace has been updated.
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
                                    <p>${not empty selectedAssessment.instructions ? selectedAssessment.instructions : 'Open the assessment from the action bar when you are ready to continue.'}</p>
                                </div>

                                <div class="lh-assessment-block is-wide">
                                    <span>Current Status</span>
                                    <p>
                                        <strong>${selectedAssessmentStatusLabel}</strong>
                                        <c:if test="${not empty selectedAssessmentLatest}">
                                            <span class="lh-inline-separator">&middot;</span>
                                            Latest attempt #${selectedAssessmentLatest.attemptNumber}
                                            <c:if test="${not empty selectedAssessmentLatest.score}">
                                                <span class="lh-inline-separator">&middot;</span>
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
                            <p>Choose a material or assessment from the course flow to begin.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <footer class="lh-action-bar">
                <div class="lh-action-bar__copy">
                    <strong>Workspace Actions</strong>
                    <p id="lhActionNote">${workspaceActionNote}</p>
                </div>

                <div class="lh-action-bar__actions">
                    <a class="sv-btn lh-nav-action is-hidden" id="lhPrevAction" href="#">
                        <i class="fas fa-arrow-left"></i>
                        <span>Previous</span>
                    </a>

                    <a class="sv-btn lh-nav-action is-hidden" id="lhNextAction" href="#">
                        <span>Next</span>
                        <i class="fas fa-arrow-right"></i>
                    </a>

                    <c:choose>
                        <c:when test="${selectedMode == 'assessment' and not empty selectedAssessment and not empty selectedAssessmentPrimaryUrl}">
                            <a class="sv-btn primary" id="lhSubmitAction" href="${selectedAssessmentPrimaryUrl}">
                                <i class="fas fa-${workspacePrimaryActionIcon}"></i>
                                <span>${selectedAssessmentPrimaryLabel}</span>
                            </a>
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
    var actionNote = document.getElementById('lhActionNote');
    var itemStatusBadge = document.getElementById('lhItemStatusBadge');
    var progressPercentNodes = [
        document.getElementById('edProgressPercent'),
        document.getElementById('edProgressPercentSummary')
    ];
    var progressBars = [
        document.getElementById('lhSidebarProgressBar'),
        document.getElementById('lhSummaryProgressBar')
    ];
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
        for (var i = 0; i < progressPercentNodes.length; i++) {
            if (progressPercentNodes[i]) {
                progressPercentNodes[i].textContent = progressPercent + '%';
            }
        }
        for (var j = 0; j < progressBars.length; j++) {
            if (progressBars[j]) {
                progressBars[j].style.width = progressPercent + '%';
            }
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
        var state = activeLink.querySelector('.lh-flow-state');
        var stateText = activeLink.querySelector('.lh-flow-state-text');
        var stateIcon = state ? state.querySelector('i') : null;
        if (state) {
            state.classList.remove('is-open', 'is-locked');
            state.classList.add('is-done');
        }
        if (stateText) {
            stateText.textContent = 'Completed';
        }
        if (stateIcon) {
            stateIcon.className = 'fas fa-check';
        }
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
