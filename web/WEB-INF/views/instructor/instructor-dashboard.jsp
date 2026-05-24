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
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        <section class="ins-hero-section">
            <div class="ins-hero-content">
                <h2>Welcome back, <c:out value="${not empty instructorName ? instructorName : user.fullName}"/> 👋</h2>
                <p>You have <strong>${pendingGrading}</strong> submission(s) awaiting grading and <strong>${dueSoon}</strong> assessment(s) due soon.</p>
            </div>
        </section>

        <%-- KPI CARDS --%>
        <section class="ins-kpi-section">
            <div class="ins-section-head">
                <h3>Overview</h3>
            </div>
            <div class="ins-attention-grid">
                <a href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard" class="ins-attention-card ins-attention-warn" style="text-decoration: none;">
                    <div class="ins-attention-icon"><i class="fas fa-pen-to-square"></i></div>
                    <div class="ins-attention-content">
                        <span class="ins-attention-label">Action Required</span>
                        <strong>${pendingGrading}</strong>
                        <small>Submissions awaiting grading</small>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/instructor/courses" class="ins-attention-card ins-attention-neutral" style="text-decoration: none;">
                    <div class="ins-attention-icon"><i class="fas fa-layer-group"></i></div>
                    <div class="ins-attention-content">
                        <span class="ins-attention-label">Active Courses</span>
                        <strong>${courseCount}</strong>
                        <small>Currently managed by you</small>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard" class="ins-attention-card ins-attention-good" style="text-decoration: none;">
                    <div class="ins-attention-icon"><i class="fas fa-calendar-check"></i></div>
                    <div class="ins-attention-content">
                        <span class="ins-attention-label">Upcoming Deadlines</span>
                        <strong>${dueSoon}</strong>
                        <small>Assessments due within 7 days</small>
                    </div>
                </a>
                <div class="ins-attention-card ins-attention-neutral">
                    <div class="ins-attention-icon"><i class="fas fa-users"></i></div>
                    <div class="ins-attention-content">
                        <span class="ins-attention-label">Total Students</span>
                        <strong>${studentCount}</strong>
                        <small>Across all your courses</small>
                    </div>
                </div>
            </div>
        </section>

        <%-- ANALYTICS CHART --%>
        <section class="pm-chart-section">
            <div class="ins-section-head-row">
                <div class="ins-section-label-group">
                    <h3>Teaching & Workload Analytics</h3>
                </div>
            </div>
            <div class="pm-chart-card">
                <div class="pm-chart-header">
                    <div>
                        <h4>Students & Grading Overview</h4>
                        <p>Visualizing total enrollments and pending submissions per course</p>
                    </div>
                </div>
                <div class="pm-chart-body">
                    <canvas id="pmAnalyticsChart"></canvas>
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

            <%-- Premium Skeletons Placeholders --%>
            <div id="insCoursesSkeleton" class="pm-skeleton-grid">
                <c:forEach begin="1" end="${courseCount > 0 ? courseCount : 3}">
                    <div class="pm-skeleton-card">
                        <div class="pm-skeleton-banner placeholder-shimmer"></div>
                        <div class="pm-skeleton-body">
                            <div class="pm-skeleton-title placeholder-shimmer"></div>
                            <div class="pm-skeleton-title short placeholder-shimmer"></div>
                            <div class="pm-skeleton-metrics">
                                <div class="pm-skeleton-metric placeholder-shimmer"></div>
                                <div class="pm-skeleton-metric placeholder-shimmer"></div>
                                <div class="pm-skeleton-metric placeholder-shimmer"></div>
                            </div>
                        </div>
                        <div class="pm-skeleton-footer placeholder-shimmer"></div>
                    </div>
                </c:forEach>
            </div>

            <%-- Actual Course Content Grid (transitions in after skeleton fades out) --%>
            <div id="insCoursesActual" style="display: none;">
                <c:choose>
                    <c:when test="${empty courses}">
                        <div class="ins-empty-courses">
                            <div class="ins-empty-icon"><i class="fas fa-layer-group"></i></div>
                            <p>No courses assigned yet.</p>
                            <span>Contact your administrator to get courses assigned.</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="pm-courses-grid">
                            <c:forEach var="course" items="${courses}">
                                <article class="pm-course-card" onclick="window.location.href='${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}'" style="cursor: pointer;">
                                    <%-- Card Image Banner --%>
                                    <div class="pm-card-banner">
                                        <c:choose>
                                            <c:when test="${not empty course.courseBanner}">
                                                <img src="${course.courseBanner}" alt="${course.courseName} banner">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="ins-card-banner-placeholder" style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; font-size:2.5rem; color:rgba(255,255,255,0.15);">
                                                    <i class="fas fa-book-open"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <%-- Premium Card Content --%>
                                    <div class="pm-card-body">
                                        <div class="pm-card-header">
                                            <h4 class="pm-course-title"><c:out value="${course.courseName}"/></h4>
                                            <span class="pm-status-badge pm-status-${fn:toLowerCase(course.status)}">
                                                <c:out value="${course.status}"/>
                                            </span>
                                        </div>

                                        <%-- Operational SVG Metrics Stack --%>
                                        <div class="pm-metrics-stack">
                                            <div class="pm-metric-item">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16"><path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3zM3.8 9.53l8.2 4.47 8.2-4.47-8.2-4.47-8.2 4.47zM12 16.5c-2.4 0-4.38-1.56-5.18-3.74l-1.84.84C6.12 16.64 8.8 18.5 12 18.5s5.88-1.86 7.02-4.9l-1.84-.84c-.8 2.18-2.78 3.74-5.18 3.74z"/></svg>
                                                <span><strong><c:out value="${courseEnrollmentCountById[course.courseId]}" default="0"/></strong> Enrolled Students</span>
                                            </div>
                                            <div class="pm-metric-item ${pendingSubmissionsByCourseId[course.courseId] > 0 ? 'pm-metric-warn' : ''}">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16"><path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H10v-2h4v2zm0-4H10v-4h4v4z"/></svg>
                                                <span><strong><c:out value="${pendingSubmissionsByCourseId[course.courseId]}" default="0"/></strong> Pending Submissions</span>
                                            </div>
                                            <div class="pm-metric-item">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16"><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm4.2 14.2L11 13V7h1.5v5.2l4.5 2.7-.8 1.3z"/></svg>
                                                <span>Duration: <strong><c:out value="${course.displayDuration}"/></strong></span>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Pill Shape CTA Manage Button --%>
                                    <div class="pm-card-footer">
                                        <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${course.courseId}"
                                           class="pm-manage-btn">
                                            Manage Course <i class="fas fa-arrow-right" style="margin-left: 4px;"></i>
                                        </a>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </div>
</main>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const ctx = document.getElementById('pmAnalyticsChart');
    if (!ctx) return;

    // Retrieve data arrays populated dynamically from JSP
    const courseNames = [];
    const studentCounts = [];
    const pendingSubmissions = [];

    <c:forEach var="course" items="${courses}">
        courseNames.push("<c:out value="${course.courseName}"/>");
        studentCounts.push(${not empty courseEnrollmentCountById[course.courseId] ? courseEnrollmentCountById[course.courseId] : 0});
        pendingSubmissions.push(${not empty pendingSubmissionsByCourseId[course.courseId] ? pendingSubmissionsByCourseId[course.courseId] : 0});
    </c:forEach>

    let chart = null;

    function getThemeColors() {
        const theme = document.documentElement.getAttribute('data-theme') || 'light';
        const isDark = theme === 'dark';
        return {
            isDark: isDark,
            text: isDark ? '#94a3b8' : '#64748b',
            grid: isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(15, 23, 42, 0.06)',
            primary: isDark ? 'hsl(250, 100%, 68%)' : 'hsl(256, 100%, 56%)',
            accent: isDark ? 'hsl(40, 96%, 54%)' : 'hsl(38, 92%, 38%)'
        };
    }

    function initChart() {
        const colors = getThemeColors();
        const ctx2d = ctx.getContext('2d');

        // Create elegant, brand-colored gradients for fills
        const gradientPrimary = ctx2d.createLinearGradient(0, 0, 0, 350);
        gradientPrimary.addColorStop(0, colors.isDark ? 'hsla(250, 100%, 68%, 0.85)' : 'hsla(256, 100%, 56%, 0.85)');
        gradientPrimary.addColorStop(1, colors.isDark ? 'hsla(250, 100%, 68%, 0.1)' : 'hsla(256, 100%, 56%, 0.1)');

        const gradientAccent = ctx2d.createLinearGradient(0, 0, 0, 350);
        gradientAccent.addColorStop(0, colors.isDark ? 'hsla(40, 96%, 54%, 0.85)' : 'hsla(38, 92%, 38%, 0.85)');
        gradientAccent.addColorStop(1, colors.isDark ? 'hsla(40, 96%, 54%, 0.1)' : 'hsla(38, 92%, 38%, 0.1)');
        
        chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: courseNames,
                datasets: [
                    {
                        label: 'Students Enrolled',
                        data: studentCounts,
                        backgroundColor: gradientPrimary,
                        borderWidth: 0, // completely remove default ugly borders
                        borderRadius: 8,
                        maxBarThickness: 45
                    },
                    {
                        label: 'Pending Submissions',
                        data: pendingSubmissions,
                        backgroundColor: gradientAccent,
                        borderWidth: 0, // completely remove default ugly borders
                        borderRadius: 8,
                        maxBarThickness: 45
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            color: colors.text,
                            font: {
                                family: "'Inter', sans-serif",
                                weight: '600',
                                size: 12
                            },
                            padding: 18
                        }
                    },
                    tooltip: {
                        backgroundColor: colors.isDark ? '#1e293b' : '#ffffff',
                        titleColor: colors.isDark ? '#ffffff' : '#0f172a',
                        bodyColor: colors.isDark ? '#cbd5e1' : '#334155',
                        borderColor: colors.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(15, 23, 42, 0.06)',
                        borderWidth: 1,
                        cornerRadius: 8, // rounded tooltip corners
                        padding: 12,
                        boxPadding: 6,
                        titleFont: {
                            family: "'Inter', sans-serif",
                            weight: '700',
                            size: 13
                        },
                        bodyFont: {
                            family: "'Inter', sans-serif",
                            size: 13
                        }
                    }
                },
                scales: {
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            color: colors.text,
                            font: {
                                family: "'Inter', sans-serif",
                                weight: '500'
                            }
                        }
                    },
                    y: {
                        grid: {
                            color: colors.grid,
                            borderDash: [5, 5], // elegant faint dashed lines
                            drawBorder: false // hide solid vertical border lines
                        },
                        ticks: {
                            color: colors.text,
                            precision: 0,
                            font: {
                                family: "'Inter', sans-serif"
                            }
                        }
                    }
                }
            }
        });
    }

    initChart();

    // Listen for theme mutations to update the chart dynamically
    const observer = new MutationObserver(function() {
        if (chart) {
            chart.destroy();
        }
        initChart();
    });

    observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['data-theme']
    });

    // Simulate high-end skeleton loading transition
    setTimeout(function() {
        const skeleton = document.getElementById('insCoursesSkeleton');
        const actual = document.getElementById('insCoursesActual');
        if (skeleton && actual) {
            skeleton.style.display = 'none';
            actual.style.display = 'block';
            actual.classList.add('ins-fade-in');
        }
    }, 600);
});
</script>
</main>
</body>
</html>
