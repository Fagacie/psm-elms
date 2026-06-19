<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructor Dashboard - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/InstructorDashboard.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-workspace-modern.css?v=1">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp" />
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for JSX rendering -->
    `n    
    
    <!-- Recharts dependencies (Prop-Types, Recharts UMD) -->
    <script src="https://unpkg.com/prop-types@15.8.1/prop-types.min.js"></script>
    <script src="https://unpkg.com/recharts@3.8.1/umd/Recharts.js"></script>

    <!-- Framer Motion UMD -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>

    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
</head>

                <body class="instructor-ui">
                    <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
                        <jsp:param name="pageTitle" value="Dashboard" />
                        <jsp:param name="pageSubtitle" value="Your teaching workspace at a glance" />
                    </jsp:include>

                    <c:set var="activeInstructorPage" value="dashboard" />
                    <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp" />

                    <main class="app-main">
                        <!-- Scoped React Sandbox Root -->
                        <div id="instructor-react-root"></div>
                    </main>

                    <!-- Serialize JSTL properties to window state for React sandbox execution -->
                    <script type="text/javascript">
                        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
                        window.__INSTRUCTOR_NAME__ = "${not empty instructorName ? fn:escapeXml(instructorName) : fn:escapeXml(user.fullName)}";
                        window.__INSTRUCTOR_DASHBOARD_DATA__ = {
                            studentCount: ${not empty totalStudents ? totalStudents : 0},
                            newEnrollments: ${not empty newEnrollments30Days ? newEnrollments30Days : 0},
                            avgScore: ${not empty averageAssessmentScore ? averageAssessmentScore : 0},
                            courseCount: ${not empty totalCourses ? totalCourses : 0},
                            
                            completedCount: ${not empty completedEnrollmentsCount ? completedEnrollmentsCount : 0},
                            inProgressCount: ${not empty inProgressEnrollmentsCount ? inProgressEnrollmentsCount : 0},
                            droppedCount: ${not empty droppedEnrollmentsCount ? droppedEnrollmentsCount : 0},
                            
                            passedSubmissions: ${not empty passedSubmissions ? passedSubmissions : 0},
                            failedSubmissions: ${not empty failedSubmissions ? failedSubmissions : 0},
                            
                            monthlyTrends: [
                                <c:forEach var="trend" items="${monthlyTrends}" varStatus="status">
                                    {
                                        date: "${fn:escapeXml(trend.date)}",
                                        enrollments: ${trend.enrollments != null ? trend.enrollments : 0},
                                        revenue: ${trend.revenue != null ? trend.revenue : 0.0}
                                    }${not status.last ? ',' : ''}
                                </c:forEach>
                            ]
                        };
                        window.__COURSES__ = [
                            <c:forEach var="course" items="${courses}" varStatus="status">
                                {
                                    courseId: ${course.courseId},
                                    courseName: "${fn:escapeXml(course.courseName)}",
                                    courseBanner: "${fn:escapeXml(course.courseBanner)}",
                                    status: "${fn:escapeXml(course.status)}",
                                    displayDuration: "${fn:escapeXml(course.displayDuration)}",
                                    enrolledCount: ${not empty courseEnrollmentCountById[course.courseId] ? courseEnrollmentCountById[course.courseId] : 0},
                                    materialCount: ${not empty courseMaterialCountById[course.courseId] ? courseMaterialCountById[course.courseId] : 0},
                                    assessmentCount: ${not empty courseAssessmentCountById[course.courseId] ? courseAssessmentCountById[course.courseId] : 0},
                                    pendingGradingCount: ${not empty pendingSubmissionsByCourseId[course.courseId] ? pendingSubmissionsByCourseId[course.courseId] : 0}
                                }${not status.last ? ',' : ''}
                            </c:forEach>
                        ];
                    </script>

                    <!-- Interactive React Sandbox Application (Zero CSS Bleed) -->
                    
    <script type="module" src="${pageContext.request.contextPath}/js/dist/instructor-dashboard.js"></script> </main>
                </body>

                </html>
