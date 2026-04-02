<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Admin - Payment Detail</title>
    <style>
        dt { font-weight: bold; }
        dd { margin: 0 0 8px 0; }
    </style>
</head>
<body>
<h2>Payment Detail</h2>
<dl>
    <dt>Payment ID</dt><dd>${payment.paymentId}</dd>
    <dt>Enrollment ID</dt><dd>${payment.enrollmentId}</dd>
    <dt>Amount</dt><dd>${payment.amount}</dd>
    <dt>Status</dt><dd>${payment.status}</dd>
    <dt>Method</dt><dd>${payment.method}</dd>
    <dt>Reference</dt><dd>${payment.paystackReference}</dd>
    <dt>Payment Date</dt><dd><c:out value="${payment.paymentDate}" default=""/></dd>
</dl>
<p><a href="${pageContext.request.contextPath}/admin/payments">Back to list</a></p>
</body>
</html>
