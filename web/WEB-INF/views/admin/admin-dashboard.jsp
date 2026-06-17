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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminDashboard.module.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for JSX rendering -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    
    <!-- Recharts dependencies (Prop-Types, Recharts UMD) -->
    <script src="https://unpkg.com/prop-types@15.8.1/prop-types.min.js"></script>
    <script src="https://unpkg.com/recharts@2.12.7/umd/Recharts.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Admin Dashboard"/>
    <jsp:param name="pageSubtitle" value="Manage platform operations from one structured workspace"/>
    <jsp:param name="showNotifications" value="true"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- React Root Entry Node -->
    <div id="admin-react-root"></div>
</main>

<!-- Serialize backend JSTL variables strictly to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__ADMIN_DASHBOARD_DATA__ = {
        totalRevenue: ${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0.0},
        totalUsers: ${systemMetrics['totalUsers'] != null ? systemMetrics['totalUsers'] : 0},
        activeCourses: ${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0},
        totalEnrollments: ${systemMetrics['totalEnrollments'] != null ? systemMetrics['totalEnrollments'] : 0},
        
        studentsCount: ${systemMetrics['studentsCount'] != null ? systemMetrics['studentsCount'] : 0},
        instructorsCount: ${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0},
        adminsCount: ${systemMetrics['adminsCount'] != null ? systemMetrics['adminsCount'] : 0},
        
        approvedCourses: ${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0},
        pendingCourses: ${systemMetrics['pendingCourses'] != null ? systemMetrics['pendingCourses'] : 0},
        archivedCourses: ${systemMetrics['archivedCourses'] != null ? systemMetrics['archivedCourses'] : 0},
        
        platformGrowth: [
            <c:forEach var="stat" items="${platformGrowth}" varStatus="status">
                {
                    date: "${fn:escapeXml(stat.date)}",
                    newUsers: ${stat.newUsers != null ? stat.newUsers : 0},
                    platformRevenue: ${stat.platformRevenue != null ? stat.platformRevenue : 0.0}
                }${not status.last ? ',' : ''}
            </c:forEach>
        ]
    };
    
    window.__RECENT_ENROLLMENTS__ = [
        <c:forEach var="enrollment" items="${recentEnrollments}" varStatus="status">
            {
                studentName: "${fn:escapeXml(enrollment.studentName)}",
                studentEmail: "${fn:escapeXml(enrollment.studentEmail)}",
                courseName: "${fn:escapeXml(enrollment.courseName)}",
                enrollmentDate: "${enrollment.enrollmentDate != null ? fn:substring(enrollment.enrollmentDate.toString(), 0, 10) : 'N/A'}",
                coursePrice: ${enrollment.coursePrice != null ? enrollment.coursePrice : 0},
                paymentStatus: "${fn:escapeXml(enrollment.paymentStatus)}"
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];
</script>

<!-- Interactive React Command Center Application -->
<script type="text/babel" data-presets="react,env">
    const { useState, useEffect } = React;
    const { 
        ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid,
        PieChart, Pie, Cell
    } = window.Recharts || {};

    const USER_COLORS = ['#3b82f6', '#10b981', '#f59e0b']; // Students, Instructors, Admins
    const COURSE_COLORS = ['#10b981', '#f59e0b', '#ef4444']; // Active, Pending, Archived

    function AdminDashboard() {
        const [adminDashboardData] = useState(window.__ADMIN_DASHBOARD_DATA__ || {});
        const [enrollments] = useState(window.__RECENT_ENROLLMENTS__ || []);

        useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [adminDashboardData, enrollments]);

        // Formatted distribution charts data source
        const userDemographicsData = [
            { name: 'Students', value: adminDashboardData.studentsCount || 0 },
            { name: 'Instructors', value: adminDashboardData.instructorsCount || 0 },
            { name: 'Admins', value: adminDashboardData.adminsCount || 0 }
        ];

        const courseStatusesData = [
            { name: 'Active Courses', value: adminDashboardData.approvedCourses || 0 },
            { name: 'Pending Approval', value: adminDashboardData.pendingCourses || 0 },
            { name: 'Rejected/Drafts', value: adminDashboardData.archivedCourses || 0 }
        ];

        return (
            <div className="ad_container">
                {/* Header */}
                <header className="ad_header">
                    <h1>Command Center</h1>
                    <p>Real-time platform-wide insights, student governance, financial analytics, and key platform metrics.</p>
                </header>

                {/* Top KPI Grid (Platform-Wide Metrics) */}
                <section className="ad_kpi_grid">
                    <div className="ad_kpi_card">
                        <div className="ad_kpi_icon emerald">
                            <i data-lucide="dollar-sign"></i>
                        </div>
                        <div className="ad_kpi_details">
                            <span className="ad_kpi_label">Total Revenue</span>
                            <span className="ad_kpi_value">
                                ₦{(adminDashboardData.totalRevenue || 0).toLocaleString('en-NG', { maximumFractionDigits: 0 })}
                            </span>
                        </div>
                    </div>

                    <div className="ad_kpi_card">
                        <div className="ad_kpi_icon blue">
                            <i data-lucide="users"></i>
                        </div>
                        <div className="ad_kpi_details">
                            <span className="ad_kpi_label">Total Users</span>
                            <span className="ad_kpi_value">
                                {(adminDashboardData.totalUsers || 0).toLocaleString()}
                            </span>
                        </div>
                    </div>

                    <div className="ad_kpi_card">
                        <div className="ad_kpi_icon violet">
                            <i data-lucide="book-open"></i>
                        </div>
                        <div className="ad_kpi_details">
                            <span className="ad_kpi_label">Active Courses</span>
                            <span className="ad_kpi_value">
                                {(adminDashboardData.activeCourses || 0).toLocaleString()}
                            </span>
                        </div>
                    </div>

                    <div className="ad_kpi_card">
                        <div className="ad_kpi_icon amber">
                            <i data-lucide="graduation-cap"></i>
                        </div>
                        <div className="ad_kpi_details">
                            <span className="ad_kpi_label">Enrollments</span>
                            <span className="ad_kpi_value">
                                {(adminDashboardData.totalEnrollments || 0).toLocaleString()}
                            </span>
                        </div>
                    </div>
                </section>

                {/* Main Growth Chart (Users & Revenue) */}
                {window.Recharts && (
                    <section className="ad_panel">
                        <div className="ad_panel_header">
                            <h2 className="ad_panel_title">Platform Growth Trends</h2>
                            <p className="ad_panel_subtitle">Daily breakdown of user registrations and gross platform revenue</p>
                        </div>
                        <div style={{ width: '100%', height: '350px' }}>
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={adminDashboardData.platformGrowth || []} margin={{ top: 10, right: 10, left: 10, bottom: 0 }}>
                                    <defs>
                                        <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#10b981" stopOpacity={0.15}/>
                                            <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                                        </linearGradient>
                                        <linearGradient id="colorUsers" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.15}/>
                                            <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" opacity={0.5} />
                                    <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                    <YAxis yAxisId="left" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} tickFormatter={(v) => '₦' + v.toLocaleString()} />
                                    <YAxis yAxisId="right" orientation="right" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                    <Tooltip 
                                        contentStyle={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' }}
                                        labelStyle={{ fontWeight: '700', color: '#0f172a' }}
                                        formatter={(value, name) => {
                                            if (name === "Revenue") return ['₦' + value.toLocaleString(), 'Daily Revenue'];
                                            if (name === "New Users") return [value.toLocaleString(), 'New Registrations'];
                                            return [value, name];
                                        }}
                                    />
                                    <Area yAxisId="left" type="monotone" dataKey="platformRevenue" name="Revenue" stroke="#10b981" strokeWidth={2.5} fillOpacity={1} fill="url(#colorRevenue)" />
                                    <Area yAxisId="right" type="monotone" dataKey="newUsers" name="New Users" stroke="#3b82f6" strokeWidth={2.5} fillOpacity={1} fill="url(#colorUsers)" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>
                    </section>
                )}

                {/* Bottom Insights (System Health Donut Charts) */}
                {window.Recharts && (
                    <section className="ad_distribution_grid">
                        {/* Donut 1: User Demographics */}
                        <div className="ad_donut_card">
                            <div className="ad_panel_header">
                                <h2 className="ad_panel_title">User Demographics</h2>
                                <p className="ad_panel_subtitle">Distribution of platform members by role</p>
                            </div>
                            <div className="ad_donut_chart_container">
                                <ResponsiveContainer width="100%" height="100%">
                                    <PieChart>
                                        <Pie
                                            data={userDemographicsData}
                                            cx="50%"
                                            cy="50%"
                                            innerRadius={60}
                                            outerRadius={80}
                                            paddingAngle={4}
                                            dataKey="value"
                                        >
                                            {userDemographicsData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={USER_COLORS[index % USER_COLORS.length]} />
                                            ))}
                                        </Pie>
                                        <Tooltip 
                                            contentStyle={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' }}
                                            formatter={(value, name) => [value, name]}
                                        />
                                    </PieChart>
                                </ResponsiveContainer>
                            </div>
                            <div className="ad_donut_legend">
                                {userDemographicsData.map((entry, idx) => (
                                    <div key={idx} className="ad_legend_item">
                                        <span className="ad_legend_dot" style={{ backgroundColor: USER_COLORS[idx % USER_COLORS.length] }}></span>
                                        <span>{entry.name}: {entry.value}</span>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Donut 2: Course Statuses */}
                        <div className="ad_donut_card">
                            <div className="ad_panel_header">
                                <h2 className="ad_panel_title">Course Statuses</h2>
                                <p className="ad_panel_subtitle">Overview of courses pending review or published</p>
                            </div>
                            <div className="ad_donut_chart_container">
                                <ResponsiveContainer width="100%" height="100%">
                                    <PieChart>
                                        <Pie
                                            data={courseStatusesData}
                                            cx="50%"
                                            cy="50%"
                                            innerRadius={60}
                                            outerRadius={80}
                                            paddingAngle={4}
                                            dataKey="value"
                                        >
                                            {courseStatusesData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={COURSE_COLORS[index % COURSE_COLORS.length]} />
                                            ))}
                                        </Pie>
                                        <Tooltip 
                                            contentStyle={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' }}
                                            formatter={(value, name) => [value, name]}
                                        />
                                    </PieChart>
                                </ResponsiveContainer>
                            </div>
                            <div className="ad_donut_legend">
                                {courseStatusesData.map((entry, idx) => (
                                    <div key={idx} className="ad_legend_item">
                                        <span className="ad_legend_dot" style={{ backgroundColor: COURSE_COLORS[idx % COURSE_COLORS.length] }}></span>
                                        <span>{entry.name}: {entry.value}</span>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </section>
                )}

                {/* Global Action Bar */}
                <section className="action-bar-gf" style={{ marginTop: '0px' }}>
                    <div className="action-buttons-gf">
                        <a href={window.__CONTEXT_PATH__ + '/admin/users'} className="action-btn-gf">
                            <i data-lucide="user-plus"></i> + Add New User
                        </a>
                        <a href={window.__CONTEXT_PATH__ + '/admin/courses'} className="action-btn-gf">
                            <i data-lucide="plus-circle"></i> + Create Course
                        </a>
                    </div>
                </section>

                {/* Recent Activity Table */}
                <section className="recent-activity-section-gf" style={{ marginTop: '0px' }}>
                    <div className="section-header-minimal-gf">
                        <h2>Recent Enrollments</h2>
                        <span>Latest admissions and payment verifications across the platform</span>
                    </div>

                    <div className="table-container-gf">
                        <table className="activity-table-gf">
                            <thead>
                                <tr>
                                    <th>Student Details</th>
                                    <th>Enrolled Course</th>
                                    <th>Date Enrolled</th>
                                    <th>Amount Paid</th>
                                    <th>Payment Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                {enrollments.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="empty-row-gf">
                                            No recent enrollments or activities recorded.
                                        </td>
                                    </tr>
                                ) : (
                                    enrollments.map((enrollment, idx) => (
                                        <tr key={idx}>
                                            <td>
                                                <div className="student-info-gf">
                                                    <span className="student-name-gf">{enrollment.studentName}</span>
                                                    <span className="student-email-gf">{enrollment.studentEmail}</span>
                                                </div>
                                            </td>
                                            <td className="course-name-cell-gf">{enrollment.courseName}</td>
                                            <td className="date-cell-gf">{enrollment.enrollmentDate}</td>
                                            <td className="amount-cell-gf">
                                                ₦{(enrollment.coursePrice || 0).toLocaleString('en-NG', { maximumFractionDigits: 0 })}
                                            </td>
                                            <td>
                                                <span className={"status-badge-gf " + (
                                                    enrollment.paymentStatus === 'Paid' || enrollment.paymentStatus.toLowerCase() === 'success'
                                                        ? 'badge-success-gf'
                                                        : enrollment.paymentStatus === 'Pending'
                                                        ? 'badge-pending-gf'
                                                        : 'badge-failed-gf'
                                                )}>
                                                    {enrollment.paymentStatus === 'Paid' || enrollment.paymentStatus.toLowerCase() === 'success' ? 'Successful' : enrollment.paymentStatus}
                                                </span>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        );
    }

    const container = document.getElementById('admin-react-root');
    const root = ReactDOM.createRoot(container);
    root.render(<AdminDashboard />);
</script>
</body>
</html>
