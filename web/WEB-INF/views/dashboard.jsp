<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-dashboard-v3.css">
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
            <h1>Dashboard</h1>
            <p>${dashboardDate}</p>
        </div>
    </div>
    <div class="sv-top-right">
        <a href="${pageContext.request.contextPath}/profile" class="sd3-user">
            <div class="sd3-avatar">
                <c:choose>
                    <c:when test="${not empty student.passportPath}">
                        <c:choose>
                            <c:when test="${student.passportPath.startsWith('http')}">
                                <img src="${student.passportPath}" alt="Profile">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/${student.passportPath}" alt="Profile">
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <i class="fas fa-user"></i>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="sd3-user-copy">
                <strong>${sessionScope.userName}</strong>
                <span>Student workspace</span>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a>
    </div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link active"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main sd3-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>Overview</span>
        </div>

        <section class="sd3-hero sv-card">
            <div class="sv-card-body sd3-hero-body">
                <div class="sd3-hero-copy">
                    <p class="sd3-kicker">Student Workspace</p>
                    <h2>Learn with clarity, track real progress, and keep moving.</h2>
                    <p>Everything important is here: your active courses, current progress, and the next place to continue without distraction.</p>
                    <div class="sd3-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary">My Courses</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse Courses</a>
                    </div>
                </div>
                <div class="sd3-summary-card">
                    <div class="sd3-summary-row">
                        <span>Average Progress</span>
                        <strong>${overallProgress}%</strong>
                    </div>
                    <div class="sv-progress">
                        <div class="sv-progress-bar sd3-progress-bar" data-progress="${overallProgress}" style="width:${overallProgress}%;"></div>
                    </div>
                    <div class="sd3-summary-grid">
                        <div>
                            <span>Active</span>
                            <strong>${activeCoursesCount}</strong>
                        </div>
                        <div>
                            <span>Completed</span>
                            <strong>${completedCoursesCount}</strong>
                        </div>
                        <div>
                            <span>Paid</span>
                            <strong>${paidEnrollmentsCount}</strong>
                        </div>
                        <div>
                            <span>Certificates</span>
                            <strong>${certificatesCount}</strong>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="sv-metrics sd3-metrics">
            <article class="sv-metric">
                <p>Total Enrollments</p>
                <h3 class="sd3-count" data-counter="${enrolledCoursesCount}">${enrolledCoursesCount}</h3>
            </article>
            <article class="sv-metric">
                <p>Active Courses</p>
                <h3 class="sd3-count" data-counter="${activeCoursesCount}">${activeCoursesCount}</h3>
            </article>
            <article class="sv-metric">
                <p>Completed Courses</p>
                <h3 class="sd3-count" data-counter="${completedCoursesCount}">${completedCoursesCount}</h3>
            </article>
            <article class="sv-metric">
                <p>Certificates Issued</p>
                <h3 class="sd3-count" data-counter="${certificatesCount}">${certificatesCount}</h3>
            </article>
        </section>

        <section class="sd3-grid">
            <article class="sv-card">
                <div class="sv-card-head">
                    <div>
                        <h2>Continue Learning</h2>
                        <p class="sd3-head-copy">Your top courses, arranged as reusable product cards instead of a dense table.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">View All</a>
                </div>

                <div class="sd3-controlbar">
                    <div class="sd3-filter-group">
                        <button type="button" class="sd3-filter active" data-filter="all">All</button>
                        <button type="button" class="sd3-filter" data-filter="live">In Progress</button>
                        <button type="button" class="sd3-filter" data-filter="done">Completed</button>
                        <button type="button" class="sd3-filter" data-filter="hold">Not Started</button>
                    </div>
                    <div class="sd3-search-wrap">
                        <label for="sd3CourseSearch" class="sd3-sr-only">Search courses</label>
                        <input id="sd3CourseSearch" type="text" placeholder="Search courses..." autocomplete="off">
                    </div>
                </div>

                <div class="sv-card-body">
                    <c:choose>
                        <c:when test="${not empty enrolledCourses}">
                            <div class="sd3-course-grid">
                                <c:forEach var="course" items="${enrolledCourses}" varStatus="loop">
                                    <c:if test="${loop.index < 6}">
                                        <c:set var="courseProgress" value="${not empty course.progress ? course.progress : 0}"/>
                                        <c:set var="courseStatus" value="${course.completionStatus == 'Completed' ? 'done' : (course.completionStatus == 'In Progress' ? 'live' : 'hold')}"/>
                                        <article class="sv-course-card sd3-row" data-status="${courseStatus}" data-course="${course.courseName}">
                                            <div class="sv-course-media">
                                                <c:choose>
                                                    <c:when test="${not empty course.courseBanner}">
                                                        <c:choose>
                                                            <c:when test="${course.courseBanner.startsWith('http')}">
                                                                <img class="sv-course-banner" src="${course.courseBanner}" alt="${course.courseName} banner">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img class="sv-course-banner" src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner">
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
                                            <div class="sv-course-copy">
                                                <h3 class="sv-course-title">${course.courseName}</h3>
                                                <p class="sv-course-line">Instructor: ${course.instructorName}</p>
                                            </div>
                                            <div class="sv-course-progress-block">
                                                <div class="sv-course-progress-top">
                                                    <span>Progress</span>
                                                    <strong>${courseProgress}%</strong>
                                                </div>
                                                <div class="sv-progress">
                                                    <div class="sv-progress-bar sd3-progress-bar" data-progress="${courseProgress}" style="width:${courseProgress}%;"></div>
                                                </div>
                                            </div>
                                            <div class="sv-course-actions">
                                                <button type="button" class="sv-btn primary sd3-continue-link" data-href="${pageContext.request.contextPath}/student/enrollment-details?id=${course.enrollmentId}">Continue</button>
                                            </div>
                                        </article>
                                    </c:if>
                                </c:forEach>
                            </div>
                            <div class="empty-state-box sd3-empty-hidden" id="sd3NoRows">
                                <i class="fas fa-magnifying-glass"></i>
                                <p>No courses match your current filter or search.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state-box">
                                <i class="fas fa-book-open"></i>
                                <p>You do not have active enrollments yet.</p>
                                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Courses</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </article>

            <article class="sv-card">
                <div class="sv-card-head">
                    <h2>Quick Actions</h2>
                </div>
                <div class="sv-card-body">
                    <div class="sd3-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sd3-action-item">
                            <strong>My Courses</strong>
                            <p>Return to your enrolled courses and continue learning.</p>
                        </a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sd3-action-item">
                            <strong>Browse Courses</strong>
                            <p>Discover new courses and expand your path.</p>
                        </a>
                        <a href="${pageContext.request.contextPath}/student/certificates" class="sd3-action-item">
                            <strong>Certificates</strong>
                            <p>Review issued certificates and readiness status.</p>
                        </a>
                        <a href="${pageContext.request.contextPath}/profile" class="sd3-action-item">
                            <strong>Settings</strong>
                            <p>Update your profile and manage account details.</p>
                        </a>
                    </div>
                </div>
            </article>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/student-dashboard-v3.js"></script>
</body>
</html>
