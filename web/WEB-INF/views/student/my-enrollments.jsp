<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <!-- Uses both browse-courses and my-enrollments stylesheets to guarantee size, layout, badges, and hover sync -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/my-enrollments-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/browse-courses-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="My Courses"/>
<c:set var="topbarSubtitle" value="Track active courses and continue learning"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main me-page">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>My Courses</span>
        </div>

        <c:if test="${param.message == 'alreadypaid'}">
            <div class="alert alert-success">
                <i class="fas fa-circle-check"></i> This enrollment has already been paid and is ready in your learning workspace.
            </div>
        </c:if>
        <c:if test="${param.error == 'notfound' || param.error == 'invalid'}">
            <div class="alert alert-error">
                <i class="fas fa-triangle-exclamation"></i> We could not find that enrollment. Please open it again from your course list.
            </div>
        </c:if>
        <c:if test="${param.error == 'unauthorized' || param.error == 'permission'}">
            <div class="alert alert-error">
                <i class="fas fa-shield-halved"></i> You do not have permission to access that enrollment.
            </div>
        </c:if>
        <c:if test="${param.error == 'exception'}">
            <div class="alert alert-error">
                <i class="fas fa-circle-exclamation"></i> Something interrupted the enrollment flow. Please try again.
            </div>
        </c:if>

        <section class="sv-card" style="margin-top: 24px;">
            <div class="sv-card-head">
                <div>
                    <h2>My Courses</h2>
                    <p style="margin: 4px 0 0; color: var(--sv-muted); font-size: 0.9rem;">Track your courses, review progress, and resume learning.</p>
                </div>
                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary"><i class="fas fa-search"></i>&nbsp;Browse Courses</a>
            </div>

            <div class="me-controlbar" aria-label="Course pipeline controls">
                <div class="me-filter-group">
                    <button type="button" class="me-filter active" data-filter="all">All</button>
                    <button type="button" class="me-filter" data-filter="live">In Progress</button>
                    <button type="button" class="me-filter" data-filter="done">Completed</button>
                    <button type="button" class="me-filter" data-filter="hold">Not Started</button>
                </div>
                <div class="me-search-wrap">
                    <label for="meCourseSearch" class="me-sr-only">Search courses</label>
                    <input id="meCourseSearch" type="text" placeholder="Search by course or instructor..." autocomplete="off" data-search-target="#meGrid" data-search-item=".bc-card">
                </div>
            </div>

            <div class="sv-card-body">
                <c:choose>
                    <c:when test="${empty enrollments}">
                        <div class="empty-state-box">
                            <i class="fas fa-graduation-cap"></i>
                            <p>Start your learning journey by enrolling in your first course.</p>
                            <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Courses</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="bc-course-grid me-grid" id="meGrid">
                            <c:forEach var="enrollment" items="${enrollments}">
                                <c:set var="lifecycleStatus" value="${not empty enrollment.completionStatus ? enrollment.completionStatus : (enrollment.status == 'Completed' ? 'Completed' : (enrollment.status == 'Active' || enrollment.status == 'Enrolled' ? 'In Progress' : 'Not Started'))}"/>
                                <c:set var="progress" value="${not empty enrollment.progress ? enrollment.progress : (lifecycleStatus == 'Completed' ? 100 : (lifecycleStatus == 'In Progress' ? 65 : 0))}"/>
                                <c:set var="enrollmentPaid" value="${enrollment.paymentStatus == 'Paid' || enrollment.paymentStatus == 'Completed' || enrollment.paymentStatus == 'COMPLETED' || enrollment.paymentStatus == 'Success' || enrollment.paymentStatus == 'SUCCESS'}"/>
                                <c:set var="courseAccessGranted" value="${enrollmentPaid || enrollment.coursePrice == null || enrollment.coursePrice <= 0}"/>
                                
                                <!-- Card matches Browse Courses exactly in styling -->
                                <article class="bc-card sv-card bc-tilt" data-status="${lifecycleStatus == 'Completed' ? 'done' : (lifecycleStatus == 'In Progress' ? 'live' : 'hold')}" data-course="${enrollment.courseName}" data-instructor="${enrollment.instructorName}">
                                    <div class="bc-card-head" style="padding: 18px 18px 0 !important;">
                                        <span class="bc-level-badge level-${fn:toLowerCase(enrollment.level)}">${not empty enrollment.level ? enrollment.level : 'Beginner'}</span>
                                        <span class="bc-cat">${enrollment.category}</span>
                                    </div>
                                    <div class="sv-card-body" style="padding-top: 0 !important;">
                                        <div class="bc-banner-wrap">
                                            <c:choose>
                                                <c:when test="${not empty enrollment.courseBanner}">
                                                    <c:choose>
                                                        <c:when test="${enrollment.courseBanner.startsWith('http')}">
                                                            <img class="bc-banner" src="${enrollment.courseBanner}" alt="${enrollment.courseName} banner">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img class="bc-banner" src="${pageContext.request.contextPath}/${enrollment.courseBanner}" alt="${enrollment.courseName} banner">
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bc-banner bc-banner-placeholder">
                                                        <i class="fas fa-book-open"></i>
                                                        <span>Course Banner</span>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <h3 data-search-text style="margin-bottom: 6px !important;"><c:out value="${enrollment.courseName}"/></h3>
                                        <p class="sv-course-line" data-search-text style="font-size: 0.84rem; color: var(--sv-muted); margin: 0 0 12px;">Instructor: <c:out value="${enrollment.instructorName}"/></p>
                                        
                                        <!-- Custom Progress bar with dynamic coloring -->
                                        <div class="sv-course-progress-block" style="margin-bottom: 12px;">
                                            <div class="sv-course-progress-top" style="display:flex; justify-content:space-between; font-size:0.78rem; font-weight:600; color:var(--sv-muted); margin-bottom:4px;">
                                                <span>Progress</span>
                                                <strong>${progress}%</strong>
                                            </div>
                                            <div class="sv-progress" style="height:6px; border-radius:999px; background:var(--sv-border); overflow:hidden;">
                                                <div class="sv-progress-bar" style="height:100%; width: ${progress}%; background: ${progress < 35 ? '#ef4444' : (progress < 75 ? '#eab308' : '#10b981')}; transition:width 0.4s ease;"></div>
                                            </div>
                                        </div>

                                        <div class="bc-meta" style="margin-top: 10px !important;">
                                            <c:if test="${not empty enrollment.displayDuration}">
                                                <span><i class="fas fa-clock" style="color: #3b82f6;"></i> ${enrollment.displayDuration}</span>
                                                <c:set var="daysLeft" value="${enrollment.daysRemaining}"/>
                                                <c:if test="${daysLeft >= 0}">
                                                    <span style="color: ${daysLeft <= 2 ? '#ef4444' : '#10b981'}; margin-left: auto; font-weight: 700;">
                                                        ${daysLeft} ${daysLeft == 1 ? 'day' : 'days'} remaining
                                                    </span>
                                                </c:if>
                                                <c:if test="${daysLeft < 0 && not empty enrollment.courseDuration && enrollment.courseDuration > 0}">
                                                    <span style="color: #ef4444; margin-left: auto; font-weight: 700;">
                                                        Expired
                                                    </span>
                                                </c:if>
                                            </c:if>
                                        </div>
                                        <div class="bc-actions" style="margin-top: 14px !important;">
                                            <a class="sv-btn primary me-continue-link" style="width:100%; text-align:center;" href="${courseAccessGranted ? pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrollment.enrollmentId) : pageContext.request.contextPath.concat('/student/payment?enrollmentId=').concat(enrollment.enrollmentId).concat('&error=required')}">${courseAccessGranted ? 'Continue' : 'Pay Now'}</a>
                                        </div>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                        <div class="empty-state-box me-empty-hidden" id="meNoRows">
                            <i class="fas fa-magnifying-glass"></i>
                            <p>No courses match your filter or search term.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/my-enrollments-v2.js"></script>
</body>
</html>
