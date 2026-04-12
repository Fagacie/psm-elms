<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Enrollment Summary - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Enrollment Summary"/>
<c:set var="topbarSubtitle" value="Confirm course details before payment"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="browse-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main ef-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
            <span>/</span>
            <span>Enrollment Summary</span>
        </div>

        <div class="ef-stepper">
            <div class="ef-step active">1. Enrollment Summary</div>
            <div class="ef-step">2. Payment</div>
            <div class="ef-step">3. Access Learning Hub</div>
        </div>

        <c:if test="${empty course}">
            <section class="sv-card"><div class="sv-card-body"><div class="empty-state-box"><i class="fas fa-folder-open"></i><h3>Course details not available</h3><p>Return to the catalog and pick a course.</p><a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Courses</a></div></div></section>
        </c:if>

        <c:if test="${not empty course}">
            <section class="ef-course">
                <h3>${course.courseName}</h3>
                <p>${course.description}</p>

                <div class="ef-grid">
                    <div class="ef-meta"><span>Category</span><strong><c:out value="${course.category}" default="General"/></strong></div>
                    <div class="ef-meta"><span>Level</span><strong><c:out value="${course.level}" default="General"/></strong></div>
                    <div class="ef-meta"><span>Duration</span><strong><c:out value="${course.displayDuration}" default="-"/></strong></div>
                </div>

                <div class="ef-amount"><span>Total Fee</span><strong><c:choose><c:when test="${course.courseFee == 0}">Free</c:when><c:otherwise><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise></c:choose></strong></div>

                <form method="post" action="${pageContext.request.contextPath}/student/enroll">
                    <input type="hidden" name="courseId" value="${course.courseId}" />
                    <div class="ef-actions">
                        <button type="submit" class="sv-btn primary">
                            <c:choose>
                                <c:when test="${course.courseFee == 0}">Enroll for Free</c:when>
                                <c:otherwise>Proceed to Payment</c:otherwise>
                            </c:choose>
                        </button>
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/courses">Cancel</a>
                    </div>
                </form>
            </section>
        </c:if>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

