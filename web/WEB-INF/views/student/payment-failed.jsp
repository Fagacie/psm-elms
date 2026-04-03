<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Failed - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Payment Failed</h1><p>Action required</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/profile" class="sv-profile-link"><i class="fas fa-user"></i><span>${sessionScope.userName}</span></a><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout ef-layout-flat">
    <main class="sv-main ef-main-centered">
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
                    <li><c:choose><c:when test="${param.error == 'noreference'}">No payment reference was returned from the gateway. Retry payment from My Courses.</c:when><c:when test="${param.error == 'notfound'}">Enrollment or payment session not found. Please re-initiate payment.</c:when><c:when test="${param.error == 'unauthorized'}">Unauthorized payment attempt.</c:when><c:when test="${param.error == 'failed'}">Gateway reported payment failed. Verify card/account and retry.</c:when><c:when test="${param.error == 'abandoned'}">Payment was not completed. You can safely retry from My Courses.</c:when><c:when test="${param.error == 'verification'}">Could not verify payment result with gateway. No access was granted.</c:when><c:when test="${param.error == 'update'}">Payment may have succeeded but local update failed. Contact support with your payment reference.</c:when><c:when test="${param.error == 'unknownstatus'}">Gateway returned an unknown status. No access was granted.</c:when><c:when test="${param.error == 'invalid'}">Invalid payment information.</c:when><c:otherwise>Unexpected payment error. Please retry.</c:otherwise></c:choose></li>
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
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary">Retry From My Courses</a>
                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse Courses</a>
            </div>
        </section>
    </main>
</div>
</body>
</html>

