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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
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
        <!-- Welcome Section -->
        <div style="padding-bottom: 20px; border-bottom: 1px solid var(--color-light-grey); margin-bottom: 30px;">
            <h1 style="font-size: 28px; color: var(--color-text); margin: 0 0 5px 0;"><i class="fas fa-tachometer-alt" style="color: var(--color-primary); margin-right: 10px;"></i>Dashboard</h1>
            <p style="color: var(--color-text-light); margin: 0; font-size: 14px;">Welcome, <strong>${sessionScope.user.fullName}</strong>! Here's your system overview.</p>
        </div>

        <!-- Key Performance Indicators -->
        <section class="section-card" style="margin-bottom: 30px;">
            <div class="section-header">
                <h2>Key Performance Indicators</h2>
            </div>
            <div class="metrics-grid">
                <!-- Total Users -->
                <div class="metric-card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: -10px; right: -10px; font-size: 60px; color: rgba(59, 130, 246, 0.1); z-index: 1;"><i class="fas fa-users"></i></div>
                    <div class="metric-label" style="position: relative; z-index: 2;">Total Users</div>
                    <div class="metric-value" style="position: relative; z-index: 2; color: var(--color-primary);"><c:out value="${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0}"/></div>
                    <div style="position: relative; z-index: 2; font-size: 12px; color: var(--color-text-light); margin-top: 8px;">
                        <i class="fas fa-user-graduate" style="margin-right: 5px;"></i><span id="students-count">0</span> Students
                        <i class="fas fa-chalkboard-teacher" style="margin-left: 10px; margin-right: 5px;"></i><span id="instructors-count">0</span> Instructors
                    </div>
                </div>

                <!-- Active Courses -->
                <div class="metric-card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: -10px; right: -10px; font-size: 60px; color: rgba(34, 197, 94, 0.1); z-index: 1;"><i class="fas fa-book"></i></div>
                    <div class="metric-label" style="position: relative; z-index: 2;">Active Courses</div>
                    <div class="metric-value" style="position: relative; z-index: 2; color: rgb(34, 197, 94);"><c:out value="${systemMetrics['activeCourses'] != null ? systemMetrics['activeCourses'] : 0}"/></div>
                    <div style="position: relative; z-index: 2; font-size: 12px; color: var(--color-text-light); margin-top: 8px;">
                        <i class="fas fa-clock" style="margin-right: 5px;"></i><span id="pending-courses">0</span> Pending Review
                    </div>
                </div>

                <!-- Total Enrollments -->
                <div class="metric-card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: -10px; right: -10px; font-size: 60px; color: rgba(245, 158, 11, 0.1); z-index: 1;"><i class="fas fa-id-card"></i></div>
                    <div class="metric-label" style="position: relative; z-index: 2;">Total Enrollments</div>
                    <div class="metric-value" style="position: relative; z-index: 2; color: rgb(245, 158, 11);"><c:out value="${systemMetrics['totalEnrollments'] != null ? systemMetrics['totalEnrollments'] : 0}"/></div>
                    <div style="position: relative; z-index: 2; font-size: 12px; color: var(--color-text-light); margin-top: 8px;">
                        <i class="fas fa-check-circle" style="margin-right: 5px;"></i><span id="paid-enrollments">0</span> Paid
                    </div>
                </div>

                <!-- Revenue -->
                <div class="metric-card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: -10px; right: -10px; font-size: 60px; color: rgba(236, 72, 153, 0.1); z-index: 1;"><i class="fas fa-credit-card"></i></div>
                    <div class="metric-label" style="position: relative; z-index: 2;">Total Revenue</div>
                    <div class="metric-value" style="position: relative; z-index: 2; color: rgb(236, 72, 153);">₦<fmt:formatNumber value="${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></div>
                    <div style="position: relative; z-index: 2; font-size: 12px; color: var(--color-text-light); margin-top: 8px;">
                        <i class="fas fa-arrow-up" style="margin-right: 5px;"></i>Monthly Income
                    </div>
                </div>
            </div>
        </section>

        <!-- Charts Section -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 30px;">
            <!-- Enrollment Status Chart -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Enrollment Status Distribution</h2>
                </div>
                <div style="position: relative; height: 300px; margin-bottom: 20px;">
                    <canvas id="enrollmentChart"></canvas>
                </div>
            </section>

            <!-- Course Status Chart -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Course Status Overview</h2>
                </div>
                <div style="position: relative; height: 300px; margin-bottom: 20px;">
                    <canvas id="courseChart"></canvas>
                </div>
            </section>
        </div>

        <!-- Quick Stats -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 30px;">
            <!-- Pending Actions -->
            <section class="section-card">
                <div class="section-header">
                    <h2><i class="fas fa-tasks" style="margin-right: 10px; color: var(--color-primary);"></i>Pending Actions</h2>
                </div>
                <div id="pending-actions" style="padding: 20px;">
                    <div style="text-align: center; color: var(--color-text-light);">
                        <i class="fas fa-spinner fa-spin"></i> Loading...
                    </div>
                </div>
            </section>

            <!-- System Status -->
            <section class="section-card">
                <div class="section-header">
                    <h2><i class="fas fa-server" style="margin-right: 10px; color: var(--color-success);"></i>System Status</h2>
                </div>
                <div style="padding: 20px;">
                    <div style="display: flex; align-items: center; margin-bottom: 15px; padding: 10px; background: rgba(34, 197, 94, 0.1); border-radius: 4px; border-left: 3px solid rgb(34, 197, 94);">
                        <i class="fas fa-check-circle" style="color: rgb(34, 197, 94); font-size: 18px; margin-right: 10px;"></i>
                        <div>
                            <div style="font-weight: 600; color: var(--color-text);">Database</div>
                            <div style="font-size: 12px; color: var(--color-text-light);">All systems operational</div>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; margin-bottom: 15px; padding: 10px; background: rgba(34, 197, 94, 0.1); border-radius: 4px; border-left: 3px solid rgb(34, 197, 94);">
                        <i class="fas fa-check-circle" style="color: rgb(34, 197, 94); font-size: 18px; margin-right: 10px;"></i>
                        <div>
                            <div style="font-weight: 600; color: var(--color-text);">API Server</div>
                            <div style="font-size: 12px; color: var(--color-text-light);">Response time normal</div>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; padding: 10px; background: rgba(34, 197, 94, 0.1); border-radius: 4px; border-left: 3px solid rgb(34, 197, 94);">
                        <i class="fas fa-check-circle" style="color: rgb(34, 197, 94); font-size: 18px; margin-right: 10px;"></i>
                        <div>
                            <div style="font-weight: 600; color: var(--color-text);">Storage</div>
                            <div style="font-size: 12px; color: var(--color-text-light);">85% capacity used</div>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <!-- Quick Links Section -->
        <section class="section-card">
            <div class="section-header">
                <h2><i class="fas fa-link" style="margin-right: 10px; color: var(--color-primary);"></i>Quick Navigation</h2>
            </div>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; padding: 20px 0;">
                <a href="${pageContext.request.contextPath}/admin/users" style="padding: 15px; border: 1px solid var(--color-light-grey); border-radius: 4px; text-decoration: none; color: var(--color-text); transition: all 0.3s ease;">
                    <div style="font-size: 24px; color: var(--color-primary); margin-bottom: 8px;"><i class="fas fa-users"></i></div>
                    <div style="font-weight: 600; margin-bottom: 4px;">User Management</div>
                    <div style="font-size: 12px; color: var(--color-text-light);">Manage all users</div>
                </a>
                <a href="${pageContext.request.contextPath}/admin/courses" style="padding: 15px; border: 1px solid var(--color-light-grey); border-radius: 4px; text-decoration: none; color: var(--color-text); transition: all 0.3s ease;">
                    <div style="font-size: 24px; color: rgb(34, 197, 94); margin-bottom: 8px;"><i class="fas fa-book"></i></div>
                    <div style="font-weight: 600; margin-bottom: 4px;">Courses</div>
                    <div style="font-size: 12px; color: var(--color-text-light);">Review & approve courses</div>
                </a>
                <a href="${pageContext.request.contextPath}/admin/enrollments" style="padding: 15px; border: 1px solid var(--color-light-grey); border-radius: 4px; text-decoration: none; color: var(--color-text); transition: all 0.3s ease;">
                    <div style="font-size: 24px; color: rgb(245, 158, 11); margin-bottom: 8px;"><i class="fas fa-id-card"></i></div>
                    <div style="font-weight: 600; margin-bottom: 4px;">Enrollments</div>
                    <div style="font-size: 12px; color: var(--color-text-light);">Track enrollments & payments</div>
                </a>
                <a href="${pageContext.request.contextPath}/admin/payments" style="padding: 15px; border: 1px solid var(--color-light-grey); border-radius: 4px; text-decoration: none; color: var(--color-text); transition: all 0.3s ease;">
                    <div style="font-size: 24px; color: rgb(236, 72, 153); margin-bottom: 8px;"><i class="fas fa-credit-card"></i></div>
                    <div style="font-weight: 600; margin-bottom: 4px;">Payments</div>
                    <div style="font-size: 12px; color: var(--color-text-light);">Payment records & reports</div>
                </a>
            </div>
        </section>
    </div>
</main>

<script>
    // Initialize charts when page loads
    document.addEventListener('DOMContentLoaded', function() {
        initializeCharts();
        loadPendingActions();
    });

    function initializeCharts() {
        // Enrollment Status Chart
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
                            color: '#475569'
                        }
                    }
                }
            }
        });

        // Course Status Chart
        const courseCtx = document.getElementById('courseChart').getContext('2d');
        new Chart(courseCtx, {
            type: 'bar',
            data: {
                labels: ['Approved', 'Pending', 'Archived'],
                datasets: [{
                    label: 'Courses',
                    data: [${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0}, ${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0}, ${systemMetrics['archivedCourses'] != null ? systemMetrics['archivedCourses'] : 0}],
                    backgroundColor: ['#3b82f6', '#f59e0b', '#9ca3af'],
                    borderColor: '#e2e8f0',
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
                            color: '#f5f7fa'
                        },
                        ticks: {
                            font: { size: 12 },
                            color: '#64748b'
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            font: { size: 12 },
                            color: '#64748b'
                        }
                    }
                }
            }
        });
    }

    function loadPendingActions() {
        // Calculate pending courses
        const pendingCourses = ${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0};
        const pendingEnrollments = ${systemMetrics['pendingEnrollments'] != null ? systemMetrics['pendingEnrollments'] : 0};
        
        let html = '';
        
        if (pendingCourses > 0) {
            html += '<div style="display: flex; justify-content: space-between; align-items: center; padding: 12px; background: rgba(245, 158, 11, 0.1); border-radius: 4px; margin-bottom: 10px; border-left: 3px solid rgb(245, 158, 11);">';
            html += '<div><strong style="color: var(--color-text);">Courses Pending Review</strong><div style="font-size: 12px; color: var(--color-text-light);">' + pendingCourses + ' course' + (pendingCourses > 1 ? 's' : '') + ' awaiting approval</div></div>';
            html += '<a href="${pageContext.request.contextPath}/admin/courses?status=Pending" style="padding: 6px 12px; background: rgb(245, 158, 11); color: white; text-decoration: none; border-radius: 2px; font-size: 12px; font-weight: 600;">Review</a>';
            html += '</div>';
        }
        
        if (pendingEnrollments > 0) {
            html += '<div style="display: flex; justify-content: space-between; align-items: center; padding: 12px; background: rgba(59, 130, 246, 0.1); border-radius: 4px; margin-bottom: 10px; border-left: 3px solid var(--color-primary);">';
            html += '<div><strong style="color: var(--color-text);">Payments Pending</strong><div style="font-size: 12px; color: var(--color-text-light);">' + pendingEnrollments + ' enrollment' + (pendingEnrollments > 1 ? 's' : '') + ' awaiting payment</div></div>';
            html += '<a href="${pageContext.request.contextPath}/admin/enrollments" style="padding: 6px 12px; background: var(--color-primary); color: white; text-decoration: none; border-radius: 2px; font-size: 12px; font-weight: 600;">View</a>';
            html += '</div>';
        }
        
        if (pendingCourses === 0 && pendingEnrollments === 0) {
            html = '<div style="text-align: center; padding: 30px; color: var(--color-text-light);"><i class="fas fa-check-circle" style="font-size: 32px; margin-bottom: 10px; display: block; color: rgb(34, 197, 94);"></i><strong>All Clear!</strong><div style="font-size: 12px;">No pending actions required</div></div>';
        }
        
        document.getElementById('pending-actions').innerHTML = html;
        
        // Update quick stats
        document.getElementById('students-count').textContent = ${systemMetrics['studentsCount'] != null ? systemMetrics['studentsCount'] : 0};
        document.getElementById('instructors-count').textContent = ${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0};
        document.getElementById('pending-courses').textContent = pendingCourses;
        document.getElementById('paid-enrollments').textContent = ${systemMetrics['paidEnrollments'] != null ? systemMetrics['paidEnrollments'] : 0};
    }
</script>
</body>
</html>
