<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Student Dashboard - PSM E-Learning</title>
            <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Dashboard.module.css">
            <script src="https://unpkg.com/lucide@latest"></script>
            <!-- React & ReactDOM (UMD production versions) -->
            <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
            <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
            
            <!-- Babel Standalone for JSX rendering -->
            
            
            <!-- Recharts dependencies (Prop-Types, Recharts UMD) -->
            <script src="https://unpkg.com/prop-types@15.8.1/prop-types.min.js"></script>
            <script src="https://unpkg.com/recharts@3.8.1/umd/Recharts.js"></script>

            <!-- Framer Motion UMD -->
            <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
        </head>

        <body class="sv-page">
            <c:set var="topbarTitle" value="Dashboard" />
            <c:set var="topbarSubtitle" value="Academic overview and course progress" />
            <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

            <div class="sv-layout">
                <c:set var="activePage" value="dashboard" />
                <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

                <main class="sv-main">
                    <!-- Scoped React Sandbox Root -->
                    <div id="student-react-root"></div>
                </main>
            </div>

            <!-- Serialize JSTL properties to window state for React sandbox execution -->
            <script type="text/javascript">
                window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
                window.__STUDENT_NAME__ = "${sessionScope.userName}";
                window.__OVERALL_PROGRESS__ = ${overallProgress != null ? overallProgress : 0};
                window.__CERTIFICATES_COUNT__ = ${certificatesCount != null ? certificatesCount : 0};
                window.__ENROLLED_COURSES_COUNT__ = ${enrolledCoursesCount != null ? enrolledCoursesCount : 0};
                window.__ACTIVE_COURSES_COUNT__ = ${activeCoursesCount != null ? activeCoursesCount : 0};
                window.__COMPLETED_COURSES_COUNT__ = ${completedCoursesCount != null ? completedCoursesCount : 0};
                window.__ENROLLED_COURSES__ = [
                    <c:forEach var="course" items="${enrolledCourses}" varStatus="status">
                        {
                            enrollmentId: ${course.enrollmentId},
                            courseName: "${fn:escapeXml(course.courseName)}",
                            instructorName: "${fn:escapeXml(course.instructorName)}",
                            courseBanner: "${fn:escapeXml(course.courseBanner)}",
                            progress: ${course.progress != null ? course.progress : 0},
                            completionStatus: "${fn:escapeXml(course.completionStatus)}"
                        }${not status.last ? ',' : ''}
                    </c:forEach>
                ];
                window.__ACTIVITY_DATA__ = [
                    <c:forEach var="dayData" items="${activityData}" varStatus="status">
                        {
                            day: "${dayData.day}",
                            Minutes: ${dayData.Minutes}
                        }${not status.last ? ',' : ''}
                    </c:forEach>
                ];
            </script>

            <!-- Interactive React Sandbox Application (Zero CSS Bleed) -->
            
    <script type="module" src="${pageContext.request.contextPath}/js/dist/dashboard.js"></script>

            <div class="sv-overlay" id="svOverlay"></div>
            <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
        </body>

        </html>
