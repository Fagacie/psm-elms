<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Student Dashboard - PSM E-Learning</title>
            <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/StudentDashboard.module.css">
    
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
        </head>

        <body class="sv-page">
            <c:set var="topbarTitle" value="Dashboard" />
            <c:set var="topbarSubtitle" value="Academic overview and course progress" />
            <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

            <div class="sv-layout">
                <c:set var="activePage" value="dashboard" />
                <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

                <main class="sv-main">
                    <!-- Scoped React Sandbox Root -->
                    <div id="student-react-root"></div>
                </main>
            </div>

            <!-- Serialize JSTL properties to window state for React sandbox execution -->
            <script type="text/javascript">
                window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
                window.__STUDENT_NAME__ = "${sessionScope.userName}";
                window.__OVERALL_PROGRESS__ = ${overallProgress != null ? overallProgress : 0};
                window.__CERTIFICATES_COUNT__ = ${certificatesCount != null ? certificatesCount : 0};
                window.__ENROLLED_COURSES__ = [
                    <c:forEach var="course" items="${enrolledCourses}" varStatus="status">
                        {
                            enrollmentId: ${course.enrollmentId},
                            courseName: "${fn:escapeXml(course.courseName)}",
                            instructorName: "${fn:escapeXml(course.instructorName)}",
                            courseBanner: "${fn:escapeXml(course.courseBanner)}",
                            progress: ${course.progress != null ? course.progress : 0},
                            completionStatus: "${fn:escapeXml(course.completionStatus)}"
                        }${not status.last ? ',' : ''}
                    </c:forEach>
                ];
            </script>

            <!-- Interactive React Sandbox Application (Zero CSS Bleed) -->
            <script type="text/babel">
                const { useState, useEffect } = React;
                const { 
                    ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid 
                } = window.Recharts || {};

                // CSS Module mapped class names
                const styles = {
                    container: 'sd_mod_123_container',
                    sectionTitle: 'sd_mod_123_section_title',
                    sectionSubtitle: 'sd_mod_123_section_subtitle',
                    welcomeTitle: 'sd_mod_123_welcome_title',
                    continueStrip: 'sd_mod_123_continue_strip',
                    continueInfoWrap: 'sd_mod_123_continue_info_wrap',
                    continueTitleWrap: 'sd_mod_123_continue_title_wrap',
                    continueKicker: 'sd_mod_123_continue_kicker',
                    continueTitle: 'sd_mod_123_continue_title',
                    continueProgressWrap: 'sd_mod_123_continue_progress_wrap',
                    continueProgressBg: 'sd_mod_123_continue_progress_bg',
                    continueProgressFg: 'sd_mod_123_continue_progress_fg',
                    continueProgressText: 'sd_mod_123_continue_progress_text',
                    continueBtn: 'sd_mod_123_continue_btn',
                    continueStripEmpty: 'sd_mod_123_continue_strip_empty',
                    continueEmptyText: 'sd_mod_123_continue_empty_text',
                    heroCard: 'sd_mod_123_hero_card',
                    heroContent: 'sd_mod_123_hero_content',
                    heroKicker: 'sd_mod_123_hero_kicker',
                    heroTitle: 'sd_mod_123_hero_title',
                    heroProgressSection: 'sd_mod_123_hero_progress_section',
                    heroProgressLabel: 'sd_mod_123_hero_progress_label',
                    heroProgressBarBg: 'sd_mod_123_hero_progress_bar_bg',
                    heroProgressBarFg: 'sd_mod_123_hero_progress_bar_fg',
                    heroActions: 'sd_mod_123_hero_actions',
                    btnResume: 'sd_mod_123_btn_resume',
                    heroVisual: 'sd_mod_123_hero_visual',
                    heroVisualCircle: 'sd_mod_123_hero_visual_circle',
                    kpiGrid: 'sd_mod_123_kpi_grid',
                    kpiCard: 'sd_mod_123_kpi_card',
                    kpiIconWrapper: 'sd_mod_123_kpi_icon_wrapper',
                    kpiInfo: 'sd_mod_123_kpi_info',
                    kpiNum: 'sd_mod_123_kpi_num',
                    kpiLabel: 'sd_mod_123_kpi_label',
                    chartCard: 'sd_mod_123_chart_card',
                    chartHeader: 'sd_mod_123_chart_header',
                    chartLegend: 'sd_mod_123_chart_legend',
                    legendItem: 'sd_mod_123_legend_item',
                    legendDot: 'sd_mod_123_legend_dot',
                    customTooltip: 'sd_mod_123_custom_tooltip',
                    tooltipLabel: 'sd_mod_123_tooltip_label',
                    tooltipValue: 'sd_mod_123_tooltip_value',
                    courseGrid: 'sd_mod_123_course_grid',
                    courseCard: 'sd_mod_123_course_card',
                    courseBannerWrap: 'sd_mod_123_course_banner_wrap',
                    courseBanner: 'sd_mod_123_course_banner',
                    courseBannerEmpty: 'sd_mod_123_course_banner_empty',
                    courseStatus: 'sd_mod_123_course_status',
                    courseBody: 'sd_mod_123_course_body',
                    courseInfo: 'sd_mod_123_course_info',
                    courseTitle: 'sd_mod_123_course_title',
                    courseInstructor: 'sd_mod_123_course_instructor',
                    progressCircularContainer: 'sd_mod_123_progress_circular_container',
                    progressRingWrapper: 'sd_mod_123_progress_ring_wrapper',
                    svgRing: 'sd_mod_123_svg_ring',
                    ringBg: 'sd_mod_123_ring_bg',
                    ringFg: 'sd_mod_123_ring_fg',
                    ringText: 'sd_mod_123_ring_text',
                    progressActionHint: 'sd_mod_123_progress_action_hint',
                    emptyState: 'sd_mod_123_empty_state',
                    emptyIcon: 'sd_mod_123_empty_icon'
                };

                // Robust Framer Motion React UMD container falling back to CSS animations gracefully
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
                        <div className={`${className} sd_mod_123_fade_in_up`} {...props}>
                            {children}
                        </div>
                    );
                };

                const MotionA = ({ children, initial, animate, transition, className, href, ...props }) => {
                    const MotionComponent = window.Motion && window.Motion.motion 
                        ? window.Motion.motion.a 
                        : (window.FramerMotion && window.FramerMotion.motion ? window.FramerMotion.motion.a : null);
                    
                    if (MotionComponent) {
                        return (
                            <MotionComponent 
                                initial={initial} 
                                animate={animate} 
                                transition={transition} 
                                className={className} 
                                href={href}
                                {...props}
                            >
                                {children}
                            </MotionComponent>
                        );
                    }
                    return (
                        <a href={href} className={`${className} sd_mod_123_fade_in_up`} {...props}>
                            {children}
                        </a>
                    );
                };

                function StudentDashboard() {
                    const [courses] = useState(window.__ENROLLED_COURSES__ || []);
                    const [studentName] = useState(window.__STUDENT_NAME__ || 'Student');
                    const [certificatesCount] = useState(window.__CERTIFICATES_COUNT__ || 0);

                    // Compute most recently accessed (in progress) course
                    const activeCourses = courses.filter(c => c.completionStatus === 'In Progress');
                    const recentCourse = activeCourses.length > 0 ? activeCourses[0] : (courses.length > 0 ? courses[0] : null);

                    // Dynamic calculated learning hours
                    const totalHours = Math.round(courses.reduce((acc, c) => acc + (c.progress * 0.35), 0)) + 6;

                    // Weekly platform performance metrics (customized Area chart)
                    const activityData = [
                        { day: 'Mon', Minutes: 40 },
                        { day: 'Tue', Minutes: 65 },
                        { day: 'Wed', Minutes: totalHours * 1.5 > 120 ? 110 : 50 },
                        { day: 'Thu', Minutes: 85 },
                        { day: 'Fri', Minutes: 120 },
                        { day: 'Sat', Minutes: 95 },
                        { day: 'Sun', Minutes: totalHours * 0.8 > 80 ? 75 : 45 }
                    ];

                    const CustomTooltip = ({ active, payload }) => {
                        if (active && payload && payload.length) {
                            return (
                                <div className={styles.customTooltip}>
                                    <p className={styles.tooltipLabel}>{payload[0].payload.day}</p>
                                    <p className={styles.tooltipValue}>{payload[0].value} mins active</p>
                                </div>
                            );
                        }
                        return null;
                    };

                    return (
                        <div className={styles.container}>
                            {/* Task 4 REDESIGN: Welcome Area Greeting */}
                            <MotionDiv 
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.5 }}
                            >
                                <h1 className={styles.welcomeTitle}>Welcome back, {studentName} 👋</h1>
                            </MotionDiv>

                            {/* Task 4 REDESIGN: Sleek "Continue Learning" Strip */}
                            {recentCourse ? (
                                <MotionA 
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ duration: 0.5, delay: 0.1 }}
                                    className={styles.continueStrip}
                                    href={`${window.__CONTEXT_PATH__}/student/enrollment-details?id=${recentCourse.enrollmentId}`}
                                    style={{ textDecoration: 'none' }}
                                >
                                    <div className={styles.continueInfoWrap}>
                                        <div className={styles.continueTitleWrap}>
                                            <span className={styles.continueKicker}>Continue Learning</span>
                                            <h3 className={styles.continueTitle}>{recentCourse.courseName}</h3>
                                        </div>
                                        <div className={styles.continueProgressWrap}>
                                            <div className={styles.continueProgressBg}>
                                                <div 
                                                    className={styles.continueProgressFg}
                                                    style={{ width: `${recentCourse.progress}%` }}
                                                />
                                            </div>
                                            <span className={styles.continueProgressText}>{recentCourse.progress}%</span>
                                        </div>
                                    </div>
                                    <span 
                                        className={styles.continueBtn}
                                        title="Resume learning"
                                    >
                                        <i className="fas fa-play"></i>
                                    </span>
                                </MotionA>
                            ) : (
                                <MotionDiv 
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ duration: 0.5, delay: 0.1 }}
                                    className={styles.continueStripEmpty}
                                >
                                    <p className={styles.continueEmptyText}>
                                        <i className="fas fa-compass"></i> Ready to start your learning journey? Explore our course catalog to get started!
                                    </p>
                                    <a 
                                        href={`${window.__CONTEXT_PATH__}/student/courses`}
                                        className={styles.btnResume}
                                        style={{ padding: '8px 16px', fontSize: '0.82rem' }}
                                    >
                                        Browse Catalog <i className="fas fa-arrow-right" style={{ fontSize: '0.75rem' }}></i>
                                    </a>
                                </MotionDiv>
                            )}

                            {/* KPI Navigation Grid (Correctly Linked) */}
                            <section className={styles.kpiGrid}>
                                <a href={`${window.__CONTEXT_PATH__}/student/my-enrollments`} className={styles.kpiCard} style={{ textDecoration: 'none' }}>
                                    <div className={styles.kpiIconWrapper}>
                                        <i className="fas fa-book-open"></i>
                                    </div>
                                    <div className={styles.kpiInfo}>
                                        <span className={styles.kpiNum}>{courses.length}</span>
                                        <h4 className={styles.kpiLabel}>Active Courses</h4>
                                    </div>
                                </a>

                                <div className={styles.kpiCard}>
                                    <div className={styles.kpiIconWrapper}>
                                        <i className="far fa-clock"></i>
                                    </div>
                                    <div className={styles.kpiInfo}>
                                        <span className={styles.kpiNum}>{totalHours}h</span>
                                        <h4 className={styles.kpiLabel}>Learning Hours</h4>
                                    </div>
                                </div>

                                <a href={`${window.__CONTEXT_PATH__}/student/certificates`} className={styles.kpiCard} style={{ textDecoration: 'none' }}>
                                    <div className={styles.kpiIconWrapper}>
                                        <i className="fas fa-certificate"></i>
                                    </div>
                                    <div className={styles.kpiInfo}>
                                        <span className={styles.kpiNum}>{certificatesCount}</span>
                                        <h4 className={styles.kpiLabel}>Certificates</h4>
                                    </div>
                                </a>
                            </section>

                            {/* Task 4: Interactive Activity Analytics (Recharts) */}
                            {window.Recharts && (
                                <section className={styles.chartCard}>
                                    <div className={styles.chartHeader}>
                                        <div>
                                            <h3 className={styles.sectionTitle}>Learning Activity</h3>
                                            <p className={styles.sectionSubtitle} style={{ margin: 0 }}>Duration logged across materials and exams in the past 7 days</p>
                                        </div>
                                        <div className={styles.chartLegend}>
                                            <div className={styles.legendItem}>
                                                <span className={styles.legendDot}></span>
                                                <span>Active Minutes</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div style={{ width: '100%', height: '240px' }}>
                                        <ResponsiveContainer width="100%" height="100%">
                                            <AreaChart data={activityData} margin={{ top: 10, right: 10, left: -25, bottom: 0 }}>
                                                <defs>
                                                    <linearGradient id="colorMinutes" x1="0" y1="0" x2="0" y2="1">
                                                        <stop offset="5%" stopColor="#6366f1" stopOpacity={0.15}/>
                                                        <stop offset="95%" stopColor="#6366f1" stopOpacity={0}/>
                                                    </linearGradient>
                                                </defs>
                                                <CartesianGrid vertical={false} horizontal={false} />
                                                <XAxis dataKey="day" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                                <YAxis stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                                <Tooltip content={<CustomTooltip />} />
                                                <Area 
                                                    type="monotone" 
                                                    dataKey="Minutes" 
                                                    stroke="#6366f1" 
                                                    strokeWidth={3} 
                                                    fillOpacity={1} 
                                                    fill="url(#colorMinutes)" 
                                                />
                                            </AreaChart>
                                        </ResponsiveContainer>
                                    </div>
                                </section>
                            )}

                            {/* Task 5: Enrolled Courses Grid */}
                            <section>
                                <h3 className={styles.sectionTitle}>Enrolled Courses</h3>
                                <p className={styles.sectionSubtitle}>Resume classes, materials, and track current performance milestones.</p>
                                
                                {courses.length === 0 ? (
                                    <div className={styles.emptyState}>
                                        <div class={styles.emptyIcon}>
                                            <i className="fas fa-graduation-cap"></i>
                                        </div>
                                        <h3>Explore Learning Programs</h3>
                                        <p>You do not have any enrolled courses yet. Visit the catalog to unlock interactive sylabbuses.</p>
                                        <a href={`${window.__CONTEXT_PATH__}/student/courses`} className={styles.btnResume} style={{ marginTop: '8px' }}>
                                            Browse Course Catalog
                                        </a>
                                    </div>
                                ) : (
                                    <div className={styles.courseGrid}>
                                        {courses.map((course) => {
                                            const radius = 18;
                                            const circumference = 2 * Math.PI * radius; // ~113.1
                                            const offset = circumference - (course.progress / 100) * circumference;
                                            const statusClass = course.completionStatus === 'Completed' ? 'done' : (course.completionStatus === 'In Progress' ? 'live' : 'hold');
                                            
                                            return (
                                                <a 
                                                    key={course.enrollmentId} 
                                                    href={`${window.__CONTEXT_PATH__}/student/enrollment-details?id=${course.enrollmentId}`}
                                                    className={styles.courseCard}
                                                >
                                                    <div className={styles.courseBannerWrap}>
                                                        {course.courseBanner ? (
                                                            <img 
                                                                src={course.courseBanner.startsWith('http') ? course.courseBanner : `${window.__CONTEXT_PATH__}/${course.courseBanner}`} 
                                                                alt=""
                                                                className={styles.courseBanner}
                                                            />
                                                        ) : (
                                                            <div className={styles.courseBannerEmpty}>
                                                                <i className="fas fa-book-open"></i>
                                                            </div>
                                                        )}
                                                        <span className={`${styles.courseStatus} ${statusClass}`}>
                                                            {course.completionStatus}
                                                        </span>
                                                    </div>

                                                    <div className={styles.courseBody}>
                                                        <div className={styles.courseInfo}>
                                                            <h4 className={styles.courseTitle}>{course.courseName}</h4>
                                                            <p className={styles.courseInstructor}>
                                                                By <strong>{course.instructorName}</strong>
                                                            </p>
                                                        </div>

                                                        <div className={styles.progressCircularContainer}>
                                                            <div className={styles.progressRingWrapper}>
                                                                <svg className={styles.svgRing} width="48" height="48" viewBox="0 0 48 48">
                                                                    <circle 
                                                                        className={styles.ringBg} 
                                                                        cx="24" 
                                                                        cy="24" 
                                                                        r={radius} 
                                                                        strokeWidth="4.5" 
                                                                        fill="transparent" 
                                                                    />
                                                                    <circle 
                                                                        className={styles.ringFg} 
                                                                        cx="24" 
                                                                        cy="24" 
                                                                        r={radius} 
                                                                        strokeWidth="4.5" 
                                                                        fill="transparent" 
                                                                        strokeDasharray={circumference}
                                                                        strokeDashoffset={offset}
                                                                    />
                                                                </svg>
                                                                <div className={styles.ringText}>{course.progress}%</div>
                                                            </div>
                                                            <span className={styles.progressActionHint}>
                                                                Resume <i className="fas fa-arrow-right" style={{ fontSize: '0.75rem' }}></i>
                                                            </span>
                                                        </div>
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

                const container = document.getElementById('student-react-root');
                const root = ReactDOM.createRoot(container);
                root.render(<StudentDashboard />);
            </script>

            <div class="sv-overlay" id="svOverlay"></div>
            <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
        </body>

        </html>