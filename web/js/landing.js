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

    // 4.5 Innovative Parallax
    if (!reduceMotion && statsTrigger) {
        document.addEventListener('mousemove', (e) => {
            const layers = statsTrigger.querySelectorAll('.lp_stat_parallax_layer');
            if(!layers.length) return;
            const xAxis = (window.innerWidth / 2 - e.clientX) / 40;
            const yAxis = (window.innerHeight / 2 - e.clientY) / 40;
            
            layers.forEach((layer, index) => {
                const depth = (index + 1) * 0.6;
                layer.style.transform = `translate(${xAxis * depth}px, ${yAxis * depth}px)`;
            });
        });
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

    // 6. Dynamic Course Loading, Filtering & Pagination
    const courseDataStore = document.getElementById('courseDataStore');
    const dynamicCourseContainer = document.getElementById('dynamicCourseContainer');
    const filterContainer = document.getElementById('courseFilterContainer');
    const paginationContainer = document.getElementById('coursePaginationContainer');
    
    if (courseDataStore && dynamicCourseContainer) {
        let allCourses = [];
        let categories = new Set();
        
        const dataItems = courseDataStore.querySelectorAll('.course-data-item');
        dataItems.forEach(item => {
            const course = {
                id: item.dataset.id,
                name: item.dataset.name,
                category: item.dataset.category,
                fee: parseFloat(item.dataset.fee),
                duration: item.dataset.duration,
                level: item.dataset.level,
                banner: item.dataset.banner,
                context: item.dataset.context,
                desc: item.textContent.trim()
            };
            allCourses.push(course);
            if(course.category) categories.add(course.category);
        });

        let currentFilter = 'all';
        let currentSearchQuery = '';
        let currentPage = 1;
        const itemsPerPage = 4;
        let filteredCourses = [...allCourses];

        const searchInput = document.getElementById('courseSearchInput');

        function applyFilters() {
            filteredCourses = allCourses.filter(c => {
                const matchSearch = currentSearchQuery === '' || 
                                    c.name.toLowerCase().includes(currentSearchQuery.toLowerCase()) || 
                                    (c.desc && c.desc.toLowerCase().includes(currentSearchQuery.toLowerCase()));
                return matchSearch;
            });
            currentPage = 1;
            renderCourses();
        }

        if(searchInput) {
            searchInput.addEventListener('input', (e) => {
                currentSearchQuery = e.target.value.trim();
                applyFilters();
            });
        }

        function renderCourses() {
            const totalPages = Math.ceil(filteredCourses.length / itemsPerPage) || 1;
            if(currentPage > totalPages) currentPage = totalPages;
            
            const startIdx = (currentPage - 1) * itemsPerPage;
            const currentCourses = filteredCourses.slice(startIdx, startIdx + itemsPerPage);
            
            dynamicCourseContainer.innerHTML = '';
            
            if(currentCourses.length === 0) {
                dynamicCourseContainer.innerHTML = `
                    <div style="grid-column: 1/-1; padding: 60px; text-align: center; border: 1px dashed var(--lp-gray-border); border-radius: var(--lp-radius); color: var(--lp-slate-light);">
                        <p>No courses found matching your search.</p>
                    </div>`;
                if(paginationContainer) paginationContainer.style.display = 'none';
                return;
            }

            currentCourses.forEach((course, index) => {
                const feeDisplay = course.fee > 0 ? '₦' + course.fee.toLocaleString(undefined, {minimumFractionDigits:2, maximumFractionDigits:2}) : 'Free';
                
                let imgSrc = `<div style="height: 100%; display: flex; align-items: center; justify-content: center; background: var(--lp-gray-soft); color: var(--lp-slate-light);">No Image</div>`;
                if(course.banner) {
                    if(course.banner.startsWith('http')) {
                        imgSrc = `<img class="lp_course_img" src="${course.banner}" alt="cover">`;
                    } else {
                        imgSrc = `<img class="lp_course_img" src="${course.context}${course.banner}" alt="cover">`;
                    }
                }

                const article = document.createElement('article');
                article.className = 'lp_course_card course-details-btn';
                article.setAttribute('data-name', course.name.replace(/"/g, '&quot;'));
                article.setAttribute('data-category', course.category.replace(/"/g, '&quot;'));
                article.setAttribute('data-level', course.level.replace(/"/g, '&quot;'));
                article.setAttribute('data-duration', course.duration.replace(/"/g, '&quot;'));
                article.setAttribute('data-fee', course.fee);
                article.setAttribute('data-desc', course.desc.replace(/"/g, '&quot;'));
                article.setAttribute('data-aos', 'fade-up');
                article.setAttribute('data-aos-delay', (index * 100).toString());
                
                article.innerHTML = `
                    <div class="lp_course_cover">
                        ${imgSrc}
                        <div class="lp_course_gradient"></div>
                    </div>
                    <div class="lp_course_basic_info">
                        <span class="lp_course_category">${course.category}</span>
                        <h3>${course.name}</h3>
                    </div>
                    <div class="lp_course_reveal">
                        <div class="lp_reveal_price">${feeDisplay}</div>
                        <div class="lp_reveal_meta">
                            <span><i data-lucide="bar-chart"></i> Level: ${course.level}</span>
                            <span><i data-lucide="clock"></i> Duration: ${course.duration}</span>
                        </div>
                        <span class="lp_hover_btn">View Details <i data-lucide="arrow-right"></i></span>
                    </div>
                `;
                dynamicCourseContainer.appendChild(article);
            });

            if(typeof lucide !== 'undefined') lucide.createIcons();
            
            const newBtns = dynamicCourseContainer.querySelectorAll('.course-details-btn');
            newBtns.forEach(btn => {
                btn.addEventListener('click', () => openCourseModal(btn));
            });

            if(paginationContainer && totalPages > 1) {
                paginationContainer.style.display = 'flex';
                document.getElementById('coursePageIndicator').textContent = 'Page ' + currentPage + ' of ' + totalPages;
                document.getElementById('prevCoursePage').disabled = currentPage === 1;
                document.getElementById('nextCoursePage').disabled = currentPage === totalPages;
            } else if(paginationContainer) {
                paginationContainer.style.display = 'none';
            }
        }

        const prevBtn = document.getElementById('prevCoursePage');
        const nextBtn = document.getElementById('nextCoursePage');
        
        if(prevBtn) {
            prevBtn.addEventListener('click', () => {
                if(currentPage > 1) {
                    currentPage--;
                    renderCourses();
                }
            });
        }
        
        if(nextBtn) {
            nextBtn.addEventListener('click', () => {
                const totalPages = Math.ceil(filteredCourses.length / itemsPerPage);
                if(currentPage < totalPages) {
                    currentPage++;
                    renderCourses();
                }
            });
        }

        renderCourses();
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
        
        var navLinks = siteHeader.querySelectorAll('.lp_nav a, .lp_header_actions a');
        navLinks.forEach(function(link) {
            link.addEventListener('click', function() {
                siteHeader.classList.remove("lp_mobile_open");
            });
        });
    }
});

