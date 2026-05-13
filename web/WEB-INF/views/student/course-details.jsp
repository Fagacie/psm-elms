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

        <section class="sv-card" style="border-radius: 16px;">
            <div class="sv-card-head" style="border-bottom: 1px solid var(--sv-border); padding: 24px 28px !important; display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap;">
                <div style="display: flex; flex-direction: column; gap: 6px;">
                    <span style="font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.12em; color: var(--sv-accent); font-weight: 800;"><i class="fas fa-graduation-cap"></i> Course Details</span>
                    <h2 style="margin: 0; font-size: clamp(1.4rem, 2.2vw, 1.9rem); font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.03em;"><c:out value="${course.courseName}"/></h2>
                </div>
                <div class="sv-inline-actions" style="display: flex; gap: 8px; align-items: center;">
                    <c:choose>
                        <c:when test="${isEnrolled}">
                            <span class="sv-chip done" style="height: 32px; font-size: 0.7rem; border-radius: 6px;"><i class="fas fa-check-circle"></i> Enrolled</span>
                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn" style="height: 36px; padding: 0 14px; border-radius: 8px;"><i class="fas fa-book"></i> My Courses</a>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" style="display:inline;">
                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                        <button type="submit" class="sv-btn primary" style="height: 36px; padding: 0 16px; border-radius: 8px;"><i class="fas fa-user-plus"></i> Enroll Free</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="sv-btn primary" style="height: 36px; padding: 0 16px; border-radius: 8px;"><i class="fas fa-shopping-cart"></i> Enroll Now</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn" style="height: 36px; padding: 0 14px; border-radius: 8px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground);"><i class="fas fa-arrow-left"></i> Back</a>
                </div>
            </div>
            <div class="sv-card-body cd-hero-grid" style="padding: 28px !important;">
                <div>
                    <!-- Banner Frame -->
                    <div class="cd-banner-wrap" style="border-radius: 14px; overflow: hidden; border: 1px solid var(--sv-border); margin-bottom: 24px; box-shadow: var(--sv-shadow-sm);">
                        <c:choose>
                            <c:when test="${not empty course.courseBanner}">
                                <c:choose>
                                    <c:when test="${course.courseBanner.startsWith('http')}">
                                        <img class="cd-banner" src="${course.courseBanner}" alt="${course.courseName} banner" style="max-height: 280px; width: 100%; object-fit: cover; display: block;">
                                    </c:when>
                                    <c:otherwise>
                                        <img class="cd-banner" src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner" style="max-height: 280px; width: 100%; object-fit: cover; display: block;">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <div class="cd-banner-placeholder" style="height: 220px; background: var(--sv-surface-soft); display: flex; align-items: center; justify-content: center; color: var(--sv-muted); gap: 10px;">
                                    <i class="fas fa-image" style="font-size: 1.5rem;"></i> <span>No banner uploaded</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Description card -->
                    <div style="background: var(--sv-surface-soft); border: 1px solid var(--sv-border); border-radius: 14px; padding: 22px; margin-bottom: 24px;">
                        <h4 style="margin: 0 0 10px; font-size: 1.1rem; font-weight: 800; color: var(--sv-foreground);"><i class="fas fa-info-circle" style="color: var(--sv-accent);"></i> Course Overview</h4>
                        <p class="cd-description" style="margin: 0; line-height: 1.6; color: var(--sv-muted); font-size: 0.94rem;"><c:out value="${course.description}"/></p>
                    </div>

                    <!-- Instructor Highlight Card -->
                    <div style="display: flex; align-items: center; gap: 16px; padding: 18px; border: 1px solid var(--sv-border); border-radius: 14px; background: var(--sv-surface); margin-bottom: 24px; box-shadow: var(--sv-shadow-sm);">
                        <div style="width: 48px; height: 48px; border-radius: 12px; background: rgba(59, 130, 246, 0.08); display: flex; align-items: center; justify-content: center; color: #3b82f6; font-size: 1.3rem; flex-shrink: 0;">
                            <i class="fas fa-user-tie"></i>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 2px;">
                            <span style="font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700;">Assigned Instructor</span>
                            <strong style="font-size: 1rem; color: var(--sv-foreground); font-weight: 700;"><c:out value="${instructor.fullName}" default="TBA"/></strong>
                            <span style="font-size: 0.78rem; color: var(--sv-muted);"><c:out value="${instructor.email}" default="Contact academic advisor"/></span>
                        </div>
                    </div>

                    <!-- Course Metadata grid -->
                    <div class="cd-meta-grid" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px;">
                        <div class="cd-meta-card" style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface); padding: 16px 20px; border-left: 4px solid #3b82f6;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 700;">Category</span>
                            <strong style="display: block; margin-top: 6px; font-size: 0.98rem; color: var(--sv-foreground); font-weight: 700;"><c:out value="${course.category}"/></strong>
                        </div>
                        <div class="cd-meta-card" style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface); padding: 16px 20px; border-left: 4px solid #8b5cf6;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 700;">Level</span>
                            <strong style="display: block; margin-top: 6px; font-size: 0.98rem; color: var(--sv-foreground); font-weight: 700;"><c:out value="${course.level}"/></strong>
                        </div>
                        <div class="cd-meta-card" style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface); padding: 16px 20px; border-left: 4px solid #10b981;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 700;">Duration</span>
                            <strong style="display: block; margin-top: 6px; font-size: 0.98rem; color: var(--sv-foreground); font-weight: 700;"><c:out value="${course.displayDuration}"/></strong>
                        </div>
                        <div class="cd-meta-card" style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface); padding: 16px 20px; border-left: 4px solid #f59e0b;">
                            <span style="display: block; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 700;">Course Fee</span>
                            <strong style="display: block; margin-top: 6px; font-size: 0.98rem; color: var(--sv-foreground); font-weight: 700;">
                                <c:choose><c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when><c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise></c:choose>
                            </strong>
                        </div>
                    </div>
                </div>

                <!-- Right actions panel -->
                <aside class="cd-side-panel" style="border: 1px solid var(--sv-border); border-radius: 14px; background: var(--sv-surface-soft); padding: 24px; display: flex; flex-direction: column; gap: 16px;">
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <div style="width: 32px; height: 32px; border-radius: 8px; background: var(--sv-accent-soft); display: flex; align-items: center; justify-content: center; color: var(--sv-accent); font-size: 0.95rem;">
                            <i class="fas fa-shopping-bag"></i>
                        </div>
                        <h3 style="margin: 0; font-size: 1.1rem; font-weight: 800; color: var(--sv-foreground);">Course Actions</h3>
                    </div>
                    <p style="margin: 0; color: var(--sv-muted); font-size: 0.88rem; line-height: 1.5;">View details, open your courses, and continue learning from one place.</p>
                    
                    <div class="cd-action-stack" style="display: flex; flex-direction: column; gap: 10px; margin-top: 8px;">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/my-enrollments" style="height: 42px; border-radius: 8px; display: flex; align-items: center; justify-content: center; gap: 8px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground); font-weight: 600;">
                            <i class="fas fa-layer-group"></i> My Courses
                        </a>
                        <c:if test="${not isEnrolled}">
                            <c:choose>
                                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" style="display:block; width:100%;">
                                        <input type="hidden" name="courseId" value="${course.courseId}">
                                        <button type="submit" class="sv-btn primary" style="width:100%; height: 42px; border-radius: 8px; font-weight: 700;"><i class="fas fa-user-plus"></i> Enroll Free</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" style="height: 42px; border-radius: 8px; display: flex; align-items: center; justify-content: center; gap: 8px; font-weight: 700;">
                                        <i class="fas fa-shopping-cart"></i> Enroll Now
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                    </div>

                    <div style="border-top: 1px solid var(--sv-border); padding-top: 14px; margin-top: 10px; display: flex; flex-direction: column; gap: 8px; font-size: 0.72rem; color: var(--sv-muted);">
                        <div style="display: flex; align-items: center; gap: 6px;">
                            <i class="fas fa-shield-alt" style="color: #10b981;"></i>
                            <span>Secure checkout</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 6px;">
                            <i class="fas fa-undo-alt" style="color: #3b82f6;"></i>
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

