<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material Preview - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/learning-hub.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/material-viewer-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Material Preview"/>
<c:set var="topbarSubtitle" value="Review the current material in one focused workspace"/>
<c:set var="previewEnrollmentId" value="${not empty previewEnrollment ? previewEnrollment.enrollmentId : ''}"/>
<c:set var="courseProgressPercent" value="${not empty previewEnrollment and not empty previewEnrollment.progress ? previewEnrollment.progress : 0}"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="${not empty previewEnrollmentId ? 'course' : 'default'}"/>
<c:set var="navContextPage" value="materials"/>
<c:set var="navCourseEnrollmentId" value="${previewEnrollmentId}"/>
<c:set var="navCourseTitle" value="${not empty previewEnrollment.courseName ? previewEnrollment.courseName : material.title}"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main mv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${backToHubUrl}">${backToHubLabel}</a>
            <span>/</span>
            <span>Material Preview</span>
        </div>

        <section class="lh-workspace mv-shell">
            <header class="lh-stage-head">
                <div class="lh-stage-head__copy">
                    <span class="lh-stage-eyebrow">${material.materialType}</span>
                    <h2>${material.title}</h2>
                    <p>
                        <c:choose>
                            <c:when test="${not empty material.description}">${material.description}</c:when>
                            <c:otherwise>Review the material in place, then continue through the course flow.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="lh-stage-head__status">
                    <span class="status-badge ${materialStatusClass}" id="mvStatusBadge">${materialStatusLabel}</span>
                    <span class="lh-stage-access is-ready">
                        <i class="fas fa-layer-group"></i>
                        ${not empty previewEnrollmentId ? 'Course-linked viewer' : 'Standalone viewer'}
                    </span>
                </div>
            </header>

            <div class="lh-stage-meta">
                <span class="lh-stage-chip"><i class="fas fa-tag"></i> ${material.materialType}</span>
                <c:if test="${materialPosition > 0}">
                    <span class="lh-stage-chip"><i class="fas fa-list-ol"></i> ${materialPosition} / ${totalMaterialsInCourse}</span>
                </c:if>
                <span class="lh-stage-chip"><i class="fas fa-chart-line"></i> <strong id="mvCourseProgressPercent">${courseProgressPercent}%</strong></span>
                <span class="lh-stage-chip"><i class="fas fa-circle-check"></i> <span id="mvStatusChip">${materialStatusLabel}</span></span>
            </div>

            <div class="lh-stage-body">
                <section class="mv-stage-panel">
                    <iframe
                        class="mv-fragment-frame"
                        id="mvMaterialFrame"
                        title="Learning material viewer"
                        src="${pageContext.request.contextPath}/student/materials?action=preview&id=${material.materialId}&enrollmentId=${previewEnrollmentId}&fragment=true"></iframe>
                </section>
            </div>

            <footer class="lh-action-bar">
                <div class="lh-action-bar__copy">
                    <strong>Viewer Actions</strong>
                    <p id="mvActionNote">
                        <c:choose>
                            <c:when test="${isCompletedMaterial}">This material is already part of your course progress.</c:when>
                            <c:when test="${completionRule == 'video' || completionRule == 'audio'}">Playback unlocks completion once you reach the required threshold.</c:when>
                            <c:when test="${completionRule == 'link'}">Open the external resource, then mark the item complete from here.</c:when>
                            <c:otherwise>Review the material, then mark it complete when you are ready.</c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <div class="lh-action-bar__actions mv-action-cluster">
                    <a class="sv-btn" href="${backToHubUrl}">
                        <i class="fas fa-arrow-left"></i>
                        <span>${backToHubLabel}</span>
                    </a>

                    <c:if test="${not empty previousMaterial}">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${previousMaterial.materialId}&enrollmentId=${previewEnrollmentId}">
                            <i class="fas fa-arrow-left"></i>
                            <span>Previous</span>
                        </a>
                    </c:if>

                    <a class="sv-btn ${empty nextMaterial ? 'mv-hidden' : ''}" id="mvNextAction" href="${not empty nextMaterial ? pageContext.request.contextPath.concat('/student/materials?action=preview&id=').concat(nextMaterial.materialId).concat('&enrollmentId=').concat(previewEnrollmentId) : backToHubUrl}">
                        <span>Next</span>
                        <i class="fas fa-arrow-right"></i>
                    </a>

                    <a class="sv-btn" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${material.materialId}">
                        <i class="fas fa-up-right-from-square"></i>
                        <span>Open Source</span>
                    </a>

                    <c:if test="${material.materialType != 'Link' and not isVideoMaterial}">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=download&id=${material.materialId}">
                            <i class="fas fa-download"></i>
                            <span>Download</span>
                        </a>
                    </c:if>

                    <button
                        id="mvMarkCompleted"
                        type="button"
                        class="sv-btn primary"
                        data-material-id="${material.materialId}"
                        data-enrollment-id="${previewEnrollmentId}"
                        data-completed="${isCompletedMaterial}"
                        data-complete-url="${completeActionUrl}"
                        <c:if test="${isCompletedMaterial}">disabled="disabled"</c:if>>
                        <i class="fas fa-check-circle"></i>
                        <span>${isCompletedMaterial ? 'Completed' : 'Mark Complete'}</span>
                    </button>
                </div>
            </footer>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
(function () {
    var completeButton = document.getElementById('mvMarkCompleted');
    var actionNote = document.getElementById('mvActionNote');
    var statusBadge = document.getElementById('mvStatusBadge');
    var statusChip = document.getElementById('mvStatusChip');
    var courseProgressBadge = document.getElementById('mvCourseProgressPercent');
    var nextAction = document.getElementById('mvNextAction');
    var viewerState = {
        unlocked: '${isCompletedMaterial}' === 'true',
        completed: '${isCompletedMaterial}' === 'true'
    };

    if (!completeButton) {
        return;
    }

    function setButtonState(disabled, label) {
        completeButton.disabled = !!disabled;
        if (label) {
            completeButton.innerHTML = '<i class="fas fa-check-circle"></i><span>' + label + '</span>';
        }
    }

    function setProgress(percent) {
        if (typeof percent !== 'number' || isNaN(percent)) {
            return;
        }
        var progressBars = document.querySelectorAll('.sv-progress-bar, .lh-progress-bar');
        for (var i = 0; i < progressBars.length; i++) {
            progressBars[i].style.width = percent + '%';
        }
        if (courseProgressBadge) {
            courseProgressBadge.textContent = percent + '%';
        }
    }

    function applyCompletedState(note) {
        viewerState.completed = true;
        viewerState.unlocked = true;
        setButtonState(true, 'Completed');
        if (statusBadge) {
            statusBadge.className = 'status-badge status-Approved';
            statusBadge.textContent = 'Completed';
        }
        if (statusChip) {
            statusChip.textContent = 'Completed';
        }
        if (actionNote && note) {
            actionNote.textContent = note;
        }
    }

    function unlockCompletion(note) {
        if (viewerState.completed) {
            return;
        }
        viewerState.unlocked = true;
        setButtonState(false, 'Mark Complete');
        if (actionNote && note) {
            actionNote.textContent = note;
        }
    }

    function setWaitingState() {
        if (viewerState.completed) {
            return;
        }
        setButtonState(true, 'Review In Progress');
    }

    if (viewerState.completed) {
        applyCompletedState('This material is already part of your course progress.');
    } else {
        setWaitingState();
    }

    completeButton.addEventListener('click', function () {
        if (completeButton.disabled || viewerState.completed) {
            return;
        }

        var materialId = completeButton.getAttribute('data-material-id');
        var enrollmentId = completeButton.getAttribute('data-enrollment-id');
        var completeUrl = completeButton.getAttribute('data-complete-url');
        if (!materialId || !completeUrl) {
            return;
        }

        setButtonState(true, 'Saving...');
        var payload = 'materialId=' + encodeURIComponent(materialId);
        if (enrollmentId) {
            payload += '&enrollmentId=' + encodeURIComponent(enrollmentId);
        }

        fetch(completeUrl, {
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
            if (nextAction && data.continueLabel && data.continueUrl) {
                nextAction.classList.remove('mv-hidden');
                nextAction.href = data.continueUrl;
                nextAction.innerHTML = '<span>' + data.continueLabel + '</span><i class="fas fa-arrow-right"></i>';
            }
        })
        .catch(function (error) {
            viewerState.unlocked = false;
            setWaitingState();
            unlockCompletion(error.message || 'Unable to save completion right now.');
        });
    });

    window.addEventListener('message', function (event) {
        if (event.origin !== window.location.origin || !event.data) {
            return;
        }

        if (event.data.type === 'lhViewerState') {
            if (event.data.completed) {
                applyCompletedState('This material is already part of your course progress.');
                return;
            }
            if (actionNote && event.data.note) {
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
