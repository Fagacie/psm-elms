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

        <section class="ef-result">
            <div class="ef-result-top">
                <div class="ef-icon fail"><i class="fas fa-times"></i></div>
                <div>
                    <h2>Payment Could Not Be Completed</h2>
                    <p>Your enrollment is still pending payment.</p>
                </div>
            </div>

            <div class="ef-note">
                <h4>Error Details</h4>
                <ul>
                    <li><c:choose><c:when test="${param.error == 'noreference'}">No payment reference was returned from the gateway. Retry payment from your enrollment.</c:when><c:when test="${param.error == 'notfound'}">Enrollment or payment session not found. Please re-initiate payment.</c:when><c:when test="${param.error == 'unauthorized'}">Unauthorized payment attempt was blocked.</c:when><c:when test="${param.error == 'failed'}">Gateway reported payment failed. Verify card/account details and retry.</c:when><c:when test="${param.error == 'abandoned'}">Payment was not completed. You can safely retry.</c:when><c:when test="${param.error == 'verification'}">Could not verify payment result with gateway. No access was granted.</c:when><c:when test="${param.error == 'amountmismatch'}">Amount verification failed. Your enrollment remains locked until a valid payment is completed.</c:when><c:when test="${param.error == 'state'}">Payment was captured but enrollment state could not be aligned. Retry, then contact support if this repeats.</c:when><c:when test="${param.error == 'update'}">Payment may have succeeded but local update failed. Contact support with your payment reference.</c:when><c:when test="${param.error == 'unknownstatus'}">Gateway returned an unknown status. No access was granted.</c:when><c:when test="${param.error == 'invalid'}">Invalid payment information.</c:when><c:otherwise>Unexpected payment error. Please retry.</c:otherwise></c:choose></li>
                </ul>
            </div>

            <div class="ef-note">
                <h4>Troubleshooting</h4>
                <ul>
                    <li>Check card balance and details.</li>
                    <li>Ensure stable internet connection.</li>
                    <li>Retry from your enrollment list.</li>
                </ul>
            </div>

            <div class="ef-actions">
                <a href="${retryPaymentUrl}" class="sv-btn primary">Retry Payment</a>
                <a href="${detailsUrl}" class="sv-btn">View Enrollment</a>
                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse Courses</a>
            </div>
        </section>
    </main>
</div>
</body>
</html>

