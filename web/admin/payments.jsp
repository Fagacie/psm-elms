<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Payment Management | Admin</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css" />
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css" />
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.2/css/buttons.dataTables.min.css" />
</head>
<body class="admin-layout-body">
    <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

    <main class="admin-main-content">
        <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
            <jsp:param name="pageTitle" value="Payment Management" />
            <jsp:param name="pageSubtitle" value="Track transactions, monitor statuses, and inspect payment records." />
        </jsp:include>

        <div class="admin-page-content">
            <div class="admin-breadcrumb">Dashboard &gt; Payments</div>

            <c:if test="${not empty success}">
                <div class="admin-alert admin-alert-success">
                    <span>${success}</span>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="admin-alert admin-alert-danger">
                    <span>${error}</span>
                </div>
            </c:if>

            <section class="admin-section-card">
                <div class="admin-card-header-row">
                    <h2 class="admin-card-title">Payment Records</h2>
                </div>

                <div class="admin-table-toolbar">
                    <span class="admin-code">Live list</span>
                    <span class="table-subtext">Use search, paging, and export actions from the table controls.</span>
                </div>

                <div class="admin-table-wrap">
                    <table id="paymentsTable" class="admin-table display nowrap" style="width:100%">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Ref</th>
                                <th>Student</th>
                                <th>Course</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Paid At</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${payments}">
                                <tr>
                                    <td>${p.id}</td>
                                    <td>${p.reference}</td>
                                    <td>${p.studentName}</td>
                                    <td>${p.courseTitle}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.currency ne null and p.currency ne ''}">${p.currency}</c:when>
                                            <c:otherwise>MYR</c:otherwise>
                                        </c:choose>
                                        ${p.amount}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.status eq 'SUCCESS'}"><span class="status-badge status-published">SUCCESS</span></c:when>
                                            <c:when test="${p.status eq 'PENDING'}"><span class="status-badge status-draft">PENDING</span></c:when>
                                            <c:otherwise><span class="status-badge status-unpublished">${p.status}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${p.paidAt}</td>
                                    <td>
                                        <div class="admin-table-actions">
                                            <a class="admin-btn" href="${pageContext.request.contextPath}/admin/payments/view?id=${p.id}">View</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.html5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

    <script>
        $(function() {
            $('#paymentsTable').DataTable({
                order: [[0, 'desc']],
                pageLength: 10,
                lengthMenu: [[10, 25, 50, 100], [10, 25, 50, 100]],
                dom: 'Bfrtip',
                buttons: [
                    { extend: 'csvHtml5', title: 'payments_export' },
                    { extend: 'excelHtml5', title: 'payments_export' }
                ],
                responsive: true
            });
        });
    </script>
</body>
</html>
