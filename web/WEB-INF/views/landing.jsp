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
    <script src="https://unpkg.com/@dotlottie/player-component@2.7.12/dist/dotlottie-player.js"></script>
        <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="landing-page">
<header class="site-header" id="siteHeader">
    <div class="container shell">
        <a class="brand" href="#home" aria-label="PSM E-Learning home">
            <span class="brand-mark">PSM</span>
            <span class="brand-text">E-Learning</span>
        </a>

        <button class="menu-toggle" id="menuToggle" type="button" aria-label="Toggle navigation" aria-expanded="false">
            <span></span>
            <span></span>
        </button>

        <nav class="nav" id="siteNav" aria-label="Primary navigation">
            <a href="#home">Home</a>
            <a href="#courses">Courses</a>
            <a href="#verify">Verify</a>
            <a href="#contact">Contact</a>
        </nav>

        <div class="header-actions">
            <button type="button" class="theme-toggle" data-theme-toggle aria-pressed="false">
                <span class="theme-toggle-label">Dark mode</span>
            </button>
            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/login">Login</a>
            <a class="btn btn-solid" href="${pageContext.request.contextPath}/register">Get Started</a>
        </div>
    </div>
</header>

<c:if test="${not empty sessionScope.success}">
    <div class="container landing-alert landing-alert-success">
        <c:out value="${sessionScope.success}"/>
    </div>
    <c:remove var="success" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.error}">
    <div class="container landing-alert landing-alert-error">
        <c:out value="${sessionScope.error}"/>
    </div>
    <c:remove var="error" scope="session"/>
</c:if>

<main>
    <section class="hero section" id="home">
        <div class="container hero-grid">
            <div class="hero-copy reveal">
                <h1>Start learning with clear steps and real progress you can track.</h1>
                <p class="hero-lead">Find a course, continue where you stopped, and verify your certificate easily when you finish.</p>
                <div class="hero-actions">
                    <a class="btn btn-solid" href="${pageContext.request.contextPath}/register">Get Started</a>
                    <a class="btn btn-ghost" href="#features">Learn More</a>
                </div>
            </div>

            <div class="hero-visual reveal" aria-hidden="true">
                <div class="hero-lottie-shell">
                        <lottie-player
                            src="${pageContext.request.contextPath}/img/landing/hero-animation.json"
                            background="transparent"
                            speed="1"
                            loop
                            autoplay>
                        </lottie-player>
                </div>
            </div>
        </div>
    </section>

    <section class="stats section" id="stats">
        <div class="container reveal">
            <div class="section-heading compact">
                <p class="eyebrow">Quick facts</p>
                <h2>A quick view of who is learning here.</h2>
                <p>Simple numbers help students and instructors see progress at a glance.</p>
            </div>
            <div class="stats-grid">
                <article class="stat-card">
                    <span class="stat-label">Active Students</span>
                    <strong data-target="${studentCount}" class="counter">0</strong>
                </article>
                <article class="stat-card">
                    <span class="stat-label">Instructors</span>
                    <strong data-target="${instructorCount}" class="counter">0</strong>
                </article>
                <article class="stat-card">
                    <span class="stat-label">Approved Courses</span>
                    <strong data-target="${courseCount}" class="counter">0</strong>
                </article>
            </div>
        </div>
    </section>

    <section class="verify section" id="verify">
        <div class="container reveal verify-grid">
            <div class="section-heading compact">
                <p class="eyebrow">Public verification</p>
                <h2>Verify certificates without needing an account.</h2>
                <p>Enter the certificate code to check authenticity, issue details, and status instantly.</p>
            </div>
            <form class="verify-console" method="get" action="${pageContext.request.contextPath}/certificate/verify">
                <label for="landingCertificateCode">Certificate code</label>
                <div class="verify-command-row">
                    <input id="landingCertificateCode" type="text" name="code" placeholder="PSM-CERT-20260404-ABC123" required>
                    <button class="btn btn-solid" type="submit">Verify</button>
                </div>
                <p class="verify-inline-note">Public verification. No login required.</p>
                <div class="verify-motion-track" aria-hidden="true"><span></span></div>
            </form>
        </div>
    </section>

    <section class="features section" id="features">
        <div class="container">
            <div class="section-heading reveal">
                <p class="eyebrow">Features</p>
                <h2>Built around what people need to do.</h2>
                <p>Each part of the system helps people start, continue, and verify without confusion.</p>
            </div>
            <div class="feature-grid">
                <article class="feature-card reveal">
                    <span class="feature-kicker">01</span>
                    <div class="feature-copy">
                        <h3>Course control</h3>
                        <p>Create and manage courses with a layout that stays out of the way.</p>
                    </div>
                    <span class="feature-trace" aria-hidden="true"></span>
                </article>
                <article class="feature-card reveal">
                    <span class="feature-kicker">02</span>
                    <div class="feature-copy">
                        <h3>Assessment flow</h3>
                        <p>Track submissions, progress, and outcomes without cluttered screens.</p>
                    </div>
                    <span class="feature-trace" aria-hidden="true"></span>
                </article>
                <article class="feature-card reveal">
                    <span class="feature-kicker">03</span>
                    <div class="feature-copy">
                        <h3>Certificate trust</h3>
                        <p>Issue and verify credentials publicly with a direct, reliable workflow.</p>
                    </div>
                    <span class="feature-trace" aria-hidden="true"></span>
                </article>
            </div>
        </div>
    </section>

    <section class="courses section" id="courses">
        <div class="container">
            <div class="section-heading reveal">
                <p class="eyebrow">Featured courses</p>
                <h2>Choose a course and start learning.</h2>
                <p>A short list makes it easier to find a course and continue quickly.</p>
            </div>
            <c:choose>
                <c:when test="${not empty featuredCourses}">
                    <div class="course-mini-grid">
                        <c:forEach var="course" items="${featuredCourses}" begin="0" end="2">
                            <article class="course-mini-card reveal">
                                <div class="course-mini-cover">
                                    <c:choose>
                                        <c:when test="${not empty course.courseBanner}">
                                            <c:choose>
                                                <c:when test="${fn:startsWith(course.courseBanner, 'http')}">
                                                    <img src="${course.courseBanner}" alt="${course.courseName} cover">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}${course.courseBanner}" alt="${course.courseName} cover">
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="course-mini-cover-fallback" aria-hidden="true">
                                                <span></span><span></span><span></span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <span class="course-mini-label">Approved course</span>
                                <h3><c:out value="${course.courseName}"/></h3>
                                <p><c:out value="${course.category}"/> &middot; <fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2"/></p>
                                <a href="${pageContext.request.contextPath}/student/courses">View details</a>
                            </article>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="course-mini-empty reveal">
                        <p>No featured courses are available right now.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <section class="preview section" id="preview">
        <div class="container preview-grid">
            <div class="preview-sidebar reveal">
                <div class="section-heading">
                    <p class="eyebrow">Interactive Demo</p>
                    <h2>Explore our integrated workspaces.</h2>
                    <p>Select a portal below to see how learning, teaching, and system administration flows seamlessly on our platform.</p>
                </div>
                
                <div class="preview-tabs">
                    <button type="button" class="preview-pill active" data-target="mockup-student">
                        <i class="fas fa-graduation-cap"></i>
                        <span>Student Space</span>
                    </button>
                    <button type="button" class="preview-pill" data-target="mockup-instructor">
                        <i class="fas fa-chalkboard-user"></i>
                        <span>Instructor Console</span>
                    </button>
                    <button type="button" class="preview-pill" data-target="mockup-admin">
                        <i class="fas fa-user-shield"></i>
                        <span>Admin Dashboard</span>
                    </button>
                </div>
            </div>

            <div class="preview-card reveal">
                <div class="preview-media-container">
                    <div class="preview-mockup-header">
                        <span class="dot red"></span>
                        <span class="dot yellow"></span>
                        <span class="dot green"></span>
                        <span class="mockup-url" id="mockupUrl">https://psmels.software/student/workspace</span>
                    </div>
                    <div class="preview-mockup-body">
                        <!-- Student Mockup -->
                        <div id="mockup-student" class="preview-mockup active">
                            <div class="mockup-item">
                                <span class="course-mini-label">Active Learning</span>
                                <h4 style="margin: 4px 0 0; font-size: 1.1rem; color: var(--text);">Interactive Web Development</h4>
                                <div class="mockup-progress-bar">
                                    <span style="width: 78%;"></span>
                                </div>
                                <span style="font-size: 0.82rem; color: var(--muted); margin-top: 4px; display: block;">Progress: 78% &middot; 14/18 Materials Complete</span>
                            </div>
                            <div class="mockup-item" style="flex-direction: row; justify-content: space-between; align-items: center; gap: 12px;">
                                <div>
                                    <h4 style="margin: 0; font-size: 1rem; color: var(--text);">Verified Credentials</h4>
                                    <span style="font-size: 0.82rem; color: var(--muted); display: block; margin-top: 2px;">Share public achievement links</span>
                                </div>
                                <i class="fas fa-certificate" style="font-size: 1.5rem; color: var(--accent); flex-shrink: 0;"></i>
                            </div>
                            <div style="height: 120px; display: flex; align-items: center; justify-content: center; overflow: hidden; border-radius: 12px; margin-top: 10px; background: var(--surface-soft);">
                                <lottie-player src="${pageContext.request.contextPath}/img/landing/student-animation.json" background="transparent" speed="1" loop autoplay style="width: 220px; height: 220px;"></lottie-player>
                            </div>
                        </div>
                        
                        <!-- Instructor Mockup -->
                        <div id="mockup-instructor" class="preview-mockup">
                            <div class="mockup-item">
                                <span class="course-mini-label">Course Stats</span>
                                <div style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 4px;">
                                    <strong style="font-size: 1.8rem; font-weight: 800; color: var(--text); margin: 0;">148</strong>
                                    <span style="font-size: 0.84rem; color: #10b981; font-weight: 600;"><i class="fas fa-arrow-up"></i> +12% this week</span>
                                </div>
                                <span style="font-size: 0.82rem; color: var(--muted); margin-top: 2px; display: block;">Active Enrolled Students</span>
                            </div>
                            <div class="mockup-item">
                                <span class="course-mini-label">Curriculum Control</span>
                                <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 6px;">
                                    <div style="display: flex; align-items: center; gap: 8px; font-size: 0.84rem; padding: 6px 10px; background: var(--surface); border: 1px solid var(--line); border-radius: 8px; color: var(--text);">
                                        <i class="fas fa-file-lines" style="color: var(--accent);"></i>
                                        <span>Module 1: HTML5 Semantics</span>
                                    </div>
                                    <div style="display: flex; align-items: center; gap: 8px; font-size: 0.84rem; padding: 6px 10px; background: var(--surface); border: 1px solid var(--line); border-radius: 8px; color: var(--text);">
                                        <i class="fas fa-video" style="color: var(--accent);"></i>
                                        <span>Module 2: CSS3 Grid & Flexbox</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Admin Mockup -->
                        <div id="mockup-admin" class="preview-mockup">
                            <div class="mockup-item" style="padding: 16px;">
                                <span class="course-mini-label">Platform Growth</span>
                                <div class="mockup-chart-container">
                                    <div class="mockup-chart-bar" style="height: 35%;"></div>
                                    <div class="mockup-chart-bar" style="height: 55%;"></div>
                                    <div class="mockup-chart-bar" style="height: 45%;"></div>
                                    <div class="mockup-chart-bar" style="height: 75%;"></div>
                                    <div class="mockup-chart-bar filled" style="height: 90%;"></div>
                                </div>
                            </div>
                            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px;">
                                <div class="mockup-item" style="padding: 12px;">
                                    <span class="course-mini-label">Daily Revenue</span>
                                    <strong style="font-size: 1.15rem; color: var(--text); margin: 0; display: block; margin-top: 4px;">$1,240.00</strong>
                                </div>
                                <div class="mockup-item" style="padding: 12px;">
                                    <span class="course-mini-label">New Signups</span>
                                    <strong style="font-size: 1.15rem; color: var(--text); margin: 0; display: block; margin-top: 4px;">+48 Users</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="cta section">
        <div class="container cta-box reveal">
            <div>
                <p class="eyebrow">Ready to begin</p>
                <h2>Start learning without the clutter.</h2>
            </div>
            <div class="cta-actions">
                <a class="btn btn-solid" href="${pageContext.request.contextPath}/register">Get Started</a>
                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/login">Login</a>
            </div>
        </div>
    </section>
</main>

<footer class="site-footer" id="contact">
    <div class="container footer-grid">
        <div>
            <a class="brand footer-brand" href="#home">
                <span class="brand-mark">PSM</span>
                <span class="brand-text">E-Learning</span>
            </a>
            <p>A simple place for students to learn, instructors to teach, and anyone to verify certificates.</p>
            <p class="footer-note">Need help? Sign in for your account or verify a certificate publicly from the link below.</p>
        </div>
        <div>
            <span class="footer-title">Explore</span>
            <a href="#features">Features</a>
                <a href="#courses">Courses</a>
            <a href="#preview">Preview</a>
            <a href="#stats">Trust</a>
        </div>
        <div>
            <span class="footer-title">Access</span>
            <a href="${pageContext.request.contextPath}/login">Login</a>
            <a href="${pageContext.request.contextPath}/register">Register</a>
            <a href="${pageContext.request.contextPath}/certificate/verify">Verify Certificate</a>
        </div>
    </div>
</footer>

<script src="${pageContext.request.contextPath}/js/landing.js"></script>
</body>
</html>
