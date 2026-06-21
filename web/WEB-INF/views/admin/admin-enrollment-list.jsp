<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Control Command Center - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css?v=2.1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-enrollments-gf.css?v=1.0">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for JSX rendering -->
    `n    
    
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    
    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Enrollments"/>
    <jsp:param name="pageSubtitle" value="Track payments, course progress, and custom access lifecycles"/>
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
    List<Enrollment> enrollmentsList = (List<Enrollment>) request.getAttribute("enrollments");
    org.json.JSONArray enrollmentsJsonArray = new org.json.JSONArray();
    if (enrollmentsList != null) {
        for (Enrollment e : enrollmentsList) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("enrollmentId", e.getEnrollmentId());
            obj.put("userId", e.getUserId());
            obj.put("courseId", e.getCourseId());
            obj.put("status", e.getStatus() != null ? e.getStatus() : "Pending");
            obj.put("paymentStatus", e.getPaymentStatus() != null ? e.getPaymentStatus() : "Pending");
            obj.put("paymentRef", e.getPaymentRef() != null ? e.getPaymentRef() : "N/A");
            obj.put("enrollmentDate", e.getEnrollmentDate() != null ? e.getEnrollmentDate().toString().substring(0, 10) : "");
            obj.put("expiryDateOverride", e.getExpiryDateOverride() != null ? e.getExpiryDateOverride().toString().substring(0, 10) : "");
            obj.put("effectiveEndDate", e.getEffectiveEndDate() != null ? e.getEffectiveEndDate().toString().substring(0, 10) : "");
            obj.put("completionStatus", e.getCompletionStatus() != null ? e.getCompletionStatus() : "Not Started");
            obj.put("progress", e.getProgress() != null ? e.getProgress() : 0);
            obj.put("courseName", e.getCourseName() != null ? e.getCourseName() : "");
            obj.put("coursePrice", e.getCoursePrice() != null ? e.getCoursePrice() : 0.0);
            obj.put("studentName", e.getStudentName() != null ? e.getStudentName() : "");
            obj.put("studentEmail", e.getStudentEmail() != null ? e.getStudentEmail() : "");
            obj.put("instructorName", e.getInstructorName() != null ? e.getInstructorName() : "N/A");
            obj.put("displayDuration", e.getDisplayDuration() != null ? e.getDisplayDuration() : "-");
            obj.put("daysRemaining", e.getDaysRemaining());
            enrollmentsJsonArray.put(obj);
        }
    }
    pageContext.setAttribute("serializedEnrollmentsJson", enrollmentsJsonArray.toString());
%>

<!-- Serialize JSTL variables securely to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__ENROLLMENTS__ = ${serializedEnrollmentsJson};
</script>

<!-- Interactive React Command Center Application -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/admin-enrollment-list.js"></script>
</body>
</html>
