<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <style>
        body {
            background: var(--color-background);
            padding: var(--spacing-lg);
        }
        .payment-wrapper {
            max-width: 600px;
            margin: 0 auto;
            padding: var(--spacing-xl);
        }
        .payment-card {
            background: var(--color-white);
            border: 1px solid var(--color-light-grey);
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .payment-header {
            background: var(--color-primary);
            color: var(--color-white);
            padding: var(--spacing-lg);
        }
        .payment-header h2 {
            margin: 0;
            font-size: 1.5rem;
            font-weight: 600;
        }
        .payment-body {
            padding: var(--spacing-lg);
        }
        .course-info {
            background: var(--color-light-grey);
            padding: var(--spacing-md);
            margin-bottom: var(--spacing-lg);
            border: 1px solid #e0e0e0;
        }
        .course-info h4 {
            margin: 0 0 var(--spacing-xs) 0;
            font-size: 1rem;
            font-weight: 600;
            color: var(--color-text);
        }
        .course-info p {
            margin: 0;
            color: var(--color-text-light);
            font-size: 0.9rem;
        }
        .amount-box {
            text-align: center;
            padding: var(--spacing-lg);
            margin: var(--spacing-lg) 0;
            background: var(--color-background);
            border: 1px solid var(--color-light-grey);
        }
        .amount-label {
            color: var(--color-text-light);
            font-size: 0.9rem;
            margin-bottom: var(--spacing-sm);
        }
        .amount-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--color-primary);
        }
        .button-group {
            display: flex;
            gap: var(--spacing-md);
            margin: var(--spacing-lg) 0;
        }
        .btn-full {
            flex: 1;
        }
        .security-notice {
            text-align: center;
            color: var(--color-text-light);
            font-size: 0.9rem;
            margin-top: var(--spacing-lg);
            padding-top: var(--spacing-lg);
            border-top: 1px solid var(--color-light-grey);
        }
    </style>
</head>
<body>
    <div class="payment-wrapper">
        <div class="payment-card">
            <div class="payment-header">
                <h2>Complete Payment</h2>
            </div>
            <div class="payment-body">
                <!-- Course Information -->
                <div class="course-info">
                    <h4>${enrollment.courseName}</h4>
                    <p>${enrollment.courseDescription}</p>
                </div>
                
                <!-- Amount Display -->
                <div class="amount-box">
                    <div class="amount-label">Total Amount</div>
                    <div class="amount-value">
                        ₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                    </div>
                </div>
                
                <!-- Paystack Payment Trigger -->
                <form method="post" action="${pageContext.request.contextPath}/student/start-payment" id="paystackForm">
                    <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                    <div class="button-group">
                        <button type="submit" class="btn btn-primary btn-full">Pay Now</button>
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-outline btn-full" style="flex:1; text-align:center;">Cancel</a>
                    </div>
                </form>
                
                <!-- Security Notice -->
                <div class="security-notice">
                    Your payment is secure and encrypted
                </div>
            </div>
        </div>
    </div>
</body>
</html>
