<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="cp-fragment material-fragment">
    <c:set var="resolvedEnrollmentId" value=""/>
    <c:choose>
        <c:when test="${not empty previewEnrollment and not empty previewEnrollment.enrollmentId}">
            <c:set var="resolvedEnrollmentId" value="${previewEnrollment.enrollmentId}"/>
        </c:when>
        <c:when test="${not empty param.enrollmentId}">
            <c:set var="resolvedEnrollmentId" value="${param.enrollmentId}"/>
        </c:when>
    </c:choose>

    <div class="mv-head-copy cp-header">
        <div class="mv-head-top">
            <span class="status-badge ${materialStatusClass}" id="mvStatusBadge">${materialStatusLabel}</span>
            <span class="cp-type-badge">${material.materialType}</span>
        </div>
        <h2>${material.title}</h2>
        <c:if test="${not empty material.description}">
            <p class="mv-description">${material.description}</p>
        </c:if>
    </div>

    <div class="cp-viewer-container">
        <c:choose>
            <c:when test="${isLinkMaterial}">
                <div class="mv-link-state">
                    <i class="fas fa-link"></i>
                    <h3>External Resource</h3>
                    <a id="mvOpenResource" class="sv-btn primary" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${material.materialId}">Open Resource</a>
                </div>
            </c:when>
            <c:when test="${isVideoMaterial}">
                <div class="mv-player-wrap">
                    <video id="mvPlaybackMedia" class="mv-video" controls preload="metadata" playsinline>
                        <source src="${streamUrl}">
                        Your browser does not support embedded video playback.
                    </video>
                </div>
            </c:when>
            <c:when test="${isAudioMaterial}">
                <div class="mv-audio-wrap">
                    <audio id="mvPlaybackMedia" controls preload="metadata" class="mv-audio">
                        <source src="${streamUrl}">
                        Your browser does not support audio playback.
                    </audio>
                </div>
            </c:when>
            <c:when test="${isPdfMaterial}">
                <div class="mv-frame-wrap">
                    <iframe class="mv-frame" src="${streamUrl}" title="PDF preview"></iframe>
                </div>
            </c:when>

            <c:when test="${canInlinePreview}">
                <div class="mv-frame-wrap">
                    <iframe class="mv-frame" src="${streamUrl}" title="Material preview" style="border:none; width:100%; height:100%;"></iframe>
                </div>
            </c:when>
            <c:otherwise>
                <div class="mv-link-state">
                    <i class="fas fa-file-arrow-down"></i>
                    <h3>Preview Not Available</h3>
                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=download&id=${material.materialId}">Download File</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="cp-tracking-bar">
        <div class="cp-tracking-info">
            <h4 id="mvCompletionHeading">
                <c:choose>
                    <c:when test="${isCompletedMaterial}">Completed</c:when>
                    <c:otherwise>Mark as Complete</c:otherwise>
                </c:choose>
            </h4>
            <p id="mvCompletionHint">
                <c:choose>
                    <c:when test="${isCompletedMaterial}">You've completed this material.</c:when>
                    <c:when test="${completionRule == 'video' || completionRule == 'audio'}">Watch through to enable completion.</c:when>
                    <c:otherwise>Review the content, then mark complete.</c:otherwise>
                </c:choose>
            </p>
        </div>
        
        <button
                type="button"
                id="mvMarkCompleted"
                class="sv-btn cp-complete-btn"
                data-material-id="${material.materialId}"
                data-enrollment-id="${previewEnrollmentId}"
                data-completion-rule="${completionRule}"
                data-completed="${isCompletedMaterial}"
                data-complete-url="${completeActionUrl}"
                <c:if test="${isCompletedMaterial}">disabled="disabled"</c:if>>
            <c:choose>
                <c:when test="${isCompletedMaterial}"><i class="fas fa-check"></i> Completed</c:when>
                <c:otherwise><i class="fas fa-check-circle"></i> Complete &amp; Continue</c:otherwise>
            </c:choose>
        </button>
    </div>
</div>

<script>
(function () {
    var completeButton = document.getElementById('mvMarkCompleted');
    var completionHint = document.getElementById('mvCompletionHint');
    var completionHeading = document.getElementById('mvCompletionHeading');
    var statusBadge = document.getElementById('mvStatusBadge');
    var playbackMedia = document.getElementById('mvPlaybackMedia');
    var openResourceLink = document.getElementById('mvOpenResource');
    var unlockTimer = null;
    var completionRequested = false;

    if (!completeButton) return;

    var completionRule = completeButton.getAttribute('data-completion-rule') || 'default';
    var completeUrl = completeButton.getAttribute('data-complete-url');
    var materialId = completeButton.getAttribute('data-material-id');
    var enrollmentId = completeButton.getAttribute('data-enrollment-id');
    var alreadyCompleted = completeButton.getAttribute('data-completed') === 'true';

    completeButton.addEventListener('click', function () {
        if (completeButton.disabled) return;
        markCompleted();
    });

    function setHint(message) {
        if (completionHint) completionHint.textContent = message;
    }

    function setButtonState(disabled, label) {
        completeButton.disabled = !!disabled;
        if (label) completeButton.textContent = label;
    }

    function unlockCompletion(message) {
        if (alreadyCompleted) return;
        if (unlockTimer) {
            window.clearInterval(unlockTimer);
            unlockTimer = null;
        }
        setButtonState(false, 'Complete & Continue');
        setHint(message || 'You can confirm this material as completed now.');
    }

    function applyCompletedState(message) {
        alreadyCompleted = true;
        setButtonState(true, 'Completed');
        completeButton.setAttribute('data-completed', 'true');
        if (statusBadge) {
            statusBadge.className = 'status-badge status-Approved';
            statusBadge.textContent = 'Completed';
        }
        if (completionHeading) completionHeading.textContent = 'Material Completed';
        setHint(message || 'Your course progress has been updated for this material.');
    }

    function markCompleted() {
        if (alreadyCompleted || completionRequested || !completeUrl || !materialId) return;

        completionRequested = true;
        setButtonState(true, 'Saving...');
        var payload = 'materialId=' + encodeURIComponent(materialId);
        if (enrollmentId) payload += '&enrollmentId=' + encodeURIComponent(enrollmentId);

        fetch(completeUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: payload
        })
        .then(function (response) {
            if (!response.ok) throw new Error('Unable to save completion.');
            return response.json();
        })
        .then(function (data) {
            if (!data.success) throw new Error(data.message || 'Unable to save completion.');
            applyCompletedState('Marked complete.');
            
            // Trigger custom event for the parent Course Player to navigate to next item
            var event = new CustomEvent('CoursePlayerItemCompleted', {
                detail: { materialId: materialId, nextUrl: data.continueUrl }
            });
            document.dispatchEvent(event);
        })
        .catch(function (error) {
            completionRequested = false;
            setButtonState(false, 'Complete & Continue');
            setHint(error.message || 'Unable to save completion right now.');
        });
    }

    if (alreadyCompleted) {
        applyCompletedState('Your course progress already includes this material.');
        return;
    }

    if (completionRule === 'video' || completionRule === 'audio') {
        setButtonState(true, 'Complete After Playback');
        if (!playbackMedia) {
            unlockCompletion('Playback could not be detected, confirm completion manually.');
            return;
        }

        playbackMedia.addEventListener('timeupdate', function () {
            if (!playbackMedia.duration || alreadyCompleted) return;
            var progress = playbackMedia.currentTime / playbackMedia.duration;
            if (progress >= 0.85) {
                unlockCompletion('Playback threshold reached. You can complete this material.');
            }
        });

        playbackMedia.addEventListener('ended', function () {
            unlockCompletion('Playback finished. Completing this material now.');
            markCompleted();
        });
        return;
    }

    if (completionRule === 'link') {
        setButtonState(true, 'Open Resource First');
        if (openResourceLink) {
            openResourceLink.addEventListener('click', function () {
                window.setTimeout(function () {
                    unlockCompletion('After reviewing the external resource, click Complete & Continue.');
                }, 1200);
            });
        } else {
            unlockCompletion('Confirm completion after reviewing the external resource.');
        }
        return;
    }

    var waitSeconds = completionRule === 'document' || completionRule === 'slides' ? 5 : 3;
    setButtonState(true, 'Review In Progress');
    setHint('Completion unlocks in ' + waitSeconds + ' seconds.');

    unlockTimer = window.setInterval(function () {
        waitSeconds -= 1;
        if (waitSeconds <= 0) {
            unlockCompletion('Review complete. You can complete this material now.');
            return;
        }
        setHint('Completion unlocks in ' + waitSeconds + ' seconds.');
    }, 1000);

})();
</script>
