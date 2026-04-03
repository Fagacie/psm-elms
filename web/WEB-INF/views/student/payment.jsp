<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - PSM E-Learning</title>
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
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Payment</h1><p>Secure checkout</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/profile" class="sv-profile-link"><i class="fas fa-user"></i><span>${sessionScope.userName}</span></a><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link active"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main ef-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
            <span>/</span>
            <span>Payment</span>
        </div>

        <div class="ef-stepper">
            <div class="ef-step">1. Enrollment Summary</div>
            <div class="ef-step active">2. Payment</div>
            <div class="ef-step">3. Access Learning Hub</div>
        </div>

        <section class="ef-course">
            <c:if test="${paymentError == 'paystack'}">
                <div class="alert alert-error">Unable to initialize secure payment gateway. Please try again.</div>
            </c:if>
            <c:if test="${paymentError == 'initstore'}">
                <div class="alert alert-error">Payment session started but could not be saved. Please retry to avoid inconsistent status.</div>
            </c:if>
            <c:if test="${paymentError == 'noemail'}">
                <div class="alert alert-error">Your account email is missing. Update profile email before retrying payment.</div>
            </c:if>

            <h3>${enrollment.courseName}</h3>
            <p>${enrollment.courseDescription}</p>

            <div class="ef-grid">
                <div class="ef-meta"><span>Enrollment ID</span><strong>#${enrollment.enrollmentId}</strong></div>
                <div class="ef-meta"><span>Payment Status</span><strong><c:out value="${enrollment.paymentStatus}" default="Pending"/></strong></div>
                <div class="ef-meta"><span>Reference</span><strong><c:out value="${enrollment.paymentRef}" default="-"/></strong></div>
            </div>

            <div class="ef-amount"><span>Total Amount</span><strong><fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong></div>

            <form method="post" action="${pageContext.request.contextPath}/student/start-payment" id="paystackForm">
                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                <div class="ef-actions">
                    <button type="submit" class="sv-btn primary">Pay Now</button>
                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">Cancel</a>
                </div>
            </form>

            <div class="ef-note"><h4>Security Notice</h4><ul><li>Your payment is encrypted and processed securely.</li><li>After successful payment, access is activated immediately.</li></ul></div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

