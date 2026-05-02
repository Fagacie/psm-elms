<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-player.css">

<div class="cp-fragment lh-fragment-viewer">
    <div class="cp-viewer-container">
        <c:choose>
            <c:when test="${isLinkMaterial}">
                <div class="mv-link-state">
                    <i class="fas fa-link"></i>
                    <h3>External Resource</h3>
                    <p>This resource opens in a new tab.</p>
                    <a id="mvOpenResource"
                       class="cp-inline-link"
                       target="_blank"
                       rel="noopener noreferrer"
                       href="${pageContext.request.contextPath}/student/materials?action=view&id=${material.materialId}">
                        Open Resource
                    </a>
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
                    <iframe class="mv-frame" src="${streamUrl}" title="Material preview"></iframe>
                </div>
            </c:when>
            <c:otherwise>
                <div class="mv-link-state">
                    <i class="fas fa-file-arrow-down"></i>
                    <h3>Preview Not Available</h3>
                    <p>This file cannot be embedded reliably in the browser.</p>
                    <a class="cp-inline-link" href="${pageContext.request.contextPath}/student/materials?action=download&id=${material.materialId}">
                        Download File
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
(function () {
    var playbackMedia = document.getElementById('mvPlaybackMedia');
    var openResourceLink = document.getElementById('mvOpenResource');
    var completionRule = '${completionRule}';
    var alreadyCompleted = '${isCompletedMaterial}' === 'true';

    function postToParent(type, note) {
        if (!window.parent || window.parent === window) {
            return;
        }

        window.parent.postMessage({
            type: type,
            completionRule: completionRule,
            completed: alreadyCompleted,
            note: note || ''
        }, window.location.origin);
    }

    function initialNote() {
        if (alreadyCompleted) {
            return 'This material is already part of your course progress.';
        }
        if (completionRule === 'video' || completionRule === 'audio') {
            return 'Playback unlocks completion once you reach the required threshold.';
        }
        if (completionRule === 'link') {
            return 'Open the external resource in the viewer.';
        }
        return 'Review the current material.';
    }

    postToParent('lhViewerState', initialNote());

    if (alreadyCompleted) {
        return;
    }

    if (completionRule === 'video' || completionRule === 'audio') {
        if (!playbackMedia) {
            postToParent('lhViewerUnlock', 'Playback could not be detected. You can mark this material complete manually.');
            return;
        }

        playbackMedia.addEventListener('timeupdate', function () {
            if (!playbackMedia.duration) {
                return;
            }
            var progress = playbackMedia.currentTime / playbackMedia.duration;
            if (progress >= 0.85) {
                postToParent('lhViewerUnlock', 'Playback threshold reached. You can mark this material complete now.');
            }
        });

        playbackMedia.addEventListener('ended', function () {
            postToParent('lhViewerUnlock', 'Playback finished. You can mark this material complete now.');
        });
        return;
    }

    if (completionRule === 'link') {
        if (openResourceLink) {
            openResourceLink.addEventListener('click', function () {
                window.setTimeout(function () {
                    postToParent('lhViewerUnlock', 'After reviewing the external resource, you can mark this item complete.');
                }, 1200);
            });
        }
        return;
    }

    window.setTimeout(function () {
        postToParent('lhViewerUnlock', 'Review complete. You can mark this material complete now.');
    }, completionRule === 'document' || completionRule === 'slides' ? 5000 : 3000);
})();
</script>
