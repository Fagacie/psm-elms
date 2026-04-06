<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="studentProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Courses - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/browse-courses-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Browse Courses"/>
<c:set var="topbarSubtitle" value="Discover and enroll in new courses"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="browse-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main bc-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>Browse Courses</span>
        </div>

        <section class="bc-hero sv-card">
            <div class="sv-card-body bc-hero-body">
                <div class="bc-hero-copy">
                    <h2>Find The Right Course, Start Fast</h2>
                    <p>Filter by category, level, and fee. Open details or enroll directly from course cards.</p>
                    <div class="bc-hero-stats">
                        <div><strong class="bc-count" data-counter="${not empty courses ? courses.size() : 0}">${not empty courses ? courses.size() : 0}</strong><span>Available</span></div>
                        <div><strong class="bc-count" data-counter="${not empty enrolledCourseIds ? enrolledCourseIds.size() : 0}">${not empty enrolledCourseIds ? enrolledCourseIds.size() : 0}</strong><span>Already Enrolled</span></div>
                        <div><strong>${not empty searchKeyword ? 'Search Active' : 'All Catalog'}</strong><span>Mode</span></div>
                    </div>
                </div>
                <div class="bc-hero-scene" id="bcHeroScene" aria-hidden="true">
                    <span class="bc-obj bc-obj-a" data-depth="18"></span>
                    <span class="bc-obj bc-obj-b" data-depth="28"></span>
                    <span class="bc-obj bc-obj-c" data-depth="14"></span>
                    <span class="bc-obj bc-obj-d" data-depth="22"></span>
                </div>
            </div>
        </section>

        <c:if test="${not empty param.success}"><div class="alert alert-success">Course enrollment action completed successfully.</div></c:if>
        <c:if test="${not empty param.error}"><div class="alert alert-error">Action failed. Please retry.</div></c:if>

        <section class="sv-card">
            <div class="sv-card-head"><h3>Search And Filter</h3></div>
            <div class="sv-card-body">
                <form method="get" action="${pageContext.request.contextPath}/student/courses" class="bc-filter-grid">
                    <div>
                        <label>Keyword</label>
                        <input type="text" name="keyword" placeholder="Title, category, level" value="${searchKeyword}">
                    </div>
                    <div>
                        <label>Category</label>
                        <input type="text" name="category" placeholder="e.g. Programming" value="${filterCategory}">
                    </div>
                    <div>
                        <label>Level</label>
                        <select name="level">
                            <option value="">All Levels</option>
                            <option value="Beginner" ${filterLevel == 'Beginner' ? 'selected' : ''}>Beginner</option>
                            <option value="Intermediate" ${filterLevel == 'Intermediate' ? 'selected' : ''}>Intermediate</option>
                            <option value="Advanced" ${filterLevel == 'Advanced' ? 'selected' : ''}>Advanced</option>
                        </select>
                    </div>
                    <div>
                        <label>Min Fee</label>
                        <input type="number" step="0.01" min="0" name="minFee" value="${filterMinFee}">
                    </div>
                    <div>
                        <label>Max Fee</label>
                        <input type="number" step="0.01" min="0" name="maxFee" value="${filterMaxFee}">
                    </div>
                    <div class="bc-filter-actions">
                        <button class="sv-btn" type="submit" name="action" value="search">Search</button>
                        <button class="sv-btn primary" type="submit" name="action" value="filter">Apply Filters</button>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Clear</a>
                    </div>
                </form>
            </div>
        </section>

        <section class="sv-card">
            <div class="sv-card-body bc-controlbar" aria-label="Quick browser controls">
                <div class="bc-filter-group">
                    <button type="button" class="bc-filter active" data-filter="all">All</button>
                    <button type="button" class="bc-filter" data-filter="beginner">Beginner</button>
                    <button type="button" class="bc-filter" data-filter="intermediate">Intermediate</button>
                    <button type="button" class="bc-filter" data-filter="advanced">Advanced</button>
                    <button type="button" class="bc-filter" data-filter="enrolled">Enrolled</button>
                </div>
                <div class="bc-search-wrap">
                    <label for="bcQuickSearch" class="bc-sr-only">Quick search courses</label>
                    <input id="bcQuickSearch" type="text" placeholder="Quick search courses..." autocomplete="off">
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
                <section class="bc-course-grid" id="bcGrid">
                    <c:forEach var="course" items="${courses}">
                        <c:set var="isEnrolled" value="${not empty enrolledCourseIds && enrolledCourseIds.contains(course.courseId)}"/>
                        <article class="bc-card sv-card bc-tilt" data-level="${fn:toLowerCase(course.level)}" data-enrolled="${isEnrolled ? 'yes' : 'no'}" data-course="${course.courseName}" data-category="${course.category}">
                            <div class="bc-card-head">
                                <span class="assessment-type-badge assessment-type-${course.level == 'Beginner' ? 'Assignment' : (course.level == 'Intermediate' ? 'Quiz' : 'Exam')}">${course.level}</span>
                                <span class="bc-cat">${course.category}</span>
                            </div>
                            <div class="sv-card-body">
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
                                </div>
                                <h3>${course.courseName}</h3>
                                <p>
                                    <c:choose>
                                        <c:when test="${not empty course.description && course.description.length() > 150}">${course.description.substring(0, 150)}...</c:when>
                                        <c:otherwise>${course.description}</c:otherwise>
                                    </c:choose>
                                </p>
                                <div class="bc-meta">
                                    <span><i class="fas fa-clock"></i> ${course.displayDuration}</span>
                                    <span><i class="fas fa-wallet"></i>
                                        <c:choose>
                                            <c:when test="${course.courseFee == 0}">Free</c:when>
                                            <c:otherwise><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="bc-actions">
                                    <a href="${pageContext.request.contextPath}/student/courses?action=details&id=${course.courseId}" class="sv-btn">Details</a>
                                    <c:choose>
                                        <c:when test="${isEnrolled}">
                                            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">My Course</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="sv-btn primary">Enroll</a>
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

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/browse-courses-v2.js"></script>
</body>
</html>

