<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visual Analytics Hub - PSM E-Learning</title>
    <meta name="description" content="Admin analytics dashboard for PSM E-Learning platform insights, revenue charts, and enrollment metrics">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminReports.module.css">
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>

    <!-- React & ReactDOM UMD -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>

    <!-- Babel Standalone for JSX -->
    `n    

    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>

    <!-- Chart.js UMD -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Reports"/>
    <jsp:param name="pageSubtitle" value="Visual analytics hub for platform-level insights and data-driven decisions"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <c:if test="${not empty error}">
        <div style="max-width: 1400px; margin: 1.5rem auto 0; padding: 0 2rem;">
            <div class="alert-error-gf">
                <i class="fas fa-exclamation-circle"></i> ${error}
            </div>
        </div>
    </c:if>

    <div id="analytics-root"></div>
</main>

<%
    // ── Serialize report summary ──
    java.util.Map<String, Object> summary = (java.util.Map<String, Object>) request.getAttribute("reportSummary");
    org.json.JSONObject summaryJson = new org.json.JSONObject();
    if (summary != null) {
        for (java.util.Map.Entry<String, Object> e : summary.entrySet()) {
            summaryJson.put(e.getKey(), e.getValue() != null ? e.getValue() : 0);
        }
    }

    // ── Serialize top courses ──
    java.util.List<java.util.Map<String, Object>> topCourses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("topCourses");
    org.json.JSONArray topCoursesJson = new org.json.JSONArray();
    if (topCourses != null) {
        for (java.util.Map<String, Object> row : topCourses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("courseId", row.get("courseId"));
            obj.put("title", row.get("title") != null ? row.get("title") : "");
            obj.put("enrollments", row.get("enrollments") != null ? row.get("enrollments") : 0);
            obj.put("completions", row.get("completions") != null ? row.get("completions") : 0);
            obj.put("avgProgress", row.get("avgProgress") != null ? row.get("avgProgress") : 0);
            obj.put("completionRate", row.get("completionRate") != null ? row.get("completionRate") : 0);
            topCoursesJson.put(obj);
        }
    }

    // ── Serialize revenue rows ──
    java.util.List<java.util.Map<String, Object>> revenueRows = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("revenueRows");
    org.json.JSONArray revenueJson = new org.json.JSONArray();
    if (revenueRows != null) {
        for (java.util.Map<String, Object> row : revenueRows) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("courseId", row.get("courseId"));
            obj.put("title", row.get("title") != null ? row.get("title") : "");
            obj.put("enrollments", row.get("enrollments") != null ? row.get("enrollments") : 0);
            obj.put("revenue", row.get("revenue") != null ? row.get("revenue") : 0);
            revenueJson.put(obj);
        }
    }

    // ── Serialize recent exports ──
    java.util.List<java.util.Map<String, Object>> recentExports = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("recentExports");
    org.json.JSONArray exportsJson = new org.json.JSONArray();
    if (recentExports != null) {
        for (java.util.Map<String, Object> row : recentExports) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("exportId", row.get("exportId"));
            obj.put("reportType", row.get("reportType") != null ? row.get("reportType") : "");
            obj.put("exportFormat", row.get("exportFormat") != null ? row.get("exportFormat") : "");
            obj.put("filtersJson", row.get("filtersJson") != null ? row.get("filtersJson") : "{}");
            obj.put("createdAt", row.get("createdAt") != null ? row.get("createdAt").toString() : "");
            exportsJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> userRoles = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("userRoles");
    org.json.JSONArray userRolesJson = new org.json.JSONArray();
    if (userRoles != null) {
        for (java.util.Map<String, Object> row : userRoles) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            userRolesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> userStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("userStatuses");
    org.json.JSONArray userStatusesJson = new org.json.JSONArray();
    if (userStatuses != null) {
        for (java.util.Map<String, Object> row : userStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            userStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> courseStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("courseStatuses");
    org.json.JSONArray courseStatusesJson = new org.json.JSONArray();
    if (courseStatuses != null) {
        for (java.util.Map<String, Object> row : courseStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            courseStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> enrollmentStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("enrollmentStatuses");
    org.json.JSONArray enrollmentStatusesJson = new org.json.JSONArray();
    if (enrollmentStatuses != null) {
        for (java.util.Map<String, Object> row : enrollmentStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            enrollmentStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> paymentStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("paymentStatuses");
    org.json.JSONArray paymentStatusesJson = new org.json.JSONArray();
    if (paymentStatuses != null) {
        for (java.util.Map<String, Object> row : paymentStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            paymentStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> certificateStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("certificateStatuses");
    org.json.JSONArray certificateStatusesJson = new org.json.JSONArray();
    if (certificateStatuses != null) {
        for (java.util.Map<String, Object> row : certificateStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            certificateStatusesJson.put(obj);
        }
    }

    java.util.Map<String, Object> assessmentSummary = (java.util.Map<String, Object>) request.getAttribute("assessmentSummary");
    org.json.JSONObject assessmentSummaryJson = new org.json.JSONObject();
    if (assessmentSummary != null) {
        for (java.util.Map.Entry<String, Object> e : assessmentSummary.entrySet()) {
            assessmentSummaryJson.put(e.getKey(), e.getValue() != null ? e.getValue() : 0);
        }
    }

    java.util.List<java.util.Map<String, Object>> gradingModes = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("gradingModes");
    org.json.JSONArray gradingModesJson = new org.json.JSONArray();
    if (gradingModes != null) {
        for (java.util.Map<String, Object> row : gradingModes) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            gradingModesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> submissionModes = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("submissionModes");
    org.json.JSONArray submissionModesJson = new org.json.JSONArray();
    if (submissionModes != null) {
        for (java.util.Map<String, Object> row : submissionModes) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            submissionModesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> reportAccessStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("reportAccessStatuses");
    org.json.JSONArray reportAccessStatusesJson = new org.json.JSONArray();
    if (reportAccessStatuses != null) {
        for (java.util.Map<String, Object> row : reportAccessStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            reportAccessStatusesJson.put(obj);
        }
    }

    pageContext.setAttribute("summaryJsonStr", summaryJson.toString());
    pageContext.setAttribute("topCoursesJsonStr", topCoursesJson.toString());
    pageContext.setAttribute("revenueJsonStr", revenueJson.toString());
    pageContext.setAttribute("exportsJsonStr", exportsJson.toString());
    pageContext.setAttribute("userRolesJsonStr", userRolesJson.toString());
    pageContext.setAttribute("userStatusesJsonStr", userStatusesJson.toString());
    pageContext.setAttribute("courseStatusesJsonStr", courseStatusesJson.toString());
    pageContext.setAttribute("enrollmentStatusesJsonStr", enrollmentStatusesJson.toString());
    pageContext.setAttribute("paymentStatusesJsonStr", paymentStatusesJson.toString());
    pageContext.setAttribute("certificateStatusesJsonStr", certificateStatusesJson.toString());
    pageContext.setAttribute("assessmentSummaryJsonStr", assessmentSummaryJson.toString());
    pageContext.setAttribute("gradingModesJsonStr", gradingModesJson.toString());
    pageContext.setAttribute("submissionModesJsonStr", submissionModesJson.toString());
    pageContext.setAttribute("reportAccessStatusesJsonStr", reportAccessStatusesJson.toString());
%>

<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__REPORT_SUMMARY__ = ${summaryJsonStr};
    window.__TOP_COURSES__ = ${topCoursesJsonStr};
    window.__REVENUE_ROWS__ = ${revenueJsonStr};
    window.__RECENT_EXPORTS__ = ${exportsJsonStr};
    window.__USER_ROLE_BREAKDOWN__ = ${userRolesJsonStr};
    window.__USER_STATUS_BREAKDOWN__ = ${userStatusesJsonStr};
    window.__COURSE_STATUS_BREAKDOWN__ = ${courseStatusesJsonStr};
    window.__ENROLLMENT_STATUS_BREAKDOWN__ = ${enrollmentStatusesJsonStr};
    window.__PAYMENT_STATUS_BREAKDOWN__ = ${paymentStatusesJsonStr};
    window.__CERTIFICATE_STATUS_BREAKDOWN__ = ${certificateStatusesJsonStr};
    window.__ASSESSMENT_SUMMARY__ = ${assessmentSummaryJsonStr};
    window.__ASSESSMENT_GRADING_BREAKDOWN__ = ${gradingModesJsonStr};
    window.__ASSESSMENT_SUBMISSION_BREAKDOWN__ = ${submissionModesJsonStr};
    window.__REPORT_ACCESS_BREAKDOWN__ = ${reportAccessStatusesJsonStr};
    window.__SELECTED_START_DATE__ = "${selectedStartDate}";
    window.__SELECTED_END_DATE__ = "${selectedEndDate}";
</script>


    <script type="module" src="${pageContext.request.contextPath}/js/dist/admin-reports.js"></script>
</body>
</html>
