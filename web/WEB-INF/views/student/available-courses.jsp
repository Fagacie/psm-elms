<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/browse-courses-v2.css">
</head>

<body class="sv-page">
    <c:set var="topbarTitle" value="Browse Courses" />
    <c:set var="topbarSubtitle" value="Find courses and start enrollment" />
    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

    <div class="sv-layout">
        <c:set var="activePage" value="browse-courses" />
        <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

        <main class="sv-main bc-main">
            <div class="sv-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
                <span>/</span>
                <span>Browse Courses</span>
            </div>

            <!-- Premium Discovery Hero section -->
            <section class="bc-hero sv-card bc-hero-card">
                <div class="sv-card-body bc-hero-card__body">
                    <div class="bc-hero-copy bc-hero-card__copy">
                        <span class="bc-hero-card__kicker">
                            <i class="fas fa-compass bc-hero-card__kicker-icon"></i> Course Catalog
                        </span>
                        <h2 class="bc-hero-card__title">Browse available courses</h2>
                        <p class="bc-hero-card__text">Filter by difficulty, category, or price. Open a course to review the details before enrolling.</p>
                        <div class="bc-hero-card__actions">
                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary"><i class="fas fa-book-open-reader"></i> My Learning</a>
                            <a href="${pageContext.request.contextPath}/student/payments" class="sv-btn"><i class="fas fa-receipt"></i> Billing history</a>
                        </div>
                    </div>

                    <div class="bc-hero-card__stats">
                        <div class="bc-hero-card__stat">
                            <i class="fas fa-graduation-cap bc-hero-card__stat-icon"></i>
                            <div class="bc-hero-card__stat-copy">
                                <strong class="bc-count bc-hero-card__stat-value" data-counter="${not empty courses ? fn:length(courses) : 0}">${not empty courses ? fn:length(courses) : 0}</strong>
                                <span class="bc-hero-card__stat-label">Available Catalog</span>
                            </div>
                        </div>
                        <div class="bc-hero-card__stat">
                            <i class="fas fa-book-bookmark bc-hero-card__stat-icon is-success"></i>
                            <div class="bc-hero-card__stat-copy">
                                <strong class="bc-count bc-hero-card__stat-value" data-counter="${not empty enrolledCourseIds ? fn:length(enrolledCourseIds) : 0}">${not empty enrolledCourseIds ? fn:length(enrolledCourseIds) : 0}</strong>
                                <span class="bc-hero-card__stat-label">Active Courses</span>
                            </div>
                        </div>
                        <div class="bc-hero-card__stat">
                            <i class="fas fa-tags bc-hero-card__stat-icon is-warning"></i>
                            <div class="bc-hero-card__stat-copy">
                                <strong class="bc-count bc-hero-card__stat-value" data-counter="${freeCourseCount}">${freeCourseCount}</strong>
                                <span class="bc-hero-card__stat-label">Free Classes</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <c:if test="${not empty param.success}">
                <div class="alert alert-success">Course enrollment action completed successfully.</div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-error">Action failed. Please retry.</div>
            </c:if>

            <!-- 1. Horizontal Control bar (Instant filters bar) -->
            <section class="sv-card">
                <div class="sv-card-body bc-controlbar" aria-label="Quick browser controls">
                    <div class="bc-filter-group">
                        <button type="button" class="bc-filter active" data-filter="all">All</button>
                        <button type="button" class="bc-filter" data-filter="free">Free</button>
                        <button type="button" class="bc-filter" data-filter="paid">Paid</button>
                        <button type="button" class="bc-filter" data-filter="beginner">Beginner</button>
                        <button type="button" class="bc-filter" data-filter="intermediate">Intermediate</button>
                        <button type="button" class="bc-filter" data-filter="advanced">Advanced</button>
                        <button type="button" class="bc-filter" data-filter="enrolled">Enrolled</button>
                    </div>
                    <div class="bc-search-wrap">
                        <label for="bcQuickSearch" class="bc-sr-only">Quick search courses</label>
                        <input id="bcQuickSearch" type="text" placeholder="Search courses or categories..." autocomplete="off" data-search-target="#bcGrid" data-search-item=".bc-card">
                        <i class="fas fa-magnifying-glass bc-search-icon"></i>
                    </div>
                </div>
            </section>

            <c:choose>
                <c:when test="${empty courses}">
                    <section class="sv-card">
                        <div class="sv-card-body">
                            <div class="empty-state-box">
                                <i class="fas fa-book-open"></i>
                                <h3>No Courses Found</h3>
                                <p>No courses match your current search/filter criteria.</p>
                                <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">View Full Catalog</a>
                            </div>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>


                    <!-- Pulsing Skeleton Loader Grid -->
                    <div class="bc-skeleton-grid" id="bcSkeletonGrid">
                        <c:forEach begin="1" end="3">
                            <div class="bc-skeleton-card">
                                <div class="bc-skeleton-banner"></div>
                                <div class="bc-skeleton-title"></div>
                                <div class="bc-skeleton-meta"></div>
                                <div class="bc-skeleton-button"></div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Spacious 3-Column Spanning Grid -->
                    <section class="bc-course-grid is-hidden" id="bcGrid">
                        <c:forEach var="course" items="${courses}">
                            <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}" />
                            <c:set var="isFree" value="${empty course.courseFee || course.courseFee le 0}" />
                            
                            <c:set var="lowercasedLevel" value="all" />
                            <c:if test="${not empty course.level}">
                                <c:set var="lowercasedLevel" value="${fn:toLowerCase(course.level)}" />
                            </c:if>
                            
                            <article class="bc-card sv-card bc-tilt"
                                tabindex="0"
                                data-level="${lowercasedLevel}"
                                data-enrolled="${isEnrolled ? 'yes' : 'no'}"
                                data-price-type="${isFree ? 'free' : 'paid'}"
                                data-course='<c:out value="${course.courseName}"/>'
                                data-category='<c:out value="${course.category}"/>'
                                data-href="${isEnrolled ? pageContext.request.contextPath.concat('/student/enrollment-details?id=').concat(enrolledCourseMap[course.courseId]) : pageContext.request.contextPath.concat('/student/courses?action=details&id=').concat(course.courseId)}">
                                
                                <!-- Details stacked vertically inside body container -->
                                <div class="sv-card-body bc-card-body-tight bc-card-details-stack">
                                    
                                    <!-- Banner image area (clean graphic banner) -->
                                    <div class="bc-banner-wrap">
                                        <c:choose>
                                            <c:when test="${not empty course.courseBanner}">
                                                <c:choose>
                                                    <c:when test="${course.courseBanner.startsWith('http')}">
                                                        <img class="bc-banner" src="${course.courseBanner}" alt="${course.courseName} banner">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img class="bc-banner" src="${pageContext.request.contextPath}/${course.courseBanner}" alt="${course.courseName} banner">
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="bc-banner bc-banner-placeholder">
                                                    <i class="fas fa-image"></i>
                                                    <span>Course Banner</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- floating overlaid taxonomic chips -->
                                        <span class="bc-level-badge level-${lowercasedLevel}">${course.level}</span>
                                        <span class="bc-cat"><c:out value="${course.category}"/></span>
                                    </div>

                                    <h3 data-search-text class="bc-course-title">
                                        <c:out value="${course.courseName}" />
                                    </h3>

                                    <!-- Elegant Metadata Row (Duration, Price, and active Enrolled Status) -->
                                    <div class="bc-meta">
                                        <span><i class="fas fa-clock bc-meta-icon"></i> ${course.displayDuration}</span>
                                        <span><i class="fas fa-wallet bc-meta-icon is-success"></i>
                                            <c:choose>
                                                <c:when test="${isFree}">Free</c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <c:if test="${isEnrolled}">
                                            <span class="bc-enrolled-pill"><i class="fas fa-circle-check"></i> Enrolled</span>
                                        </c:if>
                                    </div>

                                    <!-- Action panel (original links and form definitions perfectly preserved) -->
                                    <div class="bc-actions">
                                        <a href="${pageContext.request.contextPath}/student/courses?action=details&id=${course.courseId}" class="sv-btn bc-details-btn">View Details</a>
                                        
                                        <c:choose>
                                            <c:when test="${isEnrolled}">
                                                 <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrolledCourseMap[course.courseId]}" class="sv-btn bc-btn-enrolled">Continue Learning</a>
                                             </c:when>
                                            <c:otherwise>
                                                <c:choose>
                                                    <c:when test="${isFree}">
                                                        <form method="post" action="${pageContext.request.contextPath}/student/enroll" style="display:inline;" class="bc-free-enroll-form">
                                                            <input type="hidden" name="courseId" value="${course.courseId}">
                                                            <button type="submit" class="sv-btn primary bc-free-enroll-btn">
                                                                <span class="btn-text">Enroll Free</span>
                                                                <span class="btn-spinner"><i class="fas fa-spinner fa-spin"></i></span>
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="sv-btn primary bc-paid-enroll-btn">
                                                            <span class="btn-text">Enroll</span>
                                                            <span class="btn-spinner"><i class="fas fa-spinner fa-spin"></i></span>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </section>

                    <section class="sv-card bc-empty-hidden" id="bcNoRows">
                        <div class="sv-card-body">
                            <div class="empty-state-box">
                                <i class="fas fa-magnifying-glass"></i>
                                <h3>No Courses Match</h3>
                                <p>Try another quick filter or search term.</p>
                            </div>
                        </div>
                    </section>
                </c:otherwise>
            </c:choose>
        </main>
    </div>



    <!-- 2. Interactive Free Enrollment Glassmorphic Modal Overlay -->
    <div class="bc-enroll-overlay" id="bcEnrollOverlay">
        <div class="bc-enroll-modal">
            <div class="bc-modal-loader" id="bcModalLoader">
                <div class="bc-spinner"></div>
                <h3>Securing Your Spot...</h3>
                <p>We are initializing your workspace resources and enrolling you into the course.</p>
            </div>
            <div class="bc-modal-success is-hidden" id="bcModalSuccess">
                <div class="bc-success-checkmark">
                    <i class="fas fa-circle-check"></i>
                </div>
                <h3>Enrollment Successful!</h3>
                <p>Welcome aboard! Redirecting you directly to your My Courses list...</p>
            </div>
        </div>
    </div>

    <div class="sv-overlay" id="svOverlay"></div>
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
    <script src="${pageContext.request.contextPath}/js/browse-courses-v2.js"></script>
</body>

</html>