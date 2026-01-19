<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Management - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
        <jsp:param name="pageTitle" value="Enrollment Management"/>
    </jsp:include>

    <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

    <main class="app-main">
        <div class="content-wrapper">
            <!-- Initialize counters -->
            <c:set var="totalCount" value="${empty enrollments ? 0 : fn:length(enrollments)}"/>
            <c:set var="paidCount" value="0"/>
            <c:set var="pendingCount" value="0"/>
            <c:set var="totalRevenue" value="0"/>
            <c:forEach items="${enrollments}" var="e">
                <c:set var="ps" value="${e.paymentStatus}"/>
                <c:choose>
                    <c:when test="${ps eq 'success' or ps eq 'Success' or ps eq 'SUCCESS' or ps eq 'paid' or ps eq 'Paid' or ps eq 'PAID'}">
                        <c:set var="paidCount" value="${paidCount + 1}"/>
                        <c:choose>
                            <c:when test="${e.coursePrice != null}">
                                <c:set var="totalRevenue" value="${totalRevenue + e.coursePrice}"/>
                            </c:when>
                        </c:choose>
                    </c:when>
                    <c:when test="${ps eq 'pending' or ps eq 'Pending' or ps eq 'PENDING'}">
                        <c:set var="pendingCount" value="${pendingCount + 1}"/>
                    </c:when>
                </c:choose>
            </c:forEach>

            <!-- Alerts -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${successMessage}
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> ${errorMessage}
                </div>
            </c:if>

            <!-- Enrollment Statistics -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Enrollment Statistics</h2>
                </div>
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-label">Total Enrollments</div>
                        <div class="metric-value">${totalCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Paid Enrollments</div>
                        <div class="metric-value">${paidCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Pending Payment</div>
                        <div class="metric-value">${pendingCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Total Revenue</div>
                        <div class="metric-value">₦<fmt:formatNumber value="${totalRevenue}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                    </div>
                </div>
            </section>
            <!-- Enrollments Table -->
            <section class="section-card">
                <div class="section-header">
                    <h2>All Enrollments</h2>
                </div>
                <c:choose>
                    <c:when test="${empty enrollments}">
                        <div style="text-align: center; padding: 40px; color: var(--color-text-light);">
                            <i class="fas fa-inbox fa-2x" style="display: block; margin-bottom: 10px;"></i>
                            <p>No enrollments found</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrapper">
                            <table id="enrollmentsTable" class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Student</th>
                                        <th>Email</th>
                                        <th>Course</th>
                                        <th>Amount (₦)</th>
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
                                            <td><strong>${enrollment.studentName}</strong></td>
                                            <td>${enrollment.studentEmail}</td>
                                            <td>${enrollment.courseName}</td>
                                            <td style="text-align: right;"><fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${enrollment.status == 'Enrolled' or enrollment.status == 'enrolled'}">
                                                        <span class="status-badge status-success">Enrolled</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.status == 'Pending' or enrollment.status == 'pending'}">
                                                        <span class="status-badge status-warning">Pending</span>
                                                    </c:when>
                                                    <c:when test="${enrollment.status == 'Cancelled' or enrollment.status == 'cancelled'}">
                                                        <span class="status-badge status-danger">Cancelled</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge status-secondary">${enrollment.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:set var="ps" value="${enrollment.paymentStatus}"/>
                                                <c:choose>
                                                    <c:when test="${ps eq 'success' or ps eq 'Success' or ps eq 'SUCCESS' or ps eq 'paid' or ps eq 'Paid' or ps eq 'PAID'}">
                                                        <span class="status-badge status-success">Paid</span>
                                                    </c:when>
                                                    <c:when test="${ps eq 'pending' or ps eq 'Pending' or ps eq 'PENDING'}">
                                                        <span class="status-badge status-warning">Pending</span>
                                                    </c:when>
                                                    <c:when test="${ps eq 'failed' or ps eq 'Failed' or ps eq 'FAILED'}">
                                                        <span class="status-badge status-danger">Failed</span>
                                                    </c:when>
                                                    <c:when test="${ps eq 'abandoned' or ps eq 'Abandoned' or ps eq 'ABANDONED'}">
                                                        <span class="status-badge status-secondary">Abandoned</span>
                                                    </c:when>
                                                    <c:when test="${empty ps or ps eq 'null'}">
                                                        <span class="status-badge status-warning">Pending</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge status-secondary">${ps}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty enrollment.paymentRef}">
                                                        <code style="font-size: 11px; background: var(--color-background); padding: 2px 6px; border-radius: 2px;">${enrollment.paymentRef}</code>
                                                    </c:when>
                                                    <c:otherwise>—</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">${enrollment.completionStatus}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${enrollment.enrollmentDate != null}">
                                                        ${enrollment.enrollmentDate.toString().substring(0, 10)}
                                                    </c:when>
                                                    <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-size: 13px;">
                                                <a href="${pageContext.request.contextPath}/admin/enrollment-details?id=${enrollment.enrollmentId}" class="link"><i class="fas fa-eye"></i> View</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <!-- DataTables styling and initialization -->
            <style>
                .dataTables_wrapper { padding: 15px 0; }
                .dataTables_length, .dataTables_filter { margin-bottom: 15px; }
                .dataTables_length label, .dataTables_filter label { display:flex; align-items:center; gap:10px; font-size:14px; color: var(--color-text); font-weight:500; }
                .dataTables_length select, .dataTables_filter input { padding:8px 12px; border:1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); font-size:14px; margin:0 5px; border-radius: 2px; }
                .dataTables_length select:focus, .dataTables_filter input:focus { outline:none; border-color: var(--color-primary); }
                .dataTables_info { padding:15px 0; color: var(--color-text-light); font-size:14px; }
                .dataTables_paginate { padding:15px 0; }
                .dataTables_paginate .paginate_button { padding:6px 12px; margin:0 2px; border:1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); cursor:pointer; font-size:14px; border-radius: 2px; }
                .dataTables_paginate .paginate_button:hover { background: var(--color-background); border-color: var(--color-primary); color: var(--color-primary); }
                .dataTables_paginate .paginate_button.current { background: var(--color-primary); border-color: var(--color-primary); color:#fff; font-weight:600; }
                .dataTables_paginate .paginate_button.disabled { opacity:0.5; cursor:not-allowed; }
                .dataTables_length { float:left; } .dataTables_filter { float:right; }
                .dataTables_info { float:left; clear:both; } .dataTables_paginate { float:right; clear:both; }
                @media (max-width:768px){ .dataTables_length, .dataTables_filter, .dataTables_info, .dataTables_paginate { float:none; text-align:center; margin:10px 0; } .dataTables_length label, .dataTables_filter label { justify-content:center; } }
            </style>
        </div>
    </main>

    <script>
        $(document).ready(function() {
            if ($('#enrollmentsTable').length && $('#enrollmentsTable tbody tr').length > 1) {
                $('#enrollmentsTable').DataTable({
                    order: [[0, 'desc']],
                    pageLength: 25,
                    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                    language: {
                        search: "Search enrollments:",
                        lengthMenu: "Show _MENU_ entries",
                        info: "Showing _START_ to _END_ of _TOTAL_ enrollments",
                        infoEmpty: "Showing 0 to 0 of 0 enrollments",
                        infoFiltered: "(filtered from _MAX_ total enrollments)",
                        zeroRecords: "No matching enrollments found",
                        emptyTable: "No enrollments available",
                        paginate: { first: "First", last: "Last", next: "Next", previous: "Previous" }
                    },
                    columnDefs: [
                        { orderable: true, targets: [0, 1, 2, 3, 4, 9] },
                        { orderable: false, targets: [5, 6, 7, 8, 10] }
                    ]
                });
            }
        });
    </script>
</body>
</html>
