<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Enrollment Summary - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/checkout-flow-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Enrollment Summary"/>
<c:set var="topbarSubtitle" value="Review your order before proceeding"/>
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
            <span>Enrollment Summary</span>
        </nav>

        <%-- Progress Stepper --%>
        <div class="ef-stepper" role="list" aria-label="Checkout steps">
            <c:choose>
                <c:when test="${empty course.courseFee || course.courseFee le 0}">
                    <div class="ef-step active" role="listitem" aria-current="step">
                        <span class="ef-step-num">1</span> Enrollment Summary
                    </div>
                    <div class="ef-step" role="listitem">
                        <span class="ef-step-num">2</span> Access Learning Hub
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="ef-step active" role="listitem" aria-current="step">
                        <span class="ef-step-num">1</span> Enrollment Summary
                    </div>
                    <div class="ef-step" role="listitem">
                        <span class="ef-step-num">2</span> Secure Payment
                    </div>
                    <div class="ef-step" role="listitem">
                        <span class="ef-step-num">3</span> Access Learning Hub
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- Empty state --%>
        <c:if test="${empty course}">
            <div class="ef-empty-state">
                <div class="ef-empty-icon"><i class="fas fa-folder-open" aria-hidden="true"></i></div>
                <h3>Course not found</h3>
                <p>We couldn't load the course details. Return to the catalog and pick a course to enroll.</p>
                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary" style="border-radius:10px;">
                    <i class="fas fa-compass"></i> Browse Courses
                </a>
            </div>
        </c:if>

        <%-- Main checkout grid --%>
        <c:if test="${not empty course}">
            <div class="ef-checkout-layout">

                <%-- ── LEFT COLUMN ── --%>
                <section class="ef-left-col" aria-label="Order details">

                    <%-- Course Summary Card --%>
                    <article class="ef-card">
                        <div class="ef-card-body">
                            <span class="ef-kicker"><i class="fas fa-graduation-cap" aria-hidden="true"></i> Course Overview</span>
                            <div class="ef-course-header">
                                <h2 class="ef-course-title">${course.courseName}</h2>
                                <p class="ef-course-desc"><c:out value="${course.description}" default="No description available."/></p>
                            </div>

                            <div class="ef-meta-grid">
                                <div class="ef-meta-chip">
                                    <i class="fas fa-tag ef-meta-chip-icon" aria-hidden="true"></i>
                                    <span class="ef-meta-chip-label">Category</span>
                                    <span class="ef-meta-chip-value"><c:out value="${course.category}" default="General"/></span>
                                </div>
                                <div class="ef-meta-chip">
                                    <i class="fas fa-signal ef-meta-chip-icon" aria-hidden="true"></i>
                                    <span class="ef-meta-chip-label">Level</span>
                                    <span class="ef-meta-chip-value"><c:out value="${course.level}" default="All Levels"/></span>
                                </div>
                                <div class="ef-meta-chip">
                                    <i class="fas fa-clock ef-meta-chip-icon" aria-hidden="true"></i>
                                    <span class="ef-meta-chip-label">Duration</span>
                                    <span class="ef-meta-chip-value"><c:out value="${course.displayDuration}" default="—"/></span>
                                </div>
                            </div>
                        </div>
                    </article>

                    <%-- Paystack Info Card (paid courses only) --%>
                    <c:if test="${not empty course.courseFee && course.courseFee gt 0}">
                        <article class="ef-card">
                            <div class="ef-card-body">
                                <span class="ef-kicker"><i class="fas fa-shield-halved" aria-hidden="true"></i> Payment Gateway</span>
                                <div class="ef-paystack-banner">
                                    <div class="ef-paystack-logo" aria-hidden="true"><i class="fas fa-bolt"></i></div>
                                    <div class="ef-paystack-copy">
                                        <strong>Secured by Paystack</strong>
                                        <span>All major cards, bank transfers &amp; USSD accepted. No extra fees.</span>
                                    </div>
                                </div>
                            </div>
                        </article>
                    </c:if>

                </section>

                <%-- ── RIGHT COLUMN — Sticky Invoice ── --%>
                <aside class="ef-sticky-invoice" aria-label="Order invoice">
                    <div class="ef-invoice-card">

                        <div class="ef-invoice-header">
                            <div class="ef-invoice-header-icon" aria-hidden="true"><i class="fas fa-receipt"></i></div>
                            <h3 class="ef-invoice-header-title">Order Summary</h3>
                        </div>

                        <div class="ef-invoice-body">

                            <%-- Mini course thumb --%>
                            <div class="ef-invoice-course-thumb">
                                <div class="ef-invoice-course-thumb-icon" aria-hidden="true"><i class="fas fa-book-open"></i></div>
                                <div>
                                    <div class="ef-invoice-course-name">${course.courseName}</div>
                                    <div class="ef-invoice-course-sub">
                                        <c:out value="${course.category}" default="General"/> &bull; <c:out value="${course.level}" default="All Levels"/>
                                    </div>
                                </div>
                            </div>

                            <%-- Line items --%>
                            <div class="ef-invoice-rows">
                                <div class="ef-invoice-row">
                                    <span class="ef-row-label">Enrollment Fee</span>
                                    <span class="ef-row-amount">
                                        <c:choose>
                                            <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                                <span class="ef-free-badge"><i class="fas fa-gift" aria-hidden="true"></i> FREE</span>
                                            </c:when>
                                            <c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="ef-invoice-row">
                                    <span class="ef-row-label">Processing Fee</span>
                                    <span class="ef-row-amount" style="color: #10b981;">₦0.00</span>
                                </div>
                                <div class="ef-invoice-row total">
                                    <span>Total Due</span>
                                    <span class="ef-row-amount">
                                        <c:choose>
                                            <c:when test="${empty course.courseFee || course.courseFee le 0}">
                                                <span class="ef-free-badge"><i class="fas fa-gift" aria-hidden="true"></i> FREE</span>
                                            </c:when>
                                            <c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>

                            <%-- CTA form --%>
                            <form method="post" action="${pageContext.request.contextPath}/student/enroll" id="checkoutForm" novalidate>
                                <input type="hidden" name="courseId" value="${course.courseId}" />
                                <div class="ef-cta-stack">
                                    <button type="submit"
                                            class="ef-btn-primary"
                                            id="payButton"
                                            aria-label="${empty course.courseFee || course.courseFee le 0 ? 'Confirm free enrollment' : 'Confirm and pay securely'}">
                                        <i class="fas fa-check-circle" id="payBtnIcon" aria-hidden="true"></i>
                                        <span id="payBtnText">
                                            <c:choose>
                                                <c:when test="${empty course.courseFee || course.courseFee le 0}">Confirm Free Enrollment</c:when>
                                                <c:otherwise>Confirm &amp; Pay Securely</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span class="ef-spinner" id="paySpinner" aria-hidden="true"></span>
                                    </button>
                                    <a class="ef-btn-secondary"
                                       href="${pageContext.request.contextPath}/student/courses"
                                       aria-label="Cancel and return to course catalog">
                                        <i class="fas fa-arrow-left" aria-hidden="true"></i> Back to Courses
                                    </a>
                                </div>
                            </form>

                            <%-- Trust strip --%>
                            <div class="ef-trust-strip" role="list" aria-label="Security guarantees">
                                <div class="ef-trust-row" role="listitem">
                                    <i class="fas fa-lock" aria-hidden="true"></i>
                                    <span><strong>256-bit SSL Encrypted</strong> — your data is always protected</span>
                                </div>
                                <div class="ef-trust-row" role="listitem">
                                    <i class="fas fa-shield-halved" aria-hidden="true"></i>
                                    <span><strong>Secured by Paystack</strong> — PCI-DSS Level 1 compliant</span>
                                </div>
                                <div class="ef-trust-row" role="listitem">
                                    <i class="fas fa-rotate-left" aria-hidden="true"></i>
                                    <span>Cancel anytime before payment completes</span>
                                </div>
                            </div>

                        </div><%-- /invoice-body --%>
                    </div><%-- /invoice-card --%>
                </aside>

            </div><%-- /checkout-layout --%>
        </c:if>

    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const form   = document.getElementById("checkoutForm");
    const btn    = document.getElementById("payButton");
    const icon   = document.getElementById("payBtnIcon");
    const text   = document.getElementById("payBtnText");
    const spinner = document.getElementById("paySpinner");

    if (form && btn) {
        form.addEventListener("submit", function () {
            // Prevent double-submit
            btn.disabled = true;
            btn.classList.add("processing");
            btn.setAttribute("aria-busy", "true");

            // Swap to loading state
            if (icon)    { icon.className = ""; icon.style.display = "none"; }
            if (spinner) { spinner.style.display = "block"; }
            if (text)    { text.textContent = "Processing…"; }
        });
    }
});
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
