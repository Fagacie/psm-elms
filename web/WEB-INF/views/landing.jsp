<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="A simple place for learners to join courses, track progress, and verify certificates.">
    <title>PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Landing.module.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="lp_landing_page">
<header class="lp_header" id="siteHeader">
    <div class="lp_container lp_shell">
        <a class="lp_brand" href="#home" aria-label="PSM E-Learning home">
            <span class="lp_brand_mark">PSM</span>
            <span class="lp_brand_text">E-Learning</span>
        </a>

        <button class="lp_hamburger" id="lpMobileToggle" aria-label="Toggle menu">
            <i data-lucide="menu"></i>
        </button>

        <div class="lp_nav_wrapper" id="lpNavWrapper">
            <nav class="lp_nav" id="siteNav" aria-label="Primary navigation">
                <a href="#home">Home</a>
                <a href="#courses">Courses</a>
                <a href="#verify">Verify</a>
                <a href="#contact">Contact</a>
            </nav>

            <div class="lp_header_actions">
                <a class="lp_btn lp_btn_ghost" href="${pageContext.request.contextPath}/login">Login</a>
                <a class="lp_btn lp_btn_indigo" href="${pageContext.request.contextPath}/register">Get Started</a>
            </div>
        </div>
    </div>
</header>

<c:if test="${not empty sessionScope.success}">
    <div class="lp_container" style="margin-top: 24px; padding: 16px; background: #ecfdf5; color: #065f46; border: 1px solid #10b981; border-radius: 12px; font-weight: 500;">
        <c:out value="${sessionScope.success}"/>
    </div>
    <c:remove var="success" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.error}">
    <div class="lp_container" style="margin-top: 24px; padding: 16px; background: #fef2f2; color: #991b1b; border: 1px solid #ef4444; border-radius: 12px; font-weight: 500;">
        <c:out value="${sessionScope.error}"/>
    </div>
    <c:remove var="error" scope="session"/>
</c:if>

<main>
    <section class="lp_hero" id="home">
        <div class="lp_container lp_hero_grid">
            <div class="lp_hero_copy" data-aos="fade-up">
                <h1>Start learning with clear steps and real progress.</h1>
                <p class="lp_hero_lead">Find a course, continue where you stopped, and verify your certificate easily when you finish your learning journey.</p>
                <div class="lp_hero_actions">
                    <a class="lp_btn lp_btn_indigo" href="${pageContext.request.contextPath}/register">Get Started</a>
                </div>
            </div>

            <div class="lp_hero_visual" aria-hidden="true" data-aos="fade-up" data-aos-delay="200">
                <canvas id="heroCanvas" style="width: 100%; height: 100%; position: absolute; top: 0; left: 0; z-index: 1; border-radius: var(--lp-radius);"></canvas>
            </div>
        </div>
    </section>

    <!-- Task 2: Quick Facts Banner -->
    <section class="lp_banner_dark" id="stats">
        <div class="lp_container">
            <p class="lp_eyebrow" data-aos="fade-up">Quick facts</p>
            <h2 data-aos="fade-up" data-aos-delay="100">A quick view of who is learning here.</h2>
            <p data-aos="fade-up" data-aos-delay="200">Simple numbers help students and instructors see progress at a glance.</p>
            
            <div class="lp_stats_innovative" id="statsTrigger">
                <div class="lp_stat_item_innovative" data-aos="fade-up" data-aos-delay="300">
                    <div class="lp_stat_parallax_layer">
                        <strong data-target="${empty studentCount ? 10500 : studentCount}" class="lp_stat_value_innovative lp_counter lp_text_gradient_1">0</strong>
                        <span class="lp_stat_label_innovative"><i data-lucide="users"></i> Active Students</span>
                    </div>
                </div>
                <div class="lp_stat_item_innovative" data-aos="fade-up" data-aos-delay="400">
                    <div class="lp_stat_parallax_layer">
                        <strong data-target="${empty instructorCount ? 320 : instructorCount}" class="lp_stat_value_innovative lp_counter lp_text_gradient_2">0</strong>
                        <span class="lp_stat_label_innovative"><i data-lucide="graduation-cap"></i> Instructors</span>
                    </div>
                </div>
                <div class="lp_stat_item_innovative" data-aos="fade-up" data-aos-delay="500">
                    <div class="lp_stat_parallax_layer">
                        <strong data-target="${empty courseCount ? 1200 : courseCount}" class="lp_stat_value_innovative lp_counter lp_text_gradient_3">0</strong>
                        <span class="lp_stat_label_innovative"><i data-lucide="book-open"></i> Approved Courses</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Task 3: Course Cards Redesign -->
    <section class="lp_section lp_courses lp_section_alt" id="courses">
        <div class="lp_container">
            <div class="lp_section_heading" data-aos="fade-up">
                <p class="lp_eyebrow">Explore our courses</p>
                <h2>Discover your next skill.</h2>
                <p>Browse our catalog, filter by category, and hover over a course to preview its syllabus.</p>
            </div>
            
            <c:choose>
                <c:when test="${not empty featuredCourses}">
                    <!-- Dynamic Search -->
                    <div class="lp_course_search_container" data-aos="fade-up" data-aos-delay="50">
                        <div class="lp_course_search">
                            <i data-lucide="search"></i>
                            <input type="text" id="courseSearchInput" placeholder="Search courses by name or keyword..." aria-label="Search courses">
                        </div>
                    </div>

                    <!-- Dynamic Grid -->
                    <div class="lp_course_grid" id="dynamicCourseContainer" data-aos="fade-up" data-aos-delay="200">
                        <!-- Course cards injected here via JS -->
                    </div>

                    <!-- Pagination Controls -->
                    <div class="lp_course_pagination" id="coursePaginationContainer" data-aos="fade-up" data-aos-delay="300" style="display: none;">
                        <button class="lp_page_btn" id="prevCoursePage" disabled><i data-lucide="chevron-left"></i> Prev</button>
                        <span class="lp_page_indicator" id="coursePageIndicator">Page 1 of 1</span>
                        <button class="lp_page_btn" id="nextCoursePage">Next <i data-lucide="chevron-right"></i></button>
                    </div>

                    <!-- Robust Data Store for JS parsing -->
                    <div id="courseDataStore" style="display: none;">
                        <c:forEach var="course" items="${featuredCourses}">
                            <div class="course-data-item"
                                 data-id="${course.courseId}"
                                 data-name="${fn:escapeXml(course.courseName)}"
                                 data-category="${fn:escapeXml(course.category)}"
                                 data-fee="${course.courseFee}"
                                 data-duration="${fn:escapeXml(course.displayDuration)}"
                                 data-level="${fn:escapeXml(course.level)}"
                                 data-banner="${fn:escapeXml(course.courseBanner)}"
                                 data-context="${pageContext.request.contextPath}">
                                 ${fn:escapeXml(course.description)}
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="padding: 60px; text-align: center; border: 1px dashed var(--lp-gray-border); border-radius: var(--lp-radius); color: var(--lp-slate-light);" data-aos="fade-up">
                        <i data-lucide="inbox" style="width: 48px; height: 48px; margin-bottom: 16px; opacity: 0.5;"></i>
                        <p>No courses are available right now.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- Task 4: Interactive Verification Block -->
    <section class="lp_section lp_verify" id="verify">
        <div class="lp_container">
            <div class="lp_verify_wrapper" data-aos="fade-up">
                <i data-lucide="shield-check" class="lp_verify_watermark"></i>
                <p class="lp_eyebrow" style="color: var(--lp-cyan);">Public verification</p>
                <h2>Verify certificates seamlessly.</h2>
                <p style="margin-top: 16px;">Enter the certificate code to check authenticity instantly without logging in.</p>
                
                <form class="lp_verify_console" method="get" action="${pageContext.request.contextPath}/certificate/verify">
                    <div class="lp_verify_search_bar">
                        <i data-lucide="search"></i>
                        <input id="landingCertificateCode" class="lp_verify_input" type="text" name="code" placeholder="PSM-CERT-20260404-ABC123" required>
                        <button class="lp_verify_btn" type="submit">
                            Verify <i data-lucide="arrow-right"></i>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <section class="lp_section lp_features" id="features">
        <div class="lp_container">
            <div class="lp_section_heading lp_section_heading_center" data-aos="fade-up">
                <p class="lp_eyebrow">Features</p>
                <h2>Built around what people need to do.</h2>
                <p>Each part of the system helps people start, continue, and verify without confusion.</p>
            </div>
            <div class="lp_feature_galaxy" aria-label="Interactive features layout">
                <div class="lp_orb lp_orb_1">
                    <div class="lp_orb_core">
                        <i data-lucide="layout"></i>
                    </div>
                    <div class="lp_orb_info">
                        <h3>Course control</h3>
                        <p>Create and manage courses with a layout that stays out of the way.</p>
                    </div>
                </div>
                <div class="lp_orb lp_orb_2">
                    <div class="lp_orb_core">
                        <i data-lucide="activity"></i>
                    </div>
                    <div class="lp_orb_info">
                        <h3>Assessment flow</h3>
                        <p>Track submissions, progress, and outcomes without cluttered screens.</p>
                    </div>
                </div>
                <div class="lp_orb lp_orb_3">
                    <div class="lp_orb_core">
                        <i data-lucide="shield-check"></i>
                    </div>
                    <div class="lp_orb_info">
                        <h3>Certificate trust</h3>
                        <p>Issue and verify credentials publicly with a direct, reliable workflow.</p>
                    </div>
                </div>
                <div class="lp_orb lp_orb_4">
                    <div class="lp_orb_core">
                        <i data-lucide="credit-card"></i>
                    </div>
                    <div class="lp_orb_info">
                        <h3>Secure Payments</h3>
                        <p>Integrated Paystack processing for instant, secure course enrollment.</p>
                    </div>
                </div>
                <div class="lp_orb lp_orb_5">
                    <div class="lp_orb_core">
                        <i data-lucide="trending-up"></i>
                    </div>
                    <div class="lp_orb_info">
                        <h3>Progress Tracking</h3>
                        <p>Real-time monitoring of module completion and learning performance.</p>
                    </div>
                </div>
                <div class="lp_orb lp_orb_6">
                    <div class="lp_orb_core">
                        <i data-lucide="help-circle"></i>
                    </div>
                    <div class="lp_orb_info">
                        <h3>Interactive Quizzes</h3>
                        <p>Engaging assessments with automated grading and instant feedback.</p>
                    </div>
                </div>
                <div class="lp_orb lp_orb_7">
                    <div class="lp_orb_core">
                        <i data-lucide="users"></i>
                    </div>
                    <div class="lp_orb_info">
                        <h3>Multi-role Portals</h3>
                        <p>Dedicated dashboards optimized for students, instructors, and admins.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<footer class="lp_footer" id="contact">
    <div class="lp_container">
        <div class="lp_footer_grid">
            <div class="lp_footer_col_brand">
                <a class="lp_brand" href="#home" style="margin-bottom: 24px;">
                    <span class="lp_brand_mark">PSM</span>
                    <span class="lp_brand_text">E-Learning</span>
                </a>
                <p>Empowering students and instructors with a state-of-the-art virtual campus.</p>
                <div class="lp_footer_socials">
                    <a href="#" aria-label="Twitter"><i data-lucide="twitter"></i></a>
                    <a href="#" aria-label="LinkedIn"><i data-lucide="linkedin"></i></a>
                    <a href="#" aria-label="Facebook"><i data-lucide="facebook"></i></a>
                    <a href="#" aria-label="Instagram"><i data-lucide="instagram"></i></a>
                </div>
            </div>
            
            <div class="lp_footer_col">
                <span class="lp_footer_title">Features</span>
                <a href="#features">Course Management</a>
                <a href="#features">Assessments & Quizzes</a>
                <a href="#features">Secure Payments</a>
                <a href="#features">Role Portals</a>
            </div>

            <div class="lp_footer_col">
                <span class="lp_footer_title">Support</span>
                <a href="mailto:support@psmels.software">Contact Support</a>
                <a href="#">Help Center</a>
                <a href="#">Terms of Service</a>
                <a href="#">Privacy Policy</a>
            </div>

            <div class="lp_footer_col">
                <span class="lp_footer_title">Access</span>
                <a href="${pageContext.request.contextPath}/login">Login</a>
                <a href="${pageContext.request.contextPath}/register">Register</a>
                <a href="${pageContext.request.contextPath}/certificate/verify">Verify Certificate</a>
            </div>
        </div>
        <div class="lp_footer_bottom">
            <span>© 2026 PSM E-Learning. All rights reserved.</span>
            <div class="lp_footer_bottom_links">
                <a href="#">System Status: <strong style="color: var(--lp-cyan);">All Systems Operational</strong></a>
            </div>
        </div>
    </div>
</footer>

<!-- Public Course Details Modal -->
<div id="courseDetailsModal" class="lp_modal" aria-hidden="true" role="dialog">
    <div class="lp_modal_dialog">
        <button type="button" id="modalCloseBtn" style="position: absolute; top: 20px; right: 20px; background: none; border: none; cursor: pointer; color: var(--lp-slate-light);"><i data-lucide="x"></i></button>
        <h3 id="modalCourseName" style="margin: 0 0 16px; font-size: 1.5rem; color: var(--lp-slate-dark);">Course Title</h3>
        
        <div style="display: flex; gap: 8px; margin-bottom: 24px; flex-wrap: wrap;">
            <span id="modalCourseCategory" style="font-size: 0.75rem; padding: 4px 10px; background: var(--lp-gray-soft); border-radius: 999px; font-weight: 600; color: var(--lp-slate-dark);">Category</span>
            <span id="modalCourseLevel" style="font-size: 0.75rem; padding: 4px 10px; background: var(--lp-gray-soft); border-radius: 999px; font-weight: 600; color: var(--lp-slate-dark);">Level</span>
            <span id="modalCourseDuration" style="font-size: 0.75rem; padding: 4px 10px; background: var(--lp-gray-soft); border-radius: 999px; font-weight: 600; color: var(--lp-slate-dark);">Duration</span>
            <span id="modalCourseFee" style="font-size: 0.75rem; padding: 4px 10px; background: rgba(79, 70, 229, 0.1); color: var(--lp-indigo); border-radius: 999px; font-weight: 800;">Free</span>
        </div>
        
        <h4 style="margin: 0 0 8px; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--lp-slate-light);">Course Syllabus & Overview</h4>
        <p id="modalCourseDesc" style="font-size: 0.95rem; line-height: 1.6; margin-bottom: 32px;">Course description.</p>
        
        <div style="display: flex; gap: 16px; justify-content: flex-end;">
            <a href="${pageContext.request.contextPath}/login" class="lp_btn lp_btn_ghost">Sign In</a>
            <a href="${pageContext.request.contextPath}/register" class="lp_btn lp_btn_indigo">Register Account</a>
        </div>
    </div>
</div>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script src="https://unpkg.com/lucide@latest"></script>
<script src="${pageContext.request.contextPath}/js/landing.js?v=2"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const canvas = document.getElementById('heroCanvas');
    if (canvas) {
        const ctx = canvas.getContext('2d');
        let width = canvas.offsetWidth;
        let height = canvas.offsetHeight;
        canvas.width = width;
        canvas.height = height;

        const particles = [];
        const numParticles = 60;

        for (let i = 0; i < numParticles; i++) {
            particles.push({
                x: Math.random() * width,
                y: Math.random() * height,
                vx: (Math.random() - 0.5) * 1.2,
                vy: (Math.random() - 0.5) * 1.2,
                radius: Math.random() * 2 + 1
            });
        }

        function draw() {
            ctx.clearRect(0, 0, width, height);
            
            for (let i = 0; i < numParticles; i++) {
                let p = particles[i];
                p.x += p.vx;
                p.y += p.vy;

                if (p.x < 0) { p.x = 0; p.vx *= -1; }
                else if (p.x > width) { p.x = width; p.vx *= -1; }
                if (p.y < 0) { p.y = 0; p.vy *= -1; }
                else if (p.y > height) { p.y = height; p.vy *= -1; }

                ctx.beginPath();
                ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
                ctx.fillStyle = 'rgba(79, 70, 229, 0.6)';
                ctx.fill();

                for (let j = i + 1; j < numParticles; j++) {
                    let p2 = particles[j];
                    let dx = p.x - p2.x;
                    let dy = p.y - p2.y;
                    let dist = Math.sqrt(dx * dx + dy * dy);

                    if (dist < 120) {
                        ctx.beginPath();
                        ctx.moveTo(p.x, p.y);
                        ctx.lineTo(p2.x, p2.y);
                        ctx.strokeStyle = 'rgba(79, 70, 229, ' + (1 - dist/120) * 0.4 + ')';
                        ctx.lineWidth = 1;
                        ctx.stroke();
                    }
                }
            }
            requestAnimationFrame(draw);
        }
        draw();

        window.addEventListener('resize', () => {
            width = canvas.offsetWidth;
            height = canvas.offsetHeight;
            canvas.width = width;
            canvas.height = height;
        });
    }
});
</script>
</body>
</html>
