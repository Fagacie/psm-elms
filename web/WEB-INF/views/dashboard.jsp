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
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
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
            <h1>Student Workspace</h1>
            <p>${dashboardDate}</p>
        </div>
    </div>
    <div class="sv-top-right">
        <div class="sd3-user">
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
            <span>${sessionScope.userName}</span>
        </div>
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
            <span>Student Workspace</span>
        </div>

        <section class="sd3-intro sv-card">
            <div class="sv-card-body">
                <p class="sd3-kicker">Learning Command Center</p>
                <h2>Welcome back, ${sessionScope.userName}</h2>
                <p>Track your course progress, continue learning, review payment-backed enrollments, and stay on top of certificate readiness from one consistent workspace.</p>
            </div>
        </section>

        <section class="sd3-hero sv-card" id="sd3Hero" aria-label="Dashboard highlights">
            <div class="sv-card-body sd3-hero-body">
                <div class="sd3-hero-copy">
                    <h3>Professional Student Workspace</h3>
                    <p>Use your dashboard as the starting point for every action: continue a course, check progress, review achievements, and jump into the next learning step without friction.</p>
                    <div class="sd3-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary">Open My Courses</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse New Courses</a>
                    </div>
                </div>
                <div class="sd3-hero-scene" id="sd3HeroScene" aria-hidden="true">
                    <span class="sd3-orb sd3-orb-a" data-depth="22"></span>
                    <span class="sd3-orb sd3-orb-b" data-depth="16"></span>
                    <span class="sd3-orb sd3-orb-c" data-depth="28"></span>
                    <span class="sd3-shape sd3-shape-a" data-depth="26"></span>
                    <span class="sd3-shape sd3-shape-b" data-depth="14"></span>
                    <span class="sd3-shape sd3-shape-c" data-depth="18"></span>
                </div>
            </div>
        </section>

        <section class="sv-metrics sd3-metrics">
            <article class="sv-metric sd3-tilt">
                <h3 class="sd3-count" data-counter="${enrolledCoursesCount}">${enrolledCoursesCount}</h3>
                <p>Total Enrollments</p>
            </article>
            <article class="sv-metric sd3-tilt">
                <h3 class="sd3-count" data-counter="${activeCoursesCount}">${activeCoursesCount}</h3>
                <p>Active Courses</p>
            </article>
            <article class="sv-metric sd3-tilt">
                <h3 class="sd3-count" data-counter="${completedCoursesCount}">${completedCoursesCount}</h3>
                <p>Completed Courses</p>
            </article>
            <article class="sv-metric sd3-tilt">
                <h3 class="sd3-count" data-counter="${paidEnrollmentsCount}">${paidEnrollmentsCount}</h3>
                <p>Paid Enrollments</p>
            </article>
            <article class="sv-metric sd3-tilt">
                <h3 class="sd3-count" data-counter="${overallProgress}" data-suffix="%">${overallProgress}%</h3>
                <p>Average Progress</p>
            </article>
            <article class="sv-metric sd3-tilt">
                <h3 class="sd3-count" data-counter="${certificatesCount}">${certificatesCount}</h3>
                <p>Certificates Issued</p>
            </article>
        </section>

        <section class="sd3-grid">
            <article class="sv-card sd3-tilt">
                <div class="sv-card-head">
                    <h2>Learning Pipeline</h2>
                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">Open My Courses</a>
                </div>

                <div class="sd3-controlbar" aria-label="Course pipeline filters">
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
                            <div class="sd3-table-wrap">
                                <table class="sd3-table">
                                    <thead>
                                        <tr>
                                            <th>Course</th>
                                            <th>Instructor</th>
                                            <th>Progress</th>
                                            <th>Status</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="course" items="${enrolledCourses}" varStatus="loop">
                                            <c:if test="${loop.index < 6}">
                                                <tr data-status="${course.completionStatus == 'Completed' ? 'done' : (course.completionStatus == 'In Progress' ? 'live' : 'hold')}" data-course="${course.courseName}" class="sd3-row">
                                                    <td>
                                                        <strong>${course.courseName}</strong>
                                                        <small>ID: ${course.courseId}</small>
                                                    </td>
                                                    <td>${course.instructorName}</td>
                                                    <td>
                                                        <div class="sv-progress">
                                                            <div class="sv-progress-bar sd3-progress-bar" data-progress="${not empty course.progress ? course.progress : 0}" style="width:${not empty course.progress ? course.progress : 0}%;"></div>
                                                        </div>
                                                        <small>${not empty course.progress ? course.progress : 0}%</small>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${course.completionStatus == 'Completed'}"><span class="sv-chip done">Completed</span></c:when>
                                                            <c:when test="${course.completionStatus == 'In Progress'}"><span class="sv-chip live">In Progress</span></c:when>
                                                            <c:otherwise><span class="sv-chip hold">Not Started</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">Continue</a>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </c:forEach>
                                    </tbody>
                                </table>
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

            <article class="sv-card sd3-tilt">
                <div class="sv-card-head">
                    <h2>Action Center</h2>
                </div>
                <div class="sv-card-body">
                    <div class="sd3-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sd3-action-item sd3-tilt">
                            <i class="fas fa-play"></i>
                            <div>
                                <h4>Continue Learning</h4>
                                <p>Resume where you stopped in your enrolled courses.</p>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sd3-action-item sd3-tilt">
                            <i class="fas fa-layer-group"></i>
                            <div>
                                <h4>Open Learning Hub</h4>
                                <p>Access materials and assessments directly inside each enrolled course.</p>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/student/certificates" class="sd3-action-item sd3-tilt">
                            <i class="fas fa-medal"></i>
                            <div>
                                <h4>Certificate Status</h4>
                                <p>Review eligibility and download issued certificates.</p>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/profile" class="sd3-action-item sd3-tilt">
                            <i class="fas fa-id-card"></i>
                            <div>
                                <h4>Update Profile</h4>
                                <p>Keep your identity and contact details current.</p>
                            </div>
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
