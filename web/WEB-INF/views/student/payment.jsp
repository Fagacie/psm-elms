<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Payment"/>
<c:set var="topbarSubtitle" value="Complete secure checkout to continue"/>
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
            <span>Payment</span>
        </div>

        <div class="ef-stepper" style="display: flex; gap: 14px; margin-bottom: 28px;">
            <div class="ef-step" style="flex: 1; border-radius: 10px; background: var(--sv-surface-soft); border: 1px solid var(--sv-border); color: var(--sv-muted); padding: 12px 14px; text-align: center; font-size: 0.8rem;">1. Enrollment Summary</div>
            <div class="ef-step active" style="flex: 1; border-radius: 10px; background: var(--sv-accent-soft); color: var(--sv-accent); border: 1px solid rgba(59, 130, 246, 0.15); font-weight: 700; padding: 12px 14px; text-align: center; font-size: 0.8rem;">2. Payment Details</div>
            <div class="ef-step" style="flex: 1; border-radius: 10px; background: var(--sv-surface-soft); border: 1px solid var(--sv-border); color: var(--sv-muted); padding: 12px 14px; text-align: center; font-size: 0.8rem;">3. Access Learning Hub</div>
        </div>

        <div style="display: grid; grid-template-columns: minmax(0, 1.2fr) 380px; gap: 28px; align-items: start;">
            <section class="ef-course sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 28px; display: flex; flex-direction: column; gap: 20px;">
                <c:if test="${not empty paymentError}">
                    <div style="background: rgba(239, 68, 68, 0.08); border: 1px solid rgba(239, 68, 68, 0.2); padding: 14px 18px; border-radius: 10px; color: #ef4444; font-size: 0.88rem; display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <i class="fas fa-exclamation-triangle" style="font-size: 1.1rem; flex-shrink: 0;"></i>
                        <div>
                            <c:choose>
                                <c:when test="${paymentError == 'paystack'}">Unable to initialize secure payment gateway. Please try again.</c:when>
                                <c:when test="${paymentError == 'initstore'}">Payment session could not be saved. Please retry.</c:when>
                                <c:when test="${paymentError == 'noemail'}">Your account email is missing. Update profile email before retrying payment.</c:when>
                                <c:when test="${paymentError == 'required'}">Payment is required before you can access this paid course. Complete payment to continue.</c:when>
                                <c:when test="${paymentError == 'paystackconfig'}">Payment gateway is not configured. Please contact support.</c:when>
                                <c:otherwise>A system-level transaction error has occurred. Please retry your payment.</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>

                <div style="display: flex; flex-direction: column; gap: 6px;">
                    <span style="font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--sv-accent); font-weight: 800;"><i class="fas fa-lock"></i> Payment Details</span>
                    <h3 style="margin: 0; font-size: 1.4rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.02em;">${enrollment.courseName}</h3>
                </div>
                <p style="margin: 0; line-height: 1.6; color: var(--sv-muted); font-size: 0.94rem;">${enrollment.courseDescription}</p>

                <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px; margin-top: 8px;">
                    <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px;">
                        <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Enrollment ID</span>
                        <strong style="font-size: 0.88rem; color: var(--sv-foreground); font-weight: 700;">#${enrollment.enrollmentId}</strong>
                    </div>
                    <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px;">
                        <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Status</span>
                        <strong style="font-size: 0.88rem; color: #f59e0b; font-weight: 700;"><c:out value="${enrollment.paymentStatus}" default="Pending"/></strong>
                    </div>
                    <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                        <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Reference</span>
                        <strong style="font-size: 0.82rem; color: var(--sv-foreground); font-weight: 700; overflow: hidden; text-overflow: ellipsis; display: block;" title="${enrollment.paymentRef}"><c:out value="${enrollment.paymentRef}" default="-"/></strong>
                    </div>
                </div>
            </section>

            <!-- Right panel: Checkout order form & paystack call action -->
            <aside class="sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 24px; display: flex; flex-direction: column; gap: 20px;">
                <h3 style="margin: 0; font-size: 1.15rem; font-weight: 800; color: var(--sv-foreground);"><i class="fas fa-shield-alt" style="color: #10b981;"></i> Secured Payment</h3>
                
                <div style="display: flex; flex-direction: column; gap: 12px; font-size: 0.88rem; border-bottom: 1px solid var(--sv-border); padding-bottom: 16px;">
                    <div style="display: flex; justify-content: space-between; color: var(--sv-muted);">
                        <span>Course fee</span>
                        <span>₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                    </div>
                    <div style="display: flex; justify-content: space-between; color: var(--sv-muted);">
                        <span>Gateway fee</span>
                        <span>₦0.00</span>
                    </div>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 0.88rem; font-weight: 700; color: var(--sv-foreground);">Total Charge Amount</span>
                    <strong style="font-size: 1.45rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.03em;">₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/student/start-payment" id="paystackForm" style="margin: 0;">
                    <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                    <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 8px;">
                        <button type="submit" class="sv-btn primary" style="height: 42px; border-radius: 8px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 8px;">
                            <i class="fas fa-credit-card"></i> Pay now
                        </button>
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" style="height: 42px; border-radius: 8px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground); font-weight: 600;" class="sv-btn">Back to My Courses</a>
                    </div>
                </form>

                <div style="border-top: 1px solid var(--sv-border); padding-top: 14px; display: flex; flex-direction: column; gap: 10px; font-size: 0.72rem; color: var(--sv-muted);">
                    <div style="display: flex; align-items: flex-start; gap: 8px; line-height: 1.4;">
                        <i class="fas fa-info-circle" style="color: var(--sv-accent); margin-top: 2px;"></i>
                        <span>Once payment is confirmed, your access will be updated automatically.</span>
                    </div>
                    <div style="display: flex; align-items: flex-start; gap: 8px; line-height: 1.4;">
                        <i class="fas fa-lock" style="color: #10b981; margin-top: 2px;"></i>
                        <span>Payments are handled through a secure gateway.</span>
                    </div>
                </div>
            </aside>
        </div>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

