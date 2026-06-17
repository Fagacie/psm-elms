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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/InstructorDashboard.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-workspace-modern.css?v=1">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp" />
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for JSX rendering -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    
    <!-- Recharts dependencies (Prop-Types, Recharts UMD) -->
    <script src="https://unpkg.com/prop-types@15.8.1/prop-types.min.js"></script>
    <script src="https://unpkg.com/recharts@2.12.7/umd/Recharts.js"></script>

    <!-- Framer Motion UMD -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>

    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
</head>

                <body class="instructor-ui">
                    <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
                        <jsp:param name="pageTitle" value="Dashboard" />
                        <jsp:param name="pageSubtitle" value="Your teaching workspace at a glance" />
                    </jsp:include>

                    <c:set var="activeInstructorPage" value="dashboard" />
                    <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp" />

                    <main class="app-main">
                        <!-- Scoped React Sandbox Root -->
                        <div id="instructor-react-root"></div>
                    </main>

                    <!-- Serialize JSTL properties to window state for React sandbox execution -->
                    <script type="text/javascript">
                        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
                        window.__INSTRUCTOR_NAME__ = "${not empty instructorName ? fn:escapeXml(instructorName) : fn:escapeXml(user.fullName)}";
                        window.__INSTRUCTOR_DASHBOARD_DATA__ = {
                            studentCount: ${not empty totalStudents ? totalStudents : 0},
                            newEnrollments: ${not empty newEnrollments30Days ? newEnrollments30Days : 0},
                            avgScore: ${not empty averageAssessmentScore ? averageAssessmentScore : 0},
                            courseCount: ${not empty totalCourses ? totalCourses : 0},
                            
                            completedCount: ${not empty completedEnrollmentsCount ? completedEnrollmentsCount : 0},
                            inProgressCount: ${not empty inProgressEnrollmentsCount ? inProgressEnrollmentsCount : 0},
                            droppedCount: ${not empty droppedEnrollmentsCount ? droppedEnrollmentsCount : 0},
                            
                            passedSubmissions: ${not empty passedSubmissions ? passedSubmissions : 0},
                            failedSubmissions: ${not empty failedSubmissions ? failedSubmissions : 0},
                            
                            monthlyTrends: [
                                <c:forEach var="trend" items="${monthlyTrends}" varStatus="status">
                                    {
                                        date: "${fn:escapeXml(trend.date)}",
                                        enrollments: ${trend.enrollments != null ? trend.enrollments : 0},
                                        revenue: ${trend.revenue != null ? trend.revenue : 0.0}
                                    }${not status.last ? ',' : ''}
                                </c:forEach>
                            ]
                        };
                        window.__COURSES__ = [
                            <c:forEach var="course" items="${courses}" varStatus="status">
                                {
                                    courseId: ${course.courseId},
                                    courseName: "${fn:escapeXml(course.courseName)}",
                                    courseBanner: "${fn:escapeXml(course.courseBanner)}",
                                    status: "${fn:escapeXml(course.status)}",
                                    displayDuration: "${fn:escapeXml(course.displayDuration)}",
                                    enrolledCount: ${not empty courseEnrollmentCountById[course.courseId] ? courseEnrollmentCountById[course.courseId] : 0},
                                    materialCount: ${not empty courseMaterialCountById[course.courseId] ? courseMaterialCountById[course.courseId] : 0},
                                    assessmentCount: ${not empty courseAssessmentCountById[course.courseId] ? courseAssessmentCountById[course.courseId] : 0},
                                    pendingGradingCount: ${not empty pendingSubmissionsByCourseId[course.courseId] ? pendingSubmissionsByCourseId[course.courseId] : 0}
                                }${not status.last ? ',' : ''}
                            </c:forEach>
                        ];
                    </script>

                    <!-- Interactive React Sandbox Application (Zero CSS Bleed) -->
                    <script type="text/babel" data-presets="react,env">
                        const { useState, useEffect } = React;
                        const { 
                            ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid,
                            PieChart, Pie, Cell
                        } = window.Recharts || {};

                        // CSS Module class mappings
                        const styles = {
                            container: 'ins_mod_123_container',
                            sectionTitle: 'ins_mod_123_section_title',
                            sectionSubtitle: 'ins_mod_123_section_subtitle',
                            kpiRow: 'ins_mod_123_kpi_row',
                            kpiCard: 'ins_mod_123_kpi_card',
                            kpiContent: 'ins_mod_123_kpi_content',
                            kpiNum: 'ins_mod_123_kpi_num',
                            kpiLabel: 'ins_mod_123_kpi_label',
                            kpiDesc: 'ins_mod_123_kpi_desc',
                            kpiIcon: 'ins_mod_123_kpi_icon',
                            chartCard: 'ins_mod_123_chart_card',
                            chartHeader: 'ins_mod_123_chart_header',
                            chartLegend: 'ins_mod_123_chart_legend',
                            legendItem: 'ins_mod_123_legend_item',
                            legendDotPrimary: 'ins_mod_123_legend_dot_primary',
                            legendDotAccent: 'ins_mod_123_legend_dot_accent',
                            customTooltip: 'ins_mod_123_custom_tooltip',
                            tooltipLabel: 'ins_mod_123_tooltip_label',
                            tooltipRow: 'ins_mod_123_tooltip_row',
                            tooltipVal: 'ins_mod_123_tooltip_val',
                            coursesSection: 'ins_mod_123_courses_section',
                            coursesHead: 'ins_mod_123_courses_head',
                            courseList: 'ins_mod_123_course_list',
                            courseRow: 'ins_mod_123_course_row',
                            courseLeft: 'ins_mod_123_course_left',
                            courseMiddle: 'ins_mod_123_course_middle',
                            courseTitle: 'ins_mod_123_course_title',
                            courseStatusPill: 'ins_mod_123_course_status_pill',
                            courseRight: 'ins_mod_123_course_right',
                            btnManage: 'ins_mod_123_btn_manage',
                            viewAllLink: 'ins_mod_123_view_all_link',
                            emptyState: 'ins_mod_123_empty_state',
                            emptyIcon: 'ins_mod_123_empty_icon',
                            distributionGrid: 'ins_mod_123_distribution_grid',
                            donutCard: 'ins_mod_123_donut_card',
                            donutChartContainer: 'ins_mod_123_donut_chart_container',
                            donutLegend: 'ins_mod_123_donut_legend'
                        };

                        // Scoped Motion Container supporting Framer Motion UMD and keyframe transition fallbacks
                        const MotionDiv = ({ children, initial, animate, transition, className, ...props }) => {
                            const MotionComponent = window.Motion && window.Motion.motion 
                                ? window.Motion.motion.div 
                                : (window.FramerMotion && window.FramerMotion.motion ? window.FramerMotion.motion.div : null);
                            
                            if (MotionComponent) {
                                return (
                                    <MotionComponent 
                                        initial={initial} 
                                        animate={animate} 
                                        transition={transition} 
                                        className={className} 
                                        {...props}
                                    >
                                        {children}
                                    </MotionComponent>
                                );
                            }
                            return (
                                <div className={`${className} ins_mod_123_fade_in_up`} {...props}>
                                    {children}
                                </div>
                            );
                        };

                        const COMPLETION_COLORS = ['#10b981', '#3b82f6', '#ef4444']; // Completed, In Progress, Dropped
                        const PASS_COLORS = ['#10b981', '#ef4444']; // Passed, Failed

                        function InstructorDashboard() {
                            const [dashboardData] = useState(window.__INSTRUCTOR_DASHBOARD_DATA__ || {});
                            const [courses] = useState(window.__COURSES__ || []);
                            const [instructorName] = useState(window.__INSTRUCTOR_NAME__ || 'Instructor');

                            useEffect(() => {
                                // Initialize Lucide Icons if loaded
                                if (window.lucide) {
                                    window.lucide.createIcons();
                                }
                            }, [dashboardData, courses]);

                            const totalCompletion = (dashboardData.completedCount || 0) + 
                                                    (dashboardData.inProgressCount || 0) + 
                                                    (dashboardData.droppedCount || 0);
                            const completionData = totalCompletion > 0 ? [
                                { name: 'Completed', value: dashboardData.completedCount || 0 },
                                { name: 'In Progress', value: dashboardData.inProgressCount || 0 },
                                { name: 'Dropped', value: dashboardData.droppedCount || 0 }
                            ] : [
                                { name: 'No Data Available', value: 1 }
                            ];

                            const totalPassRate = (dashboardData.passedSubmissions || 0) + 
                                                  (dashboardData.failedSubmissions || 0);
                            const passRateData = totalPassRate > 0 ? [
                                { name: 'Passed', value: dashboardData.passedSubmissions || 0 },
                                { name: 'Failed', value: dashboardData.failedSubmissions || 0 }
                            ] : [
                                { name: 'No Data Available', value: 1 }
                            ];

                            return (
                                <div className={styles.container}>
                                    {/* Header Greeting */}
                                    <header style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                        <h1 className={styles.sectionTitle} style={{ fontSize: '1.8rem', margin: 0 }}>Welcome back, {instructorName} 👋</h1>
                                        <p className={styles.sectionSubtitle} style={{ margin: 0 }}>Here is your teaching workspace at a glance.</p>
                                    </header>

                                    {/* Task 1: Top KPI Grid (E-Learning Metrics) */}
                                    <section className={styles.kpiRow}>
                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum}>
                                                    {(dashboardData.studentCount || 0).toLocaleString()}
                                                </span>
                                                <h4 className={styles.kpiLabel}>Total Students</h4>
                                                <p className={styles.kpiDesc}>Total unique students taught across your courses</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="graduation-cap" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>

                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4, delay: 0.1 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum}>{dashboardData.newEnrollments}</span>
                                                <h4 className={styles.kpiLabel}>New Enrollments</h4>
                                                <p className={styles.kpiDesc}>Admissions during the last 30 days</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="user-plus" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>

                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4, delay: 0.2 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum}>{dashboardData.avgScore}%</span>
                                                <h4 className={styles.kpiLabel}>Avg Assessment Score</h4>
                                                <p className={styles.kpiDesc}>Mean score across graded attempts</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="award" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>

                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4, delay: 0.3 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum}>{dashboardData.courseCount}</span>
                                                <h4 className={styles.kpiLabel}>Assigned Courses</h4>
                                                <p className={styles.kpiDesc}>Total course programs under your workspace</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="book-open" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>
                                    </section>

                                    {/* Task 2: The Main Trend Chart (Enrollments & Revenue) */}
                                    {window.Recharts && (dashboardData.monthlyTrends || []).length > 0 && (
                                        <section className={styles.chartCard}>
                                            <div className={styles.chartHeader}>
                                                <div>
                                                    <h3 className={styles.sectionTitle} style={{ fontSize: '1.25rem' }}>Enrollment & Revenue Trends</h3>
                                                    <p className={styles.sectionSubtitle} style={{ margin: 0 }}>Monthly aggregation over the last 6 months</p>
                                                </div>
                                                <div className={styles.chartLegend}>
                                                    <div className={styles.legendItem}>
                                                        <span className={styles.legendDotPrimary}></span>
                                                        <span>Enrollments</span>
                                                    </div>
                                                    <div className={styles.legendItem}>
                                                        <span className={styles.legendDotAccent}></span>
                                                        <span>Revenue</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style={{ width: '100%', height: '320px', padding: '0 10px' }}>
                                                <ResponsiveContainer width="100%" height="100%">
                                                    <AreaChart data={dashboardData.monthlyTrends} margin={{ top: 10, right: 30, left: 10, bottom: 0 }}>
                                                        <defs>
                                                            <linearGradient id="colorEnrollments" x1="0" y1="0" x2="0" y2="1">
                                                                <stop offset="5%" stopColor="#6366f1" stopOpacity={0.15}/>
                                                                <stop offset="95%" stopColor="#6366f1" stopOpacity={0}/>
                                                            </linearGradient>
                                                            <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                                                <stop offset="5%" stopColor="#f59e0b" stopOpacity={0.15}/>
                                                                <stop offset="95%" stopColor="#f59e0b" stopOpacity={0}/>
                                                            </linearGradient>
                                                        </defs>
                                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" opacity={0.5} />
                                                        <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                                        <YAxis yAxisId="left" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                                        <YAxis yAxisId="right" orientation="right" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} tickFormatter={(v) => '₦' + v.toLocaleString()} />
                                                        <Tooltip 
                                                            contentStyle={{ backgroundColor: '#ffffff', borderRadius: '10px', border: '1px solid #f1f5f9', boxShadow: '0 4px 12px rgba(15, 23, 42, 0.08)' }}
                                                            formatter={(value, name) => {
                                                                if (name === "Revenue") return ['₦' + value.toLocaleString(), 'Revenue'];
                                                                return [value, 'Enrollments'];
                                                            }}
                                                        />
                                                        <Area yAxisId="left" type="monotone" dataKey="enrollments" name="Enrollments" stroke="#6366f1" strokeWidth={2.5} fillOpacity={1} fill="url(#colorEnrollments)" />
                                                        <Area yAxisId="right" type="monotone" dataKey="revenue" name="Revenue" stroke="#f59e0b" strokeWidth={2.5} fillOpacity={1} fill="url(#colorRevenue)" />
                                                    </AreaChart>
                                                </ResponsiveContainer>
                                            </div>
                                        </section>
                                    )}

                                    {/* Task 3: Bottom Insights (Donut Charts) */}
                                    {window.Recharts && (
                                        <section className={styles.distributionGrid}>
                                            {/* Donut 1: Course Completion */}
                                            <div className={styles.donutCard}>
                                                <div className={styles.chartHeader} style={{ marginBottom: '12px' }}>
                                                    <div>
                                                        <h3 className={styles.sectionTitle} style={{ fontSize: '1.15rem', margin: 0 }}>Course Completion Ratios</h3>
                                                        <p className={styles.sectionSubtitle} style={{ margin: '4px 0 0 0' }}>Student state mapping across active courses</p>
                                                    </div>
                                                </div>
                                                <div className={styles.donutChartContainer}>
                                                    <ResponsiveContainer width="100%" height="100%">
                                                        <PieChart>
                                                            <Pie
                                                                data={completionData}
                                                                cx="50%"
                                                                cy="50%"
                                                                innerRadius={60}
                                                                outerRadius={80}
                                                                paddingAngle={totalCompletion > 0 ? 4 : 0}
                                                                dataKey="value"
                                                            >
                                                                {completionData.map((entry, index) => {
                                                                    const fill = totalCompletion > 0 
                                                                        ? COMPLETION_COLORS[index % COMPLETION_COLORS.length] 
                                                                        : '#cbd5e1';
                                                                    return <Cell key={`cell-${index}`} fill={fill} />;
                                                                })}
                                                            </Pie>
                                                            {totalCompletion > 0 && (
                                                                <Tooltip 
                                                                    contentStyle={{ backgroundColor: '#ffffff', borderRadius: '10px', border: '1px solid #f1f5f9', boxShadow: '0 4px 12px rgba(15, 23, 42, 0.08)' }}
                                                                />
                                                            )}
                                                        </PieChart>
                                                    </ResponsiveContainer>
                                                </div>
                                                <div className={styles.donutLegend}>
                                                    {[
                                                        { name: 'Completed', value: dashboardData.completedCount || 0 },
                                                        { name: 'In Progress', value: dashboardData.inProgressCount || 0 },
                                                        { name: 'Dropped', value: dashboardData.droppedCount || 0 }
                                                    ].map((entry, idx) => (
                                                        <div key={idx} className={styles.legendItem}>
                                                            <span className="ins_mod_123_legend_dot" style={{ backgroundColor: COMPLETION_COLORS[idx % COMPLETION_COLORS.length], width: '8px', height: '8px', borderRadius: '50%', display: 'inline-block' }}></span>
                                                            <span>{entry.name}: {entry.value}</span>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>

                                            {/* Donut 2: Assessment Pass Rate */}
                                            <div className={styles.donutCard}>
                                                <div className={styles.chartHeader} style={{ marginBottom: '12px' }}>
                                                    <div>
                                                        <h3 className={styles.sectionTitle} style={{ fontSize: '1.15rem', margin: 0 }}>Assessment Pass Rate</h3>
                                                        <p className={styles.sectionSubtitle} style={{ margin: '4px 0 0 0' }}>Ratio of passed vs failed submissions</p>
                                                    </div>
                                                </div>
                                                <div className={styles.donutChartContainer}>
                                                    <ResponsiveContainer width="100%" height="100%">
                                                        <PieChart>
                                                            <Pie
                                                                data={passRateData}
                                                                cx="50%"
                                                                cy="50%"
                                                                innerRadius={60}
                                                                outerRadius={80}
                                                                paddingAngle={totalPassRate > 0 ? 4 : 0}
                                                                dataKey="value"
                                                            >
                                                                {passRateData.map((entry, index) => {
                                                                    const fill = totalPassRate > 0 
                                                                        ? PASS_COLORS[index % PASS_COLORS.length] 
                                                                        : '#cbd5e1';
                                                                    return <Cell key={`cell-${index}`} fill={fill} />;
                                                                })}
                                                            </Pie>
                                                            {totalPassRate > 0 && (
                                                                <Tooltip 
                                                                    contentStyle={{ backgroundColor: '#ffffff', borderRadius: '10px', border: '1px solid #f1f5f9', boxShadow: '0 4px 12px rgba(15, 23, 42, 0.08)' }}
                                                                />
                                                            )}
                                                        </PieChart>
                                                    </ResponsiveContainer>
                                                </div>
                                                <div className={styles.donutLegend}>
                                                    {[
                                                        { name: 'Passed', value: dashboardData.passedSubmissions || 0 },
                                                        { name: 'Failed', value: dashboardData.failedSubmissions || 0 }
                                                    ].map((entry, idx) => (
                                                        <div key={idx} className={styles.legendItem}>
                                                            <span className="ins_mod_123_legend_dot" style={{ backgroundColor: PASS_COLORS[idx % PASS_COLORS.length], width: '8px', height: '8px', borderRadius: '50%', display: 'inline-block' }}></span>
                                                            <span>{entry.name}: {entry.value}</span>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        </section>
                                    )}

                                    {/* Assigned Courses (STRICT LIST VIEW) — real course data */}
                                    <section className={styles.coursesSection}>
                                        <div className={styles.coursesHead}>
                                            <div>
                                                <h3 className={styles.sectionTitle} style={{ fontSize: '1.25rem', margin: 0 }}>Your Courses</h3>
                                                <p className={styles.sectionSubtitle} style={{ margin: 0 }}>Manage course content, materials, and assessments.</p>
                                            </div>
                                            <a href={`${window.__CONTEXT_PATH__}/instructor/courses`} className={styles.viewAllLink}>
                                                View All <i data-lucide="arrow-right" style={{ width: '14px', height: '14px' }}></i>
                                            </a>
                                        </div>

                                        {courses.length === 0 ? (
                                            <div className={styles.emptyState}>
                                                <div className={styles.emptyIcon}>
                                                    <i data-lucide="layer-group"></i>
                                                </div>
                                                <h3>No Courses Assigned</h3>
                                                <p>You have not been assigned any courses yet. Contact platform administrators to set up learning workspace permissions.</p>
                                            </div>
                                        ) : (
                                            <div className={styles.courseList}>
                                                {courses.map((course) => {
                                                    const statusClass = course.status ? course.status.toLowerCase() : 'draft';
                                                    return (
                                                        <a 
                                                            key={course.courseId} 
                                                            href={`${window.__CONTEXT_PATH__}/instructor/courses?action=workspace&courseId=${course.courseId}`}
                                                            className={styles.courseRow}
                                                        >
                                                            <div className={styles.courseLeft}>
                                                                <i data-lucide="book-open" style={{ width: '20px', height: '20px' }}></i>
                                                            </div>
                                                            <div className={styles.courseMiddle}>
                                                                <h4 className={styles.courseTitle}>{course.courseName}</h4>
                                                                <div style={{ display: 'flex', gap: '8px', alignItems: 'center', flexWrap: 'wrap' }}>
                                                                    <span className={`${styles.courseStatusPill} ${styles[statusClass]}`}>
                                                                        {course.status}
                                                                    </span>
                                                                    <span style={{ fontSize: '0.78rem', color: '#64748b', fontWeight: 500 }}>
                                                                        {course.enrolledCount} student{course.enrolledCount !== 1 ? 's' : ''} · {course.materialCount} material{course.materialCount !== 1 ? 's' : ''} · {course.assessmentCount} assessment{course.assessmentCount !== 1 ? 's' : ''}
                                                                    </span>
                                                                    {course.pendingGradingCount > 0 && (
                                                                        <span style={{ fontSize: '0.7rem', fontWeight: 700, background: 'rgba(245, 158, 11, 0.1)', color: '#f59e0b', padding: '2px 8px', borderRadius: '999px' }}>
                                                                            {course.pendingGradingCount} to grade
                                                                        </span>
                                                                    )}
                                                                </div>
                                                            </div>
                                                            <div className={styles.courseRight}>
                                                                <button type="button" className={styles.btnManage}>
                                                                    Manage Course <i data-lucide="arrow-right" style={{ width: '14px', height: '14px' }}></i>
                                                                </button>
                                                            </div>
                                                        </a>
                                                    );
                                                })}
                                            </div>
                                        )}
                                    </section>
                                </div>
                            );
                        }

                        const container = document.getElementById('instructor-react-root');
                        const root = ReactDOM.createRoot(container);
                        root.render(<InstructorDashboard />);
                    </script> </main>
                </body>

                </html>
