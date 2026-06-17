<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Receipt - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
    <style>
        @media print {
            .receipt-actions,
            .sv-topbar,
            .sv-sidebar,
            .sv-overlay {
                display: none !important;
            }
            .sv-layout {
                display: block !important;
            }
            .sv-main {
                margin: 0 !important;
                padding: 0 !important;
            }
        }
    </style>
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Payment Receipt"/>
<c:set var="topbarSubtitle" value="Print or save a clean copy of your payment record"/>
<c:set var="topbarShowSearch" value="false"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="payments"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main ef-main-centered">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/payments">Payments</a>
            <span>/</span>
            <span>Receipt</span>
        </div>

        <section class="sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 28px; box-shadow: var(--sv-shadow-md);">
            <div style="display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; align-items: flex-start; margin-bottom: 22px;">
                <div>
                    <span style="display: inline-flex; align-items: center; gap: 8px; padding: 6px 10px; border-radius: 999px; background: rgba(16, 185, 129, 0.08); color: #10b981; font-weight: 700; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em;">
                        <i class="fas fa-receipt"></i> Payment Receipt
                    </span>
                    <h2 style="margin: 12px 0 8px; font-size: 1.55rem; font-weight: 800; letter-spacing: -0.03em; color: var(--sv-foreground);">${enrollment.courseName}</h2>
                    <p style="margin: 0; color: var(--sv-muted);">Use this record for verification, reimbursement, or personal tracking.</p>
                </div>
                <div class="receipt-actions" style="display: flex; gap: 10px; flex-wrap: wrap;">
                    <button type="button" class="sv-btn" onclick="window.print()"><i class="fas fa-print"></i> Print / Save PDF</button>
                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/payments"><i class="fas fa-clock-rotate-left"></i> Back to Payments</a>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; margin-bottom: 20px;">
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 16px;">
                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Receipt ID</span>
                    <strong style="font-size: 1rem; color: var(--sv-foreground);">${receiptCode}</strong>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 16px;">
                    <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Status</span>
                    <c:choose>
                        <c:when test="${payment.status == 'Paid'}"><span class="sa-status status-Approved">Paid</span></c:when>
                        <c:when test="${payment.status == 'Pending'}"><span class="sa-status status-Pending">Pending</span></c:when>
                        <c:when test="${payment.status == 'Failed'}"><span class="sa-status status-Archived">Failed</span></c:when>
                        <c:otherwise><span class="sa-status status-Pending">${payment.status}</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div style="border: 1px solid var(--sv-border); border-radius: 14px; overflow: hidden; margin-bottom: 20px;">
                <table style="width: 100%; border-collapse: collapse;">
                    <tbody>
                        <tr>
                            <td style="width: 34%; padding: 14px 16px; background: var(--sv-surface-soft); border-bottom: 1px solid var(--sv-border); color: var(--sv-muted);">Enrollment ID</td>
                            <td style="padding: 14px 16px; border-bottom: 1px solid var(--sv-border); color: var(--sv-foreground); font-weight: 600;">#${enrollment.enrollmentId}</td>
                        </tr>
                        <tr>
                            <td style="padding: 14px 16px; background: var(--sv-surface-soft); border-bottom: 1px solid var(--sv-border); color: var(--sv-muted);">Student</td>
                            <td style="padding: 14px 16px; border-bottom: 1px solid var(--sv-border); color: var(--sv-foreground); font-weight: 600;">${not empty studentName ? studentName : enrollment.studentName}</td>
                        </tr>
                        <tr>
                            <td style="padding: 14px 16px; background: var(--sv-surface-soft); border-bottom: 1px solid var(--sv-border); color: var(--sv-muted);">Payment reference</td>
                            <td style="padding: 14px 16px; border-bottom: 1px solid var(--sv-border); color: var(--sv-foreground); font-weight: 600;">${not empty payment.paymentRef ? payment.paymentRef : '-'}</td>
                        </tr>
                        <tr>
                            <td style="padding: 14px 16px; background: var(--sv-surface-soft); border-bottom: 1px solid var(--sv-border); color: var(--sv-muted);">Gateway reference</td>
                            <td style="padding: 14px 16px; border-bottom: 1px solid var(--sv-border); color: var(--sv-foreground); font-weight: 600;">${not empty payment.paystackReference ? payment.paystackReference : '-'}</td>
                        </tr>
                        <tr>
                            <td style="padding: 14px 16px; background: var(--sv-surface-soft); border-bottom: 1px solid var(--sv-border); color: var(--sv-muted);">Payment method</td>
                            <td style="padding: 14px 16px; border-bottom: 1px solid var(--sv-border); color: var(--sv-foreground); font-weight: 600;">${not empty payment.method ? payment.method : 'Paystack'}</td>
                        </tr>
                        <tr>
                            <td style="padding: 14px 16px; background: var(--sv-surface-soft); border-bottom: 1px solid var(--sv-border); color: var(--sv-muted);">Payment date</td>
                            <td style="padding: 14px 16px; border-bottom: 1px solid var(--sv-border); color: var(--sv-foreground); font-weight: 600;">
                                <c:choose>
                                    <c:when test="${not empty payment.paymentDate}">${fn:replace(payment.paymentDate, 'T', ' ')}</c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 14px 16px; background: var(--sv-surface-soft); border-bottom: 1px solid var(--sv-border); color: var(--sv-muted);">Amount paid</td>
                            <td style="padding: 14px 16px; border-bottom: 1px solid var(--sv-border); color: var(--sv-foreground); font-weight: 800;">₦<fmt:formatNumber value="${payment.amount}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
                        </tr>
                        <tr>
                            <td style="padding: 14px 16px; background: var(--sv-surface-soft); color: var(--sv-muted);">Enrollment status</td>
                            <td style="padding: 14px 16px; color: var(--sv-foreground); font-weight: 600;">${enrollment.paymentStatus}</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px;">
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 16px;">
                    <h4 style="margin: 0 0 8px; font-size: 0.9rem; font-weight: 800; color: var(--sv-foreground);">Status note</h4>
                    <p style="margin: 0; color: var(--sv-muted); line-height: 1.6;">
                        <c:choose>
                            <c:when test="${payment.status == 'Paid'}">This payment has been confirmed and the course access should be active.</c:when>
                            <c:when test="${payment.status == 'Pending'}">This payment is still being processed. Return here after verification to confirm completion.</c:when>
                            <c:otherwise>This transaction was not finalized successfully. Review the receipt history if you need to retry or report the issue.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 16px;">
                    <h4 style="margin: 0 0 8px; font-size: 0.9rem; font-weight: 800; color: var(--sv-foreground);">Quick actions</h4>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}"><i class="fas fa-layer-group"></i> Open Course</a>
                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/payments"><i class="fas fa-list"></i> All Payments</a>
                    </div>
                </div>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
