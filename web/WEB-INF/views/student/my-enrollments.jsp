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
                    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
                    <!-- Link the advanced interactive My Courses layout stylesheet -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/my-enrollments-v3.css">
                </head>

                <body class="sv-page">
                    <c:set var="topbarTitle" value="My Courses" />
                    <c:set var="topbarSubtitle" value="Track active courses and continue learning" />
                    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

                    <div class="sv-layout">
                        <c:set var="activePage" value="my-courses" />
                        <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

                        <main class="sv-main me-page">
                            <div class="sv-breadcrumb">
                                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i>
                                    Dashboard</a>
                                <span>/</span>
                                <span>My Courses</span>
                            </div>

                            <c:if test="${param.message == 'alreadypaid'}">
                                <div class="alert alert-success">
                                    <i class="fas fa-circle-check"></i> This enrollment has already been paid and is
                                    ready in your learning workspace.
                                </div>
                            </c:if>
                            <c:if test="${param.error == 'notfound' || param.error == 'invalid'}">
                                <div class="alert alert-error">
                                    <i class="fas fa-triangle-exclamation"></i> We could not find that enrollment.
                                    Please open it again from your course list.
                                </div>
                            </c:if>
                            <c:if test="${param.error == 'unauthorized' || param.error == 'permission'}">
                                <div class="alert alert-error">
                                    <i class="fas fa-shield-halved"></i> You do not have permission to access that
                                    enrollment.
                                </div>
                            </c:if>
                            <c:if test="${param.error == 'exception'}">
                                <div class="alert alert-error">
                                    <i class="fas fa-circle-exclamation"></i> Something interrupted the enrollment flow.
                                    Please try again.
                                </div>
                            </c:if>

                            <!-- Main Page Header Row (No Outer Section Card!) -->
                            <div class="me-header-row">
                                <div>
                                    <h1>My Courses</h1>
                                    <p class="me-card-intro">Track your courses, review progress, and resume learning.
                                    </p>
                                </div>
                                <div class="me-head-actions">
                                    <a href="${pageContext.request.contextPath}/student/payments" class="sv-btn"><i
                                            class="fas fa-receipt"></i>&nbsp;Payments</a>
                                    <a href="${pageContext.request.contextPath}/student/courses"
                                        class="sv-btn primary"><i class="fas fa-search"></i>&nbsp;Browse Courses</a>
                                </div>
                            </div>

                            <!-- Horizontal "Second Header" Summary Strip -->
                            <div class="me-metrics-strip">
                                <div class="me-metric-tile">
                                    <div class="me-metric-icon-wrap"><i class="fas fa-book-open"></i></div>
                                    <div class="me-metric-body">
                                        <span class="me-metric-label">Total Courses</span>
                                        <strong class="me-metric-value">${not empty enrollments ? enrollments.size() :
                                            0}</strong>
                                    </div>
                                </div>
                                <div class="me-metric-tile me-metric-tile--blue">
                                    <div class="me-metric-icon-wrap"><i class="fas fa-circle-play"></i></div>
                                    <div class="me-metric-body">
                                        <span class="me-metric-label">In Progress</span>
                                        <strong class="me-metric-value">${inProgressCount}</strong>
                                    </div>
                                </div>
                                <div class="me-metric-tile me-metric-tile--green">
                                    <div class="me-metric-icon-wrap"><i class="fas fa-circle-check"></i></div>
                                    <div class="me-metric-body">
                                        <span class="me-metric-label">Completed</span>
                                        <strong class="me-metric-value">${completedCount}</strong>
                                    </div>
                                </div>
                                <div class="me-metric-tile me-metric-tile--amber">
                                    <div class="me-metric-icon-wrap"><i class="fas fa-wallet"></i></div>
                                    <div class="me-metric-body">
                                        <span class="me-metric-label">Paid Courses</span>
                                        <strong class="me-metric-value">${paidCount}</strong>
                                    </div>
                                </div>
                            </div>

                            <!-- Premium Sticky Full-Width Controls Bar -->
                            <div class="me-sticky-bar" id="meStickyBar">
                                <div class="me-controls-left">
                                    <!-- Layout Toggle buttons with A11y attributes -->
                                    <div class="me-view-toggles" role="group" aria-label="Layout view switcher">
                                        <button type="button" id="toggleGridBtn" class="me-toggle-btn active"
                                            aria-pressed="true" aria-label="Switch to grid view" title="Grid View">
                                            <i class="fas fa-th-large"></i>
                                        </button>
                                        <button type="button" id="toggleListBtn" class="me-toggle-btn"
                                            aria-pressed="false" aria-label="Switch to list view" title="List View">
                                            <i class="fas fa-list"></i>
                                        </button>
                                    </div>

                                    <!-- Asynchronous Status Filter Chips -->
                                    <div class="me-filter-chips" role="group" aria-label="Filter courses by status">
                                        <button type="button" class="me-filter-chip active" data-status="all"
                                            aria-pressed="true">All</button>
                                        <button type="button" class="me-filter-chip" data-status="live"
                                            aria-pressed="false">In Progress</button>
                                        <button type="button" class="me-filter-chip" data-status="done"
                                            aria-pressed="false">Completed</button>
                                        <button type="button" class="me-filter-chip" data-status="hold"
                                            aria-pressed="false">Not Started</button>
                                    </div>
                                </div>

                                <div class="me-controls-right">
                                    <!-- Client-side Sorting Select -->
                                    <div class="me-sort-box">
                                        <select id="meLibrarySort" aria-label="Sort courses">
                                            <option value="default">Default Order</option>
                                            <option value="progress-desc">Highest Progress</option>
                                            <option value="progress-asc">Lowest Progress</option>
                                            <option value="title-asc">Title (A-Z)</option>
                                        </select>
                                    </div>

                                    <!-- Instant client-side course search input -->
                                    <div class="me-search-box">
                                        <i class="fas fa-search search-icon"></i>
                                        <input type="text" id="meLibrarySearch" placeholder="Search course..."
                                            aria-label="Search courses" autocomplete="off">
                                        <button type="button" id="clearSearchBtn" class="me-clear-btn"
                                            aria-label="Clear search input">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- A11y Live region target for screen reader notifications -->
                            <div id="meA11yLive" class="me-sr-only" aria-live="polite"></div>

                            <c:choose>
                                <c:when test="${empty enrollments}">
                                    <div class="empty-state-box">
                                        <i class="fas fa-graduation-cap"></i>
                                        <p>Start your learning journey by enrolling in your first course.</p>
                                        <a href="${pageContext.request.contextPath}/student/courses"
                                            class="sv-btn primary">Browse Courses</a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <!-- Main Library Container (Full width, single column, responsive visual grid) -->
                                    <div class="me-library-container me-view-grid" id="meLibrary">
                                        <c:forEach var="enrollment" items="${enrollments}">
                                            <c:set var="lifecycleStatus"
                                                value="${not empty enrollment.completionStatus ? enrollment.completionStatus : (enrollment.status == 'Completed' ? 'Completed' : (enrollment.status == 'Active' || enrollment.status == 'Enrolled' ? 'In Progress' : 'Not Started'))}" />
                                            <c:set var="progress"
                                                value="${not empty enrollment.progress ? enrollment.progress : (lifecycleStatus == 'Completed' ? 100 : 0)}" />
                                            <c:set var="enrollmentPaid"
                                                value="${enrollment.paymentStatus == 'Paid' || enrollment.paymentStatus == 'Completed' || enrollment.paymentStatus == 'COMPLETED' || enrollment.paymentStatus == 'Success' || enrollment.paymentStatus == 'SUCCESS'}" />
                                            <c:set var="courseAccessGranted"
                                                value="${enrollmentPaid || enrollment.coursePrice == null || enrollment.coursePrice <= 0}" />
                                            <c:set var="progressTone"
                                                value="${progress < 35 ? 'is-low' : (progress < 75 ? 'is-mid' : 'is-high')}" />
                                            <c:set var="daysLeft" value="${enrollment.daysRemaining}" />
                                            <c:set var="continueUrl"
                                                value="${courseAccessGranted ? pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrollment.enrollmentId) : pageContext.request.contextPath.concat('/student/payment?enrollmentId=').concat(enrollment.enrollmentId).concat('&error=required')}" />

                                            <!-- Sleek, Compact, Fully-Clickable Course Item Card -->
                                            <a class="me-course-item" href="${continueUrl}"
                                                data-status="${lifecycleStatus == 'Completed' ? 'done' : (lifecycleStatus == 'In Progress' ? 'live' : 'hold')}"
                                                data-title="${fn:toLowerCase(enrollment.courseName)}"
                                                data-instructor="${fn:toLowerCase(enrollment.instructorName)}"
                                                data-progress="${progress}"
                                                data-enrollment-id="${enrollment.enrollmentId}"
                                                aria-label="Continue course: ${enrollment.courseName}">

                                                <!-- 1. Sleek, Low-Profile Visual Banner Area -->
                                                <div class="me-item-visual">
                                                    <c:choose>
                                                        <c:when test="${not empty enrollment.courseBanner}">
                                                            <c:choose>
                                                                <c:when
                                                                    test="${enrollment.courseBanner.startsWith('http')}">
                                                                    <img class="me-item-banner"
                                                                        src="${enrollment.courseBanner}" alt="">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <img class="me-item-banner"
                                                                        src="${pageContext.request.contextPath}/${enrollment.courseBanner}"
                                                                        alt="">
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="me-item-banner-placeholder">
                                                                <i class="fas fa-book-open"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <!-- Floating Translucent Expiry Badge -->
                                                    <c:if test="${daysLeft >= 0}">
                                                        <span
                                                            class="me-expiry-pill ${daysLeft <= 2 ? 'is-urgent' : 'is-healthy'}">
                                                            ${daysLeft}d left
                                                        </span>
                                                    </c:if>
                                                    <c:if
                                                        test="${daysLeft < 0 && not empty enrollment.courseDuration && enrollment.courseDuration > 0}">
                                                        <span class="me-expiry-pill is-expired">
                                                            Expired
                                                        </span>
                                                    </c:if>

                                                    <!-- Floating Certified Gold Badge for Completed Items -->
                                                    <c:if test="${lifecycleStatus == 'Completed'}">
                                                        <span class="me-certified-badge">
                                                            <i class="fas fa-certificate"></i> Certified
                                                        </span>
                                                    </c:if>

                                                    <!-- Glassmorphic Hover Play Overlay -->
                                                    <div class="me-play-overlay">
                                                        <span class="me-play-btn">
                                                            <i class="fas fa-circle-play"></i> ${courseAccessGranted ?
                                                            'Resume' : 'Pay Now'}
                                                        </span>
                                                    </div>
                                                </div>

                                                <!-- 2. Integrated Horizontal Meta + SVG Progress -->
                                                <div class="me-item-body">
                                                    <div class="me-item-details">
                                                        <h3 class="me-item-title">
                                                            <c:out value="${enrollment.courseName}" />
                                                        </h3>
                                                        <p class="me-item-instructor">By <strong>
                                                                <c:out value="${enrollment.instructorName}" />
                                                            </strong></p>
                                                    </div>

                                                    <div class="me-item-progress">
                                                        <div class="me-svg-circle-wrap">
                                                            <!-- Reduced footprint: 48px visual SVG Progress Ring -->
                                                            <svg class="me-progress-svg" width="48" height="48"
                                                                viewBox="0 0 48 48">
                                                                <circle class="me-svg-circle-bg" cx="24" cy="24" r="20"
                                                                    stroke-width="4.5" fill="none" />
                                                                <circle class="me-svg-circle-fg ${progressTone}" cx="24"
                                                                    cy="24" r="20" stroke-width="4.5" fill="none"
                                                                    stroke-dasharray="125.66" stroke-dashoffset="125.66"
                                                                    data-progress="${progress}" />
                                                            </svg>
                                                            <div class="me-progress-svg-text">
                                                                <strong>${progress}%</strong>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </a>
                                        </c:forEach>
                                    </div>

                                    <!-- Client-Side Search Fallback Container -->
                                    <div class="empty-state-box me-empty-hidden" id="meNoRows">
                                        <i class="fas fa-magnifying-glass"></i>
                                        <p>No courses match your filter or search term.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </main>
                    </div>

                    <div class="sv-overlay" id="svOverlay"></div>
                    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
                    <!-- Link the new advanced interactive course listing engine -->
                    <script src="${pageContext.request.contextPath}/js/my-enrollments-v3.js"></script>
                </body>

                </html>