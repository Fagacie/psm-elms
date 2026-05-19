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
<c:set var="topbarSubtitle" value="Academic overview and current course progress"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="dashboard"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main sd3-main sd3-dashboard">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>Workspace</span>
        </div>

        <section class="sd3-welcome sv-card">
            <div class="sv-card-body sd3-welcome-body">
                <div class="sd3-welcome-copy">
                    <p class="sd3-kicker">Student workspace</p>
                    <h2>Welcome back, ${sessionScope.userName}</h2>
                    <p class="sd3-subtitle">Review your active courses, track progress, and continue learning from where you left off.</p>
                    <div class="sd3-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary">My Courses</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse Courses</a>
                    </div>
                </div>
                <div class="sd3-welcome-aside">
                    <div class="sd3-welcome-panel">
                        <span>Average progress</span>
                        <strong class="sd3-count" data-counter="${overallProgress}">${overallProgress}%</strong>
                        <p>Across your enrolled courses</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="sv-card sd3-overview-card">
            <div class="sv-card-head">
                <div>
                    <h2>Learning Overview</h2>
                    <p>Key progress indicators from your student account.</p>
                </div>
            </div>
            <div class="sv-card-body">
                <div class="sd3-overview-grid">
                    <article class="sd3-overview-tile">
                        <span class="sd3-metric-lbl">Active Courses</span>
                        <strong class="sd3-count" data-counter="${activeCoursesCount}">${activeCoursesCount}</strong>
                    </article>
                    <article class="sd3-overview-tile">
                        <span class="sd3-metric-lbl">Completed Courses</span>
                        <strong class="sd3-count" data-counter="${completedCoursesCount}">${completedCoursesCount}</strong>
                    </article>
                    <article class="sd3-overview-tile">
                        <span class="sd3-metric-lbl">Certificates</span>
                        <strong class="sd3-count" data-counter="${certificatesCount}">${certificatesCount}</strong>
                    </article>
                    <article class="sd3-overview-tile">
                        <span class="sd3-metric-lbl">Average Progress</span>
                        <strong class="sd3-count" data-counter="${overallProgress}" data-suffix="%">${overallProgress}%</strong>
                    </article>
                </div>
            </div>
        </section>

        <section class="sv-card sd3-continue-card">
            <div class="sv-card-head">
                <div>
                    <h2>Continue Learning</h2>
                    <p>Open an active course and continue from the last saved point.</p>
                </div>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">View all courses</a>
            </div>

            <div class="sv-card-body">
                <c:choose>
                    <c:when test="${not empty enrolledCourses}">
                        <div class="sd3-course-list">
                            <c:forEach var="course" items="${enrolledCourses}" varStatus="loop">
                                <c:if test="${loop.index < 4}">
                                    <c:set var="courseProgress" value="${not empty course.progress ? course.progress : 0}"/>
                                    <c:set var="courseStatus" value="${course.completionStatus == 'Completed' ? 'done' : (course.completionStatus == 'In Progress' ? 'live' : 'hold')}"/>
                                    <article class="sd3-course-row" data-status="${courseStatus}" data-course="${course.courseName}">
                                        <div class="sd3-course-thumb">
                                            <c:choose>
                                                <c:when test="${not empty course.courseBanner}">
                                                    <c:choose>
                                                        <c:when test="${course.courseBanner.startsWith('http')}">
                                                            <img src="${course.courseBanner}" alt="${course.courseName} banner">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner">
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="sd3-course-thumb-empty"><i class="fas fa-book-open"></i></div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="sd3-course-copy">
                                            <div class="sd3-course-header-line">
                                                <h3><c:out value="${course.courseName}"/></h3>
                                                <span class="sd3-course-status ${courseStatus}">${course.completionStatus}</span>
                                            </div>
                                            <p class="sd3-course-line">Instructor: <c:out value="${course.instructorName}"/></p>
                                            <c:if test="${not empty course.displayDuration or course.daysRemaining != null}">
                                                <p class="sd3-course-meta-line">
                                                    <c:if test="${not empty course.displayDuration}">
                                                        Duration: <c:out value="${course.displayDuration}"/>
                                                    </c:if>
                                                    <c:if test="${course.daysRemaining != null}">
                                                        <c:set var="daysLeft" value="${course.daysRemaining}"/>
                                                        <c:choose>
                                                            <c:when test="${daysLeft >= 0}">
                                                                <span>Access ends in ${daysLeft} ${daysLeft == 1 ? 'day' : 'days'}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span>Access ended</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                </p>
                                            </c:if>

                                            <div class="sd3-course-progress-block">
                                                <div class="sv-course-progress-top">
                                                    <span>Progress</span>
                                                    <strong>${courseProgress}%</strong>
                                                </div>
                                                <div class="sv-progress">
                                                    <div class="sv-progress-bar sd3-progress-bar" data-progress="${courseProgress}" style="width: ${courseProgress}%;"></div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="sd3-course-actions-panel">
                                            <a class="sv-btn primary sd3-continue-link" href="${pageContext.request.contextPath}/student/enrollment-details?id=${course.enrollmentId}">Continue</a>
                                        </div>
                                    </article>
                                </c:if>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-box sd3-empty-state">
                            <i class="fas fa-book-open"></i>
                            <p>You do not have active enrollments yet.</p>
                            <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Courses</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/student-dashboard-v3.js"></script>
</body>
</html>
