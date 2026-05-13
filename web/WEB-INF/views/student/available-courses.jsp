<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/browse-courses-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Browse Courses"/>
<c:set var="topbarSubtitle" value="Find courses and start enrollment"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="browse-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main bc-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>Browse Courses</span>
        </div>

        <section class="bc-hero sv-card" style="margin-bottom: 24px; background: linear-gradient(135deg, var(--sv-surface) 0%, var(--sv-surface-soft) 100%); border-radius: 16px;">
            <div class="sv-card-body" style="padding: 24px 28px !important; display: flex; flex-direction: column; gap: 20px;">
                <div class="bc-hero-copy" style="max-width: 800px;">
                    <span style="font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.12em; color: var(--sv-accent); font-weight: 800; display: inline-flex; align-items: center; gap: 6px; margin-bottom: 6px;">
                        <i class="fas fa-compass" style="font-size: 0.8rem;"></i> Course Catalog
                    </span>
                    <h2 style="margin: 0; font-size: clamp(1.5rem, 2.1vw, 2.0rem); font-weight: 800; letter-spacing: -0.03em; line-height: 1.2;">Browse available courses</h2>
                    <p style="margin: 6px 0 0; color: var(--sv-muted); font-size: 0.92rem; line-height: 1.5;">Filter by difficulty, category, or price. Open a course to review the details before enrolling.</p>
                </div>
                
                <div style="display: flex; gap: 12px; flex-wrap: wrap; border-top: 1px solid var(--sv-border); padding-top: 16px;">
                    <div style="display: flex; align-items: center; gap: 10px; background: var(--sv-surface); border: 1px solid var(--sv-border); padding: 8px 14px; border-radius: 10px; min-width: 130px;">
                        <i class="fas fa-book" style="color: var(--sv-accent); font-size: 0.95rem;"></i>
                        <div style="display: flex; flex-direction: column;">
                            <strong class="bc-count" style="font-size: 0.95rem; font-weight: 700; line-height: 1.1;" data-counter="${not empty courses ? courses.size() : 0}">${not empty courses ? courses.size() : 0}</strong>
                            <span style="font-size: 0.65rem; color: var(--sv-muted); text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600;">Available</span>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 10px; background: var(--sv-surface); border: 1px solid var(--sv-border); padding: 8px 14px; border-radius: 10px; min-width: 130px;">
                        <i class="fas fa-user-check" style="color: #10b981; font-size: 0.95rem;"></i>
                        <div style="display: flex; flex-direction: column;">
                            <strong class="bc-count" style="font-size: 0.95rem; font-weight: 700; line-height: 1.1;" data-counter="${not empty enrolledCourseIds ? enrolledCourseIds.size() : 0}">${not empty enrolledCourseIds ? enrolledCourseIds.size() : 0}</strong>
                            <span style="font-size: 0.65rem; color: var(--sv-muted); text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600;">Enrolled</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <c:if test="${not empty param.success}"><div class="alert alert-success">Course enrollment action completed successfully.</div></c:if>
        <c:if test="${not empty param.error}"><div class="alert alert-error">Action failed. Please retry.</div></c:if>

        <section class="sv-card">
            <div class="sv-card-body bc-controlbar" aria-label="Quick browser controls">
                <div class="bc-filter-group">
                    <button type="button" class="bc-filter active" data-filter="all">All</button>
                    <button type="button" class="bc-filter" data-filter="beginner">Beginner</button>
                    <button type="button" class="bc-filter" data-filter="intermediate">Intermediate</button>
                    <button type="button" class="bc-filter" data-filter="advanced">Advanced</button>
                    <button type="button" class="bc-filter" data-filter="enrolled">Enrolled</button>
                </div>
                <div class="bc-search-wrap">
                    <label for="bcQuickSearch" class="bc-sr-only">Quick search courses</label>
                    <input id="bcQuickSearch" type="text" placeholder="Quick search courses..." autocomplete="off" data-search-target="#bcGrid" data-search-item=".bc-card">
                </div>
            </div>
        </section>

        <c:choose>
            <c:when test="${empty courses}">
                <section class="sv-card">
                    <div class="sv-card-body">
                        <div class="empty-state-box">
                            <i class="fas fa-book-open"></i>
                            <h3>No Courses Found</h3>
                            <p>No courses match your current search/filter criteria.</p>
                            <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">View Full Catalog</a>
                        </div>
                    </div>
                </section>
            </c:when>
            <c:otherwise>
                <section class="bc-course-grid" id="bcGrid">
                    <c:forEach var="course" items="${courses}">
                        <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}"/>
                        <article class="bc-card sv-card bc-tilt" data-level="${fn:toLowerCase(course.level)}" data-enrolled="${isEnrolled ? 'yes' : 'no'}" data-course="${course.courseName}" data-category="${course.category}">
                            <div class="bc-card-head">
                                <span class="bc-level-badge level-${fn:toLowerCase(course.level)}">${course.level}</span>
                                <span class="bc-cat">${course.category}</span>
                            </div>
                            <div class="sv-card-body" style="padding-top: 0 !important;">
                                <div class="bc-banner-wrap">
                                        <c:choose>
                                            <c:when test="${not empty course.courseBanner}">
                                                <c:choose>
                                                    <c:when test="${course.courseBanner.startsWith('http')}">
                                                        <img class="bc-banner" src="${course.courseBanner}" alt="${course.courseName} banner">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img class="bc-banner" src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner">
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                            <div class="bc-banner bc-banner-placeholder">
                                                <i class="fas fa-image"></i>
                                                <span>Course Banner</span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <h3 data-search-text style="margin-bottom: 8px !important;"><c:out value="${course.courseName}"/></h3>
                                
                                <p style="margin-top: 10px !important;">
                                    <c:choose>
                                        <c:when test="${not empty course.description && course.description.length() > 120}">${course.description.substring(0, 120)}...</c:when>
                                        <c:otherwise>${course.description}</c:otherwise>
                                    </c:choose>
                                </p>
                                <div class="bc-meta">
                                    <span><i class="fas fa-clock" style="color: #3b82f6;"></i> ${course.displayDuration}</span>
                                    <span><i class="fas fa-wallet" style="color: #10b981;"></i>
                                        <c:choose>
                                            <c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when>
                                            <c:otherwise><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="bc-actions">
                                    <a href="${pageContext.request.contextPath}/student/courses?action=details&id=${course.courseId}" class="sv-btn">Details</a>
                                    <c:choose>
                                        <c:when test="${isEnrolled}">
                                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn" style="background: rgba(16, 185, 129, 0.1); color: #10b981; border-color: rgba(16, 185, 129, 0.2); font-weight: 600;">My Course</a>
                                        </c:when>
                                        <c:otherwise>
                                            <c:choose>
                                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" style="display:inline;" class="bc-free-enroll-form">
                                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                                        <button type="submit" class="sv-btn primary bc-free-enroll-btn">Enroll for Free</button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="sv-btn primary">Enroll</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </section>
                <section class="sv-card bc-empty-hidden" id="bcNoRows">
                    <div class="sv-card-body">
                        <div class="empty-state-box">
                            <i class="fas fa-magnifying-glass"></i>
                            <h3>No Courses Match</h3>
                            <p>Try another quick filter or search term.</p>
                        </div>
                    </div>
                </section>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<!-- Interactive Free Enrollment Glassmorphic Modal Overlay -->
<div class="bc-enroll-overlay" id="bcEnrollOverlay">
    <div class="bc-enroll-modal">
        <div class="bc-modal-loader" id="bcModalLoader">
            <div class="bc-spinner"></div>
            <h3>Securing Your Spot...</h3>
            <p>We are initializing your workspace resources and enrolling you into the course.</p>
        </div>
        <div class="bc-modal-success" id="bcModalSuccess" style="display: none;">
            <div class="bc-success-checkmark">
                <i class="fas fa-circle-check"></i>
            </div>
            <h3>Enrollment Successful!</h3>
            <p>Welcome aboard! Redirecting you directly to your My Courses list...</p>
        </div>
    </div>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/browse-courses-v2.js"></script>
</body>
</html>

