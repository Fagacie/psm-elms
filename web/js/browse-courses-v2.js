(function () {
    var scene = document.getElementById('bcHeroScene');
    var filterButtons = document.querySelectorAll('.bc-filter');
    var searchInput = document.getElementById('bcQuickSearch');
    var cards = document.querySelectorAll('.bc-card[data-level]');
    var noRows = document.getElementById('bcNoRows');
    var counters = document.querySelectorAll('.bc-count[data-counter]');
    var tiltEls = document.querySelectorAll('.bc-tilt');
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function animateCounters() {
        counters.forEach(function (counter) {
            if (counter.dataset.counted === '1') return;
            var target = parseInt(counter.getAttribute('data-counter'), 10);
            if (isNaN(target)) return;
            counter.dataset.counted = '1';

            var startTs = 0;
            var duration = reduceMotion ? 0 : 900;

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

    function applyFilters() {
        if (!cards.length) return;

        var activeButton = document.querySelector('.bc-filter.active');
        var mode = activeButton ? activeButton.getAttribute('data-filter') : 'all';
        var q = searchInput ? searchInput.value.trim().toLowerCase() : '';
        var visibleCount = 0;

        cards.forEach(function (card) {
            var level = card.getAttribute('data-level') || '';
            var enrolled = card.getAttribute('data-enrolled') || 'no';
            var courseName = (card.getAttribute('data-course') || '').toLowerCase();
            var category = (card.getAttribute('data-category') || '').toLowerCase();

            var modeMatch = mode === 'all'
                ? true
                : (mode === 'enrolled' ? enrolled === 'yes' : level === mode);
            var searchMatch = q ? (courseName.indexOf(q) !== -1 || category.indexOf(q) !== -1) : true;
            var show = modeMatch && searchMatch;

            card.style.display = show ? '' : 'none';
            if (show) visibleCount += 1;
        });

        if (noRows) {
            noRows.style.display = visibleCount === 0 ? 'block' : 'none';
        }
    }

    if (scene && !reduceMotion) {
        var objs = scene.querySelectorAll('[data-depth]');

        function onMove(event) {
            var rect = scene.getBoundingClientRect();
            var x = ((event.clientX - rect.left) / rect.width) - 0.5;
            var y = ((event.clientY - rect.top) / rect.height) - 0.5;

            objs.forEach(function (obj) {
                var depth = parseFloat(obj.getAttribute('data-depth')) || 12;
                obj.style.transform = 'translate3d(' + (x * depth).toFixed(2) + 'px,' + (y * depth).toFixed(2) + 'px,0)';
            });
        }

        function onLeave() {
            objs.forEach(function (obj) {
                obj.style.transform = 'translate3d(0,0,0)';
            });
        }

        scene.addEventListener('mousemove', onMove);
        scene.addEventListener('mouseleave', onLeave);
    }

    if (!reduceMotion) {
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

    animateCounters();
    applyFilters();
})();
