<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
    
    <!-- Scoped isolated styles for the learning library -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/MyCourses.module.css">

    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for browser JSX compilation -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>`n    
    
    <!-- Framer Motion for premium staggered layout animations -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
</head>
<body class="sv-page">
    <c:set var="topbarTitle" value="My Learning" />
    <c:set var="topbarSubtitle" value="Track active courses and continue learning" />
    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

    <div class="sv-layout">
        <c:set var="activePage" value="my-courses" />
        <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

        <main class="sv-main">
            <!-- Scoped React Sandbox Root node -->
            <div id="student-react-root"></div>
        </main>
    </div>

    <!-- Background Notification Banners for alerts -->
    <div style="display:none;">
        <c:if test="${param.message == 'alreadypaid'}">
            <div id="alertMessagePaid" data-message="This enrollment has already been paid and is ready in your learning workspace."></div>
        </c:if>
        <c:if test="${param.error == 'notfound' || param.error == 'invalid'}">
            <div id="alertMessageError" data-message="We could not find that enrollment. Please open it again from your course list."></div>
        </c:if>
        <c:if test="${param.error == 'unauthorized' || param.error == 'permission'}">
            <div id="alertMessageAuth" data-message="You do not have permission to access that enrollment."></div>
        </c:if>
        <c:if test="${param.error == 'exception'}">
            <div id="alertMessageExcept" data-message="Something interrupted the enrollment flow. Please try again."></div>
        </c:if>
    </div>

    <%
        List<Enrollment> enrollmentsList = (List<Enrollment>) request.getAttribute("enrollments");
        
        org.json.JSONArray enrollmentsJsonArray = new org.json.JSONArray();
        if (enrollmentsList != null) {
            for (Enrollment e : enrollmentsList) {
                org.json.JSONObject obj = new org.json.JSONObject();
                
                int eid = e.getEnrollmentId() != null ? e.getEnrollmentId() : 0;
                int cid = e.getCourseId() != null ? e.getCourseId() : 0;
                String cName = e.getCourseName() != null ? e.getCourseName() : "";
                String instructorName = e.getInstructorName() != null ? e.getInstructorName() : "Instructor";
                String banner = e.getCourseBanner() != null ? e.getCourseBanner() : "";
                int progress = e.getProgress() != null ? e.getProgress() : 0;
                String completionStatus = e.getCompletionStatus() != null ? e.getCompletionStatus() : "Not Started";
                String paymentStatus = e.getPaymentStatus() != null ? e.getPaymentStatus() : "Pending";
                double price = e.getCoursePrice() != null ? e.getCoursePrice() : 0.0;
                long daysLeft = e.getDaysRemaining();
                
                boolean paid = "Paid".equalsIgnoreCase(paymentStatus) 
                            || "Completed".equalsIgnoreCase(paymentStatus) 
                            || "SUCCESS".equalsIgnoreCase(paymentStatus);
                boolean granted = paid || price <= 0.0;
                
                obj.put("enrollmentId", eid);
                obj.put("courseId", cid);
                obj.put("courseName", cName);
                obj.put("instructorName", instructorName);
                obj.put("courseBanner", banner);
                obj.put("progress", progress);
                obj.put("completionStatus", completionStatus);
                obj.put("paymentStatus", paymentStatus);
                obj.put("coursePrice", price);
                obj.put("daysRemaining", daysLeft);
                obj.put("courseAccessGranted", granted);
                
                enrollmentsJsonArray.put(obj);
            }
        }
        
        pageContext.setAttribute("serializedEnrollmentsJson", enrollmentsJsonArray.toString());
    %>

    <script type="text/javascript">
        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
        window.__ENROLLED_COURSES__ = ${serializedEnrollmentsJson};
    </script>

    <!-- React App Engine -->
    <script type="text/babel" data-plugins="transform-react-jsx">
        const { useState, useEffect, useMemo } = React;

        // Isolated CSS class name mappings — universal design matching dashboard
        const styles = {
            container: 'mc_mod_999_container',
            headerWrap: 'mc_mod_999_header_wrap',
            title: 'mc_mod_999_title',
            subtitle: 'mc_mod_999_subtitle',
            headerActions: 'mc_mod_999_header_actions',
            breadcrumb: 'mc_mod_999_breadcrumb',
            controlsRow: 'mc_mod_999_controls_row',
            filterGroup: 'mc_mod_999_filter_group',
            filterPill: 'mc_mod_999_filter_pill',
            filterPillActive: 'mc_mod_999_filter_pill_active',
            filterPillInactive: 'mc_mod_999_filter_pill_inactive',
            controlsSeparator: 'mc_mod_999_controls_separator',
            sortSelect: 'mc_mod_999_sort_select',
            searchWrapper: 'mc_mod_999_search_wrapper',
            searchIcon: 'mc_mod_999_search_icon',
            searchInput: 'mc_mod_999_search_input',
            resultsCount: 'mc_mod_999_results_count',
            courseGrid: 'mc_mod_999_course_grid',
            courseCard: 'mc_mod_999_course_card',
            courseBannerWrap: 'mc_mod_999_course_banner_wrap',
            courseBanner: 'mc_mod_999_course_banner',
            courseBannerEmpty: 'mc_mod_999_course_banner_empty',
            courseStatus: 'mc_mod_999_course_status',
            courseBody: 'mc_mod_999_course_body',
            courseInfo: 'mc_mod_999_course_info',
            courseTitle: 'mc_mod_999_course_title',
            courseInstructor: 'mc_mod_999_course_instructor',
            progressCircularContainer: 'mc_mod_999_progress_circular_container',
            progressRingWrapper: 'mc_mod_999_progress_ring_wrapper',
            svgRing: 'mc_mod_999_svg_ring',
            ringBg: 'mc_mod_999_ring_bg',
            ringFg: 'mc_mod_999_ring_fg',
            ringText: 'mc_mod_999_ring_text',
            progressActionHint: 'mc_mod_999_progress_action_hint',
            emptyState: 'mc_mod_999_empty_state',
            emptyIcon: 'mc_mod_999_empty_icon',
            svBtn: 'mc_mod_999_sv_btn',
            svBtnPrimary: 'mc_mod_999_sv_btn_primary',
            fadeInUp: 'mc_mod_999_fade_in_up'
        };

        // Robust Framer Motion React UMD container falling back to CSS animations gracefully
        const MotionDiv = ({ children, initial, animate, transition, variants, className, ...props }) => {
            const MotionComponent = window.Motion && window.Motion.motion 
                ? window.Motion.motion.div 
                : (window.FramerMotion && window.FramerMotion.motion ? window.FramerMotion.motion.div : null);
            
            if (MotionComponent) {
                return (
                    <MotionComponent 
                        initial={initial} 
                        animate={animate} 
                        transition={transition} 
                        variants={variants}
                        className={className} 
                        {...props}
                    >
                        {children}
                    </MotionComponent>
                );
            }
            return (
                <div className={(className || '') + ' ' + styles.fadeInUp} {...props}>
                    {children}
                </div>
            );
        };

        const gridContainerVariants = {
            hidden: { opacity: 0 },
            show: {
                opacity: 1,
                transition: {
                    staggerChildren: 0.08
                }
            }
        };

        const cardVariants = {
            hidden: { opacity: 0, y: 15 },
            show: { 
                opacity: 1, 
                y: 0,
                transition: {
                    type: "spring",
                    stiffness: 100,
                    damping: 15
                }
            }
        };

        const GRADIENTS = [
            'linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)',
            'linear-gradient(135deg, #0ea5e9 0%, #2563eb 100%)',
            'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
            'linear-gradient(135deg, #10b981 0%, #059669 100%)',
            'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)'
        ];

        function StudentCoursesApp() {
            const [enrollments] = useState(window.__ENROLLED_COURSES__ || []);
            const [filterStatus, setFilterStatus] = useState('all');
            const [searchQuery, setSearchQuery] = useState('');
            const [sortOption, setSortOption] = useState('default');
            const [notifications, setNotifications] = useState([]);

            // Parse any JSTL notification alert attributes in page
            useEffect(() => {
                const alerts = [];
                const p1 = document.getElementById("alertMessagePaid");
                const p2 = document.getElementById("alertMessageError");
                const p3 = document.getElementById("alertMessageAuth");
                const p4 = document.getElementById("alertMessageExcept");
                
                if (p1) alerts.push({ type: 'success', text: p1.getAttribute("data-message") });
                if (p2) alerts.push({ type: 'error', text: p2.getAttribute("data-message") });
                if (p3) alerts.push({ type: 'error', text: p3.getAttribute("data-message") });
                if (p4) alerts.push({ type: 'error', text: p4.getAttribute("data-message") });
                
                if (alerts.length > 0) {
                    setNotifications(alerts);
                }
            }, []);

            // Client side filter and sorting
            const processedCourses = useMemo(() => {
                let items = [...enrollments];

                // 1. Status Filter Mapping
                if (filterStatus === 'live') {
                    items = items.filter(c => c.completionStatus === 'In Progress' || c.completionStatus === 'Not Started');
                } else if (filterStatus === 'done') {
                    items = items.filter(c => c.completionStatus === 'Completed');
                }

                // 2. Search Keyword filter
                if (searchQuery.trim().length > 0) {
                    const q = searchQuery.toLowerCase().trim();
                    items = items.filter(c => 
                        c.courseName.toLowerCase().includes(q) || 
                        c.instructorName.toLowerCase().includes(q)
                    );
                }

                // 3. Sorting Algorithms
                if (sortOption === 'progress-desc') {
                    items.sort((a, b) => b.progress - a.progress);
                } else if (sortOption === 'progress-asc') {
                    items.sort((a, b) => a.progress - b.progress);
                } else if (sortOption === 'title-asc') {
                    items.sort((a, b) => a.courseName.localeCompare(b.courseName));
                }

                return items;
            }, [enrollments, filterStatus, searchQuery, sortOption]);

            const ctxPath = window.__CONTEXT_PATH__;
            const RING_RADIUS = 18;
            const CIRCUMFERENCE = 2 * Math.PI * RING_RADIUS;

            return (
                <div className={styles.container}>
                    {/* Visual breadcrumbs */}
                    <div className={styles.breadcrumb}>
                        <a href={ctxPath + "/dashboard"}><i className="fas fa-house"></i> Dashboard</a>
                        <span>/</span>
                        <span>My Courses</span>
                    </div>

                    {/* Alert banners if present */}
                    {notifications.map((n, idx) => (
                        <div 
                            key={idx} 
                            style={{
                                padding: '14px 20px',
                                borderRadius: '10px',
                                borderLeft: n.type === 'success' ? '4px solid #10b981' : '4px solid #ef4444',
                                backgroundColor: n.type === 'success' ? 'rgba(16, 185, 129, 0.05)' : 'rgba(239, 68, 68, 0.05)',
                                color: n.type === 'success' ? '#065f46' : '#991b1b',
                                fontSize: '0.88rem',
                                fontWeight: '600',
                                display: 'flex',
                                alignItems: 'center',
                                gap: '10px',
                                boxSizing: 'border-box'
                            }}
                        >
                            <i className={n.type === 'success' ? 'fas fa-circle-check' : 'fas fa-circle-exclamation'} />
                            {n.text}
                        </div>
                    ))}

                    {/* Header bar section */}
                    <header className={styles.headerWrap}>
                        <div>
                            <p className={styles.subtitle} style={{ fontSize: '0.98rem', color: '#64748b', fontWeight: '500', margin: 0 }}>
                                Resume your classes, review syllabus topics, and unlock milestones.
                            </p>
                        </div>
                        <div className={styles.headerActions}>
                            <a href={ctxPath + "/student/courses"} className={styles.svBtn + ' ' + styles.svBtnPrimary}>
                                <i className="fas fa-compass"></i> Explore Catalog
                            </a>
                        </div>
                    </header>

                    {/* Unified Filter Bar — clean single-row layout */}
                    <section className={styles.controlsRow}>
                        {/* Status filter pills */}
                        <div className={styles.filterGroup}>
                            <button 
                                className={styles.filterPill + ' ' + (filterStatus === 'all' ? styles.filterPillActive : styles.filterPillInactive)}
                                onClick={() => setFilterStatus('all')}
                            >
                                All Courses
                            </button>
                            <button 
                                className={styles.filterPill + ' ' + (filterStatus === 'live' ? styles.filterPillActive : styles.filterPillInactive)}
                                onClick={() => setFilterStatus('live')}
                            >
                                In Progress
                            </button>
                            <button 
                                className={styles.filterPill + ' ' + (filterStatus === 'done' ? styles.filterPillActive : styles.filterPillInactive)}
                                onClick={() => setFilterStatus('done')}
                            >
                                Completed
                            </button>
                        </div>

                        {/* Vertical separator */}
                        <div className={styles.controlsSeparator}></div>

                        {/* Sort dropdown */}
                        <select 
                            className={styles.sortSelect} 
                            value={sortOption} 
                            onChange={(e) => setSortOption(e.target.value)}
                        >
                            <option value="default">Default Order</option>
                            <option value="progress-desc">Highest Progress</option>
                            <option value="progress-asc">Lowest Progress</option>
                            <option value="title-asc">Title (A-Z)</option>
                        </select>

                        {/* Search input */}
                        <div className={styles.searchWrapper}>
                            <i className={"fas fa-search " + styles.searchIcon} />
                            <input 
                                type="text" 
                                placeholder="Search courses..." 
                                className={styles.searchInput}
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>

                        {/* Results count */}
                        <span className={styles.resultsCount}>
                            {processedCourses.length + ' course' + (processedCourses.length !== 1 ? 's' : '')}
                        </span>
                    </section>

                    {/* Main Course Grid — UNIVERSAL CARD DESIGN matching dashboard */}
                    {processedCourses.length === 0 ? (
                        <div className={styles.emptyState}>
                            <div className={styles.emptyIcon}>
                                <i className="fas fa-graduation-cap" />
                            </div>
                            <h3>No Courses Found</h3>
                            <p>We could not find any learning programs matching your filters. Browse the catalog to start studying.</p>
                            <a href={ctxPath + "/student/courses"} className={styles.svBtn + ' ' + styles.svBtnPrimary} style={{ marginTop: '12px' }}>
                                Browse Course Catalog
                            </a>
                        </div>
                    ) : (
                        <MotionDiv
                            variants={gridContainerVariants}
                            initial="hidden"
                            animate="show"
                            className={styles.courseGrid}
                        >
                            {processedCourses.map((course) => {
                                const detailUrl = ctxPath + "/student/enrollment-details?id=" + course.enrollmentId;
                                const statusClass = course.completionStatus === 'Completed' ? 'done' : (course.completionStatus === 'In Progress' ? 'live' : 'hold');
                                const offset = CIRCUMFERENCE - (course.progress / 100) * CIRCUMFERENCE;

                                const bannerSrc = course.courseBanner 
                                    ? (course.courseBanner.startsWith('http') ? course.courseBanner : ctxPath + '/' + course.courseBanner)
                                    : '';
                                
                                const fallbackGradient = GRADIENTS[course.courseId % 5];
                                const fallbackText = course.courseName ? course.courseName.substring(0, 2).toUpperCase() : 'CO';

                                const actionLabel = course.completionStatus === 'Completed' ? 'Review' : 'Resume';

                                return (
                                    <MotionDiv
                                        key={course.enrollmentId}
                                        variants={cardVariants}
                                    >
                                        <a
                                            href={detailUrl}
                                            className="sv-premium-card"
                                        >
                                            <div className="sv-premium-cover">
                                                {course.courseBanner ? (
                                                    <img src={bannerSrc} alt="" className="sv-premium-img" />
                                                ) : (
                                                    <div className={styles.courseBannerEmpty} style={{height: '100%', background: fallbackGradient, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#ffffff', fontSize: '2.5rem', fontWeight: '800', letterSpacing: '2px'}}>
                                                        {fallbackText}
                                                    </div>
                                                )}
                                            </div>
                                            
                                            <div className="sv-premium-gradient"></div>
                                            
                                            <div className="sv-premium-basic-info">
                                                <span className="sv-premium-category" style={{ color: course.completionStatus === 'Completed' ? '#10b981' : (course.completionStatus === 'In Progress' ? '#06b6d4' : '#fbbf24') }}>
                                                    {course.completionStatus}
                                                </span>
                                                <h3>{course.courseName}</h3>
                                                <span className="sv-premium-instructor"><i className="far fa-user"></i> {course.instructorName}</span>
                                            </div>

                                            <div className="sv-premium-reveal">
                                                <div className="sv-premium-reveal-meta" style={{ marginBottom: '24px' }}>
                                                    <div className={styles.progressCircularContainer} style={{ background: 'transparent' }}>
                                                        <div className={styles.progressRingWrapper} style={{ transform: 'scale(1.5)', marginBottom: '16px' }}>
                                                            <svg className={styles.svgRing} width="48" height="48" viewBox="0 0 48 48">
                                                                <circle className={styles.ringBg} cx="24" cy="24" r={RING_RADIUS} strokeWidth="4.5" fill="transparent" />
                                                                <circle className={styles.ringFg} cx="24" cy="24" r={RING_RADIUS} strokeWidth="4.5" fill="transparent" strokeDasharray={CIRCUMFERENCE} strokeDashoffset={offset} />
                                                            </svg>
                                                            <div className={styles.ringText} style={{ color: 'white' }}>{course.progress}%</div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                                    <span className={styles.svBtn + ' ' + (course.completionStatus === 'Completed' ? styles.svBtnSuccess : styles.svBtnPrimary)} style={{ width: '100%' }}>
                                                        {actionLabel} <i className="fas fa-arrow-right"></i>
                                                    </span>
                                                </div>
                                            </div>
                                        </a>
                                    </MotionDiv>
                                );
                            })}
                        </MotionDiv>
                    )}
                </div>
            );
        }

        // Mount Sandbox Application
        const containerNode = document.getElementById('student-react-root');
        if (containerNode) {
            const root = ReactDOM.createRoot(containerNode);
            root.render(<StudentCoursesApp />);
        }
    </script>
    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
