<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.courseName}"/> - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-details-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Course Details"/>
<c:set var="topbarSubtitle" value="Review details and choose your next step"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="browse-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main cd-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
            <span>/</span>
            <span><c:out value="${course.courseName}"/></span>
        </div>

        <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}"/>

        <section class="sv-card cd-shell-card">
            <div class="sv-card-head cd-shell-head">
                <div class="cd-shell-copy">
                    <span class="cd-kicker"><i class="fas fa-graduation-cap"></i> Course Details</span>
                    <h2 class="cd-shell-title"><c:out value="${course.courseName}"/></h2>
                </div>
                <div class="sv-inline-actions cd-shell-actions">
                    <c:choose>
                        <c:when test="${isEnrolled}">
                            <span class="sv-chip done cd-chip"><i class="fas fa-check-circle"></i> Enrolled</span>
                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn cd-btn-compact"><i class="fas fa-book"></i> My Courses</a>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" class="cd-inline-form">
                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                        <button type="submit" class="sv-btn primary cd-btn-compact"><i class="fas fa-user-plus"></i> Enroll Free</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="sv-btn primary cd-btn-compact"><i class="fas fa-shopping-cart"></i> Enroll Now</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn cd-btn-compact cd-btn-back"><i class="fas fa-arrow-left"></i> Back</a>
                </div>
            </div>

            <div class="sv-card-body cd-shell-body cd-hero-grid">
                <div>
                    <div class="cd-banner-wrap cd-banner-frame">
                        <c:choose>
                            <c:when test="${not empty course.courseBanner}">
                                <c:choose>
                                    <c:when test="${course.courseBanner.startsWith('http')}">
                                        <img class="cd-banner cd-banner-frame__image" src="${course.courseBanner}" alt="${course.courseName} banner">
                                    </c:when>
                                    <c:otherwise>
                                        <img class="cd-banner cd-banner-frame__image" src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <div class="cd-banner-placeholder cd-banner-frame__placeholder">
                                    <i class="fas fa-image"></i>
                                    <span>No banner uploaded</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="cd-overview-card">
                        <h4 class="cd-section-title"><i class="fas fa-info-circle"></i> Course Overview</h4>
                        <p class="cd-description cd-overview-text"><c:out value="${course.description}"/></p>
                    </div>

                    <div class="cd-instructor-card">
                        <div class="cd-instructor-icon">
                            <i class="fas fa-user-tie"></i>
                        </div>
                        <div class="cd-instructor-copy">
                            <span class="cd-instructor-label">Assigned Instructor</span>
                            <strong class="cd-instructor-name"><c:out value="${instructor.fullName}" default="TBA"/></strong>
                            <span class="cd-instructor-email"><c:out value="${instructor.email}" default="Contact academic advisor"/></span>
                        </div>
                    </div>

                    <div class="cd-meta-grid">
                        <div class="cd-meta-card cd-meta-card--category">
                            <span>Category</span>
                            <strong><c:out value="${course.category}"/></strong>
                        </div>
                        <div class="cd-meta-card cd-meta-card--level">
                            <span>Level</span>
                            <strong><c:out value="${course.level}"/></strong>
                        </div>
                        <div class="cd-meta-card cd-meta-card--duration">
                            <span>Duration</span>
                            <strong><c:out value="${course.displayDuration}"/></strong>
                        </div>
                        <div class="cd-meta-card cd-meta-card--fee">
                            <span>Course Fee</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when>
                                    <c:otherwise>NGN <fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                                </c:choose>
                            </strong>
                        </div>
                    </div>
                </div>

                <aside class="cd-side-panel cd-actions-panel">
                    <div class="cd-actions-head">
                        <div class="cd-actions-icon">
                            <i class="fas fa-shopping-bag"></i>
                        </div>
                        <h3 class="cd-actions-title">Course Actions</h3>
                    </div>
                    <p class="cd-actions-copy">View details, open your courses, and continue learning from one place.</p>

                    <div class="cd-action-stack cd-actions-stack">
                        <a class="sv-btn cd-action-button" href="${pageContext.request.contextPath}/student/my-enrollments">
                            <i class="fas fa-layer-group"></i> My Courses
                        </a>
                        <c:if test="${not isEnrolled}">
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" class="cd-action-form">
                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                        <button type="submit" class="sv-btn primary cd-action-button cd-action-button--primary"><i class="fas fa-user-plus"></i> Enroll Free</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a class="sv-btn primary cd-action-button cd-action-button--primary" href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}">
                                        <i class="fas fa-shopping-cart"></i> Enroll Now
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                    </div>

                    <div class="cd-support-list">
                        <div class="cd-support-item">
                            <i class="fas fa-shield-alt cd-support-icon--success"></i>
                            <span>Secure checkout</span>
                        </div>
                        <div class="cd-support-item">
                            <i class="fas fa-undo-alt cd-support-icon--accent"></i>
                            <span>Access course materials and certificates</span>
                        </div>
                    </div>
                </aside>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
