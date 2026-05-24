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

        <!-- Immersive Storefront Hero Banner -->
        <header class="cd-hero-banner">
            <div class="cd-hero-badge-row">
                <span class="cd-hero-badge accent"><i class="fas fa-star"></i> Bestseller</span>
                <span class="cd-hero-badge"><i class="fas fa-award"></i> Professional Certificate</span>
                <span class="cd-hero-badge"><c:out value="${course.category}"/></span>
            </div>
            <h1 class="cd-hero-title"><c:out value="${course.courseName}"/></h1>
            <p style="color: #cbd5e1; font-size: 1.1rem; line-height: 1.6; max-width: 800px; margin: 0 0 24px 0;">
                Accelerate your career milestones. Join our immersive, master-level training program led by elite academic instructors and industry veterans.
            </p>
            
            <div style="display: flex; flex-wrap: wrap; align-items: center; gap: 16px; margin-bottom: 24px; font-size: 0.9rem; color: #e2e8f0;">
                <span style="display: inline-flex; align-items: center; gap: 6px;">
                    <i class="fas fa-star" style="color: #f59e0b;"></i>
                    <strong style="color: #fff;">4.9</strong> (118 ratings)
                </span>
                <span style="color: #64748b;">•</span>
                <span><i class="fas fa-user-friends"></i> 1,420+ Enrolled Students</span>
                <span style="color: #64748b;">•</span>
                <span><i class="fas fa-circle-check" style="color: #10b981;"></i> 100% Verified Outcomes</span>
            </div>

            <div class="cd-hero-meta-row">
                <div class="cd-hero-meta-item">
                    <i class="fas fa-clock"></i>
                    <span>Duration: <strong><c:out value="${course.displayDuration}"/></strong></span>
                </div>
                <div class="cd-hero-meta-item">
                    <i class="fas fa-signal"></i>
                    <span>Level: <strong><c:out value="${course.level}"/></strong></span>
                </div>
                <div class="cd-hero-meta-item">
                    <i class="fas fa-globe"></i>
                    <span>Language: <strong>English</strong></span>
                </div>
            </div>
        </header>

        <div class="cd-details-layout" style="margin-bottom: 40px;">
            <!-- Left Column (Rich Course Outlines & Curriculums) -->
            <div class="cd-details-left">
                
                <!-- What you will learn checklist -->
                <div class="cd-wyl-box">
                    <h4 class="cd-section-title" style="margin-bottom: 8px;"><i class="fas fa-circle-check"></i> What you'll learn in this course</h4>
                    <p style="font-size: 0.88rem; color: var(--sv-muted); margin: 0 0 16px 0;">Acquire practical, state-of-the-art capabilities that will help you excel immediately in the professional workspace.</p>
                    <div class="cd-wyl-grid">
                        <div class="cd-wyl-item">
                            <i class="fas fa-check"></i>
                            <span>Comprehensive step-by-step concepts vetted by industry professionals.</span>
                        </div>
                        <div class="cd-wyl-item">
                            <i class="fas fa-check"></i>
                            <span>Dynamic evaluation tools including MCQ quizzes, secure tests, and practical assignments.</span>
                        </div>
                        <div class="cd-wyl-item">
                            <i class="fas fa-check"></i>
                            <span>Professional, shareable completion certificate upon clearing assessment guidelines.</span>
                        </div>
                        <div class="cd-wyl-item">
                            <i class="fas fa-check"></i>
                            <span>High-quality lesson slides, references, and video walkthroughs.</span>
                        </div>
                    </div>
                </div>

                <div class="cd-overview-card">
                    <h4 class="cd-section-title"><i class="fas fa-align-left"></i> Course Description</h4>
                    <p class="cd-description cd-overview-text" style="font-size: 0.95rem; line-height: 1.8;"><c:out value="${course.description}"/></p>
                </div>

                <!-- Interactive Syllabus Accordion -->
                <div class="cd-syllabus-section">
                    <h4 class="cd-section-title" style="margin-bottom: 4px;"><i class="fas fa-list-ol"></i> Detailed Course Syllabus</h4>
                    <p style="font-size: 0.88rem; color: var(--sv-muted); margin: 0 0 12px 0;">Browse through the comprehensive outline of learning modules and resources included in this program.</p>
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

            <!-- Right Column (Sticky Enrollment & Checkout Stack) -->
            <aside class="cd-details-right cd-sticky-sidebar">
                <div class="cd-banner-wrap cd-banner-frame" style="border-radius: 20px;">
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
                            <div class="cd-banner-placeholder cd-banner-frame__placeholder" style="aspect-ratio: 16/10;">
                                <i class="fas fa-image"></i>
                                <span>No banner uploaded</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="cd-price-tag-card">
                    <span class="cd-price-tag-label">Enrollment Investment</span>
                    <strong class="cd-price-tag-value" style="font-size: 2.2rem; color: var(--sv-accent);">
                        <c:choose>
                            <c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when>
                            <c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                        </c:choose>
                    </strong>
                    <p style="margin: 8px 0 0 0; font-size: 0.78rem; color: var(--sv-muted);"><i class="fas fa-history"></i> Full lifetime access included</p>
                </div>

                <div class="cd-action-vertical-stack">
                    <c:choose>
                        <c:when test="${isEnrolled}">
                            <a class="sv-btn primary cd-action-button" href="${pageContext.request.contextPath}/student/my-enrollments" style="background: #10b981 !important; color: white !important; border-color: #10b981 !important; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.25) !important;">
                                <i class="fas fa-graduation-cap"></i> Continue Learning
                            </a>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" class="cd-action-form" style="width: 100%;">
                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                        <button type="submit" class="sv-btn primary cd-action-button"><i class="fas fa-user-plus"></i> Enroll for Free Now</button>
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
                    
                    <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn cd-action-button cd-btn-secondary"><i class="fas fa-arrow-left"></i> Browse Other Courses</a>
                </div>

                <div class="cd-trust-guarantee-badges">
                    <div class="cd-trust-item">
                        <i class="fas fa-shield-halved" style="color: #6366f1;"></i>
                        <div>
                            <strong style="display: block; color: var(--sv-foreground); font-size: 0.8rem; margin-bottom: 2px;">Instant Course Access</strong>
                            <span>Start learning immediately after checkout verification.</span>
                        </div>
                    </div>
                    <div class="cd-trust-item">
                        <i class="fas fa-award" style="color: #6366f1;"></i>
                        <div>
                            <strong style="display: block; color: var(--sv-foreground); font-size: 0.8rem; margin-bottom: 2px;">Professional Certificate</strong>
                            <span>Earn a beautiful completion credential upon passing all sequential modules.</span>
                        </div>
                    </div>
                </div>
            </aside>
        </div>
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
