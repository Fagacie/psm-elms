<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Materials - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-materials.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Materials"/>
    <jsp:param name="pageSubtitle" value="Organize learning assets by course and content type"/>
</jsp:include>

<c:set var="activeInstructorPage" value="materials"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Materials</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Learning Content</p>
                <h2>Organize course materials with clearer teaching flow</h2>
                <p>This page now follows the instructor workspace pattern so uploading, ordering, editing, and archiving materials feels more like a professional content studio.</p>
            </div>
            <div class="ins-hero-actions">
                <c:if test="${not empty selectedCourse}">
                    <button class="btn btn-primary" type="button" onclick="openUploadModal()">
                        <i class="fas fa-plus"></i> Add Material
                    </button>
                    <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}" class="btn btn-secondary">
                        <i class="fas fa-layer-group"></i> Open Workspace
                    </a>
                </c:if>
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                    <i class="fas fa-book"></i> Open Courses
                </a>
            </div>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>
        <c:if test="${param.success == 'created'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Material uploaded successfully.</div>
        </c:if>

        <section class="section-card materials-launch-panel">
            <div class="section-header">
                <div>
                    <h3 class="section-title">Materials Workspace Launcher</h3>
                    <p class="section-caption">Materials are now managed inside each course workspace. Use the cards below to jump straight into the right course.</p>
                </div>
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-primary btn-sm">
                    <i class="fas fa-layer-group"></i> Open My Courses
                </a>
            </div>

            <div class="materials-launch-grid">
                <c:choose>
                    <c:when test="${empty courses}">
                        <div class="empty-state-box">
                            <i class="fas fa-folder-open"></i>
                            <p>No courses are available yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="course" items="${courses}">
                            <article class="materials-launch-card">
                                <div class="materials-launch-card-top">
                                    <div>
                                        <h4><c:out value="${course.courseName}"/></h4>
                                        <p>
                                            <c:choose>
                                                <c:when test="${not empty course.description}">
                                                    <c:out value="${course.description}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    Open the workspace to manage materials, assessments, and students from one place.
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                    <span class="status-badge status-${course.status}"><c:out value="${course.status}"/></span>
                                </div>
                                <div class="materials-launch-meta">
                                    <span><i class="fas fa-tag"></i> <c:out value="${empty course.category ? 'General' : course.category}"/></span>
                                    <span><i class="fas fa-signal"></i> <c:out value="${course.level}"/></span>
                                    <span><i class="fas fa-clock"></i> <c:out value="${course.displayDuration}"/></span>
                                </div>
                                <div class="materials-launch-actions">
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}#materials" class="btn btn-primary btn-sm">
                                        <i class="fas fa-folder-open"></i> Open Workspace Materials
                                    </a>
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}" class="btn btn-secondary btn-sm">
                                        <i class="fas fa-layer-group"></i> Open Workspace
                                    </a>
                                </div>
                            </article>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </div>
</main>
</body>
</html>

