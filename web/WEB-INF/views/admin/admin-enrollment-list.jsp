<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Management - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css">
</head>
<body>
    <jsp:include page="../common/navbar.jsp"/>
    
    <div class="container-fluid mt-4 mb-5">
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col">
                <h2><i class="fas fa-users-cog me-2"></i>Enrollment Management</h2>
                <p class="text-muted">Monitor and manage all student enrollments</p>
            </div>
        </div>
        
        <!-- Statistics Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body">
                        <h6 class="card-title">Total Enrollments</h6>
                        <h3 class="mb-0">${enrollments.size()}</h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h6 class="card-title">Paid Enrollments</h6>
                        <h3 class="mb-0">
                            <c:set var="paidCount" value="0"/>
                            <c:forEach items="${enrollments}" var="e">
                                <c:if test="${e.paymentStatus == 'Paid'}">
                                    <c:set var="paidCount" value="${paidCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${paidCount}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-warning text-dark">
                    <div class="card-body">
                        <h6 class="card-title">Pending Payment</h6>
                        <h3 class="mb-0">
                            <c:set var="pendingCount" value="0"/>
                            <c:forEach items="${enrollments}" var="e">
                                <c:if test="${e.paymentStatus == 'Pending'}">
                                    <c:set var="pendingCount" value="${pendingCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${pendingCount}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-info text-white">
                    <div class="card-body">
                        <h6 class="card-title">Total Revenue</h6>
                        <h3 class="mb-0">
                            <c:set var="totalRevenue" value="0"/>
                            <c:forEach items="${enrollments}" var="e">
                                <c:if test="${e.paymentStatus == 'Paid'}">
                                    <c:set var="totalRevenue" value="${totalRevenue + e.coursePrice}"/>
                                </c:if>
                            </c:forEach>
                            <fmt:formatNumber value="${totalRevenue}" type="currency"/>
                        </h3>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Enrollments Table -->
        <div class="card">
            <div class="card-header bg-white">
                <h5 class="mb-0">All Enrollments</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty enrollments}">
                        <div class="text-center p-5">
                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                            <p class="text-muted">No enrollments found</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table id="enrollmentsTable" class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Student</th>
                                        <th>Email</th>
                                        <th>Course</th>
                                        <th>Amount</th>
                                        <th>Status</th>
                                        <th>Payment</th>
                                        <th>Reference</th>
                                        <th>Progress</th>
                                        <th>Enrolled Date</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${enrollments}" var="enrollment">
                                        <tr>
                                            <td>#${enrollment.enrollmentId}</td>
                                            <td>${enrollment.studentName}</td>
                                            <td>${enrollment.studentEmail}</td>
                                            <td>${enrollment.courseName}</td>
                                            <td class="text-success fw-bold">
                                                <fmt:formatNumber value="${enrollment.coursePrice}" type="currency"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${enrollment.status == 'Enrolled'}">
                                                        <span class="badge bg-success">Enrolled</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.status == 'Pending'}">
                                                        <span class="badge bg-warning text-dark">Pending</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.status == 'Cancelled'}">
                                                        <span class="badge bg-danger">Cancelled</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${enrollment.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${enrollment.paymentStatus == 'Paid'}">
                                                        <span class="badge bg-success">Paid</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.paymentStatus == 'Pending'}">
                                                        <span class="badge bg-warning text-dark">Pending</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.paymentStatus == 'Failed'}">
                                                        <span class="badge bg-danger">Failed</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.paymentStatus == 'Abandoned'}">
                                                        <span class="badge bg-secondary">Abandoned</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${enrollment.paymentStatus}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="font-monospace">
                                                <c:choose>
                                                    <c:when test="${not empty enrollment.paymentRef}">
                                                        ${enrollment.paymentRef}
                                                    </c:when>
                                                    <c:otherwise>—</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${enrollment.completionStatus}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${enrollment.enrollmentDate != null}">
                                                        ${enrollment.enrollmentDate.toString().substring(0, 10)}
                                                    </c:when>
                                                    <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/admin/enrollment-details?id=${enrollment.enrollmentId}" 
                                                   class="btn btn-sm btn-primary">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    
    <jsp:include page="../common/footer.jsp"/>
    
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#enrollmentsTable').DataTable({
                order: [[0, 'desc']],
                pageLength: 25,
                language: {
                    search: "Search enrollments:",
                    lengthMenu: "Show _MENU_ entries"
                }
            });
        });
    </script>
</body>
</html>
