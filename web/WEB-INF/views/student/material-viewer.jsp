<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material Preview - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/material-viewer-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Material Preview"/>
<c:set var="topbarSubtitle" value="Preview materials and continue learning"/>
<c:set var="previewEnrollmentId" value="${not empty previewEnrollment ? previewEnrollment.enrollmentId : ''}"/>
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
            <a href="${backToHubUrl}">Learning Hub</a>
            <span>/</span>
            <span>Material Preview</span>
        </div>

        <section class="sv-card mv-head-card">
            <div class="sv-card-body mv-head-body">
                <div class="mv-head-copy">
                    <div class="mv-head-top">
                        <p class="mv-kicker">${material.materialType}</p>
                        <span id="mvStatusBadge" class="status-badge ${materialStatusClass}">${materialStatusLabel}</span>
                    </div>
                    <h2>${material.title}</h2>
                    <p class="mv-description">
                        <c:choose>
                            <c:when test="${not empty material.description}">${material.description}</c:when>
                            <c:otherwise>No description provided for this material.</c:otherwise>
                        </c:choose>
                    </p>
                    <div class="mv-meta-grid">
                        <div class="mv-meta-item">
                            <span>Sequence</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${materialPosition > 0}">${materialPosition} of ${totalMaterialsInCourse}</c:when>
                                    <c:otherwise>Standalone</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>
                        <div class="mv-meta-item">
                            <span>Uploaded</span>
                            <strong><c:out value="${not empty material.uploadDate ? material.uploadDate.toLocalDate() : '-'}"/></strong>
                        </div>
                        <div class="mv-meta-item">
                            <span>Tracking Rule</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${completionRule == 'video' || completionRule == 'audio'}">Finish playback</c:when>
                                    <c:when test="${completionRule == 'document' || completionRule == 'slides'}">Review, then confirm</c:when>
                                    <c:when test="${completionRule == 'link'}">Open external resource</c:when>
                                    <c:otherwise>Open and confirm</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>
                    </div>
                </div>
                <div class="mv-head-actions">
                    <a class="sv-btn" href="${backToHubUrl}">${backToHubLabel}</a>
                    <c:if test="${not empty previousMaterial}">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${previousMaterial.materialId}&enrollmentId=${previewEnrollmentId}">
                            <i class="fas fa-arrow-left"></i>&nbsp;Previous
                        </a>
                    </c:if>
                    <c:if test="${not empty nextMaterial}">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${nextMaterial.materialId}&enrollmentId=${previewEnrollmentId}">
                            Next&nbsp;<i class="fas fa-arrow-right"></i>
                        </a>
                    </c:if>
                    <a class="sv-btn" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${material.materialId}">Open in New Tab</a>
                    <c:if test="${material.materialType != 'Link'}">
                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=download&id=${material.materialId}">Download</a>
                    </c:if>
                </div>
            </div>
        </section>

        <section class="sv-card mv-tracking-card">
            <div class="sv-card-body mv-tracking-body">
                <div class="mv-tracking-copy">
                    <span class="mv-kicker">Study Tracking</span>
                    <h3 id="mvCompletionHeading">
                        <c:choose>
                            <c:when test="${isCompletedMaterial}">This material is already completed</c:when>
                            <c:otherwise>Finish this step to keep your learning progress moving</c:otherwise>
                        </c:choose>
                    </h3>
                    <p id="mvCompletionHint" class="mv-tracking-hint">
                        <c:choose>
                            <c:when test="${isCompletedMaterial}">Your course progress already includes this material. You can continue to the next chapter anytime.</c:when>
                            <c:when test="${completionRule == 'video' || completionRule == 'audio'}">Complete most of the playback or finish the media to unlock completion automatically.</c:when>
                            <c:when test="${completionRule == 'document' || completionRule == 'slides'}">Spend a little time reviewing the content, then confirm completion here.</c:when>
                            <c:when test="${completionRule == 'link'}">Open the external resource, review it, then confirm completion when you return.</c:when>
                            <c:otherwise>Review this material, then mark it completed to update your study progress.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="mv-tracking-actions">
                    <button
                            type="button"
                            id="mvMarkCompleted"
                            class="sv-btn primary"
                            data-material-id="${material.materialId}"
                            data-enrollment-id="${previewEnrollmentId}"
                            data-completion-rule="${completionRule}"
                            data-completed="${isCompletedMaterial}"
                            data-complete-url="${completeActionUrl}"
                            <c:if test="${isCompletedMaterial}">disabled="disabled"</c:if>>
                        <c:choose>
                            <c:when test="${isCompletedMaterial}">Completed</c:when>
                            <c:otherwise>Mark as Completed</c:otherwise>
                        </c:choose>
                    </button>
                    <c:choose>
                        <c:when test="${not empty nextMaterial}">
                            <a id="mvNextAction" class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${nextMaterial.materialId}&enrollmentId=${previewEnrollmentId}">Open Next Material</a>
                        </c:when>
                        <c:otherwise>
                            <a id="mvNextAction" class="sv-btn" href="${backToHubUrl}">Back to Learning Hub</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </section>

        <section class="sv-card mv-viewer-card">
            <div class="sv-card-body">
                <c:choose>
                    <c:when test="${isLinkMaterial}">
                        <div class="mv-link-state">
                            <i class="fas fa-link"></i>
                            <h3>External Resource</h3>
                            <p>This material opens outside the platform. Review it in a new tab, then return here to confirm completion.</p>
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
                            <iframe class="mv-frame" src="${streamUrl}" title="Material PDF preview"></iframe>
                        </div>
                    </c:when>
                    <c:when test="${canInlinePreview}">
                        <div class="mv-frame-wrap">
                            <iframe class="mv-frame" src="${streamUrl}" title="Material preview"></iframe>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mv-link-state">
                            <i class="fas fa-file-arrow-down"></i>
                            <h3>Preview Not Available</h3>
                            <p>This file type cannot be embedded reliably in-browser. Use download or open in a new tab, then confirm completion here.</p>
                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=download&id=${material.materialId}">Download File</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
(function () {
    var completeButton = document.getElementById('mvMarkCompleted');
    var completionHint = document.getElementById('mvCompletionHint');
    var completionHeading = document.getElementById('mvCompletionHeading');
    var nextAction = document.getElementById('mvNextAction');
    var statusBadge = document.getElementById('mvStatusBadge');
    var playbackMedia = document.getElementById('mvPlaybackMedia');
    var openResourceLink = document.getElementById('mvOpenResource');
    var unlockTimer = null;
    var completionRequested = false;

    if (!completeButton) {
        return;
    }

    var completionRule = completeButton.getAttribute('data-completion-rule') || 'default';
    var completeUrl = completeButton.getAttribute('data-complete-url');
    var materialId = completeButton.getAttribute('data-material-id');
    var enrollmentId = completeButton.getAttribute('data-enrollment-id');
    var alreadyCompleted = completeButton.getAttribute('data-completed') === 'true';

    completeButton.addEventListener('click', function () {
        if (completeButton.disabled) {
            return;
        }
        markCompleted();
    });

    function setHint(message) {
        if (completionHint) {
            completionHint.textContent = message;
        }
    }

    function setButtonState(disabled, label) {
        completeButton.disabled = !!disabled;
        if (label) {
            completeButton.textContent = label;
        }
    }

    function unlockCompletion(message) {
        if (alreadyCompleted) {
            return;
        }
        if (unlockTimer) {
            window.clearInterval(unlockTimer);
            unlockTimer = null;
        }
        setButtonState(false, 'Mark as Completed');
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
        if (completionHeading) {
            completionHeading.textContent = 'This material is completed';
        }
        setHint(message || 'Your course progress has been updated for this material.');
    }

    function markCompleted() {
        if (alreadyCompleted || completionRequested || !completeUrl || !materialId) {
            return;
        }

        completionRequested = true;
        setButtonState(true, 'Saving...');
        var payload = 'materialId=' + encodeURIComponent(materialId);
        if (enrollmentId) {
            payload += '&enrollmentId=' + encodeURIComponent(enrollmentId);
        }

        fetch(completeUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
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
                applyCompletedState('Marked complete. Your learning progress is now updated.');
                if (nextAction && data.continueLabel && data.continueUrl) {
                    nextAction.textContent = data.continueLabel;
                    nextAction.setAttribute('href', data.continueUrl);
                }
            })
            .catch(function (error) {
                completionRequested = false;
                setButtonState(false, 'Mark as Completed');
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
            unlockCompletion('Playback could not be detected, so you can confirm completion manually.');
            return;
        }

        playbackMedia.addEventListener('timeupdate', function () {
            if (!playbackMedia.duration || alreadyCompleted) {
                return;
            }
            var progress = playbackMedia.currentTime / playbackMedia.duration;
            if (progress >= 0.85) {
                unlockCompletion('Playback threshold reached. You can mark this material as completed.');
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
                    unlockCompletion('After reviewing the external resource, confirm completion here.');
                }, 1200);
            });
        } else {
            unlockCompletion('Confirm completion after reviewing the external resource.');
        }
        return;
    }

    var waitSeconds = completionRule === 'document' || completionRule === 'slides' ? 12 : 8;
    setButtonState(true, 'Review In Progress');
    setHint('Spend a little time reviewing this material. Completion unlocks in ' + waitSeconds + ' seconds.');

    unlockTimer = window.setInterval(function () {
        waitSeconds -= 1;
        if (waitSeconds <= 0) {
            unlockCompletion('Review complete. You can mark this material as completed now.');
            return;
        }
        setHint('Spend a little time reviewing this material. Completion unlocks in ' + waitSeconds + ' seconds.');
    }, 1000);

})();
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
