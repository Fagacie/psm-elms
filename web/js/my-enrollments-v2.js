(function () {
    var heroScene = document.getElementById('meHeroScene');
    var filterButtons = document.querySelectorAll('.me-filter');
    var searchInput = document.getElementById('meCourseSearch');
    var cards = document.querySelectorAll('.bc-card');
    var noRows = document.getElementById('meNoRows');
    var counters = document.querySelectorAll('.me-count[data-counter]');
    var progressBars = document.querySelectorAll('.bc-card .sv-progress-bar[data-progress]');
    var tiltEls = document.querySelectorAll('.bc-tilt');
    var prefersReducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function animateCounters() {
        counters.forEach(function (counter) {
            if (counter.dataset.counted === '1') return;
            var target = parseInt(counter.getAttribute('data-counter'), 10);
            if (isNaN(target)) return;
            counter.dataset.counted = '1';

            var startTs = 0;
            var duration = prefersReducedMotion ? 0 : 900;

            function tick(ts) {
                if (!startTs) startTs = ts;
                var p = duration === 0 ? 1 : Math.min((ts - startTs) / duration, 1);
                var eased = 1 - Math.pow(1 - p, 3);
                counter.textContent = String(Math.floor(target * eased));
                if (p < 1) {
                    window.requestAnimationFrame(tick);
                }
            }

            window.requestAnimationFrame(tick);
        });
    }

    function animateProgress() {
        progressBars.forEach(function (bar) {
            if (bar.dataset.animated === '1') return;
            var target = parseFloat(bar.getAttribute('data-progress'));
            if (isNaN(target)) return;
            bar.dataset.animated = '1';
            
            // Set dynamic color based on progress percentage
            var color = '#dc2626'; // Red for < 35%
            if (target >= 35 && target < 75) {
                color = '#f59e0b'; // Yellow/Amber for 35% - 75%
            } else if (target >= 75) {
                color = '#10b981'; // Emerald Green for >= 75%
            }
            bar.style.backgroundColor = color;

            if (prefersReducedMotion) {
                bar.style.width = target + '%';
                return;
            }
            bar.style.width = '0%';
            window.requestAnimationFrame(function () {
                bar.style.width = Math.max(0, Math.min(100, target)) + '%';
            });
        });
    }

    function applyFilters() {
        if (!cards.length) return;

        var activeButton = document.querySelector('.me-filter.active');
        var status = activeButton ? activeButton.getAttribute('data-filter') : 'all';
        var q = searchInput ? searchInput.value.trim().toLowerCase() : '';
        var visibleCount = 0;

        cards.forEach(function (card) {
            var cardStatus = card.getAttribute('data-status') || '';
            var courseName = (card.getAttribute('data-course') || '').toLowerCase();
            var instructorName = (card.getAttribute('data-instructor') || '').toLowerCase();
            var statusMatch = status === 'all' ? true : cardStatus === status;
            var searchMatch = q ? (courseName.indexOf(q) !== -1 || instructorName.indexOf(q) !== -1) : true;
            var show = statusMatch && searchMatch;
            card.style.display = show ? '' : 'none';
            if (show) visibleCount += 1;
        });

        if (noRows) {
            noRows.style.display = visibleCount === 0 ? 'grid' : 'none';
        }
    }

    if (heroScene && !prefersReducedMotion) {
        var layers = heroScene.querySelectorAll('[data-depth]');

        heroScene.addEventListener('mousemove', function (event) {
            var rect = heroScene.getBoundingClientRect();
            var x = ((event.clientX - rect.left) / rect.width) - 0.5;
            var y = ((event.clientY - rect.top) / rect.height) - 0.5;

            layers.forEach(function (layer) {
                var depth = parseFloat(layer.getAttribute('data-depth')) || 12;
                var tx = x * depth;
                var ty = y * depth;
                layer.style.transform = 'translate3d(' + tx.toFixed(2) + 'px,' + ty.toFixed(2) + 'px,0)';
            });
        });

        heroScene.addEventListener('mouseleave', function () {
            layers.forEach(function (layer) {
                layer.style.transform = 'translate3d(0,0,0)';
            });
        });
    }

    if (!prefersReducedMotion) {
        tiltEls.forEach(function (el) {
            el.addEventListener('mousemove', function (event) {
                var rect = el.getBoundingClientRect();
                var x = event.clientX - rect.left;
                var y = event.clientY - rect.top;
                var cx = rect.width / 2;
                var cy = rect.height / 2;
                var rx = -((y - cy) / cy) * 4;
                var ry = ((x - cx) / cx) * 4;
                el.style.transform = 'perspective(900px) rotateX(' + rx.toFixed(2) + 'deg) rotateY(' + ry.toFixed(2) + 'deg) translateY(-2px)';
            });

            el.addEventListener('mouseleave', function () {
                el.style.transform = '';
            });
        });
    }

    filterButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            filterButtons.forEach(function (b) { b.classList.remove('active'); });
            button.classList.add('active');
            applyFilters();
        });
    });

    if (searchInput) {
        searchInput.addEventListener('input', applyFilters);

        document.addEventListener('keydown', function (event) {
            if (event.key === '/' && document.activeElement !== searchInput) {
                event.preventDefault();
                searchInput.focus();
            }

            if (event.key === 'Escape' && document.activeElement === searchInput) {
                searchInput.value = '';
                applyFilters();
                searchInput.blur();
            }
        });
    }

    document.querySelectorAll('button.me-continue-link[data-href]').forEach(function (button) {
        button.addEventListener('click', function () {
            var targetUrl = button.getAttribute('data-href');
            if (targetUrl) {
                window.location.href = targetUrl;
            }
        });
    });

    function initStreakTracker() {
        var streakDaysKey = 'meStudyStreakDays';
        var streakCountKey = 'meStudyStreakCount';
        var lastLoginDateKey = 'meStudyStreakLastDate';

        var today = new Date();
        var todayStr = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        var currentDayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, etc.

        // Load streak array
        var streakDays = [];
        try {
            streakDays = JSON.parse(localStorage.getItem(streakDaysKey)) || [];
        } catch (e) {
            streakDays = [];
        }

        // Check if yesterday was active to maintain count
        var lastLogin = localStorage.getItem(lastLoginDateKey);
        var streakCount = parseInt(localStorage.getItem(streakCountKey), 10) || 1;

        if (lastLogin) {
            var lastDateObj = new Date(lastLogin);
            // Reset hours for clean date math
            var d1 = new Date(today.getFullYear(), today.getMonth(), today.getDate());
            var d2 = new Date(lastDateObj.getFullYear(), lastDateObj.getMonth(), lastDateObj.getDate());
            var diffTime = d1 - d2;
            var diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));

            if (diffDays > 1) {
                // Streak broken
                streakCount = 1;
                streakDays = [];
            } else if (diffDays === 1) {
                // Streak continued
                streakCount += 1;
            }
        }

        // Record today
        localStorage.setItem(lastLoginDateKey, todayStr);
        localStorage.setItem(streakCountKey, streakCount);

        if (streakDays.indexOf(currentDayOfWeek) === -1) {
            streakDays.push(currentDayOfWeek);
            localStorage.setItem(streakDaysKey, JSON.stringify(streakDays));
        }

        // Update UI Flame count
        var flameCountEl = document.getElementById('meStreakCount');
        if (flameCountEl) {
            flameCountEl.textContent = streakCount + (streakCount === 1 ? ' Day' : ' Days');
        }

        // Update UI Day circles
        var dayCircles = document.querySelectorAll('.me-day-circle');
        dayCircles.forEach(function (circle) {
            var circleDay = parseInt(circle.getAttribute('data-day'), 10);
            if (circleDay === currentDayOfWeek) {
                circle.classList.add('active');
            }
            if (streakDays.indexOf(circleDay) !== -1) {
                circle.classList.add('checked');
            }
        });
    }

    animateCounters();
    animateProgress();
    applyFilters();
    initStreakTracker();
})();
