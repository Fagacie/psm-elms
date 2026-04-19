document.addEventListener('DOMContentLoaded', function () {
    var header = document.getElementById('siteHeader');
    var menuToggle = document.getElementById('menuToggle');
    var nav = document.getElementById('siteNav');
    var applicationModal = document.getElementById('applicationModal');
    var applicationOpeners = document.querySelectorAll('[data-application-modal-open]');
    var applicationClosers = document.querySelectorAll('[data-application-modal-close]');
    var links = nav ? nav.querySelectorAll('a[href^="#"]') : [];
    var reveals = document.querySelectorAll('.reveal');
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var lastModalTrigger = null;

    function setHeaderState() {
        if (!header) return;
        header.classList.toggle('is-scrolled', window.scrollY > 12);
    }

    function closeMenu() {
        if (!nav || !menuToggle) return;
        nav.classList.remove('is-open');
        menuToggle.setAttribute('aria-expanded', 'false');
    }

    function openApplicationModal(trigger) {
        if (!applicationModal) return;

        lastModalTrigger = trigger || document.activeElement;
        applicationModal.classList.add('is-open');
        applicationModal.setAttribute('aria-hidden', 'false');
        document.body.classList.add('application-modal-open');

        var firstField = applicationModal.querySelector('input, textarea, select, button');
        if (firstField && firstField.focus) {
            firstField.focus();
        }
    }

    function closeApplicationModal() {
        if (!applicationModal) return;

        applicationModal.classList.remove('is-open');
        applicationModal.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('application-modal-open');

        if (lastModalTrigger && lastModalTrigger.focus) {
            lastModalTrigger.focus();
        }
    }

    if (menuToggle && nav) {
        menuToggle.addEventListener('click', function () {
            var isOpen = nav.classList.toggle('is-open');
            menuToggle.setAttribute('aria-expanded', String(isOpen));
        });
    }

    applicationOpeners.forEach(function (button) {
        button.addEventListener('click', function () {
            openApplicationModal(button);
        });
    });

    applicationClosers.forEach(function (button) {
        button.addEventListener('click', function () {
            closeApplicationModal();
        });
    });

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

    if (applicationModal) {
        applicationModal.addEventListener('click', function (event) {
            if (event.target === applicationModal) {
                closeApplicationModal();
            }
        });
    }

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && applicationModal && applicationModal.classList.contains('is-open')) {
            closeApplicationModal();
        }
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
