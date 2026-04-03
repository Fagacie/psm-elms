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
<body>
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Payments"/>
    <jsp:param name="pageSubtitle" value="Track transactions, monitor statuses, and inspect payment records."/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Payments</span>
            </div>
        </section>

        <c:if test="${not empty success}">
            <div class="alert alert-success"><span>${success}</span></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-error"><span>${error}</span></div>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Payment Records</h2>
            </div>

            <div class="admin-table-toolbar">
                <span class="admin-code">Live list</span>
                <span class="table-subtext">Use search, paging, and export actions from the table controls.</span>
            </div>

            <div class="table-wrapper">
                <table id="paymentsTable" class="data-table display nowrap" style="width:100%">
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
                                <td>${p.paymentId}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty p.paystackReference}">${p.paystackReference}</c:when>
                                        <c:otherwise>${p.paymentRef}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${p.studentName}</td>
                                <td>${p.courseName}</td>
                                <td>NGN ${p.amount}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status eq 'Paid'}"><span class="status-badge status-success">Paid</span></c:when>
                                        <c:when test="${p.status eq 'Pending'}"><span class="status-badge status-warning">Pending</span></c:when>
                                        <c:when test="${p.status eq 'Failed'}"><span class="status-badge status-danger">Failed</span></c:when>
                                        <c:otherwise><span class="status-badge status-secondary">${p.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${p.paymentDate}</td>
                                <td>
                                    <div class="admin-table-actions">
                                        <button type="button" class="admin-btn js-open-payment-modal" data-payment-url="${pageContext.request.contextPath}/admin/payment?id=${p.paymentId}&modal=1">View</button>
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

<div id="paymentDetailModal" class="admin-modal" aria-hidden="true">
    <div class="admin-modal-backdrop" data-close-modal="paymentDetailModal"></div>
    <div class="admin-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="paymentDetailModalTitle">
        <div class="admin-modal-header">
            <h3 id="paymentDetailModalTitle" class="admin-modal-title">Payment Detail</h3>
            <button type="button" class="admin-modal-close" data-close-modal="paymentDetailModal" aria-label="Close">x</button>
        </div>
        <iframe id="paymentDetailModalFrame" class="admin-modal-iframe" title="Payment Detail"></iframe>
    </div>
</div>

<script>
    (function() {
        var modal = document.getElementById('paymentDetailModal');
        var frame = document.getElementById('paymentDetailModalFrame');
        var openButtons = document.querySelectorAll('.js-open-payment-modal');
        var closeButtons = document.querySelectorAll('[data-close-modal="paymentDetailModal"]');

        function openModal(url) {
            frame.src = url;
            modal.classList.add('active');
            modal.setAttribute('aria-hidden', 'false');
            document.body.classList.add('admin-modal-open');
        }

        function closeModal() {
            modal.classList.remove('active');
            modal.setAttribute('aria-hidden', 'true');
            document.body.classList.remove('admin-modal-open');
            frame.src = 'about:blank';
        }

        openButtons.forEach(function(btn) {
            btn.addEventListener('click', function() {
                openModal(btn.getAttribute('data-payment-url'));
            });
        });

        closeButtons.forEach(function(btn) {
            btn.addEventListener('click', closeModal);
        });

        document.addEventListener('keydown', function(evt) {
            if (evt.key === 'Escape' && modal.classList.contains('active')) {
                closeModal();
            }
        });
    })();
</script>
</body>
</html>
