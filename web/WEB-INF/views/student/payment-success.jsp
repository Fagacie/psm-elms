<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Payment Success"/>
<c:set var="topbarSubtitle" value="Enrollment confirmed. Start learning now"/>
<c:set var="topbarShowMenu" value="false"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout ef-layout-flat">
    <main class="sv-main ef-main-centered">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>Payment Success</span>
        </div>

        <div class="ef-stepper">
            <div class="ef-step">1. Enrollment Summary</div>
            <div class="ef-step">2. Payment</div>
            <div class="ef-step active">3. Access Learning Hub</div>
        </div>

        <section class="ef-result">
            <div class="ef-result-top">
                <div class="ef-icon success"><i class="fas fa-check"></i></div>
                <div>
                    <h2>Payment Successful</h2>
                    <p>You are now enrolled and can start learning immediately.</p>
                </div>
            </div>

            <!-- Automated Redirection Countdown -->
            <div class="ef-redirect-banner" id="redirectBanner" style="display:flex; align-items:center; gap:12px; margin-bottom: 20px; padding:12px 16px; background:rgba(var(--sv-accent-rgb, 99, 102, 241), 0.1); border:1px solid var(--sv-accent); border-radius:6px; color:var(--sv-accent); font-size:0.9rem;">
                <i class="fas fa-circle-notch fa-spin"></i>
                <div>
                    <strong style="display:block; font-weight:700;">Launching Learning Hub Workspace...</strong>
                    <span>Automatically redirected in <span id="countdown" style="font-weight:700;">5</span> seconds. <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning" style="color:var(--sv-accent); text-decoration:underline; font-weight:600;">Click here to bypass.</a></span>
                </div>
            </div>

            <div class="ef-grid ef-grid-tight">
                <div class="ef-meta"><span>Course</span><strong>${enrollment.courseName}</strong></div>
                <div class="ef-meta"><span>Enrollment ID</span><strong>#${enrollment.enrollmentId}</strong></div>
                <div class="ef-meta"><span>Reference</span><strong><c:out value="${enrollment.paymentRef}" default="-"/></strong></div>
                <div class="ef-meta"><span>Amount Paid</span><strong><fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong></div>
                <div class="ef-meta"><span>Status</span><strong>Enrolled</strong></div>
            </div>

            <div class="ef-note">
                <h4>Next Steps</h4>
                <ul>
                    <li>Open your Learning Hub and start materials.</li>
                    <li>Take course assessments in sequence.</li>
                    <li>Complete course requirements to qualify for certificate.</li>
                </ul>
            </div>

            <div class="ef-actions">
                <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning" class="sv-btn primary">Start Learning</a>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">My Courses</a>
            </div>
        </section>
    </main>
</div>

<script>
    (function() {
        var count = 5;
        var countdownEl = document.getElementById('countdown');
        var targetUrl = "${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning";
        
        var timer = setInterval(function() {
            count--;
            if (countdownEl) {
                countdownEl.textContent = count;
            }
            if (count <= 0) {
                clearInterval(timer);
                window.location.href = targetUrl;
            }
        }, 1000);
    })();
</script>
</body>
</html>


