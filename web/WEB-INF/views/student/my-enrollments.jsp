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
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
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
            <p>Learning hub and enrollment progress</p>
        </div>
    </div>
    <div class="sv-top-right">
        <div class="me-user">
            <span class="me-user-icon"><i class="fas fa-user-graduate"></i></span>
            <div class="me-user-copy">
                <strong>${sessionScope.userName}</strong>
                <span>Student</span>
            </div>
        </div>
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

    <main class="sv-main">
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

        <section class="me-hero" id="meHero" aria-label="My courses highlights">
            <div class="me-hero-copy">
                <p class="me-kicker">Smart Learning Hub</p>
                <h2>Every enrolled course in one focused workspace</h2>
                <p>Track payment state, continue learning, monitor progress, and jump directly into the course hub with a cleaner student workflow.</p>
                <div class="me-hero-actions">
                    <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse New Courses</a>
                    <a href="${pageContext.request.contextPath}/student/certificates" class="sv-btn">Certificates</a>
                </div>
            </div>
            <div class="me-hero-scene" id="meHeroScene" aria-hidden="true">
                <span class="me-orb me-orb-a" data-depth="22"></span>
                <span class="me-orb me-orb-b" data-depth="16"></span>
                <span class="me-orb me-orb-c" data-depth="28"></span>
                <span class="me-shape me-shape-a" data-depth="24"></span>
                <span class="me-shape me-shape-b" data-depth="14"></span>
                <span class="me-shape me-shape-c" data-depth="18"></span>
                <div class="me-scene-panel me-scene-panel-a">
                    <span>Progress Flow</span>
                    <strong>${completedCount} completed</strong>
                </div>
                <div class="me-scene-panel me-scene-panel-b">
                    <span>Payment Ready</span>
                    <strong>${paidCount} paid</strong>
                </div>
            </div>
        </section>

        <section class="sv-metrics">
            <article class="sv-metric me-tilt"><h3 class="me-count" data-counter="${not empty enrollments ? enrollments.size() : 0}">${not empty enrollments ? enrollments.size() : 0}</h3><p>Total Enrolled</p></article>
            <article class="sv-metric me-tilt"><h3 class="me-count" data-counter="${inProgressCount}">${inProgressCount}</h3><p>In Progress</p></article>
            <article class="sv-metric me-tilt"><h3 class="me-count" data-counter="${completedCount}">${completedCount}</h3><p>Completed</p></article>
            <article class="sv-metric me-tilt"><h3 class="me-count" data-counter="${paidCount}">${paidCount}</h3><p>Paid Enrollments</p></article>
        </section>

        <div class="sv-card me-tilt">
            <div class="sv-card-head">
                <h2>Learning Pipeline</h2>
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
                <div class="me-section-intro">
                    <div>
                        <strong>Continue from where you stopped</strong>
                        <p>Your enrolled courses are organized by status so it is easier to return to the right course immediately.</p>
                    </div>
                    <span class="me-section-pill">${not empty enrollments ? enrollments.size() : 0} course(s)</span>
                </div>
                <c:choose>
                    <c:when test="${empty enrollments}">
                        <div class="empty-state-box">
                            <i class="fas fa-graduation-cap"></i>
                            <p>Start your learning journey by enrolling in your first course.</p>
                            <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Courses</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="sv-grid-cards" id="meGrid">
                            <c:forEach var="enrollment" items="${enrollments}">
                                <c:set var="lifecycleStatus" value="${not empty enrollment.completionStatus ? enrollment.completionStatus : (enrollment.status == 'Completed' ? 'Completed' : (enrollment.status == 'Active' || enrollment.status == 'Enrolled' ? 'In Progress' : 'Not Started'))}"/>
                                <c:set var="progress" value="${not empty enrollment.progress ? enrollment.progress : (lifecycleStatus == 'Completed' ? 100 : (lifecycleStatus == 'In Progress' ? 65 : 0))}"/>
                                <article class="sv-course-card me-card me-tilt" data-status="${lifecycleStatus == 'Completed' ? 'done' : (lifecycleStatus == 'In Progress' ? 'live' : 'hold')}" data-course="${enrollment.courseName}" data-instructor="${enrollment.instructorName}">
                                    <div class="sv-course-head">
                                        <h3 class="sv-course-title">${enrollment.courseName}</h3>
                                        <c:choose>
                                            <c:when test="${lifecycleStatus == 'Completed'}"><span class="sv-chip done">Completed</span></c:when>
                                            <c:when test="${lifecycleStatus == 'In Progress'}"><span class="sv-chip live">In Progress</span></c:when>
                                            <c:otherwise><span class="sv-chip hold">Not Started</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <p class="sv-course-line"><i class="fas fa-chalkboard-teacher"></i> ${enrollment.instructorName}</p>
                                    <div class="sv-progress"><div class="sv-progress-bar" data-progress="${progress}" style="width:${progress}%;"></div></div>
                                    <p class="sv-course-line">Progress: ${progress}%</p>
                                    <div class="sv-course-meta">
                                        <div><i class="fas fa-folder-open"></i><span>${materialCountByCourse[enrollment.courseId]} Materials</span></div>
                                        <div><i class="fas fa-clipboard-list"></i><span>${assessmentCountByCourse[enrollment.courseId]} Assessments</span></div>
                                        <div><i class="fas fa-credit-card"></i><span>Payment: ${enrollment.paymentStatus}</span></div>
                                        <div><i class="fas fa-calendar"></i><span>Enrolled: <c:out value="${enrollment.enrollmentDate}" default="-"/></span></div>
                                    </div>
                                    <div class="sv-course-actions">
                                        <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" class="sv-btn primary">Continue</a>
                                        <c:if test="${lifecycleStatus == 'Completed'}">
                                            <a href="${pageContext.request.contextPath}/student/certificates?enrollmentId=${enrollment.enrollmentId}" class="sv-btn">Certificate</a>
                                        </c:if>
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
        </div>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/my-enrollments-v2.js"></script>
</body>
</html>
