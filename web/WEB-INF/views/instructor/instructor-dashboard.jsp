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
        <jsp:param name="pageTitle" value="Instructor Dashboard"/>
        <jsp:param name="pageSubtitle" value="Overview of courses, enrollments, and teaching operations"/>
        <jsp:param name="showNotifications" value="true"/>
    </jsp:include>

    <c:set var="activeInstructorPage" value="dashboard"/>
    <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

    <!-- Main Content Area -->
    <main class="app-main">
        <div class="content-wrapper">
            <c:set var="courseCount" value="${not empty totalCourses ? totalCourses : 0}" />
            <c:set var="studentCount" value="${not empty totalStudents ? totalStudents : 0}" />
            <c:set var="totalEnrollmentCount" value="${not empty totalEnrollments ? totalEnrollments : 0}" />
            <c:set var="pendingEnrollmentCount" value="${not empty pendingEnrollments ? pendingEnrollments : 0}" />
            <c:set var="activeEnrollmentCount" value="${not empty activeEnrollments ? activeEnrollments : 0}" />
            <c:set var="completionRate" value="${totalEnrollmentCount > 0 ? (activeEnrollmentCount * 100) / totalEnrollmentCount : 0}" />

            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Overview</span>
            </nav>

            <section class="dashboard-shell">
                <div class="dashboard-hero-card">
                    <div class="dashboard-hero-copy">
                        <p class="dashboard-kicker">Instructor Command Center</p>
                        <h2>Shape, track, and improve your course portfolio from one focused workspace.</h2>
                        <p class="dashboard-subtitle">This view highlights the key signals that matter most: live courses, enrolled learners, approval pressure, and what needs your attention next.</p>
                        <div class="dashboard-actions">
                            <a href="${pageContext.request.contextPath}/instructor/courses?action=create" class="btn btn-primary">
                                <i class="fas fa-plus"></i>
                                Create Course
                            </a>
                            <a href="${pageContext.request.contextPath}/instructor/materials" class="btn btn-secondary">
                                <i class="fas fa-folder-open"></i>
                                Manage Materials
                            </a>
                            <a href="${pageContext.request.contextPath}/instructor/assessments" class="btn btn-secondary">
                                <i class="fas fa-clipboard-list"></i>
                                Review Assessments
                            </a>
                        </div>
                    </div>
                    <div class="dashboard-hero-panel">
                        <div class="hero-panel-head">
                            <span class="hero-panel-label">Today</span>
                            <span class="hero-panel-date">Instructor view</span>
                        </div>
                        <div class="hero-panel-score">
                            <strong>${completionRate}%</strong>
                            <span>Completion rate</span>
                        </div>
                        <div class="hero-panel-stack">
                            <div class="hero-mini-card">
                                <span>Pending enrollments</span>
                                <strong>${pendingEnrollmentCount}</strong>
                            </div>
                            <div class="hero-mini-card">
                                <span>Active learners</span>
                                <strong>${activeEnrollmentCount}</strong>
                            </div>
                        </div>
                    </div>
                </div>

                <section class="dashboard-stats">
                    <article class="stat-card stat-card-accent">
                        <p class="stat-label">Live Courses</p>
                        <p class="stat-value">${courseCount}</p>
                        <p class="stat-note">Courses currently owned by your account.</p>
                    </article>
                    <article class="stat-card">
                        <p class="stat-label">Total Students</p>
                        <p class="stat-value">${studentCount}</p>
                        <p class="stat-note">Unique learners enrolled across all your courses.</p>
                    </article>
                    <article class="stat-card">
                        <p class="stat-label">Total Enrollments</p>
                        <p class="stat-value">${totalEnrollmentCount}</p>
                        <p class="stat-note">All enrollment records tied to your course portfolio.</p>
                    </article>
                    <article class="stat-card">
                        <p class="stat-label">Pending Review</p>
                        <p class="stat-value">${pendingEnrollmentCount}</p>
                        <p class="stat-note">Applications still waiting on approval or processing.</p>
                    </article>
                </section>

                <div class="dashboard-grid">
                    <section class="section-card section-card-wide">
                        <div class="section-header section-header-tight">
                            <div>
                                <p class="section-eyebrow">Portfolio Overview</p>
                                <h3 class="section-title">Recent courses and their status</h3>
                            </div>
                            <a class="link-action" href="${pageContext.request.contextPath}/instructor/courses">View all</a>
                        </div>
                        <c:choose>
                            <c:when test="${not empty courses}">
                                <div class="course-portfolio-list">
                                    <c:forEach var="course" items="${courses}" begin="0" end="4" varStatus="loop">
                                        <article class="course-portfolio-item">
                                            <div class="course-portfolio-main">
                                                <div class="course-portfolio-badge"><c:out value="${loop.index + 1}"/></div>
                                                <div class="course-portfolio-copy">
                                                    <div class="course-portfolio-title"><c:out value="${course.courseName}"/></div>
                                                    <div class="course-portfolio-meta">
                                                        <span><c:out value="${course.level}"/></span>
                                                        <span><c:out value="${course.category}"/></span>
                                                        <span><c:choose><c:when test="${course.courseFee == 0}">Free</c:when><c:otherwise>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise></c:choose></span>
                                                        <span>${course.displayDuration}</span>
                                                    </div>
                                                    <div class="course-portfolio-desc">
                                                        <c:choose>
                                                            <c:when test="${not empty course.description && course.description.length() > 120}">
                                                                <c:out value="${course.description.substring(0, 120)}"/>...
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:out value="${course.description}"/>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="course-portfolio-side">
                                                <span class="course-status-badge status-${fn:toLowerCase(course.status)}"><c:out value="${course.status}"/></span>
                                                <div class="course-portfolio-updated">
                                                    <span>Last updated</span>
                                                    <strong>
                                                        <c:choose>
                                                            <c:when test="${not empty course.updatedAt}">
                                                                    <c:out value="${course.updatedAt}"/>
                                                            </c:when>
                                                            <c:otherwise>Not available</c:otherwise>
                                                        </c:choose>
                                                    </strong>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/instructor/content-organizer?courseId=${course.courseId}" class="btn btn-secondary btn-sm">
                                                    <i class="fas fa-layer-group"></i> Organize
                                                </a>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state empty-state-hero">
                                    <i class="fas fa-layer-group"></i>
                                    <p>No courses have been created yet.</p>
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=create" class="btn btn-primary btn-sm">
                                        <i class="fas fa-plus"></i> Create First Course
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </section>

                    <aside class="dashboard-side-stack">
                        <section class="section-card">
                            <div class="section-header section-header-tight">
                                <div>
                                    <p class="section-eyebrow">Status Mix</p>
                                    <h3 class="section-title">Enrollment health</h3>
                                </div>
                            </div>
                            <div class="status-metrics">
                                <div class="status-metric status-metric-good">
                                    <span>Active</span>
                                    <strong>${activeEnrollmentCount}</strong>
                                </div>
                                <div class="status-metric status-metric-warn">
                                    <span>Pending</span>
                                    <strong>${pendingEnrollmentCount}</strong>
                                </div>
                                <div class="status-metric status-metric-neutral">
                                    <span>Total</span>
                                    <strong>${totalEnrollmentCount}</strong>
                                </div>
                            </div>
                            <div class="status-meter">
                                <div class="status-meter-fill" style="--completion-rate: ${completionRate};"></div>
                            </div>
                            <p class="section-caption">Completion rate is derived from active enrollments versus the total enrollment volume.</p>
                        </section>

                        <section class="section-card">
                            <div class="section-header section-header-tight">
                                <div>
                                    <p class="section-eyebrow">Next Steps</p>
                                    <h3 class="section-title">High-value actions</h3>
                                </div>
                            </div>
                            <div class="action-stack">
                                <a class="action-link" href="${pageContext.request.contextPath}/instructor/courses?action=create">
                                    <i class="fas fa-plus-circle"></i>
                                    <span>
                                        <strong>Create new course</strong>
                                        <small>Publish a new offering and start approvals.</small>
                                    </span>
                                </a>
                                <a class="action-link" href="${pageContext.request.contextPath}/instructor/materials">
                                    <i class="fas fa-folder-open"></i>
                                    <span>
                                        <strong>Manage materials</strong>
                                        <small>Upload, edit, and reorder learning assets.</small>
                                    </span>
                                </a>
                                <a class="action-link" href="${pageContext.request.contextPath}/instructor/assessments">
                                    <i class="fas fa-clipboard-list"></i>
                                    <span>
                                        <strong>Review assessments</strong>
                                        <small>Build quizzes and inspect submission workflows.</small>
                                    </span>
                                </a>
                                <a class="action-link" href="${pageContext.request.contextPath}/instructor/certificates">
                                    <i class="fas fa-certificate"></i>
                                    <span>
                                        <strong>Verify certificates</strong>
                                        <small>Track completion and certificate readiness.</small>
                                    </span>
                                </a>
                            </div>
                        </section>
                    </aside>
                </div>
            </section>
        </div>
    </main>
</body>
</html>

