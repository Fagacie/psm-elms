<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="PSM E-Learning Management System - a clean, modern platform for course delivery, assessments, and certificate verification.">
    <title>PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/@dotlottie/player-component@2.7.12/dist/dotlottie-player.js"></script>
        <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
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
            <a href="#stats">Trust</a>
            <a href="#verify">Verify</a>
            <a href="#features">Features</a>
            <a href="#courses">Courses</a>
            <a href="#preview">Preview</a>
            <a href="#contact">Contact</a>
        </nav>

        <div class="header-actions">
            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/login">Login</a>
            <a class="btn btn-solid" href="${pageContext.request.contextPath}/register">Get Started</a>
        </div>
    </div>
</header>

<main>
    <section class="hero section" id="home">
        <div class="container hero-grid">
            <div class="hero-copy reveal">
                <p class="eyebrow">PSM E-Learning Platform</p>
                <h1>Clear learning operations for courses, certificates, and verification.</h1>
                <p class="hero-lead">A minimal e-learning system built to keep teaching, tracking, and public verification simple, fast, and easy to scan.</p>
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
                <p class="eyebrow">Trusted by the platform</p>
                <h2>Small surface area. Clear signals.</h2>
                <p>Simple metrics keep the experience focused on outcomes instead of noise.</p>
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
                <h2>Minimal by design, complete in function.</h2>
                <p>Each part of the system is built to stay readable and direct.</p>
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
                <h2>Approved courses that are ready to explore.</h2>
                <p>A small selection keeps the landing page informative without turning it into a catalog.</p>
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
                                <p><c:out value="${course.category}"/> · <fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2"/></p>
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
            <div class="section-heading reveal">
                <p class="eyebrow">Product preview</p>
                <h2>Student learning journey, visualized.</h2>
                <p>An overview of how learners progress through coursework, assessments, and credential verification in one streamlined flow.</p>
            </div>
            <div class="preview-card reveal">
                <div class="preview-media">
                    <lottie-player src="${pageContext.request.contextPath}/img/landing/student-animation.json" background="transparent" speed="1" loop autoplay></lottie-player>
                </div>
            </div>
        </div>
    </section>

    <section class="cta section">
        <div class="container cta-box reveal">
            <div>
                <p class="eyebrow">Ready to begin</p>
                <h2>Start with a platform that stays clear at every step.</h2>
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
            <p>Simple learning tools with public verification and low-friction navigation.</p>
            <p class="footer-note">Need help? Use the login page for support access or verify certificates publicly from the link below.</p>
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
