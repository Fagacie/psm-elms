<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List,java.util.Map" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
    
    <!-- Scoped isolated styles for the Discovery Experience -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/BrowseCourses.module.css">

    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for browser JSX compilation -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    
    <!-- Framer Motion for premium staggered layout animations -->
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
</head>
<body class="sv-page">
    <c:set var="topbarTitle" value="Browse Courses" />
    <c:set var="topbarSubtitle" value="Explore available learning catalog and enroll" />
    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

    <div class="sv-layout">
        <c:set var="activePage" value="browse-courses" />
        <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

        <main class="sv-main">
            <!-- Scoped React Sandbox Root node -->
            <div id="student-react-root"></div>
        </main>
    </div>

    <%
        List<Course> coursesList = (List<Course>) request.getAttribute("courses");
        List<Integer> enrolledIdsList = (List<Integer>) request.getAttribute("enrolledCourseIds");
        Map<Integer, Integer> enrolledMapObj = (Map<Integer, Integer>) request.getAttribute("enrolledCourseMap");
        
        com.psm.elearning.dao.UserDAO userDAO = new com.psm.elearning.dao.UserDAOImpl();
        org.json.JSONArray coursesJson = new org.json.JSONArray();
        if (coursesList != null) {
            for (Course c : coursesList) {
                org.json.JSONObject obj = new org.json.JSONObject();
                obj.put("courseId", c.getCourseId() != null ? c.getCourseId() : 0);
                obj.put("courseName", c.getCourseName() != null ? c.getCourseName() : "");
                obj.put("category", c.getCategory() != null ? c.getCategory() : "General");
                obj.put("level", c.getLevel() != null ? c.getLevel() : "All Levels");
                obj.put("courseFee", c.getCourseFee() != null ? c.getCourseFee() : 0.0);
                obj.put("displayDuration", c.getDisplayDuration() != null ? c.getDisplayDuration() : "Self-paced");
                obj.put("courseBanner", c.getCourseBanner() != null ? c.getCourseBanner() : "");
                obj.put("createdBy", c.getCreatedBy() != null ? c.getCreatedBy() : 0);
                
                String instructorName = "Instructor";
                if (c.getCreatedBy() != null) {
                    try {
                        com.psm.elearning.model.User instructor = userDAO.findById(c.getCreatedBy());
                        if (instructor != null && instructor.getFullName() != null) {
                            instructorName = instructor.getFullName();
                        }
                    } catch (Exception ex) {
                        // Keep fallback
                    }
                }
                obj.put("instructorName", instructorName);
                coursesJson.put(obj);
            }
        }
        
        org.json.JSONArray enrolledIdsJson = new org.json.JSONArray();
        if (enrolledIdsList != null) {
            for (Integer id : enrolledIdsList) {
                enrolledIdsJson.put(id);
            }
        }
        
        org.json.JSONObject enrolledMapJson = new org.json.JSONObject();
        if (enrolledMapObj != null) {
            for (Map.Entry<Integer, Integer> entry : enrolledMapObj.entrySet()) {
                enrolledMapJson.put(String.valueOf(entry.getKey()), entry.getValue());
            }
        }
        
        pageContext.setAttribute("serializedCourses", coursesJson.toString());
        pageContext.setAttribute("serializedEnrolledIds", enrolledIdsJson.toString());
        pageContext.setAttribute("serializedEnrolledMap", enrolledMapJson.toString());
    %>

    <script type="text/javascript">
        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
        window.__COURSES__ = ${serializedCourses};
        window.__ENROLLED_COURSE_IDS__ = ${serializedEnrolledIds};
        window.__ENROLLED_COURSE_MAP__ = ${serializedEnrolledMap};
    </script>

    <!-- React App Engine -->
    <script type="text/babel" data-presets="react,env">
        const { useState, useEffect, useMemo } = React;

        // Isolated CSS class name mappings — universal premium discovery design
        const styles = {
            container: 'bc_mod_456_container',
            breadcrumb: 'bc_mod_456_breadcrumb',
            headerWrap: 'bc_mod_456_header_wrap',
            title: 'bc_mod_456_title',
            subtitle: 'bc_mod_456_subtitle',
            headerActions: 'bc_mod_456_header_actions',
            controlsRow: 'bc_mod_456_controls_row',
            topRow: 'bc_mod_456_top_row',
            searchWrapper: 'bc_mod_456_search_wrapper',
            searchIcon: 'bc_mod_456_search_icon',
            searchInput: 'bc_mod_456_search_input',
            sortSelect: 'bc_mod_456_sort_select',
            filterBar: 'bc_mod_456_filter_bar',
            filterGroup: 'bc_mod_456_filter_group',
            filterPill: 'bc_mod_456_filter_pill',
            filterPillActive: 'bc_mod_456_filter_pill_active',
            filterPillInactive: 'bc_mod_456_filter_pill_inactive',
            resultsCount: 'bc_mod_456_results_count',
            courseGrid: 'bc_mod_456_course_grid',
            courseCard: 'bc_mod_456_course_card',
            courseBannerWrap: 'bc_mod_456_course_banner_wrap',
            courseBanner: 'bc_mod_456_course_banner',
            courseBannerEmpty: 'bc_mod_456_course_banner_empty',
            categoryBadge: 'bc_mod_456_category_badge',
            levelBadge: 'bc_mod_456_level_badge',
            courseBody: 'bc_mod_456_course_body',
            courseInfo: 'bc_mod_456_course_info',
            courseTitle: 'bc_mod_456_course_title',
            courseInstructor: 'bc_mod_456_course_instructor',
            courseMeta: 'bc_mod_456_course_meta',
            metaItem: 'bc_mod_456_meta_item',
            priceFree: 'bc_mod_456_price_free',
            priceValue: 'bc_mod_456_price_value',
            enrolledPill: 'bc_mod_456_enrolled_pill',
            cardAction: 'bc_mod_456_card_action',
            svBtn: 'bc_mod_456_sv_btn',
            svBtnPrimary: 'bc_mod_456_sv_btn_primary',
            svBtnSecondary: 'bc_mod_456_sv_btn_secondary',
            svBtnSuccess: 'bc_mod_456_sv_btn_success',
            emptyState: 'bc_mod_456_empty_state',
            emptyIcon: 'bc_mod_456_empty_icon',
            modalOverlay: 'bc_mod_456_modal_overlay',
            modalContainer: 'bc_mod_456_modal_container',
            spinner: 'bc_mod_456_spinner',
            successIcon: 'bc_mod_456_success_icon',
            fadeInUp: 'bc_mod_456_fade_in_up'
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
            const [courses] = useState(window.__COURSES__ || []);
            const [enrolledIds] = useState(window.__ENROLLED_COURSE_IDS__ || []);
            const [enrolledMap] = useState(window.__ENROLLED_COURSE_MAP__ || {});
            
            const [searchQuery, setSearchQuery] = useState('');
            const [selectedCategory, setSelectedCategory] = useState('All');
            const [sortOption, setSortOption] = useState('default');

            // Enrollment loaders
            const [isEnrolling, setIsEnrolling] = useState(false);
            const [enrollSuccess, setEnrollSuccess] = useState(false);
            const [enrollingCourseName, setEnrollingCourseName] = useState('');

            // Extract unique categories dynamically
            const categories = useMemo(() => {
                const unique = new Set(courses.map(c => c.category).filter(Boolean));
                return ['All', ...Array.from(unique)];
            }, [courses]);

            // Filter & Sort Course list in real-time
            const sortedCourses = useMemo(() => {
                let items = [...courses];
                
                // 1. Filter out already enrolled courses
                items = items.filter(c => !enrolledIds.includes(c.courseId));
                
                // 2. Category Filter
                if (selectedCategory !== 'All') {
                    items = items.filter(c => c.category === selectedCategory);
                }
                
                // 2. Search Query filter
                if (searchQuery.trim().length > 0) {
                    const q = searchQuery.toLowerCase().trim();
                    items = items.filter(c => 
                        c.courseName.toLowerCase().includes(q) || 
                        c.instructorName.toLowerCase().includes(q) ||
                        c.category.toLowerCase().includes(q)
                    );
                }
                
                // 3. Sorting Algorithms
                if (sortOption === 'price-low') {
                    items.sort((a, b) => a.courseFee - b.courseFee);
                } else if (sortOption === 'price-high') {
                    items.sort((a, b) => b.courseFee - a.courseFee);
                } else if (sortOption === 'title-asc') {
                    items.sort((a, b) => a.courseName.localeCompare(b.courseName));
                }
                
                return items;
            }, [courses, selectedCategory, searchQuery, sortOption]);

            const ctxPath = window.__CONTEXT_PATH__;

            const handleEnrollFree = (courseId, courseName) => {
                setEnrollingCourseName(courseName);
                setIsEnrolling(true);
                
                // Premium micro-interaction loader for 1.2s before redirecting
                setTimeout(() => {
                    setEnrollSuccess(true);
                    setTimeout(() => {
                        const form = document.createElement('form');
                        form.method = 'POST';
                        form.action = ctxPath + "/student/enroll";
                        
                        const input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = 'courseId';
                        input.value = courseId;
                        
                        form.appendChild(input);
                        document.body.appendChild(form);
                        form.submit();
                    }, 1000);
                }, 1200);
            };

            const handleEnrollPaid = (courseId) => {
                window.location.href = ctxPath + "/student/enrollment-summary?courseId=" + courseId;
            };

            return (
                <div className={styles.container}>
                    {/* Visual breadcrumbs */}
                    <div className={styles.breadcrumb}>
                        <a href={ctxPath + "/dashboard"}><i className="fas fa-house"></i> Dashboard</a>
                        <span>/</span>
                        <span>Browse Courses</span>
                    </div>

                    {/* Header bar section */}
                    <header className={styles.headerWrap}>
                        <div>
                            <p className={styles.subtitle} style={{ fontSize: '0.98rem', color: '#64748b', fontWeight: '500', margin: 0 }}>
                                Find courses, start enrollment, and launch your academic learning journey.
                            </p>
                        </div>
                        <div className={styles.headerActions}>
                            <a href={ctxPath + "/student/my-enrollments"} className={styles.svBtn + ' ' + styles.svBtnSecondary} style={{ width: 'auto' }}>
                                <i className="fas fa-book-open"></i> My Learning
                            </a>
                        </div>
                    </header>

                    {/* Unified Command Center — Search, Sort & Pills */}
                    <section className={styles.controlsRow}>
                        {/* Top controls: Search input & Sort dropdown */}
                        <div className={styles.topRow}>
                            <div className={styles.searchWrapper}>
                                <i className={"fas fa-search " + styles.searchIcon} />
                                <input 
                                    type="text" 
                                    placeholder="Search by course name, category, or instructor..." 
                                    className={styles.searchInput}
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                />
                            </div>

                            <select 
                                className={styles.sortSelect} 
                                value={sortOption} 
                                onChange={(e) => setSortOption(e.target.value)}
                            >
                                <option value="default">Default Sorting</option>
                                <option value="price-low">Price: Low to High</option>
                                <option value="price-high">Price: High to Low</option>
                                <option value="title-asc">Title: A to Z</option>
                            </select>
                        </div>

                        {/* Filter Bar: Category Scroll Pills & Results Counter */}
                        <div className={styles.filterBar}>
                            <div className={styles.filterGroup}>
                                {categories.map((cat, idx) => (
                                    <button
                                        key={idx}
                                        className={styles.filterPill + ' ' + (selectedCategory === cat ? styles.filterPillActive : styles.filterPillInactive)}
                                        onClick={() => setSelectedCategory(cat)}
                                    >
                                        {cat}
                                    </button>
                                ))}
                            </div>

                            <span className={styles.resultsCount}>
                                {sortedCourses.length + ' course' + (sortedCourses.length !== 1 ? 's' : '') + ' available'}
                            </span>
                        </div>
                    </section>

                    {/* Discovery Course Grid with framer-motion stagger animations */}
                    {sortedCourses.length === 0 ? (
                        <div className={styles.emptyState}>
                            <div className={styles.emptyIcon}>
                                <i className="fas fa-compass" />
                            </div>
                            <h3>No Courses Match</h3>
                            <p>We could not find any courses matching your keywords or selected category filters. Try adjusting your search query.</p>
                            <button onClick={() => { setSearchQuery(''); setSelectedCategory('All'); }} className={styles.svBtn + ' ' + styles.svBtnPrimary} style={{ marginTop: '12px', width: 'auto' }}>
                                Reset Filters
                            </button>
                        </div>
                    ) : (
                        <MotionDiv
                            variants={gridContainerVariants}
                            initial="hidden"
                            animate="show"
                            className={styles.courseGrid}
                        >
                            {sortedCourses.map((course) => {
                                const isEnrolled = enrolledIds.includes(course.courseId);
                                const isFree = course.courseFee <= 0.0;
                                const formattedPrice = isFree ? "Free" : course.courseFee.toFixed(2);
                                
                                const bannerSrc = course.courseBanner 
                                    ? (course.courseBanner.startsWith('http') ? course.courseBanner : ctxPath + '/' + course.courseBanner)
                                    : '';
                                
                                const fallbackGradient = GRADIENTS[course.courseId % 5];
                                const fallbackText = course.courseName ? course.courseName.substring(0, 2).toUpperCase() : 'CO';

                                return (
                                    <MotionDiv
                                        key={course.courseId}
                                        variants={cardVariants}
                                    >
                                        <a 
                                            href={isEnrolled ? ctxPath + "/student/enrollment-details?id=" + enrolledMap[course.courseId] : ctxPath + "/student/courses?action=details&id=" + course.courseId}
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
                                                <span className="sv-premium-category">{course.category}</span>
                                                <h3>{course.courseName}</h3>
                                                <span className="sv-premium-instructor"><i className="far fa-user"></i> {course.instructorName}</span>
                                            </div>
                                            
                                            <div className="sv-premium-reveal">
                                                <div className="sv-premium-reveal-price">
                                                    {isEnrolled ? (
                                                        <span style={{ color: '#10b981', fontSize: '1.25rem' }}><i className="fas fa-check-circle"></i> Enrolled</span>
                                                    ) : (
                                                        isFree ? 'Free' : '₦' + formattedPrice
                                                    )}
                                                </div>
                                                
                                                <div className="sv-premium-reveal-meta">
                                                    <span><i className="far fa-clock"></i> {course.displayDuration}</span>
                                                    <span><i className="fas fa-layer-group"></i> {course.level}</span>
                                                </div>
                                                
                                                <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                                    {isEnrolled ? (
                                                        <span className={styles.svBtn + ' ' + styles.svBtnSuccess} style={{ width: '100%' }}>
                                                            Continue Learning <i className="fas fa-arrow-right"></i>
                                                        </span>
                                                    ) : (
                                                        <React.Fragment>
                                                            <span className={styles.svBtn + ' ' + styles.svBtnSecondary} style={{ width: '100%' }}>
                                                                View Details
                                                            </span>
                                                            {isFree ? (
                                                                <button 
                                                                    onClick={(e) => { e.preventDefault(); handleEnrollFree(course.courseId, course.courseName); }} 
                                                                    className={styles.svBtn + ' ' + styles.svBtnPrimary} 
                                                                    style={{ width: '100%' }}
                                                                >
                                                                    Enroll Now
                                                                </button>
                                                            ) : (
                                                                <button 
                                                                    onClick={(e) => { e.preventDefault(); window.location.href = ctxPath + "/student/enrollment-summary?courseId=" + course.courseId; }}
                                                                    className={styles.svBtn + ' ' + styles.svBtnPrimary} 
                                                                    style={{ width: '100%' }}
                                                                >
                                                                    Enroll Now
                                                                </button>
                                                            )}
                                                        </React.Fragment>
                                                    )}
                                                </div>
                                            </div>
                                        </a>
                                    </MotionDiv>
                                );
                            })}
                        </MotionDiv>
                    )}

                    {/* Premium Glassmorphic Modal Loader */}
                    {isEnrolling && (
                        <div className={styles.modalOverlay}>
                            <div className={styles.modalContainer}>
                                {!enrollSuccess ? (
                                    <React.Fragment>
                                        <div className={styles.spinner} />
                                        <h3>Securing Your Spot...</h3>
                                        <p>Enrolling you in <strong>{enrollingCourseName}</strong>. Preparing syllabus and setting up your workspace resources...</p>
                                    </React.Fragment>
                                ) : (
                                    <React.Fragment>
                                        <div className={styles.successIcon}>
                                            <i className="fas fa-circle-check" />
                                        </div>
                                        <h3>Enrollment Successful!</h3>
                                        <p>Redirecting you directly to your learning workspace catalog. Get ready to launch your study modules!</p>
                                    </React.Fragment>
                                )}
                            </div>
                        </div>
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
