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
                        window.__METRICS__ = {
                            courseCount: ${not empty totalCourses ? totalCourses : 0},
                            activeCourses: ${not empty activeCourses ? activeCourses : 0},
                            studentCount: ${not empty totalStudents ? totalStudents : 0},
                            totalEnrollments: ${not empty totalEnrollments ? totalEnrollments : 0},
                            activeEnrollments: ${not empty activeEnrollments ? activeEnrollments : 0},
                            pendingEnrollments: ${not empty pendingEnrollments ? pendingEnrollments : 0},
                            pendingGrading: ${not empty pendingGradingCount ? pendingGradingCount : 0},
                            publishedMaterials: ${not empty publishedMaterialsCount ? publishedMaterialsCount : 0},
                            activeLearnersCount: ${not empty activeLearnersCount ? activeLearnersCount : 0},
                            averageProgress: ${not empty averageProgress ? averageProgress : 0},
                            missingMaterialsCourseCount: ${not empty missingMaterialsCourseCount ? missingMaterialsCourseCount : 0},
                            dueSoon: ${not empty dueSoonAssessmentCount ? dueSoonAssessmentCount : 0}
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
                    <script type="text/babel">
                        const { useState, useEffect } = React;
                        const { 
                            ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid, Cell 
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
                            emptyIcon: 'ins_mod_123_empty_icon'
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

                        function InstructorDashboard() {
                            const [metrics] = useState(window.__METRICS__ || {});
                            const [courses] = useState(window.__COURSES__ || []);
                            const [instructorName] = useState(window.__INSTRUCTOR_NAME__ || 'Instructor');

                            useEffect(() => {
                                // Initialize Lucide Icons if loaded
                                if (window.lucide) {
                                    window.lucide.createIcons();
                                }
                            }, [courses]);

                            // Build chart data from real courses — per-course enrollment and pending grading counts
                            const courseChartData = courses.map((c) => ({
                                name: c.courseName.length > 18 ? c.courseName.substring(0, 18) + '…' : c.courseName,
                                fullName: c.courseName,
                                Enrolled: c.enrolledCount || 0,
                                Pending: c.pendingGradingCount || 0
                            }));

                            const CustomTooltip = ({ active, payload }) => {
                                if (active && payload && payload.length) {
                                    return (
                                        <div className={styles.customTooltip}>
                                            <p className={styles.tooltipLabel}>{payload[0].payload.fullName}</p>
                                            {payload.map((entry, i) => (
                                                <div key={i} className={styles.tooltipRow}>
                                                    <span>{entry.name}</span>
                                                    <span className={styles.tooltipVal} style={{ color: entry.color }}>{entry.value}</span>
                                                </div>
                                            ))}
                                        </div>
                                    );
                                }
                                return null;
                            };

                            return (
                                <div className={styles.container}>
                                    {/* Header Greeting */}
                                    <header style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                        <h1 className={styles.sectionTitle} style={{ fontSize: '1.8rem', margin: 0 }}>Welcome back, {instructorName} 👋</h1>
                                        <p className={styles.sectionSubtitle} style={{ margin: 0 }}>Here is your teaching workspace at a glance.</p>
                                    </header>

                                    {/* KPI Command Row — all data from backend */}
                                    <section className={styles.kpiRow}>
                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum}>{metrics.studentCount}</span>
                                                <h4 className={styles.kpiLabel}>Total Students</h4>
                                                <p className={styles.kpiDesc}>{metrics.activeLearnersCount} currently active learners</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="users" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>

                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4, delay: 0.1 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum} style={{ color: metrics.pendingGrading > 0 ? '#f59e0b' : '#0f172a' }}>{metrics.pendingGrading}</span>
                                                <h4 className={styles.kpiLabel}>Submissions to Grade</h4>
                                                <p className={styles.kpiDesc}>Assessments awaiting your review</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="file-spreadsheet" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>

                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4, delay: 0.2 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum}>{metrics.courseCount}</span>
                                                <h4 className={styles.kpiLabel}>Total Courses</h4>
                                                <p className={styles.kpiDesc}>{metrics.activeCourses} approved &amp; live</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="book-open" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>

                                        <MotionDiv 
                                            initial={{ opacity: 0, y: 10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            transition={{ duration: 0.4, delay: 0.3 }}
                                            className={styles.kpiCard}
                                        >
                                            <div className={styles.kpiContent}>
                                                <span className={styles.kpiNum}>{metrics.publishedMaterials}</span>
                                                <h4 className={styles.kpiLabel}>Published Materials</h4>
                                                <p className={styles.kpiDesc}>{metrics.missingMaterialsCourseCount > 0 ? metrics.missingMaterialsCourseCount + ' course(s) need content' : 'All courses have content'}</p>
                                            </div>
                                            <div className={styles.kpiIcon}>
                                                <i data-lucide="file-text" style={{ width: '20px', height: '20px' }}></i>
                                            </div>
                                        </MotionDiv>
                                    </section>

                                    {/* Per-Course Analytics Chart — real data from backend */}
                                    {window.Recharts && courseChartData.length > 0 && (
                                        <section className={styles.chartCard}>
                                            <div className={styles.chartHeader}>
                                                <div>
                                                    <h3 className={styles.sectionTitle} style={{ fontSize: '1.25rem' }}>Course Analytics</h3>
                                                    <p className={styles.sectionSubtitle} style={{ margin: 0 }}>Enrollment count and pending submissions per course</p>
                                                </div>
                                                <div className={styles.chartLegend}>
                                                    <div className={styles.legendItem}>
                                                        <span className={styles.legendDotPrimary}></span>
                                                        <span>Enrolled</span>
                                                    </div>
                                                    <div className={styles.legendItem}>
                                                        <span className={styles.legendDotAccent}></span>
                                                        <span>Pending Grading</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div style={{ width: '100%', height: Math.max(260, courseChartData.length * 50) + 'px', padding: '0 10px' }}>
                                                <ResponsiveContainer width="100%" height="100%">
                                                    <BarChart data={courseChartData} layout="vertical" margin={{ top: 10, right: 30, left: 10, bottom: 0 }}>
                                                        <CartesianGrid horizontal={false} strokeDasharray="3 3" stroke="#f1f5f9" />
                                                        <XAxis type="number" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} />
                                                        <YAxis dataKey="name" type="category" stroke="#94a3b8" fontSize={11} tickLine={false} axisLine={false} width={140} />
                                                        <Tooltip content={<CustomTooltip />} />
                                                        <Bar dataKey="Enrolled" fill="#6366f1" radius={[0, 4, 4, 0]} barSize={16} />
                                                        <Bar dataKey="Pending" fill="#f59e0b" radius={[0, 4, 4, 0]} barSize={16} />
                                                    </BarChart>
                                                </ResponsiveContainer>
                                            </div>
                                        </section>
                                    )}

                                    {/* Average student progress indicator */}
                                    {metrics.totalEnrollments > 0 && (
                                        <section className={styles.chartCard} style={{ padding: '24px 32px' }}>
                                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                                                <div>
                                                    <h3 className={styles.sectionTitle} style={{ fontSize: '1.15rem', margin: 0 }}>Average Student Progress</h3>
                                                    <p className={styles.sectionSubtitle} style={{ margin: '4px 0 0 0' }}>Across {metrics.totalEnrollments} total enrollment(s)</p>
                                                </div>
                                                <span className={styles.kpiNum} style={{ fontSize: '1.75rem' }}>{metrics.averageProgress}%</span>
                                            </div>
                                            <div style={{ width: '100%', height: '8px', borderRadius: '999px', background: '#f1f5f9', overflow: 'hidden' }}>
                                                <div style={{ width: `${metrics.averageProgress}%`, height: '100%', borderRadius: '999px', background: 'linear-gradient(90deg, #6366f1, #818cf8)', transition: 'width 0.6s ease' }}></div>
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