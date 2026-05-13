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

        <div class="ef-stepper" style="display: flex; gap: 14px; margin-bottom: 28px;">
            <c:choose>
                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                    <div class="ef-step active" style="flex: 1; border-radius: 10px; background: var(--sv-accent-soft); color: var(--sv-accent); border: 1px solid rgba(59, 130, 246, 0.15); font-weight: 700; padding: 12px 14px; text-align: center; font-size: 0.8rem;">1. Enrollment Summary</div>
                    <div class="ef-step" style="flex: 1; border-radius: 10px; background: var(--sv-surface-soft); border: 1px solid var(--sv-border); color: var(--sv-muted); padding: 12px 14px; text-align: center; font-size: 0.8rem;">2. Access Learning Hub</div>
                </c:when>
                <c:otherwise>
                    <div class="ef-step active" style="flex: 1; border-radius: 10px; background: var(--sv-accent-soft); color: var(--sv-accent); border: 1px solid rgba(59, 130, 246, 0.15); font-weight: 700; padding: 12px 14px; text-align: center; font-size: 0.8rem;">1. Enrollment Summary</div>
                    <div class="ef-step" style="flex: 1; border-radius: 10px; background: var(--sv-surface-soft); border: 1px solid var(--sv-border); color: var(--sv-muted); padding: 12px 14px; text-align: center; font-size: 0.8rem;">2. Payment Details</div>
                    <div class="ef-step" style="flex: 1; border-radius: 10px; background: var(--sv-surface-soft); border: 1px solid var(--sv-border); color: var(--sv-muted); padding: 12px 14px; text-align: center; font-size: 0.8rem;">3. Access Learning Hub</div>
                </c:otherwise>
            </c:choose>
        </div>

        <c:if test="${empty course}">
            <section class="sv-card" style="border-radius: 14px;"><div class="sv-card-body" style="padding: 40px; text-align: center;"><div class="empty-state-box"><div style="width: 54px; height: 54px; border-radius: 50%; background: var(--sv-accent-soft); color: var(--sv-accent); display: inline-flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-bottom: 14px;"><i class="fas fa-folder-open"></i></div><h3>Course details not available</h3><p style="color: var(--sv-muted); margin-bottom: 20px;">Please return to the course catalog and pick a course to enroll.</p><a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary" style="border-radius: 8px;">Browse Courses</a></div></div></section>
        </c:if>

        <c:if test="${not empty course}">
            <div style="display: grid; grid-template-columns: minmax(0, 1.2fr) 380px; gap: 28px; align-items: start;">
                <!-- Left panel: Course summary card -->
                <section class="ef-course sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 28px; display: flex; flex-direction: column; gap: 20px;">
                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <span style="font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--sv-accent); font-weight: 800;"><i class="fas fa-shopping-cart"></i> Enrollment Details</span>
                        <h3 style="margin: 0; font-size: 1.4rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.02em;">${course.courseName}</h3>
                    </div>
                    <p style="margin: 0; line-height: 1.6; color: var(--sv-muted); font-size: 0.94rem;">${course.description}</p>

                    <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px; margin-top: 8px;">
                        <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px; border-left: 3px solid #3b82f6;">
                            <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Category</span>
                            <strong style="font-size: 0.88rem; color: var(--sv-foreground); font-weight: 700;"><c:out value="${course.category}" default="General"/></strong>
                        </div>
                        <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px; border-left: 3px solid #8b5cf6;">
                            <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Difficulty</span>
                            <strong style="font-size: 0.88rem; color: var(--sv-foreground); font-weight: 700;"><c:out value="${course.level}" default="General"/></strong>
                        </div>
                        <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px; border-left: 3px solid #10b981;">
                            <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Duration</span>
                            <strong style="font-size: 0.88rem; color: var(--sv-foreground); font-weight: 700;"><c:out value="${course.displayDuration}" default="-"/></strong>
                        </div>
                    </div>
                </section>

                <!-- Right panel: Pricing Summary Check out card -->
                <aside class="sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 24px; display: flex; flex-direction: column; gap: 20px;">
                    <h3 style="margin: 0; font-size: 1.15rem; font-weight: 800; color: var(--sv-foreground);"><i class="fas fa-file-invoice-dollar" style="color: var(--sv-accent);"></i> Order Summary</h3>
                    
                    <div style="display: flex; flex-direction: column; gap: 12px; font-size: 0.88rem; border-bottom: 1px solid var(--sv-border); padding-bottom: 16px;">
                        <div style="display: flex; justify-content: space-between; color: var(--sv-muted);">
                            <span>Course fee</span>
                            <span>
                                <c:choose><c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when><c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise></c:choose>
                            </span>
                        </div>
                        <div style="display: flex; justify-content: space-between; color: var(--sv-muted);">
                            <span>Discount</span>
                            <span style="color: #10b981; font-weight: 600;">None</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; color: var(--sv-muted);">
                            <span>Tax</span>
                            <span>₦0.00</span>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-size: 0.88rem; font-weight: 700; color: var(--sv-foreground);">Total Amount Due</span>
                        <strong style="font-size: 1.45rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.03em;">
                            <c:choose><c:when test="${empty course.courseFee || course.courseFee le 0}">Free</c:when><c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise></c:choose>
                        </strong>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/student/enroll" style="margin: 0;">
                        <input type="hidden" name="courseId" value="${course.courseId}" />
                        <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 8px;">
                            <button type="submit" class="sv-btn primary" style="height: 42px; border-radius: 8px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 8px;">
                                <c:choose>
                                    <c:when test="${empty course.courseFee || course.courseFee le 0}"><i class="fas fa-check-circle"></i> Enroll Now</c:when>
                                    <c:otherwise><i class="fas fa-credit-card"></i> Continue to Payment</c:otherwise>
                                </c:choose>
                            </button>
                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/courses" style="height: 42px; border-radius: 8px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground); font-weight: 600;">Back to Courses</a>
                        </div>
                    </form>

                    <div style="border-top: 1px solid var(--sv-border); padding-top: 14px; display: flex; flex-direction: column; gap: 8px; font-size: 0.72rem; color: var(--sv-muted);">
                        <div style="display: flex; align-items: center; gap: 6px;">
                            <i class="fas fa-lock" style="color: #10b981;"></i>
                            <span>Payment is processed through a secure gateway</span>
                        </div>
                    </div>
                </aside>
            </div>
        </c:if>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

