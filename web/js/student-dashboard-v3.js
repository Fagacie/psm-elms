(function () {
    var counters = document.querySelectorAll('.sd3-count[data-counter]');
    var progressBars = document.querySelectorAll('.sv-progress-bar[data-progress]');
    var prefersReducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

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

            // Dynamic color based on progress
            var color = '#dc2626';
            if (target >= 35 && target < 75) {
                color = '#f59e0b';
            } else if (target >= 75) {
                color = '#10b981';
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

    function updateGreeting() {
        var greetingEl = document.getElementById('sd3DynamicGreeting');
        if (!greetingEl) return;
        var rawText = greetingEl.textContent || '';
        var userName = rawText.replace('Welcome back, ', '').trim();
        var hour = new Date().getHours();
        var greeting = 'Welcome back';
        if (hour < 12) {
            greeting = 'Good morning';
        } else if (hour < 18) {
            greeting = 'Good afternoon';
        } else {
            greeting = 'Good evening';
        }
        greetingEl.innerHTML = greeting + ', <span class="sd3-welcome-banner__username">' + userName + '</span>';
    }

    animateCounters();
    animateProgress();
    updateGreeting();
})();

