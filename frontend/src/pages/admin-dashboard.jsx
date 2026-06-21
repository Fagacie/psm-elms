const { useState, useEffect, useMemo, useCallback, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;

const { motion } = window.Motion || {
    motion: {
        div: 'div',
        header: 'header',
        section: 'section'
    }
};

const { 
    ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid,
    PieChart, Pie, Cell
} = window.Recharts || {};

const USER_COLORS = ['#3b82f6', '#10b981', '#f59e0b']; // Students, Instructors, Admins
const COURSE_COLORS = ['#10b981', '#f59e0b', '#ef4444']; // Active, Pending, Archived

// Animation variants for staggered load
const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
        opacity: 1,
        transition: { staggerChildren: 0.1 }
    }
};

const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
        opacity: 1,
        y: 0,
        transition: { duration: 0.4, ease: "easeOut" }
    }
};

function AdminDashboard() {
    const [adminDashboardData] = useState(window.__ADMIN_DASHBOARD_DATA__ || {});
    const [enrollments] = useState(window.__RECENT_ENROLLMENTS__ || []);

    useEffect(() => {
        if (window.lucide) {
            window.lucide.createIcons();
        }
    }); // Run after every render to catch new lucide icons in the feed

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
        <motion.div 
            className="ad_container"
            variants={containerVariants}
            initial="hidden"
            animate="visible"
        >
            {/* Header */}
            <motion.header className="ad_header" variants={itemVariants}>
                <h1>Command Center</h1>
            </motion.header>

            {/* Top KPI Grid (Platform-Wide Metrics) */}
            <motion.section className="ad_kpi_grid" variants={itemVariants}>
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
            </motion.section>

            {/* Main Growth Chart (Users & Revenue) */}
            {window.Recharts && (
                <motion.section className="ad_panel" variants={itemVariants}>
                    <div className="ad_panel_header">
                        <h2 className="ad_panel_title">Platform Growth Trends</h2>
                    </div>
                    <div style={{ width: '100%', height: '350px' }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={adminDashboardData.platformGrowth || []} margin={{ top: 10, right: 10, left: 10, bottom: 0 }}>
                                <defs>
                                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#10b981" stopOpacity={0.8}/>
                                        <stop offset="95%" stopColor="#10b981" stopOpacity={0.05}/>
                                    </linearGradient>
                                    <linearGradient id="colorUsers" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.8}/>
                                        <stop offset="95%" stopColor="#3b82f6" stopOpacity={0.05}/>
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#64748b" opacity={0.2} />
                                <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                <YAxis yAxisId="left" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} tickFormatter={(v) => '₦' + v.toLocaleString()} />
                                <YAxis yAxisId="right" orientation="right" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                <Tooltip 
                                    contentStyle={{ borderRadius: '12px', border: '1px solid var(--admin-border-strong, #e5e7eb)', boxShadow: '0 8px 16px rgba(0, 0, 0, 0.1)' }}
                                    wrapperClassName="ad_chart_tooltip"
                                    labelStyle={{ fontWeight: '700', marginBottom: '8px' }}
                                    formatter={(value, name) => {
                                        if (name === "Revenue") return ['₦' + value.toLocaleString(), 'Daily Revenue'];
                                        if (name === "New Users") return [value.toLocaleString(), 'New Registrations'];
                                        return [value, name];
                                    }}
                                />
                                <Area yAxisId="left" type="monotone" dataKey="platformRevenue" name="Revenue" stroke="#10b981" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
                                <Area yAxisId="right" type="monotone" dataKey="newUsers" name="New Users" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorUsers)" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </motion.section>
            )}

            {/* Bottom Insights (System Health Donut Charts) */}
            {window.Recharts && (
                <motion.section className="ad_distribution_grid" variants={itemVariants}>
                    {/* Donut 1: User Demographics */}
                    <div className="ad_donut_card">
                        <div className="ad_panel_header">
                            <h2 className="ad_panel_title">User Demographics</h2>
                        </div>
                        <div className="ad_donut_chart_container">
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie
                                        data={userDemographicsData}
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={65}
                                        outerRadius={85}
                                        paddingAngle={4}
                                        dataKey="value"
                                        stroke="none"
                                    >
                                        {userDemographicsData.map((entry, index) => (
                                            <Cell key={`cell-${index}`} fill={USER_COLORS[index % USER_COLORS.length]} />
                                        ))}
                                    </Pie>
                                    <Tooltip 
                                        contentStyle={{ borderRadius: '12px', border: '1px solid var(--admin-border-strong, #e5e7eb)', boxShadow: '0 8px 16px rgba(0, 0, 0, 0.1)' }}
                                        wrapperClassName="ad_chart_tooltip"
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
                        </div>
                        <div className="ad_donut_chart_container">
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie
                                        data={courseStatusesData}
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={65}
                                        outerRadius={85}
                                        paddingAngle={4}
                                        dataKey="value"
                                        stroke="none"
                                    >
                                        {courseStatusesData.map((entry, index) => (
                                            <Cell key={`cell-${index}`} fill={COURSE_COLORS[index % COURSE_COLORS.length]} />
                                        ))}
                                    </Pie>
                                    <Tooltip 
                                        contentStyle={{ borderRadius: '12px', border: '1px solid var(--admin-border-strong, #e5e7eb)', boxShadow: '0 8px 16px rgba(0, 0, 0, 0.1)' }}
                                        wrapperClassName="ad_chart_tooltip"
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
                </motion.section>
            )}

            {/* NEW MODULES: Quick Actions & Live Activity Feed */}
            <motion.section className="ad_dashboard_lower" variants={itemVariants}>
                
                {/* Left: Quick Actions Command Hub */}
                <div className="ad_panel">
                    <div className="ad_panel_header">
                        <h2 className="ad_panel_title">Quick Actions</h2>
                    </div>
                    <div className="ad_quick_actions">
                        <a href={window.__CONTEXT_PATH__ + '/admin/courses'} className="ad_action_btn">
                            <i data-lucide="plus-circle" style={{ width: 32, height: 32, strokeWidth: 1.5 }}></i>
                            Add Courses
                        </a>
                        <a href={window.__CONTEXT_PATH__ + '/admin/payments'} className="ad_action_btn">
                            <i data-lucide="file-spreadsheet" style={{ width: 32, height: 32, strokeWidth: 1.5 }}></i>
                            View Financials
                        </a>
                        <a href={window.__CONTEXT_PATH__ + '/admin/users'} className="ad_action_btn">
                            <i data-lucide="user-plus" style={{ width: 32, height: 32, strokeWidth: 1.5 }}></i>
                            Manage Users
                        </a>
                        <a href={window.__CONTEXT_PATH__ + '/admin/settings'} className="ad_action_btn">
                            <i data-lucide="settings" style={{ width: 32, height: 32, strokeWidth: 1.5 }}></i>
                            System Settings
                        </a>
                    </div>
                </div>

                {/* Right: Recent Activity Feed */}
                <div className="ad_panel">
                    <div className="ad_panel_header">
                        <h2 className="ad_panel_title">Live Activity</h2>
                    </div>
                    <div className="ad_feed_list">
                        {enrollments.length === 0 ? (
                            <div style={{ textAlign: 'center', padding: '24px 0', color: 'var(--admin-muted)' }}>
                                <i data-lucide="activity" style={{ opacity: 0.5, marginBottom: 8 }}></i>
                                <div>No recent activity</div>
                            </div>
                        ) : (
                            enrollments.map((enr, idx) => {
                                const statusClass = enr.paymentStatus === 'Paid' || enr.paymentStatus.toLowerCase() === 'success' 
                                    ? 'success' 
                                    : enr.paymentStatus === 'Pending' ? 'pending' : 'failed';
                                
                                return (
                                    <div key={idx} className="ad_feed_item">
                                        <div className="ad_feed_avatar">
                                            {enr.studentName ? enr.studentName.charAt(0).toUpperCase() : 'U'}
                                        </div>
                                        <div className="ad_feed_content">
                                            <div className="ad_feed_title">{enr.studentName || 'Unknown User'}</div>
                                            <div style={{ fontSize: '0.8rem', color: 'var(--admin-text)' }}>
                                                Enrolled in <span style={{ fontWeight: 600 }}>{enr.courseName}</span>
                                            </div>
                                            <div className="ad_feed_meta">
                                                <span>{enr.enrollmentDate}</span>
                                                <span className={`ad_feed_status ${statusClass}`}>
                                                    {enr.paymentStatus}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                );
                            })
                        )}
                    </div>
                </div>

            </motion.section>
        </motion.div>
    );
}

const container = document.getElementById('admin-react-root');
const root = ReactDOM.createRoot(container);
root.render(<AdminDashboard />);
