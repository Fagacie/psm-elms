<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List,java.util.Map" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
    
    <!-- Scoped isolated styles for the Discovery Experience -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/BrowseCourses.module.css">

    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for browser JSX compilation -->
    `n    
    
    <!-- Framer Motion for premium staggered layout animations -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
</head>
<body class="sv-page">
    <c:set var="topbarTitle" value="Browse Courses" />
    <c:set var="topbarSubtitle" value="Explore available learning catalog and enroll" />
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
        List<Course> coursesList = (List<Course>) request.getAttribute("courses");
        List<Integer> enrolledIdsList = (List<Integer>) request.getAttribute("enrolledCourseIds");
        Map<Integer, Integer> enrolledMapObj = (Map<Integer, Integer>) request.getAttribute("enrolledCourseMap");
        
        com.psm.elearning.dao.UserDAO userDAO = new com.psm.elearning.dao.UserDAOImpl();
        org.json.JSONArray coursesJson = new org.json.JSONArray();
        if (coursesList != null) {
            for (Course c : coursesList) {
                org.json.JSONObject obj = new org.json.JSONObject();
                obj.put("courseId", c.getCourseId() != null ? c.getCourseId() : 0);
                obj.put("courseName", c.getCourseName() != null ? c.getCourseName() : "");
                obj.put("category", c.getCategory() != null ? c.getCategory() : "General");
                obj.put("level", c.getLevel() != null ? c.getLevel() : "All Levels");
                obj.put("courseFee", c.getCourseFee() != null ? c.getCourseFee() : 0.0);
                obj.put("displayDuration", c.getDisplayDuration() != null ? c.getDisplayDuration() : "Self-paced");
                obj.put("courseBanner", c.getCourseBanner() != null ? c.getCourseBanner() : "");
                obj.put("createdBy", c.getCreatedBy() != null ? c.getCreatedBy() : 0);
                
                String instructorName = "Instructor";
                if (c.getCreatedBy() != null) {
                    try {
                        com.psm.elearning.model.User instructor = userDAO.findById(c.getCreatedBy());
                        if (instructor != null && instructor.getFullName() != null) {
                            instructorName = instructor.getFullName();
                        }
                    } catch (Exception ex) {
                        // Keep fallback
                    }
                }
                obj.put("instructorName", instructorName);
                coursesJson.put(obj);
            }
        }
        
        org.json.JSONArray enrolledIdsJson = new org.json.JSONArray();
        if (enrolledIdsList != null) {
            for (Integer id : enrolledIdsList) {
                enrolledIdsJson.put(id);
            }
        }
        
        org.json.JSONObject enrolledMapJson = new org.json.JSONObject();
        if (enrolledMapObj != null) {
            for (Map.Entry<Integer, Integer> entry : enrolledMapObj.entrySet()) {
                enrolledMapJson.put(String.valueOf(entry.getKey()), entry.getValue());
            }
        }
        
        pageContext.setAttribute("serializedCourses", coursesJson.toString());
        pageContext.setAttribute("serializedEnrolledIds", enrolledIdsJson.toString());
        pageContext.setAttribute("serializedEnrolledMap", enrolledMapJson.toString());
    %>

    <script type="text/javascript">
        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
        window.__COURSES__ = ${serializedCourses};
        window.__ENROLLED_COURSE_IDS__ = ${serializedEnrolledIds};
        window.__ENROLLED_COURSE_MAP__ = ${serializedEnrolledMap};
    </script>

    <!-- React App Engine -->
    
    <script type="module" src="${pageContext.request.contextPath}/js/dist/available-courses.js"></script>
    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
