(function () {
    var scene = document.querySelector('.cert-hero-scene');
    var filters = document.querySelectorAll('.cert-filter');
    var searchInput = document.getElementById('certQuickSearch');
    var rows = document.querySelectorAll('.cert-row');
    var noRows = document.getElementById('certNoRows');
    var counters = document.querySelectorAll('.cert-count[data-counter]');
    var tiltEls = document.querySelectorAll('.cert-card, .cert-metric, .cert-actions .sv-btn');
    var copyButtons = document.querySelectorAll('[data-cert-copy]');
    var copyToast = document.getElementById('certCopyToast');
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function showCopyToast(message) {
        if (!copyToast) return;
        copyToast.textContent = message;
        copyToast.classList.add('is-visible');
        window.clearTimeout(showCopyToast._timer);
        showCopyToast._timer = window.setTimeout(function () {
            copyToast.classList.remove('is-visible');
        }, 1800);
    }

    function flashCopyState(button, text) {
        var original = button.innerHTML;
        button.innerHTML = '<i class="fas fa-check"></i><span>' + text + '</span>';
        window.setTimeout(function () {
            button.innerHTML = original;
        }, 1200);
    }

    function copyCertificateCode(code, button) {
        if (!code) return;

        function onSuccess() {
            if (button) flashCopyState(button, 'Code Copied');
            showCopyToast('Certificate code copied: ' + code);
        }

        function onFailure() {
            if (button) flashCopyState(button, 'Copy Failed');
            showCopyToast('Copy failed. Please copy manually: ' + code);
        }

        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(code).then(onSuccess).catch(onFailure);
            return;
        }

        var temp = document.createElement('input');
        temp.type = 'text';
        temp.value = code;
        document.body.appendChild(temp);
        temp.select();
        try {
            document.execCommand('copy');
            onSuccess();
        } catch (e) {
            onFailure();
        }
        document.body.removeChild(temp);
    }

    function wireCopyButtons() {
        if (!copyButtons.length) return;
        copyButtons.forEach(function (btn) {
            btn.addEventListener('click', function () {
                copyCertificateCode(btn.getAttribute('data-cert-copy'), btn);
            });
        });
    }

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
                if (p < 1) window.requestAnimationFrame(tick);
            }

            window.requestAnimationFrame(tick);
        });
    }

    function applyFilters() {
        if (!rows.length) return;

        var activeButton = document.querySelector('.cert-filter.active');
        var mode = activeButton ? activeButton.getAttribute('data-filter') : 'all';
        var q = searchInput ? searchInput.value.trim().toLowerCase() : '';
        var visibleCount = 0;

        rows.forEach(function (row) {
            var status = row.getAttribute('data-status') || '';
            var course = (row.getAttribute('data-course') || '').toLowerCase();
            var cert = (row.getAttribute('data-cert') || '').toLowerCase();
            var modeMatch = mode === 'all' ? true : status === mode;
            var searchMatch = q ? (course.indexOf(q) !== -1 || cert.indexOf(q) !== -1) : true;
            var show = modeMatch && searchMatch;

            row.style.display = show ? '' : 'none';
            if (show) visibleCount += 1;
        });

        if (noRows) {
            noRows.style.display = visibleCount === 0 ? 'grid' : 'none';
        }
    }

    if (scene && !reduceMotion) {
        var layers = scene.querySelectorAll('[data-depth]');
        scene.addEventListener('mousemove', function (event) {
            var rect = scene.getBoundingClientRect();
            var x = ((event.clientX - rect.left) / rect.width) - 0.5;
            var y = ((event.clientY - rect.top) / rect.height) - 0.5;

            layers.forEach(function (layer) {
                var depth = parseFloat(layer.getAttribute('data-depth')) || 12;
                var tx = x * depth;
                var ty = y * depth;
                layer.style.transform = 'translate3d(' + tx.toFixed(2) + 'px,' + ty.toFixed(2) + 'px,0)';
            });
        });

        scene.addEventListener('mouseleave', function () {
            layers.forEach(function (layer) {
                layer.style.transform = 'translate3d(0,0,0)';
            });
        });
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

    filters.forEach(function (btn) {
        btn.addEventListener('click', function () {
            filters.forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
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

    wireCopyButtons();
    animateCounters();
    applyFilters();
})();
