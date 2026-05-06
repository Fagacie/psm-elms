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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/my-enrollments-v2.css">
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

        <section class="me-hero sv-card">
            <div class="sv-card-body me-hero-body">
                <div class="me-hero-copy">
                    <h2>My Courses</h2>
                    <p>Track progress and continue learning.</p>
                    <div class="me-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse New Courses</a>
                    </div>
                </div>
                <div class="me-hero-summary">
                    <div>
                        <span>Total Enrolled</span>
                        <strong>${not empty enrollments ? enrollments.size() : 0}</strong>
                    </div>
                    <div>
                        <span>In Progress</span>
                        <strong>${inProgressCount}</strong>
                    </div>
                    <div>
                        <span>Completed</span>
                        <strong>${completedCount}</strong>
                    </div>
                    <div>
                        <span>Paid Enrollments</span>
                        <strong>${paidCount}</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="sv-metrics me-metrics">
            <article class="sv-metric"><p>Total Enrolled</p><h3 class="me-count" data-counter="${not empty enrollments ? enrollments.size() : 0}">${not empty enrollments ? enrollments.size() : 0}</h3></article>
            <article class="sv-metric"><p>In Progress</p><h3 class="me-count" data-counter="${inProgressCount}">${inProgressCount}</h3></article>
            <article class="sv-metric"><p>Completed</p><h3 class="me-count" data-counter="${completedCount}">${completedCount}</h3></article>
            <article class="sv-metric"><p>Paid Enrollments</p><h3 class="me-count" data-counter="${paidCount}">${paidCount}</h3></article>
        </section>

        <section class="sv-card">
            <div class="sv-card-head">
                <div>
                    <h2>Course Grid</h2>
                    <p class="me-head-copy">Card-based courses with clear progress, status, and the next action.</p>
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
                    <input id="meCourseSearch" type="text" placeholder="Search by course or instructor..." autocomplete="off" data-search-target="#meGrid" data-search-item=".me-card">
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
                        <div class="sv-grid-cards me-grid" id="meGrid">
                            <c:forEach var="enrollment" items="${enrollments}">
                                <c:set var="lifecycleStatus" value="${not empty enrollment.completionStatus ? enrollment.completionStatus : (enrollment.status == 'Completed' ? 'Completed' : (enrollment.status == 'Active' || enrollment.status == 'Enrolled' ? 'In Progress' : 'Not Started'))}"/>
                                <c:set var="progress" value="${not empty enrollment.progress ? enrollment.progress : (lifecycleStatus == 'Completed' ? 100 : (lifecycleStatus == 'In Progress' ? 65 : 0))}"/>
                                <c:set var="enrollmentPaid" value="${enrollment.paymentStatus == 'Paid' || enrollment.paymentStatus == 'Completed' || enrollment.paymentStatus == 'COMPLETED' || enrollment.paymentStatus == 'Success' || enrollment.paymentStatus == 'SUCCESS'}"/>
                                <c:set var="courseAccessGranted" value="${enrollmentPaid || enrollment.coursePrice == null || enrollment.coursePrice <= 0}"/>
                                <article class="sv-course-card me-card" data-status="${lifecycleStatus == 'Completed' ? 'done' : (lifecycleStatus == 'In Progress' ? 'live' : 'hold')}" data-course="${enrollment.courseName}" data-instructor="${enrollment.instructorName}">
                                    <div class="sv-course-media">
                                        <c:choose>
                                            <c:when test="${not empty enrollment.courseBanner}">
                                                <c:choose>
                                                    <c:when test="${enrollment.courseBanner.startsWith('http')}">
                                                        <img class="sv-course-banner" src="${enrollment.courseBanner}" alt="${enrollment.courseName} banner">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img class="sv-course-banner" src="${pageContext.request.contextPath}/${enrollment.courseBanner}" alt="${enrollment.courseName} banner">
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="sv-course-banner-placeholder">
                                                    <i class="fas fa-book-open"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="me-card-top">
                                        <span class="sv-chip ${lifecycleStatus == 'Completed' ? 'done' : 'status-Pending'}">${lifecycleStatus}</span>
                                        <span class="sv-chip ${courseAccessGranted ? 'done' : 'status-Pending'}">${courseAccessGranted && !enrollmentPaid ? 'Free Course' : (empty enrollment.paymentStatus ? 'Pending' : enrollment.paymentStatus)}</span>
                                    </div>
                                    <div class="sv-course-copy">
                                        <h3 class="sv-course-title" data-search-text>${enrollment.courseName}</h3>
                                        <p class="sv-course-line" data-search-text>Instructor: ${enrollment.instructorName}</p>
                                    </div>

                                    <div class="sv-course-progress-block">
                                        <div class="sv-course-progress-top">
                                            <span>Progress</span>
                                            <strong>${progress}%</strong>
                                        </div>
                                        <div class="sv-progress"><div class="sv-progress-bar" data-progress="${progress}" style="width:${progress}%;"></div></div>
                                    </div>

                                    <div class="me-card-footer">
                                        <div class="me-card-meta">
                                            <span>${progress}% complete</span>
                                            <span>#${enrollment.enrollmentId}</span>
                                        </div>
                                        <a class="sv-btn primary me-continue-link" href="${courseAccessGranted ? pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrollment.enrollmentId) : pageContext.request.contextPath.concat('/student/payment?enrollmentId=').concat(enrollment.enrollmentId).concat('&error=required')}">${courseAccessGranted ? 'Continue' : 'Pay Now'}</a>
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
