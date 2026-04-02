(function () {
    var menuBtn = document.getElementById('sdMenuBtn');
    var sidebar = document.getElementById('sdSidebar');
    var overlay = document.getElementById('sdOverlay');
    var revealEls = document.querySelectorAll('.reveal');
    var heroScene = document.getElementById('sdHeroScene');
    var filterButtons = document.querySelectorAll('.sd-filter');
    var searchInput = document.getElementById('sdCourseSearch');
    var rows = document.querySelectorAll('.sd-row');
    var noRows = document.getElementById('sdNoRows');
    var counters = document.querySelectorAll('.sd-count[data-counter]');
    var progressBars = document.querySelectorAll('.sd-progress-bar[data-progress]');
    var tiltEls = document.querySelectorAll('.sd-tilt');
    var prefersReducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function closeSidebar() {
        if (!sidebar || !overlay) return;
        sidebar.classList.remove('open');
        overlay.classList.remove('show');
    }

    if (menuBtn && sidebar && overlay) {
        menuBtn.addEventListener('click', function () {
            sidebar.classList.toggle('open');
            overlay.classList.toggle('show');
        });

        overlay.addEventListener('click', closeSidebar);

        window.addEventListener('resize', function () {
            if (window.innerWidth > 1024) {
                closeSidebar();
            }
        });
    }

    if ('IntersectionObserver' in window) {
        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                entry.target.classList.add('is-visible');

                if (entry.target.classList.contains('sd-metric') || entry.target.classList.contains('sd-grid')) {
                    animateCounters();
                    animateProgress();
                }

                observer.unobserve(entry.target);
            });
        }, { threshold: 0.08 });

        revealEls.forEach(function (el) {
            observer.observe(el);
        });
    } else {
        revealEls.forEach(function (el) {
            el.classList.add('is-visible');
        });
        animateCounters();
        animateProgress();
    }

    function animateCounters() {
        counters.forEach(function (counter) {
            if (counter.dataset.counted === '1') return;
            var target = parseInt(counter.getAttribute('data-counter'), 10);
            if (isNaN(target)) return;
            var suffix = counter.getAttribute('data-suffix') || '';
            counter.dataset.counted = '1';

            var startTs = 0;
            var duration = prefersReducedMotion ? 0 : 900;

            function tick(ts) {
                if (!startTs) startTs = ts;
                var p = duration === 0 ? 1 : Math.min((ts - startTs) / duration, 1);
                var eased = 1 - Math.pow(1 - p, 3);
                var value = Math.floor(target * eased);
                counter.textContent = String(value) + suffix;
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

                el.classList.add('is-tilting');
                el.style.transform = 'perspective(900px) rotateX(' + rx.toFixed(2) + 'deg) rotateY(' + ry.toFixed(2) + 'deg) translateY(-2px)';
                el.style.setProperty('--mx', ((x / rect.width) * 100).toFixed(2) + '%');
                el.style.setProperty('--my', ((y / rect.height) * 100).toFixed(2) + '%');
            });

            el.addEventListener('mouseleave', function () {
                el.style.transform = '';
                el.classList.remove('is-tilting');
            });
        });
    }

    function applyRowFilters() {
        if (!rows.length) return;

        var activeButton = document.querySelector('.sd-filter.active');
        var status = activeButton ? activeButton.getAttribute('data-filter') : 'all';
        var q = searchInput ? searchInput.value.trim().toLowerCase() : '';
        var visibleCount = 0;

        rows.forEach(function (row) {
            var rowStatus = row.getAttribute('data-status') || '';
            var courseName = (row.getAttribute('data-course') || '').toLowerCase();
            var statusMatch = status === 'all' ? true : rowStatus === status;
            var searchMatch = q ? courseName.indexOf(q) !== -1 : true;
            var show = statusMatch && searchMatch;

            row.style.display = show ? '' : 'none';
            if (show) visibleCount += 1;
        });

        if (noRows) {
            noRows.style.display = visibleCount === 0 ? 'grid' : 'none';
        }
    }

    filterButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            filterButtons.forEach(function (b) {
                b.classList.remove('active');
            });
            button.classList.add('active');
            applyRowFilters();
        });
    });

    if (searchInput) {
        searchInput.addEventListener('input', applyRowFilters);

        document.addEventListener('keydown', function (event) {
            if (event.key === '/' && document.activeElement !== searchInput) {
                event.preventDefault();
                searchInput.focus();
            }

            if (event.key === 'Escape' && document.activeElement === searchInput) {
                searchInput.value = '';
                applyRowFilters();
                searchInput.blur();
            }
        });
    }

    applyRowFilters();
})();
