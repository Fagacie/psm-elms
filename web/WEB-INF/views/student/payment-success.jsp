<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <style>
        body {
            background: var(--color-background);
            padding: var(--spacing-lg);
        }
        .success-wrapper {
            max-width: 600px;
            margin: 0 auto;
            padding: var(--spacing-xl);
        }
        .success-card {
            background: var(--color-white);
            border: 1px solid var(--color-light-grey);
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            text-align: center;
        }
        .success-icon {
            width: 80px;
            height: 80px;
            margin: var(--spacing-lg) auto var(--spacing-md);
            background: var(--color-success);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--color-white);
            font-size: 2.5rem;
        }
        .success-card h1 {
            color: var(--color-success);
            margin: 0 0 var(--spacing-md) 0;
            font-size: 1.75rem;
        }
        .success-card .subtitle {
            color: var(--color-text-light);
            margin-bottom: var(--spacing-lg);
            font-size: 1rem;
        }
        .enrollment-details {
            background: var(--color-background);
            padding: var(--spacing-lg);
            margin: var(--spacing-lg) 0;
            border: 1px solid var(--color-light-grey);
            text-align: left;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: var(--spacing-sm) 0;
            border-bottom: 1px solid var(--color-light-grey);
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            font-weight: 600;
            color: var(--color-text);
        }
        .detail-value {
            color: var(--color-text-light);
        }
        .next-steps {
            background: var(--color-info-light);
            padding: var(--spacing-md);
            margin: var(--spacing-lg) 0;
            border: 1px solid var(--color-info-border);
            text-align: left;
        }
        .next-steps h6 {
            margin: 0 0 var(--spacing-sm) 0;
            color: var(--color-text);
            font-weight: 600;
        }
        .next-steps ul {
            margin: 0;
            padding-left: 1.5rem;
            color: var(--color-text);
        }
        .next-steps li {
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
    <div class="success-wrapper">
        <div class="success-card">
            <div class="success-icon">✓</div>
            
            <h1>Payment Successful!</h1>
            <p class="subtitle">Congratulations! You have successfully enrolled in the course.</p>
            
            <!-- Enrollment Details -->
            <div class="enrollment-details">
                <h5 style="margin-top:0; margin-bottom: var(--spacing-md); color: var(--color-text);">${enrollment.courseName}</h5>
                <div class="detail-row">
                    <span class="detail-label">Enrollment ID:</span>
                    <span class="detail-value">#${enrollment.enrollmentId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Payment Reference:</span>
                    <span class="detail-value">${enrollment.paymentRef}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Amount Paid:</span>
                    <span class="detail-value" style="color: var(--color-success); font-weight: 600;">
                        <fmt:formatNumber value="${enrollment.coursePrice}" type="currency"/>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="detail-value" style="background: var(--color-success); color: var(--color-white); padding: 0.25rem 0.75rem; border-radius: 3px; display: inline-block;">Enrolled</span>
                </div>
            </div>
            
            <!-- Next Steps -->
            <div class="next-steps">
                <h6>What's Next?</h6>
                <ul>
                    <li>You can now access course materials</li>
                    <li>Complete assessments to track your progress</li>
                    <li>Earn your certificate upon course completion</li>
                </ul>
            </div>
            
            <!-- Action Buttons -->
            <div class="button-group">
                <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}" class="btn btn-primary">Start Learning</a>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-outline">My Courses</a>
            </div>
        </div>
    </div>
</body>
</html>
    
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
                                            ₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
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
                                <i class="fas fa-list me-2"></i>My Courses
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
