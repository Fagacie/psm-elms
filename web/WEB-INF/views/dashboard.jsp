<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Student Dashboard - PSM E-Learning</title>
            <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-dashboard-v3.css">
        </head>

        <body class="sv-page">
            <c:set var="topbarTitle" value="Dashboard" />
            <c:set var="topbarSubtitle" value="Academic overview and course progress" />
            <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

            <div class="sv-layout">
                <c:set var="activePage" value="dashboard" />
                <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

                <main class="sv-main sd3-main sd3-dashboard">
                    <div class="sv-breadcrumb">
                        <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i>
                            Dashboard</a>
                    </div>

                    <div class="sd3-single-layout">
                        <%-- Welcome Banner Card --%>
                            <section class="sd3-welcome-banner" aria-labelledby="sd3DynamicGreeting">
                                <div class="sd3-welcome-banner__content">
                                    <span class="sd3-welcome-banner__kicker"><i class="fas fa-graduation-cap"></i>
                                        Academic Portal</span>
                                    <h1 class="sd3-welcome-banner__title" id="sd3DynamicGreeting">Welcome back,
                                        ${sessionScope.userName}</h1>
                                    <p class="sd3-welcome-banner__subtitle">Track your academic progress, resume active
                                        lectures, and manage credentials.</p>
                                    <div class="sd3-welcome-banner__actions">
                                        <a href="${pageContext.request.contextPath}/student/my-enrollments"
                                            class="sv-btn primary"><i class="fas fa-book-open"></i> Resume Learning</a>
                                        <a href="${pageContext.request.contextPath}/student/courses"
                                            class="sv-btn secondary-btn"><i class="fas fa-compass"></i> Explore
                                            Catalog</a>
                                        <button type="button" class="sv-btn secondary-btn" id="btnCustomizeLayout"
                                            aria-expanded="false" aria-controls="sd3CustomizerPanel">
                                            <i class="fas fa-sliders" aria-hidden="true"></i> Customize Layout
                                        </button>
                                    </div>
                                </div>
                                <div class="sd3-welcome-banner__visual">
                                    <div class="sd3-welcome-progress-card">
                                        <span class="sd3-progress-card__label">Average Progress</span>
                                        <div class="sd3-progress-circle-wrapper">
                                            <svg class="sd3-progress-circle" width="100" height="100"
                                                viewBox="0 0 100 100"
                                                aria-label="Overall progress indicator: ${overallProgress}%">
                                                <circle class="sd3-progress-circle-bg" cx="50" cy="50" r="40"
                                                    stroke-width="8" fill="transparent" />
                                                <circle class="sd3-progress-circle-fg" cx="50" cy="50" r="40"
                                                    stroke-width="8" fill="transparent" stroke-dasharray="251.2"
                                                    stroke-dashoffset="251.2" data-progress="${overallProgress}" />
                                            </svg>
                                            <div class="sd3-progress-circle-text">
                                                <strong class="sd3-progress-card__value sd3-count"
                                                    data-counter="${overallProgress}"
                                                    data-suffix="%">${overallProgress}%</strong>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <%-- Customize Layout Control Panel --%>
                                <section class="sd3-customizer-panel" id="sd3CustomizerPanel" style="display: none;"
                                    aria-label="Layout customization options">
                                    <div class="sd3-customizer-panel__header">
                                        <h4><i class="fas fa-sliders" aria-hidden="true"></i> Customize Your Dashboard
                                            Layout</h4>
                                        <p>Drag the widgets by their handles to reorder, or toggle visibility using the
                                            switches below.</p>
                                    </div>
                                    <div class="sd3-customizer-panel__body">
                                        <div class="sd3-customizer-toggle-group">
                                            <label class="sd3-custom-switch">
                                                <input type="checkbox" id="toggle-widget-courses" checked>
                                                <span class="sd3-switch-slider"></span>
                                                <span class="sd3-switch-label">Continue Learning</span>
                                            </label>
                                            <label class="sd3-custom-switch">
                                                <input type="checkbox" id="toggle-widget-credentials" checked>
                                                <span class="sd3-switch-slider"></span>
                                                <span class="sd3-switch-label">Credentials</span>
                                            </label>
                                            <label class="sd3-custom-switch">
                                                <input type="checkbox" id="toggle-widget-quicknav" checked>
                                                <span class="sd3-switch-slider"></span>
                                                <span class="sd3-switch-label">Quick Management</span>
                                            </label>
                                        </div>
                                        <div class="sd3-customizer-actions">
                                            <button type="button" class="sv-btn secondary-btn" id="btnResetLayout"><i
                                                    class="fas fa-rotate-left" aria-hidden="true"></i> Reset</button>
                                            <button type="button" class="sv-btn primary" id="btnSaveLayout"><i
                                                    class="fas fa-check" aria-hidden="true"></i> Done</button>
                                        </div>
                                    </div>
                                </section>

                                <%-- Widget container for drag and drop sorting --%>
                                    <div class="sd3-widgets-container" id="sd3WidgetsContainer" role="list"
                                        aria-label="Draggable Dashboard Widgets">

                                        <%-- Widget: Enrolled Courses --%>
                                            <section class="sd3-widget sd3-courses-section" id="widget-courses"
                                                data-widget-id="widget-courses" role="listitem"
                                                aria-roledescription="draggable dashboard widget" tabindex="0">
                                                <div class="sd3-widget-header-wrapper">
                                                    <div class="sd3-widget-drag-handle"
                                                        title="Drag to reorder Continue Learning widget"
                                                        aria-hidden="true">
                                                        <i class="fas fa-grip-vertical"></i>
                                                    </div>
                                                    <div class="sd3-section-header">
                                                        <div>
                                                            <h2>Continue Learning</h2>
                                                            <p>Resume your recent course lectures and modules.</p>
                                                        </div>
                                                        <a href="${pageContext.request.contextPath}/student/my-enrollments"
                                                            class="sd3-header-link">View All <i
                                                                class="fas fa-arrow-right-long"
                                                                aria-hidden="true"></i></a>
                                                    </div>
                                                </div>

                                                <c:choose>
                                                    <c:when test="${not empty enrolledCourses}">
                                                        <div class="sd3-course-grid">
                                                            <c:forEach var="course" items="${enrolledCourses}"
                                                                varStatus="loop">
                                                                <c:if test="${loop.index < 3}">
                                                                    <c:set var="courseProgress"
                                                                        value="${not empty course.progress ? course.progress : 0}" />
                                                                    <c:set var="courseStatus"
                                                                        value="${course.completionStatus == 'Completed' ? 'done' : (course.completionStatus == 'In Progress' ? 'live' : 'hold')}" />
                                                                    <c:set var="continueUrl"
                                                                        value="${pageContext.request.contextPath}/student/enrollment-details?id=${course.enrollmentId}" />

                                                                    <!-- Sleek, Clickable Dashboard Course Card Anchor -->
                                                                    <a class="sd3-course-card" href="${continueUrl}"
                                                                        data-status="${courseStatus}"
                                                                        aria-label="Resume course: ${course.courseName}">
                                                                        <div class="sd3-course-card__banner">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${not empty course.courseBanner}">
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${course.courseBanner.startsWith('http')}">
                                                                                            <img src="${course.courseBanner}"
                                                                                                alt="">
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <img src="${pageContext.request.contextPath}/${course.courseBanner}"
                                                                                                alt="">
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <div
                                                                                        class="sd3-course-card__banner-empty">
                                                                                        <i class="fas fa-book-open"
                                                                                            aria-hidden="true"></i>
                                                                                    </div>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                            <span
                                                                                class="sd3-course-card__status ${courseStatus}">${course.completionStatus}</span>

                                                                            <!-- Glassmorphic Hover Play Overlay -->
                                                                            <div class="sd3-play-overlay">
                                                                                <span class="sd3-play-btn">
                                                                                    <i class="fas fa-circle-play"></i>
                                                                                    Resume
                                                                                </span>
                                                                            </div>
                                                                        </div>

                                                                        <div class="sd3-course-card__body">
                                                                            <div class="sd3-course-card__details">
                                                                                <h3 class="sd3-course-card__title">
                                                                                    <c:out
                                                                                        value="${course.courseName}" />
                                                                                </h3>
                                                                                <p class="sd3-course-card__instructor">
                                                                                    By <strong>
                                                                                        <c:out
                                                                                            value="${course.instructorName}" />
                                                                                    </strong></p>
                                                                            </div>

                                                                            <div
                                                                                class="sd3-course-card__progress-wrap-circular">
                                                                                <div
                                                                                    class="sd3-course-progress-circle-compact">
                                                                                    <svg class="sd3-compact-circle"
                                                                                        width="48" height="48"
                                                                                        viewBox="0 0 48 48">
                                                                                        <circle
                                                                                            class="sd3-compact-circle-bg"
                                                                                            cx="24" cy="24" r="18"
                                                                                            stroke-width="4.5"
                                                                                            fill="transparent" />
                                                                                        <circle
                                                                                            class="sd3-compact-circle-fg"
                                                                                            cx="24" cy="24" r="18"
                                                                                            stroke-width="4.5"
                                                                                            fill="transparent"
                                                                                            stroke-dasharray="113.1"
                                                                                            stroke-dashoffset="113.1"
                                                                                            data-progress="${courseProgress}" />
                                                                                    </svg>
                                                                                    <div
                                                                                        class="sd3-compact-circle-text">
                                                                                        ${courseProgress}%</div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </a>
                                                                </c:if>
                                                            </c:forEach>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="sd3-empty-state">
                                                            <div class="sd3-empty-state__icon"><i
                                                                    class="fas fa-graduation-cap"
                                                                    aria-hidden="true"></i></div>
                                                            <h3>No Active Courses</h3>
                                                            <p>You aren't enrolled in any active courses. Explore the
                                                                catalog to get started.</p>
                                                            <a href="${pageContext.request.contextPath}/student/courses"
                                                                class="sv-btn primary">Browse Catalog</a>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </section>

                                            <%-- Widget: Credentials achievements --%>
                                                <section class="sd3-widget sd3-sidebar-panel" id="widget-credentials"
                                                    data-widget-id="widget-credentials" role="listitem"
                                                    aria-roledescription="draggable dashboard widget" tabindex="0">
                                                    <div class="sd3-widget-header-wrapper">
                                                        <div class="sd3-widget-drag-handle"
                                                            title="Drag to reorder Credentials widget"
                                                            aria-hidden="true">
                                                            <i class="fas fa-grip-vertical"></i>
                                                        </div>
                                                        <h3 class="sd3-sidebar-panel__title">Credentials</h3>
                                                    </div>
                                                    <c:choose>
                                                        <c:when test="${certificatesCount > 0}">
                                                            <div class="sd3-credentials-box">
                                                                <div class="sd3-credentials-badge"><i
                                                                        class="fas fa-certificate"
                                                                        aria-hidden="true"></i></div>
                                                                <h4>Earned Certificates</h4>
                                                                <p>You have earned <strong>${certificatesCount}</strong>
                                                                    official certificate(s) for completing courses.</p>
                                                                <a href="${pageContext.request.contextPath}/student/certificates"
                                                                    class="sv-btn secondary-btn">View Certificates</a>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="sd3-credentials-box is-locked">
                                                                <div class="sd3-credentials-badge"><i
                                                                        class="fas fa-lock" aria-hidden="true"></i>
                                                                </div>
                                                                <h4>Complete a Course</h4>
                                                                <p>Unlock official, shareable certificates by finishing
                                                                    all course lessons and passing assessments.</p>
                                                                <a href="${pageContext.request.contextPath}/student/courses"
                                                                    class="sv-btn secondary-btn">View Catalog</a>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </section>

                                                <%-- Widget: Quick management --%>
                                                    <section class="sd3-widget sd3-sidebar-panel" id="widget-quicknav"
                                                        data-widget-id="widget-quicknav" role="listitem"
                                                        aria-roledescription="draggable dashboard widget" tabindex="0">
                                                        <div class="sd3-widget-header-wrapper">
                                                            <div class="sd3-widget-drag-handle"
                                                                title="Drag to reorder Quick Management widget"
                                                                aria-hidden="true">
                                                                <i class="fas fa-grip-vertical"></i>
                                                            </div>
                                                            <h3 class="sd3-sidebar-panel__title">Quick Management</h3>
                                                        </div>
                                                        <div class="sd3-sidebar-actions">
                                                            <a class="sd3-sidebar-action"
                                                                href="${pageContext.request.contextPath}/student/certificates">
                                                                <i class="fas fa-scroll" aria-hidden="true"></i>
                                                                <div>
                                                                    <strong>Certificates</strong>
                                                                    <span>Manage earned credentials</span>
                                                                </div>
                                                            </a>
                                                            <a class="sd3-sidebar-action"
                                                                href="${pageContext.request.contextPath}/student/payments">
                                                                <i class="fas fa-receipt" aria-hidden="true"></i>
                                                                <div>
                                                                    <strong>Billing & Receipts</strong>
                                                                    <span>Review purchases and history</span>
                                                                </div>
                                                            </a>
                                                            <a class="sd3-sidebar-action"
                                                                href="${pageContext.request.contextPath}/student/profile">
                                                                <i class="fas fa-user-gear" aria-hidden="true"></i>
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

            <%-- Screen-reader live region for accessible announcements during widget movement --%>
                <div id="sd3A11yLive" class="sr-only" aria-live="polite"
                    style="position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); border: 0;">
                </div>

                <div class="sv-overlay" id="svOverlay"></div>
                <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
                <script src="${pageContext.request.contextPath}/js/student-dashboard-v3.js"></script>
        </body>

        </html>