<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.courseName}"/> - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    
    <!-- Scoped isolated styles for the ultra-minimalist storefront -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/CourseDetails.module.css">

    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for browser JSX compilation -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>

    <!-- Lucide Core for thin UI icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="sv-page">
    <c:set var="topbarTitle" value="Course Details" />
    <c:set var="topbarSubtitle" value="Review details and choose your next step" />
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
        Course cObj = (Course) request.getAttribute("course");
        User instObj = (User) request.getAttribute("instructor");
        List<Material> matsList = (List<Material>) request.getAttribute("materials");
        List<Integer> enrolledIdsList = (List<Integer>) request.getAttribute("enrolledCourseIds");
        
        org.json.JSONObject courseJson = new org.json.JSONObject();
        if (cObj != null) {
            courseJson.put("courseId", cObj.getCourseId() != null ? cObj.getCourseId() : 0);
            courseJson.put("courseName", cObj.getCourseName() != null ? cObj.getCourseName() : "");
            courseJson.put("description", cObj.getDescription() != null ? cObj.getDescription() : "");
            courseJson.put("category", cObj.getCategory() != null ? cObj.getCategory() : "General");
            courseJson.put("level", cObj.getLevel() != null ? cObj.getLevel() : "All Levels");
            courseJson.put("courseFee", cObj.getCourseFee() != null ? cObj.getCourseFee().doubleValue() : 0.0);
            courseJson.put("displayDuration", cObj.getDisplayDuration() != null ? cObj.getDisplayDuration() : "Self-paced");
            courseJson.put("courseBanner", cObj.getCourseBanner() != null ? cObj.getCourseBanner() : "");
        }
        
        org.json.JSONObject instructorJson = new org.json.JSONObject();
        if (instObj != null) {
            instructorJson.put("fullName", instObj.getFullName() != null ? instObj.getFullName() : "Instructor");
            instructorJson.put("email", instObj.getEmail() != null ? instObj.getEmail() : "");
        }
        
        org.json.JSONArray materialsJson = new org.json.JSONArray();
        if (matsList != null) {
            for (Material m : matsList) {
                org.json.JSONObject mObj = new org.json.JSONObject();
                mObj.put("materialId", m.getMaterialId() != null ? m.getMaterialId() : 0);
                mObj.put("title", m.getTitle() != null ? m.getTitle() : "");
                mObj.put("description", m.getDescription() != null ? m.getDescription() : "");
                mObj.put("materialType", m.getMaterialType() != null ? m.getMaterialType() : "Document");
                materialsJson.put(mObj);
            }
        }
        
        boolean isEnrolled = false;
        if (cObj != null && enrolledIdsList != null && enrolledIdsList.contains(cObj.getCourseId())) {
            isEnrolled = true;
        }
        
        pageContext.setAttribute("serializedCourse", courseJson.toString());
        pageContext.setAttribute("serializedInstructor", instructorJson.toString());
        pageContext.setAttribute("serializedMaterials", materialsJson.toString());
        pageContext.setAttribute("isEnrolled", isEnrolled);
    %>

    <script type="text/javascript">
        window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
        window.__COURSE__ = ${serializedCourse};
        window.__INSTRUCTOR__ = ${serializedInstructor};
        window.__MATERIALS__ = ${serializedMaterials};
        window.__IS_ENROLLED__ = ${isEnrolled};
    </script>

    <!-- React App Engine -->
    <script type="text/babel">
        const { useState, useEffect } = React;

        // Custom Scoped Isolated CSS classes (immune to legacy Bootstrap overrides)
        const styles = {
            container: 'cd_mod_789_container',
            breadcrumb: 'cd_mod_789_breadcrumb',
            hero: 'cd_mod_789_hero',
            title: 'cd_mod_789_title',
            meta: 'cd_mod_789_meta',
            metaDot: 'cd_mod_789_meta_dot',
            grid: 'cd_mod_789_grid',
            leftCol: 'cd_mod_789_left_col',
            section: 'cd_mod_789_section',
            sectionTitle: 'cd_mod_789_section_title',
            description: 'cd_mod_789_description',
            syllabusList: 'cd_mod_789_syllabus_list',
            syllabusItem: 'cd_mod_789_syllabus_item',
            syllabusLeft: 'cd_mod_789_syllabus_left',
            syllabusIcon: 'cd_mod_789_syllabus_icon',
            syllabusText: 'cd_mod_789_syllabus_text',
            syllabusBadge: 'cd_mod_789_syllabus_badge',
            rightCol: 'cd_mod_789_right_col',
            bannerWrap: 'cd_mod_789_banner_wrap',
            banner: 'cd_mod_789_banner',
            bannerPlaceholder: 'cd_mod_789_banner_placeholder',
            priceWrap: 'cd_mod_789_price_wrap',
            priceLabel: 'cd_mod_789_price_label',
            priceVal: 'cd_mod_789_price_val',
            priceFree: 'cd_mod_789_price_free',
            btnStack: 'cd_mod_789_btn_stack',
            actionBtn: 'cd_mod_789_action_btn',
            actionBtnPrimary: 'cd_mod_789_action_btn_primary',
            actionBtnSuccess: 'cd_mod_789_action_btn_success',
            actionBtnSecondary: 'cd_mod_789_action_btn_secondary',
            spinner: 'cd_mod_789_spinner',
            trustBadges: 'cd_mod_789_trust_badges',
            trustItem: 'cd_mod_789_trust_item',
            trustIcon: 'cd_mod_789_trust_icon'
        };

        function StudentCourseDetailsApp() {
            const course = window.__COURSE__ || {};
            const instructor = window.__INSTRUCTOR__ || {};
            const materials = window.__MATERIALS__ || [];
            const isEnrolled = window.__IS_ENROLLED__ || false;

            const [isEnrolling, setIsEnrolling] = useState(false);
            const ctxPath = window.__CONTEXT_PATH__;

            useEffect(() => {
                // Parse and boot Lucide UMD dynamic icons
                if (window.lucide) {
                    window.lucide.createIcons();
                }
            }, []);

            const handleEnroll = () => {
                if (isEnrolled) return;
                setIsEnrolling(true);

                const isFree = course.courseFee <= 0;
                
                if (isFree) {
                    // Trigger free enrollment direct secure POST sequence
                    setTimeout(() => {
                        const form = document.createElement('form');
                        form.method = 'POST';
                        form.action = ctxPath + "/student/enroll";
                        
                        const input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = 'courseId';
                        input.value = course.courseId;
                        
                        form.appendChild(input);
                        document.body.appendChild(form);
                        form.submit();
                    }, 800);
                } else {
                    // Redirect to safe Paystack payment checkout page
                    setTimeout(() => {
                        window.location.href = ctxPath + "/student/enrollment-summary?courseId=" + course.courseId;
                    }, 500);
                }
            };

            const isFree = course.courseFee <= 0;
            const formattedPrice = isFree ? "Free" : "₦" + course.courseFee.toFixed(2);
            
            const bannerSrc = course.courseBanner 
                ? (course.courseBanner.startsWith('http') ? course.courseBanner : ctxPath + '/' + course.courseBanner)
                : '';

            return (
                <div className={styles.container}>
                    {/* Visual breadcrumbs path mapping */}
                    <div className={styles.breadcrumb}>
                        <a href={ctxPath + "/dashboard"}>
                            <i data-lucide="home" style={{ width: '13px', height: '13px', verticalAlign: 'middle', marginRight: '4px' }}></i> Dashboard
                        </a>
                        <span>/</span>
                        <a href={ctxPath + "/student/courses"}>Browse Courses</a>
                        <span>/</span>
                        <span style={{ color: '#0f172a', fontWeight: '600' }}>{course.courseName}</span>
                    </div>

                    {/* Typographic Hero (sitting flat on white canvas) */}
                    <header className={styles.hero}>
                        <h1 className={styles.title}>{course.courseName}</h1>
                        <div className={styles.meta}>
                            <span>By <strong>{instructor.fullName || 'TBA'}</strong></span>
                            <span className={styles.metaDot}>•</span>
                            <span>{course.level}</span>
                            <span className={styles.metaDot}>•</span>
                            <span>{course.category}</span>
                        </div>
                    </header>

                    {/* Asymmetrical Layout Grid */}
                    <div className={styles.grid}>
                        
                        {/* Reading Column (Left) */}
                        <div className={styles.leftCol}>
                            
                            {/* Course Description Section */}
                            <section className={styles.section}>
                                <h3 className={styles.sectionTitle}>Course Overview</h3>
                                <p className={styles.description}>
                                    {course.description || "Acquire practical, state-of-the-art capabilities that will help you excel immediately in the professional workspace."}
                                </p>
                            </section>

                            {/* Syllabus Curriculum List (Simple Vertical Text List, No Boxes) */}
                            <section className={styles.section}>
                                <h3 className={styles.sectionTitle}>Course Syllabus</h3>
                                {materials.length === 0 ? (
                                    <p style={{ color: '#64748b', fontSize: '0.95rem' }}>No syllabus modules published yet. Please check back later.</p>
                                ) : (
                                    <div className={styles.syllabusList}>
                                        {materials.map((mat, index) => {
                                            const isVideo = mat.materialType === 'Video' || mat.materialType === 'YouTube';
                                            const isPdf = mat.materialType === 'PDF';
                                            const isSlides = mat.materialType === 'Slides';
                                            
                                            let iconName = "link";
                                            if (isVideo) iconName = "play-circle";
                                            else if (isPdf) iconName = "file-text";
                                            else if (isSlides) iconName = "presentation";

                                            return (
                                                <div key={mat.materialId} className={styles.syllabusItem}>
                                                    <div className={styles.syllabusLeft}>
                                                        <span className={styles.syllabusIcon}>
                                                            <i data-lucide={iconName} style={{ width: '16px', height: '16px' }}></i>
                                                        </span>
                                                        <span className={styles.syllabusText}>{mat.title}</span>
                                                    </div>
                                                    <span className={styles.syllabusBadge}>Module {index + 1}</span>
                                                </div>
                                            );
                                        })}
                                    </div>
                                )}
                            </section>

                        </div>

                        {/* Sticky Action Sidebar (Right, Flat & Shadowless) */}
                        <aside className={styles.rightCol}>
                            
                            {/* Banner Thumbnail */}
                            <div className={styles.bannerWrap}>
                                {course.courseBanner ? (
                                    <img 
                                        src={bannerSrc}
                                        alt=""
                                        className={styles.banner}
                                    />
                                ) : (
                                    <div className={styles.bannerPlaceholder}>
                                        <i data-lucide="image" style={{ width: '32px', height: '32px' }}></i>
                                        <span>No Banner</span>
                                    </div>
                                )}
                            </div>

                            {/* Flat Price tag Display */}
                            <div className={styles.priceWrap}>
                                <span className={styles.priceLabel}>Enrollment Investment</span>
                                <span className={styles.priceVal + ' ' + (isFree ? styles.priceFree : '')}>
                                    {formattedPrice}
                                </span>
                            </div>

                            {/* Frictionless conversion button stack */}
                            <div className={styles.btnStack}>
                                {isEnrolled ? (
                                    <button 
                                        disabled
                                        className={styles.actionBtn + ' ' + styles.actionBtnSuccess}
                                    >
                                        <i data-lucide="check" style={{ width: '16px', height: '16px' }}></i> Enrolled
                                    </button>
                                ) : (
                                    <button 
                                        onClick={handleEnroll}
                                        disabled={isEnrolling}
                                        className={styles.actionBtn + ' ' + styles.actionBtnPrimary}
                                    >
                                        {isEnrolling ? (
                                            <span className={styles.spinner} />
                                        ) : (
                                            course.courseFee > 0 ? "Buy Course Now" : "Enroll for Free Now"
                                        )}
                                    </button>
                                )}

                                <a 
                                    href={ctxPath + "/student/courses"} 
                                    className={styles.actionBtn + ' ' + styles.actionBtnSecondary}
                                >
                                    <i data-lucide="arrow-left" style={{ width: '16px', height: '16px', verticalAlign: 'middle', marginRight: '6px' }}></i> Back to Courses
                                </a>
                            </div>

                            {/* Secure trust guarantees badges */}
                            <div className={styles.trustBadges}>
                                <div className={styles.trustItem}>
                                    <span className={styles.trustIcon}>
                                        <i data-lucide="lock" style={{ width: '14px', height: '14px' }}></i>
                                    </span>
                                    <span><strong>Instant Access</strong> — Start learning immediately after checkout verification.</span>
                                </div>
                                <div className={styles.trustItem}>
                                    <span className={styles.trustIcon}>
                                        <i data-lucide="award" style={{ width: '14px', height: '14px' }}></i>
                                    </span>
                                    <span><strong>Completion Certificate</strong> — Shareable professional credential upon clearing assessment criteria.</span>
                                </div>
                            </div>

                        </aside>

                    </div>
                </div>
            );
        }

        // Mount Sandbox Application
        const containerNode = document.getElementById('student-react-root');
        if (containerNode) {
            const root = ReactDOM.createRoot(containerNode);
            root.render(<StudentCourseDetailsApp />);
        }
    </script>
</body>
</html>
