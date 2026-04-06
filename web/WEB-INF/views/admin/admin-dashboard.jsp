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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Admin Dashboard"/>
    <jsp:param name="pageSubtitle" value="Manage platform operations from one structured workspace"/>
    <jsp:param name="showNotifications" value="true"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Admin Workspace</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Admin Overview</p>
                    <h2>Monitor users, courses, enrollments, payments, and certificates in one place.</h2>
                    <p>Everything here is arranged for fast scanning, clear hierarchy, and minimal visual noise.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <div class="admin-scene-panel">
                        <span>Total Users</span>
                        <strong><c:out value="${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0}"/></strong>
                    </div>
                    <div class="admin-scene-panel">
                        <span>Active Courses</span>
                        <strong><c:out value="${systemMetrics['activeCourses'] != null ? systemMetrics['activeCourses'] : 0}"/></strong>
                    </div>
                    <div class="admin-scene-panel">
                        <span>Total Revenue</span>
                        <strong>NGN <fmt:formatNumber value="${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Core Metrics</h2>
            </div>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-label">Users</div>
                    <div class="metric-value"><c:out value="${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0}"/></div>
                    <div class="metric-meta">Students <c:out value="${systemMetrics['studentsCount'] != null ? systemMetrics['studentsCount'] : 0}"/> and instructors <c:out value="${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0}"/></div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Applications</div>
                    <div class="metric-value"><c:out value="${systemMetrics['pendingApplications'] != null ? systemMetrics['pendingApplications'] : 0}"/></div>
                    <div class="metric-meta">Instructor submissions waiting for review</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Courses</div>
                    <div class="metric-value"><c:out value="${systemMetrics['activeCourses'] != null ? systemMetrics['activeCourses'] : 0}"/></div>
                    <div class="metric-meta">Pending review <c:out value="${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0}"/></div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Enrollments</div>
                    <div class="metric-value"><c:out value="${systemMetrics['totalEnrollments'] != null ? systemMetrics['totalEnrollments'] : 0}"/></div>
                    <div class="metric-meta">Paid <c:out value="${systemMetrics['paidEnrollments'] != null ? systemMetrics['paidEnrollments'] : 0}"/> / Pending <c:out value="${systemMetrics['pendingEnrollments'] != null ? systemMetrics['pendingEnrollments'] : 0}"/></div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Revenue</div>
                    <div class="metric-value">NGN <fmt:formatNumber value="${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></div>
                    <div class="metric-meta">Current month collections</div>
                </div>
            </div>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Operational Review</h2>
                </div>
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Area</th>
                                <th>Status</th>
                                <th>Count</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Pending courses</td>
                                <td><span class="status-badge">Review</span></td>
                                <td><c:out value="${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0}"/></td>
                            </tr>
                            <tr>
                                <td>Pending enrollments</td>
                                <td><span class="status-badge">Watch</span></td>
                                <td><c:out value="${systemMetrics['pendingEnrollments'] != null ? systemMetrics['pendingEnrollments'] : 0}"/></td>
                            </tr>
                            <tr>
                                <td>Instructor applications</td>
                                <td><span class="status-badge">Review</span></td>
                                <td><c:out value="${systemMetrics['pendingApplications'] != null ? systemMetrics['pendingApplications'] : 0}"/></td>
                            </tr>
                            <tr>
                                <td>Approved courses</td>
                                <td><span class="status-badge">Live</span></td>
                                <td><c:out value="${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0}"/></td>
                            </tr>
                            <tr>
                                <td>Archived courses</td>
                                <td><span class="status-badge">Stored</span></td>
                                <td><c:out value="${systemMetrics['archivedCourses'] != null ? systemMetrics['archivedCourses'] : 0}"/></td>
                            </tr>
                        </tbody>
                    </table>
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
                        <div class="status-state good">Healthy</div>
                    </div>
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Application</strong>
                            <span>Response time normal</span>
                        </div>
                        <div class="status-state good">Stable</div>
                    </div>
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Storage</strong>
                            <span>Capacity within safe range</span>
                        </div>
                        <div class="status-state good">Available</div>
                    </div>
                </div>
            </section>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Quick Actions</h2>
            </div>
            <div class="quick-links">
                <a href="${pageContext.request.contextPath}/admin/users" class="quick-link-card">
                    <i class="fas fa-users"></i>
                    <strong>Users</strong>
                    <span>Open user management</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/instructor-applications" class="quick-link-card">
                    <i class="fas fa-file-signature"></i>
                    <strong>Applications</strong>
                    <span>Review instructor requests</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/courses" class="quick-link-card">
                    <i class="fas fa-book"></i>
                    <strong>Courses</strong>
                    <span>Review course approvals</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/enrollments" class="quick-link-card">
                    <i class="fas fa-id-card"></i>
                    <strong>Enrollment</strong>
                    <span>Check enrollment records</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/payments" class="quick-link-card">
                    <i class="fas fa-credit-card"></i>
                    <strong>Payment</strong>
                    <span>View transaction records</span>
                </a>
            </div>
        </section>
    </div>
</main>
</body>
</html>
