<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Materials - Student</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-details.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/materials.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<nav class="top-navbar">
    <div class="top-navbar-inner">
        <div class="top-navbar-left">
            <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                <span class="logo-text">PSM</span><span class="logo-subtext">E-Learning</span>
            </a>
            <h1 class="page-title-nav"><i class="fas fa-folder-open"></i> Learning Materials</h1>
        </div>
        <div class="top-navbar-right">
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </div>
</nav>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item"><i class="fas fa-home"></i><span>Dashboard</span></a>
        <a href="${pageContext.request.contextPath}/student/courses" class="nav-item"><i class="fas fa-book"></i><span>Browse Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item"><i class="fas fa-graduation-cap"></i><span>My Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/materials" class="nav-item active"><i class="fas fa-folder-open"></i><span>Materials</span></a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="nav-item"><i class="fas fa-clipboard-list"></i><span>Assessments</span></a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="nav-item"><i class="fas fa-certificate"></i><span>Certificates</span></a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item"><i class="fas fa-user"></i><span>Profile</span></a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Home</a>
            <span class="separator">/</span>
            <span>Learning Materials</span>
        </div>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>

        <c:choose>
            <c:when test="${empty paidEnrollments}">
                <div class="section-card">
                    <div class="empty-inline">
                        <i class="fas fa-graduation-cap"></i>
                        <p style="margin-top: 16px; font-size: 16px; font-weight: 500;">No Paid Enrollments</p>
                        <p>You don't have any paid enrollments yet. Complete payment to access course materials.</p>
                        <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-primary" style="margin-top: 16px;">
                            <i class="fas fa-book"></i> Browse Courses
                        </a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="section-card">
                    <div class="materials-toolbar">
                        <form method="get" action="${pageContext.request.contextPath}/student/materials" class="materials-filter-form">
                            <label for="courseId"><strong>View By Course</strong></label>
                            <select id="courseId" name="courseId">
                                <option value="">All paid courses</option>
                                <c:forEach var="e" items="${paidEnrollments}">
                                    <option value="${e.courseId}" <c:if test="${selectedCourseId == e.courseId}">selected</c:if>>
                                        ${e.courseName}
                                    </option>
                                </c:forEach>
                            </select>
                            <input type="text" name="keyword" value="${searchKeyword}" placeholder="Search by title, description...">
                            <select name="materialType">
                                <option value="">All Types</option>
                                <option value="PDF" ${selectedMaterialType == 'PDF' ? 'selected' : ''}>PDF</option>
                                <option value="Video" ${selectedMaterialType == 'Video' ? 'selected' : ''}>Video</option>
                                <option value="Slides" ${selectedMaterialType == 'Slides' ? 'selected' : ''}>Slides</option>
                                <option value="Link" ${selectedMaterialType == 'Link' ? 'selected' : ''}>Link</option>
                            </select>
                            <select name="sort">
                                <option value="sequence" ${selectedSort == 'sequence' ? 'selected' : ''}>Chapter Order</option>
                                <option value="latest" ${selectedSort == 'latest' ? 'selected' : ''}>Latest first</option>
                                <option value="oldest" ${selectedSort == 'oldest' ? 'selected' : ''}>Oldest first</option>
                                <option value="title" ${selectedSort == 'title' ? 'selected' : ''}>Title A-Z</option>
                                <option value="type" ${selectedSort == 'type' ? 'selected' : ''}>Type</option>
                            </select>
                            <button class="btn btn-primary btn-sm" type="submit"><i class="fas fa-filter"></i> Apply</button>
                            <a href="${pageContext.request.contextPath}/student/materials" class="btn btn-secondary btn-sm">Reset</a>
                        </form>
                        <div class="materials-summary">
                            <div class="summary-item">
                                <div class="summary-value">${visibleCourseCount}</div>
                                <div class="summary-label">Course(s)</div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-value">${totalMaterials}</div>
                                <div class="summary-label">Material(s)</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="section-card">
                    <h3 class="section-title-lg"><i class="fas fa-book-open"></i> Your Learning Library</h3>
                    <c:forEach var="e" items="${displayEnrollments}">
                        <div class="course-material-block">
                            <div class="course-material-header">
                                <div>
                                    <h4><i class="fas fa-book"></i> ${e.courseName}</h4>
                                    <div class="course-material-meta"><i class="fas fa-check-circle" style="color: var(--color-success);"></i> Paid Access</div>
                                </div>
                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/course-details?id=${e.courseId}">
                                    <i class="fas fa-book-open"></i> Course
                                </a>
                            </div>

                            <c:set var="courseMaterials" value="${materialsByCourse[e.courseId]}"/>
                            <c:choose>
                                <c:when test="${empty courseMaterials}">
                                    <div class="empty-inline">
                                        <i class="fas fa-inbox"></i>
                                        <p>No materials available yet for this course.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="material-card-grid">
                                        <c:forEach var="m" items="${courseMaterials}">
                                            <article class="material-card">
                                                <div class="material-card-top">
                                                    <span class="material-type-badge material-type-${m.materialType}">
                                                        <c:choose>
                                                            <c:when test="${m.materialType == 'PDF'}">
                                                                <i class="fas fa-file-pdf"></i>
                                                            </c:when>
                                                            <c:when test="${m.materialType == 'Video'}">
                                                                <i class="fas fa-play-circle"></i>
                                                            </c:when>
                                                            <c:when test="${m.materialType == 'Slides'}">
                                                                <i class="fas fa-file-powerpoint"></i>
                                                            </c:when>
                                                            <c:when test="${m.materialType == 'Link'}">
                                                                <i class="fas fa-link"></i>
                                                            </c:when>
                                                        </c:choose>
                                                        ${m.materialType}
                                                    </span>
                                                    <span class="material-version">
                                                        <c:choose>
                                                            <c:when test="${not empty m.displayOrder}">Ch ${m.displayOrder}</c:when>
                                                            <c:otherwise>${m.versionNumber}</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <h5>${m.title}</h5>
                                                <c:if test="${not empty m.description}">
                                                    <p>${m.description}</p>
                                                </c:if>
                                                <div class="material-meta">
                                                    <span>
                                                        <i class="fas fa-calendar-alt"></i>
                                                        <c:choose>
                                                            <c:when test="${not empty m.uploadDate}">
                                                                ${m.uploadDate.toLocalDate()}
                                                            </c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <div class="material-actions">
                                                    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/materials?action=view&id=${m.materialId}" target="_blank" rel="noopener noreferrer">
                                                        <i class="fas fa-eye"></i> Open
                                                    </a>
                                                    <c:if test="${m.materialType != 'Link'}">
                                                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/materials?action=download&id=${m.materialId}">
                                                            <i class="fas fa-download"></i> Download
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </article>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>

                    <c:if test="${empty displayEnrollments}">
                        <div class="empty-inline">
                            <i class="fas fa-search"></i>
                            <p>No courses matched the selected filter.</p>
                            <a href="${pageContext.request.contextPath}/student/materials" class="btn btn-secondary" style="margin-top: 16px;">
                                <i class="fas fa-redo"></i> Reset Filters
                            </a>
                        </div>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>
</body>
</html>
