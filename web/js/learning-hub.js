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
        if (progressBar) {
            progressBar.style.width = progressPercent + '%';
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

    // ── SIDEBAR TOGGLE (MOBILE & DESKTOP) ─────────────────────────────────
    var sidebarToggle = document.getElementById('hubMobileToggle');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function () {
            if (window.innerWidth > 1100) {
                var isClosed = body.classList.toggle('lh-sidebar-desktop-closed');
                sidebarToggle.setAttribute('aria-expanded', String(!isClosed));
            } else {
                var isOpen = body.classList.toggle('lh-sidebar-open');
                sidebarToggle.setAttribute('aria-expanded', String(isOpen));
            }
        });

        body.addEventListener('click', function (e) {
            if (window.innerWidth <= 1100 &&
                body.classList.contains('lh-sidebar-open') &&
                !e.target.closest('#svSidebar') &&
                !e.target.closest('#hubMobileToggle')) {
                body.classList.remove('lh-sidebar-open');
                sidebarToggle.setAttribute('aria-expanded', 'false');
            }
        });
    }

    // ── PREV / NEXT LABEL INJECTION ───────────────────────────
    var prevLabelEl = document.getElementById('lhPrevLabel');
    var nextLabelEl = document.getElementById('lhNextLabel');

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
                            (allChapterItems[activeIdx - 1].querySelector('.hub_moduleTitle') || {}).textContent || '';
            prevTitle = String(prevTitle);
            prevLabelEl.textContent = prevTitle.replace(/ — (Completed|Locked)$/, '');
        }
        if (nextLabelEl && activeIdx < allChapterItems.length - 1) {
            var nextTitle = allChapterItems[activeIdx + 1].getAttribute('aria-label') ||
                            (allChapterItems[activeIdx + 1].querySelector('.hub_moduleTitle') || {}).textContent || '';
            nextTitle = String(nextTitle);
            nextLabelEl.textContent = nextTitle.replace(/ — (Completed|Locked)$/, '');
        }
    }

    // ── TOPBAR PROGRESS SYNC ──────────────────────────────────
    var topbarPct  = document.getElementById('lhTopbarPct');
    var topbarFill = document.getElementById('lhTopbarFill');

    function syncTopbarProgress(pct) {
        if (topbarPct)  topbarPct.textContent = pct + '% Modules';
        if (topbarFill) topbarFill.style.width = pct + '%';
    }

    // ── SIDEBAR CLICK INTERCEPTION (SPA) ──────────────────────
    function bindSidebarClicks() {
        flowLinks.forEach(function (link) {
            if (link.dataset.clickBound === 'true') return;
            link.dataset.clickBound = 'true';

            link.addEventListener('click', function (e) {
                if (link.getAttribute('aria-disabled') === 'true') {
                    e.preventDefault();
                    return;
                }
                var url = link.getAttribute('href');
                if (url) {
                    if (typeof window.loadStageContent === 'function') {
                        e.preventDefault();
                        window.loadStageContent(url);
                    } else {
                        // Let the browser perform standard navigation (default action)
                    }
                }
            });
        });
    }

    // ── FOOTER ACTIONS CLICK INTERCEPTION (SPA) ────────────────
    function bindFooterClicks() {
        if (prevAction) {
            prevAction.addEventListener('click', function (e) {
                var url = prevAction.getAttribute('href');
                if (url) {
                    if (typeof window.loadStageContent === 'function') {
                        e.preventDefault();
                        window.loadStageContent(url);
                    } else {
                        // Let default navigation happen
                    }
                }
            });
        }
        if (nextAction) {
            nextAction.addEventListener('click', function (e) {
                var url = nextAction.getAttribute('href');
                if (url) {
                    if (typeof window.loadStageContent === 'function') {
                        e.preventDefault();
                        window.loadStageContent(url);
                    } else {
                        // Let default navigation happen
                    }
                }
            });
        }
    }

    // ── NAVIGATION TO NEXT SYLLABUS ITEM & VICTORY SCREEN ─────
    function showVictoryScreen() {
        var stage = document.querySelector('.lh-content-stage');
        if (!stage) return;
        
        var isEarned = !!document.querySelector('.lh-cert-overview-card.is-earned, .lh-cert-performance-card.is-earned, .is-earned');
        var isReady = !!document.querySelector('.lh-cert-overview-card.is-ready, .lh-cert-performance-card.is-ready, .is-ready');
        
        var progressPercentVal = 0;
        var progressPercentNode = document.getElementById('lhSidebarProgressPercent');
        if (progressPercentNode) {
            progressPercentVal = parseFloat(progressPercentNode.textContent) || 0;
        }
        if (!isEarned && !isReady && progressPercentVal >= 100) {
            isReady = true;
        }
        var downloadUrl = contextPath + '/student/certificate?enrollmentId=' + (body.dataset.enrollmentId || '');
        
        var certSection = '';
        if (isEarned) {
            certSection = 
                '<div style="margin-top: 32px;">' +
                    '<a href="' + downloadUrl + '" class="assessment_button assessment_button--primary" style="padding: 16px 32px; font-size: 1.1rem; border-radius: 50px; background: linear-gradient(135deg, #2563eb, #1d4ed8); border: none; color: #fff; box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.4); display: inline-flex; align-items: center; gap: 8px;">' +
                        '<i class="fas fa-medal"></i>' +
                        '<span>Download Certificate</span>' +
                    '</a>' +
                '</div>';
        } else if (isReady) {
            var enrollmentIdVal = '';
            if (completeButton) enrollmentIdVal = completeButton.getAttribute('data-enrollment-id');
            if (!enrollmentIdVal) {
                var urlParams = new URLSearchParams(window.location.search);
                enrollmentIdVal = urlParams.get('id') || urlParams.get('enrollmentId') || '';
            }
            certSection = 
                '<div style="margin-top: 32px;">' +
                    '<form method="post" action="' + contextPath + '/student/certificate" style="display: inline-block;">' +
                        '<input type="hidden" name="enrollmentId" value="' + enrollmentIdVal + '">' +
                        '<button type="submit" class="assessment_button assessment_button--primary" style="padding: 16px 32px; font-size: 1.1rem; border-radius: 50px; background: linear-gradient(135deg, #10b981, #059669); border: none; color: #fff; box-shadow: 0 10px 25px -5px rgba(5, 150, 105, 0.4); display: inline-flex; align-items: center; gap: 8px;">' +
                            '<i class="fas fa-award"></i>' +
                            '<span>Claim & Generate Certificate</span>' +
                        '</button>' +
                    '</form>' +
                '</div>';
        }
        
        stage.innerHTML = 
            '<div style="max-width: 700px; margin: 60px auto; padding: 60px 40px; text-align: center; background: #ffffff; border-radius: 24px; box-shadow: 0 20px 40px -15px rgba(0,0,0,0.05); border: 1px solid #f1f5f9;">' +
                '<div style="width: 100px; height: 100px; margin: 0 auto 30px; display: flex; align-items: center; justify-content: center; background: #ecfdf5; color: #10b981; border-radius: 50%; font-size: 3rem; box-shadow: 0 10px 20px -5px rgba(16, 185, 129, 0.2);">' +
                    '<i class="fas fa-trophy"></i>' +
                '</div>' +
                '<h2 style="font-size: 2.5rem; font-weight: 800; color: #0f172a; margin-bottom: 16px; letter-spacing: -0.03em;">Course Completed!</h2>' +
                '<p style="font-size: 1.125rem; color: #64748b; line-height: 1.7; max-width: 50ch; margin: 0 auto 32px;">' +
                    'Congratulations! You have completed all lesson materials and passed all required assessments. You have officially finished the course.' +
                '</p>' +
                '<div style="display: flex; flex-direction: column; align-items: center; gap: 16px;">' +
                    certSection +
                    '<a href="' + contextPath + '/student/my-enrollments" class="assessment_button" style="padding: 14px 28px; border-radius: 50px; color: #475569; font-weight: 600; text-decoration: none; border: 1px solid #e2e8f0; display: inline-flex; align-items: center; gap: 8px;">' +
                        '<i class="fas fa-house"></i>' +
                        '<span>Return to Dashboard</span>' +
                    '</a>' +
                '</div>' +
            '</div>';
    }

    function navigateToNextSyllabusItem() {
        var activeIdx = findActiveLink();
        if (activeIdx >= 0 && activeIdx < flowLinks.length - 1) {
            var nextLink = flowLinks[activeIdx + 1];
            var nextUrl = nextLink.getAttribute('href');
            if (nextUrl && typeof window.loadStageContent === 'function') {
                window.loadStageContent(nextUrl);
            } else {
                window.location.href = nextUrl;
            }
        } else {
            showVictoryScreen();
        }
    }

    updatePager();
    var initialProgress = Number(body.dataset.progressPercent || '0');
    setProgress(initialProgress);
    syncTopbarProgress(initialProgress);
    injectNavLabels();
    bindSidebarClicks();
    bindFooterClicks();

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
                navigateToNextSyllabusItem();
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

        if (event.data.type === 'syncTheme') {
            document.documentElement.setAttribute('data-theme', event.data.theme);
            try {
                localStorage.setItem('psme-theme', event.data.theme);
            } catch (e) {}
            
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

    window.LearningHub = {
        rebindLabels: function () {
            injectNavLabels();
            updatePager();
        },
        navigateToNext: navigateToNextSyllabusItem
    };
})();
