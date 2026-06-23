<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="isAdminProfile" value="${sessionScope.userRole == 'Admin'}"/>
<c:set var="isStudentProfile" value="${sessionScope.userRole == 'Student'}"/>
<c:set var="isInstructorProfile" value="${sessionScope.userRole == 'Instructor'}"/>
<c:set var="openPasswordModal" value="${param.openPasswordModal == '1' or not empty sessionScope.passwordError}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Settings | PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <c:if test="${isAdminProfile}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    </c:if>
    <c:if test="${isInstructorProfile}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    </c:if>
    <!-- Scoped Profile Settings CSS Module -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Profile.module.css">
    
    <!-- React, Animation & Lucide CDNs -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="${isInstructorProfile ? 'instructor-ui' : (isAdminProfile ? 'admin-page profile-admin' : 'sv-page')}">
<c:choose>
    <c:when test="${isInstructorProfile}">
        <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
            <jsp:param name="pageTitle" value="Profile"/>
        </jsp:include>
    </c:when>
    <c:when test="${isAdminProfile}">
        <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
            <jsp:param name="pageTitle" value="Profile"/>
            <jsp:param name="pageSubtitle" value="Manage your account details and personal information"/>
        </jsp:include>
    </c:when>
    <c:when test="${isStudentProfile}">
        <c:set var="topbarTitle" value="Profile"/>
        <c:set var="topbarSubtitle" value="Manage your account details and personal information"/>
        <c:set var="topbarShowSearch" value="false"/>
        <jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>
    </c:when>
    <c:otherwise>
        <c:set var="topbarTitle" value="Profile"/>
        <c:set var="topbarSubtitle" value="Manage your account details and personal information"/>
        <jsp:include page="/WEB-INF/views/common/account-topbar.jsp"/>
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${isInstructorProfile}">
        <c:set var="activeInstructorPage" value="profile"/>
        <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>
        
        <main class="app-main profile-page">
            <div class="content-wrapper">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    <span>&gt;</span>
                    <span>Profile</span>
                </nav>
    </c:when>
    <c:when test="${isAdminProfile}">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>
        <div class="adm_nav_layout">
            <main class="adm_nav_main profile-page" style="padding: 24px 32px;">
                <div class="admin-breadcrumb" style="margin-bottom: 20px;">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    <i class="fas fa-angle-right"></i>
                    <span>Profile</span>
                </div>
    </c:when>
    <c:otherwise>
        <div class="sv-layout">
            <c:choose>
                <c:when test="${isStudentProfile}">
                    <c:set var="activePage" value="profile"/>
                    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>
                </c:when>
                <c:otherwise>
                    <c:set var="activePage" value="profile"/>
                    <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>
                </c:otherwise>
            </c:choose>

            <main class="sv-main profile-page">
                <div class="sv-breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    <i class="fas fa-angle-right"></i>
                    <span>Profile</span>
                </div>
    </c:otherwise>
</c:choose>

        <!-- React Account Settings Workspace Target Root -->
        <div id="profile-settings-react-root"></div>

<c:choose>
    <c:when test="${isInstructorProfile}">
            </div>
        </main>
    </c:when>
    <c:when test="${isAdminProfile}">
        </main>
    </div>
    </c:when>
    <c:otherwise>
    </main>
</div>
    </c:otherwise>
</c:choose>

<!-- JSTL JSP Data Bridge to browser React state variables -->
<script>
    window.contextPath = "${pageContext.request.contextPath}";
    window.profileData = {
        fullName: `${fn:escapeXml(user.fullName)}`,
        email: `${fn:escapeXml(user.email)}`,
        phone: `${fn:escapeXml(user.phone)}`,
        userRole: "${sessionScope.userRole}",
        profilePicture: "${user.profilePicture}",
        
        // Student Specific Details
        studentRegNumber: "${student.regNumber}",
        studentDob: "${student.dob}",
        studentGender: "${student.gender}",
        studentCountry: `${fn:escapeXml(student.country)}`,
        studentState: `${fn:escapeXml(student.state)}`,
        studentEmergencyContact: "${student.emergencyContact}",
        studentQualification: `${fn:escapeXml(student.qualification)}`,
        studentPassportPath: "${student.passportPath}",

        // Instructor Specific Details
        instructorSpecialization: `${fn:escapeXml(instructor.specialization)}`,
        instructorYearsOfExperience: "${instructor.yearsOfExperience}",
        instructorCertification: `${fn:escapeXml(instructor.certification)}`,
        instructorHireDate: "${instructor.hireDate}"
    };
    
    window.profileStatus = {
        profileSuccess: `${fn:escapeXml(sessionScope.profileSuccess)}`,
        profileError: `${fn:escapeXml(sessionScope.profileError)}`,
        passwordSuccess: `${fn:escapeXml(sessionScope.passwordSuccess)}`,
        passwordError: `${fn:escapeXml(sessionScope.passwordError)}`,
        openPasswordModal: ${openPasswordModal}
    };
</script>
<c:remove var="profileSuccess" scope="session"/>
<c:remove var="profileError" scope="session"/>
<c:remove var="passwordSuccess" scope="session"/>
<c:remove var="passwordError" scope="session"/>

<!-- React Settings Workspace compiled in browser via Babel -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/profile.js"></script>

<c:if test="${not isInstructorProfile and not isAdminProfile}">
    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</c:if>

</body>
</html>
