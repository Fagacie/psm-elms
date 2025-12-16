<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.psm.elearning.model.Payment" %>
<html>
<head>
    <title>Admin - Payments</title>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background: #f3f3f3; }
        .filters { margin-bottom: 12px; }
    </style>
</head>
<body>
<h2>Payments</h2>
<div class="filters">
    <form method="get" action="">
        <label>Status:
            <select name="status">
                <option value="">All</option>
                <option value="Pending" ${"Pending".equals(request.getAttribute("status"))?"selected":""}>Pending</option>
                <option value="Success" ${"Success".equals(request.getAttribute("status"))?"selected":""}>Success</option>
                <option value="Failed" ${"Failed".equals(request.getAttribute("status"))?"selected":""}>Failed</option>
                <option value="Abandoned" ${"Abandoned".equals(request.getAttribute("status"))?"selected":""}>Abandoned</option>
            </select>
        </label>
        <label>Page size: <input type="number" name="pageSize" value="${pageSize}" min="5" max="100"/></label>
        <button type="submit">Apply</button>
    </form>
</div>
<%
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
%>
<table>
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
        <th>PaidAt</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <% if (payments != null) {
        for (Payment p : payments) { %>
            <tr>
                <td><%= p.getPaymentId() %></td>
                <td><%= p.getEnrollmentId() %></td>
                <td><%= p.getCourseName() != null ? p.getCourseName() : "" %></td>
                <td><%= p.getStudentName() != null ? p.getStudentName() : "" %></td>
                <td><%= String.format("%.2f", p.getAmount()) %></td>
                <td><%= p.getStatus() %></td>
                <td><%= p.getMethod() %></td>
                <td><%= p.getPaystackReference() %></td>
                <td><%= p.getPaymentDate() != null ? p.getPaymentDate() : "" %></td>
                <td><a href="<%= request.getContextPath() %>/admin/payment?id=<%= p.getPaymentId() %>">View</a></td>
            </tr>
        <% }
    } %>
    </tbody>
</table>
</body>
</html>
