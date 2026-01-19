<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.psm.elearning.model.Payment" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Management - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
        <jsp:param name="pageTitle" value="Payment Management"/>
    </jsp:include>

    <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

    <main class="app-main">
        <div class="content-wrapper">
            <!-- Gather payments list -->
            <c:set var="payments" value="${requestScope.payments}"/>
            
            <!-- Payment Statistics -->
            <c:set var="totalPayments" value="${payments != null ? payments.size() : 0}"/>
            <c:set var="paidCount" value="0"/>
            <c:set var="pendingCount" value="0"/>
            <c:set var="failedCount" value="0"/>
            <c:set var="abandonedCount" value="0"/>
            <c:set var="totalRevenue" value="0.0"/>
            <c:forEach items="${payments}" var="p">
                <c:set var="ps" value="${p.status}"/>
                <c:choose>
                    <c:when test="${ps eq 'Success' or ps eq 'success' or ps eq 'Paid' or ps eq 'paid'}">
                        <c:set var="paidCount" value="${paidCount + 1}"/>
                        <c:if test="${p.amount != null}">
                            <c:set var="totalRevenue" value="${totalRevenue + p.amount}"/>
                        </c:if>
                    </c:when>
                    <c:when test="${ps eq 'Pending' or ps eq 'pending'}">
                        <c:set var="pendingCount" value="${pendingCount + 1}"/>
                    </c:when>
                    <c:when test="${ps eq 'Failed' or ps eq 'failed'}">
                        <c:set var="failedCount" value="${failedCount + 1}"/>
                    </c:when>
                    <c:when test="${ps eq 'Abandoned' or ps eq 'abandoned'}">
                        <c:set var="abandonedCount" value="${abandonedCount + 1}"/>
                    </c:when>
                </c:choose>
            </c:forEach>

            <section class="section-card">
                <div class="section-header">
                    <h2>Payment Statistics</h2>
                </div>
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-label">Total Payments</div>
                        <div class="metric-value">${totalPayments}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Paid</div>
                        <div class="metric-value">${paidCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Pending</div>
                        <div class="metric-value">${pendingCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Failed</div>
                        <div class="metric-value">${failedCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Abandoned</div>
                        <div class="metric-value">${abandonedCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Total Revenue</div>
                        <div class="metric-value">₦<fmt:formatNumber value="${totalRevenue}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                    </div>
                </div>
            </section>

            <!-- Filters -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Filters</h2>
                </div>
                <form method="get" action="" class="filters-grid">
                    <div class="form-group">
                        <label>Status</label>
                        <select name="status" class="form-select">
                            <option value="">All</option>
                            <option value="Pending" ${"Pending".equals(request.getAttribute("status"))?"selected":""}>Pending</option>
                            <option value="Success" ${"Success".equals(request.getAttribute("status"))?"selected":""}>Success</option>
                            <option value="Failed" ${"Failed".equals(request.getAttribute("status"))?"selected":""}>Failed</option>
                            <option value="Abandoned" ${"Abandoned".equals(request.getAttribute("status"))?"selected":""}>Abandoned</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Page size</label>
                        <input type="number" name="pageSize" value="${pageSize}" min="5" max="100" class="form-input"/>
                    </div>
                    <div class="form-actions-inline">
                        <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Apply</button>
                    </div>
                </form>
            </section>

            <!-- Payments Table -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Payments</h2>
                </div>
                <div class="table-wrapper">
                    <table id="paymentsTable" class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Enrollment</th>
                                <th>Course</th>
                                <th>Student</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Method</th>
                                <th>Reference</th>
                                <th>Paid At</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${payments}" var="p">
                                <tr>
                                    <td>${p.paymentId}</td>
                                    <td>${p.enrollmentId}</td>
                                    <td><c:out value="${p.courseName}"/></td>
                                    <td><c:out value="${p.studentName}"/></td>
                                    <td>₦<fmt:formatNumber value="${p.amount}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
                                    <td>
                                        <c:set var="ps" value="${p.status}"/>
                                        <c:choose>
                                            <c:when test="${ps eq 'Success' or ps eq 'success' or ps eq 'Paid' or ps eq 'paid'}"><span class="status-badge status-success">Paid</span></c:when>
                                            <c:when test="${ps eq 'Pending' or ps eq 'pending'}"><span class="status-badge status-warning">Pending</span></c:when>
                                            <c:when test="${ps eq 'Failed' or ps eq 'failed'}"><span class="status-badge status-danger">Failed</span></c:when>
                                            <c:when test="${ps eq 'Abandoned' or ps eq 'abandoned'}"><span class="status-badge status-secondary">Abandoned</span></c:when>
                                            <c:otherwise><span class="status-badge status-secondary">${ps}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${p.method}"/></td>
                                    <td><code><c:out value="${p.paystackReference}"/></code></td>
                                    <td><c:out value="${p.paymentDate}"/></td>
                                    <td><a href="${pageContext.request.contextPath}/admin/payment?id=${p.paymentId}" class="link"><i class="fas fa-eye"></i> View</a></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- DataTables controls styling -->
            <style>
                .dataTables_wrapper { padding: 15px 0; }
                .dataTables_length, .dataTables_filter { margin-bottom: 15px; }
                .dataTables_length label, .dataTables_filter label { display:flex; align-items:center; gap:10px; font-size:14px; color: var(--color-text); font-weight:500; }
                .dataTables_length select, .dataTables_filter input { padding:8px 12px; border:1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); font-size:14px; margin:0 5px; }
                .dataTables_length select:focus, .dataTables_filter input:focus { outline:none; border-color: var(--color-primary); }
                .dataTables_info { padding:15px 0; color: var(--color-text-light); font-size:14px; }
                .dataTables_paginate { padding:15px 0; }
                .dataTables_paginate .paginate_button { padding:6px 12px; margin:0 2px; border:1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); cursor:pointer; font-size:14px; }
                .dataTables_paginate .paginate_button:hover { background: var(--color-background); border-color: var(--color-primary); color: var(--color-primary); }
                .dataTables_paginate .paginate_button.current { background: var(--color-primary); border-color: var(--color-primary); color:#fff; font-weight:600; }
                .dataTables_paginate .paginate_button.disabled { opacity:0.5; cursor:not-allowed; }
                .dataTables_length { float:left; } .dataTables_filter { float:right; }
                .dataTables_info { float:left; clear:both; } .dataTables_paginate { float:right; clear:both; }
                @media (max-width:768px){ .dataTables_length, .dataTables_filter, .dataTables_info, .dataTables_paginate { float:none; text-align:center; margin:10px 0; } .dataTables_length label, .dataTables_filter label { justify-content:center; } }
            </style>

            <script>
                $(function(){
                    if ($('#paymentsTable').length && $('#paymentsTable tbody tr').length > 0) {
                        $('#paymentsTable').DataTable({
                            order: [[0,'desc']],
                            pageLength: 25,
                            lengthMenu: [[10,25,50,100,-1],[10,25,50,100,'All']],
                            language: {
                                search: 'Search payments:',
                                lengthMenu: 'Show _MENU_ entries',
                                info: 'Showing _START_ to _END_ of _TOTAL_ payments',
                                infoEmpty: 'Showing 0 to 0 of 0 payments',
                                infoFiltered: '(filtered from _MAX_ total payments)',
                                zeroRecords: 'No matching payments found',
                                emptyTable: 'No payments available',
                                paginate: { first:'First', last:'Last', next:'Next', previous:'Previous' }
                            },
                            columnDefs: [
                                { orderable: true, targets: [0,1,2,3,4,8] },
                                { orderable: false, targets: [5,6,7,9] }
                            ]
                        });
                    }
                });
            </script>
        </div>
    </main>
</body>
</html>
