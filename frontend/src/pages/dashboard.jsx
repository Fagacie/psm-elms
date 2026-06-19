const { useState, useEffect, useMemo, useCallback, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;

                console.log("BABEL SCRIPT STARTED!!!");
                
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

                function StudentDashboard() { console.log("STUDENT DASHBOARD RENDERED!");
                    const [courses] = useState(window.__ENROLLED_COURSES__ || []);
                    const [studentName] = useState(window.__STUDENT_NAME__ || 'Student');
                    const [certificatesCount] = useState(window.__CERTIFICATES_COUNT__ || 0);
                    const [overallProgress] = useState(window.__OVERALL_PROGRESS__ || 0);
                    const [enrolledCount] = useState(window.__ENROLLED_COURSES_COUNT__ || 0);
                    const [activeCount] = useState(window.__ACTIVE_COURSES_COUNT__ || 0);
                    const [completedCount] = useState(window.__COMPLETED_COURSES_COUNT__ || 0);

                    const [activityData] = useState(() => {
                        if (window.__ACTIVITY_DATA__ && window.__ACTIVITY_DATA__.length > 0) {
                            return window.__ACTIVITY_DATA__;
                        }
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return days.map(d => ({ day: d, Minutes: 0 }));
                    });

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

                    useEffect(() => {
                        if (window.lucide) {
                            window.lucide.createIcons();
                        }
                    }, [courses, activityData]);

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
                                <MotionDiv 
                                    className="db_hero"
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ duration: 0.5, delay: 0.1 }}
                                >
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
                                </MotionDiv>

                                {/* ── KPI Summary Grid ── */}
                                <MotionDiv 
                                    className="db_kpiGrid"
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ duration: 0.5, delay: 0.2 }}
                                >
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
                                </MotionDiv>

                                {/* ── Continue Learning Section ── */}
                                <MotionDiv 
                                    className="db_section"
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ duration: 0.5, delay: 0.3 }}
                                >
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
                                </MotionDiv>

                                {/* ── Quick Actions ── */}
                                <MotionDiv 
                                    className="db_quickActions"
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ duration: 0.5, delay: 0.4 }}
                                >
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
                                </MotionDiv>

                                {/* ── Activity Chart ── */}
                                {window.Recharts && (
                                    <MotionDiv 
                                        className="db_chartCard"
                                        initial={{ opacity: 0, y: 20 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        transition={{ duration: 0.5, delay: 0.5 }}
                                    >
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
                                                        <linearGradient id="colorMinutes" x1="0" y1="0" x2="1" y2="0">
                                                            <stop offset="0%" stopColor="#06b6d4" stopOpacity={0.25}/>
                                                            <stop offset="100%" stopColor="#4f46e5" stopOpacity={0.25}/>
                                                        </linearGradient>
                                                        <linearGradient id="colorMinutesLine" x1="0" y1="0" x2="1" y2="0">
                                                            <stop offset="0%" stopColor="#06b6d4" stopOpacity={1}/>
                                                            <stop offset="100%" stopColor="#4f46e5" stopOpacity={1}/>
                                                        </linearGradient>
                                                    </defs>
                                                    <CartesianGrid vertical={false} horizontal={false} />
                                                    <XAxis dataKey="day" stroke="#94a3b8" fontSize={11} fontWeight={600} tickLine={false} axisLine={false} />
                                                    <YAxis stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                                    <Tooltip content={<CustomTooltip />} />
                                                    <Area 
                                                        type="monotone" 
                                                        dataKey="Minutes" 
                                                        stroke="url(#colorMinutesLine)" 
                                                        strokeWidth={3} 
                                                        fillOpacity={1} 
                                                        fill="url(#colorMinutes)" 
                                                    />
                                                </AreaChart>
                                            </ResponsiveContainer>
                                        </div>
                                        {activityData.every(d => d.Minutes === 0) && (
                                            <div className="db_chartEmptyState">
                                                <i data-lucide="info" style={{ width: 14, height: 14, color: '#3b82f6', marginRight: 6 }}></i>
                                                <span>No study activity recorded this week. Start viewing materials or taking assessments to track your progress!</span>
                                            </div>
                                        )}
                                    </MotionDiv>
                                )}

                            </MotionDiv>
                        </div>
                    );
                }

                const container = document.getElementById('student-react-root');
                const root = ReactDOM.createRoot(container);
                root.render(<StudentDashboard />);
            