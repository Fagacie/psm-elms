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

        <section class="ef-result sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 32px; display: flex; flex-direction: column; gap: 24px; box-shadow: var(--sv-shadow-md);">
            <div class="ef-result-top" style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
                <div class="ef-icon success" style="width: 52px; height: 52px; border-radius: 50%; background: rgba(16, 185, 129, 0.08); color: #10b981; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <h2 style="margin: 0; font-size: 1.5rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.02em;">Tuition Receipt Confirmed!</h2>
                    <p style="margin: 0; color: var(--sv-muted); font-size: 0.92rem;">Your transaction was completed securely and your learning workspace is active.</p>
                </div>
            </div>

            <!-- Automated Redirection Countdown -->
            <div class="ef-redirect-banner" id="redirectBanner" style="display:flex; align-items:center; gap:16px; padding:18px 22px; background: rgba(59, 130, 246, 0.05); border:1px solid rgba(59, 130, 246, 0.15); border-radius: 12px; color: #2563eb; font-size:0.9rem;">
                <i class="fas fa-circle-notch fa-spin" style="font-size: 1.3rem;"></i>
                <div>
                    <strong style="display:block; font-weight:800; color: var(--sv-foreground); margin-bottom: 2px;">Setting Up Your Curriculum Desk...</strong>
                    <span style="color: var(--sv-muted);">Redirecting to your learning hub in <span id="countdown" style="font-weight:800; color: #2563eb;">5</span> seconds. <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=overview" style="color:#2563eb; text-decoration:none; font-weight:700;">Open now</a></span>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px;">
                <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px;">
                    <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Syllabus</span>
                    <strong style="font-size: 0.88rem; color: var(--sv-foreground); font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block;">${enrollment.courseName}</strong>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px;">
                    <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Enrollment ID</span>
                    <strong style="font-size: 0.88rem; color: var(--sv-foreground); font-weight: 700;">#${enrollment.enrollmentId}</strong>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                    <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Reference</span>
                    <strong style="font-size: 0.82rem; color: var(--sv-foreground); font-weight: 700; overflow: hidden; text-overflow: ellipsis; display: block;" title="${enrollment.paymentRef}"><c:out value="${enrollment.paymentRef}" default="-"/></strong>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 10px; background: var(--sv-surface-soft); padding: 14px;">
                    <span style="font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--sv-muted); font-weight: 700; display: block; margin-bottom: 4px;">Amount Paid</span>
                    <strong style="font-size: 0.88rem; color: var(--sv-foreground); font-weight: 700;">₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong>
                </div>
            </div>

            <div class="ef-note" style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 20px; display: flex; flex-direction: column; gap: 10px;">
                <h4 style="margin: 0; font-size: 1rem; font-weight: 800; color: var(--sv-foreground);"><i class="fas fa-graduation-cap" style="color: var(--sv-accent);"></i> Study Suggestions</h4>
                <ul style="margin: 0; padding-left: 18px; color: var(--sv-muted); font-size: 0.88rem; line-height: 1.6; display: flex; flex-direction: column; gap: 6px;">
                    <li>Access syllabus content blocks from the workspace curriculum desk.</li>
                    <li>Complete quizzes and assignments sequentially to test progress.</li>
                    <li>Ensure total curriculum requirements are met to unlock download credentials.</li>
                </ul>
            </div>

            <div class="ef-actions" style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning" class="sv-btn primary" style="height: 42px; border-radius: 8px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; padding: 0 20px; gap: 8px;"><i class="fas fa-play"></i> Start Learning Workspace</a>
                <a href="${pageContext.request.contextPath}/student/payments?receiptPaymentId=${payment.paymentId}" class="sv-btn" style="height: 42px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; justify-content: center; padding: 0 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground);"><i class="fas fa-file-invoice"></i> View Receipt</a>
                <a href="${pageContext.request.contextPath}/student/payments" class="sv-btn" style="height: 42px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; justify-content: center; padding: 0 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground);"><i class="fas fa-clock-rotate-left"></i> Payment History</a>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn" style="height: 42px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; justify-content: center; padding: 0 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); color: var(--sv-foreground);"><i class="fas fa-layer-group"></i> Back to My Courses</a>
            </div>
        </section>
    </main>
</div>

<script>
    (function() {
        var count = 5;
        var countdownEl = document.getElementById('countdown');
        var targetUrl = "${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=overview";
        
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


