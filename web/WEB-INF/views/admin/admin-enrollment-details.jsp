<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Details - Admin - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .info-card {
            border-left: 4px solid #0d6efd;
        }
        .detail-row {
            padding: 0.75rem 0;
            border-bottom: 1px solid #e9ecef;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
        <jsp:param name="pageTitle" value="Enrollment Details"/>
    </jsp:include>
    <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>
    
    <main class="app-main">
    <div class="content-wrapper">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/enrollments">Enrollments</a></li>
                <li class="breadcrumb-item active">Enrollment #${enrollment.enrollmentId}</li>
            </ol>
        </nav>
        
        <!-- Enrollment Header -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                <h4 class="mb-0">Enrollment Details - #${enrollment.enrollmentId}</h4>
                <div>
                    <c:choose>
                        <c:when test="${enrollment.status == 'Enrolled'}">
                            <span class="badge bg-light text-dark fs-6">Enrolled</span>
                        </c:when>
                        <c:when test="${enrollment.status == 'Pending'}">
                            <span class="badge bg-warning fs-6">Pending</span>
                        </c:when>
                        <c:when test="${enrollment.status == 'Cancelled'}">
                            <span class="badge bg-danger fs-6">Cancelled</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-secondary fs-6">${enrollment.status}</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <div class="row">
            <!-- Left Column -->
            <div class="col-md-6 mb-4">
                <!-- Student Information -->
                <div class="card info-card mb-4">
                    <div class="card-body">
                        <h5 class="card-title"><i class="fas fa-user me-2"></i>Student Information</h5>
                        <hr>
                        <div class="detail-row">
                            <small class="text-muted">Student Name</small>
                            <div class="fw-bold">${enrollment.studentName}</div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Email</small>
                            <div>${enrollment.studentEmail}</div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">User ID</small>
                            <div>#${enrollment.userId}</div>
                        </div>
                    </div>
                </div>
                
                <!-- Course Information -->
                <div class="card info-card">
                    <div class="card-body">
                        <h5 class="card-title"><i class="fas fa-book me-2"></i>Course Information</h5>
                        <hr>
                        <div class="detail-row">
                            <small class="text-muted">Course Name</small>
                            <div class="fw-bold">${enrollment.courseName}</div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Description</small>
                            <div>${enrollment.courseDescription}</div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Instructor</small>
                            <div>${enrollment.instructorName}</div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Course ID</small>
                            <div>#${enrollment.courseId}</div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right Column -->
            <div class="col-md-6 mb-4">
                <!-- Enrollment Status -->
                <div class="card info-card mb-4">
                    <div class="card-body">
                        <h5 class="card-title"><i class="fas fa-info-circle me-2"></i>Enrollment Status</h5>
                        <hr>
                        <div class="detail-row">
                            <small class="text-muted">Enrollment Status</small>
                            <div>
                                <c:choose>
                                    <c:when test="${enrollment.status == 'Enrolled'}">
                                        <span class="badge bg-success fs-6">Enrolled</span>
                                    </c:when>
                                    <c:when test="${enrollment.status == 'Pending'}">
                                        <span class="badge bg-warning text-dark fs-6">Pending</span>
                                    </c:when>
                                    <c:when test="${enrollment.status == 'Cancelled'}">
                                        <span class="badge bg-danger fs-6">Cancelled</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary fs-6">${enrollment.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Completion Status</small>
                            <div class="fw-bold">${enrollment.completionStatus}</div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Enrolled Date</small>
                            <div>
                                <c:choose>
                                    <c:when test="${enrollment.enrollmentDate != null}">
                                        ${enrollment.enrollmentDate.toString().substring(0, 10)}
                                    </c:when>
                                    <c:otherwise>N/A</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Last Updated</small>
                            <div>
                                <c:choose>
                                    <c:when test="${enrollment.updatedDate != null}">
                                        ${enrollment.updatedDate.toString().substring(0, 10)}
                                    </c:when>
                                    <c:otherwise>N/A</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Payment Information -->
                <div class="card info-card">
                    <div class="card-body">
                        <h5 class="card-title"><i class="fas fa-credit-card me-2"></i>Payment Information</h5>
                        <hr>
                        <div class="detail-row">
                            <small class="text-muted">Payment Status</small>
                            <div>
                                <c:choose>
                                    <c:when test="${enrollment.paymentStatus == 'Paid'}">
                                        <span class="badge bg-success fs-6">Paid</span>
                                    </c:when>
                                    <c:when test="${enrollment.paymentStatus == 'Pending'}">
                                        <span class="badge bg-warning text-dark fs-6">Pending</span>
                                    </c:when>
                                    <c:when test="${enrollment.paymentStatus == 'Failed'}">
                                        <span class="badge bg-danger fs-6">Failed</span>
                                    </c:when>
                                    <c:when test="${enrollment.paymentStatus == 'Abandoned'}">
                                        <span class="badge bg-secondary fs-6">Abandoned</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary fs-6">${enrollment.paymentStatus}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="detail-row">
                            <small class="text-muted">Amount</small>
                            <div class="fw-bold text-success fs-5">
                                ₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                            </div>
                        </div>
                        <c:if test="${enrollment.paymentRef != null}">
                            <div class="detail-row">
                                <small class="text-muted">Payment Reference (Paystack)</small>
                                <div class="font-monospace">${enrollment.paymentRef}</div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="card">
            <div class="card-body">
                <h5 class="card-title mb-3">Actions</h5>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/enrollments" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left me-2"></i>Back to List
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/users?action=view&id=${enrollment.userId}" class="btn btn-primary">
                        <i class="fas fa-user me-2"></i>View Student
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/courses?action=view&id=${enrollment.courseId}" class="btn btn-info text-white">
                        <i class="fas fa-book me-2"></i>View Course
                    </a>
                </div>
            </div>
        </div>
    </div>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
