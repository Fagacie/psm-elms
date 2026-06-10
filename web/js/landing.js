document.addEventListener('DOMContentLoaded', function () {
    // 1. Initialize Libraries
    if (typeof AOS !== 'undefined') {
        AOS.init({
            once: true,
            offset: 80,
            duration: 800,
            easing: 'ease-out-cubic',
        });
    }

    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    // 2. DOM Elements
    const header = document.getElementById('siteHeader');
    const nav = document.getElementById('siteNav');
    const links = nav ? nav.querySelectorAll('a[href^="#"]') : [];
    const reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // 3. Header & Navigation State
    function setHeaderState() {
        if (!header) return;
        header.classList.toggle('lp_header_scrolled', window.scrollY > 12);
    }

    links.forEach(link => {
        link.addEventListener('click', event => {
            const targetId = link.getAttribute('href').slice(1);
            const target = document.getElementById(targetId);
            if (!target) return;

            event.preventDefault();
            const offset = header ? header.offsetHeight + 14 : 0;
            const top = window.pageYOffset + target.getBoundingClientRect().top - offset;
            window.scrollTo({ top, behavior: reduceMotion ? 'auto' : 'smooth' });
        });
    });

    function updateActiveLink() {
        if (!links.length) return;
        const fromTop = window.scrollY + (header ? header.offsetHeight : 0) + 120;

        links.forEach(link => {
            const section = document.querySelector(link.getAttribute('href'));
            if (!section) return;

            const inView = fromTop >= section.offsetTop && fromTop < section.offsetTop + section.offsetHeight;
            link.classList.toggle('lp_active', inView);
        });
    }

    // 4. Number Count-Up Logic for Stats Banner
    let countersStarted = false;
    const counters = document.querySelectorAll('.lp_counter');
    const statsTrigger = document.getElementById('statsTrigger');

    function countUp(element, target, duration) {
        const start = 0;
        const increment = target / (duration / 50);
        let current = start;

        const timer = setInterval(() => {
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
        if (countersStarted || counters.length === 0) return;
        countersStarted = true;
        counters.forEach(counter => {
            const target = parseInt(counter.getAttribute('data-target'), 10);
            if (isNaN(target)) return;
            countUp(counter, target, 1500);
        });
    }

    if (!reduceMotion && 'IntersectionObserver' in window && statsTrigger) {
        const statsObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    startCounters();
                    statsObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });
        statsObserver.observe(statsTrigger);
    } else {
        // Fallback if no IntersectionObserver or reduced motion
        startCounters();
    }

    // 5. Course Details Modal handlers
    const courseDetailsModal = document.getElementById('courseDetailsModal');
    const modalCloseBtn = document.getElementById('modalCloseBtn');
    const courseDetailsBtns = document.querySelectorAll('.course-details-btn');

    function openCourseModal(btn) {
        if (!courseDetailsModal) return;
        
        const name = btn.getAttribute('data-name') || '';
        const category = btn.getAttribute('data-category') || '';
        const level = btn.getAttribute('data-level') || '';
        const duration = btn.getAttribute('data-duration') || '';
        const feeVal = parseFloat(btn.getAttribute('data-fee')) || 0;
        const desc = btn.getAttribute('data-desc') || '';

        const nameEl = document.getElementById('modalCourseName');
        const categoryEl = document.getElementById('modalCourseCategory');
        const levelEl = document.getElementById('modalCourseLevel');
        const durationEl = document.getElementById('modalCourseDuration');
        const feeEl = document.getElementById('modalCourseFee');
        const descEl = document.getElementById('modalCourseDesc');

        if (nameEl) nameEl.textContent = name;
        if (categoryEl) categoryEl.textContent = category;
        if (levelEl) levelEl.textContent = level;
        if (durationEl) durationEl.textContent = duration;
        
        if (feeEl) {
            if (feeVal <= 0) {
                feeEl.textContent = 'Free';
            } else {
                feeEl.textContent = '₦' + feeVal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }
        }
        
        if (descEl) descEl.textContent = desc;

        courseDetailsModal.classList.add('is-open');
        courseDetailsModal.setAttribute('aria-hidden', 'false');
    }

    function closeCourseModal() {
        if (!courseDetailsModal) return;
        courseDetailsModal.classList.remove('is-open');
        courseDetailsModal.setAttribute('aria-hidden', 'true');
    }

    courseDetailsBtns.forEach(btn => {
        btn.addEventListener('click', () => openCourseModal(btn));
    });

    if (modalCloseBtn) {
        modalCloseBtn.addEventListener('click', closeCourseModal);
    }

    if (courseDetailsModal) {
        courseDetailsModal.addEventListener('click', event => {
            if (event.target === courseDetailsModal) closeCourseModal();
        });
    }

    // Event Listeners
    window.addEventListener('scroll', () => {
        setHeaderState();
        updateActiveLink();
    }, { passive: true });

    // Initial triggers
    setHeaderState();
    updateActiveLink();
});

document.addEventListener("DOMContentLoaded", function() {
    var mobileToggle = document.getElementById("lpMobileToggle");
    var siteHeader = document.getElementById("siteHeader");
    if (mobileToggle && siteHeader) {
        mobileToggle.addEventListener("click", function() {
            siteHeader.classList.toggle("lp_mobile_open");
        });
    }
});

