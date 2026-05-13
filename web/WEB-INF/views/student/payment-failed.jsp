<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Failed - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Payment Failed"/>
<c:set var="topbarSubtitle" value="Resolve payment and retry checkout"/>
<c:set var="topbarShowMenu" value="false"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout ef-layout-flat">
    <main class="sv-main ef-main-centered">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>Payment Failed</span>
        </div>

        <section class="ef-result sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 32px; display: flex; flex-direction: column; gap: 24px; box-shadow: var(--sv-shadow-md);">
            <div class="ef-result-top" style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
                <div class="ef-icon fail" style="width: 52px; height: 52px; border-radius: 50%; background: rgba(239, 68, 68, 0.08); color: #ef4444; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <h2 style="margin: 0; font-size: 1.5rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.02em;">Payment could not be completed</h2>
                    <p style="margin: 0; color: var(--sv-muted); font-size: 0.92rem;">Your enrollment is still pending.</p>
                </div>
            </div>

            <div style="background: rgba(239, 68, 68, 0.03); border: 1px solid rgba(239, 68, 68, 0.12); border-radius: 12px; padding: 18px 22px; display: flex; align-items: flex-start; gap: 14px; color: #ef4444;">
                <i class="fas fa-exclamation-triangle" style="font-size: 1.2rem; margin-top: 2px;"></i>
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <strong style="font-weight: 800; font-size: 0.92rem; color: var(--sv-foreground);">Error Reason</strong>
                    <span style="font-size: 0.88rem; color: var(--sv-muted); line-height: 1.5;"><c:choose><c:when test="${param.error == 'noreference'}">No payment reference was returned. Retry from your enrollment.</c:when><c:when test="${param.error == 'notfound'}">Enrollment or payment session not found. Please try again.</c:when><c:when test="${param.error == 'unauthorized'}">This payment attempt was blocked.</c:when><c:when test="${param.error == 'failed'}">The gateway reported a failed payment. Check your card or account details and retry.</c:when><c:when test="${param.error == 'abandoned'}">Payment was not completed. You can retry safely.</c:when><c:when test="${param.error == 'verification'}">The payment result could not be verified. No access was granted.</c:when><c:when test="${param.error == 'amountmismatch'}">Amount verification failed. The enrollment remains locked until a valid payment is completed.</c:when><c:when test="${param.error == 'state'}">Payment was captured but the enrollment state could not be updated. Retry, then contact support if this repeats.</c:when><c:when test="${param.error == 'update'}">Payment may have succeeded but the local update failed. Contact support with your payment reference.</c:when><c:when test="${param.error == 'unknownstatus'}">The gateway returned an unknown status. No access was granted.</c:when><c:when test="${param.error == 'invalid'}">Invalid payment information.</c:when><c:otherwise>Unexpected payment error. Please retry.</c:otherwise></c:choose></span>
                </div>
            </div>

            <div class="ef-note" style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 20px; display: flex; flex-direction: column; gap: 10px;">
                <h4 style="margin: 0; font-size: 1rem; font-weight: 800; color: var(--sv-foreground);"><i class="fas fa-tools" style="color: var(--sv-accent);"></i> What to check</h4>
                <ul style="margin: 0; padding-left: 18px; color: var(--sv-muted); font-size: 0.88rem; line-height: 1.6; display: flex; flex-direction: column; gap: 6px;">
                    <li>Make sure your payment source has enough balance and allows online transactions.</li>
                    <li>Check the card or account details before retrying.</li>
                    <li>Contact your bank if they are blocking e-commerce payments.</li>
                </ul>
            </div>

            <!-- Action buttons -->
            <div class="ef-actions" style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="${retryPaymentUrl}" class="sv-btn primary" style="height: 42px; border-radius: 8px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; padding: 0 20px; gap: 8px;"><i class="fas fa-redo"></i> Retry Payment</a>
                <a href="${detailsUrl}" class="sv-btn" style="height: 42px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; justify-content: center; padding: 0 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground);"><i class="fas fa-file-invoice"></i> View Enrollment Details</a>
                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn" style="height: 42px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; justify-content: center; padding: 0 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground);"><i class="fas fa-search"></i> Browse Other Courses</a>
            </div>
        </section>
    </main>
</div>
</body>
</html>
