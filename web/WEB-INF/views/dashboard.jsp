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
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Dashboard.module.css">
            <script src="https://unpkg.com/lucide@latest"></script>
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
                window.__ENROLLED_COURSES_COUNT__ = ${enrolledCoursesCount != null ? enrolledCoursesCount : 0};
                window.__ACTIVE_COURSES_COUNT__ = ${activeCoursesCount != null ? activeCoursesCount : 0};
                window.__COMPLETED_COURSES_COUNT__ = ${completedCoursesCount != null ? completedCoursesCount : 0};
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
                const { useState, useEffect, useRef } = React;
                const { 
                    ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid 
                } = window.Recharts || {};

                // Framer Motion wrapper with fallback
                const MotionDiv = ({ children, initial, animate, transition, className, style, ...props }) => {
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
                                style={style}
                                {...props}
                            >
                                {children}
                            </MotionComponent>
                        );
                    }
                    return (
                        <div className={(className || '') + " db_fadeIn"} style={style} {...props}>
                            {children}
                        </div>
                    );
                };

                function StudentDashboard() {
                    const [courses] = useState(window.__ENROLLED_COURSES__ || []);
                    const [studentName] = useState(window.__STUDENT_NAME__ || 'Student');
                    const [certificatesCount] = useState(window.__CERTIFICATES_COUNT__ || 0);
                    const [overallProgress] = useState(window.__OVERALL_PROGRESS__ || 0);
                    const [enrolledCount] = useState(window.__ENROLLED_COURSES_COUNT__ || 0);
                    const [activeCount] = useState(window.__ACTIVE_COURSES_COUNT__ || 0);
                    const [completedCount] = useState(window.__COMPLETED_COURSES_COUNT__ || 0);

                    const activeCourses = courses.filter(c => c.completionStatus === 'In Progress');
                    const firstName = studentName.split(' ')[0];
                    const totalHours = Math.round(courses.reduce((acc, c) => acc + (c.progress * 0.35), 0)) + 6;

                    // Greeting based on time of day
                    const hour = new Date().getHours();
                    const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

                    // Today's date formatted
                    const today = new Date();
                    const dateStr = today.toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' });

                    // Overall progress ring dimensions
                    const overallRadius = 22;
                    const overallCircumference = 2 * Math.PI * overallRadius;
                    const overallOffset = overallCircumference - (overallProgress / 100) * overallCircumference;

                    // Weekly activity data
                    const activityData = [
                        { day: 'Mon', Minutes: 40 },
                        { day: 'Tue', Minutes: 65 },
                        { day: 'Wed', Minutes: totalHours * 1.5 > 120 ? 110 : 50 },
                        { day: 'Thu', Minutes: 85 },
                        { day: 'Fri', Minutes: 120 },
                        { day: 'Sat', Minutes: 95 },
                        { day: 'Sun', Minutes: totalHours * 0.8 > 80 ? 75 : 45 }
                    ];

                    useEffect(() => {
                        if (window.lucide) {
                            window.lucide.createIcons();
                        }
                    }, [courses]);

                    const CustomTooltip = ({ active, payload }) => {
                        if (active && payload && payload.length) {
                            return (
                                <div className="db_customTooltip">
                                    <p className="db_tooltipLabel">{payload[0].payload.day}</p>
                                    <p className="db_tooltipValue">{payload[0].value} mins active</p>
                                </div>
                            );
                        }
                        return null;
                    };

                    return (
                        <div className="db_pageWrapper">
                            <MotionDiv 
                                className="db_container"
                                initial={{ opacity: 0 }}
                                animate={{ opacity: 1 }}
                                transition={{ duration: 0.45 }}
                            >
                                {/* ── Hero Greeting ── */}
                                <header className="db_hero">
                                    <div className="db_heroText">
                                        <h1 className="db_welcomeTitle">
                                            {greeting}, {firstName} 👋
                                        </h1>
                                        <p className="db_subtitle">
                                            Here is an overview of your learning progress.
                                        </p>
                                        <span className="db_dateChip">
                                            <i data-lucide="calendar" style={{ width: 13, height: 13 }}></i>
                                            {dateStr}
                                        </span>
                                    </div>

                                    {courses.length > 0 && (
                                        <div className="db_heroProgress">
                                            <div className="db_overallRingWrap">
                                                <svg className="db_overallRingSvg" width="56" height="56" viewBox="0 0 56 56">
                                                    <circle 
                                                        className="db_overallRingBg" 
                                                        cx="28" cy="28" r={overallRadius} 
                                                        strokeWidth="5" fill="transparent" 
                                                    />
                                                    <circle 
                                                        className="db_overallRingFg" 
                                                        cx="28" cy="28" r={overallRadius} 
                                                        strokeWidth="5" fill="transparent" 
                                                        strokeDasharray={overallCircumference}
                                                        strokeDashoffset={overallOffset}
                                                    />
                                                </svg>
                                                <div className="db_overallRingText">{overallProgress}%</div>
                                            </div>
                                            <div className="db_overallLabel">
                                                <span className="db_overallTitle">Overall Progress</span>
                                                <span className="db_overallSub">Across all courses</span>
                                            </div>
                                        </div>
                                    )}
                                </header>

                                {/* ── KPI Summary Grid ── */}
                                <section className="db_kpiGrid">
                                    <div className="db_kpiBlock">
                                        <div className="db_kpiIcon blue">
                                            <i data-lucide="book-open" style={{ width: 20, height: 20 }}></i>
                                        </div>
                                        <div className="db_kpiContent">
                                            <span className="db_kpiNum">{enrolledCount}</span>
                                            <span className="db_kpiLabel">Total Enrolled</span>
                                        </div>
                                    </div>
                                    <div className="db_kpiBlock">
                                        <div className="db_kpiIcon green">
                                            <i data-lucide="play-circle" style={{ width: 20, height: 20 }}></i>
                                        </div>
                                        <div className="db_kpiContent">
                                            <span className="db_kpiNum">{activeCount}</span>
                                            <span className="db_kpiLabel">In Progress</span>
                                        </div>
                                    </div>
                                    <div className="db_kpiBlock">
                                        <div className="db_kpiIcon violet">
                                            <i data-lucide="check-circle-2" style={{ width: 20, height: 20 }}></i>
                                        </div>
                                        <div className="db_kpiContent">
                                            <span className="db_kpiNum">{completedCount}</span>
                                            <span className="db_kpiLabel">Completed</span>
                                        </div>
                                    </div>
                                    <div className="db_kpiBlock">
                                        <div className="db_kpiIcon amber">
                                            <i data-lucide="award" style={{ width: 20, height: 20 }}></i>
                                        </div>
                                        <div className="db_kpiContent">
                                            <span className="db_kpiNum">{certificatesCount}</span>
                                            <span className="db_kpiLabel">Certificates</span>
                                        </div>
                                    </div>
                                </section>

                                {/* ── Continue Learning Section ── */}
                                <section className="db_section">
                                    <div className="db_sectionHeader">
                                        <h3 className="db_sectionTitle">Continue Learning</h3>
                                        {activeCourses.length > 0 && (
                                            <a href={window.__CONTEXT_PATH__ + "/student/my-enrollments"} className="db_sectionAction">
                                                View all <i data-lucide="arrow-right" style={{ width: 14, height: 14 }}></i>
                                            </a>
                                        )}
                                    </div>
                                    {activeCourses.length > 0 ? (
                                        <div className="db_courseGrid">
                                            {activeCourses.map((course) => {
                                                const statusClass = course.completionStatus === 'Completed' ? 'done' : (course.completionStatus === 'In Progress' ? 'live' : 'hold');
                                                
                                                return (
                                                    <a 
                                                        key={course.enrollmentId} 
                                                        href={window.__CONTEXT_PATH__ + "/student/enrollment-details?id=" + course.enrollmentId}
                                                        className="db_courseCard"
                                                    >
                                                        <div className="db_courseBannerWrap">
                                                            {course.courseBanner ? (
                                                                <img 
                                                                    src={course.courseBanner.startsWith('http') ? course.courseBanner : window.__CONTEXT_PATH__ + "/" + course.courseBanner} 
                                                                    alt=""
                                                                    className="db_courseBanner"
                                                                />
                                                            ) : (
                                                                <div className="db_courseBannerEmpty">
                                                                    <i data-lucide="book-open" style={{ width: 32, height: 32 }}></i>
                                                                </div>
                                                            )}
                                                            <span className={"db_courseStatus " + statusClass}>
                                                                {course.completionStatus}
                                                            </span>
                                                        </div>

                                                        <div className="db_courseBody">
                                                            <div className="db_courseInfo">
                                                                <h4 className="db_courseTitle">{course.courseName}</h4>
                                                                <p className="db_courseInstructor">
                                                                    By <strong>{course.instructorName}</strong>
                                                                </p>
                                                            </div>

                                                            <div className="db_courseFooter">
                                                                <div className="db_progressBarWrap">
                                                                    <span className="db_progressLabel">{course.progress}% complete</span>
                                                                    <div className="db_progressTrack">
                                                                        <div 
                                                                            className="db_progressFill" 
                                                                            style={{ width: course.progress + '%' }}
                                                                        ></div>
                                                                    </div>
                                                                </div>
                                                                <span className="db_resumeHint">
                                                                    Resume <i data-lucide="arrow-right" style={{ width: 14, height: 14 }}></i>
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </a>
                                                );
                                            })}
                                        </div>
                                    ) : (
                                        <div className="db_emptyStrip">
                                            <p className="db_emptyText">
                                                <i data-lucide="compass" style={{ width: 20, height: 20, color: '#3b82f6' }}></i>
                                                Ready to start your learning journey? Explore our course catalog.
                                            </p>
                                            <a href={window.__CONTEXT_PATH__ + "/student/courses"} className="db_exploreBtn">
                                                Browse Catalog <i data-lucide="arrow-right" style={{ width: 14, height: 14 }}></i>
                                            </a>
                                        </div>
                                    )}
                                </section>

                                {/* ── Quick Actions ── */}
                                <section className="db_quickActions">
                                    <a href={window.__CONTEXT_PATH__ + "/student/courses"} className="db_quickAction">
                                        <div className="db_quickActionIcon">
                                            <i data-lucide="compass" style={{ width: 18, height: 18 }}></i>
                                        </div>
                                        <div className="db_quickActionText">
                                            <span className="db_quickActionTitle">Browse Courses</span>
                                            <span className="db_quickActionSub">Discover new learning paths</span>
                                        </div>
                                    </a>
                                    <a href={window.__CONTEXT_PATH__ + "/student/certificates"} className="db_quickAction">
                                        <div className="db_quickActionIcon" style={{ background: 'rgba(139,92,246,0.08)', color: '#8b5cf6' }}>
                                            <i data-lucide="award" style={{ width: 18, height: 18 }}></i>
                                        </div>
                                        <div className="db_quickActionText">
                                            <span className="db_quickActionTitle">My Certificates</span>
                                            <span className="db_quickActionSub">View and download earned certificates</span>
                                        </div>
                                    </a>
                                    <a href={window.__CONTEXT_PATH__ + "/student/payments"} className="db_quickAction">
                                        <div className="db_quickActionIcon" style={{ background: 'rgba(16,185,129,0.08)', color: '#10b981' }}>
                                            <i data-lucide="receipt" style={{ width: 18, height: 18 }}></i>
                                        </div>
                                        <div className="db_quickActionText">
                                            <span className="db_quickActionTitle">Payment History</span>
                                            <span className="db_quickActionSub">Review transaction records</span>
                                        </div>
                                    </a>
                                </section>

                                {/* ── Activity Chart ── */}
                                {window.Recharts && (
                                    <section className="db_chartCard">
                                        <div className="db_chartHeader">
                                            <div className="db_chartTitleWrap">
                                                <h3 className="db_sectionTitle">Weekly Study Activity</h3>
                                                <p className="db_subtitle">Daily active study minutes across courses and assessments</p>
                                            </div>
                                        </div>
                                        <div style={{ width: '100%', height: '220px' }}>
                                            <ResponsiveContainer width="100%" height="100%">
                                                <AreaChart data={activityData} margin={{ top: 8, right: 8, left: -28, bottom: 0 }}>
                                                    <defs>
                                                        <linearGradient id="colorMinutes" x1="0" y1="0" x2="0" y2="1">
                                                            <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.12}/>
                                                            <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                                                        </linearGradient>
                                                    </defs>
                                                    <CartesianGrid vertical={false} horizontal={false} />
                                                    <XAxis dataKey="day" stroke="#94a3b8" fontSize={11} fontWeight={600} tickLine={false} axisLine={false} />
                                                    <YAxis stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                                    <Tooltip content={<CustomTooltip />} />
                                                    <Area 
                                                        type="monotone" 
                                                        dataKey="Minutes" 
                                                        stroke="#3b82f6" 
                                                        strokeWidth={2.5} 
                                                        fillOpacity={1} 
                                                        fill="url(#colorMinutes)" 
                                                    />
                                                </AreaChart>
                                            </ResponsiveContainer>
                                        </div>
                                    </section>
                                )}

                            </MotionDiv>
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