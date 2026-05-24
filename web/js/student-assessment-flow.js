(function () {
    function init(root) {
        initStartTransitions(root);
        initStageToggles(root);
        initUploadZones(root);
        initForms(root);
        initAttemptExperience(root);
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
                var host = button.closest('[data-assessment-stage-host]');
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
                    host.innerHTML = html;
                    host.classList.remove('is-loading');
                    if (window.history && window.history.pushState) {
                        window.history.pushState({ assessmentStage: 'active' }, '', url);
                    }
                    init(host);
                    var focusTitle = host.querySelector('.ax-focus__title');
                    if (focusTitle) {
                        focusTitle.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                })
                .catch(function () {
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
                    return;
                }

                if (current) {
                    current.hidden = true;
                    current.removeAttribute('data-stage-current');
                }
                target.hidden = false;
                target.setAttribute('data-stage-current', 'true');
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        });
    }

    function initUploadZones(root) {
        root.querySelectorAll('[data-upload-zone]').forEach(function (zone) {
            if (zone.dataset.bound === 'true') {
                return;
            }
            zone.dataset.bound = 'true';

            var input = zone.querySelector('input[type="file"]');
            var list = zone.closest('form') ? zone.closest('form').querySelector('[data-file-list]') : null;
            if (!input || !list) {
                return;
            }

            function updateList(files) {
                list.innerHTML = '';
                if (!files || !files.length) {
                    return;
                }

                Array.prototype.forEach.call(files, function (file) {
                    var item = document.createElement('div');
                    item.className = 'ax-file-item';
                    item.innerHTML =
                        '<div class="ax-file-item__meta">' +
                            '<i class="fas fa-file-lines"></i>' +
                            '<div>' +
                                '<div class="ax-file-item__name"></div>' +
                                '<div class="ax-file-item__size"></div>' +
                            '</div>' +
                        '</div>' +
                        '<button type="button" class="ax-file-remove" aria-label="Remove attachment"><i class="fas fa-xmark"></i></button>';

                    item.querySelector('.ax-file-item__name').textContent = file.name;
                    item.querySelector('.ax-file-item__size').textContent = formatBytes(file.size);
                    item.querySelector('.ax-file-remove').addEventListener('click', function () {
                        input.value = '';
                        updateList([]);
                    });
                    list.appendChild(item);
                });
            }

            function syncFiles(fileList) {
                if (typeof DataTransfer === 'function') {
                    var transfer = new DataTransfer();
                    Array.prototype.forEach.call(fileList, function (file) {
                        transfer.items.add(file);
                    });
                    input.files = transfer.files;
                }
                updateList(fileList);
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
                updateList(input.files);
            });
        });
    }

    function initForms(root) {
        root.querySelectorAll('[data-loading-submit]').forEach(function (form) {
            if (form.dataset.bound === 'true') {
                return;
            }
            form.dataset.bound = 'true';

            form.addEventListener('submit', function () {
                var button = form.querySelector('[data-submit-button]');
                if (!button || button.dataset.busy === 'true') {
                    return;
                }

                button.dataset.busy = 'true';
                button.classList.add('is-busy');
                button.disabled = true;
                button.innerHTML = '<i class="fas fa-spinner"></i><span>' + (button.getAttribute('data-loading-label') || 'Submitting...') + '</span>';
            });
        });
    }

    function initAttemptExperience(root) {
        root.querySelectorAll('[data-attempt-form]').forEach(function (form) {
            if (form.dataset.bound === 'true') {
                return;
            }
            form.dataset.bound = 'true';

            var attemptShell = form.closest('[data-attempt-shell]') || root;
            var questions = Array.prototype.slice.call(form.querySelectorAll('[data-question-index]'));
            var stepperButtons = Array.prototype.slice.call(form.querySelectorAll('[data-step-index]'));
            var currentIndexNode = form.querySelector('[data-current-question]');
            var progressFill = form.querySelector('[data-progress-fill]');
            var submitButton = form.querySelector('[data-submit-button]');
            var previousButton = form.querySelector('[data-prev-question]');
            var nextButton = form.querySelector('[data-next-question]');
            var exitButton = form.querySelector('[data-exit-attempt]');
            var exitField = form.querySelector('[name="exitSubmission"]');
            var timerNode = attemptShell.querySelector('[data-timer]');
            var timerText = attemptShell.querySelector('[data-timer-text]');
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
                submitButton.classList.add('is-busy');
                submitButton.innerHTML = '<i class="fas fa-spinner"></i><span>' + label + '</span>';
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
                            chip.classList.add('is-complete');
                        }
                    } else if (chip) {
                        chip.classList.remove('is-complete');
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
                    question.classList.toggle('is-active', questionIndex === activeIndex);
                });
                stepperButtons.forEach(function (button, buttonIndex) {
                    button.classList.toggle('is-active', buttonIndex === activeIndex);
                });
                if (currentIndexNode) {
                    currentIndexNode.textContent = String(activeIndex + 1);
                }
                if (previousButton) {
                    previousButton.disabled = activeIndex === 0;
                }
                if (nextButton) {
                    nextButton.innerHTML = activeIndex === questions.length - 1
                        ? '<i class="fas fa-flag-checkered"></i><span>Review & Submit</span>'
                        : '<span>Next</span><i class="fas fa-arrow-right"></i>';
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

            function submitWithLoading(label) {
                isSubmitting = true;
                setBusyState(label);
                form.submit();
            }

            function updateTimer() {
                if (!timerNode || !timerText || !timerStart || !timerDuration) {
                    return;
                }

                var remainingMillis = (timerDuration * 1000) - (Date.now() - timerStart);
                if (remainingMillis <= 0) {
                    window.clearInterval(timerHandle);
                    timerText.textContent = '00:00';
                    timerNode.classList.remove('is-warning');
                    timerNode.classList.add('is-critical');
                    setTimeout(function () {
                        submitWithLoading('Grading your submission...');
                    }, 700);
                    return;
                }

                var totalSeconds = Math.floor(remainingMillis / 1000);
                var minutes = Math.floor(totalSeconds / 60);
                var seconds = totalSeconds % 60;
                timerText.textContent = String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
                timerNode.classList.toggle('is-warning', remainingMillis <= 120000 && remainingMillis > 30000);
                timerNode.classList.toggle('is-critical', remainingMillis <= 30000);
            }

            stepperButtons.forEach(function (button) {
                button.addEventListener('click', function () {
                    showQuestion(Number(button.getAttribute('data-step-index')));
                });
            });

            form.querySelectorAll('.ax-answer-card input[type="radio"]').forEach(function (input) {
                function syncSelection() {
                    var name = input.name;
                    form.querySelectorAll('input[name="' + name + '"]').forEach(function (peer) {
                        var card = peer.closest('.ax-answer-card');
                        if (card) {
                            card.classList.toggle('is-selected', peer.checked);
                        }
                    });
                    updateProgress();
                }
                syncSelection();
                input.addEventListener('change', syncSelection);
            });

            if (previousButton) {
                previousButton.addEventListener('click', function () {
                    showQuestion(activeIndex - 1);
                });
            }

            if (nextButton) {
                nextButton.addEventListener('click', function () {
                    if (activeIndex < questions.length - 1) {
                        showQuestion(activeIndex + 1);
                        return;
                    }

                    var unanswered = unansweredIndexes();
                    if (unanswered.length) {
                        notify('warning', 'You still have unanswered questions: ' + unanswered.join(', '));
                    } else {
                        notify('success', 'All questions answered. You can submit when ready.');
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
                            submitWithLoading('Saving your attempt...');
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
                    submitWithLoading('Grading your submission...');
                });
            });

            window.addEventListener('beforeunload', function (event) {
                if (isSubmitting) {
                    return;
                }
                event.preventDefault();
                event.returnValue = 'Assessment in progress. Leaving may end your attempt.';
            });

            showQuestion(0);
            updateProgress();
            updateTimer();
            if (timerStart && timerDuration) {
                timerHandle = window.setInterval(updateTimer, 250);
            }
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

    document.addEventListener('DOMContentLoaded', function () {
        init(document);
    });

    window.StudentAssessmentFlow = {
        init: init
    };
})();
