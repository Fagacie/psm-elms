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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Dashboard"/>
</jsp:include>

<c:set var="activeInstructorPage" value="dashboard"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper dashboard-shell">
        <c:set var="courseCount" value="${not empty totalCourses ? totalCourses : 0}" />
        <c:set var="studentCount" value="${not empty totalStudents ? totalStudents : 0}" />
        <c:set var="pendingGradingCount" value="${not empty pendingGradingCount ? pendingGradingCount : 0}" />
        <c:set var="missingMaterialsCourseCount" value="${not empty missingMaterialsCourseCount ? missingMaterialsCourseCount : 0}" />
        <c:set var="dueSoonAssessmentCount" value="${not empty dueSoonAssessmentCount ? dueSoonAssessmentCount : 0}" />

        <%-- SECTION 1: Welcome --%>
        <section class="ins-welcome">
            <h2>Welcome back, <c:out value="${not empty instructorName ? instructorName : user.fullName}"/> 👋</h2>
            <p>Manage your courses, grading, and student activity.</p>
        </section>

        <%-- SECTION 2: Course Cards --%>
        <section class="ins-section">
            <div class="ins-section-head">
                <h3>My Courses</h3>
                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/courses">View All</a>
            </div>

            <c:choose>
                <c:when test="${empty courses}">
                    <div class="empty-state-box">
                        <i class="fas fa-layer-group"></i>
                        <p>No courses are assigned to your account yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="ins-course-grid">
                        <c:forEach var="course" items="${courses}">
                            <article class="ins-course-card">
                                <c:if test="${not empty course.courseBanner}">
                                    <div style="width: 100%; height: 120px; border-radius: 8px; margin-bottom: 12px; overflow: hidden;">
                                        <img src="${course.courseBanner}" alt="Banner" style="width: 100%; height: 100%; object-fit: cover;">
                                    </div>
                                </c:if>
                                <div class="ins-course-card__top">
                                    <h4><c:out value="${course.courseName}"/></h4>
                                    <span class="status-badge status-${fn:toLowerCase(course.status)}"><c:out value="${course.status}"/></span>
                                </div>
                                <p class="ins-course-card__meta">
                                    <c:out value="${empty course.category ? 'General' : course.category}"/> · <c:out value="${course.level}"/>
                                </p>
                                <div class="ins-course-card__stats">
                                    <div>
                                        <strong><c:out value="${courseEnrollmentCountById[course.courseId]}" default="0"/></strong>
                                        <span>Students</span>
                                    </div>
                                    <div>
                                        <strong><c:out value="${pendingSubmissionsByCourseId[course.courseId]}" default="0"/></strong>
                                        <span>Pending</span>
                                    </div>
                                </div>
                                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}" class="btn btn-primary btn-sm ins-course-card__cta">
                                    <i class="fas fa-arrow-right"></i> Open Workspace
                                </a>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <%-- SECTION 3: Pending Actions --%>
        <section class="ins-section">
            <div class="ins-section-head">
                <h3>Pending Actions</h3>
            </div>
            <div class="ins-attention-grid">
                <article class="ins-attention-card ins-attention-warn">
                    <span class="ins-attention-label">Grading</span>
                    <strong><c:out value="${pendingGradingCount}" default="0"/></strong>
                    <small>submissions awaiting grading</small>
                </article>
                <article class="ins-attention-card ins-attention-neutral">
                    <span class="ins-attention-label">Materials</span>
                    <strong><c:out value="${missingMaterialsCourseCount}" default="0"/></strong>
                    <small>course(s) missing materials</small>
                </article>
                <article class="ins-attention-card ins-attention-good">
                    <span class="ins-attention-label">Assessments</span>
                    <strong><c:out value="${dueSoonAssessmentCount}" default="0"/></strong>
                    <small>due within 7 days</small>
                </article>
            </div>
        </section>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
<script>
(function(){
    var btn = document.getElementById('insMenuBtn');
    var sidebar = document.getElementById('insSidebar');
    if(btn && sidebar){
        btn.addEventListener('click', function(){
            document.body.classList.toggle('ins-shell-collapsed');
        });
    }
})();
</script>
</body>
</html>
