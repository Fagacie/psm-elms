(function () {
    var body = document.body;
    if (!body || !body.classList.contains('lh-shell-page')) {
        return;
    }

    var contextPath = body.dataset.contextPath || '';
    var flowLinks = Array.prototype.slice.call(document.querySelectorAll('.lh-chapter-item'));
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
        // Support both old sv-progress-bar and new slim fill bar
        if (progressBar) {
            progressBar.style.width = progressPercent + '%';
            // legacy color update only if it's the old bar type
            if (progressBar.classList.contains('sv-progress-bar')) {
                var color = '#dc2626';
                if (progressPercent >= 35 && progressPercent < 75) {
                    color = '#f59e0b';
                } else if (progressPercent >= 75) {
                    color = '#10b981';
                }
                progressBar.style.backgroundColor = color;
            }
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
        if (!completeButton || viewerState.completed || currentSelectionMode !== 'material' || courseExpired) {
            return;
        }
        setCompletionButton(false, 'Mark Complete');
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
        // Playback threshold limits bypassed for immediate manual progress tracking
    }

    function bindExternalResourceUnlock() {
        // External link click limits bypassed for immediate manual progress tracking
    }

    // ── ACCORDION: open/close chapter groups ──────────────────
    var chapters = Array.prototype.slice.call(document.querySelectorAll('.lh-chapter'));
    chapters.forEach(function (chapter) {
        var toggle = chapter.querySelector('.lh-chapter__toggle');
        var items  = chapter.querySelector('.lh-chapter__items');
        if (!toggle || !items) return;

        // On page load: open chapters that contain the active item (driven by server-side data-has-active)
        if (chapter.dataset.hasActive === 'true') {
            chapter.classList.add('is-open');
            toggle.classList.add('has-active');
            toggle.setAttribute('aria-expanded', 'true');
        }

        toggle.addEventListener('click', function () {
            var isOpen = chapter.classList.contains('is-open');
            chapter.classList.toggle('is-open', !isOpen);
            toggle.setAttribute('aria-expanded', String(!isOpen));
        });
    });

    // ── MOBILE SIDEBAR TOGGLE ─────────────────────────────────
    var sidebarToggle = document.getElementById('lhSidebarToggle');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function () {
            var isOpen = body.classList.toggle('lh-sidebar-open');
            sidebarToggle.setAttribute('aria-expanded', String(isOpen));
        });

        // Close sidebar when user clicks the dim overlay
        body.addEventListener('click', function (e) {
            if (body.classList.contains('lh-sidebar-open') &&
                !e.target.closest('#svSidebar') &&
                !e.target.closest('#lhSidebarToggle')) {
                body.classList.remove('lh-sidebar-open');
                sidebarToggle.setAttribute('aria-expanded', 'false');
            }
        });
    }

    // ── PREV / NEXT LABEL INJECTION ───────────────────────────
    var prevLabelEl = document.getElementById('lhPrevLabel');
    var nextLabelEl = document.getElementById('lhNextLabel');

    // Collect all chapter-items (the new accordion anchors)
    var allChapterItems = Array.prototype.slice.call(
        document.querySelectorAll('.lh-chapter-item')
    );

    function injectNavLabels() {
        var activeIdx = -1;
        for (var i = 0; i < allChapterItems.length; i++) {
            if (allChapterItems[i].classList.contains('is-active')) {
                activeIdx = i;
                break;
            }
        }
        if (activeIdx < 0) return;

        if (prevLabelEl && activeIdx > 0) {
            var prevTitle = allChapterItems[activeIdx - 1].getAttribute('aria-label') ||
                            (allChapterItems[activeIdx - 1].querySelector('.lh-ci-title') || {}).textContent || '';
            prevTitle = String(prevTitle);
            prevLabelEl.textContent = prevTitle.replace(/ — (Completed|Locked)$/, '');
        }
        if (nextLabelEl && activeIdx < allChapterItems.length - 1) {
            var nextTitle = allChapterItems[activeIdx + 1].getAttribute('aria-label') ||
                            (allChapterItems[activeIdx + 1].querySelector('.lh-ci-title') || {}).textContent || '';
            nextTitle = String(nextTitle);
            nextLabelEl.textContent = nextTitle.replace(/ — (Completed|Locked)$/, '');
        }
    }

    // ── TOPBAR PROGRESS SYNC ──────────────────────────────────
    var topbarPct  = document.getElementById('lhTopbarPct');
    var topbarFill = document.getElementById('lhTopbarFill');

    function syncTopbarProgress(pct) {
        if (topbarPct)  topbarPct.textContent = pct + '%';
        if (topbarFill) topbarFill.style.width = pct + '%';
    }

    updatePager();
    var initialProgress = Number(body.dataset.progressPercent || '0');
    setProgress(initialProgress);
    syncTopbarProgress(initialProgress);
    injectNavLabels();

    if (completeButton) {
        if (viewerState.completed) {
            setCompletionButton(true, 'Completed');
        } else if (courseExpired) {
            setCompletionButton(true, 'Course Expired');
        } else {
            setWaitingState();

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
                    syncTopbarProgress(data.progressPercent);
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
        if (event.origin !== window.location.origin || !event.data) {
            return;
        }

        // Theme sync support from secure assessment workspace
        if (event.data.type === 'syncTheme') {
            document.documentElement.setAttribute('data-theme', event.data.theme);
            try {
                localStorage.setItem('psme-theme', event.data.theme);
            } catch (e) {}
            
            // Trigger visual button updates if toggle buttons exist
            var buttons = document.querySelectorAll('[data-theme-toggle]');
            buttons.forEach(function (button) {
                var label = button.querySelector('.theme-toggle-label');
                var icon = button.querySelector('i');
                var theme = event.data.theme;
                var nextThemeLabel = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
                
                button.setAttribute('aria-pressed', String(theme === 'dark'));
                button.setAttribute('aria-label', nextThemeLabel);
                button.setAttribute('title', nextThemeLabel);
                button.dataset.theme = theme;
                if (icon) {
                    icon.className = theme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
                }
                if (label) {
                    label.textContent = nextThemeLabel;
                }
            });
            return;
        }

        if (currentSelectionMode !== 'material') {
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
