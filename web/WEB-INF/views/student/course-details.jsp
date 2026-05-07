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

        <section class="sv-card">
            <div class="sv-card-head">
                <h2><c:out value="${course.courseName}"/></h2>
                <div class="sv-inline-actions">
                    <c:choose>
                        <c:when test="${isEnrolled}">
                            <span class="sv-chip done">Enrolled</span>
                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">My Courses</a>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" style="display:inline;">
                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                        <button type="submit" class="sv-btn primary">Enroll for Free</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="sv-btn primary">Enroll Now</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Back</a>
                </div>
            </div>
            <div class="sv-card-body cd-hero-grid">
                <div>
                    <div class="cd-banner-wrap">
                        <c:choose>
                            <c:when test="${not empty course.courseBanner}">
                                <c:choose>
                                    <c:when test="${course.courseBanner.startsWith('http')}">
                                        <img class="cd-banner" src="${course.courseBanner}" alt="${course.courseName} banner">
                                    </c:when>
                                    <c:otherwise>
                                        <img class="cd-banner" src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <div class="cd-banner-placeholder">
                                    <span><i class="fas fa-image"></i> No course banner uploaded</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <p class="cd-description"><c:out value="${course.description}"/></p>
                    <div class="cd-meta-grid">
                        <div class="cd-meta-card"><span>Category</span><strong><c:out value="${course.category}"/></strong></div>
                        <div class="cd-meta-card"><span>Level</span><strong><c:out value="${course.level}"/></strong></div>
                        <div class="cd-meta-card"><span>Duration</span><strong><c:out value="${course.displayDuration}"/></strong></div>
                        <div class="cd-meta-card"><span>Fee</span><strong><c:choose><c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when><c:otherwise><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise></c:choose></strong></div>
                        <div class="cd-meta-card"><span>Instructor</span><strong><c:out value="${instructor.fullName}" default="TBA"/></strong></div>
                        <div class="cd-meta-card"><span>Language</span><strong><c:out value="${course.language}" default="English"/></strong></div>
                    </div>
                </div>
                <aside class="cd-side-panel">
                    <h3>Course Actions</h3>
                    <p>Open supporting resources and continue your enrollment flow from one clear panel.</p>
                    <div class="cd-action-stack">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/my-enrollments"><i class="fas fa-layer-group"></i>&nbsp;Open Learning Hub</a>
                        <c:if test="${not isEnrolled}">
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" style="display:block; width:100%;">
                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                        <button type="submit" class="sv-btn primary" style="width:100%;">Enroll for Free</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}">Proceed to Enroll</a>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
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

