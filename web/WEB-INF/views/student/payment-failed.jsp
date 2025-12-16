<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Failed - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .error-animation {
            text-align: center;
            animation: fadeInUp 0.5s ease-in;
        }
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .error-icon {
            font-size: 5rem;
            color: #dc3545;
            animation: shake 0.5s ease-in-out;
        }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/navbar.jsp"/>
    
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
