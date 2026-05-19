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
<c:set var="topbarSubtitle" value="Academic overview and course progress"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="dashboard"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main sd3-main sd3-dashboard">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
        </div>

        <div class="sd3-single-layout">
            <%-- Welcome Banner Card --%>
            <section class="sd3-welcome-banner">
                <div class="sd3-welcome-banner__content">
                    <span class="sd3-welcome-banner__kicker"><i class="fas fa-graduation-cap"></i> Academic Portal</span>
                    <h1 class="sd3-welcome-banner__title" id="sd3DynamicGreeting">Welcome back, ${sessionScope.userName}</h1>
                    <p class="sd3-welcome-banner__subtitle">Track your academic progress, resume active lectures, and manage credentials.</p>
                    <div class="sd3-welcome-banner__actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary"><i class="fas fa-book-open"></i> Resume Learning</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn secondary-btn"><i class="fas fa-compass"></i> Explore Catalog</a>
                    </div>
                </div>
                <div class="sd3-welcome-banner__visual">
                    <div class="sd3-welcome-progress-card">
                        <span class="sd3-progress-card__label">Average Progress</span>
                        <strong class="sd3-progress-card__value sd3-count" data-counter="${overallProgress}" data-suffix="%">${overallProgress}%</strong>
                        <div class="sd3-progress-card__bar-wrap">
                            <div class="sd3-progress-card__bar" style="width: ${overallProgress}%;"></div>
                        </div>
                    </div>
                </div>
            </section>

            <%-- In Progress Courses --%>
            <section class="sd3-courses-section">
                <div class="sd3-section-header">
                    <div>
                        <h2>Continue Learning</h2>
                        <p>Resume your recent course lectures and modules.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sd3-header-link">View All <i class="fas fa-arrow-right-long"></i></a>
                </div>

                <c:choose>
                    <c:when test="${not empty enrolledCourses}">
                        <div class="sd3-course-grid">
                            <c:forEach var="course" items="${enrolledCourses}" varStatus="loop">
                                <c:if test="${loop.index < 3}">
                                    <c:set var="courseProgress" value="${not empty course.progress ? course.progress : 0}"/>
                                    <c:set var="courseStatus" value="${course.completionStatus == 'Completed' ? 'done' : (course.completionStatus == 'In Progress' ? 'live' : 'hold')}"/>
                                    <article class="sd3-course-card" data-status="${courseStatus}">
                                        <div class="sd3-course-card__banner">
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
                                                    <div class="sd3-course-card__banner-empty"><i class="fas fa-book-open"></i></div>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="sd3-course-card__status ${courseStatus}">${course.completionStatus}</span>
                                        </div>

                                        <div class="sd3-course-card__body">
                                            <h3 class="sd3-course-card__title"><c:out value="${course.courseName}"/></h3>
                                            <p class="sd3-course-card__instructor">Instructor: <strong><c:out value="${course.instructorName}"/></strong></p>
                                            
                                            <div class="sd3-course-card__progress-wrap">
                                                <div class="sd3-course-card__progress-info">
                                                    <span>Progress</span>
                                                    <strong>${courseProgress}%</strong>
                                                </div>
                                                <div class="sv-progress">
                                                    <div class="sv-progress-bar" data-progress="${courseProgress}" style="width: ${courseProgress}%;"></div>
                                                </div>
                                            </div>

                                            <div class="sd3-course-card__actions">
                                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${course.enrollmentId}">
                                                    <i class="fas fa-play"></i> Resume
                                                </a>
                                            </div>
                                        </div>
                                    </article>
                                </c:if>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="sd3-empty-state">
                            <div class="sd3-empty-state__icon"><i class="fas fa-graduation-cap"></i></div>
                            <h3>No Active Courses</h3>
                            <p>You aren't enrolled in any active courses. Explore the catalog to get started.</p>
                            <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Catalog</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <%-- Bottom Row (Credentials + Quick Actions) --%>
            <div class="sd3-bottom-row">
                <%-- Achievements Milestone --%>
                <section class="sd3-sidebar-panel">
                    <h3 class="sd3-sidebar-panel__title">Credentials</h3>
                    <c:choose>
                        <c:when test="${certificatesCount > 0}">
                            <div class="sd3-credentials-box">
                                <div class="sd3-credentials-badge"><i class="fas fa-certificate"></i></div>
                                <h4>Earned Certificates</h4>
                                <p>You have earned <strong>${certificatesCount}</strong> official certificate(s) for completing courses.</p>
                                <a href="${pageContext.request.contextPath}/student/certificates" class="sv-btn secondary-btn">View Certificates</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="sd3-credentials-box is-locked">
                                <div class="sd3-credentials-badge"><i class="fas fa-lock"></i></div>
                                <h4>Complete a Course</h4>
                                <p>Unlock official, shareable certificates by finishing all course lessons and passing assessments.</p>
                                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn secondary-btn">View Catalog</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>

                <%-- Quick Actions Panel --%>
                <section class="sd3-sidebar-panel">
                    <h3 class="sd3-sidebar-panel__title">Quick Management</h3>
                    <div class="sd3-sidebar-actions">
                        <a class="sd3-sidebar-action" href="${pageContext.request.contextPath}/student/certificates">
                            <i class="fas fa-scroll"></i>
                            <div>
                                <strong>Certificates</strong>
                                <span>Manage earned credentials</span>
                            </div>
                        </a>
                        <a class="sd3-sidebar-action" href="${pageContext.request.contextPath}/student/payments">
                            <i class="fas fa-receipt"></i>
                            <div>
                                <strong>Billing & Receipts</strong>
                                <span>Review purchases and history</span>
                            </div>
                        </a>
                        <a class="sd3-sidebar-action" href="${pageContext.request.contextPath}/student/profile">
                            <i class="fas fa-user-gear"></i>
                            <div>
                                <strong>Profile Settings</strong>
                                <span>Manage profile & preferences</span>
                            </div>
                        </a>
                    </div>
                </section>
            </div>
        </div>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/student-dashboard-v3.js"></script>
</body>
</html>
