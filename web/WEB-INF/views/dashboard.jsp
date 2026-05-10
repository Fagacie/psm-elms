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
                    <h2>Welcome back, ${sessionScope.userName}</h2>
                    <p>Pick up where you left off or explore something new.</p>
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
                        <div class="sv-progress-bar sd3-progress-bar" data-progress="${overallProgress}"></div>
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
                    </div>
                </div>
            </div>
        </section>

        <section class="sd3-grid">
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
                                                    <div class="sv-progress-bar sd3-progress-bar" data-progress="${courseProgress}"></div>
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


        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/student-dashboard-v3.js"></script>
</body>
</html>
