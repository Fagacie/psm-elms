<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css?v=2.1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminDashboard.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard-gf.css?v=1.0">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Framer Motion UMD -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    
    <!-- Recharts dependencies (Prop-Types, Recharts UMD) -->
    <script src="https://unpkg.com/prop-types@15.8.1/prop-types.min.js"></script>
    <script src="https://unpkg.com/recharts@2.12.7/umd/Recharts.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Admin Dashboard"/>
    <jsp:param name="pageSubtitle" value="Manage platform operations from one structured workspace"/>
    <jsp:param name="showNotifications" value="true"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- React Root Entry Node -->
    <div id="admin-react-root"></div>
</main>

<!-- Serialize backend JSTL variables strictly to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__ADMIN_DASHBOARD_DATA__ = {
        totalRevenue: ${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0.0},
        totalUsers: ${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0},
        activeCourses: ${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0},
        totalEnrollments: ${systemMetrics['totalEnrollments'] != null ? systemMetrics['totalEnrollments'] : 0},
        
        studentsCount: ${systemMetrics['studentsCount'] != null ? systemMetrics['studentsCount'] : 0},
        instructorsCount: ${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0},
        adminsCount: ${systemMetrics['adminsCount'] != null ? systemMetrics['adminsCount'] : 0},
        
        approvedCourses: ${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0},
        pendingCourses: ${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0},
        archivedCourses: ${systemMetrics['archivedCourses'] != null ? systemMetrics['archivedCourses'] : 0},
        
        platformGrowth: [
            <c:forEach var="stat" items="${platformGrowth}" varStatus="status">
                {
                    date: "${fn:escapeXml(stat.date)}",
                    newUsers: ${stat.newUsers != null ? stat.newUsers : 0},
                    platformRevenue: ${stat.platformRevenue != null ? stat.platformRevenue : 0.0}
                }${not status.last ? ',' : ''}
            </c:forEach>
        ]
    };
    
    window.__RECENT_ENROLLMENTS__ = [
        <c:forEach var="enrollment" items="${recentEnrollments}" varStatus="status">
            {
                studentName: "${fn:escapeXml(enrollment.studentName)}",
                studentEmail: "${fn:escapeXml(enrollment.studentEmail)}",
                courseName: "${fn:escapeXml(enrollment.courseName)}",
                enrollmentDate: "${enrollment.enrollmentDate != null ? fn:substring(enrollment.enrollmentDate.toString(), 0, 10) : 'N/A'}",
                coursePrice: ${enrollment.coursePrice != null ? enrollment.coursePrice : 0},
                paymentStatus: "${fn:escapeXml(enrollment.paymentStatus)}"
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];
</script>

<!-- Interactive React Command Center Application -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/admin-dashboard.js"></script>
</body>
</html>
