<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.courseName}"/> - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-details-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Course Details</h1><p>Review and continue course flow</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/profile" class="sv-profile-link"><i class="fas fa-user"></i><span>${sessionScope.userName}</span></a><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
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

    <main class="sv-main cd-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
            <span>/</span>
            <span><c:out value="${course.courseName}"/></span>
        </div>

        <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}"/>

        <section class="sv-card">
            <div class="sv-card-head">
                <h2><c:out value="${course.courseName}"/></h2>
                <div class="sv-inline-actions">
                    <c:choose>
                        <c:when test="${isEnrolled}">
                            <span class="sv-chip done">Enrolled</span>
                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">My Courses</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="sv-btn primary">Enroll Now</a>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Back</a>
                </div>
            </div>
            <div class="sv-card-body cd-hero-grid">
                <div>
                    <div class="cd-banner-wrap">
                        <c:choose>
                            <c:when test="${not empty course.courseBanner}">
                                <c:choose>
                                    <c:when test="${course.courseBanner.startsWith('http')}">
                                        <img class="cd-banner" src="${course.courseBanner}" alt="${course.courseName} banner">
                                    </c:when>
                                    <c:otherwise>
                                        <img class="cd-banner" src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <div class="cd-banner-placeholder">
                                    <span><i class="fas fa-image"></i> No course banner uploaded</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <p class="cd-description"><c:out value="${course.description}"/></p>
                    <div class="cd-meta-grid">
                        <div class="cd-meta-card"><span>Category</span><strong><c:out value="${course.category}"/></strong></div>
                        <div class="cd-meta-card"><span>Level</span><strong><c:out value="${course.level}"/></strong></div>
                        <div class="cd-meta-card"><span>Duration</span><strong><c:out value="${course.duration}"/> hours</strong></div>
                        <div class="cd-meta-card"><span>Fee</span><strong><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong></div>
                        <div class="cd-meta-card"><span>Instructor</span><strong><c:out value="${instructor.fullName}" default="TBA"/></strong></div>
                        <div class="cd-meta-card"><span>Language</span><strong><c:out value="${course.language}" default="English"/></strong></div>
                    </div>
                </div>
                <aside class="cd-side-panel">
                    <h3>Course Actions</h3>
                    <p>Open supporting resources, review assessments, or continue your enrollment flow from one clear panel.</p>
                    <div class="cd-action-stack">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?courseId=${course.courseId}"><i class="fas fa-folder-open"></i>&nbsp;Materials</a>
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?courseId=${course.courseId}"><i class="fas fa-clipboard-list"></i>&nbsp;Assessments</a>
                        <c:if test="${not isEnrolled}">
                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}">Proceed to Enroll</a>
                        </c:if>
                    </div>
                </aside>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

