<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-users-gf.css?v=<%= System.currentTimeMillis() %>">
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
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Users"/>
    <jsp:param name="pageSubtitle" value="Manage student, instructor, and administrator accounts"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- JSTL Success/Warning/Error Notifications -->
    <div style="max-width: 1400px; margin: 2rem auto 0 auto; padding: 0 2rem;">
        <c:if test="${not empty sessionScope.success}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> <c:out value="${sessionScope.success}"/>
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.error}"/>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.warning}">
            <div class="alert-gf alert-success-gf" style="background-color: #fef3c7; color: #b45309; border: 1px solid rgba(180, 83, 9, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-info-circle"></i> <c:out value="${sessionScope.warning}"/>
            </div>
            <c:remove var="warning" scope="session"/>
        </c:if>
    </div>

    <!-- React Greenfield Root Mounting Element -->
    <div id="admin-react-root"></div>
</main>

<%
    List<User> usersList = (List<User>) request.getAttribute("users");
    java.util.Map<Integer, Student> studentDetailsMap = (java.util.Map<Integer, Student>) request.getAttribute("studentDetailsMap");
    java.util.Map<Integer, Instructor> instructorDetailsMap = (java.util.Map<Integer, Instructor>) request.getAttribute("instructorDetailsMap");
    java.util.Map<Integer, String> studentEnrollmentsMap = (java.util.Map<Integer, String>) request.getAttribute("studentEnrollmentsMap");
    java.util.Map<Integer, String> instructorCoursesMap = (java.util.Map<Integer, String>) request.getAttribute("instructorCoursesMap");
    java.util.Map<Integer, Integer> instructorMaterialsCountMap = (java.util.Map<Integer, Integer>) request.getAttribute("instructorMaterialsCountMap");
    java.util.Map<Integer, Integer> instructorAssessmentsCountMap = (java.util.Map<Integer, Integer>) request.getAttribute("instructorAssessmentsCountMap");

    org.json.JSONArray usersJsonArray = new org.json.JSONArray();
    if (usersList != null) {
        for (User u : usersList) {
            org.json.JSONObject userObj = new org.json.JSONObject();
            int uid = u.getUserId();
            userObj.put("userId", uid);
            userObj.put("fullName", u.getFullName() != null ? u.getFullName() : "");
            userObj.put("email", u.getEmail() != null ? u.getEmail() : "");
            userObj.put("phone", u.getPhone() != null ? u.getPhone() : "");
            userObj.put("role", u.getRole() != null ? u.getRole() : "");
            userObj.put("status", u.getStatus() != null ? u.getStatus() : "");
            
            // Student specific details
            if (studentDetailsMap != null && studentDetailsMap.containsKey(uid)) {
                Student s = studentDetailsMap.get(uid);
                userObj.put("studentReg", s.getRegNumber() != null ? s.getRegNumber() : "");
                userObj.put("studentQualification", s.getQualification() != null ? s.getQualification() : "");
                userObj.put("studentCountry", s.getCountry() != null ? s.getCountry() : "");
                userObj.put("studentState", s.getState() != null ? s.getState() : "");
                userObj.put("studentGender", s.getGender() != null ? s.getGender() : "");
                userObj.put("studentEmergency", s.getEmergencyContact() != null ? s.getEmergencyContact() : "");
            } else {
                userObj.put("studentReg", "");
                userObj.put("studentQualification", "");
                userObj.put("studentCountry", "");
                userObj.put("studentState", "");
                userObj.put("studentGender", "");
                userObj.put("studentEmergency", "");
            }
            userObj.put("studentEnrollments", (studentEnrollmentsMap != null && studentEnrollmentsMap.get(uid) != null) ? studentEnrollmentsMap.get(uid) : "");
            
            // Instructor specific details
            if (instructorDetailsMap != null && instructorDetailsMap.containsKey(uid)) {
                Instructor ins = instructorDetailsMap.get(uid);
                userObj.put("instructorSpecialization", ins.getSpecialization() != null ? ins.getSpecialization() : "");
                userObj.put("instructorCertification", ins.getCertification() != null ? ins.getCertification() : "");
                userObj.put("instructorExperience", ins.getYearsOfExperience() != null ? ins.getYearsOfExperience().toString() : "");
                userObj.put("instructorBio", ins.getBio() != null ? ins.getBio() : "");
            } else {
                userObj.put("instructorSpecialization", "");
                userObj.put("instructorCertification", "");
                userObj.put("instructorExperience", "");
                userObj.put("instructorBio", "");
            }
            userObj.put("instructorCourses", (instructorCoursesMap != null && instructorCoursesMap.get(uid) != null) ? instructorCoursesMap.get(uid) : "");
            userObj.put("instructorMaterials", (instructorMaterialsCountMap != null && instructorMaterialsCountMap.get(uid) != null) ? instructorMaterialsCountMap.get(uid) : 0);
            userObj.put("instructorAssessments", (instructorAssessmentsCountMap != null && instructorAssessmentsCountMap.get(uid) != null) ? instructorAssessmentsCountMap.get(uid) : 0);
            
            usersJsonArray.put(userObj);
        }
    }
    pageContext.setAttribute("serializedUsersJson", usersJsonArray.toString());
%>

<!-- Serialize backend variables strictly to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__CURRENT_USER_ID__ = ${sessionScope.user.userId};
    window.__USERS__ = ${serializedUsersJson};
</script>

<!-- Interactive React Command Center Application -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/users.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
