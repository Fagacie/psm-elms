<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
    
    <!-- Scoped isolated styles for the learning library -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/MyCourses.module.css">

    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for browser JSX compilation -->
    `n    
    
    <!-- Framer Motion for premium staggered layout animations -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
</head>
<body class="sv-page">
    <c:set var="topbarTitle" value="My Learning" />
    <c:set var="topbarSubtitle" value="Track active courses and continue learning" />
    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

    <div class="sv-layout">
        <c:set var="activePage" value="my-courses" />
        <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

        <main class="sv-main">
            <!-- Scoped React Sandbox Root node -->
            <div id="student-react-root"></div>
        </main>
    </div>

    <!-- Background Notification Banners for alerts -->
    <div style="display:none;">
        <c:if test="${param.message == 'alreadypaid'}">
            <div id="alertMessagePaid" data-message="This enrollment has already been paid and is ready in your learning workspace."></div>
        </c:if>
        <c:if test="${param.error == 'notfound' || param.error == 'invalid'}">
            <div id="alertMessageError" data-message="We could not find that enrollment. Please open it again from your course list."></div>
        </c:if>
        <c:if test="${param.error == 'unauthorized' || param.error == 'permission'}">
            <div id="alertMessageAuth" data-message="You do not have permission to access that enrollment."></div>
        </c:if>
        <c:if test="${param.error == 'exception'}">
            <div id="alertMessageExcept" data-message="Something interrupted the enrollment flow. Please try again."></div>
        </c:if>
    </div>

    <%
        List<Enrollment> enrollmentsList = (List<Enrollment>) request.getAttribute("enrollments");
        
        org.json.JSONArray enrollmentsJsonArray = new org.json.JSONArray();
        if (enrollmentsList != null) {
            for (Enrollment e : enrollmentsList) {
                org.json.JSONObject obj = new org.json.JSONObject();
                
                int eid = e.getEnrollmentId() != null ? e.getEnrollmentId() : 0;
                int cid = e.getCourseId() != null ? e.getCourseId() : 0;
                String cName = e.getCourseName() != null ? e.getCourseName() : "";
                String instructorName = e.getInstructorName() != null ? e.getInstructorName() : "Instructor";
                String banner = e.getCourseBanner() != null ? e.getCourseBanner() : "";
                int progress = e.getProgress() != null ? e.getProgress() : 0;
                String completionStatus = e.getCompletionStatus() != null ? e.getCompletionStatus() : "Not Started";
                String paymentStatus = e.getPaymentStatus() != null ? e.getPaymentStatus() : "Pending";
                double price = e.getCoursePrice() != null ? e.getCoursePrice() : 0.0;
                long daysLeft = e.getDaysRemaining();
                
                boolean paid = "Paid".equalsIgnoreCase(paymentStatus) 
                            || "Completed".equalsIgnoreCase(paymentStatus) 
                            || "SUCCESS".equalsIgnoreCase(paymentStatus);
                boolean granted = paid || price <= 0.0;
                
                obj.put("enrollmentId", eid);
                obj.put("courseId", cid);
                obj.put("courseName", cName);
                obj.put("instructorName", instructorName);
                obj.put("courseBanner", banner);
                obj.put("progress", progress);
                obj.put("completionStatus", completionStatus);
                obj.put("paymentStatus", paymentStatus);
                obj.put("coursePrice", price);
                obj.put("daysRemaining", daysLeft);
                obj.put("courseAccessGranted", granted);
                
                enrollmentsJsonArray.put(obj);
            }
        }
        
        pageContext.setAttribute("serializedEnrollmentsJson", enrollmentsJsonArray.toString());
    %>

    <script type="text/javascript">
        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
        window.__ENROLLED_COURSES__ = ${serializedEnrollmentsJson};
    </script>

    <!-- React App Engine -->
    
    <script type="module" src="${pageContext.request.contextPath}/js/dist/my-enrollments.js"></script>
    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
