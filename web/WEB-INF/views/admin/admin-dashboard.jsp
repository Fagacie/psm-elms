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
    window.__ADMIN_METRICS__ = {
        studentsCount: ${systemMetrics['studentsCount'] != null ? systemMetrics['studentsCount'] : 0},
        instructorsCount: ${systemMetrics['instructorsCount'] != null ? systemMetrics['instructorsCount'] : 0},
        totalRevenue: ${systemMetrics['totalRevenue'] != null ? systemMetrics['totalRevenue'] : 0},
        approvedCourses: ${systemMetrics['approvedCourses'] != null ? systemMetrics['approvedCourses'] : 0}
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
    window.__PERFORMANCE_DATA__ = [
        <c:forEach var="stat" items="${performanceStats}" varStatus="status">
            {
                day: "${fn:escapeXml(stat.day)}",
                dateLabel: "${fn:escapeXml(stat.dateLabel)}",
                Revenue: ${stat.revenue != null ? stat.revenue : 0.0},
                Enrollments: ${stat.enrollments != null ? stat.enrollments : 0}
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];
</script>

<!-- Interactive React Command Center Application -->
<script type="text/babel">
    const { useState, useEffect } = React;
    const { 
        ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid 
    } = window.Recharts || {};

    function AdminDashboard() {
        const [metrics] = useState(window.__ADMIN_METRICS__ || {});
        const [enrollments] = useState(window.__RECENT_ENROLLMENTS__ || []);
        const [performanceData] = useState(window.__PERFORMANCE_DATA__ || []);

        useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [enrollments]);

        return (
            <div className="admin-container">
                {/* Greenfield typographically prioritized Header */}
                <header className="dashboard-header-gf">
                    <h1>Command Center</h1>
                    <p>Real-time system oversight, student governance, financial analytics, and key platform metrics.</p>
                </header>

                {/* KPI Metrics Row */}
                <section className="kpi-grid-gf">
                    <div className="kpi-card-gf">
                        <div className="kpi-icon-gf">
                            <i data-lucide="graduation-cap"></i>
                        </div>
                        <div className="kpi-details-gf">
                            <span className="kpi-label-gf">Active Students</span>
                            <span className="kpi-value-gf">{metrics.studentsCount || 0}</span>
                        </div>
                    </div>

                    <div className="kpi-card-gf">
                        <div className="kpi-icon-gf">
                            <i data-lucide="users"></i>
                        </div>
                        <div className="kpi-details-gf">
                            <span className="kpi-label-gf">Total Instructors</span>
                            <span className="kpi-value-gf">{metrics.instructorsCount || 0}</span>
                        </div>
                    </div>

                    <div className="kpi-card-gf">
                        <div className="kpi-icon-gf">
                            <i data-lucide="dollar-sign"></i>
                        </div>
                        <div className="kpi-details-gf">
                            <span className="kpi-label-gf">Gross Revenue</span>
                            <span className="kpi-value-gf">
                                ₦{(metrics.totalRevenue || 0).toLocaleString('en-NG', { maximumFractionDigits: 0 })}
                            </span>
                        </div>
                    </div>

                    <div className="kpi-card-gf">
                        <div className="kpi-icon-gf">
                            <i data-lucide="book-open"></i>
                        </div>
                        <div className="kpi-details-gf">
                            <span className="kpi-label-gf">Published Courses</span>
                            <span className="kpi-value-gf">{metrics.approvedCourses || 0}</span>
                        </div>
                    </div>
                </section>

                {/* Recharts Platform Revenue Area Chart */}
                {window.Recharts && (
                    <section className="recent-activity-section-gf">
                        <div className="section-header-minimal-gf">
                            <h2>Platform Performance</h2>
                            <span>Billing collections and registration frequency over the past 7 days</span>
                        </div>
                        <div className="table-container-gf" style={{ padding: '2rem 1.5rem 1.5rem 0.5rem', height: '350px' }}>
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={performanceData} margin={{ top: 10, right: 10, left: 15, bottom: 0 }}>
                                    <defs>
                                        <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#10b981" stopOpacity={0.2}/>
                                            <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                    <XAxis dataKey="day" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                                    <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(v) => '₦' + v.toLocaleString()} />
                                    <Tooltip 
                                        contentStyle={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)' }}
                                        labelStyle={{ fontWeight: '700', color: '#0f172a' }}
                                    />
                                    <Area type="monotone" dataKey="Revenue" stroke="#10b981" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>
                    </section>
                )}

                {/* Global Action Bar */}
                <section className="action-bar-gf">
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
                <section className="recent-activity-section-gf">
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
