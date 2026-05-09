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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
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
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Platform Core Metrics</h2>
            </div>
            <div class="metrics-grid">
                <div class="metric-card metric-card-premium">
                    <div class="metric-card-header">
                        <div class="metric-icon-box m-users"><i class="fas fa-users"></i></div>
                        <div class="metric-label">Total Users</div>
                    </div>
                    <div class="metric-value"><c:out value="${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0}"/></div>
                    <div class="metric-meta">Students: <strong><c:out value="${systemMetrics['studentsCount'] != null ? systemMetrics['studentsCount'] : 0}"/></strong> &bull; Instructors: <strong><c:out value="${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0}"/></strong></div>
                </div>
                <div class="metric-card metric-card-premium">
                    <div class="metric-card-header">
                        <div class="metric-icon-box m-admins"><i class="fas fa-user-shield"></i></div>
                        <div class="metric-label">Administrators</div>
                    </div>
                    <div class="metric-value"><c:out value="${systemMetrics['adminsCount'] != null ? systemMetrics['adminsCount'] : 0}"/></div>
                    <div class="metric-meta">Accounts with full system privileges</div>
                </div>
                <div class="metric-card metric-card-premium">
                    <div class="metric-card-header">
                        <div class="metric-icon-box m-courses"><i class="fas fa-book-open"></i></div>
                        <div class="metric-label">Active Courses</div>
                    </div>
                    <div class="metric-value"><c:out value="${systemMetrics['activeCourses'] != null ? systemMetrics['activeCourses'] : 0}"/></div>
                    <div class="metric-meta">Pending Review: <strong style="color: #d97706;"><c:out value="${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0}"/></strong></div>
                </div>
                <div class="metric-card metric-card-premium">
                    <div class="metric-card-header">
                        <div class="metric-icon-box m-enrollments"><i class="fas fa-graduation-cap"></i></div>
                        <div class="metric-label">Total Enrollments</div>
                    </div>
                    <div class="metric-value"><c:out value="${systemMetrics['totalEnrollments'] != null ? systemMetrics['totalEnrollments'] : 0}"/></div>
                    <div class="metric-meta">Paid: <strong style="color: var(--admin-accent);"><c:out value="${systemMetrics['paidEnrollments'] != null ? systemMetrics['paidEnrollments'] : 0}"/></strong> &bull; Pending: <strong style="color: #d97706;"><c:out value="${systemMetrics['pendingEnrollments'] != null ? systemMetrics['pendingEnrollments'] : 0}"/></strong></div>
                </div>
                <div class="metric-card metric-card-premium">
                    <div class="metric-card-header">
                        <div class="metric-icon-box m-revenue"><i class="fas fa-wallet"></i></div>
                        <div class="metric-label">Gross Revenue</div>
                    </div>
                    <div class="metric-value">NGN <fmt:formatNumber value="${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0}" type="number" minFractionDigits="0" maxFractionDigits="0"/></div>
                    <div class="metric-meta">Platform financial collections</div>
                </div>
            </div>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Operational Status Review</h2>
                </div>
                <div class="operational-console-grid">
                    <div class="console-item-card status-review">
                        <div class="card-left-bar amber"></div>
                        <div class="card-main-content">
                            <div class="console-card-top">
                                <div class="console-icon amber"><i class="fas fa-clock"></i></div>
                                <span class="badge badge-warning">Review</span>
                            </div>
                            <div class="console-card-metric">
                                <div class="m-number"><c:out value="${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0}"/></div>
                                <div class="m-label">Pending Courses</div>
                            </div>
                        </div>
                    </div>
                    <div class="console-item-card status-watch">
                        <div class="card-left-bar orange"></div>
                        <div class="card-main-content">
                            <div class="console-card-top">
                                <div class="console-icon orange"><i class="fas fa-user-clock"></i></div>
                                <span class="badge badge-warning">Watch</span>
                            </div>
                            <div class="console-card-metric">
                                <div class="m-number"><c:out value="${systemMetrics['pendingEnrollments'] != null ? systemMetrics['pendingEnrollments'] : 0}"/></div>
                                <div class="m-label">Pending Enrollments</div>
                            </div>
                        </div>
                    </div>
                    <div class="console-item-card status-managed">
                        <div class="card-left-bar emerald"></div>
                        <div class="card-main-content">
                            <div class="console-card-top">
                                <div class="console-icon emerald"><i class="fas fa-chalkboard-teacher"></i></div>
                                <span class="badge badge-success">Managed</span>
                            </div>
                            <div class="console-card-metric">
                                <div class="m-number"><c:out value="${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0}"/></div>
                                <div class="m-label">Instructors</div>
                            </div>
                        </div>
                    </div>
                    <div class="console-item-card status-live">
                        <div class="card-left-bar blue"></div>
                        <div class="card-main-content">
                            <div class="console-card-top">
                                <div class="console-icon blue"><i class="fas fa-check-circle"></i></div>
                                <span class="badge badge-success">Live</span>
                            </div>
                            <div class="console-card-metric">
                                <div class="m-number"><c:out value="${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0}"/></div>
                                <div class="m-label">Approved Courses</div>
                            </div>
                        </div>
                    </div>
                    <div class="console-item-card status-stored">
                        <div class="card-left-bar slate"></div>
                        <div class="card-main-content">
                            <div class="console-card-top">
                                <div class="console-icon slate"><i class="fas fa-archive"></i></div>
                                <span class="badge badge-secondary">Stored</span>
                            </div>
                            <div class="console-card-metric">
                                <div class="m-number"><c:out value="${systemMetrics['archivedCourses'] != null ? systemMetrics['archivedCourses'] : 0}"/></div>
                                <div class="m-label">Archived Courses</div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>Real-Time System Telemetry</h2>
                </div>
                <div class="telemetry-grid">
                    <div class="telemetry-card">
                        <div class="telemetry-card-head">
                            <div class="t-title-stack">
                                <strong>Database Cluster</strong>
                                <span class="t-sub">PostgreSQL Connection Pool</span>
                            </div>
                            <div class="telemetry-status">
                                <span class="pulse-dot green"></span> <span class="t-status-text text-green">Healthy</span>
                            </div>
                        </div>
                        <div class="telemetry-chart-box">
                            <svg class="telemetry-sparkline" viewBox="0 0 140 30">
                                <path d="M0,15 Q10,12 20,18 T40,15 T60,20 T80,10 T100,16 T120,8 T140,15" fill="none" stroke="#10b981" stroke-width="1.8" />
                            </svg>
                        </div>
                        <div class="telemetry-meta">
                            <div class="meta-stat">
                                <span class="m-stat-lbl">Uptime</span>
                                <span class="m-stat-val">99.99%</span>
                            </div>
                            <div class="meta-stat">
                                <span class="m-stat-lbl">Active Conn</span>
                                <span class="m-stat-val">12/100</span>
                            </div>
                        </div>
                    </div>

                    <div class="telemetry-card">
                        <div class="telemetry-card-head">
                            <div class="t-title-stack">
                                <strong>Application Core</strong>
                                <span class="t-sub">Tomcat / Servlets Threads</span>
                            </div>
                            <div class="telemetry-status">
                                <span class="pulse-dot green"></span> <span class="t-status-text text-green">Stable</span>
                            </div>
                        </div>
                        <div class="telemetry-chart-box">
                            <svg class="telemetry-sparkline" viewBox="0 0 140 30">
                                <path d="M0,22 Q15,10 30,15 T60,12 T90,24 T120,14 T140,18" fill="none" stroke="#3b82f6" stroke-width="1.8" />
                            </svg>
                        </div>
                        <div class="telemetry-meta">
                            <div class="meta-stat">
                                <span class="m-stat-lbl">Latency</span>
                                <span class="m-stat-val">45ms</span>
                            </div>
                            <div class="meta-stat">
                                <span class="m-stat-lbl">CPU Usage</span>
                                <span class="m-stat-val">12.4%</span>
                            </div>
                        </div>
                    </div>

                    <div class="telemetry-card">
                        <div class="telemetry-card-head">
                            <div class="t-title-stack">
                                <strong>Object Storage</strong>
                                <span class="t-sub">Local Uploads Partition</span>
                            </div>
                            <div class="telemetry-status">
                                <span class="pulse-dot green"></span> <span class="t-status-text text-green">Online</span>
                            </div>
                        </div>
                        <div class="telemetry-chart-box">
                            <div class="storage-bar-box">
                                <div class="storage-bar-fill" style="width: 24.5%;"></div>
                            </div>
                        </div>
                        <div class="telemetry-meta">
                            <div class="meta-stat">
                                <span class="m-stat-lbl">Available</span>
                                <span class="m-stat-val">75.5 GB</span>
                            </div>
                            <div class="meta-stat">
                                <span class="m-stat-lbl">Used Space</span>
                                <span class="m-stat-val">24.5%</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Administrative Control Hub</h2>
            </div>
            <div class="control-hub-grid">
                <a href="${pageContext.request.contextPath}/admin/users" class="control-hub-card">
                    <div class="card-accent-glow u-blue"></div>
                    <div class="hub-card-body">
                        <div class="hub-icon-circle bg-blue"><i class="fas fa-users"></i></div>
                        <div class="hub-text-block">
                            <strong>User Directory</strong>
                            <span>Audit active students &amp; instructors credentials</span>
                        </div>
                        <div class="hub-arrow-indicator"><i class="fas fa-arrow-right"></i></div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/admin/courses" class="control-hub-card">
                    <div class="card-accent-glow u-emerald"></div>
                    <div class="hub-card-body">
                        <div class="hub-icon-circle bg-emerald"><i class="fas fa-book-open"></i></div>
                        <div class="hub-text-block">
                            <strong>Courses Board</strong>
                            <span>Review curriculums and verify newly created courses</span>
                        </div>
                        <div class="hub-arrow-indicator"><i class="fas fa-arrow-right"></i></div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/admin/enrollments" class="control-hub-card">
                    <div class="card-accent-glow u-amber"></div>
                    <div class="hub-card-body">
                        <div class="hub-icon-circle bg-amber"><i class="fas fa-graduation-cap"></i></div>
                        <div class="hub-text-block">
                            <strong>Enrollments Hub</strong>
                            <span>Oversee compact student admissions &amp; verification</span>
                        </div>
                        <div class="hub-arrow-indicator"><i class="fas fa-arrow-right"></i></div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/admin/payments" class="control-hub-card">
                    <div class="card-accent-glow u-indigo"></div>
                    <div class="hub-card-body">
                        <div class="hub-icon-circle bg-indigo"><i class="fas fa-credit-card"></i></div>
                        <div class="hub-text-block">
                            <strong>Financials Ledger</strong>
                            <span>Trace secure payment transactions and audit collection gates</span>
                        </div>
                        <div class="hub-arrow-indicator"><i class="fas fa-arrow-right"></i></div>
                    </div>
                </a>
            </div>
        </section>
    </div>
</main>
</body>
</html>
