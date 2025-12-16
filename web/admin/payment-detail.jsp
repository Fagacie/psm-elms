<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.psm.elearning.model.Payment" %>
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
<%
    Payment p = (Payment) request.getAttribute("payment");
%>
<dl>
    <dt>Payment ID</dt><dd><%= p.getPaymentId() %></dd>
    <dt>Enrollment ID</dt><dd><%= p.getEnrollmentId() %></dd>
    <dt>Amount</dt><dd><%= String.format("%.2f", p.getAmount()) %></dd>
    <dt>Status</dt><dd><%= p.getStatus() %></dd>
    <dt>Method</dt><dd><%= p.getMethod() %></dd>
    <dt>Reference</dt><dd><%= p.getPaystackReference() %></dd>
    <dt>Payment Date</dt><dd><%= p.getPaymentDate() != null ? p.getPaymentDate() : "" %></dd>
</dl>
<p><a href="<%= request.getContextPath() %>/admin/payments">Back to list</a></p>
</body>
</html>
