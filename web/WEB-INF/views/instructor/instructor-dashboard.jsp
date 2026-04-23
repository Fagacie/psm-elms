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
    <jsp:param name="pageSubtitle" value="Command center for courses, grading, and student activity"/>
    <jsp:param name="showNotifications" value="true"/>
</jsp:include>

<c:set var="activeInstructorPage" value="dashboard"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper dashboard-shell">
        <c:set var="courseCount" value="${not empty totalCourses ? totalCourses : 0}" />
        <c:set var="studentCount" value="${not empty totalStudents ? totalStudents : 0}" />
        <c:set var="totalEnrollmentCount" value="${not empty totalEnrollments ? totalEnrollments : 0}" />
        <c:set var="pendingEnrollmentCount" value="${not empty pendingEnrollments ? pendingEnrollments : 0}" />
        <c:set var="activeEnrollmentCount" value="${not empty activeEnrollments ? activeEnrollments : 0}" />
        <c:set var="activeCoursesCount" value="${not empty activeCourses ? activeCourses : 0}" />
        <c:set var="pendingGradingCount" value="${not empty pendingGradingCount ? pendingGradingCount : 0}" />
        <c:set var="publishedMaterialsCount" value="${not empty publishedMaterialsCount ? publishedMaterialsCount : 0}" />
        <c:set var="missingMaterialsCourseCount" value="${not empty missingMaterialsCourseCount ? missingMaterialsCourseCount : 0}" />
        <c:set var="dueSoonAssessmentCount" value="${not empty dueSoonAssessmentCount ? dueSoonAssessmentCount : 0}" />
        <c:set var="activeLearnersCount" value="${not empty activeLearnersCount ? activeLearnersCount : 0}" />
        <c:set var="averageProgressValue" value="${not empty averageProgress ? averageProgress : 0}" />
        <c:set var="firstCourseId" value="${not empty courses ? courses[0].courseId : ''}" />

        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <span>Overview</span>
        </nav>

        <section class="dashboard-hero-card">
            <div class="dashboard-hero-copy">
                <p class="dashboard-kicker">Instructor Command Center</p>
                <h2>Welcome back, <c:out value="${not empty instructorName ? instructorName : user.fullName}"/></h2>
                <p class="dashboard-subtitle">Your courses, grading queue, and student activity are organized below.</p>
            </div>

            <div class="dashboard-hero-panel">
                <div class="dashboard-chip-row">
                    <div class="dashboard-chip">
                        <span>Active Courses</span>
                        <strong><c:out value="${activeCoursesCount}" default="0"/></strong>
                    </div>
                    <div class="dashboard-chip">
                        <span>Pending Grading</span>
                        <strong><c:out value="${pendingGradingCount}" default="0"/></strong>
                    </div>
                    <div class="dashboard-chip">
                        <span>Total Students</span>
                        <strong><c:out value="${studentCount}" default="0"/></strong>
                    </div>
                </div>

                <div class="dashboard-activity-card">
                    <div class="dashboard-activity-head">
                        <span>Student Activity</span>
                        <strong><c:out value="${activeLearnersCount}" default="0"/> active learners</strong>
                    </div>
                    <div class="dashboard-activity-grid">
                        <div>
                            <span>Average Progress</span>
                            <strong><c:out value="${averageProgressValue}" default="0"/>%</strong>
                        </div>
                        <div>
                            <span>Completion Rate</span>
                            <strong>${totalEnrollmentCount > 0 ? (activeEnrollmentCount * 100) / totalEnrollmentCount : 0}%</strong>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="dashboard-kpis">
            <article class="dashboard-kpi-card kpi-accent">
                <p class="dashboard-kpi-label">Active Courses</p>
                <p class="dashboard-kpi-value"><c:out value="${activeCoursesCount}" default="0"/></p>
                <p class="dashboard-kpi-note">Approved courses currently available to learners.</p>
            </article>
            <article class="dashboard-kpi-card">
                <p class="dashboard-kpi-label">Students Enrolled</p>
                <p class="dashboard-kpi-value"><c:out value="${studentCount}" default="0"/></p>
                <p class="dashboard-kpi-note">Unique learners across your course portfolio.</p>
            </article>
            <article class="dashboard-kpi-card">
                <p class="dashboard-kpi-label">Pending Grading</p>
                <p class="dashboard-kpi-value"><c:out value="${pendingGradingCount}" default="0"/></p>
                <p class="dashboard-kpi-note">Submissions awaiting review and feedback.</p>
            </article>
            <article class="dashboard-kpi-card">
                <p class="dashboard-kpi-label">Published Materials</p>
                <p class="dashboard-kpi-value"><c:out value="${publishedMaterialsCount}" default="0"/></p>
                <p class="dashboard-kpi-note">Visible course materials across all live courses.</p>
            </article>
        </section>

        <section class="dashboard-grid">
            <article class="section-card section-card-wide">
                <div class="section-header section-header-tight">
                    <div>
                        <p class="section-eyebrow">My Courses Snapshot</p>
                        <h3 class="section-title">Course workload at a glance</h3>
                    </div>
                    <a class="link-action" href="${pageContext.request.contextPath}/instructor/courses">View all courses</a>
                </div>

                <c:choose>
                    <c:when test="${empty courses}">
                        <div class="empty-state empty-state-hero">
                            <i class="fas fa-layer-group"></i>
                            <p>No courses are assigned to your account yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="dashboard-table">
                                <thead>
                                <tr>
                                    <th>Course</th>
                                    <th>Enrolled</th>
                                    <th>Materials</th>
                                    <th>Pending Submissions</th>
                                    <th>Status</th>
                                    <th></th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="course" items="${courses}">
                                    <tr>
                                        <td data-label="Course">
                                            <div class="course-name-block">
                                                <strong><c:out value="${course.courseName}"/></strong>
                                                <span><c:out value="${course.level}"/> · <c:out value="${course.category}"/></span>
                                            </div>
                                        </td>
                                        <td data-label="Enrolled"><c:out value="${courseEnrollmentCountById[course.courseId]}" default="0"/></td>
                                        <td data-label="Materials"><c:out value="${courseMaterialCountById[course.courseId]}" default="0"/></td>
                                        <td data-label="Pending Submissions"><c:out value="${pendingSubmissionsByCourseId[course.courseId]}" default="0"/></td>
                                        <td data-label="Status">
                                            <span class="course-status-badge status-${fn:toLowerCase(course.status)}"><c:out value="${course.status}"/></span>
                                        </td>
                                        <td data-label="Actions" class="course-open-cell">
                                            <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}">Open Workspace</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </article>

            <aside class="dashboard-side-stack">
                <section class="section-card">
                    <div class="section-header section-header-tight">
                        <div>
                            <p class="section-eyebrow">Action Center</p>
                            <h3 class="section-title">Fast follow-up</h3>
                        </div>
                    </div>
                    <div class="action-grid">
                        <c:choose>
                            <c:when test="${not empty firstCourseId}">
                                <a class="action-card" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${firstCourseId}">
                                    <i class="fas fa-inbox"></i>
                                    <span>
                                        <strong>Review Submissions</strong>
                                        <small>Open the grading queue</small>
                                    </span>
                                </a>
                                <a class="action-card" href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${firstCourseId}#materials">
                                    <i class="fas fa-folder-open"></i>
                                    <span>
                                        <strong>Add Material</strong>
                                        <small>Go to the course workspace</small>
                                    </span>
                                </a>
                                <a class="action-card" href="${pageContext.request.contextPath}/instructor/assessments?view=drafts&courseId=${firstCourseId}">
                                    <i class="fas fa-clipboard-list"></i>
                                    <span>
                                        <strong>Create Assessment</strong>
                                        <small>Start a draft assessment</small>
                                    </span>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a class="action-card" href="${pageContext.request.contextPath}/instructor/assessments">
                                    <i class="fas fa-inbox"></i>
                                    <span>
                                        <strong>Review Submissions</strong>
                                        <small>Open the grading queue</small>
                                    </span>
                                </a>
                                <a class="action-card" href="${pageContext.request.contextPath}/instructor/courses">
                                    <i class="fas fa-folder-open"></i>
                                    <span>
                                        <strong>Add Material</strong>
                                        <small>Select a course first</small>
                                    </span>
                                </a>
                                <a class="action-card" href="${pageContext.request.contextPath}/instructor/assessments">
                                    <i class="fas fa-clipboard-list"></i>
                                    <span>
                                        <strong>Create Assessment</strong>
                                        <small>Select a course first</small>
                                    </span>
                                </a>
                            </c:otherwise>
                        </c:choose>
                        <a class="action-card" href="${pageContext.request.contextPath}/instructor/certificates">
                            <i class="fas fa-certificate"></i>
                            <span>
                                <strong>View Certificates</strong>
                                <small>Check issued credentials</small>
                            </span>
                        </a>
                    </div>
                </section>

                <section class="section-card">
                    <div class="section-header section-header-tight">
                        <div>
                            <p class="section-eyebrow">Attention Panel</p>
                            <h3 class="section-title">Needs your attention</h3>
                        </div>
                    </div>
                    <div class="attention-grid">
                        <article class="attention-card attention-warn">
                            <span class="attention-label">Grading</span>
                            <strong><c:out value="${pendingGradingCount}" default="0"/></strong>
                            <small>submissions awaiting grading</small>
                        </article>
                        <article class="attention-card attention-neutral">
                            <span class="attention-label">Materials</span>
                            <strong><c:out value="${missingMaterialsCourseCount}" default="0"/></strong>
                            <small>course(s) missing materials</small>
                        </article>
                        <article class="attention-card attention-good">
                            <span class="attention-label">Assessments</span>
                            <strong><c:out value="${dueSoonAssessmentCount}" default="0"/></strong>
                            <small>due within 7 days</small>
                        </article>
                    </div>
                </section>
            </aside>
        </section>
    </div>
</main>
</body>
</html>
