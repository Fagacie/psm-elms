<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    
    <!-- Isolated CSS Module targeting a narrow, high-whitespace document style -->
    <link class="cf-styles-link" rel="stylesheet" href="${pageContext.request.contextPath}/css/CheckoutFlow.module.css">

    <!-- Lucide Core for clean thin icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body style="margin: 0; padding: 0; min-height: 100vh; background-color: #ffffff;">
    
    <c:if test="${not empty course}">
        <!-- Step 1: Review Enrollment -->
        <div class="flow_cf_container" id="checkout-step-1">
            <h1 class="flow_cf_header">Review Enrollment</h1>
            
            <c:if test="${not empty param.error}">
                <div class="flow_cf_alert">
                    <i data-lucide="alert-triangle" style="width: 20px; height: 20px; flex-shrink: 0;"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.error == 'paystackconfig'}">Payment gateway keys are not configured. Please contact the administrator.</c:when>
                            <c:when test="${param.error == 'initstore'}">Failed to persist payment transaction. Please try again.</c:when>
                            <c:when test="${param.error == 'paystack'}">Failed to initialize transaction with Paystack. Please try again.</c:when>
                            <c:when test="${param.error == 'exception'}">An unexpected system error occurred. Please try again.</c:when>
                            <c:otherwise>An error occurred during payment processing: <c:out value="${param.error}"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>
            
            <c:choose>
                <c:when test="${not empty course.courseBanner}">
                    <c:choose>
                        <c:when test="${fn:startsWith(course.courseBanner, 'http')}">
                            <img src="${course.courseBanner}" alt="" class="flow_cf_thumbnail" />
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/${course.courseBanner}" alt="" class="flow_cf_thumbnail" />
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <div class="flow_cf_thumbnail" style="background: #f1f5f9; display: flex; align-items: center; justify-content: center; color: #94a3b8;">
                        <i data-lucide="image" style="width: 48px; height: 48px;"></i>
                    </div>
                </c:otherwise>
            </c:choose>
            
            <h2 class="flow_cf_courseTitle"><c:out value="${course.courseName}"/></h2>
            <p class="flow_cf_instructor">By <c:out value="${instructorName}" default="Course Instructor"/></p>
            
            <div class="flow_cf_benefitsList">
                <div class="flow_cf_benefitItem">
                    <i data-lucide="check" class="flow_cf_checkIcon"></i>
                    <span>Full Lifetime Access to all course resources</span>
                </div>
                <div class="flow_cf_benefitItem">
                    <i data-lucide="check" class="flow_cf_checkIcon"></i>
                    <span>Premium Digital Certificate upon successful completion</span>
                </div>
                <div class="flow_cf_benefitItem">
                    <i data-lucide="check" class="flow_cf_checkIcon"></i>
                    <span>Self-paced learning with expert instructor feedback</span>
                </div>
            </div>
            
            <button 
                type="button" 
                class="flow_cf_actionBtn"
                onclick="showStep(2)"
            >
                <span>Continue to Payment</span>
                <i data-lucide="arrow-right" style="width: 16px; height: 16px;"></i>
            </button>
            
            <a href="${pageContext.request.contextPath}/student/courses" class="flow_cf_backBtn" style="text-decoration: none;">
                <i data-lucide="arrow-left" style="width: 14px; height: 14px;"></i>
                <span>Cancel and Back to Catalog</span>
            </a>
        </div>

        <!-- Step 2: Payment Summary -->
        <div class="flow_cf_container" id="checkout-step-2" style="display: none;">
            <h1 class="flow_cf_header">Payment Summary</h1>
            
            <c:if test="${not empty param.error}">
                <div class="flow_cf_alert">
                    <i data-lucide="alert-triangle" style="width: 20px; height: 20px; flex-shrink: 0;"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.error == 'paystackconfig'}">Payment gateway keys are not configured. Please contact the administrator.</c:when>
                            <c:when test="${param.error == 'initstore'}">Failed to persist payment transaction. Please try again.</c:when>
                            <c:when test="${param.error == 'paystack'}">Failed to initialize transaction with Paystack. Please try again.</c:when>
                            <c:when test="${param.error == 'exception'}">An unexpected system error occurred. Please try again.</c:when>
                            <c:otherwise>An error occurred during payment processing: <c:out value="${param.error}"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>
            
            <div class="flow_cf_breakdown">
                <div class="flow_cf_row">
                    <span class="flow_cf_rowLabel">Course Fee</span>
                    <span class="flow_cf_rowValue">
                        <c:choose>
                            <c:when test="${course.courseFee le 0}">Free</c:when>
                            <c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="flow_cf_row">
                    <span class="flow_cf_rowLabel">Gateway Processing</span>
                    <span class="flow_cf_rowValue" style="color: #10b981;">₦0.00</span>
                </div>
                
                <div class="flow_cf_divider"></div>
                
                <div class="flow_cf_row flow_cf_rowTotal">
                    <span>Total to Pay</span>
                    <span>
                        <c:choose>
                            <c:when test="${course.courseFee le 0}">Free</c:when>
                            <c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>
            
            <form 
                id="checkoutFormNative" 
                method="POST" 
                action="${pageContext.request.contextPath}/student/enroll"
                style="width: 100%;"
            >
                <input type="hidden" name="courseId" value="${course.courseId}" />
                
                <button 
                    type="submit" 
                    id="payButton"
                    class="flow_cf_actionBtn"
                    style="height: 56px;"
                >
                    <i data-lucide="lock" id="payButtonIcon" style="width: 16px; height: 16px;"></i>
                    <span id="payButtonSpinner" class="flow_cf_spinner" style="display: none;"></span>
                    <span id="payButtonText">${course.courseFee le 0 ? 'Confirm Free Enrollment' : 'Proceed to Payment Gateway'}</span>
                </button>
            </form>
            
            <button 
                type="button" 
                class="flow_cf_backBtn"
                onclick="showStep(1)"
                id="backToReviewBtn"
            >
                <i data-lucide="arrow-left" style="width: 14px; height: 14px;"></i>
                <span>Back to Review</span>
            </button>
        </div>
    </c:if>

    <script type="text/javascript">
        function showStep(stepNum) {
            const step1 = document.getElementById('checkout-step-1');
            const step2 = document.getElementById('checkout-step-2');
            
            if (stepNum === 1) {
                if (step2) step2.style.display = 'none';
                if (step1) step1.style.display = 'block';
            } else if (stepNum === 2) {
                if (step1) step1.style.display = 'none';
                if (step2) step2.style.display = 'block';
            }
            
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }
        
        // Initial setup
        document.addEventListener("DOMContentLoaded", function() {
            if (window.lucide) {
                window.lucide.createIcons();
            }
            
            // If there is an error parameter in the URL, go directly to Step 2 so they see the error in the payment context!
            const params = new URLSearchParams(window.location.search);
            if (params.get('error')) {
                showStep(2);
            }
            
            const form = document.getElementById('checkoutFormNative');
            const btn = document.getElementById('payButton');
            const icon = document.getElementById('payButtonIcon');
            const spinner = document.getElementById('payButtonSpinner');
            const text = document.getElementById('payButtonText');
            const backBtn = document.getElementById('backToReviewBtn');
            
            if (form && btn) {
                form.addEventListener('submit', function(e) {
                    // Prevent double click actions during processing
                    if (btn.hasAttribute('data-processing')) {
                        e.preventDefault();
                        return;
                    }
                    btn.setAttribute('data-processing', 'true');
                    
                    // Show processing UI immediately
                    if (icon) icon.style.display = 'none';
                    if (spinner) spinner.style.display = 'inline-block';
                    if (text) text.textContent = 'Connecting to Gateway...';
                    
                    if (backBtn) {
                        backBtn.disabled = true;
                        backBtn.style.opacity = '0.5';
                        backBtn.style.cursor = 'not-allowed';
                    }
                    
                    // Disable submit button on a microtask delay so the browser initiates natural submit on this tick
                    setTimeout(function() {
                        btn.disabled = true;
                    }, 20);
                });
            }
        });
    </script>
    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>