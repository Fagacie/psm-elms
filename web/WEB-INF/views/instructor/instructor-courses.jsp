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
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
    <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
        <jsp:param name="pageTitle" value="My Courses"/>
        <jsp:param name="pageSubtitle" value="Manage assigned courses, content, and enrollments from one workspace"/>
    </jsp:include>

    <c:set var="activeInstructorPage" value="courses"/>
    <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

    <main class="app-main">
        <div class="content-wrapper">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
                <span>&gt;</span>
                <span>My Courses</span>
            </nav>

            <section class="ins-page-head">
                <div>
                    <p class="ins-page-kicker">Course Management</p>
                    <h2>Open each assigned course from a clean professional workspace</h2>
                    <p>Every card now acts as an entry point into a dedicated course workspace, so instructors can jump into materials, assessments, students, and analytics without reselecting the course.</p>
                </div>
                <div class="ins-hero-actions">
                    <span class="courses-count">${courses != null ? courses.size() : 0} courses</span>
                </div>
            </section>

            <c:if test="${param.success == 'updated'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Course updated successfully!
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> An error occurred. Please try again.
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty courses}">
                    <div class="empty-state-box course-empty-state">
                        <i class="fas fa-layer-group"></i>
                        <p>You do not have any courses assigned yet.</p>
                        <span>Once an admin assigns a course, it will appear here as a workspace card.</span>
                    </div>
                </c:when>
                <c:otherwise>
                    <section class="course-catalog-grid" aria-label="Assigned courses">
                        <c:forEach var="course" items="${courses}">
                            <article class="course-card">
                                <div class="course-card-media">
                                    <c:choose>
                                        <c:when test="${not empty course.courseBanner}">
                                            <img class="course-card-image" src="${course.courseBanner}" alt="${course.courseName} banner">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="course-card-image course-card-placeholder">
                                                <i class="fas fa-layer-group"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="status-badge status-${course.status}"><c:out value="${course.status}"/></span>
                                </div>

                                <div class="course-card-body">
                                    <div class="course-card-topline">
                                        <div>
                                            <h3 class="course-card-title"><c:out value="${course.courseName}"/></h3>
                                            <p class="course-card-subtitle">
                                                <c:out value="${empty course.category ? 'General' : course.category}"/> · <c:out value="${course.level}"/>
                                            </p>
                                        </div>
                                    </div>

                                    <div class="course-card-stats">
                                        <div class="course-card-stat">
                                            <strong><c:out value="${courseStudentCounts[course.courseId] != null ? courseStudentCounts[course.courseId] : 0}"/></strong>
                                            <span>Students</span>
                                        </div>
                                        <div class="course-card-stat">
                                            <strong><c:out value="${not empty course.updatedAt ? course.updatedAt.toLocalDate() : (not empty course.createdAt ? course.createdAt.toLocalDate() : '-') }"/></strong>
                                            <span>Updated</span>
                                        </div>
                                    </div>

                                    <div class="course-card-footer">
                                        <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}" class="btn btn-primary">
                                            <i class="fas fa-arrow-right"></i> Open Workspace
                                        </a>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </section>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <script>
        (function () {
            const cardDescriptionLimit = 118;

            function updateCardDescriptions() {
                const descriptions = document.querySelectorAll('.course-card-description');
                descriptions.forEach(function (description) {
                    const text = (description.textContent || '').trim();
                    if (text.length > cardDescriptionLimit) {
                        description.textContent = text.slice(0, cardDescriptionLimit) + '...';
                    }
                });
            }

            updateCardDescriptions();
        })();
    </script>
</body>
</html>
