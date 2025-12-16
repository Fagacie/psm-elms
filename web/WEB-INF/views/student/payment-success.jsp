<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .success-animation {
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
        .success-icon {
            font-size: 5rem;
            color: #198754;
            animation: scaleIn 0.5s ease-in-out;
        }
        @keyframes scaleIn {
            0% { transform: scale(0); }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/navbar.jsp"/>
    
    <div class="container mt-5 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card shadow-lg success-animation">
                    <div class="card-body p-5 text-center">
                        <div class="success-icon mb-4">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        
                        <h1 class="text-success mb-3">Payment Successful!</h1>
                        <p class="lead text-muted mb-4">
                            Congratulations! You have successfully enrolled in the course.
                        </p>
                        
                        <!-- Enrollment Details -->
                        <div class="card bg-light mb-4">
                            <div class="card-body">
                                <h5 class="card-title mb-3">${enrollment.courseName}</h5>
                                <div class="row text-start">
                                    <div class="col-md-6 mb-2">
                                        <strong>Enrollment ID:</strong><br>
                                        <span class="text-muted">#${enrollment.enrollmentId}</span>
                                    </div>
                                    <div class="col-md-6 mb-2">
                                        <strong>Payment Reference:</strong><br>
                                        <span class="text-muted">${enrollment.paymentRef}</span>
                                    </div>
                                    <div class="col-md-6 mb-2">
                                        <strong>Amount Paid:</strong><br>
                                        <span class="text-success fw-bold">
                                            <fmt:formatNumber value="${enrollment.coursePrice}" type="currency"/>
                                        </span>
                                    </div>
                                    <div class="col-md-6 mb-2">
                                        <strong>Status:</strong><br>
                                        <span class="badge bg-success">Enrolled</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Next Steps -->
                        <div class="alert alert-info text-start mb-4">
                            <h6 class="alert-heading"><i class="fas fa-info-circle me-2"></i>What's Next?</h6>
                            <ul class="mb-0">
                                <li>You can now access course materials</li>
                                <li>Complete assessments to track your progress</li>
                                <li>Earn your certificate upon course completion</li>
                            </ul>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="d-flex gap-3 justify-content-center">
                            <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" class="btn btn-primary btn-lg">
                                <i class="fas fa-play-circle me-2"></i>Start Learning
                            </a>
                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-outline-secondary btn-lg">
                                <i class="fas fa-list me-2"></i>My Enrollments
                            </a>
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
