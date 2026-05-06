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

        <%-- SECTION 1: Premium Hero --%>
        <section class="ins-hero-section">
            <div class="ins-hero-content">
                <h2>Welcome back, <c:out value="${not empty instructorName ? instructorName : user.fullName}"/> 👋</h2>
                <p>Here’s what’s happening in your courses today. Manage your materials, grade pending submissions, and track student activity from your central hub.</p>
            </div>
        </section>

        <%-- SECTION 2: Pending Actions / KPI Grid --%>
        <section class="ins-section">
            <div class="ins-section-head">
                <h3>At a Glance</h3>
            </div>
            <div class="ins-attention-grid">
                <article class="ins-attention-card ins-attention-warn">
                    <div class="ins-attention-icon"><i class="fas fa-list-check"></i></div>
                    <div class="ins-attention-content">
                        <span class="ins-attention-label">Action Required</span>
                        <strong><c:out value="${pendingGradingCount}" default="0"/></strong>
                        <small>Submissions awaiting grading</small>
                    </div>
                </article>
                <article class="ins-attention-card ins-attention-neutral">
                    <div class="ins-attention-icon"><i class="fas fa-folder-open"></i></div>
                    <div class="ins-attention-content">
                        <span class="ins-attention-label">Course Health</span>
                        <strong><c:out value="${missingMaterialsCourseCount}" default="0"/></strong>
                        <small>Course(s) missing materials</small>
                    </div>
                </article>
                <article class="ins-attention-card ins-attention-good">
                    <div class="ins-attention-icon"><i class="fas fa-calendar-check"></i></div>
                    <div class="ins-attention-content">
                        <span class="ins-attention-label">Upcoming</span>
                        <strong><c:out value="${dueSoonAssessmentCount}" default="0"/></strong>
                        <small>Assessments due within 7 days</small>
                    </div>
                </article>
            </div>
        </section>

        <%-- SECTION 3: Course Cards --%>
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
                                    <div style="width: 100%; height: 140px; border-radius: 12px; margin-bottom: 4px; overflow: hidden;">
                                        <img src="${course.courseBanner}" alt="Banner" style="width: 100%; height: 100%; object-fit: cover;">
                                    </div>
                                </c:if>
                                <div class="ins-course-card__top">
                                    <h4><c:out value="${course.courseName}"/></h4>
                                    <span class="status-badge status-${fn:toLowerCase(course.status)}"><c:out value="${course.status}"/></span>
                                </div>
                                <p class="ins-course-card__meta">
                                    <i class="fas fa-tag"></i> <c:out value="${empty course.category ? 'General' : course.category}"/> &nbsp;&bull;&nbsp; <c:out value="${course.level}"/>
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
                                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}" class="btn btn-primary ins-course-card__cta">
                                    Open Workspace <i class="fas fa-arrow-right" style="margin-left: 8px;"></i>
                                </a>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>
</body>
</html>
