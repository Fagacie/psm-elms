(function () {
    var heroScene = document.getElementById('meHeroScene');
    var filterButtons = document.querySelectorAll('.me-filter');
    var searchInput = document.getElementById('meCourseSearch');
    var cards = document.querySelectorAll('.me-card');
    var noRows = document.getElementById('meNoRows');
    var counters = document.querySelectorAll('.me-count[data-counter]');
    var progressBars = document.querySelectorAll('.me-card .sv-progress-bar[data-progress]');
    var tiltEls = document.querySelectorAll('.me-tilt');
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

    animateCounters();
    animateProgress();
    applyFilters();
})();
