(function () {
    function init(root) {
        initStartTransitions(root);
        initStageToggles(root);
        initUploadZones(root);
        initChoiceBlocks(root);
        initAttemptExperience(root);
        initForms(root);
        initResultActions(root);
    }

    function stripDuplicateNav(container) {
        var selectors = ['.hub_topBar', '.hub_sidebar', '.sv-topbar', '.sv-sidebar', '.sv-layout > aside', 'header[role="banner"]'];
        selectors.forEach(function (sel) {
            container.querySelectorAll(sel).forEach(function (el) { el.remove(); });
        });
    }

    function notify(type, message) {
        if (window.StudentUX && typeof window.StudentUX.showToast === 'function') {
            window.StudentUX.showToast(message, type);
            return;
        }
        if (type === 'error') {
            window.alert(message);
        }
    }

    function confirmAction(title, message, onConfirm) {
        if (window.StudentUX && typeof window.StudentUX.confirm === 'function') {
            window.StudentUX.confirm(title, message, onConfirm);
            return;
        }
        if (window.confirm(message)) {
            onConfirm();
        }
    }

    function initStartTransitions(root) {
        root.querySelectorAll('[data-load-attempt-url]').forEach(function (button) {
            if (button.dataset.bound === 'true') {
                return;
            }
            button.dataset.bound = 'true';

            button.addEventListener('click', function (event) {
                event.preventDefault();
                var host = button.closest('[data-assessment-stage-host]') || document.querySelector('[data-assessment-stage-host]') || document.querySelector('.lh-content-stage');
                var url = button.getAttribute('data-load-attempt-url');
                if (!host || !url) {
                    window.location.href = url;
                    return;
                }

                var requestUrl = url + (url.indexOf('?') >= 0 ? '&' : '?') + 'fragment=true';
                host.classList.add('is-loading');
                button.classList.add('is-busy');
                button.setAttribute('aria-disabled', 'true');

                fetch(requestUrl, {
                    headers: {
                        'X-Requested-With': 'fetch'
                    }
                })
                .then(function (response) {
                    if (!response.ok) {
                        throw new Error('Unable to open assessment.');
                    }
                    return response.text();
                })
                .then(function (html) {
                    var parser = new DOMParser();
                    var doc = parser.parseFromString(html, 'text/html');
                    var targetContent = doc.querySelector('[data-attempt-shell]') || doc.querySelector('[data-assessment-stage-host]') || doc.querySelector('.lh-content-stage') || doc.querySelector('.ax-stage-host');
                    
                    if (targetContent) {
                        host.innerHTML = targetContent.tagName === 'SECTION' ? targetContent.outerHTML : targetContent.innerHTML;
                    } else {
                        host.innerHTML = html;
                    }
                    stripDuplicateNav(host);
                    
                    host.classList.remove('is-loading');
                    if (window.history && window.history.pushState) {
                        window.history.pushState({ assessmentStage: 'active' }, '', url);
                    }
                    init(host);
                    var focusTitle = host.querySelector('.title') || host.querySelector('.ax-focus__title');
                    if (focusTitle) {
                        focusTitle.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                })
                .catch(function (err) {
                    host.classList.remove('is-loading');
                    button.classList.remove('is-busy');
                    button.removeAttribute('aria-disabled');
                    window.location.href = url;
                });
            });
        });
    }

    function initStageToggles(root) {
        root.querySelectorAll('[data-stage-target]').forEach(function (button) {
            if (button.dataset.bound === 'true') {
                return;
            }
            button.dataset.bound = 'true';

            button.addEventListener('click', function () {
                var host = button.closest('[data-assessment-stage-host]') || root;
                var targetId = button.getAttribute('data-stage-target');
                var target = host.querySelector('#' + targetId);
                var current = host.querySelector('[data-stage-current]');
                if (!target) {
                    var globalTarget = document.getElementById(targetId);
                    if (globalTarget) target = globalTarget;
                }
                if (!target) {
                    return;
                }

                if (current) {
                    current.style.display = 'none';
                    current.removeAttribute('data-stage-current');
                }
                target.style.display = 'block';
                target.setAttribute('data-stage-current', 'true');
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        });
    }

    function formatBytes(bytes) {
        if (!bytes) {
            return '0 KB';
        }
        var units = ['B', 'KB', 'MB', 'GB'];
        var value = bytes;
        var unitIndex = 0;
        while (value >= 1024 && unitIndex < units.length - 1) {
            value = value / 1024;
            unitIndex += 1;
        }
        return value.toFixed(unitIndex === 0 ? 0 : 1) + ' ' + units[unitIndex];
    }

    function initUploadZones(root) {
        root.querySelectorAll('.dropzone, [data-upload-zone], .lh-upload-zone').forEach(function (zone) {
            if (zone.dataset.bound === 'true') {
                return;
            }
            zone.dataset.bound = 'true';

            var input = zone.querySelector('input[type="file"]');
            if (!input) {
                return;
            }

            var contentNode = zone.querySelector('.dropzone_content') || zone.querySelector('.lh-upload-zone__content');
            if (!contentNode) {
                contentNode = document.createElement('div');
                contentNode.className = 'dropzone_content lh-upload-zone__content';
                Array.from(zone.childNodes).forEach(function (child) {
                    if (child !== input) {
                        contentNode.appendChild(child);
                    }
                });
                zone.appendChild(contentNode);
            }

            // Clicking the zone triggers file input selection
            zone.addEventListener('click', function (e) {
                if (e.target !== input && !input.contains(e.target)) {
                    input.click();
                }
            });

            function updateDropzoneDisplay(files) {
                if (files && files.length > 0) {
                    var file = files[0];
                    zone.classList.add('dropzone_staged');
                    contentNode.innerHTML = '<i class="fas fa-file-pdf dropzone_icon lh-upload-zone__icon" style="color: var(--success, #10b981);"></i><div class="dropzone_text lh-upload-zone__text" style="font-weight: 600; color: var(--text-primary, #0f172a);">' + file.name + '</div><div class="dropzone_subtext lh-upload-zone__subtext">' + formatBytes(file.size) + ' - Click or drag to replace</div>';
                } else {
                    zone.classList.remove('dropzone_staged');
                    contentNode.innerHTML = '<i class="fas fa-cloud-arrow-up dropzone_icon lh-upload-zone__icon"></i><div class="dropzone_text lh-upload-zone__text">Click to browse or drag your PDF answer file here</div><div class="dropzone_subtext lh-upload-zone__subtext">Supports PDF up to 50MB</div>';
                }
            }

            function syncFiles(fileList) {
                if (typeof DataTransfer === 'function') {
                    var transfer = new DataTransfer();
                    Array.prototype.forEach.call(fileList, function (file) {
                        transfer.items.add(file);
                    });
                    input.files = transfer.files;
                }
                updateDropzoneDisplay(fileList);
            }

            ['dragenter', 'dragover'].forEach(function (eventName) {
                zone.addEventListener(eventName, function (event) {
                    event.preventDefault();
                    zone.classList.add('is-dragging');
                });
            });

            ['dragleave', 'drop'].forEach(function (eventName) {
                zone.addEventListener(eventName, function (event) {
                    event.preventDefault();
                    zone.classList.remove('is-dragging');
                });
            });

            zone.addEventListener('drop', function (event) {
                if (event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files.length) {
                    syncFiles(event.dataTransfer.files);
                }
            });

            input.addEventListener('change', function () {
                updateDropzoneDisplay(input.files);
            });
        });
    }

    function initChoiceBlocks(root) {
        root.querySelectorAll('.choice_block, .focus_choice_block').forEach(function (block) {
            if (block.dataset.bound === 'true') {
                return;
            }
            block.dataset.bound = 'true';

            var input = block.querySelector('input[type="radio"]');
            if (!input) return;

            input.addEventListener('change', function () {
                var name = input.name;
                var form = block.closest('form') || root;
                form.querySelectorAll('input[name="' + name + '"]').forEach(function (peer) {
                    var peerBlock = peer.closest('.choice_block, .focus_choice_block');
                    if (peerBlock) {
                        peerBlock.classList.toggle('choice_block_selected', peer.checked);
                        peerBlock.classList.toggle('is-selected', peer.checked);
                    }
                });
            });
        });
    }

    function initForms(root) {
        root.querySelectorAll('[data-loading-submit], #assignmentHubForm').forEach(function (form) {
            if (form.dataset.bound === 'true') {
                return;
            }
            form.dataset.bound = 'true';

            form.addEventListener('submit', function (event) {
                var button = form.querySelector('[data-submit-button]') || form.querySelector('button[type="submit"]');
                if (!button || button.dataset.busy === 'true') {
                    return;
                }
                event.preventDefault();

                button.dataset.busy = 'true';
                button.disabled = true;
                var originalHTML = button.innerHTML;
                button.innerHTML = '<i class="fas fa-spinner fa-spin"></i><span>' + (button.getAttribute('data-loading-label') || 'Submitting...') + '</span>';

                var finalUrl = '';
                try {
                    var formData = new FormData(form);
                    fetch(form.action, {
                        method: 'POST',
                        body: formData,
                        headers: {
                            'X-Requested-With': 'fetch'
                        }
                    })
                    .then(function (response) {
                        if (!response.ok) throw new Error('Submission failed');
                        finalUrl = response.url;
                        return response.text();
                    })
                    .then(function (html) {
                        var parser = new DOMParser();
                        var doc = parser.parseFromString(html, 'text/html');
                        var newContent = doc.querySelector('.lh-content-stage') || doc.querySelector('.ax-shell') || doc.querySelector('.sa-shell');
                        var stage = document.querySelector('.lh-content-stage');
                        if (newContent && stage) {
                            stage.innerHTML = newContent.innerHTML;
                            stripDuplicateNav(stage);
                            init(stage);
                            syncHubProgress(doc);
                            if (window.history && window.history.pushState && finalUrl) {
                                window.history.pushState({ assessmentStage: 'result' }, '', finalUrl);
                            }
                        } else {
                            if (finalUrl) {
                                window.location.href = finalUrl;
                            } else {
                                window.location.reload();
                            }
                        }
                    })
                    .catch(function (err) {
                        button.dataset.busy = 'false';
                        button.disabled = false;
                        button.innerHTML = originalHTML;
                        notify('error', 'Submission failed: ' + err.message);
                    });
                } catch (syncErr) {
                    button.dataset.busy = 'false';
                    button.disabled = false;
                    button.innerHTML = originalHTML;
                    notify('error', 'Submission failed: ' + syncErr.message);
                }
            });
        });
    }

    function syncHubProgress(doc) {
        ['lhTopbarPct', 'lhTopbarFill', 'lhSidebarProgressPercent', 'lhSidebarProgressBar', 'edMaterialsViewedCount'].forEach(function (id) {
            var src = doc.getElementById(id);
            var dest = document.getElementById(id);
            if (src && dest) {
                if (id === 'lhTopbarFill' || id === 'lhSidebarProgressBar') {
                    dest.style.width = src.style.width;
                } else {
                    dest.textContent = src.textContent;
                }
            }
        });
        
        var destSidebar = document.getElementById('svSidebar');
        var srcSidebar = doc.getElementById('svSidebar');
        if (destSidebar && srcSidebar) {
            var destItems = destSidebar.querySelectorAll('.lh-chapter-item');
            var srcItems = srcSidebar.querySelectorAll('.lh-chapter-item');
            destItems.forEach(function (destItem, index) {
                var srcItem = srcItems[index];
                if (srcItem) {
                    destItem.className = srcItem.className;
                    var destIcon = destItem.querySelector('.hub_completionToggle i');
                    var srcIcon = srcItem.querySelector('.hub_completionToggle i');
                    if (destIcon && srcIcon) {
                        destIcon.className = srcIcon.className;
                    }
                    var destBtn = destItem.querySelector('.hub_completionToggle');
                    var srcBtn = srcItem.querySelector('.hub_completionToggle');
                    if (destBtn && srcBtn) {
                        destBtn.className = srcBtn.className;
                        destBtn.disabled = srcBtn.disabled;
                    }
                }
            });
        }
    }

    function initAttemptExperience(root) {
        root.querySelectorAll('[data-attempt-form]').forEach(function (form) {
            if (form.dataset.bound === 'true') {
                return;
            }
            form.dataset.bound = 'true';

            var attemptShell = form.closest('[data-attempt-shell]') || root;
            var questions = Array.prototype.slice.call(form.querySelectorAll('[data-question-index]'));
            var stepperButtons = Array.prototype.slice.call(attemptShell.querySelectorAll('[data-step-index]'));
            var currentIndexNode = attemptShell.querySelector('[data-current-question]') || document.getElementById('currentQText');
            var progressFill = attemptShell.querySelector('[data-progress-fill]') || document.getElementById('focusProgressFill');
            var submitButton = form.querySelector('[data-submit-button]');
            var previousButton = form.querySelector('[data-prev-question]');
            var nextButton = form.querySelector('[data-next-question]');
            var exitButton = form.querySelector('[data-exit-attempt]');
            var exitField = form.querySelector('[name="exitSubmission"]');
            var timerNode = document.querySelector('[data-timer]');
            var timerText = document.querySelector('[data-timer-text]');
            var timerStart = Number(form.getAttribute('data-timer-start') || '0');
            var timerDuration = Number(form.getAttribute('data-timer-duration') || '0');
            var activeIndex = 0;
            var isSubmitting = false;
            var timerHandle;

            function setBusyState(label) {
                if (!submitButton) {
                    return;
                }
                submitButton.disabled = true;
                submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i><span>' + label + '</span>';
            }

            function questionAnswered(question) {
                return !!question.querySelector('input[type="radio"]:checked');
            }

            function updateProgress() {
                if (!questions.length) {
                    return;
                }

                var completed = 0;
                questions.forEach(function (question, index) {
                    var answered = questionAnswered(question);
                    var chip = stepperButtons[index];
                    if (answered) {
                        completed += 1;
                        if (chip) {
                            chip.classList.add('stepper_item_completed');
                        }
                    } else if (chip) {
                        chip.classList.remove('stepper_item_completed');
                    }
                });

                if (progressFill) {
                    progressFill.style.width = Math.round((completed / questions.length) * 100) + '%';
                }
            }

            function showQuestion(index) {
                if (index < 0 || index >= questions.length) {
                    return;
                }
                activeIndex = index;
                questions.forEach(function (question, questionIndex) {
                    question.style.display = questionIndex === activeIndex ? 'block' : 'none';
                });
                stepperButtons.forEach(function (button, buttonIndex) {
                    button.classList.toggle('stepper_item_active', buttonIndex === activeIndex);
                });
                if (currentIndexNode) {
                    currentIndexNode.textContent = String(activeIndex + 1);
                }
                if (previousButton) {
                    previousButton.disabled = activeIndex === 0;
                    previousButton.style.display = activeIndex === 0 ? 'none' : 'inline-flex';
                }
                if (nextButton) {
                    var nextLabel = nextButton.querySelector('.focus_next_label') || nextButton.querySelector('span');
                    if (activeIndex === questions.length - 1) {
                        if (nextButton.classList.contains('focus_btn_next')) {
                            if (nextLabel) nextLabel.textContent = 'Submit Assessment';
                            nextButton.querySelector('i').className = 'fas fa-paper-plane';
                        } else {
                            nextButton.style.display = 'none';
                        }
                    } else {
                        if (nextButton.classList.contains('focus_btn_next')) {
                            if (nextLabel) nextLabel.textContent = 'Next Question';
                            nextButton.querySelector('i').className = 'fas fa-arrow-right';
                        } else {
                            nextButton.style.display = 'inline-flex';
                        }
                    }
                }
            }

            function unansweredIndexes() {
                var list = [];
                questions.forEach(function (question, index) {
                    if (!questionAnswered(question)) {
                        list.push(index + 1);
                    }
                });
                return list;
            }

            function submitWithAJAX() {
                isSubmitting = true;
                setBusyState('Grading submission...');
                
                var finalUrl = '';
                var formData = new FormData(form);
                fetch(form.action, {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'X-Requested-With': 'fetch'
                    }
                })
                .then(function (response) {
                    if (!response.ok) throw new Error('Submission failed');
                    finalUrl = response.url;
                    return response.text();
                })
                .then(function (html) {
                    if (timerHandle) window.clearInterval(timerHandle);
                    
                    var parser = new DOMParser();
                    var doc = parser.parseFromString(html, 'text/html');
                    var newContent = doc.querySelector('.lh-content-stage') || doc.querySelector('.ax-shell') || doc.querySelector('.sa-shell');
                    var stage = document.querySelector('.lh-content-stage');
                    if (newContent && stage) {
                        stage.innerHTML = newContent.innerHTML;
                        stripDuplicateNav(stage);
                        init(stage);
                        syncHubProgress(doc);
                        if (window.history && window.history.pushState && finalUrl) {
                            window.history.pushState({ assessmentStage: 'result' }, '', finalUrl);
                        }
                    } else {
                        if (finalUrl) {
                            window.location.href = finalUrl;
                        } else {
                            window.location.reload();
                        }
                    }
                })
                .catch(function (err) {
                    isSubmitting = false;
                    notify('error', 'Submission failed: ' + err.message);
                    if (submitButton) {
                        submitButton.disabled = false;
                        submitButton.innerHTML = '<i class="fas fa-paper-plane"></i><span>Submit Assessment</span>';
                    }
                });
            }

            function updateTimer() {
                if (!timerNode || !timerText || !timerStart || !timerDuration) {
                    return;
                }

                var remainingMillis = (timerDuration * 1000) - (Date.now() - timerStart);
                if (remainingMillis <= 0) {
                    window.clearInterval(timerHandle);
                    timerText.textContent = '00:00';
                    timerNode.classList.remove('is_warning');
                    timerNode.classList.add('is_critical');
                    setTimeout(function () {
                        submitWithAJAX();
                    }, 700);
                    return;
                }

                var totalSeconds = Math.floor(remainingMillis / 1000);
                var minutes = Math.floor(totalSeconds / 60);
                var seconds = totalSeconds % 60;
                timerText.textContent = String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
                
                // Add warnings
                if (remainingMillis <= 120000 && remainingMillis > 30000) {
                    timerNode.classList.add('is_warning');
                    timerNode.classList.remove('is_critical');
                } else if (remainingMillis <= 30000) {
                    timerNode.classList.add('is_critical');
                    timerNode.classList.remove('is_warning');
                } else {
                    timerNode.classList.remove('is_warning', 'is_critical');
                }
            }

            stepperButtons.forEach(function (button) {
                button.addEventListener('click', function () {
                    showQuestion(Number(button.getAttribute('data-step-index')));
                });
            });

            if (previousButton) {
                previousButton.addEventListener('click', function () {
                    showQuestion(activeIndex - 1);
                });
            }

            if (nextButton) {
                nextButton.addEventListener('click', function () {
                    if (activeIndex === questions.length - 1) {
                        form.dispatchEvent(new Event('submit', { cancelable: true, bubbles: true }));
                    } else {
                        showQuestion(activeIndex + 1);
                    }
                });
            }

            if (exitButton && exitField) {
                exitButton.addEventListener('click', function () {
                    confirmAction(
                        'Save & Exit',
                        'Exit now? Your current attempt will be submitted immediately.',
                        function () {
                            exitField.value = '1';
                            submitWithAJAX();
                        }
                    );
                });
            }

            form.addEventListener('submit', function (event) {
                if (isSubmitting) {
                    return;
                }
                event.preventDefault();
                var unanswered = unansweredIndexes();
                var message = unanswered.length
                    ? 'You still have unanswered questions (' + unanswered.join(', ') + '). Submit anyway?'
                    : 'Submit this assessment now?';

                confirmAction('Submit Assessment', message, function () {
                    submitWithAJAX();
                });
            });

            // Synchronize selection changes to class highlights on choices
            form.querySelectorAll('input[type="radio"]').forEach(function (input) {
                input.addEventListener('change', function () {
                    updateProgress();
                });
                // Initial check for legacy choice blocks and new focus choice blocks
                var block = input.closest('.choice_block, .focus_choice_block');
                if (block) {
                    block.classList.toggle('choice_block_selected', input.checked);
                    block.classList.toggle('is-selected', input.checked);
                }
            });

            showQuestion(0);
            updateProgress();
            updateTimer();
            if (timerStart && timerDuration) {
                timerHandle = window.setInterval(updateTimer, 250);
            }
        });
    }

    function initResultActions(root) {
        root.querySelectorAll('[data-complete-and-continue]').forEach(function (button) {
            if (button.dataset.bound === 'true') {
                return;
            }
            button.dataset.bound = 'true';
            button.addEventListener('click', function (event) {
                event.preventDefault();
                if (window.LearningHub && typeof window.LearningHub.navigateToNext === 'function') {
                    window.LearningHub.navigateToNext();
                } else {
                    var nextBtn = document.querySelector('.sv-btn--primary[href*="learning"]');
                    if (nextBtn) {
                        window.location.href = nextBtn.href;
                    } else {
                        window.location.reload();
                    }
                }
            });
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        init(document);
    });

    window.StudentAssessmentFlow = {
        init: init,
        syncHubProgress: syncHubProgress
    };
})();
