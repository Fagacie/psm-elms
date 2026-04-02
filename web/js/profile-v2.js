(function () {
    var scene = document.getElementById('profileHeroScene');
    var counters = document.querySelectorAll('.profile-v2-count[data-counter]');
    var tiltEls = document.querySelectorAll('.profile-v2-tilt');
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
                if (p < 1) window.requestAnimationFrame(tick);
            }

            window.requestAnimationFrame(tick);
        });
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

    animateCounters();
})();
