<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.courseName}"/> - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    
    <!-- Scoped isolated styles for the ultra-minimalist storefront -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/CourseDetails.module.css">

    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for browser JSX compilation -->
    <!-- Lucide Core for thin UI icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="sv-page">
    <c:set var="topbarTitle" value="Course Details" />
    <c:set var="topbarSubtitle" value="Review details and choose your next step" />
    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

    <div class="sv-layout">
        <c:set var="activePage" value="browse-courses" />
        <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

        <main class="sv-main">
            <!-- Scoped React Sandbox Root node -->
            <div id="student-react-root"></div>
        </main>
    </div>

    <%
        Course cObj = (Course) request.getAttribute("course");
        User instObj = (User) request.getAttribute("instructor");
        List<Material> matsList = (List<Material>) request.getAttribute("materials");
        List<Integer> enrolledIdsList = (List<Integer>) request.getAttribute("enrolledCourseIds");
        
        org.json.JSONObject courseJson = new org.json.JSONObject();
        if (cObj != null) {
            courseJson.put("courseId", cObj.getCourseId() != null ? cObj.getCourseId() : 0);
            courseJson.put("courseName", cObj.getCourseName() != null ? cObj.getCourseName() : "");
            courseJson.put("description", cObj.getDescription() != null ? cObj.getDescription() : "");
            courseJson.put("category", cObj.getCategory() != null ? cObj.getCategory() : "General");
            courseJson.put("level", cObj.getLevel() != null ? cObj.getLevel() : "All Levels");
            courseJson.put("courseFee", cObj.getCourseFee() != null ? cObj.getCourseFee().doubleValue() : 0.0);
            courseJson.put("displayDuration", cObj.getDisplayDuration() != null ? cObj.getDisplayDuration() : "Self-paced");
            courseJson.put("courseBanner", cObj.getCourseBanner() != null ? cObj.getCourseBanner() : "");
        }
        
        org.json.JSONObject instructorJson = new org.json.JSONObject();
        if (instObj != null) {
            instructorJson.put("fullName", instObj.getFullName() != null ? instObj.getFullName() : "Instructor");
            instructorJson.put("email", instObj.getEmail() != null ? instObj.getEmail() : "");
        }
        
        org.json.JSONArray materialsJson = new org.json.JSONArray();
        if (matsList != null) {
            for (Material m : matsList) {
                org.json.JSONObject mObj = new org.json.JSONObject();
                mObj.put("materialId", m.getMaterialId() != null ? m.getMaterialId() : 0);
                mObj.put("title", m.getTitle() != null ? m.getTitle() : "");
                mObj.put("description", m.getDescription() != null ? m.getDescription() : "");
                mObj.put("materialType", m.getMaterialType() != null ? m.getMaterialType() : "Document");
                materialsJson.put(mObj);
            }
        }
        
        boolean isEnrolled = false;
        if (cObj != null && enrolledIdsList != null && enrolledIdsList.contains(cObj.getCourseId())) {
            isEnrolled = true;
        }
        
        pageContext.setAttribute("serializedCourse", courseJson.toString());
        pageContext.setAttribute("serializedInstructor", instructorJson.toString());
        pageContext.setAttribute("serializedMaterials", materialsJson.toString());
        pageContext.setAttribute("isEnrolled", isEnrolled);
    %>

    <script type="text/javascript">
        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
        window.__COURSE__ = ${serializedCourse};
        window.__INSTRUCTOR__ = ${serializedInstructor};
        window.__MATERIALS__ = ${serializedMaterials};
        window.__IS_ENROLLED__ = ${isEnrolled};
    </script>

    <!-- React App Engine -->
    
    <script type="module" src="${pageContext.request.contextPath}/js/dist/course-details.js"></script>
    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
