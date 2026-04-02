<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Enrollment Summary - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Enrollment Summary</h1><p>Review before payment</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link active"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main ef-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
            <span>/</span>
            <span>Enrollment Summary</span>
        </div>

        <div class="ef-stepper">
            <div class="ef-step active">1. Enrollment Summary</div>
            <div class="ef-step">2. Payment</div>
            <div class="ef-step">3. Access Learning Hub</div>
        </div>

        <c:if test="${empty course}">
            <section class="sv-card"><div class="sv-card-body"><div class="empty-state-box"><i class="fas fa-folder-open"></i><h3>Course details not available</h3><p>Return to the catalog and pick a course.</p><a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Courses</a></div></div></section>
        </c:if>

        <c:if test="${not empty course}">
            <section class="ef-course">
                <h3>${course.courseName}</h3>
                <p>${course.description}</p>

                <div class="ef-grid">
                    <div class="ef-meta"><span>Category</span><strong><c:out value="${course.category}" default="General"/></strong></div>
                    <div class="ef-meta"><span>Level</span><strong><c:out value="${course.level}" default="General"/></strong></div>
                    <div class="ef-meta"><span>Duration</span><strong><c:out value="${course.duration}" default="0"/> hours</strong></div>
                </div>

                <div class="ef-amount"><span>Total Fee</span><strong><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong></div>

                <form method="post" action="${pageContext.request.contextPath}/student/enroll">
                    <input type="hidden" name="courseId" value="${course.courseId}" />
                    <div class="ef-actions">
                        <button type="submit" class="sv-btn primary">Proceed to Payment</button>
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/courses">Cancel</a>
                    </div>
                </form>
            </section>
        </c:if>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
