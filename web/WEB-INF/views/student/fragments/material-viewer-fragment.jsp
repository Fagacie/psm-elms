<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-player.css">
<style>
.mv-youtube-wrap {
    position: relative;
    width: 100%;
    padding-top: 56.25%; /* 16:9 ratio */
    background: #000;
    border-radius: 12px;
    overflow: hidden;
}
.mv-youtube-frame {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    border: none;
    border-radius: 12px;
}
.mv-youtube-note {
    margin: 14px 0 0;
    font-size: 0.84rem;
    color: #64748b;
    display: flex;
    align-items: center;
    gap: 8px;
}
.mv-youtube-note .fab { color: #ef4444; font-size: 1.1rem; }
</style>

<div class="cp-fragment lh-fragment-viewer">
    <div class="cp-viewer-container">
        <c:choose>
            <c:when test="${isYouTubeMaterial}">
                <c:choose>
                    <c:when test="${not empty youtubeVideoId}">
                        <div class="mv-youtube-wrap">
                            <iframe
                                class="mv-youtube-frame"
                                src="https://www.youtube.com/embed/${youtubeVideoId}?rel=0&modestbranding=1&enablejsapi=1"
                                title="${material.title}"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                                allowfullscreen
                                loading="lazy">
                            </iframe>
                        </div>
                        <p class="mv-youtube-note">
                            <i class="fab fa-youtube"></i>
                            You can mark this material complete after watching.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <div class="mv-link-state">
                            <i class="fab fa-youtube"></i>
                            <h3>YouTube Video</h3>
                            <p>The YouTube URL for this material appears to be invalid. Contact your instructor.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:when test="${isLinkMaterial}">
                <div class="mv-link-state">
                    <i class="fas fa-link"></i>
                    <h3>External Resource</h3>
                    <p>Opens in a new tab.</p>
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
            return 'Already complete.';
        }
        if (completionRule === 'video' || completionRule === 'audio') {
            return 'Playback unlocks completion.';
        }
        if (completionRule === 'link') {
            return 'Open the resource to continue.';
        }
        return 'Review the material.';
    }

    postToParent('lhViewerState', initialNote());

    if (alreadyCompleted) {
        return;
    }

    if (completionRule === 'video' || completionRule === 'audio') {
        if (!playbackMedia) {
            postToParent('lhViewerUnlock', 'You can mark this material complete manually.');
            return;
        }

        playbackMedia.addEventListener('timeupdate', function () {
            if (!playbackMedia.duration) {
                return;
            }
            var progress = playbackMedia.currentTime / playbackMedia.duration;
            if (progress >= 0.85) {
                postToParent('lhViewerUnlock', 'You can mark this material complete now.');
            }
        });

        playbackMedia.addEventListener('ended', function () {
            postToParent('lhViewerUnlock', 'You can mark this material complete now.');
        });
        return;
    }

    if (completionRule === 'link' || completionRule === 'youtube') {
        if (openResourceLink) {
            openResourceLink.addEventListener('click', function () {
                window.setTimeout(function () {
                    postToParent('lhViewerUnlock', 'You can mark this material complete now.');
                }, 1200);
            });
        } else if (completionRule === 'youtube') {
            // Unlock after a delay for YouTube viewers
            window.setTimeout(function () {
                postToParent('lhViewerUnlock', 'You can mark this material complete now.');
            }, 4000);
        }
        return;
    }

    window.setTimeout(function () {
        postToParent('lhViewerUnlock', 'You can mark this material complete now.');
    }, completionRule === 'document' || completionRule === 'slides' ? 5000 : 3000);
})();
</script>
