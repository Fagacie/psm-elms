<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-dashboard-v3.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Dashboard"/>
<c:set var="topbarSubtitle" value="${dashboardDate}"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="dashboard"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main sd3-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>Overview</span>
        </div>

        <section class="sd3-hero sv-card">
            <div class="sv-card-body sd3-hero-body">
                <div class="sd3-hero-copy">
                    <h2 id="dynamicGreeting">Welcome back, ${sessionScope.userName}</h2>
                    <p class="sd3-quote-line" id="sd3QuoteLine">"The expert in anything was once a beginner."</p>
                    <div class="sd3-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary">My Courses</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse Courses</a>
                    </div>
                </div>
                <div class="sd3-hero-stats-quick">
                    <div class="sd3-stat-circle-wrap">
                        <svg class="sd3-stat-circle" viewBox="0 0 36 36">
                            <path class="circle-bg" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
                            <path class="circle" stroke-dasharray="${overallProgress}, 100" stroke="${overallProgress < 35 ? '#ef4444' : (overallProgress < 75 ? '#eab308' : '#10b981')}" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
                        </svg>
                        <div class="sd3-stat-circle-text">
                            <strong>${overallProgress}%</strong>
                            <span>Avg Progress</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Asymmetrical Two Column Layout Grid -->
        <div class="sd3-asym-grid">
            <!-- Left Main Column (65% width) -->
            <div class="sd3-col-main">
                <article class="sv-card">
                    <div class="sv-card-head">
                        <div>
                            <h2>Continue Learning</h2>
                            <p class="sd3-head-copy">Resume your active coursework from one focused workspace.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">View All</a>
                    </div>

                    <div class="sv-card-body">
                        <c:choose>
                            <c:when test="${not empty enrolledCourses}">
                                <div class="sd3-course-grid-modern">
                                    <c:forEach var="course" items="${enrolledCourses}" varStatus="loop">
                                        <c:if test="${loop.index < 4}">
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
                                                    <h3 class="sv-course-title"><c:out value="${course.courseName}"/></h3>
                                                    <p class="sv-course-line">Instructor: <c:out value="${course.instructorName}"/></p>
                                                    <c:if test="${not empty course.displayDuration}">
                                                        <div class="sv-course-duration-badge" style="font-size: 0.72rem; color: #64748b; margin-top: 6px; display: flex; align-items: center; gap: 4px;">
                                                            <i class="far fa-clock" style="color: #3b82f6;"></i>
                                                            <span>Duration: <strong><c:out value="${course.displayDuration}"/></strong></span>
                                                            <c:set var="daysLeft" value="${course.daysRemaining}"/>
                                                            <c:if test="${daysLeft >= 0}">
                                                                <span style="color: ${daysLeft <= 2 ? '#ef4444' : '#10b981'}; margin-left: auto; font-weight: 600;">
                                                                    ⏳ ${daysLeft} ${daysLeft == 1 ? 'day' : 'days'} left
                                                                </span>
                                                            </c:if>
                                                            <c:if test="${daysLeft < 0 && not empty course.courseDuration && course.courseDuration > 0}">
                                                                <span style="color: #ef4444; margin-left: auto; font-weight: 600;">
                                                                    ⚠️ Expired
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                    </c:if>
                                                </div>
                                                <div class="sv-course-progress-block">
                                                    <div class="sv-course-progress-top">
                                                        <span>Progress</span>
                                                        <strong>${courseProgress}%</strong>
                                                    </div>
                                                    <div class="sv-progress">
                                                        <div class="sv-progress-bar sd3-progress-bar" data-progress="${courseProgress}" style="width: ${courseProgress}%; background: ${courseProgress < 35 ? '#ef4444' : (courseProgress < 75 ? '#eab308' : '#10b981')};"></div>
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
            </div>

            <!-- Right Sidebar Column (35% width) -->
            <div class="sd3-col-sidebar">
                <!-- Academic Stats Summary Panel -->
                <article class="sv-card sd3-sidebar-card">
                    <div class="sv-card-head">
                        <h2>Course Summary</h2>
                    </div>
                    <div class="sv-card-body">
                        <div class="sd3-summary-grid-compact">
                            <div class="sd3-summary-metric">
                                <span class="sd3-metric-lbl">Total Enrolled</span>
                                <strong class="sd3-metric-val">${enrolledCoursesCount}</strong>
                            </div>
                            <div class="sd3-summary-metric">
                                <span class="sd3-metric-lbl">Active</span>
                                <strong class="sd3-metric-val" style="color: #3b82f6;">${activeCoursesCount}</strong>
                            </div>
                            <div class="sd3-summary-metric">
                                <span class="sd3-metric-lbl">Completed</span>
                                <strong class="sd3-metric-val" style="color: #10b981;">${completedCoursesCount}</strong>
                            </div>
                            <div class="sd3-summary-metric">
                                <span class="sd3-metric-lbl">Certificates</span>
                                <strong class="sd3-metric-val" style="color: #eab308;">${certificatesCount}</strong>
                            </div>
                        </div>
                    </div>
                </article>

                <!-- Milestone Achievements & Badge Gallery -->
                <article class="sv-card sd3-sidebar-card">
                    <div class="sv-card-head">
                        <h2>Your Achievements</h2>
                    </div>
                    <div class="sv-card-body">
                        <div class="sd3-badge-gallery">
                            <div class="sd3-badge-item ${enrolledCoursesCount > 0 ? 'unlocked' : 'locked'}" title="Enrolled in your first course!">
                                <div class="sd3-badge-icon"><i class="fas fa-graduation-cap" style="color: var(--sv-accent);"></i></div>
                                <div class="sd3-badge-info">
                                    <strong>First Step</strong>
                                    <span>Enrolled</span>
                                </div>
                            </div>
                            <div class="sd3-badge-item ${completedCoursesCount > 0 ? 'unlocked' : 'locked'}" title="Finished at least one course!">
                                <div class="sd3-badge-icon"><i class="fas fa-trophy" style="color: #f59e0b;"></i></div>
                                <div class="sd3-badge-info">
                                    <strong>Finisher</strong>
                                    <span>Course Done</span>
                                </div>
                            </div>
                            <div class="sd3-badge-item ${overallProgress >= 50 ? 'unlocked' : 'locked'}" title="Average progress is 50% or more!">
                                <div class="sd3-badge-icon"><i class="fas fa-bolt" style="color: #10b981;"></i></div>
                                <div class="sd3-badge-info">
                                    <strong>Consistent</strong>
                                    <span>50%+ Done</span>
                                </div>
                            </div>
                            <div class="sd3-badge-item ${certificatesCount > 0 ? 'unlocked' : 'locked'}" title="Earned an official certificate of completion!">
                                <div class="sd3-badge-icon"><i class="fas fa-award" style="color: #8b5cf6;"></i></div>
                                <div class="sd3-badge-info">
                                    <strong>Scholar</strong>
                                    <span>Certified</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </article>

                <!-- Expiration Alert & Study Calendar Reminders -->
                <article class="sv-card sd3-sidebar-card">
                    <div class="sv-card-head">
                        <h2>Study Timeline</h2>
                    </div>
                    <div class="sv-card-body">
                        <c:set var="hasReminders" value="false"/>
                        <div class="sd3-timeline-list">
                            <c:forEach var="course" items="${enrolledCourses}">
                                <c:set var="days" value="${course.daysRemaining}"/>
                                <c:if test="${days >= 0 && days <= 5}">
                                    <c:set var="hasReminders" value="true"/>
                                    <div class="sd3-timeline-item warning">
                                        <div class="sd3-timeline-marker"><i class="fas fa-hourglass-half" style="color: #f59e0b;"></i></div>
                                        <div class="sd3-timeline-content">
                                            <strong>Access Ending</strong>
                                            <span><c:out value="${course.courseName}"/> ends in ${days} ${days == 1 ? 'day' : 'days'}!</span>
                                        </div>
                                    </div>
                                </c:if>
                                <c:if test="${days < 0 && not empty course.courseDuration && course.courseDuration > 0}">
                                    <c:set var="hasReminders" value="true"/>
                                    <div class="sd3-timeline-item expired">
                                        <div class="sd3-timeline-marker"><i class="fas fa-triangle-exclamation" style="color: #ef4444;"></i></div>
                                        <div class="sd3-timeline-content">
                                            <strong>Course Expired</strong>
                                            <span><c:out value="${course.courseName}"/> is now in read-only mode.</span>
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                            <c:if test="${not hasReminders}">
                                <div class="sd3-timeline-empty">
                                    <div class="sd3-timeline-empty-icon"><i class="fas fa-check-circle" style="color: #10b981; font-size: 1.5rem;"></i></div>
                                    <p>All clear! No urgent timelines approaching.</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </article>
            </div>
        </div>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/student-dashboard-v3.js"></script>
</body>
</html>
