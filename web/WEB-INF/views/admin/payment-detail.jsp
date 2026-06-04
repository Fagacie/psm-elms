<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="embeddedMode" value="${param.modal eq '1'}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Detail - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="${embeddedMode ? 'admin-embedded' : 'admin-page'}">
<c:if test="${not embeddedMode}">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Payment Detail"/>
    <jsp:param name="pageSubtitle" value="Inspect a single transaction record"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>
</c:if>

<main class="app-main">
    <div class="content-wrapper">
        <c:if test="${not embeddedMode}">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/admin/payments">Payments</a>
                <span>&gt;</span>
                <span>#${payment.paymentId}</span>
            </div>
        </section>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Transaction Summary</h2>
            </div>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-label">Amount</div>
                    <div class="metric-value">NGN <fmt:formatNumber value="${payment.amount}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Status</div>
                    <div class="metric-value">
                        <c:choose>
                            <c:when test="${payment.status eq 'Paid'}"><span class="status-badge status-success">Paid</span></c:when>
                            <c:when test="${payment.status eq 'Pending'}"><span class="status-badge status-warning">Pending</span></c:when>
                            <c:when test="${payment.status eq 'Failed'}"><span class="status-badge status-danger">Failed</span></c:when>
                            <c:otherwise><span class="status-badge status-secondary"><c:out value="${payment.status}" default="N/A"/></span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Method</div>
                    <div class="metric-value"><c:out value="${payment.method}" default="N/A"/></div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Payment Date</div>
                    <div class="metric-value"><c:out value="${payment.paymentDate}" default="N/A"/></div>
                </div>
            </div>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Transaction Identifiers</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Payment ID</strong><span>#<c:out value="${payment.paymentId}" default="-"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Enrollment ID</strong><span>#<c:out value="${payment.enrollmentId}" default="-"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Paystack Reference</strong><span><c:out value="${payment.paystackReference}" default="N/A"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Internal Reference</strong><span><c:out value="${payment.paymentRef}" default="N/A"/></span></div></div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>Operational Information</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Gateway Status</strong><span><c:out value="${payment.paystackStatus}" default="N/A"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Authorization URL</strong><span><c:out value="${payment.authorizationUrl}" default="Not available"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Access Code</strong><span><c:out value="${payment.accessCode}" default="N/A"/></span></div></div>
                </div>
            </section>
        </section>

        <c:if test="${not embeddedMode}">
        <section class="section-card">
            <div class="section-header">
                <h2>Navigation</h2>
            </div>
            <div class="section-actions-inset">
                <a href="${pageContext.request.contextPath}/admin/payments" class="admin-btn secondary">Back to list</a>
            </div>
        </section>
        </c:if>
    </div>
</main>
</body>
</html>
