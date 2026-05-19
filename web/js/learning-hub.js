(function () {
    var body = document.body;
    if (!body || !body.classList.contains('lh-shell-page')) {
        return;
    }

    var contextPath = body.dataset.contextPath || '';
    var flowLinks = Array.prototype.slice.call(document.querySelectorAll('.lh-flow-link'));
    var prevAction = document.getElementById('lhPrevAction');
    var nextAction = document.getElementById('lhNextAction');
    var completeButton = document.getElementById('edMarkCompleted');
    var actionNote = null;
    var itemStatusBadge = document.getElementById('lhItemStatusBadge');
    var progressPercentNode = document.getElementById('lhSidebarProgressPercent');
    var progressBar = document.getElementById('lhSidebarProgressBar');
    var materialsViewedNode = document.getElementById('edMaterialsViewedCount');
    var currentMaterialType = body.dataset.currentMaterialType || '';
    var currentSelectionMode = body.dataset.currentSelectionMode || '';
    var totalMaterialCount = Number(body.dataset.materialCount || '0');
    var courseExpired = body.dataset.courseExpired === 'true';
    var viewerState = {
        completionRule: '',
        unlocked: body.dataset.materialCompleted === 'true',
        completed: body.dataset.materialCompleted === 'true'
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
            var color = '#dc2626';
            if (progressPercent >= 35 && progressPercent < 75) {
                color = '#f59e0b';
            } else if (progressPercent >= 75) {
                color = '#10b981';
            }
            progressBar.style.backgroundColor = color;
        }
    }

    function setMaterialsViewed(viewed, total) {
        if (!materialsViewedNode || typeof viewed !== 'number') {
            return;
        }
        var totalValue = typeof total === 'number' ? total : totalMaterialCount;
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

        if (courseExpired) {
            setCompletionButton(true, 'Course Expired');
            return;
        }

        var label = 'Mark Complete';
        if (currentMaterialType === 'Video' || currentMaterialType === 'Audio') {
            label = 'Complete After Playback';
        } else if (currentMaterialType === 'Link') {
            label = 'Open Resource First';
        } else {
            label = 'Review In Progress';
        }

        setCompletionButton(true, label);
    }

    function unlockCompletion(note) {
        if (!completeButton || viewerState.completed || currentSelectionMode !== 'material' || courseExpired) {
            return;
        }
        viewerState.unlocked = true;
        setCompletionButton(false, 'Mark Complete');
        if (actionNote && note) {
            actionNote.textContent = note;
        }
    }

    function bindNativeMediaUnlock() {
        if (currentSelectionMode !== 'material' || viewerState.completed || courseExpired) {
            return;
        }
        var mediaNodes = Array.prototype.slice.call(document.querySelectorAll('.lh-video-player, .lh-audio-player'));
        if (!mediaNodes.length) {
            return;
        }
        mediaNodes.forEach(function (mediaNode) {
            var unlocked = false;
            function maybeUnlock() {
                if (unlocked || viewerState.completed || !mediaNode.duration || isNaN(mediaNode.duration)) {
                    return;
                }
                var threshold = mediaNode.duration * 0.8;
                if (mediaNode.currentTime >= threshold || mediaNode.ended) {
                    unlocked = true;
                    unlockCompletion('Playback progress is sufficient. You can mark this material complete now.');
                }
            }
            mediaNode.addEventListener('timeupdate', maybeUnlock);
            mediaNode.addEventListener('ended', function () {
                unlocked = true;
                unlockCompletion('Playback completed. You can mark this material complete now.');
            });
        });
    }

    function bindExternalResourceUnlock() {
        if (currentSelectionMode !== 'material' || currentMaterialType !== 'Link' || viewerState.completed || courseExpired) {
            return;
        }
        var resourceLink = document.querySelector('.lh-link-preview a[target="_blank"]');
        if (resourceLink) {
            resourceLink.addEventListener('click', function () {
                window.setTimeout(function () {
                    unlockCompletion('Resource opened. You can mark this material complete when finished.');
                }, 800);
            });
        }
    }

    updatePager();
    setProgress(Number(body.dataset.progressPercent || '0'));

    if (completeButton) {
        if (viewerState.completed) {
            setCompletionButton(true, 'Completed');
        } else if (courseExpired) {
            setCompletionButton(true, 'Course Expired');
        } else {
            setWaitingState();
            if (currentMaterialType !== 'Video' && currentMaterialType !== 'Audio' && currentMaterialType !== 'Link') {
                window.setTimeout(function () {
                    if (!viewerState.unlocked && !viewerState.completed) {
                        unlockCompletion('Review complete. You can mark this material complete now.');
                    }
                }, 5500);
            }
            bindNativeMediaUnlock();
            bindExternalResourceUnlock();
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

            fetch(contextPath + '/student/mark-material-completed', {
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
        }

        if (event.data.type === 'lhViewerUnlock') {
            unlockCompletion(event.data.note || 'You can mark this material complete now.');
        }
    });
})();
