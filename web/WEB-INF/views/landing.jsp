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
                <h1>Start learning with clear steps and real progress you can track.</h1>
                <p class="lp_hero_lead">Find a course, continue where you stopped, and verify your certificate easily when you finish.</p>
                <div class="lp_hero_actions">
                    <a class="lp_btn lp_btn_indigo" href="${pageContext.request.contextPath}/register">Get Started</a>
                    <a class="lp_btn lp_btn_ghost" href="#features">Learn More</a>
                </div>
            </div>

            <div class="lp_hero_visual" aria-hidden="true" data-aos="fade-up" data-aos-delay="200">
                <div class="lp_floating_card lp_floating_card_1">
                    <div class="lp_mini_avatar"></div>
                    <div style="height: 8px; border-radius: 4px; background: var(--lp-gray-border); margin-bottom: 12px;"><div style="width: 70%; height: 100%; background: var(--lp-indigo); border-radius: 4px;"></div></div>
                    <div style="font-size: 0.8rem; margin-top: 8px; color: var(--lp-slate-gray); font-weight: 600;">Active Learning</div>
                </div>
                
                <div class="lp_floating_card lp_floating_card_2">
                    <div style="font-size: 2rem; font-weight: 800; line-height: 1; margin-bottom: 4px;">148</div>
                    <div style="font-size: 0.8rem; color: var(--lp-slate-light); font-weight: 600;">Enrolled Students</div>
                    <div class="lp_mini_chart">
                        <div class="lp_mini_chart_bar"></div>
                        <div class="lp_mini_chart_bar"></div>
                        <div class="lp_mini_chart_bar"></div>
                        <div class="lp_mini_chart_bar"></div>
                    </div>
                </div>
                
                <div class="lp_floating_card lp_floating_card_3">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <span style="font-size: 0.8rem; font-weight: 700; color: var(--lp-slate-dark);">Module 1: HTML5 Semantics</span>
                        <i data-lucide="check-circle" style="color: #22c55e; width: 18px; height: 18px;"></i>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-size: 0.8rem; font-weight: 700; color: var(--lp-slate-light);">Module 2: CSS3 Grid</span>
                        <div style="width: 16px; height: 16px; border: 2px solid var(--lp-gray-border); border-radius: 50%;"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Task 2: Quick Facts Banner -->
    <section class="lp_banner_dark" id="stats">
        <div class="lp_container">
            <p class="lp_eyebrow" data-aos="fade-up">Quick facts</p>
            <h2 data-aos="fade-up" data-aos-delay="100">A quick view of who is learning here.</h2>
            <p data-aos="fade-up" data-aos-delay="200">Simple numbers help students and instructors see progress at a glance.</p>
            
            <div class="lp_stats_grid" id="statsTrigger">
                <div class="lp_stat_item" data-aos="fade-up" data-aos-delay="300">
                    <strong data-target="${studentCount}" class="lp_stat_value lp_counter">0</strong>
                    <span class="lp_stat_label">Active Students</span>
                </div>
                <div class="lp_stat_item" data-aos="fade-up" data-aos-delay="400">
                    <strong data-target="${instructorCount}" class="lp_stat_value lp_counter">0</strong>
                    <span class="lp_stat_label">Instructors</span>
                </div>
                <div class="lp_stat_item" data-aos="fade-up" data-aos-delay="500">
                    <strong data-target="${courseCount}" class="lp_stat_value lp_counter">0</strong>
                    <span class="lp_stat_label">Approved Courses</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Task 3: Course Cards Redesign -->
    <section class="lp_section lp_courses lp_section_alt" id="courses">
        <div class="lp_container">
            <div class="lp_section_heading" data-aos="fade-up">
                <p class="lp_eyebrow">Featured courses</p>
                <h2>Choose a course and start learning.</h2>
                <p>A short list makes it easier to find a course and continue quickly.</p>
            </div>
            
            <c:choose>
                <c:when test="${not empty featuredCourses}">
                    <div class="lp_course_grid">
                        <c:forEach var="course" items="${featuredCourses}" begin="0" end="2" varStatus="status">
                            <article class="lp_course_card" data-aos="fade-up" data-aos-delay="${status.index * 150}">
                                <div class="lp_course_cover">
                                    <c:choose>
                                        <c:when test="${not empty course.courseBanner}">
                                            <c:choose>
                                                <c:when test="${fn:startsWith(course.courseBanner, 'http')}">
                                                    <img class="lp_course_img" src="${course.courseBanner}" alt="${course.courseName} cover">
                                                </c:when>
                                                <c:otherwise>
                                                    <img class="lp_course_img" src="${pageContext.request.contextPath}${course.courseBanner}" alt="${course.courseName} cover">
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="lp_course_img" style="display: flex; align-items: center; justify-content: center; background: var(--lp-gray-soft); color: var(--lp-slate-light);">No Image</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="lp_course_content">
                                    <span class="lp_course_category"><c:out value="${course.category}"/></span>
                                    <h3><c:out value="${course.courseName}"/></h3>
                                    
                                    <div class="lp_course_footer">
                                        <span class="lp_course_price">
                                            <c:choose>
                                                <c:when test="${course.courseFee > 0}">
                                                    ₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2"/>
                                                </c:when>
                                                <c:otherwise>Free</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <button type="button" class="lp_course_btn course-details-btn" 
                                                data-name="${fn:escapeXml(course.courseName)}"
                                                data-category="${fn:escapeXml(course.category)}"
                                                data-level="${fn:escapeXml(course.level)}"
                                                data-duration="${fn:escapeXml(course.displayDuration)}"
                                                data-fee="${course.courseFee}"
                                                data-desc="${fn:escapeXml(course.description)}"
                                                aria-label="View Details">
                                            <i data-lucide="arrow-right"></i>
                                        </button>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="padding: 60px; text-align: center; border: 1px dashed var(--lp-gray-border); border-radius: var(--lp-radius); color: var(--lp-slate-light);" data-aos="fade-up">
                        <i data-lucide="inbox" style="width: 48px; height: 48px; margin-bottom: 16px; opacity: 0.5;"></i>
                        <p>No featured courses are available right now.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- Task 4: Interactive Verification Block -->
    <section class="lp_section lp_verify" id="verify">
        <div class="lp_container">
            <div class="lp_verify_wrapper" data-aos="fade-up">
                <p class="lp_eyebrow">Public verification</p>
                <h2>Verify certificates seamlessly.</h2>
                <p style="margin-top: 16px;">Enter the certificate code to check authenticity instantly without logging in.</p>
                
                <form class="lp_verify_console" method="get" action="${pageContext.request.contextPath}/certificate/verify">
                    <div class="lp_verify_search_bar">
                        <i data-lucide="search"></i>
                        <input id="landingCertificateCode" class="lp_verify_input" type="text" name="code" placeholder="PSM-CERT-20260404-ABC123" required>
                        <button class="lp_verify_btn" type="submit">
                            Verify <i data-lucide="arrow-right" style="margin-left: 4px; color: white;"></i>
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
            <div class="lp_feature_grid">
                <article class="lp_feature_card" data-aos="fade-up" data-aos-delay="100">
                    <div class="lp_feature_icon"><i data-lucide="layout"></i></div>
                    <h3>Course control</h3>
                    <p>Create and manage courses with a layout that stays out of the way.</p>
                </article>
                <article class="lp_feature_card" data-aos="fade-up" data-aos-delay="200">
                    <div class="lp_feature_icon"><i data-lucide="activity"></i></div>
                    <h3>Assessment flow</h3>
                    <p>Track submissions, progress, and outcomes without cluttered screens.</p>
                </article>
                <article class="lp_feature_card" data-aos="fade-up" data-aos-delay="300">
                    <div class="lp_feature_icon"><i data-lucide="shield-check"></i></div>
                    <h3>Certificate trust</h3>
                    <p>Issue and verify credentials publicly with a direct, reliable workflow.</p>
                </article>
            </div>
        </div>
    </section>
</main>

<footer class="lp_footer" id="contact">
    <div class="lp_container">
        <div class="lp_footer_grid">
            <div>
                <a class="lp_brand" href="#home" style="margin-bottom: 24px;">
                    <span class="lp_brand_mark">PSM</span>
                    <span class="lp_brand_text">E-Learning</span>
                </a>
                <p>PSM E-Learning is a state-of-the-art virtual campus helping students acquire industry-relevant skills, enabling instructors to build structured curricula, and offering open cryptographic credential validation.</p>
            </div>
            <div>
                <span class="lp_footer_title">Contact Us</span>
                <a href="mailto:support@psmels.software"><i data-lucide="mail" style="width: 18px;"></i> support@psmels.software</a>
                <span><i data-lucide="map-pin" style="width: 18px;"></i> PSM Virtual Campus, HQ</span>
                <span><i data-lucide="clock" style="width: 18px;"></i> Mon - Fri, 9AM - 5PM</span>
            </div>
            <div>
                <span class="lp_footer_title">Access</span>
                <a href="${pageContext.request.contextPath}/login"><i data-lucide="log-in" style="width: 18px;"></i> Login</a>
                <a href="${pageContext.request.contextPath}/register"><i data-lucide="user-plus" style="width: 18px;"></i> Register</a>
                <a href="${pageContext.request.contextPath}/certificate/verify"><i data-lucide="shield" style="width: 18px;"></i> Verify Certificate</a>
            </div>
        </div>
        <div class="lp_footer_bottom">
            © 2026 PSM E-Learning. All rights reserved.
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
<script src="${pageContext.request.contextPath}/js/landing.js"></script>
</body>
</html>
