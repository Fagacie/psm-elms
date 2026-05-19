(function () {
    var menuBtn = document.getElementById('svMenuBtn');
    var sidebar = document.getElementById('svSidebar');
    var overlay = document.getElementById('svOverlay');
    var heroScene = document.getElementById('sd3HeroScene');
    var filterButtons = document.querySelectorAll('.sd3-filter');
    var searchInput = document.getElementById('sd3CourseSearch');
    var rows = document.querySelectorAll('.sd3-row');
    var noRows = document.getElementById('sd3NoRows');
    var counters = document.querySelectorAll('.sd3-count[data-counter]');
    var progressBars = document.querySelectorAll('.sd3-progress-bar[data-progress]');
    var tiltEls = document.querySelectorAll('.sd3-tilt');
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
            if (window.innerWidth > 1024) closeSidebar();
        });
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
                counter.textContent = Math.floor(target * eased) + suffix;
                if (p < 1) window.requestAnimationFrame(tick);
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

    if (heroScene && !prefersReducedMotion) {
        var layers = heroScene.querySelectorAll('[data-depth]');
        heroScene.addEventListener('mousemove', function (event) {
            var rect = heroScene.getBoundingClientRect();
            var x = ((event.clientX - rect.left) / rect.width) - 0.5;
            var y = ((event.clientY - rect.top) / rect.height) - 0.5;
            layers.forEach(function (layer) {
                var depth = parseFloat(layer.getAttribute('data-depth')) || 12;
                layer.style.transform = 'translate3d(' + (x * depth).toFixed(2) + 'px,' + (y * depth).toFixed(2) + 'px,0)';
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
            });
            el.addEventListener('mouseleave', function () {
                el.style.transform = '';
                el.classList.remove('is-tilting');
            });
        });
    }

    function applyRowFilters() {
        if (!rows.length) return;
        var activeButton = document.querySelector('.sd3-filter.active');
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

        if (noRows) noRows.style.display = visibleCount === 0 ? 'grid' : 'none';
    }

    filterButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            filterButtons.forEach(function (b) { b.classList.remove('active'); });
            button.classList.add('active');
            applyRowFilters();
        });
    });

    if (searchInput) {
        searchInput.addEventListener('input', applyRowFilters);
    }

    document.querySelectorAll('.sd3-continue-link').forEach(function (button) {
        button.addEventListener('click', function () {
            var targetUrl = button.getAttribute('data-href');
            if (targetUrl) {
                window.location.href = targetUrl;
            }
        });
    });

    animateCounters();
    animateProgress();
    applyRowFilters();
})();
