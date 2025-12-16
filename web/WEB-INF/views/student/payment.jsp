<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .payment-card {
            border: 2px solid #dee2e6;
            border-radius: 10px;
            transition: all 0.3s;
        }
        .payment-card:hover {
            border-color: #0d6efd;
            box-shadow: 0 0 15px rgba(13, 110, 253, 0.2);
        }
        .payment-method {
            cursor: pointer;
        }
        .payment-method input[type="radio"] {
            display: none;
        }
        .payment-method input[type="radio"]:checked + label {
            border-color: #0d6efd;
            background-color: #e7f1ff;
        }
        .amount-display {
            font-size: 2.5rem;
            font-weight: bold;
            color: #198754;
        }
    </style>
</head>
<body>
    <div class="container mt-5 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card shadow-lg">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0"><i class="fas fa-credit-card me-2"></i>Complete Payment</h4>
                    </div>
                    <div class="card-body p-4">
                        <!-- Course Information -->
                        <div class="alert alert-info mb-4">
                            <h5 class="alert-heading"><i class="fas fa-book me-2"></i>${enrollment.courseName}</h5>
                            <p class="mb-0">${enrollment.courseDescription}</p>
                        </div>
                        
                        <!-- Amount Display -->
                        <div class="text-center mb-4 p-4 bg-light rounded">
                            <p class="text-muted mb-2">Total Amount</p>
                            <div class="amount-display">
                                <fmt:formatNumber value="${enrollment.coursePrice}" type="currency"/>
                            </div>
                        </div>
                        
                        <!-- Paystack Payment Trigger -->
                        <form method="post" action="${pageContext.request.contextPath}/student/start-payment" id="paystackForm">
                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                            <div class="d-flex gap-3">
                                <button type="submit" class="btn btn-success btn-lg flex-grow-1">
                                    <i class="fas fa-credit-card me-2"></i>Pay with Paystack
                                </button>
                                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-outline-secondary btn-lg">Cancel</a>
                            </div>
                        </form>
                        
                        <!-- Security Notice -->
                        <div class="text-center mt-4 text-muted">
                            <i class="fas fa-shield-alt me-2"></i>
                            <small>Your payment is secure and encrypted</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>// Simplified Paystack initiation handled server-side</script>
</body>
</html>
