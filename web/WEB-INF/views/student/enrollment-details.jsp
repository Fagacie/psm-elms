<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Details - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .info-card {
            border-left: 4px solid #0d6efd;
        }
        .access-card {
            transition: all 0.3s;
            cursor: pointer;
        }
        .access-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <jsp:include page="../common/navbar.jsp"/>
    
    <div class="container mt-4 mb-5">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/student/my-enrollments">My Enrollments</a></li>
                <li class="breadcrumb-item active">Enrollment Details</li>
            </ol>
        </nav>
        
        <!-- Course Header -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h4 class="mb-0">${enrollment.courseName}</h4>
            </div>
            <div class="card-body">
                <p class="lead">${enrollment.courseDescription}</p>
                <div class="row">
                    <div class="col-md-3">
                        <strong>Instructor:</strong><br>
                        ${enrollment.instructorName}
                    </div>
                    <div class="col-md-3">
                        <strong>Status:</strong><br>
                        <c:choose>
                            <c:when test="${enrollment.status == 'Enrolled'}">
                                <span class="badge bg-success">Enrolled</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-warning">${enrollment.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-3">
                        <strong>Progress:</strong><br>
                        ${enrollment.completionStatus}
                    </div>
                    <div class="col-md-3">
                        <strong>Enrolled Date:</strong><br>
                        <c:choose>
                            <c:when test="${enrollment.enrollmentDate != null}">
                                ${enrollment.enrollmentDate.toString().substring(0, 10)}
                            </c:when>
                            <c:otherwise>N/A</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Payment Information -->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card info-card">
                    <div class="card-body">
                        <h6 class="card-title"><i class="fas fa-credit-card me-2"></i>Payment Information</h6>
                        <hr>
                        <div class="row">
                            <div class="col-6 mb-2">
                                <small class="text-muted">Payment Status</small>
                                <div>
                                    <c:choose>
                                        <c:when test="${enrollment.paymentStatus == 'Paid'}">
                                            <span class="badge bg-success">Paid</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning">${enrollment.paymentStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="col-6 mb-2">
                                <small class="text-muted">Amount</small>
                                <div class="fw-bold text-success">
                                    <fmt:formatNumber value="${enrollment.coursePrice}" type="currency"/>
                                </div>
                            </div>
                            <c:if test="${enrollment.paymentRef != null}">
                                <div class="col-12">
                                    <small class="text-muted">Payment Reference</small>
                                    <div class="font-monospace">${enrollment.paymentRef}</div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card info-card">
                    <div class="card-body">
                        <h6 class="card-title"><i class="fas fa-chart-line me-2"></i>Course Progress</h6>
                        <hr>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between mb-1">
                                <span>Completion Status</span>
                                <span class="fw-bold">${enrollment.completionStatus}</span>
                            </div>
                            <div class="progress" style="height: 25px;">
                                <c:choose>
                                    <c:when test="${enrollment.completionStatus == 'Completed'}">
                                        <div class="progress-bar bg-success" style="width: 100%">100%</div>
                                    </c:when>
                                    <c:when test="${enrollment.completionStatus == 'In Progress'}">
                                        <div class="progress-bar bg-info" style="width: 50%">50%</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="progress-bar bg-secondary" style="width: 0%">0%</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Course Access (Only if Paid) -->
        <c:if test="${enrollment.paymentStatus == 'Paid'}">
            <h5 class="mb-3">Course Content</h5>
            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="card access-card">
                        <div class="card-body text-center">
                            <i class="fas fa-book fa-3x text-primary mb-3"></i>
                            <h6>Course Materials</h6>
                            <p class="text-muted small">Access lecture notes, PDFs, and resources</p>
                            <a href="${pageContext.request.contextPath}/student/materials?courseId=${enrollment.courseId}" class="btn btn-primary btn-sm">
                                View Materials
                            </a>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card access-card">
                        <div class="card-body text-center">
                            <i class="fas fa-clipboard-check fa-3x text-success mb-3"></i>
                            <h6>Assessments</h6>
                            <p class="text-muted small">Take quizzes and track your scores</p>
                            <a href="${pageContext.request.contextPath}/student/assessments?courseId=${enrollment.courseId}" class="btn btn-success btn-sm">
                                View Assessments
                            </a>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card access-card">
                        <div class="card-body text-center">
                            <i class="fas fa-certificate fa-3x text-warning mb-3"></i>
                            <h6>Certificate</h6>
                            <p class="text-muted small">
                                <c:choose>
                                    <c:when test="${enrollment.completionStatus == 'Completed'}">
                                        Download your certificate
                                    </c:when>
                                    <c:otherwise>
                                        Available upon completion
                                    </c:otherwise>
                                </c:choose>
                            </p>
                            <c:choose>
                                <c:when test="${enrollment.completionStatus == 'Completed'}">
                                    <a href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${enrollment.enrollmentId}" class="btn btn-warning btn-sm">
                                        Download
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button class="btn btn-secondary btn-sm" disabled>Not Available</button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>
        
        <!-- Pending Payment Notice -->
        <c:if test="${enrollment.paymentStatus != 'Paid'}">
            <div class="alert alert-warning">
                <h5 class="alert-heading"><i class="fas fa-exclamation-triangle me-2"></i>Payment Required</h5>
                <p>You need to complete your payment to access course materials and assessments.</p>
                <a href="${pageContext.request.contextPath}/student/payment?enrollmentId=${enrollment.enrollmentId}" class="btn btn-warning">
                    <i class="fas fa-credit-card me-2"></i>Complete Payment
                </a>
            </div>
        </c:if>
        
        <!-- Action Buttons -->
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-2"></i>Back to My Enrollments
            </a>
        </div>
    </div>
    
    <jsp:include page="../common/footer.jsp"/>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
