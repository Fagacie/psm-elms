<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="PSM E-Learning Management System - Professional online learning platform for students, instructors, and administrators">
    <title>PSM E-Learning Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
</head>
<body>
    <!-- Header / Navigation -->
    <header class="header" id="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">
                    <span class="logo-text">PSM</span>
                    <span class="logo-subtext">E-Learning</span>
                </div>
                
                <button class="menu-toggle" id="menuToggle" aria-label="Toggle menu">
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
                
                <ul class="nav-menu" id="navMenu">
                    <li><a href="#home" class="nav-link active">Home</a></li>
                    <li><a href="#features" class="nav-link">Features</a></li>
                    <li><a href="#how-it-works" class="nav-link">How It Works</a></li>
                    <li><a href="#user-roles" class="nav-link">User Roles</a></li>
                    <li><a href="#contact" class="nav-link">Contact</a></li>
                </ul>
                
                <div class="nav-actions">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">Login</a>
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Register</a>
                </div>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero" id="home">
        <div class="container">
            <div class="hero-content">
                <div class="hero-text">
                    <h1 class="hero-title">Professional Learning Management System</h1>
                    <p class="hero-description">
                        A comprehensive platform designed to streamline education delivery, 
                        enhance student engagement, and provide robust administrative tools 
                        for academic institutions.
                    </p>
                    <div class="hero-actions">
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-large">Access LMS</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-secondary btn-large">View Courses</a>
                    </div>
                    <div class="hero-stats">
                        <div class="stat-item">
                            <div class="stat-number"><c:out value="${studentCount}" default="0"/></div>
                            <div class="stat-label">Active Students</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number"><c:out value="${instructorCount}" default="0"/></div>
                            <div class="stat-label">Expert Instructors</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number"><c:out value="${courseCount}" default="0"/></div>
                            <div class="stat-label">Courses Available</div>
                        </div>
                    </div>
                </div>
                <div class="hero-visual">
                    <div class="visual-grid">
                        <div class="visual-item visual-primary"></div>
                        <div class="visual-item visual-secondary"></div>
                        <div class="visual-item visual-accent"></div>
                        <div class="visual-item visual-light"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features" id="features">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Core Features</h2>
                <p class="section-description">
                    Comprehensive tools designed to support every aspect of the learning process
                </p>
            </div>
            
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                            <rect x="5" y="8" width="30" height="24" stroke="currentColor" stroke-width="2"/>
                            <rect x="10" y="13" width="8" height="6" fill="currentColor"/>
                            <rect x="22" y="13" width="8" height="6" fill="currentColor"/>
                            <rect x="10" y="22" width="20" height="2" fill="currentColor"/>
                        </svg>
                    </div>
                    <h3 class="feature-title">Course Management</h3>
                    <p class="feature-description">
                        Organize and manage courses efficiently with structured content delivery, 
                        scheduling, and enrollment tracking.
                    </p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                            <rect x="8" y="8" width="24" height="24" stroke="currentColor" stroke-width="2"/>
                            <path d="M14 20L18 24L26 14" stroke="currentColor" stroke-width="2"/>
                        </svg>
                    </div>
                    <h3 class="feature-title">Online Assessments</h3>
                    <p class="feature-description">
                        Create, distribute, and grade assessments with automated scoring 
                        and detailed performance analytics.
                    </p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                            <rect x="10" y="6" width="20" height="28" stroke="currentColor" stroke-width="2"/>
                            <rect x="14" y="10" width="12" height="2" fill="currentColor"/>
                            <rect x="14" y="16" width="12" height="2" fill="currentColor"/>
                            <rect x="14" y="22" width="8" height="2" fill="currentColor"/>
                        </svg>
                    </div>
                    <h3 class="feature-title">Learning Materials</h3>
                    <p class="feature-description">
                        Share documents, videos, and interactive content with organized 
                        resource libraries and easy access.
                    </p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                            <rect x="6" y="12" width="6" height="20" fill="currentColor"/>
                            <rect x="14" y="8" width="6" height="24" fill="currentColor"/>
                            <rect x="22" y="14" width="6" height="18" fill="currentColor"/>
                            <rect x="30" y="10" width="6" height="22" fill="currentColor"/>
                        </svg>
                    </div>
                    <h3 class="feature-title">Progress Tracking</h3>
                    <p class="feature-description">
                        Monitor student performance with comprehensive analytics, 
                        completion rates, and achievement tracking.
                    </p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                            <rect x="12" y="8" width="16" height="24" stroke="currentColor" stroke-width="2"/>
                            <circle cx="20" cy="18" r="4" fill="currentColor"/>
                            <rect x="16" y="24" width="8" height="6" fill="currentColor"/>
                        </svg>
                    </div>
                    <h3 class="feature-title">Secure Access</h3>
                    <p class="feature-description">
                        Role-based authentication system ensuring data security 
                        and appropriate access controls for all users.
                    </p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                            <rect x="6" y="10" width="28" height="20" stroke="currentColor" stroke-width="2"/>
                            <path d="M6 16H34" stroke="currentColor" stroke-width="2"/>
                            <circle cx="14" cy="22" r="2" fill="currentColor"/>
                            <circle cx="26" cy="22" r="2" fill="currentColor"/>
                        </svg>
                    </div>
                    <h3 class="feature-title">Payment Integration</h3>
                    <p class="feature-description">
                        Secure online payment processing for course enrollment 
                        with automated receipts and transaction tracking.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- Featured Courses Section -->
    <section class="featured-courses" id="featured-courses">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Featured Courses</h2>
                <p class="section-description">Latest approved courses from our instructors</p>
            </div>

            <c:choose>
                <c:when test="${not empty featuredCourses}">
                    <div class="courses-grid">
                        <c:forEach var="course" items="${featuredCourses}">
                            <div class="course-card">
                                <div class="course-header">
                                    <h3 class="course-title"><c:out value="${course.courseName}"/></h3>
                                    <span class="course-level"><c:out value="${course.level}"/></span>
                                </div>
                                <div class="course-body">
                                    <p class="course-category">Category: <c:out value="${course.category}"/></p>
                                    <p class="course-duration">Duration: <c:out value="${course.duration}"/> hours</p>
                                    <p class="course-fee">Fee: <fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2"/></p>
                                </div>
                                <div class="course-actions">
                                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/student/courses">View Details</a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <p>No featured courses available at the moment.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- How It Works Section -->
    <section class="how-it-works" id="how-it-works">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">How the LMS Works</h2>
                <p class="section-description">
                    Simple, efficient process from registration to course completion
                </p>
            </div>
            
            <div class="steps">
                <div class="step">
                    <div class="step-number">01</div>
                    <div class="step-content">
                        <h3 class="step-title">Register & Login</h3>
                        <p class="step-description">
                            Create your account with institutional credentials. 
                            Secure authentication ensures your data protection.
                        </p>
                    </div>
                </div>
                
                <div class="step-connector"></div>
                
                <div class="step">
                    <div class="step-number">02</div>
                    <div class="step-content">
                        <h3 class="step-title">Enroll in Courses</h3>
                        <p class="step-description">
                            Browse available courses, review descriptions, 
                            and enroll in programs aligned with your goals.
                        </p>
                    </div>
                </div>
                
                <div class="step-connector"></div>
                
                <div class="step">
                    <div class="step-number">03</div>
                    <div class="step-content">
                        <h3 class="step-title">Learn & Track Progress</h3>
                        <p class="step-description">
                            Access materials, complete assessments, and monitor 
                            your progress through comprehensive dashboards.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Access Section (Login Connection) -->
    <section class="access-platform" id="access">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Access the Platform</h2>
                <p class="section-description">Select your role and continue to login</p>
            </div>

            <div class="access-grid">
                <div class="access-card">
                    <h3 class="access-title">Students</h3>
                    <p class="access-description">Enroll in approved courses, access materials, and track progress.</p>
                    <div class="access-actions">
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/login?role=student">Login as Student</a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
                    </div>
                </div>

                <div class="access-card">
                    <h3 class="access-title">Instructors</h3>
                    <p class="access-description">Manage courses, upload content, and evaluate student performance.</p>
                    <div class="access-actions">
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/login?role=instructor">Login as Instructor</a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/instructor/courses">Manage Courses</a>
                    </div>
                </div>

                <div class="access-card">
                    <h3 class="access-title">Administrators</h3>
                    <p class="access-description">Oversee operations, manage users, and review approvals.</p>
                    <div class="access-actions">
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/login?role=admin">Login as Admin</a>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/users">Manage Users</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Call to Action Section -->
    <section class="cta">
        <div class="container">
            <div class="cta-content">
                <h2 class="cta-title">Ready to Get Started?</h2>
                <p class="cta-description">
                    Join our learning community and access professional education tools designed for success
                </p>
                <div class="cta-actions">
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-large">Create Account</a>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-large">Login to LMS</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer" id="contact">
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <div class="footer-logo">
                        <span class="logo-text">PSM</span>
                        <span class="logo-subtext">E-Learning</span>
                    </div>
                    <p class="footer-description">
                        Professional Learning Management System designed for academic excellence 
                        and institutional efficiency.
                    </p>
                </div>
                
                <div class="footer-section">
                    <h4 class="footer-title">Quick Links</h4>
                    <ul class="footer-links">
                        <li><a href="#home">Home</a></li>
                        <li><a href="#features">Features</a></li>
                        <li><a href="#how-it-works">How It Works</a></li>
                        <li><a href="${pageContext.request.contextPath}/student/courses">Courses</a></li>
                    </ul>
                </div>
                
                <div class="footer-section">
                    <h4 class="footer-title">Access</h4>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/login">Login</a></li>
                        <li><a href="${pageContext.request.contextPath}/register">Register</a></li>
                        <li><a href="${pageContext.request.contextPath}/student/dashboard">Student Portal</a></li>
                        <li><a href="${pageContext.request.contextPath}/instructor/dashboard">Instructor Portal</a></li>
                    </ul>
                </div>
                
                <div class="footer-section">
                    <h4 class="footer-title">Information</h4>
                    <ul class="footer-links">
                        <li><a href="#about">About</a></li>
                        <li><a href="#contact">Contact</a></li>
                        <li><a href="#privacy">Privacy Policy</a></li>
                        <li><a href="#terms">Terms & Conditions</a></li>
                    </ul>
                </div>
            </div>
            
            <div class="footer-bottom">
                <p class="copyright">
                    &copy; 2025 PSM E-Learning Management System. All rights reserved.
                </p>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/js/landing.js"></script>
</body>
</html>
