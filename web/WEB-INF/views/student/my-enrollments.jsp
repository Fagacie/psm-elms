<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/my-enrollments-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand">
            <span class="sv-brand-main">PSM</span>
            <span class="sv-brand-sub">E-Learning</span>
        </a>
        <div class="sv-page-title">
            <h1>My Courses</h1>
            <p>All active learning paths in one place</p>
        </div>
    </div>
    <div class="sv-top-right">
        <a href="${pageContext.request.contextPath}/profile" class="me-user">
            <span class="me-user-icon"><i class="fas fa-user-graduate"></i></span>
            <div class="me-user-copy">
                <strong>${sessionScope.userName}</strong>
                <span>Student</span>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a>
    </div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link active"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

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
                    <p class="me-kicker">Course Library</p>
                    <h2>Your enrolled courses, arranged clearly and professionally.</h2>
                    <p>Track progress, review payment status, and return to the right course without clutter or unnecessary visual noise.</p>
                    <div class="me-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse New Courses</a>
                        <a href="${pageContext.request.contextPath}/student/certificates" class="sv-btn primary">Certificates</a>
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
                    <input id="meCourseSearch" type="text" placeholder="Search by course or instructor..." autocomplete="off">
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
                                        <span class="sv-chip ${enrollment.paymentStatus == 'Paid' ? 'done' : 'status-Pending'}">${empty enrollment.paymentStatus ? 'Pending' : enrollment.paymentStatus}</span>
                                    </div>
                                    <div class="sv-course-copy">
                                        <h3 class="sv-course-title">${enrollment.courseName}</h3>
                                        <p class="sv-course-line">Instructor: ${enrollment.instructorName}</p>
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
                                        <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" class="sv-btn primary">Continue</a>
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
