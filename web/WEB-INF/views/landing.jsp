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
            <a href="#apply">Apply</a>
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
                    <a class="btn btn-ghost" href="#apply">Become an Instructor</a>
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

    <section class="application section" id="apply">
        <div class="container application-grid reveal">
            <div class="section-heading compact">
                <p class="eyebrow">Instructor applications</p>
                <h2>Ready to apply as an instructor?</h2>
                <p>Share your details, CV, and teaching background in a short form. The admin team will review it and reply with the result.</p>
                <div class="application-points">
                    <span>CV upload</span>
                    <span>Specialization review</span>
                    <span>Email decision</span>
                </div>
            </div>
            <div class="application-card application-card-compact">
                <div class="application-card-foot">
                    <button class="btn application-submit application-submit-unique" type="button" data-application-modal-open>Apply to Teach</button>
                </div>
            </div>
        </div>
    </section>

    <div class="application-modal" id="applicationModal" aria-hidden="true" role="dialog" aria-modal="true" aria-labelledby="applicationModalTitle">
        <div class="application-modal-backdrop" data-application-modal-close></div>
        <div class="application-modal-dialog" role="document">
            <div class="application-modal-header">
                <div>
                    <p class="eyebrow">Instructor applications</p>
                    <h2 id="applicationModalTitle">Apply in a few steps</h2>
                    <p>Keep it short and clear. The admin team will review your application and contact you by email.</p>
                </div>
                <button type="button" class="application-modal-close" aria-label="Close application form" data-application-modal-close>&times;</button>
            </div>

            <form class="application-card application-card-modal" method="post" action="${pageContext.request.contextPath}/apply-instructor" enctype="multipart/form-data">
                <div class="application-form-grid">
                    <div class="application-field">
                        <label for="appFullName">Full name</label>
                        <input id="appFullName" name="fullName" type="text" placeholder="Enter your full name" required>
                    </div>
                    <div class="application-field">
                        <label for="appEmail">Email</label>
                        <input id="appEmail" name="email" type="email" placeholder="name@example.com" required>
                    </div>
                    <div class="application-field">
                        <label for="appPhone">Phone</label>
                        <input id="appPhone" name="phone" type="tel" placeholder="+255 700 000 000" required>
                    </div>
                    <div class="application-field">
                        <label for="appSpecialization">Specialization</label>
                        <input id="appSpecialization" name="specialization" type="text" placeholder="e.g. Project Management" required>
                    </div>
                    <div class="application-field">
                        <label for="appYearsOfExperience">Years of experience</label>
                        <input id="appYearsOfExperience" name="yearsOfExperience" type="number" min="0" step="1" placeholder="Optional">
                    </div>
                    <div class="application-field">
                        <label for="appQualification">Qualification</label>
                        <input id="appQualification" name="qualification" type="text" placeholder="Highest qualification" required>
                    </div>
                    <div class="application-field application-field-full">
                        <label for="appCvFile">CV or supporting document</label>
                        <input id="appCvFile" name="cvFile" type="file" accept=".pdf,.doc,.docx" required>
                        <small>Accepted formats: PDF, DOC, DOCX.</small>
                    </div>
                    <div class="application-field application-field-full">
                        <label for="appCoverMessage">Short cover message</label>
                        <textarea id="appCoverMessage" name="coverMessage" rows="4" placeholder="Tell the admin team why you want to teach here."></textarea>
                    </div>
                </div>
                <div class="application-card-foot">
                    <p>Applications are reviewed manually and responses are sent by email.</p>
                    <button class="btn btn-solid application-submit" type="submit">Submit application</button>
                </div>
            </form>
        </div>
    </div>

    <section class="preview section" id="preview">
        <div class="container preview-grid">
            <div class="section-heading reveal">
                <p class="eyebrow">Preview</p>
                <h2>See how learning flows from course to certificate.</h2>
                <p>From enrollment to verification, the steps stay simple and clear for the learner.</p>
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
                <h2>Start learning without the clutter.</h2>
            </div>
            <div class="cta-actions">
                <a class="btn btn-solid" href="${pageContext.request.contextPath}/register">Get Started</a>
                <a class="btn btn-ghost" href="#apply">Apply to Teach</a>
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
