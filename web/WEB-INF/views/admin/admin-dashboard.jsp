<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Admin Dashboard"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="fas fa-angle-right"></i>
                <span>Admin Workspace</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">System Control Center</p>
                    <h2>Monitor users, courses, enrollments, and revenue from one admin workspace</h2>
                    <p>Use this dashboard to track platform health, review operational bottlenecks, and move quickly into the modules that need attention.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <span class="admin-orb admin-orb-a"></span>
                    <span class="admin-orb admin-orb-b"></span>
                    <span class="admin-shape admin-shape-a"></span>
                    <span class="admin-shape admin-shape-b"></span>
                    <div class="admin-scene-panel admin-scene-panel-a">
                        <span>Users</span>
                        <strong><c:out value="${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0}"/></strong>
                    </div>
                    <div class="admin-scene-panel admin-scene-panel-b">
                        <span>Revenue</span>
                        <strong>NGN <fmt:formatNumber value="${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Key Performance Indicators</h2>
            </div>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon"><i class="fas fa-users"></i></div>
                    <div class="metric-label">Total Users</div>
                    <div class="metric-value"><c:out value="${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0}"/></div>
                    <div class="metric-meta">
                        <i class="fas fa-user-graduate" style="margin-right: 5px;"></i><span id="students-count">0</span> Students
                        <i class="fas fa-chalkboard-teacher" style="margin-left: 10px; margin-right: 5px;"></i><span id="instructors-count">0</span> Instructors
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon"><i class="fas fa-book"></i></div>
                    <div class="metric-label">Active Courses</div>
                    <div class="metric-value"><c:out value="${systemMetrics['activeCourses'] != null ? systemMetrics['activeCourses'] : 0}"/></div>
                    <div class="metric-meta">
                        <i class="fas fa-clock" style="margin-right: 5px;"></i><span id="pending-courses">0</span> Pending Review
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon"><i class="fas fa-id-card"></i></div>
                    <div class="metric-label">Total Enrollments</div>
                    <div class="metric-value"><c:out value="${systemMetrics['totalEnrollments'] != null ? systemMetrics['totalEnrollments'] : 0}"/></div>
                    <div class="metric-meta">
                        <i class="fas fa-check-circle" style="margin-right: 5px;"></i><span id="paid-enrollments">0</span> Paid
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon"><i class="fas fa-credit-card"></i></div>
                    <div class="metric-label">Total Revenue</div>
                    <div class="metric-value">NGN <fmt:formatNumber value="${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></div>
                    <div class="metric-meta">
                        <i class="fas fa-arrow-up" style="margin-right: 5px;"></i>Monthly Income
                    </div>
                </div>
            </div>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Enrollment Status Distribution</h2>
                </div>
                <div class="chart-wrap">
                    <canvas id="enrollmentChart"></canvas>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>Course Status Overview</h2>
                </div>
                <div class="chart-wrap">
                    <canvas id="courseChart"></canvas>
                </div>
            </section>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Pending Actions</h2>
                </div>
                <div id="pending-actions" class="panel-stack">
                    <div class="empty-state">
                        <i class="fas fa-spinner fa-spin"></i> Loading...
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>System Status</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Database</strong>
                            <span>All systems operational</span>
                        </div>
                        <div class="status-state good"><i class="fas fa-check-circle"></i> Healthy</div>
                    </div>
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>API Server</strong>
                            <span>Response time normal</span>
                        </div>
                        <div class="status-state good"><i class="fas fa-check-circle"></i> Stable</div>
                    </div>
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Storage</strong>
                            <span>85% capacity used</span>
                        </div>
                        <div class="status-state good"><i class="fas fa-check-circle"></i> Available</div>
                    </div>
                </div>
            </section>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Quick Navigation</h2>
            </div>
            <div class="quick-links">
                <a href="${pageContext.request.contextPath}/admin/users" class="quick-link-card">
                    <i class="fas fa-users"></i>
                    <div><strong>User Management</strong></div>
                    <span>Manage all users</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/courses" class="quick-link-card">
                    <i class="fas fa-book"></i>
                    <div><strong>Courses</strong></div>
                    <span>Review and approve courses</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/enrollments" class="quick-link-card">
                    <i class="fas fa-id-card"></i>
                    <div><strong>Enrollments</strong></div>
                    <span>Track enrollments and payments</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/payments" class="quick-link-card">
                    <i class="fas fa-credit-card"></i>
                    <div><strong>Payments</strong></div>
                    <span>Payment records and reports</span>
                </a>
            </div>
        </section>
    </div>
</main>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        initializeCharts();
        loadPendingActions();
    });

    function initializeCharts() {
        const enrollmentCtx = document.getElementById('enrollmentChart').getContext('2d');
        new Chart(enrollmentCtx, {
            type: 'doughnut',
            data: {
                labels: ['Paid', 'Pending', 'Cancelled'],
                datasets: [{
                    data: [${systemMetrics['paidEnrollments'] != null ? systemMetrics['paidEnrollments'] : 0}, ${systemMetrics['pendingEnrollments'] != null ? systemMetrics['pendingEnrollments'] : 0}, ${systemMetrics['cancelledEnrollments'] != null ? systemMetrics['cancelledEnrollments'] : 0}],
                    backgroundColor: ['#22c55e', '#f59e0b', '#ef4444'],
                    borderColor: 'white',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            font: { size: 12 },
                            padding: 15,
                            color: '#c7d8ef'
                        }
                    }
                }
            }
        });

        const courseCtx = document.getElementById('courseChart').getContext('2d');
        new Chart(courseCtx, {
            type: 'bar',
            data: {
                labels: ['Approved', 'Pending', 'Archived'],
                datasets: [{
                    label: 'Courses',
                    data: [${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0}, ${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0}, ${systemMetrics['archivedCourses'] != null ? systemMetrics['archivedCourses'] : 0}],
                    backgroundColor: ['#3b82f6', '#f59e0b', '#9ca3af'],
                    borderColor: '#1d3554',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: '#1d3554'
                        },
                        ticks: {
                            font: { size: 12 },
                            color: '#9db2cf'
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            font: { size: 12 },
                            color: '#9db2cf'
                        }
                    }
                }
            }
        });
    }

    function loadPendingActions() {
        const pendingCourses = ${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0};
        const pendingEnrollments = ${systemMetrics['pendingEnrollments'] != null ? systemMetrics['pendingEnrollments'] : 0};
        let html = '';

        if (pendingCourses > 0) {
            html += '<div class="action-item">';
            html += '<div class="action-item-copy"><strong>Courses Pending Review</strong><span>' + pendingCourses + ' course' + (pendingCourses > 1 ? 's' : '') + ' awaiting approval</span></div>';
            html += '<a href="${pageContext.request.contextPath}/admin/courses?status=Pending" class="admin-btn">Review</a>';
            html += '</div>';
        }

        if (pendingEnrollments > 0) {
            html += '<div class="action-item">';
            html += '<div class="action-item-copy"><strong>Payments Pending</strong><span>' + pendingEnrollments + ' enrollment' + (pendingEnrollments > 1 ? 's' : '') + ' awaiting payment</span></div>';
            html += '<a href="${pageContext.request.contextPath}/admin/enrollments" class="admin-btn primary">View</a>';
            html += '</div>';
        }

        if (pendingCourses === 0 && pendingEnrollments === 0) {
            html = '<div class="empty-state"><i class="fas fa-check-circle" style="font-size:32px; color:#46d28a;"></i><strong>All Clear!</strong><div>No pending actions required</div></div>';
        }

        document.getElementById('pending-actions').innerHTML = html;
        document.getElementById('students-count').textContent = ${systemMetrics['studentsCount'] != null ? systemMetrics['studentsCount'] : 0};
        document.getElementById('instructors-count').textContent = ${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0};
        document.getElementById('pending-courses').textContent = pendingCourses;
        document.getElementById('paid-enrollments').textContent = ${systemMetrics['paidEnrollments'] != null ? systemMetrics['paidEnrollments'] : 0};
    }
</script>
</body>
</html>
