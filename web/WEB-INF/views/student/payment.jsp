<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="studentProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
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
<c:set var="topbarSubtitle" value="Secure checkout"/>
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
            <c:if test="${paymentError == 'required'}">
                <div class="alert alert-error">Payment is required before you can access this paid course. Complete payment to continue.</div>
            </c:if>
            <c:if test="${paymentError == 'paystackconfig'}">
                <div class="alert alert-error">Payment gateway is not configured with valid API keys. Set real Paystack keys and retry.</div>
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

