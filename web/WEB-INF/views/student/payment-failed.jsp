<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Failed - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <style>
        body {
            background: var(--color-background);
            padding: var(--spacing-lg);
        }
        .failed-wrapper {
            max-width: 600px;
            margin: 0 auto;
            padding: var(--spacing-xl);
        }
        .failed-card {
            background: var(--color-white);
            border: 1px solid var(--color-light-grey);
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            text-align: center;
        }
        .failed-icon {
            width: 80px;
            height: 80px;
            margin: var(--spacing-lg) auto var(--spacing-md);
            background: #f8d7da;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #721c24;
            font-size: 2.5rem;
        }
        .failed-card h1 {
            color: #721c24;
            margin: 0 0 var(--spacing-md) 0;
            font-size: 1.75rem;
        }
        .failed-card .subtitle {
            color: var(--color-text-light);
            margin-bottom: var(--spacing-lg);
            font-size: 1rem;
        }
        .error-details {
            background: var(--color-background);
            padding: var(--spacing-lg);
            margin: var(--spacing-lg) 0;
            border: 1px solid #f8d7da;
            text-align: left;
        }
        .error-details h6 {
            margin: 0 0 var(--spacing-sm) 0;
            color: #721c24;
            font-weight: 600;
        }
        .error-details p {
            margin: 0;
            color: var(--color-text);
        }
        .retry-info {
            background: var(--color-info-light);
            padding: var(--spacing-md);
            margin: var(--spacing-lg) 0;
            border: 1px solid var(--color-info-border);
            text-align: left;
        }
        .retry-info h6 {
            margin: 0 0 var(--spacing-sm) 0;
            color: var(--color-text);
            font-weight: 600;
        }
        .retry-info ul {
            margin: 0;
            padding-left: 1.5rem;
            color: var(--color-text);
        }
        .retry-info li {
            margin-bottom: var(--spacing-xs);
        }
        .button-group {
            display: flex;
            gap: var(--spacing-md);
            margin-top: var(--spacing-lg);
            justify-content: center;
        }
        .button-group a {
            flex: 1;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="failed-wrapper">
        <div class="failed-card">
            <div class="failed-icon">✕</div>
            
            <h1>Payment Failed</h1>
            <p class="subtitle">Unfortunately, your payment could not be processed.</p>
            
            <!-- Error Details -->
            <c:if test="${param.error != null}">
                <div class="error-details">
                    <h6>Error Details</h6>
                    <p>
                        <c:choose>
                            <c:when test="${param.error == 'notfound'}">
                                Enrollment not found. Please try enrolling again.
                            </c:when>
                            <c:when test="${param.error == 'unauthorized'}">
                                You don't have permission to complete this payment.
                            </c:when>
                            <c:when test="${param.error == 'payment'}">
                                Payment processing failed. Please check your payment details and try again.
                            </c:when>
                            <c:when test="${param.error == 'update'}">
                                Payment was received but enrollment update failed. Please contact support.
                            </c:when>
                            <c:when test="${param.error == 'invalid'}">
                                Invalid payment information provided.
                            </c:when>
                            <c:otherwise>
                                An unexpected error occurred. Please try again or contact support.
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </c:if>
            
            <!-- Troubleshooting Tips -->
            <div class="retry-info">
                <h6>Common Issues</h6>
                <ul>
                    <li>Check if your card has sufficient balance</li>
                    <li>Verify card details (number, expiry, CVV)</li>
                    <li>Ensure your internet connection is stable</li>
                    <li>Try using a different payment method</li>
                    <li>Contact your bank if the problem persists</li>
                </ul>
            </div>
            
            <!-- Action Buttons -->
            <div class="button-group">
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-primary">Try Again</a>
                <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-outline">Browse Courses</a>
            </div>
            
            <p style="margin-top: var(--spacing-lg); color: var(--color-text-light); font-size: 0.9rem;">
                If you continue to experience issues, please contact our support team.
            </p>
        </div>
    </div>
</body>
</html>
    
    <div class="container mt-5 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card shadow-lg error-animation">
                    <div class="card-body p-5 text-center">
                        <div class="error-icon mb-4">
                            <i class="fas fa-times-circle"></i>
                        </div>
                        
                        <h1 class="text-danger mb-3">Payment Failed</h1>
                        <p class="lead text-muted mb-4">
                            Unfortunately, we couldn't process your payment.
                        </p>
                        
                        <!-- Error Details -->
                        <c:if test="${param.error != null}">
                            <div class="alert alert-danger text-start mb-4">
                                <h6 class="alert-heading"><i class="fas fa-exclamation-triangle me-2"></i>Error Details</h6>
                                <c:choose>
                                    <c:when test="${param.error == 'notfound'}">
                                        Enrollment not found. Please try enrolling again.
                                    </c:when>
                                    <c:when test="${param.error == 'unauthorized'}">
                                        You don't have permission to complete this payment.
                                    </c:when>
                                    <c:when test="${param.error == 'payment'}">
                                        Payment processing failed. Please check your payment details and try again.
                                    </c:when>
                                    <c:when test="${param.error == 'update'}">
                                        Payment was received but enrollment update failed. Please contact support.
                                    </c:when>
                                    <c:when test="${param.error == 'invalid'}">
                                        Invalid payment information provided.
                                    </c:when>
                                    <c:otherwise>
                                        An unexpected error occurred. Please try again or contact support.
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                        
                        <!-- Troubleshooting Tips -->
                        <div class="card bg-light mb-4 text-start">
                            <div class="card-body">
                                <h6 class="card-title"><i class="fas fa-lightbulb me-2"></i>Common Issues</h6>
                                <ul class="mb-0">
                                    <li>Check if your card has sufficient balance</li>
                                    <li>Verify card details (number, expiry, CVV)</li>
                                    <li>Ensure your internet connection is stable</li>
                                    <li>Try using a different payment method</li>
                                    <li>Contact your bank if the problem persists</li>
                                </ul>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="d-flex gap-3 justify-content-center">
                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-primary btn-lg">
                                <i class="fas fa-redo me-2"></i>Try Again
                            </a>
                            <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-outline-secondary btn-lg">
                                <i class="fas fa-arrow-left me-2"></i>Browse Courses
                            </a>
                        </div>
                        
                        <!-- Support Contact -->
                        <div class="mt-4">
                            <p class="text-muted mb-0">
                                Need help? <a href="${pageContext.request.contextPath}/contact" class="text-primary">Contact Support</a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="../common/footer.jsp"/>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
