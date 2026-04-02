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
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Course Details</h1><p>Review and continue course flow</p></div>
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

    <main class="sv-main">
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
            <div class="sv-card-body">
                <div class="sv-course-banner-wrap" style="margin-bottom:14px;">
                    <c:choose>
                        <c:when test="${not empty course.courseBanner}">
                            <img src="${course.courseBanner}" alt="${course.courseName} banner" style="width:100%;max-height:260px;object-fit:cover;border:1px solid #2a486d;">
                        </c:when>
                        <c:otherwise>
                            <div style="height:220px;border:1px solid #2a486d;background:linear-gradient(180deg, rgba(14, 30, 50, 0.86), rgba(8, 18, 31, 0.9));display:flex;align-items:center;justify-content:center;color:#a7bed8;">
                                <span><i class="fas fa-image"></i> No course banner uploaded</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <p class="sv-course-line"><c:out value="${course.description}"/></p>
                <div class="sv-course-meta sv-course-meta-3">
                    <div><i class="fas fa-folder"></i><span><c:out value="${course.category}"/></span></div>
                    <div><i class="fas fa-signal"></i><span><c:out value="${course.level}"/></span></div>
                    <div><i class="fas fa-clock"></i><span><c:out value="${course.duration}"/> hours</span></div>
                    <div><i class="fas fa-money-bill-wave"></i><span><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span></div>
                    <div><i class="fas fa-chalkboard-teacher"></i><span><c:out value="${instructor.fullName}" default="TBA"/></span></div>
                    <div><i class="fas fa-language"></i><span><c:out value="${course.language}" default="English"/></span></div>
                </div>
                <div class="sv-course-actions sv-course-actions-top">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?courseId=${course.courseId}"><i class="fas fa-folder-open"></i>&nbsp;Materials</a>
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?courseId=${course.courseId}"><i class="fas fa-clipboard-list"></i>&nbsp;Assessments</a>
                </div>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
