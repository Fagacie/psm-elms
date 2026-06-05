document.addEventListener('DOMContentLoaded', function () {
    var header = document.getElementById('siteHeader');
    var menuToggle = document.getElementById('menuToggle');
    var nav = document.getElementById('siteNav');
    var links = nav ? nav.querySelectorAll('a[href^="#"]') : [];
    var reveals = document.querySelectorAll('.reveal');
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function setHeaderState() {
        if (!header) return;
        header.classList.toggle('is-scrolled', window.scrollY > 12);
    }

    function closeMenu() {
        if (!nav || !menuToggle) return;
        nav.classList.remove('is-open');
        menuToggle.setAttribute('aria-expanded', 'false');
    }

    if (menuToggle && nav) {
        menuToggle.addEventListener('click', function () {
            var isOpen = nav.classList.toggle('is-open');
            menuToggle.setAttribute('aria-expanded', String(isOpen));
        });
    }

    links.forEach(function (link) {
        link.addEventListener('click', function (event) {
            var targetId = link.getAttribute('href').slice(1);
            var target = document.getElementById(targetId);
            if (!target) return;

            event.preventDefault();
            closeMenu();

            var offset = header ? header.offsetHeight + 14 : 0;
            var top = window.pageYOffset + target.getBoundingClientRect().top - offset;
            window.scrollTo({ top: top, behavior: reduceMotion ? 'auto' : 'smooth' });
        });
    });

    function updateActiveLink() {
        if (!links.length) return;
        var fromTop = window.scrollY + (header ? header.offsetHeight : 0) + 120;

        links.forEach(function (link) {
            var section = document.querySelector(link.getAttribute('href'));
            if (!section) return;

            var inView = fromTop >= section.offsetTop && fromTop < section.offsetTop + section.offsetHeight;
            link.classList.toggle('is-active', inView);
        });
    }

    if (reduceMotion) {
        reveals.forEach(function (el) {
            el.classList.add('is-visible');
        });
    } else if ('IntersectionObserver' in window) {
        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add('is-visible');
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

        reveals.forEach(function (el) {
            observer.observe(el);
        });
    } else {
        reveals.forEach(function (el) {
            el.classList.add('is-visible');
        });
    }

    document.addEventListener('click', function (event) {
        if (!nav || !menuToggle) return;
        if (nav.contains(event.target) || menuToggle.contains(event.target)) return;
        closeMenu();
    });

    // Counter animation for stats
    var statsSection = document.querySelector('.stats');
    var counters = document.querySelectorAll('.counter');
    var counted = false;

    function countUp(element, target, duration) {
        var start = 0;
        var increment = target / (duration / 50);
        var current = start;

        var timer = setInterval(function () {
            current += increment;
            if (current >= target) {
                element.textContent = target + '+';
                clearInterval(timer);
            } else {
                element.textContent = Math.floor(current) + '+';
            }
        }, 50);
    }

    function startCounters() {
        if (counted) return;
        counted = true;

        counters.forEach(function (counter) {
            var target = parseInt(counter.getAttribute('data-target'), 10);
            countUp(counter, target, 1200);
        });
    }

    if ('IntersectionObserver' in window && statsSection) {
        var counterObserver = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    startCounters();
                    counterObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.3 });

        counterObserver.observe(statsSection);
    } else if (statsSection) {
        startCounters();
    }

    // Tabs selection for preview mockups
    var tabButtons = document.querySelectorAll('.preview-pill');
    var mockups = document.querySelectorAll('.preview-mockup');
    var mockupUrl = document.getElementById('mockupUrl');

    var urls = {
        'mockup-student': 'https://psmels.software/student/workspace',
        'mockup-instructor': 'https://psmels.software/instructor/courses',
        'mockup-admin': 'https://psmels.software/admin/dashboard'
    };

    tabButtons.forEach(function (btn) {
        btn.addEventListener('click', function () {
            tabButtons.forEach(function (b) { b.classList.remove('active'); });
            mockups.forEach(function (m) { m.classList.remove('active'); });

            btn.classList.add('active');
            var targetId = btn.getAttribute('data-target');
            var target = document.getElementById(targetId);
            if (target) {
                target.classList.add('active');
            }
            if (mockupUrl && urls[targetId]) {
                mockupUrl.textContent = urls[targetId];
            }
        });
    });

    window.addEventListener('scroll', function () {
        setHeaderState();
        updateActiveLink();
    }, { passive: true });

    window.addEventListener('resize', function () {
        if (window.innerWidth > 760) closeMenu();
    });

    setHeaderState();
    updateActiveLink();
});
