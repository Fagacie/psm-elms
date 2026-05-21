<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Payment - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/checkout-flow-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Secure Payment"/>
<c:set var="topbarSubtitle" value="Complete your secure checkout via Paystack"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="browse-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main ef-main">

        <%-- Breadcrumb --%>
        <nav class="sv-breadcrumb" aria-label="breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/courses">Browse Courses</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Enrollments</a>
            <span>/</span>
            <span>Payment</span>
        </nav>

        <%-- Progress Stepper --%>
        <div class="ef-stepper" role="list" aria-label="Checkout steps">
            <div class="ef-step done" role="listitem">
                <span class="ef-step-num"><i class="fas fa-check" style="font-size:0.6rem;" aria-hidden="true"></i></span> Enrollment Summary
            </div>
            <div class="ef-step active" role="listitem" aria-current="step">
                <span class="ef-step-num">2</span> Secure Payment
            </div>
            <div class="ef-step" role="listitem">
                <span class="ef-step-num">3</span> Access Learning Hub
            </div>
        </div>

        <%-- Two-column checkout layout --%>
        <div class="ef-checkout-layout">

            <%-- ── LEFT COLUMN ── --%>
            <section class="ef-left-col" aria-label="Payment details">

                <%-- Error alert (shown only if paymentError is set) --%>
                <c:if test="${not empty paymentError}">
                    <div class="ef-error-alert" role="alert" aria-live="assertive">
                        <i class="fas fa-triangle-exclamation ef-error-alert-icon" aria-hidden="true"></i>
                        <div>
                            <c:choose>
                                <c:when test="${paymentError == 'paystack'}">Unable to initialize the payment gateway. Please try again in a moment.</c:when>
                                <c:when test="${paymentError == 'initstore'}">Payment session could not be saved. Please retry.</c:when>
                                <c:when test="${paymentError == 'noemail'}">Your account email is missing. Please update your profile email before retrying.</c:when>
                                <c:when test="${paymentError == 'required'}">Payment is required to access this course. Please complete your payment to continue.</c:when>
                                <c:when test="${paymentError == 'paystackconfig'}">Payment gateway is not configured. Please contact support.</c:when>
                                <c:otherwise>A payment error occurred. Please try again or contact support if the issue persists.</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>

                <%-- Course / Enrollment Info Card --%>
                <article class="ef-card">
                    <div class="ef-card-body">
                        <span class="ef-kicker"><i class="fas fa-graduation-cap" aria-hidden="true"></i> Course Being Purchased</span>
                        <div class="ef-course-header">
                            <h2 class="ef-course-title">${enrollment.courseName}</h2>
                            <p class="ef-course-desc"><c:out value="${enrollment.courseDescription}" default=""/></p>
                        </div>

                        <%-- Enrollment meta chips --%>
                        <div class="ef-meta-grid">
                            <div class="ef-meta-chip">
                                <i class="fas fa-hashtag ef-meta-chip-icon" aria-hidden="true"></i>
                                <span class="ef-meta-chip-label">Enrollment ID</span>
                                <span class="ef-meta-chip-value">#${enrollment.enrollmentId}</span>
                            </div>
                            <div class="ef-meta-chip">
                                <i class="fas fa-circle-dot ef-meta-chip-icon" aria-hidden="true"></i>
                                <span class="ef-meta-chip-label">Status</span>
                                <span class="ef-meta-chip-value">
                                    <span class="ef-status-badge pending">
                                        <i class="fas fa-clock" aria-hidden="true"></i>
                                        <c:out value="${enrollment.paymentStatus}" default="Pending"/>
                                    </span>
                                </span>
                            </div>
                            <div class="ef-meta-chip">
                                <i class="fas fa-fingerprint ef-meta-chip-icon" aria-hidden="true"></i>
                                <span class="ef-meta-chip-label">Reference</span>
                                <span class="ef-meta-chip-value" style="font-size:0.76rem; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${enrollment.paymentRef}">
                                    <c:out value="${enrollment.paymentRef}" default="—"/>
                                </span>
                            </div>
                        </div>
                    </div>
                </article>

                <%-- Paystack Gateway Card --%>
                <article class="ef-card">
                    <div class="ef-card-body">
                        <span class="ef-kicker"><i class="fas fa-shield-halved" aria-hidden="true"></i> Secure Payment Gateway</span>
                        <div class="ef-paystack-banner">
                            <div class="ef-paystack-logo" aria-hidden="true"><i class="fas fa-bolt"></i></div>
                            <div class="ef-paystack-copy">
                                <strong>Powered by Paystack</strong>
                                <span>Cards, bank transfers, USSD &amp; mobile money — all accepted. PCI-DSS certified.</span>
                            </div>
                        </div>
                    </div>
                </article>

            </section>

            <%-- ── RIGHT COLUMN — Sticky Invoice ── --%>
            <aside class="ef-sticky-invoice" aria-label="Payment invoice">
                <div class="ef-invoice-card">

                    <div class="ef-invoice-header">
                        <div class="ef-invoice-header-icon" aria-hidden="true"><i class="fas fa-shield-alt"></i></div>
                        <h3 class="ef-invoice-header-title">Payment Invoice</h3>
                    </div>

                    <div class="ef-invoice-body">

                        <%-- Mini course thumb --%>
                        <div class="ef-invoice-course-thumb">
                            <div class="ef-invoice-course-thumb-icon" aria-hidden="true"><i class="fas fa-book-open"></i></div>
                            <div>
                                <div class="ef-invoice-course-name">${enrollment.courseName}</div>
                                <div class="ef-invoice-course-sub">Enrollment #${enrollment.enrollmentId}</div>
                            </div>
                        </div>

                        <%-- Line items --%>
                        <div class="ef-invoice-rows">
                            <div class="ef-invoice-row">
                                <span class="ef-row-label">Course Price</span>
                                <span class="ef-row-amount">₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </div>
                            <div class="ef-invoice-row">
                                <span class="ef-row-label">Gateway Fee</span>
                                <span class="ef-row-amount" style="color:#10b981;">₦0.00</span>
                            </div>
                            <div class="ef-invoice-row total">
                                <span>Total Charge</span>
                                <span class="ef-row-amount">₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </div>
                        </div>

                        <%-- Pay button form --%>
                        <form method="post" action="${pageContext.request.contextPath}/student/start-payment" id="paystackForm" novalidate>
                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                            <div class="ef-cta-stack">
                                <button type="submit"
                                        class="ef-btn-primary"
                                        id="payButton"
                                        aria-label="Pay securely now via Paystack">
                                    <i class="fas fa-lock" id="payBtnIcon" aria-hidden="true"></i>
                                    <span id="payBtnText">Pay Securely Now</span>
                                    <span class="ef-spinner" id="paySpinner" aria-hidden="true"></span>
                                </button>
                                <a href="${pageContext.request.contextPath}/student/my-enrollments"
                                   class="ef-btn-secondary"
                                   aria-label="Return to my enrollments">
                                    <i class="fas fa-arrow-left" aria-hidden="true"></i> My Enrollments
                                </a>
                            </div>
                        </form>

                        <%-- Trust strip --%>
                        <div class="ef-trust-strip" role="list" aria-label="Security guarantees">
                            <div class="ef-trust-row" role="listitem">
                                <i class="fas fa-lock" aria-hidden="true"></i>
                                <span><strong>256-bit SSL Encrypted</strong> — all data is fully protected</span>
                            </div>
                            <div class="ef-trust-row" role="listitem">
                                <i class="fas fa-shield-halved" aria-hidden="true"></i>
                                <span><strong>Paystack</strong> — PCI-DSS Level 1 certified gateway</span>
                            </div>
                            <div class="ef-trust-row" role="listitem">
                                <i class="fas fa-credit-card" aria-hidden="true"></i>
                                <span>Visa, Mastercard, Verve, USSD &amp; mobile money accepted</span>
                            </div>
                        </div>

                    </div><%-- /invoice-body --%>
                </div><%-- /invoice-card --%>
            </aside>

        </div><%-- /checkout-layout --%>

    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const form    = document.getElementById("paystackForm");
    const btn     = document.getElementById("payButton");
    const icon    = document.getElementById("payBtnIcon");
    const text    = document.getElementById("payBtnText");
    const spinner = document.getElementById("paySpinner");

    if (form && btn) {
        form.addEventListener("submit", function () {
            // Disable to prevent double-submit
            btn.disabled = true;
            btn.classList.add("processing");
            btn.setAttribute("aria-busy", "true");

            // Swap to loading state
            if (icon)    { icon.style.display = "none"; }
            if (spinner) { spinner.style.display = "block"; }
            if (text)    { text.textContent = "Connecting to Gateway…"; }
        });
    }
});
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
