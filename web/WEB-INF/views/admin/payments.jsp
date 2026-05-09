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
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Payments"/>
    <jsp:param name="pageSubtitle" value="Track transactions, monitor statuses, and inspect payment records."/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <c:set var="paymentCount" value="${empty payments ? 0 : payments.size()}"/>
        <c:set var="paidCount" value="0"/>
        <c:set var="pendingCount" value="0"/>
        <c:set var="abandonedCount" value="0"/>
        <c:set var="failedCount" value="0"/>
        <c:forEach var="row" items="${payments}">
            <c:choose>
                <c:when test="${row.status eq 'Paid'}">
                    <c:set var="paidCount" value="${paidCount + 1}"/>
                </c:when>
                <c:when test="${row.status eq 'Pending'}">
                    <c:set var="pendingCount" value="${pendingCount + 1}"/>
                </c:when>
                <c:when test="${row.status eq 'Failed'}">
                    <c:set var="failedCount" value="${failedCount + 1}"/>
                </c:when>
                <c:when test="${row.status eq 'Abandoned'}">
                    <c:set var="abandonedCount" value="${abandonedCount + 1}"/>
                </c:when>
            </c:choose>
        </c:forEach>

        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Payments</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Payment Operations</p>
                    <h2>Track transaction health from one clean payments workspace</h2>
                    <p>Review payment status, inspect details in context, and export records without falling back to a raw admin table experience.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <div class="admin-scene-panel">
                        <span>Total Payments</span>
                        <strong>${paymentCount}</strong>
                    </div>
                    <div class="admin-scene-panel">
                        <span>Paid</span>
                        <strong>${paidCount}</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="metrics-grid">
            <article class="metric-card">
                <span class="metric-label">Total Records</span>
                <div class="metric-value">${paymentCount}</div>
                <p class="metric-meta">All payment rows currently loaded into the workspace.</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Paid</span>
                <div class="metric-value">${paidCount}</div>
                <p class="metric-meta">Successful transactions available for audit and review.</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Pending</span>
                <div class="metric-value">${pendingCount}</div>
                <p class="metric-meta">Payments that still need completion or callback confirmation.</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Failed</span>
                <div class="metric-value">${failedCount}</div>
                <p class="metric-meta">Transactions that were declined or interrupted.</p>
            </article>
        </section>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <span><c:out value="${successMessage}"/></span></div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <span><c:out value="${errorMessage}"/></span></div>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Payment Records</h2>
            </div>
            <div class="section-actions-inset">
                <a href="${pageContext.request.contextPath}/admin/payments" class="admin-btn ${empty status ? 'primary' : 'secondary'}">All Payments</a>
                <a href="${pageContext.request.contextPath}/admin/payments?status=Paid" class="admin-btn ${status == 'Paid' ? 'primary' : 'secondary'}">Paid</a>
                <a href="${pageContext.request.contextPath}/admin/payments?status=Pending" class="admin-btn ${status == 'Pending' ? 'primary' : 'secondary'}">Pending</a>
                <a href="${pageContext.request.contextPath}/admin/payments?status=Failed" class="admin-btn ${status == 'Failed' ? 'primary' : 'secondary'}">Failed</a>
                <a href="${pageContext.request.contextPath}/admin/payments?status=Abandoned" class="admin-btn ${status == 'Abandoned' ? 'primary' : 'secondary'}">Abandoned</a>
            </div>

            <c:choose>
                <c:when test="${empty payments}">
                    <div class="empty-state empty-state-inset">
                        <i class="fas fa-credit-card"></i>
                        <strong>No payments found</strong>
                        <p>Payment records will appear here once learners begin checkout and transaction callbacks are stored.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="admin-table-toolbar">
                        <span class="admin-code">Live list</span>
                        <span class="table-subtext">Use search, paging, and export actions from the table controls.</span>
                    </div>

                    <div class="table-wrapper">
                        <table id="paymentsTable" class="data-table display nowrap" style="width:100%">
                            <thead>
                                <tr>
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
                                        <td><c:out value="${p.studentName}"/></td>
                                        <td><c:out value="${p.courseName}"/></td>
                                        <td>NGN <c:out value="${p.amount}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.status eq 'Paid'}"><span class="status-badge status-success">Paid</span></c:when>
                                                <c:when test="${p.status eq 'Pending'}"><span class="status-badge status-warning">Pending</span></c:when>
                                                <c:when test="${p.status eq 'Failed'}"><span class="status-badge status-danger">Failed</span></c:when>
                                                <c:when test="${p.status eq 'Abandoned'}"><span class="status-badge status-secondary">Abandoned</span></c:when>
                                                <c:otherwise><span class="status-badge status-secondary"><c:out value="${p.status}"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${p.paymentDate}"/></td>
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
                </c:otherwise>
            </c:choose>
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
            order: [[4, 'desc']],
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
            <button type="button" class="admin-modal-close" data-close-modal="paymentDetailModal" aria-label="Close">&times;</button>
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
