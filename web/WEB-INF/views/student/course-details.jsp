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

            <div class="sv-card-body cd-shell-body cd-details-layout">
                <!-- Left Column (Rich Details) -->
                <div class="cd-details-left">
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

                    <!-- Interactive Syllabus / Modules Accordion -->
                    <div class="cd-syllabus-section">
                        <h4 class="cd-section-title"><i class="fas fa-list-ul"></i> Course Syllabus</h4>
                        <c:choose>
                            <c:when test="${empty materials}">
                                <div class="cd-empty-syllabus">
                                    <i class="fas fa-folder-open"></i>
                                    <span>No syllabus modules published yet. Please check back later.</span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="cd-accordion" id="cdSyllabusAccordion">
                                    <c:forEach var="material" items="${materials}" varStatus="status">
                                        <div class="cd-accordion-item">
                                            <button class="cd-accordion-trigger" type="button" aria-expanded="false" aria-controls="panel-${material.materialId}" id="trigger-${material.materialId}">
                                                <span class="cd-accordion-title">
                                                    <span class="cd-lesson-badge">Module ${status.index + 1}</span>
                                                    <c:out value="${material.title}"/>
                                                </span>
                                                <span class="cd-accordion-icon-wrap">
                                                    <i class="fas fa-chevron-down cd-accordion-icon"></i>
                                                </span>
                                            </button>
                                            <div class="cd-accordion-panel" id="panel-${material.materialId}" aria-labelledby="trigger-${material.materialId}" role="region">
                                                <div class="cd-accordion-content">
                                                    <div class="cd-material-meta">
                                                        <span class="cd-material-type-badge type-${fn:toLowerCase(material.materialType)}">
                                                            <c:choose>
                                                                <c:when test="${material.materialType == 'Video' || material.materialType == 'YouTube'}"><i class="fas fa-play-circle"></i> Video</c:when>
                                                                <c:when test="${material.materialType == 'PDF'}"><i class="fas fa-file-pdf"></i> PDF Document</c:when>
                                                                <c:when test="${material.materialType == 'Slides'}"><i class="fas fa-file-powerpoint"></i> Presentation</c:when>
                                                                <c:otherwise><i class="fas fa-link"></i> External Web Link</c:otherwise>
                                                            </c:choose>
                                                            <c:out value="${material.materialType}"/>
                                                        </span>
                                                    </div>
                                                    <p class="cd-material-desc">
                                                        <c:out value="${not empty material.description ? material.description : 'Explore core lectures, exercises, and slides contained in this syllabus module.'}"/>
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
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
                </div>

                <!-- Right Column (Sticky Enrollment Card) -->
                <aside class="cd-details-right cd-sticky-sidebar">
                    <div class="cd-price-tag-card">
                        <span class="cd-price-tag-label">Investment</span>
                        <strong class="cd-price-tag-value">
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when>
                                <c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                            </c:choose>
                        </strong>
                    </div>

                    <div class="cd-meta-vertical-list">
                        <div class="cd-meta-row">
                            <span class="cd-meta-row-label"><i class="fas fa-folder"></i> Category</span>
                            <strong class="cd-meta-row-value"><c:out value="${course.category}"/></strong>
                        </div>
                        <div class="cd-meta-row">
                            <span class="cd-meta-row-label"><i class="fas fa-signal"></i> Level</span>
                            <strong class="cd-meta-row-value"><c:out value="${course.level}"/></strong>
                        </div>
                        <div class="cd-meta-row">
                            <span class="cd-meta-row-label"><i class="fas fa-clock"></i> Duration</span>
                            <strong class="cd-meta-row-value"><c:out value="${course.displayDuration}"/></strong>
                        </div>
                    </div>

                    <div class="cd-action-vertical-stack">
                        <c:choose>
                            <c:when test="${isEnrolled}">
                                <a class="sv-btn primary cd-action-button" href="${pageContext.request.contextPath}/student/my-enrollments">
                                    <i class="fas fa-book-open-reader"></i> Open My Course
                                </a>
                            </c:when>
                            <c:otherwise>
                                <c:choose>
                                    <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                        <form method="post" action="${pageContext.request.contextPath}/student/enroll" class="cd-action-form">
                                            <input type="hidden" name="courseId" value="${course.courseId}">
                                            <button type="submit" class="sv-btn primary cd-action-button"><i class="fas fa-user-plus"></i> Enroll Free Now</button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="sv-btn primary cd-action-button" href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}">
                                            <i class="fas fa-shopping-cart"></i> Buy Course Now
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:otherwise>
                        </c:choose>
                        
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn cd-action-button cd-btn-secondary"><i class="fas fa-compass"></i> View All Courses</a>
                    </div>

                    <div class="cd-trust-guarantee-badges">
                        <div class="cd-trust-item">
                            <i class="fas fa-lock"></i>
                            <span>Secure checkout & access control</span>
                        </div>
                        <div class="cd-trust-item">
                            <i class="fas fa-award"></i>
                            <span>Earn professional completion certificate</span>
                        </div>
                    </div>
                </aside>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
document.addEventListener("DOMContentLoaded", function() {
    const accordionTriggers = document.querySelectorAll(".cd-accordion-trigger");
    
    accordionTriggers.forEach(trigger => {
        trigger.addEventListener("click", function() {
            const panel = document.getElementById(this.getAttribute("aria-controls"));
            const icon = this.querySelector(".cd-accordion-icon");
            const isExpanded = this.getAttribute("aria-expanded") === "true";
            
            // Toggle expanded attribute
            this.setAttribute("aria-expanded", !isExpanded);
            
            // Toggle active panels and animate using class list
            if (!isExpanded) {
                panel.classList.add("active");
                if (icon) icon.style.transform = "rotate(180deg)";
            } else {
                panel.classList.remove("active");
                if (icon) icon.style.transform = "rotate(0deg)";
            }
        });
    });
});
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
