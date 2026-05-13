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
</head>
<body class="instructor-ui">
    <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
        <jsp:param name="pageTitle" value="My Courses"/>
    </jsp:include>

    <c:set var="activeInstructorPage" value="courses"/>
    <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

    <main class="app-main">
        <div class="content-wrapper">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>My Courses</span>
            </nav>

            <section class="ins-page-head">
                <div>
                    <p class="ins-page-kicker">Course Portfolio</p>
                    <h2>Manage your courses and student workspaces</h2>
                    <p>Access workspaces to grade assessments, arrange materials, and track student progress. You have ${courses != null ? courses.size() : 0} courses assigned.</p>
                </div>
            </section>

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
                    <div style="margin-bottom: 24px;">
                        <div style="position: relative; max-width: 400px;">
                            <i class="fas fa-search" style="position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--ins-muted);"></i>
                            <input type="text" placeholder="Search courses by name or status..." 
                                   data-search-target="#course-list-container" 
                                   data-search-item=".ins-course-card-v2"
                                   style="width: 100%; padding: 12px 16px 12px 42px; border: 1px solid var(--ins-border); border-radius: 8px; font-family: inherit;">
                        </div>
                    </div>
                    <section class="ins-course-grid" id="course-list-container" aria-label="Assigned courses">
                        <c:forEach var="course" items="${courses}">
                            <article class="ins-course-card-v2">
                                <div class="ins-card-banner-wrap">
                                    <c:choose>
                                        <c:when test="${not empty course.courseBanner}">
                                            <img src="${course.courseBanner}" alt="Banner" class="ins-card-banner">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="ins-card-banner-placeholder">
                                                <i class="fas fa-graduation-cap"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="ins-card-badges">
                                        <span class="chip chip-category"><c:out value="${empty course.category ? 'General' : course.category}"/></span>
                                        <span class="chip chip-level"><c:out value="${course.level}"/></span>
                                    </div>
                                </div>
                                <div class="ins-card-body">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; margin-bottom: 4px;">
                                        <h4 class="ins-card-title" data-search-text><c:out value="${course.courseName}"/></h4>
                                        <span class="status-badge status-${fn:toLowerCase(course.status)}" style="flex-shrink: 0;" data-search-text><c:out value="${course.status}"/></span>
                                    </div>
                                    <p class="ins-card-desc"><c:out value="${course.description}" default="No course summary description has been written for this curriculum yet."/></p>
                                    
                                    <div class="ins-card-metrics-row">
                                        <div class="ins-metric-item">
                                            <i class="fas fa-users icon-blue"></i>
                                            <div class="ins-metric-details">
                                                <span class="ins-metric-label">Enrolled</span>
                                                <span class="ins-metric-val"><c:out value="${courseStudentCounts[course.courseId] != null ? courseStudentCounts[course.courseId] : 0}"/></span>
                                            </div>
                                        </div>
                                        <div class="ins-metric-item">
                                            <i class="fas fa-history icon-green"></i>
                                            <div class="ins-metric-details">
                                                <span class="ins-metric-label">Duration</span>
                                                <span class="ins-metric-val" style="font-size: 0.78rem;"><c:out value="${course.displayDuration}"/></span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="ins-card-meta-footer">
                                        <span><i class="far fa-calendar-alt"></i> Updated: <c:out value="${not empty course.updatedAt ? course.updatedAt.toLocalDate() : '-'}"/></span>
                                        <span><i class="fas fa-code-branch"></i> ID: #${course.courseId}</span>
                                    </div>
                                </div>
                                <div class="ins-card-action">
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}" class="sv-btn primary btn-workspace-cta">
                                        Open Course Workspace <i class="fas fa-arrow-right arrow-icon"></i>
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
