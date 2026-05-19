<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Management | Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css" />
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    <style>
        /* Modern Details Modal Specific Styling */
        .details-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            margin-bottom: 8px;
        }
        .details-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
            padding: 12px 16px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
        }
        .details-item-full {
            grid-column: span 2;
        }
        .details-label {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
        }
        .details-value {
            font-size: 0.9rem;
            font-weight: 600;
            color: #0f172a;
        }
        .details-value strong {
            font-weight: 700;
        }
        .expiry-form {
            margin-top: 20px;
            padding-top: 18px;
            border-top: 1px solid #e2e8f0;
            display: grid;
            gap: 12px;
        }
        .expiry-form__head h4 {
            margin: 0;
            font-size: 0.95rem;
            font-weight: 800;
            color: #0f172a;
        }
        .expiry-form__head p {
            margin: 4px 0 0;
            font-size: 0.84rem;
            color: #64748b;
            line-height: 1.5;
        }
        .expiry-form__row {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto auto;
            gap: 10px;
            align-items: end;
        }
        .expiry-form__field {
            display: grid;
            gap: 6px;
        }
        .expiry-form__field label {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
        }
        .expiry-form__field input {
            min-height: 40px;
            padding: 0 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font: inherit;
            color: #0f172a;
            background: #fff;
        }
        .expiry-form__hint {
            font-size: 0.8rem;
            color: #64748b;
        }
    </style>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Enrollments"/>
    <jsp:param name="pageSubtitle" value="Track payments, access, and learner completion across enrollments"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <c:set var="totalCount" value="${empty enrollments ? 0 : fn:length(enrollments)}"/>
        <c:set var="paidCount" value="0"/>
        <c:set var="pendingCount" value="0"/>
        <c:set var="totalRevenue" value="0"/>
        <c:forEach items="${enrollments}" var="e">
            <c:set var="ps" value="${e.paymentStatus}"/>
            <c:choose>
                <c:when test="${ps eq 'success' or ps eq 'Success' or ps eq 'SUCCESS' or ps eq 'paid' or ps eq 'Paid' or ps eq 'PAID'}">
                    <c:set var="paidCount" value="${paidCount + 1}"/>
                    <c:if test="${e.coursePrice != null}">
                        <c:set var="totalRevenue" value="${totalRevenue + e.coursePrice}"/>
                    </c:if>
                </c:when>
                <c:when test="${ps eq 'pending' or ps eq 'Pending' or ps eq 'PENDING'}">
                    <c:set var="pendingCount" value="${pendingCount + 1}"/>
                </c:when>
            </c:choose>
        </c:forEach>

        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Enrollments</span>
            </div>
        </section>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <c:out value="${successMessage}"/>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
            </div>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Enrollment Overview</h2>
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
                    <div class="metric-value">NGN <fmt:formatNumber value="${totalRevenue}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>All Enrollments</h2>
            </div>
            <c:choose>
                <c:when test="${empty enrollments}">
                    <div class="empty-state empty-state-inset">
                        <i class="fas fa-inbox"></i>
                        <p>No enrollments found.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-wrapper">
                        <table id="enrollmentsTable" class="data-table display nowrap" style="width:100%">
                            <thead>
                                <tr>
                                    <th>Student Email</th>
                                    <th>Course Enrolled</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${enrollments}" var="enrollment">
                                    <tr 
                                        data-id="${enrollment.enrollmentId}"
                                        data-student-name="${fn:escapeXml(enrollment.studentName)}"
                                        data-student-email="${fn:escapeXml(enrollment.studentEmail)}"
                                        data-course-name="${fn:escapeXml(enrollment.courseName)}"
                                        data-course-price="${enrollment.coursePrice != null ? enrollment.coursePrice : '0.00'}"
                                        data-status="${enrollment.status}"
                                        data-payment-status="${enrollment.paymentStatus}"
                                        data-payment-ref="${enrollment.paymentRef}"
                                        data-completion="${not empty enrollment.completionStatus ? enrollment.completionStatus : 'Not Started'}"
                                        data-date="${enrollment.enrollmentDate != null ? fn:substring(enrollment.enrollmentDate.toString(), 0, 10) : 'N/A'}"
                                        data-duration="${enrollment.displayDuration}"
                                        data-expiry-date="${enrollment.effectiveEndDate != null ? fn:substring(enrollment.effectiveEndDate.toString(), 0, 10) : ''}"
                                        data-expiry-override="${enrollment.expiryDateOverride != null ? fn:substring(enrollment.expiryDateOverride.toString(), 0, 10) : ''}"
                                    >
                                        <td><c:out value="${enrollment.studentEmail}"/></td>
                                        <td><strong><c:out value="${enrollment.courseName}"/></strong></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${enrollment.status == 'Enrolled' or enrollment.status == 'enrolled' or enrollment.status == 'Active' or enrollment.status == 'active'}"><span class="status-badge status-success">Active</span></c:when>
                                                <c:when test="${enrollment.status == 'Completed' or enrollment.status == 'completed'}"><span class="status-badge status-success">Completed</span></c:when>
                                                <c:when test="${enrollment.status == 'Pending' or enrollment.status == 'pending'}"><span class="status-badge status-warning">Pending</span></c:when>
                                                <c:when test="${enrollment.status == 'Cancelled' or enrollment.status == 'cancelled'}"><span class="status-badge status-danger">Cancelled</span></c:when>
                                                <c:otherwise><span class="status-badge status-secondary"><c:out value="${enrollment.status}"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="admin-table-actions">
                                                <button type="button" class="admin-btn secondary js-view-receipt">View</button>
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

<div id="enrollmentReceiptModal" class="admin-modal" aria-hidden="true">
    <div class="admin-modal-backdrop" data-close-modal="enrollmentReceiptModal"></div>
    <div class="admin-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="receiptModalTitle" style="max-width: 600px; margin: 40px auto;">
        <div class="admin-modal-header">
            <h3 id="receiptModalTitle" class="admin-modal-title">Enrollment Information</h3>
            <button type="button" class="admin-modal-close" data-close-modal="enrollmentReceiptModal" aria-label="Close">x</button>
        </div>
        <div class="admin-modal-body" style="padding: 24px;">
            <div class="details-grid">
                <div class="details-item">
                    <span class="details-label">Enrollment ID</span>
                    <span class="details-value" id="rcpEnrollmentId">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Registration Date</span>
                    <span class="details-value" id="rcpEnrollmentDate">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Course Duration</span>
                    <span class="details-value" id="rcpCourseDuration">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Access Ends</span>
                    <span class="details-value" id="rcpExpiryDate">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Student Name</span>
                    <span class="details-value" id="rcpStudentName">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Student Email</span>
                    <span class="details-value" id="rcpStudentEmail">-</span>
                </div>
                <div class="details-item details-item-full">
                    <span class="details-label">Course Enrolled</span>
                    <span class="details-value" id="rcpCourseName">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Course Price</span>
                    <span class="details-value" id="rcpCoursePrice">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Completion Status</span>
                    <span class="details-value" id="rcpCompletionStatus">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Enrollment Status</span>
                    <span class="details-value" id="rcpStatus">-</span>
                </div>
                <div class="details-item">
                    <span class="details-label">Payment Status</span>
                    <span class="details-value" id="rcpPaymentStatus">-</span>
                </div>
                <div class="details-item details-item-full">
                    <span class="details-label">Payment Reference</span>
                    <span class="details-value" id="rcpPaymentRef" style="font-family: monospace; font-size: 0.85rem;">-</span>
                </div>
            </div>

            <form class="expiry-form" method="post" action="${pageContext.request.contextPath}/admin/enrollments">
                <div class="expiry-form__head">
                    <h4>Manage Course Expiry</h4>
                    <p>Set a custom access end date for this enrollment. Leave it blank to fall back to the normal course-duration expiry.</p>
                </div>
                <input type="hidden" name="enrollmentId" id="expiryEnrollmentId" value="">
                <div class="expiry-form__row">
                    <div class="expiry-form__field">
                        <label for="expiryDateOverride">Expiry Date Override</label>
                        <input type="date" id="expiryDateOverride" name="expiryDateOverride">
                    </div>
                    <button type="submit" class="admin-btn primary">Save Expiry</button>
                    <button type="button" class="admin-btn secondary" id="clearExpiryOverride">Clear Override</button>
                </div>
                <div class="expiry-form__hint">This is the simplest admin extension flow: update one date and the student learning hub will honor it automatically.</div>
            </form>
        </div>
        <div class="admin-modal-footer" style="display: flex; justify-content: flex-end; gap: 10px; padding: 15px 20px; border-top: 1px solid var(--admin-border);">
            <button type="button" class="admin-btn primary" data-close-modal="enrollmentReceiptModal">Close</button>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>
    $(function() {
        if ($('#enrollmentsTable').length) {
            $('#enrollmentsTable').DataTable({
                order: [[1, 'asc']],
                pageLength: 25,
                lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                language: {
                    search: 'Search enrollments:',
                    lengthMenu: 'Show _MENU_ entries',
                    info: 'Showing _START_ to _END_ of _TOTAL_ enrollments',
                    infoEmpty: 'Showing 0 to 0 of 0 enrollments',
                    infoFiltered: '(filtered from _MAX_ total enrollments)',
                    zeroRecords: 'No matching enrollments found',
                    emptyTable: 'No enrollments available',
                    paginate: { first: 'First', last: 'Last', next: 'Next', previous: 'Previous' }
                },
                columnDefs: [
                    { orderable: true, targets: [0, 1, 2] },
                    { orderable: false, targets: [3] }
                ]
            });
        }

        var receiptModal = $('#enrollmentReceiptModal');
        
        function openModal(modal) {
            modal.addClass('active').attr('aria-hidden', 'false');
            $('body').addClass('admin-modal-open');
        }
        
        function closeModal(modal) {
            modal.removeClass('active').attr('aria-hidden', 'true');
            $('body').removeClass('admin-modal-open');
        }
        
        $(document).on('click', '[data-close-modal]', function() {
            var targetId = $(this).attr('data-close-modal');
            closeModal($('#' + targetId));
        });
        
        $(document).on('click', '.js-view-receipt', function(e) {
            e.preventDefault();
            var row = $(this).closest('tr');
            
            $('#rcpEnrollmentId').text('#' + (row.data('id') || '-'));
            $('#rcpEnrollmentDate').text(row.data('date') || '-');
            $('#rcpCourseDuration').text(row.data('duration') || '-');
            $('#rcpExpiryDate').text(row.data('expiry-date') || '-');
            $('#rcpStudentName').text(row.data('student-name') || '-');
            $('#rcpStudentEmail').text(row.data('student-email') || '-');
            $('#rcpCourseName').text(row.data('course-name') || '-');
            $('#expiryEnrollmentId').val(row.data('id') || '');
            $('#expiryDateOverride').val(row.data('expiry-override') || '');
            
            var price = row.data('course-price');
            if (price) {
                var amt = parseFloat(price);
                if (!isNaN(amt)) {
                    price = 'NGN ' + amt.toLocaleString('en-NG', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                }
            }
            $('#rcpCoursePrice').text(price || 'Free');
            
            var status = row.data('status') || '-';
            $('#rcpStatus').text(status.charAt(0).toUpperCase() + status.slice(1));
            
            var pStatus = row.data('payment-status') || '-';
            $('#rcpPaymentStatus').text(pStatus.charAt(0).toUpperCase() + pStatus.slice(1));
            
            $('#rcpPaymentRef').text(row.data('payment-ref') || 'N/A');
            $('#rcpCompletionStatus').text(row.data('completion') || 'Not Started');
            
            openModal(receiptModal);
        });
        
        $(document).on('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal(receiptModal);
            }
        });

        $('#clearExpiryOverride').on('click', function() {
            $('#expiryDateOverride').val('');
        });
    });
</script>
</body>
</html>
