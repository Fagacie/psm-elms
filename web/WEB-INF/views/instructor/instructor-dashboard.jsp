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
    <jsp:param name="pageSubtitle" value="Your teaching workspace at a glance"/>
</jsp:include>

<c:set var="activeInstructorPage" value="dashboard"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper dashboard-shell">
        <c:set var="courseCount" value="${not empty totalCourses ? totalCourses : 0}"/>
        <c:set var="studentCount" value="${not empty totalStudents ? totalStudents : 0}"/>
        <c:set var="pendingGrading" value="${not empty pendingGradingCount ? pendingGradingCount : 0}"/>
        <c:set var="missingMats" value="${not empty missingMaterialsCourseCount ? missingMaterialsCourseCount : 0}"/>
        <c:set var="dueSoon" value="${not empty dueSoonAssessmentCount ? dueSoonAssessmentCount : 0}"/>

        <%-- WELCOME BANNER --%>
        <section class="ins-welcome-banner">
            <div class="ins-welcome-left">
                <div class="ins-welcome-avatar">
                    <i class="fas fa-chalkboard-teacher"></i>
                </div>
                <div class="ins-welcome-copy">
                    <h2>Welcome back, <c:out value="${not empty instructorName ? instructorName : user.fullName}"/> 👋</h2>
                    <p>You have <strong>${pendingGrading}</strong> submission(s) awaiting grading and <strong>${dueSoon}</strong> assessment(s) due soon.</p>
                </div>
            </div>
            <div class="ins-welcome-stats">
                <div class="ins-welcome-stat">
                    <span class="stat-val">${courseCount}</span>
                    <span class="stat-lbl">Courses</span>
                </div>
                <div class="ins-welcome-stat">
                    <span class="stat-val">${studentCount}</span>
                    <span class="stat-lbl">Students</span>
                </div>
                <div class="ins-welcome-stat">
                    <span class="stat-val">${pendingGrading}</span>
                    <span class="stat-lbl">Pending</span>
                </div>
            </div>
        </section>

        <%-- KPI CARDS --%>
        <section class="ins-kpi-section">
            <div class="ins-kpi-grid">
                <div class="ins-kpi-card kpi-warn">
                    <div class="kpi-icon-box"><i class="fas fa-pen-to-square"></i></div>
                    <div class="kpi-body">
                        <span class="kpi-label">Action Required</span>
                        <strong class="kpi-value">${pendingGrading}</strong>
                        <span class="kpi-sub">Submissions awaiting grading</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard" class="kpi-link-arrow"><i class="fas fa-arrow-right"></i></a>
                </div>
                <div class="ins-kpi-card kpi-info">
                    <div class="kpi-icon-box"><i class="fas fa-folder-open"></i></div>
                    <div class="kpi-body">
                        <span class="kpi-label">Course Health</span>
                        <strong class="kpi-value">${missingMats}</strong>
                        <span class="kpi-sub">Course(s) missing materials</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/instructor/courses" class="kpi-link-arrow"><i class="fas fa-arrow-right"></i></a>
                </div>
                <div class="ins-kpi-card kpi-good">
                    <div class="kpi-icon-box"><i class="fas fa-calendar-check"></i></div>
                    <div class="kpi-body">
                        <span class="kpi-label">Upcoming Deadlines</span>
                        <strong class="kpi-value">${dueSoon}</strong>
                        <span class="kpi-sub">Assessments due within 7 days</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard" class="kpi-link-arrow"><i class="fas fa-arrow-right"></i></a>
                </div>
                <div class="ins-kpi-card kpi-purple">
                    <div class="kpi-icon-box"><i class="fas fa-users"></i></div>
                    <div class="kpi-body">
                        <span class="kpi-label">Total Students</span>
                        <strong class="kpi-value">${studentCount}</strong>
                        <span class="kpi-sub">Across all your courses</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/instructor/courses" class="kpi-link-arrow"><i class="fas fa-arrow-right"></i></a>
                </div>
            </div>
        </section>

        <%-- COURSE CARDS --%>
        <section class="ins-courses-section">
            <div class="ins-section-head-row">
                <div class="ins-section-label-group">
                    <h3>My Courses</h3>
                    <span class="ins-course-count-badge">${courseCount} total</span>
                </div>
                <a class="ins-view-all-btn" href="${pageContext.request.contextPath}/instructor/courses">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>

            <c:choose>
                <c:when test="${empty courses}">
                    <div class="ins-empty-courses">
                        <div class="ins-empty-icon"><i class="fas fa-layer-group"></i></div>
                        <p>No courses assigned yet.</p>
                        <span>Contact your administrator to get courses assigned.</span>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="ins-course-cards-grid">
                        <c:forEach var="course" items="${courses}">
                            <article class="ins-course-card-v2">
                                <%-- Banner --%>
                                <div class="ins-card-banner">
                                    <c:choose>
                                        <c:when test="${not empty course.courseBanner}">
                                            <img src="${course.courseBanner}" alt="${course.courseName} banner">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="ins-card-banner-placeholder">
                                                <i class="fas fa-book-open"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="ins-card-status-pill status-${fn:toLowerCase(course.status)}">
                                        <c:out value="${course.status}"/>
                                    </span>
                                </div>

                                <%-- Card Body --%>
                                <div class="ins-card-body">
                                    <div class="ins-card-meta-chips">
                                        <span class="chip chip-category">
                                            <i class="fas fa-tag"></i>
                                            <c:out value="${empty course.category ? 'General' : course.category}"/>
                                        </span>
                                        <span class="chip chip-level">
                                            <i class="fas fa-signal"></i>
                                            <c:out value="${course.level}"/>
                                        </span>
                                    </div>
                                    <h4 class="ins-card-title"><c:out value="${course.courseName}"/></h4>

                                    <%-- Stats row --%>
                                    <div class="ins-card-stats-row">
                                        <div class="ins-card-stat">
                                            <i class="fas fa-users"></i>
                                            <strong><c:out value="${courseEnrollmentCountById[course.courseId]}" default="0"/></strong>
                                            <span>Students</span>
                                        </div>
                                        <div class="ins-card-stat">
                                            <i class="fas fa-clock"></i>
                                            <strong><c:out value="${pendingSubmissionsByCourseId[course.courseId]}" default="0"/></strong>
                                            <span>Pending</span>
                                        </div>
                                        <div class="ins-card-stat">
                                            <i class="fas fa-hourglass-half"></i>
                                            <strong><c:out value="${course.displayDuration}"/></strong>
                                            <span>Duration</span>
                                        </div>
                                    </div>
                                </div>

                                <%-- CTA --%>
                                <div class="ins-card-footer">
                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}"
                                       class="ins-card-cta-btn">
                                        Open Workspace <i class="fas fa-arrow-right"></i>
                                    </a>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<style>
/* Instructor Dashboard Premium Styles */
.ins-welcome-banner {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 20px;
    padding: 24px 28px;
    background: linear-gradient(135deg, #0f172a 0%, #1e293b 60%, #0f172a 100%);
    border-radius: 16px;
    margin-bottom: 24px;
    border: 1px solid rgba(148,163,184,0.14);
    box-shadow: 0 8px 30px rgba(2,6,17,0.4);
}

.ins-welcome-left {
    display: flex;
    align-items: center;
    gap: 18px;
}

.ins-welcome-avatar {
    width: 56px;
    height: 56px;
    border-radius: 14px;
    background: rgba(255,255,255,0.08);
    border: 1px solid rgba(255,255,255,0.12);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5rem;
    color: #94a3b8;
    flex-shrink: 0;
}

.ins-welcome-copy h2 {
    margin: 0 0 4px;
    font-size: 1.2rem;
    font-weight: 700;
    color: #ffffff;
}

.ins-welcome-copy p {
    margin: 0;
    color: #94a3b8;
    font-size: 0.88rem;
}

.ins-welcome-copy strong {
    color: #e2e8f0;
}

.ins-welcome-stats {
    display: flex;
    gap: 28px;
}

.ins-welcome-stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
}

.stat-val {
    font-size: 1.6rem;
    font-weight: 800;
    color: #ffffff;
    line-height: 1;
}

.stat-lbl {
    font-size: 0.72rem;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    font-weight: 600;
}

/* KPI Cards */
.ins-kpi-section { margin-bottom: 28px; }

.ins-kpi-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
    gap: 16px;
}

.ins-kpi-card {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 18px 20px;
    background: var(--ins-surface-strong, #fff);
    border: 1px solid var(--ins-border, #e2e8f0);
    border-radius: 14px;
    position: relative;
    overflow: hidden;
    transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;
    text-decoration: none;
    box-shadow: var(--ins-shadow-sm);
}

.ins-kpi-card:hover {
    transform: translateY(-3px);
    box-shadow: var(--ins-shadow-md);
    border-color: var(--ins-border-strong, #cbd5e1);
}

.kpi-icon-box {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
    flex-shrink: 0;
}

.kpi-warn .kpi-icon-box { background: rgba(245,158,11,0.1); color: #f59e0b; }
.kpi-info .kpi-icon-box { background: rgba(59,130,246,0.1); color: #3b82f6; }
.kpi-good .kpi-icon-box { background: rgba(16,185,129,0.1); color: #10b981; }
.kpi-purple .kpi-icon-box { background: rgba(139,92,246,0.1); color: #8b5cf6; }

/* left accent bar */
.ins-kpi-card::before {
    content: '';
    position: absolute;
    left: 0; top: 14px; bottom: 14px;
    width: 3px;
    border-radius: 0 3px 3px 0;
}
.kpi-warn::before { background: #f59e0b; }
.kpi-info::before { background: #3b82f6; }
.kpi-good::before { background: #10b981; }
.kpi-purple::before { background: #8b5cf6; }

.kpi-body { flex: 1; display: flex; flex-direction: column; gap: 1px; }
.kpi-label { font-size: 0.72rem; color: var(--ins-muted); font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
.kpi-value { font-size: 1.8rem; font-weight: 800; color: var(--ins-heading, #0f172a); line-height: 1; }
.kpi-sub { font-size: 0.78rem; color: var(--ins-muted); }

.kpi-link-arrow {
    color: var(--ins-muted);
    font-size: 0.85rem;
    transition: transform 0.2s ease, color 0.2s ease;
    text-decoration: none;
}

.ins-kpi-card:hover .kpi-link-arrow {
    transform: translateX(3px);
    color: var(--ins-heading, #0f172a);
}

/* Section header row */
.ins-courses-section { margin-bottom: 32px; }
.ins-section-head-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 18px;
}

.ins-section-label-group {
    display: flex;
    align-items: center;
    gap: 10px;
}

.ins-section-label-group h3 {
    margin: 0;
    font-size: 1.15rem;
    font-weight: 800;
    color: var(--ins-heading, #0f172a);
}

.ins-course-count-badge {
    background: var(--ins-primary-soft, rgba(15,23,42,0.05));
    color: var(--ins-muted);
    font-size: 0.74rem;
    font-weight: 700;
    padding: 3px 10px;
    border-radius: 999px;
    border: 1px solid var(--ins-border);
}

.ins-view-all-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 0.84rem;
    font-weight: 700;
    color: var(--ins-primary, #0f172a);
    text-decoration: none;
    padding: 7px 14px;
    border: 1px solid var(--ins-border);
    border-radius: 8px;
    background: var(--ins-surface-strong, #fff);
    transition: background 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
}

.ins-view-all-btn:hover {
    background: var(--ins-primary-soft);
    border-color: var(--ins-accent-border);
    transform: translateX(2px);
}

/* Course Cards V2 */
.ins-course-cards-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

.ins-course-card-v2 {
    background: var(--ins-surface-strong, #fff);
    border: 1px solid var(--ins-border, #e2e8f0);
    border-radius: 16px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    box-shadow: var(--ins-shadow-sm);
    transition: transform 0.25s cubic-bezier(0.4,0,0.2,1), box-shadow 0.25s ease, border-color 0.25s ease;
}

.ins-course-card-v2:hover {
    transform: translateY(-5px);
    box-shadow: var(--ins-shadow-md);
    border-color: var(--ins-border-strong, #cbd5e1);
}

/* Banner */
.ins-card-banner {
    position: relative;
    height: 150px;
    overflow: hidden;
    background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
    flex-shrink: 0;
}

.ins-card-banner img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.4s ease;
}

.ins-course-card-v2:hover .ins-card-banner img {
    transform: scale(1.04);
}

.ins-card-banner-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2.5rem;
    color: rgba(255,255,255,0.15);
}

.ins-card-status-pill {
    position: absolute;
    top: 12px;
    right: 12px;
    padding: 4px 12px;
    border-radius: 999px;
    font-size: 0.7rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.06em;
}

.ins-card-status-pill.status-approved,
.ins-card-status-pill.status-active {
    background: rgba(16,185,129,0.85);
    color: #fff;
    backdrop-filter: blur(4px);
}
.ins-card-status-pill.status-pending {
    background: rgba(245,158,11,0.85);
    color: #fff;
    backdrop-filter: blur(4px);
}
.ins-card-status-pill.status-archived {
    background: rgba(100,116,139,0.85);
    color: #fff;
    backdrop-filter: blur(4px);
}

/* Card Body */
.ins-card-body {
    padding: 18px 18px 14px;
    flex: 1;
}

.ins-card-meta-chips {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-bottom: 10px;
}

.chip {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 3px 10px;
    border-radius: 6px;
    font-size: 0.7rem;
    font-weight: 600;
}

.chip-category {
    background: rgba(59,130,246,0.08);
    color: #3b82f6;
}

.chip-level {
    background: rgba(139,92,246,0.08);
    color: #8b5cf6;
}

.ins-card-title {
    margin: 0 0 14px;
    font-size: 1rem;
    font-weight: 700;
    color: var(--ins-heading, #0f172a);
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Stats row */
.ins-card-stats-row {
    display: flex;
    gap: 16px;
}

.ins-card-stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
    flex: 1;
    padding: 10px 8px;
    background: var(--ins-surface-soft, #f8fafc);
    border: 1px solid var(--ins-border, #e2e8f0);
    border-radius: 10px;
    text-align: center;
}

.ins-card-stat i {
    font-size: 0.75rem;
    color: var(--ins-muted);
    margin-bottom: 2px;
}

.ins-card-stat strong {
    font-size: 1.1rem;
    font-weight: 800;
    color: var(--ins-heading, #0f172a);
    line-height: 1;
}

.ins-card-stat span {
    font-size: 0.68rem;
    color: var(--ins-muted);
    font-weight: 600;
}

/* Footer CTA */
.ins-card-footer {
    padding: 14px 18px;
    border-top: 1px solid var(--ins-border, #e2e8f0);
}

.ins-card-cta-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    width: 100%;
    padding: 10px 18px;
    background: var(--ins-primary, #0f172a);
    color: #ffffff;
    border-radius: 10px;
    font-size: 0.86rem;
    font-weight: 700;
    text-decoration: none;
    transition: background 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
}

.ins-card-cta-btn:hover {
    background: var(--ins-primary-strong, #020617);
    transform: translateY(-1px);
    box-shadow: 0 6px 18px rgba(15,23,42,0.25);
}

/* Empty courses */
.ins-empty-courses {
    text-align: center;
    padding: 56px 32px;
    background: var(--ins-surface-strong, #fff);
    border: 1px dashed var(--ins-border-strong, #cbd5e1);
    border-radius: 16px;
    color: var(--ins-muted);
}

.ins-empty-icon {
    font-size: 2.8rem;
    color: var(--ins-primary, #0f172a);
    opacity: 0.25;
    margin-bottom: 14px;
}

.ins-empty-courses p {
    margin: 0 0 4px;
    font-size: 1rem;
    font-weight: 700;
    color: var(--ins-heading, #0f172a);
}

.ins-empty-courses span {
    font-size: 0.86rem;
}

/* Dark mode card adaptation */
:root[data-theme="dark"] .ins-welcome-banner {
    background: linear-gradient(135deg, #090f1d 0%, #0e1726 60%, #090f1d 100%);
    border-color: rgba(148,163,184,0.14);
}

:root[data-theme="dark"] .ins-course-card-v2 {
    background: #0e1726;
    border-color: rgba(148,163,184,0.12);
}

:root[data-theme="dark"] .ins-card-stat {
    background: #111a2e;
    border-color: rgba(148,163,184,0.1);
}

:root[data-theme="dark"] .ins-card-title {
    color: #ffffff;
}

:root[data-theme="dark"] .ins-card-stat strong {
    color: #ffffff;
}

:root[data-theme="dark"] .ins-card-footer {
    border-top-color: rgba(148,163,184,0.1);
}

:root[data-theme="dark"] .ins-kpi-card {
    background: #0e1726;
    border-color: rgba(148,163,184,0.12);
}

:root[data-theme="dark"] .kpi-value {
    color: #ffffff;
}
</style>
</main>
</body>
</html>
