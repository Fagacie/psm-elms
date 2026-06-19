<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platform Settings - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-settings-gf.css?v=1.1">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM UMD production versions -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for live JSX translation -->
    `n    
    
    <!-- React Hook Form UMD build -->
    <script src="https://unpkg.com/react-hook-form@7.51.5/dist/index.umd.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Settings"/>
    <jsp:param name="pageSubtitle" value="Platform configurations and operational defaults"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- Success/Error Banners in Greenfield Styling -->
    <div style="max-width: 1200px; margin: 2rem auto 0 auto; padding: 0 2rem;">
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
        <c:if test="${not empty infoMessage}">
            <div class="alert-gf alert-success-gf" style="background-color: #fef3c7; color: #b45309; border: 1px solid rgba(180, 83, 9, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-info-circle"></i> <c:out value="${infoMessage}"/>
            </div>
        </c:if>
    </div>

    <!-- React Mounting Entry Node -->
    <div id="admin-react-root"></div>
</main>

<%-- JSTL data serialization to JSON bridge --%>
<%
    java.util.Map<String, String> settings = (java.util.Map<String, String>) request.getAttribute("settings");
    org.json.JSONObject sJson = new org.json.JSONObject();
    if (settings != null) {
        for (java.util.Map.Entry<String, String> e : settings.entrySet()) {
            sJson.put(e.getKey(), e.getValue() != null ? e.getValue() : "");
        }
    }
    
    java.util.List<com.psm.elearning.model.AppSettingAuditEntry> audits = (java.util.List<com.psm.elearning.model.AppSettingAuditEntry>) request.getAttribute("audits");
    org.json.JSONArray aJson = new org.json.JSONArray();
    if (audits != null) {
        for (com.psm.elearning.model.AppSettingAuditEntry entry : audits) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("auditId", entry.getAuditId());
            obj.put("settingKey", entry.getSettingKey() != null ? entry.getSettingKey() : "");
            obj.put("oldValue", entry.getOldValue() != null ? entry.getOldValue() : "");
            obj.put("newValue", entry.getNewValue() != null ? entry.getNewValue() : "");
            obj.put("changedBy", entry.getChangedBy() != null ? entry.getChangedBy() : 0);
            obj.put("changedAt", entry.getChangedAt() != null ? entry.getChangedAt().toString() : "");
            aJson.put(obj);
        }
    }
    
    pageContext.setAttribute("serializedSettings", sJson.toString());
    pageContext.setAttribute("serializedAudits", aJson.toString());
%>

<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__SETTINGS__ = ${serializedSettings};
    window.__AUDITS__ = ${serializedAudits};
    window.__HAS_PAYSTACK_SECRET__ = ${hasPaystackSecret != null ? hasPaystackSecret : false};
    window.__HAS_WEBHOOK_SECRET__ = ${hasWebhookSecret != null ? hasWebhookSecret : false};
    window.__HAS_SMTP_PASSWORD__ = ${hasSmtpPassword != null ? hasSmtpPassword : false};
    window.__HAS_CLOUDINARY_SECRET__ = ${hasCloudinarySecret != null ? hasCloudinarySecret : false};
</script>


    <script type="module" src="${pageContext.request.contextPath}/js/dist/admin-settings.js"></script>
</body>
</html>
