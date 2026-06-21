<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Transaction Ledger - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css?v=2.1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-payments-gf.css?v=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/PaymentHistory.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ReceiptModal.module.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Framer Motion UMD -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    
    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>
    
    <style media="print">
        body * {
            visibility: hidden;
        }
        #print-receipt-area, #print-receipt-area * {
            visibility: visible;
        }
        #print-receipt-area {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
        }
    </style>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Payments"/>
    <jsp:param name="pageSubtitle" value="Track tuition collections, gateway processing states, and payment verifications"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- Success/Error JSTL Notification Banners -->
    <div style="max-width: 1400px; margin: 0 auto; padding: 0 2rem;">
        <c:if test="${not empty successMessage}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> <c:out value="${successMessage}"/>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
            </div>
        </c:if>
    </div>

    <!-- React Greenfield Mounting Entry Node -->
    <div id="admin-react-root"></div>
</main>

<%
    List<Payment> paymentsList = (List<Payment>) request.getAttribute("payments");
    org.json.JSONArray paymentsJsonArray = new org.json.JSONArray();
    if (paymentsList != null) {
        for (Payment p : paymentsList) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("paymentId", p.getPaymentId());
            obj.put("enrollmentId", p.getEnrollmentId());
            obj.put("amount", p.getAmount() != null ? p.getAmount() : 0.0);
            obj.put("paymentRef", p.getPaymentRef() != null ? p.getPaymentRef() : "");
            obj.put("paystackReference", p.getPaystackReference() != null ? p.getPaystackReference() : "");
            obj.put("accessCode", p.getAccessCode() != null ? p.getAccessCode() : "");
            obj.put("authorizationUrl", p.getAuthorizationUrl() != null ? p.getAuthorizationUrl() : "");
            obj.put("paystackStatus", p.getPaystackStatus() != null ? p.getPaystackStatus() : "N/A");
            obj.put("status", p.getStatus() != null ? p.getStatus() : "Pending");
            obj.put("method", p.getMethod() != null ? p.getMethod() : "N/A");
            obj.put("paymentDate", p.getPaymentDate() != null ? p.getPaymentDate().toString() : "");
            obj.put("studentName", p.getStudentName() != null ? p.getStudentName() : "");
            obj.put("studentEmail", p.getStudentEmail() != null ? p.getStudentEmail() : "");
            obj.put("courseName", p.getCourseName() != null ? p.getCourseName() : "");
            paymentsJsonArray.put(obj);
        }
    }
    pageContext.setAttribute("serializedPaymentsJson", paymentsJsonArray.toString());
%>

<!-- Serialize JSTL variables securely to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__PAYMENTS__ = ${serializedPaymentsJson};
</script>

<!-- Interactive React Command Center Application -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/admin-payments.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
