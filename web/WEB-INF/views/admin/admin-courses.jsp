<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Catalog Management - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-courses-gf.css?v=<%= System.currentTimeMillis() %>">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Framer Motion UMD -->
    <script src="https://unpkg.com/framer-motion@10.12.16/dist/framer-motion.js"></script>
    
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    
    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Courses"/>
    <jsp:param name="pageSubtitle" value="Review approvals and keep the course catalog organized"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- JSTL Success/Error Notification Banners -->
    <div style="max-width: 1400px; margin: 2rem auto 0 auto; padding: 0 2rem;">
        <c:if test="${param.success == 'approved'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course approved successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'rejected'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course pending request rejected.
            </div>
        </c:if>
        <c:if test="${param.success == 'created'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course created and published successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'edited'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course catalog specifications updated successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'assigned'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Instructor assigned to course catalog successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'archived'}">
            <div class="alert-gf alert-success-gf" style="background-color: #f1f5f9; color: #475569; border: 1px solid rgba(71, 85, 105, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-archive"></i> Course archived and hidden from student catalog.
            </div>
        </c:if>
        <c:if test="${param.success == 'restored'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course restored back to active student catalog successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'deleted'}">
            <div class="alert-gf alert-success-gf" style="background-color: #fef2f2; color: #b91c1c; border: 1px solid rgba(185, 28, 28, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-trash-alt"></i> Course has been completely hard-deleted from database records.
            </div>
        </c:if>
        <c:if test="${param.error != null}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> An operation error occurred. Please verify and try again.
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
    List<Course> coursesList = (List<Course>) request.getAttribute("courses");
    List<User> instructorsList = (List<User>) request.getAttribute("instructors");
    java.util.Map<Integer, Integer> enrollmentCountsMap = (java.util.Map<Integer, Integer>) request.getAttribute("enrollmentCounts");

    // Map active instructor details
    java.util.Map<Integer, String> instructorLabels = new java.util.HashMap<>();
    if (instructorsList != null) {
        for (User ins : instructorsList) {
            instructorLabels.put(ins.getUserId(), ins.getFullName());
        }
    }

    org.json.JSONArray coursesJsonArray = new org.json.JSONArray();
    if (coursesList != null) {
        for (Course c : coursesList) {
            org.json.JSONObject courseObj = new org.json.JSONObject();
            int cid = c.getCourseId();
            courseObj.put("courseId", cid);
            courseObj.put("courseName", c.getCourseName() != null ? c.getCourseName() : "");
            courseObj.put("description", c.getDescription() != null ? c.getDescription() : "");
            courseObj.put("category", c.getCategory() != null ? c.getCategory() : "Uncategorized");
            courseObj.put("duration", c.getDuration() != null ? c.getDuration() : 0);
            courseObj.put("level", c.getLevel() != null ? c.getLevel() : "Beginner");
            courseObj.put("courseFee", c.getCourseFee() != null ? c.getCourseFee() : java.math.BigDecimal.ZERO);
            courseObj.put("status", c.getStatus() != null ? c.getStatus() : "Pending");
            courseObj.put("courseBanner", c.getCourseBanner() != null ? c.getCourseBanner() : "");
            courseObj.put("createdBy", c.getCreatedBy() != null ? c.getCreatedBy() : 0);
            courseObj.put("createdAt", c.getCreatedAt() != null ? c.getCreatedAt().toString() : "");
            courseObj.put("enrolledCount", (enrollmentCountsMap != null && enrollmentCountsMap.get(cid) != null) ? enrollmentCountsMap.get(cid) : 0);
            
            // Instructor label
            String insLabel = "Unassigned";
            if (c.getCreatedBy() != null && instructorLabels.containsKey(c.getCreatedBy())) {
                insLabel = instructorLabels.get(c.getCreatedBy());
            }
            courseObj.put("instructorLabel", insLabel);
            
            coursesJsonArray.put(courseObj);
        }
    }

    org.json.JSONArray instructorsJsonArray = new org.json.JSONArray();
    if (instructorsList != null) {
        for (User ins : instructorsList) {
            org.json.JSONObject insObj = new org.json.JSONObject();
            insObj.put("userId", ins.getUserId());
            insObj.put("fullName", ins.getFullName() != null ? ins.getFullName() : "");
            insObj.put("email", ins.getEmail() != null ? ins.getEmail() : "");
            instructorsJsonArray.put(insObj);
        }
    }

    pageContext.setAttribute("serializedCoursesJson", coursesJsonArray.toString());
    pageContext.setAttribute("serializedInstructorsJson", instructorsJsonArray.toString());
%>

<!-- Serialize JSTL variables securely to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__COURSES__ = ${serializedCoursesJson};
    window.__INSTRUCTORS__ = ${serializedInstructorsJson};
</script>

<!-- Interactive React Command Center Application -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/admin-courses.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
