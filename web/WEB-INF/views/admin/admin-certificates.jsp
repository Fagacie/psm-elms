<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Credentials Registry - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400;1,600&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css?v=2.1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-certificates-gf.css?v=1.0">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM UMD production versions -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for live JSX translation -->
    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Certificates"/>
    <jsp:param name="pageSubtitle" value="Validate issued credentials, search registry records, and review revocations"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- Success/Error Banners in Greenfield Styling -->
    <div style="max-width: 1400px; margin: 0 auto; padding: 0 2rem;">
        <c:if test="${param.success == 'revoked'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Certificate revoked successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'backfill'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Enrollment eligibility backfill completed. Updated: <c:out value="${param.updated}"/>, Errors: <c:out value="${param.errors}"/>.
            </div>
        </c:if>
        <c:if test="${param.error == 'revoke'}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> Unable to revoke certificate.
            </div>
        </c:if>
        <c:if test="${param.error == 'invalid'}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> Invalid certificate action request.
            </div>
        </c:if>
    </div>

    <!-- React Mounting Entry Node -->
    <div id="admin-react-root"></div>
</main>

<%
    List<com.psm.elearning.model.CertificateView> certificatesList = (List<com.psm.elearning.model.CertificateView>) request.getAttribute("certificates");
    org.json.JSONArray certsJsonArray = new org.json.JSONArray();
    if (certificatesList != null) {
        for (com.psm.elearning.model.CertificateView c : certificatesList) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("certificateId", c.getCertificateId());
            obj.put("enrollmentId", c.getEnrollmentId());
            obj.put("courseId", c.getCourseId());
            obj.put("certificateNo", c.getCertificateNo() != null ? c.getCertificateNo() : "");
            obj.put("issueDate", c.getIssueDate() != null ? c.getIssueDate().toString() : "");
            obj.put("generatedBy", c.getGeneratedBy() != null ? c.getGeneratedBy() : "");
            obj.put("verificationURL", c.getVerificationURL() != null ? c.getVerificationURL() : "");
            obj.put("qrCodePath", c.getQrCodePath() != null ? c.getQrCodePath() : "");
            obj.put("status", c.getStatus() != null ? c.getStatus() : "Active");
            obj.put("revokedAt", c.getRevokedAt() != null ? c.getRevokedAt().toString() : "");
            obj.put("revokedBy", c.getRevokedBy() != null ? c.getRevokedBy() : 0);
            obj.put("studentName", c.getStudentName() != null ? c.getStudentName() : "");
            obj.put("studentEmail", c.getStudentEmail() != null ? c.getStudentEmail() : "");
            obj.put("regNumber", c.getRegNumber() != null ? c.getRegNumber() : "");
            obj.put("courseName", c.getCourseName() != null ? c.getCourseName() : "");
            obj.put("instructorName", c.getInstructorName() != null ? c.getInstructorName() : "");
            certsJsonArray.put(obj);
        }
    }
    pageContext.setAttribute("serializedCertsJson", certsJsonArray.toString());
%>

<!-- Context Serialization securely into window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__CERTIFICATES__ = ${serializedCertsJson};
</script>

<!-- Interactive React Command Center Application -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/admin-certificates.js"></script>
</body>
</html>
