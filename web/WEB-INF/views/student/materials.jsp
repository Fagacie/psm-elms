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
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/materials-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Learning Materials"/>
<c:set var="topbarSubtitle" value="Organized by your paid courses"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="materials"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

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
                                                        <c:choose>
                                                            <c:when test="${m.materialType == 'Link'}">
                                                                <a class="sv-btn" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${m.materialId}">Open Link</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${m.materialId}">${viewedInCourse ? 'Review in App' : 'Preview in App'}</a>
                                                                <a class="sv-btn" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${m.materialId}">Open New Tab</a>
                                                                <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=download&id=${m.materialId}">Download</a>
                                                            </c:otherwise>
                                                        </c:choose>
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

