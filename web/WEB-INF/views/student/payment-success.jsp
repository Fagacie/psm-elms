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
    
    <!-- Isolated CSS Module targeting a narrow, z-indexed full-screen layout -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/PaymentSuccess.module.css">

    <!-- Lucide Core for clean thin icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body style="margin: 0; padding: 0; background-color: #ffffff;">

    <div class="success_ps_viewport">
        <!-- Animated circular success badge scaling up natively in CSS -->
        <div class="success_ps_badge">
            <!-- Checkmark fading and sliding up inside the circle natively in CSS -->
            <div class="success_ps_checkIcon">
                <i data-lucide="check" style="width: 48px; height: 48px; stroke-width: 3px;"></i>
            </div>
        </div>

        <!-- Clean typography & confirmation message -->
        <h1 class="success_ps_title">Payment Successful!</h1>
        <p class="success_ps_subtitle">
            Your enrollment is confirmed. Preparing your learning hub...
        </p>

        <!-- Sleek, thin redirect progress visualizer loading bar (0% -> 100% over 5s) -->
        <div class="success_ps_progressTrack">
            <div class="success_ps_progressBar"></div>
        </div>

        <!-- Manual escape secondary action button -->
        <button
            type="button"
            class="success_ps_escapeLink"
            onclick="redirectToHub()"
            aria-label="Proceed to learning hub manually"
        >
            <span>Click here if you are not redirected automatically</span>
            <i data-lucide="chevron-right" style="width: 14px; height: 14px; stroke-width: 2.5px; flex-shrink: 0;"></i>
        </button>
    </div>

    <script type="text/javascript">
        const targetUrl = "${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}";

        function redirectToHub() {
            window.location.href = targetUrl;
        }

        // Draw Lucide icons
        document.addEventListener("DOMContentLoaded", function() {
            if (window.lucide) {
                window.lucide.createIcons();
            }
            
            // Keep the exact 5-second redirect setTimeout logic completely intact
            setTimeout(redirectToHub, 5000);
        });
    </script>
    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
