<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="studentProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Materials - Student</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/materials-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Learning Materials</h1><p>Organized by your paid courses</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/profile" class="sv-profile-link"><c:choose><c:when test="${not empty studentProfilePicture}"><c:choose><c:when test="${fn:startsWith(studentProfilePicture, 'http')}"><img src="${studentProfilePicture}" alt="Profile" class="sv-avatar-img"></c:when><c:otherwise><img src="${pageContext.request.contextPath}${studentProfilePicture}" alt="Profile" class="sv-avatar-img"></c:otherwise></c:choose></c:when><c:otherwise><i class="fas fa-user"></i></c:otherwise></c:choose><span>${sessionScope.userName}</span></a><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link active"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>Learning Materials</span>
        </div>

        <div class="alert alert-info">
            <strong>Flow:</strong> materials and assessments are also available in each course Learning Hub.
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-link-inline">Open My Courses</a>.
        </div>

        <c:if test="${not empty errorMessage}"><div class="alert alert-error">${errorMessage}</div></c:if>

        <c:choose>
            <c:when test="${empty paidEnrollments}">
                <section class="sv-card">
                    <div class="sv-card-body">
                        <div class="empty-state-box">
                            <i class="fas fa-graduation-cap"></i>
                            <p>You do not have paid enrollments yet. Complete payment to unlock materials.</p>
                            <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary">Browse Courses</a>
                        </div>
                    </div>
                </section>
            </c:when>
            <c:otherwise>
                <section class="sv-card">
                    <div class="sv-card-head"><h3>Filter Materials</h3></div>
                    <div class="sv-card-body mat-toolbar">
                        <form method="get" action="${pageContext.request.contextPath}/student/materials" class="mat-filter">
                            <div>
                                <label for="courseId">Course</label>
                                <select id="courseId" name="courseId">
                                    <option value="">All paid courses</option>
                                    <c:forEach var="e" items="${paidEnrollments}">
                                        <option value="${e.courseId}" <c:if test="${selectedCourseId == e.courseId}">selected</c:if>>${e.courseName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label>Keyword</label>
                                <input type="text" name="keyword" value="${searchKeyword}" placeholder="title or description">
                            </div>
                            <div>
                                <label>Type</label>
                                <select name="materialType">
                                    <option value="">All Types</option>
                                    <option value="PDF" ${selectedMaterialType == 'PDF' ? 'selected' : ''}>PDF</option>
                                    <option value="Video" ${selectedMaterialType == 'Video' ? 'selected' : ''}>Video</option>
                                    <option value="Slides" ${selectedMaterialType == 'Slides' ? 'selected' : ''}>Slides</option>
                                    <option value="Link" ${selectedMaterialType == 'Link' ? 'selected' : ''}>Link</option>
                                </select>
                            </div>
                            <div>
                                <label>Sort</label>
                                <select name="sort">
                                    <option value="sequence" ${selectedSort == 'sequence' ? 'selected' : ''}>Chapter Order</option>
                                    <option value="latest" ${selectedSort == 'latest' ? 'selected' : ''}>Latest first</option>
                                    <option value="oldest" ${selectedSort == 'oldest' ? 'selected' : ''}>Oldest first</option>
                                    <option value="title" ${selectedSort == 'title' ? 'selected' : ''}>Title A-Z</option>
                                    <option value="type" ${selectedSort == 'type' ? 'selected' : ''}>Type</option>
                                </select>
                            </div>
                            <div class="mat-filter-actions">
                                <button class="sv-btn primary" type="submit">Apply</button>
                                <a href="${pageContext.request.contextPath}/student/materials" class="sv-btn">Reset</a>
                            </div>
                        </form>

                        <div class="mat-summary">
                            <div class="mat-summary-item"><strong>${visibleCourseCount}</strong><span>Course(s)</span></div>
                            <div class="mat-summary-item"><strong>${totalMaterials}</strong><span>Material(s)</span></div>
                            <div class="mat-summary-item"><strong>${totalViewedMaterials}</strong><span>Viewed</span></div>
                        </div>
                    </div>
                </section>

                <section class="sv-card">
                    <div class="sv-card-head"><h3>Your Material Library</h3></div>
                    <div class="sv-card-body">
                        <c:forEach var="e" items="${displayEnrollments}">
                            <div class="mat-course">
                                <div class="mat-course-head">
                                    <div>
                                        <h4><i class="fas fa-book"></i> ${e.courseName}</h4>
                                        <p class="sv-course-line">Paid access active</p>
                                    </div>
                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${e.enrollmentId}&tab=learning">Open Learning Hub</a>
                                </div>

                                <c:set var="courseMaterials" value="${materialsByCourse[e.courseId]}"/>
                                <c:choose>
                                    <c:when test="${empty courseMaterials}">
                                        <div class="empty-state-box sv-empty-inline"><p>No materials available yet for this course.</p></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="mat-grid">
                                            <c:forEach var="m" items="${courseMaterials}">
                                                <c:set var="viewedInCourse" value="${viewedMaterialIdsByCourse[e.courseId].contains(m.materialId)}"/>
                                                <article class="mat-card">
                                                    <div class="mat-card-top">
                                                        <span class="assessment-type-badge assessment-type-Assignment">${m.materialType}</span>
                                                        <span class="sv-course-line"><c:choose><c:when test="${not empty m.displayOrder}">Ch ${m.displayOrder}</c:when><c:otherwise>${m.versionNumber}</c:otherwise></c:choose></span>
                                                    </div>
                                                    <h5>${m.title}</h5>
                                                    <c:if test="${not empty m.description}"><p>${m.description}</p></c:if>
                                                    <div class="mat-meta">
                                                        <span><i class="fas fa-calendar-alt"></i> <c:choose><c:when test="${not empty m.uploadDate}">${m.uploadDate.toLocalDate()}</c:when><c:otherwise>-</c:otherwise></c:choose></span>
                                                        <span><i class="fas fa-circle-check"></i> ${viewedInCourse ? 'Viewed' : 'Pending'}</span>
                                                    </div>
                                                    <div class="mat-actions">
                                                        <a class="sv-btn" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${m.materialId}">${viewedInCourse ? 'Review' : 'Open'}</a>
                                                        <c:if test="${m.materialType != 'Link'}"><a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=download&id=${m.materialId}">Download</a></c:if>
                                                    </div>
                                                </article>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>

                        <c:if test="${empty displayEnrollments}">
                            <div class="empty-state-box">
                                <i class="fas fa-search"></i>
                                <p>No courses matched your selected filter.</p>
                                <a href="${pageContext.request.contextPath}/student/materials" class="sv-btn">Reset Filters</a>
                            </div>
                        </c:if>
                    </div>
                </section>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

