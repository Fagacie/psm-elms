<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment History - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Payment History"/>
<c:set var="topbarSubtitle" value="Review successful, pending, and failed payments"/>
<c:set var="topbarShowSearch" value="false"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="payments"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main ef-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>Payments</span>
        </div>

        <section class="sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 24px; margin-bottom: 20px;">
            <div style="display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; align-items: start; margin-bottom: 20px;">
                <div style="max-width: 760px;">
                    <h2 style="margin: 0 0 8px; font-size: 1.5rem; font-weight: 800; letter-spacing: -0.03em; color: var(--sv-foreground);">Payment history</h2>
                    <p style="margin: 0; color: var(--sv-muted); line-height: 1.6;">Track every transaction linked to your enrollments, then open a simple receipt modal for the full record.</p>
                </div>
                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/courses"><i class="fas fa-compass"></i> Browse Courses</a>
                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/my-enrollments"><i class="fas fa-book-open-reader"></i> My Courses</a>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px;">
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 16px;">
                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Transactions</span>
                    <strong style="font-size: 1.4rem; color: var(--sv-foreground);">${allPaymentCount}</strong>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(16, 185, 129, 0.06); padding: 16px;">
                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Successful</span>
                    <strong style="font-size: 1.4rem; color: #10b981;">${paidCount}</strong>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(245, 158, 11, 0.08); padding: 16px;">
                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Pending</span>
                    <strong style="font-size: 1.4rem; color: #d97706;">${pendingCount}</strong>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(239, 68, 68, 0.06); padding: 16px;">
                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Failed</span>
                    <strong style="font-size: 1.4rem; color: #ef4444;">${failedCount}</strong>
                </div>
            </div>
        </section>

        <section class="sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 24px;">
            <div style="display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; align-items: center; margin-bottom: 18px;">
                <div>
                    <h3 style="margin: 0; font-size: 1.15rem; font-weight: 800; color: var(--sv-foreground);">Transactions table</h3>
                    <p style="margin: 4px 0 0; color: var(--sv-muted); font-size: 0.88rem;">Use the receipt action to print or save a clean payment record.</p>
                </div>
                <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                    <a class="sv-btn ${empty statusFilter ? 'primary' : ''}" href="${pageContext.request.contextPath}/student/payments">All</a>
                    <a class="sv-btn ${statusFilter == 'Paid' ? 'primary' : ''}" href="${pageContext.request.contextPath}/student/payments?status=paid">Paid</a>
                    <a class="sv-btn ${statusFilter == 'Pending' ? 'primary' : ''}" href="${pageContext.request.contextPath}/student/payments?status=pending">Pending</a>
                    <a class="sv-btn ${statusFilter == 'Failed' ? 'primary' : ''}" href="${pageContext.request.contextPath}/student/payments?status=failed">Failed</a>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty payments}">
                    <div class="empty-state-box" style="padding: 44px 18px;">
                        <i class="fas fa-receipt"></i>
                        <h3>No payments found</h3>
                        <p>Once you complete a course payment, the transaction will appear here with a receipt link.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto;">
                        <table style="width: 100%; border-collapse: collapse; min-width: 760px;">
                            <thead>
                                <tr style="text-align: left; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em;">
                                    <th style="padding: 14px 12px; border-bottom: 1px solid var(--sv-border);">Course</th>
                                    <th style="padding: 14px 12px; border-bottom: 1px solid var(--sv-border);">Amount</th>
                                    <th style="padding: 14px 12px; border-bottom: 1px solid var(--sv-border);">Status</th>
                                    <th style="padding: 14px 12px; border-bottom: 1px solid var(--sv-border);">Date</th>
                                    <th style="padding: 14px 12px; border-bottom: 1px solid var(--sv-border);">Receipt</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="payment" items="${payments}">
                                    <tr style="border-bottom: 1px solid var(--sv-border);">
                                        <td style="padding: 16px 12px; vertical-align: top;">
                                            <strong style="display: block; color: var(--sv-foreground);">${payment.courseName}</strong>
                                        </td>
                                        <td style="padding: 16px 12px; vertical-align: top; white-space: nowrap;">
                                            <strong style="color: var(--sv-foreground);">₦<fmt:formatNumber value="${payment.amount}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                        </td>
                                        <td style="padding: 16px 12px; vertical-align: top;">
                                            <c:choose>
                                                <c:when test="${payment.status == 'Paid'}"><span class="sa-status status-Approved">Paid</span></c:when>
                                                <c:when test="${payment.status == 'Pending'}"><span class="sa-status status-Pending">Pending</span></c:when>
                                                <c:when test="${payment.status == 'Failed'}"><span class="sa-status status-Archived">Failed</span></c:when>
                                                <c:otherwise><span class="sa-status status-Pending">${payment.status}</span></c:otherwise>
                                            </c:choose>
                                            <div style="margin-top: 6px; color: var(--sv-muted); font-size: 0.8rem;">${not empty payment.method ? payment.method : 'Gateway'}</div>
                                        </td>
                                        <td style="padding: 16px 12px; vertical-align: top; white-space: nowrap; color: var(--sv-muted);">
                                            <c:choose>
                                                <c:when test="${not empty payment.paymentDate}">${fn:replace(payment.paymentDate, 'T', ' ')}</c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 16px 12px; vertical-align: top; white-space: nowrap;">
                                            <button type="button"
                                                    class="sv-btn primary"
                                                    style="height: 36px; display: inline-flex; align-items: center; gap: 6px; padding: 0 14px; border-radius: 8px;"
                                                    data-payment-modal-trigger
                                                    data-payment-id="${payment.paymentId}"
                                                    data-payment-course="${fn:escapeXml(payment.courseName)}"
                                                    data-payment-student="${fn:escapeXml(payment.studentName)}"
                                                    data-payment-amount="${payment.amount}"
                                                    data-payment-status="${fn:escapeXml(payment.status)}"
                                                    data-payment-date="${not empty payment.paymentDate ? fn:replace(payment.paymentDate, 'T', ' ') : '-'}"
                                                    data-payment-ref="${fn:escapeXml(not empty payment.paymentRef ? payment.paymentRef : '-') }"
                                                    data-payment-gateway-ref="${fn:escapeXml(not empty payment.paystackReference ? payment.paystackReference : '-') }"
                                                    data-payment-method="${fn:escapeXml(not empty payment.method ? payment.method : 'Gateway') }"
                                                    data-payment-enrollment-id="${payment.enrollmentId}">
                                                <i class="fas fa-file-invoice"></i> Receipt
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </main>
</div>

<div id="paymentReceiptModal" style="display: none; position: fixed; inset: 0; z-index: 1200; align-items: center; justify-content: center; padding: 20px;">
    <div id="paymentReceiptBackdrop" style="position: absolute; inset: 0; background: rgba(15, 23, 42, 0.55);"></div>
    <section style="position: relative; width: min(760px, 100%); max-height: min(86vh, 820px); overflow: auto; background: var(--sv-surface); border: 1px solid var(--sv-border); border-radius: 18px; box-shadow: var(--sv-shadow-xl); padding: 24px;">
        <div style="display: flex; justify-content: space-between; gap: 16px; align-items: start; margin-bottom: 18px;">
            <div>
                <span style="display: inline-flex; align-items: center; gap: 8px; padding: 6px 10px; border-radius: 999px; background: rgba(59, 130, 246, 0.08); color: #2563eb; font-weight: 700; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em;">
                    <i class="fas fa-file-invoice"></i> Receipt
                </span>
                <h3 id="paymentModalCourse" style="margin: 12px 0 4px; font-size: 1.35rem; font-weight: 800; color: var(--sv-foreground);">Payment receipt</h3>
                <p style="margin: 0; color: var(--sv-muted);">Simple transaction summary for printing or review.</p>
            </div>
            <button type="button" id="paymentReceiptClose" class="sv-btn" style="height: 40px; padding: 0 14px;"><i class="fas fa-xmark"></i></button>
        </div>

        <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; margin-bottom: 18px;">
            <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 14px;">
                <span style="display: block; color: var(--sv-muted); font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Student</span>
                <strong id="paymentModalStudent" style="color: var(--sv-foreground);"></strong>
            </div>
            <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 14px;">
                <span style="display: block; color: var(--sv-muted); font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Status</span>
                <strong id="paymentModalStatus" style="color: var(--sv-foreground);"></strong>
            </div>
            <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 14px;">
                <span style="display: block; color: var(--sv-muted); font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Amount</span>
                <strong id="paymentModalAmount" style="color: var(--sv-foreground);"></strong>
            </div>
            <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 14px;">
                <span style="display: block; color: var(--sv-muted); font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px;">Date</span>
                <strong id="paymentModalDate" style="color: var(--sv-foreground);"></strong>
            </div>
        </div>

        <div style="border-top: 1px solid var(--sv-border); padding-top: 18px; display: grid; gap: 12px;">
            <div style="display: grid; grid-template-columns: 180px 1fr; gap: 12px; align-items: start;">
                <span style="color: var(--sv-muted); font-size: 0.82rem;">Payment reference</span>
                <strong id="paymentModalRef" style="color: var(--sv-foreground); word-break: break-word;"></strong>
            </div>
            <div style="display: grid; grid-template-columns: 180px 1fr; gap: 12px; align-items: start;">
                <span style="color: var(--sv-muted); font-size: 0.82rem;">Gateway reference</span>
                <strong id="paymentModalGatewayRef" style="color: var(--sv-foreground); word-break: break-word;"></strong>
            </div>
            <div style="display: grid; grid-template-columns: 180px 1fr; gap: 12px; align-items: start;">
                <span style="color: var(--sv-muted); font-size: 0.82rem;">Payment method</span>
                <strong id="paymentModalMethod" style="color: var(--sv-foreground);"></strong>
            </div>
            <div style="display: grid; grid-template-columns: 180px 1fr; gap: 12px; align-items: start;">
                <span style="color: var(--sv-muted); font-size: 0.82rem;">Enrollment ID</span>
                <strong id="paymentModalEnrollmentId" style="color: var(--sv-foreground);"></strong>
            </div>
        </div>

        <div style="margin-top: 18px; padding-top: 16px; border-top: 1px solid var(--sv-border); display: flex; gap: 10px; flex-wrap: wrap; justify-content: flex-end;">
            <button type="button" class="sv-btn" onclick="window.print()"><i class="fas fa-print"></i> Print</button>
            <a id="paymentModalOpenCourse" class="sv-btn" href="#"><i class="fas fa-layer-group"></i> Open Course</a>
            <button type="button" id="paymentReceiptCloseSecondary" class="sv-btn primary"><i class="fas fa-check"></i> Done</button>
        </div>
    </section>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script>
(function () {
    var modal = document.getElementById('paymentReceiptModal');
    var backdrop = document.getElementById('paymentReceiptBackdrop');
    var triggers = document.querySelectorAll('[data-payment-modal-trigger]');
    var closeButtons = [document.getElementById('paymentReceiptClose'), document.getElementById('paymentReceiptCloseSecondary')];
    var modalCourse = document.getElementById('paymentModalCourse');
    var modalStudent = document.getElementById('paymentModalStudent');
    var modalStatus = document.getElementById('paymentModalStatus');
    var modalAmount = document.getElementById('paymentModalAmount');
    var modalDate = document.getElementById('paymentModalDate');
    var modalRef = document.getElementById('paymentModalRef');
    var modalGatewayRef = document.getElementById('paymentModalGatewayRef');
    var modalMethod = document.getElementById('paymentModalMethod');
    var modalEnrollmentId = document.getElementById('paymentModalEnrollmentId');
    var modalCourseLink = document.getElementById('paymentModalOpenCourse');

    function formatAmount(rawAmount) {
        var number = Number(rawAmount);
        if (!isFinite(number)) {
            return rawAmount || '-';
        }
        return '₦' + number.toLocaleString('en-NG', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function openModal(trigger) {
        if (!trigger || !modal || !backdrop) {
            return;
        }
        modalCourse.textContent = trigger.getAttribute('data-payment-course') || 'Payment receipt';
        modalStudent.textContent = trigger.getAttribute('data-payment-student') || '-';
        modalStatus.textContent = trigger.getAttribute('data-payment-status') || '-';
        modalAmount.textContent = formatAmount(trigger.getAttribute('data-payment-amount'));
        modalDate.textContent = trigger.getAttribute('data-payment-date') || '-';
        modalRef.textContent = trigger.getAttribute('data-payment-ref') || '-';
        modalGatewayRef.textContent = trigger.getAttribute('data-payment-gateway-ref') || '-';
        modalMethod.textContent = trigger.getAttribute('data-payment-method') || '-';
        modalEnrollmentId.textContent = trigger.getAttribute('data-payment-enrollment-id') ? '#' + trigger.getAttribute('data-payment-enrollment-id') : '-';
        modalCourseLink.href = '${pageContext.request.contextPath}/student/enrollment-details?id=' + (trigger.getAttribute('data-payment-enrollment-id') || '');
        modal.style.display = 'flex';
        backdrop.style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    function openModalFromPaymentId(paymentId) {
        if (!paymentId) {
            return;
        }
        var selector = '[data-payment-modal-trigger][data-payment-id="' + paymentId + '"]';
        var trigger = document.querySelector(selector);
        if (trigger) {
            openModal(trigger);
        }
    }

    function closeModal() {
        if (modal) {
            modal.style.display = 'none';
        }
        if (backdrop) {
            backdrop.style.display = 'none';
        }
        document.body.style.overflow = '';
    }

    triggers.forEach(function (trigger) {
        trigger.addEventListener('click', function () {
            openModal(trigger);
        });
    });

    closeButtons.forEach(function (button) {
        if (button) {
            button.addEventListener('click', closeModal);
        }
    });

    if (backdrop) {
        backdrop.addEventListener('click', closeModal);
    }

    var receiptPaymentId = new URLSearchParams(window.location.search).get('receiptPaymentId');
    if (receiptPaymentId) {
        openModalFromPaymentId(receiptPaymentId);
    }

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeModal();
        }
    });
})();
</script>
</body>
</html>