<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-player.css">


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
                <div class="mv-frame-wrap" style="background: #cbd5e1; display: flex; flex-direction: column;">
                    <!-- PDF Toolbar -->
                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; background: #334155; color: white; flex-shrink: 0;">
                        <div style="display: flex; gap: 8px;">
                            <button id="pdf-prev" class="sv-btn" style="background: rgba(255,255,255,0.1); color: white; border: none; padding: 6px 12px;"><i class="fas fa-chevron-left"></i></button>
                            <button id="pdf-next" class="sv-btn" style="background: rgba(255,255,255,0.1); color: white; border: none; padding: 6px 12px;"><i class="fas fa-chevron-right"></i></button>
                        </div>
                        <div style="font-size: 0.9rem; font-weight: 500;">
                            Page <span id="pdf-page-num">0</span> of <span id="pdf-page-count">0</span>
                        </div>
                        <div style="display: flex; gap: 8px;">
                            <button id="pdf-zoomin" class="sv-btn" style="background: rgba(255,255,255,0.1); color: white; border: none; padding: 6px 12px;" title="Zoom In"><i class="fas fa-magnifying-glass-plus"></i></button>
                            <button id="pdf-zoomout" class="sv-btn" style="background: rgba(255,255,255,0.1); color: white; border: none; padding: 6px 12px;" title="Zoom Out"><i class="fas fa-magnifying-glass-minus"></i></button>
                            <a class="sv-btn" href="${streamUrl}" target="_blank" rel="noopener" style="background: var(--accent); color: white; border: none; padding: 6px 12px; margin-left: 8px;"><i class="fas fa-download"></i> <span class="hide-on-mobile">Download</span></a>
                        </div>
                    </div>
                    
                    <!-- PDF Canvas Container -->
                    <div id="pdf-render-container" style="flex: 1; overflow: auto; display: flex; justify-content: center; align-items: flex-start; padding: 24px; position: relative; height: 100%; min-height: 60vh;">
                        <div id="pdf-loading-spinner" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #475569; display: flex; flex-direction: column; align-items: center; gap: 12px;">
                            <i class="fas fa-spinner fa-spin fa-2x"></i>
                            <span>Loading Document...</span>
                        </div>
                        <canvas id="pdf-canvas" style="display: none; box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1); max-width: 100%; border-radius: 4px;"></canvas>
                    </div>
                </div>
                
                <!-- PDF.js Integration Script -->
                <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
                        
                        const url = '${streamUrl}';
                        let pdfDoc = null,
                            pageNum = 1,
                            pageIsRendering = false,
                            pageNumIsPending = null,
                            scale = 1.2,
                            canvas = document.getElementById('pdf-canvas'),
                            ctx = canvas.getContext('2d'),
                            spinner = document.getElementById('pdf-loading-spinner');
                            
                        if (window.innerWidth < 768) {
                            scale = window.innerWidth / 800;
                            if(scale < 0.5) scale = 0.5;
                        }

                        function renderPage(num) {
                            pageIsRendering = true;
                            
                            pdfDoc.getPage(num).then(page => {
                                const viewport = page.getViewport({ scale });
                                canvas.height = viewport.height;
                                canvas.width = viewport.width;

                                const renderCtx = {
                                    canvasContext: ctx,
                                    viewport: viewport
                                };

                                page.render(renderCtx).promise.then(() => {
                                    pageIsRendering = false;
                                    spinner.style.display = 'none';
                                    canvas.style.display = 'block';

                                    if (pageNumIsPending !== null) {
                                        renderPage(pageNumIsPending);
                                        pageNumIsPending = null;
                                    }
                                });
                            });

                            document.getElementById('pdf-page-num').textContent = num;
                        }

                        function queueRenderPage(num) {
                            if (pageIsRendering) {
                                pageNumIsPending = num;
                            } else {
                                renderPage(num);
                            }
                        }

                        function onPrevPage() {
                            if (pageNum <= 1) return;
                            pageNum--;
                            queueRenderPage(pageNum);
                        }

                        function onNextPage() {
                            if (pageNum >= pdfDoc.numPages) return;
                            pageNum++;
                            queueRenderPage(pageNum);
                        }
                        
                        function onZoomIn() {
                            scale += 0.2;
                            queueRenderPage(pageNum);
                        }
                        
                        function onZoomOut() {
                            if(scale <= 0.4) return;
                            scale -= 0.2;
                            queueRenderPage(pageNum);
                        }

                        document.getElementById('pdf-prev').addEventListener('click', onPrevPage);
                        document.getElementById('pdf-next').addEventListener('click', onNextPage);
                        document.getElementById('pdf-zoomin').addEventListener('click', onZoomIn);
                        document.getElementById('pdf-zoomout').addEventListener('click', onZoomOut);

                        pdfjsLib.getDocument(url).promise.then(pdfDoc_ => {
                            pdfDoc = pdfDoc_;
                            document.getElementById('pdf-page-count').textContent = pdfDoc.numPages;
                            renderPage(pageNum);
                        }).catch(err => {
                            spinner.innerHTML = '<i class="fas fa-exclamation-triangle" style="color:#ef4444; font-size:2rem; margin-bottom:12px;"></i><span style="color:#334155; text-align:center;">Failed to load PDF document.<br>It might be corrupted or missing.</span>';
                            console.error(err);
                        });
                    });
                </script>
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
