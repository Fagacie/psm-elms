const { useState, useEffect, useMemo, useCallback, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;

    
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
