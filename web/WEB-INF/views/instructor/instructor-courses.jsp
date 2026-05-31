<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme-toggle.css">
    <script defer src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
    <script defer src="${pageContext.request.contextPath}/js/instructor-shell.js"></script>
    <script defer src="${pageContext.request.contextPath}/js/instructor-ux.js"></script>
</head>
<body class="instructor-ui">
    <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
        <jsp:param name="pageTitle" value="My Courses"/>
    </jsp:include>

    <c:set var="activeInstructorPage" value="courses"/>
    <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

    <main class="app-main">
        <div class="assigned-courses-page">
            <nav class="breadcrumb" aria-label="Breadcrumb" style="margin-bottom: 2rem;">
                <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>My Courses</span>
            </nav>

            <div class="assigned-courses-header">
                <div class="assigned-courses-title-area">
                    <h2>My Assigned Courses</h2>
                    <p>Manage your curriculum portfolio and access student learning workspaces.</p>
                </div>
                
                <c:if test="${not empty courses}">
                    <div class="assigned-search-wrapper">
                        <i class="fas fa-search assigned-search-icon"></i>
                        <input type="text" placeholder="Search courses by name or status..." 
                               data-search-target="#course-list-container" 
                               data-search-item=".premium-course-card"
                               class="assigned-search-input">
                    </div>
                </c:if>
            </div>

            <c:if test="${param.success == 'updated'}">
                <div class="ws-alert ws-alert-success">
                    <i class="fas fa-check-circle"></i> Course updated successfully!
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="ws-alert ws-alert-error">
                    <i class="fas fa-exclamation-circle"></i> An error occurred. Please try again.
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="ws-alert ws-alert-error">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty courses}">
                    <div class="empty-state-box course-empty-state">
                        <i class="fas fa-layer-group"></i>
                        <p>You do not have any courses assigned yet.</p>
                        <span>Once an admin assigns a course, it will appear here.</span>
                    </div>
                </c:when>
                <c:otherwise>
                    <section class="assigned-courses-grid" id="course-list-container" aria-label="Assigned courses">
                        <c:forEach var="course" items="${courses}">
                            <article class="premium-course-card">
                                <div class="card-thumbnail-wrapper">
                                    <c:choose>
                                        <c:when test="${not empty course.courseBanner}">
                                            <img src="${course.courseBanner}" alt="<c:out value='${course.courseName}'/> Banner" class="card-thumbnail-image">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="card-thumbnail-fallback">
                                                <i class="fas fa-graduation-cap"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="card-category-badge"><c:out value="${empty course.category ? 'General' : course.category}"/></span>
                                </div>
                                <div class="card-body-section">
                                    <h4 class="card-title-text" data-search-text><c:out value="${course.courseName}"/></h4>
                                    <span class="card-status-pill status-${fn:toLowerCase(course.status)}" data-search-text><c:out value="${course.status}"/></span>
                                    
                                    <div class="card-metrics-row">
                                        <div class="card-metric-item" title="Enrolled Students">
                                            <i class="fas fa-users card-metric-icon"></i>
                                            <span><c:out value="${courseStudentCounts[course.courseId] != null ? courseStudentCounts[course.courseId] : 0}"/> Students</span>
                                        </div>
                                        <div class="card-metric-item" title="Course Duration">
                                            <i class="far fa-clock card-metric-icon"></i>
                                            <span><c:out value="${course.displayDuration}"/></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-action-layer">
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}" class="card-action-button">
                                        Enter Workspace <i class="fas fa-arrow-right"></i>
                                    </a>
                                </div>
                            </article>
                        </c:forEach>
                    </section>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</body>
</html>
