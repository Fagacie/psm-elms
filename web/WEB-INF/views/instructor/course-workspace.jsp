<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Workspace - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-materials.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Workspace"/>
    <jsp:param name="pageSubtitle" value="Manage the full course flow from one professional workspace"/>
</jsp:include>

<c:set var="activeInstructorPage" value="courses"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper course-workspace-page">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Workspace</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Course Workspace</p>
                <h2><c:out value="${selectedCourse.courseName}"/></h2>
                <p>One workspace for the course lifecycle. Use the overview for quick decisions, then jump into materials, assessments, students, or analytics without selecting the course again.</p>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to My Courses
                </a>
            </div>
        </section>

        <section class="workspace-hero-card">
            <div class="workspace-hero-top">
                <div class="workspace-hero-media">
                    <c:choose>
                        <c:when test="${not empty selectedCourse.courseBanner}">
                            <img src="${selectedCourse.courseBanner}" alt="${selectedCourse.courseName} banner">
                        </c:when>
                        <c:otherwise>
                            <div class="workspace-hero-placeholder">
                                <i class="fas fa-layer-group"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="workspace-hero-copy">
                    <div class="workspace-title-row">
                        <h3><c:out value="${selectedCourse.courseName}"/></h3>
                        <span class="status-badge status-${selectedCourse.status}"><c:out value="${selectedCourse.status}"/></span>
                    </div>
                    <p class="workspace-description">
                        <c:choose>
                            <c:when test="${not empty selectedCourse.description}">
                                <c:out value="${selectedCourse.description}"/>
                            </c:when>
                            <c:otherwise>
                                This course has no description yet.
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <div class="workspace-meta-row">
                        <span><i class="fas fa-tag"></i> <c:out value="${empty selectedCourse.category ? 'General' : selectedCourse.category}"/></span>
                        <span><i class="fas fa-signal"></i> <c:out value="${selectedCourse.level}"/></span>
                        <span><i class="fas fa-clock"></i> <c:out value="${selectedCourse.displayDuration}"/></span>
                        <span><i class="fas fa-calendar-alt"></i> <c:out value="${not empty selectedCourse.updatedAt ? selectedCourse.updatedAt.toLocalDate() : (not empty selectedCourse.createdAt ? selectedCourse.createdAt.toLocalDate() : '-') }"/></span>
                    </div>
                </div>
            </div>

            <div class="workspace-kpi-grid">
                <div class="workspace-kpi-card">
                    <strong>${totalStudents}</strong>
                    <span>Students enrolled</span>
                </div>
                <div class="workspace-kpi-card">
                    <strong>${publishedMaterials}</strong>
                    <span>Materials count</span>
                </div>
                <div class="workspace-kpi-card">
                    <strong>${assessmentCount}</strong>
                    <span>Assessments count</span>
                </div>
                <div class="workspace-kpi-card">
                    <strong><fmt:formatNumber value="${completionRate}" maxFractionDigits="0"/>%</strong>
                    <span>Completion rate</span>
                </div>
            </div>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/></div>
        </c:if>

        <section class="workspace-tabs" aria-label="Course workspace tabs">
            <button type="button" class="workspace-tab is-active" data-workspace-tab="overview">Overview</button>
            <button type="button" class="workspace-tab" data-workspace-tab="materials">Materials</button>
            <button type="button" class="workspace-tab" data-workspace-tab="assessments">Assessments</button>
            <button type="button" class="workspace-tab" data-workspace-tab="students">Students</button>
            <button type="button" class="workspace-tab" data-workspace-tab="analytics">Analytics</button>
        </section>

        <section class="workspace-panel is-active" data-workspace-panel="overview">
            <div class="workspace-overview-grid">
                <article class="workspace-panel-card workspace-metrics-card">
                    <div class="section-header">
                        <div>
                            <h3 class="section-title">Overview</h3>
                            <p class="section-caption">Quick stats and fast actions for day-to-day course operations.</p>
                        </div>
                    </div>
                    <div class="workspace-overview-metrics">
                        <div class="overview-metric">
                            <span>Total Students</span>
                            <strong>${totalStudents}</strong>
                        </div>
                        <div class="overview-metric">
                            <span>Completion Rate</span>
                            <strong><fmt:formatNumber value="${completionRate}" maxFractionDigits="0"/>%</strong>
                        </div>
                        <div class="overview-metric">
                            <span>Published Materials</span>
                            <strong>${publishedMaterials}</strong>
                        </div>
                        <div class="overview-metric">
                            <span>Pending Grading</span>
                            <strong>${pendingGrading}</strong>
                        </div>
                    </div>
                </article>

                <article class="workspace-panel-card">
                    <div class="section-header">
                        <div>
                            <h3 class="section-title">Quick Actions</h3>
                            <p class="section-caption">Jump straight into the next task for this course.</p>
                        </div>
                    </div>
                    <div class="workspace-action-grid">
                        <a class="workspace-action-card" href="#materials">
                            <i class="fas fa-plus-circle"></i>
                            <strong>Add Material</strong>
                            <span>Upload learning content and keep the sequence organized.</span>
                        </a>
                        <a class="workspace-action-card" href="${pageContext.request.contextPath}/instructor/assessments?view=drafts&courseId=${selectedCourse.courseId}">
                            <i class="fas fa-clipboard-list"></i>
                            <strong>New Assessment</strong>
                            <span>Create a quiz, exam, or assignment for this course.</span>
                        </a>
                        <a class="workspace-action-card" href="#students">
                            <i class="fas fa-users"></i>
                            <strong>View Students</strong>
                            <span>Check enrollment and learner status in one place.</span>
                        </a>
                    </div>
                </article>
            </div>
        </section>

        <section class="workspace-panel" data-workspace-panel="materials" id="materials">
            <div class="workspace-panel-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Materials</h3>
                        <p class="section-caption">Manage published and archived learning assets directly inside the workspace.</p>
                    </div>
                    <div class="workspace-header-actions">
                        <button type="button" class="btn btn-primary btn-sm" onclick="openUploadModal()">
                            <i class="fas fa-plus"></i> Add Material
                        </button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="scrollToMaterialsOrder()">
                            <i class="fas fa-sort"></i> Manage Order
                        </button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="scrollToBulkActions()">
                            <i class="fas fa-layer-group"></i> Bulk Actions
                        </button>
                    </div>
                </div>
                <div class="workspace-materials-summary">
                    <div class="workspace-summary-item">
                        <strong>${publishedMaterials}</strong>
                        <span>Active materials</span>
                    </div>
                    <div class="workspace-summary-item">
                        <strong>${empty deletedMaterials ? 0 : deletedMaterials.size()}</strong>
                        <span>Archived materials</span>
                    </div>
                </div>

                <div class="workspace-materials-toolbar" id="materials-order-anchor">
                    <div>
                        <h4>Order and publish controls</h4>
                        <p>Use the order arrows to keep the sequence stable. Archive hides items from students, restore makes them visible again.</p>
                    </div>
                    <div class="workspace-toolbar-note">
                        <i class="fas fa-circle-info"></i>
                        <span>Replace file and type changes still happen in the edit dialog.</span>
                    </div>
                </div>

                <div class="workspace-bulk-actions" id="bulk-actions-anchor">
                    <div>
                        <h4>Bulk actions</h4>
                        <p>Select multiple materials from the active or archived tables and apply one action.</p>
                    </div>
                    <div class="workspace-bulk-actions-grid">
                        <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('activeMaterialIds', true)">Select Active</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('activeMaterialIds', false)">Clear Active</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('archivedMaterialIds', true)">Select Archived</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('archivedMaterialIds', false)">Clear Archived</button>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty materials}">
                        <div class="empty-state-box workspace-empty-box">
                            <i class="fas fa-folder-open"></i>
                            <p>No active materials uploaded for this course yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <form id="activeBulkForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" class="workspace-bulk-form">
                            <input type="hidden" name="action" value="bulkArchive">
                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                            <div class="workspace-bulk-submit-row">
                                <span class="workspace-bulk-help">Archive selected items to hide them from students.</span>
                                <button type="submit" class="btn btn-secondary btn-sm"><i class="fas fa-archive"></i> Archive Selected</button>
                            </div>
                        </form>

                        <div class="materials-table-wrap workspace-materials-table-wrap">
                            <table class="materials-table workspace-materials-table">
                                    <thead>
                                    <tr>
                                        <th class="material-select-head">
                                            <input type="checkbox" aria-label="Select all active materials" onclick="selectAllMaterials('activeMaterialIds', this.checked)">
                                        </th>
                                        <th>Material</th>
                                        <th>Type</th>
                                        <th>Order</th>
                                        <th>Version</th>
                                        <th>Uploaded</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="material" items="${materials}">
                                        <tr>
                                            <td class="material-select-cell">
                                                <input type="checkbox" name="materialIds" value="${material.materialId}" form="activeBulkForm" class="material-select-input activeMaterialIds">
                                            </td>
                                            <td>
                                                <div class="material-cell">
                                                    <div class="material-cell-title"><c:out value="${material.title}"/></div>
                                                    <div class="material-cell-subtitle">
                                                        <c:choose>
                                                            <c:when test="${not empty material.description && material.description.length() > 90}">
                                                                <c:out value="${material.description.substring(0, 90)}"/>...
                                                            </c:when>
                                                            <c:when test="${not empty material.description}">
                                                                <c:out value="${material.description}"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                Course asset for this workspace.
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><span class="type-badge type-${material.materialType}"><c:out value="${material.materialType}"/></span></td>
                                            <td>
                                                <div class="workspace-order-cell">
                                                    <span class="table-pill"><c:out value="${material.displayOrder}" default="N/A"/></span>
                                                    <div class="workspace-order-buttons">
                                                        <form method="post" action="${pageContext.request.contextPath}/instructor/materials">
                                                            <input type="hidden" name="action" value="reorder">
                                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                            <input type="hidden" name="materialId" value="${material.materialId}">
                                                            <input type="hidden" name="direction" value="up">
                                                            <button type="submit" class="icon-btn" aria-label="Move material up"><i class="fas fa-chevron-up"></i></button>
                                                        </form>
                                                        <form method="post" action="${pageContext.request.contextPath}/instructor/materials">
                                                            <input type="hidden" name="action" value="reorder">
                                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                            <input type="hidden" name="materialId" value="${material.materialId}">
                                                            <input type="hidden" name="direction" value="down">
                                                            <button type="submit" class="icon-btn" aria-label="Move material down"><i class="fas fa-chevron-down"></i></button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><span class="table-pill table-pill-muted"><c:out value="${material.versionNumber}" default="N/A"/></span></td>
                                            <td>
                                                <span class="table-muted">
                                                    <c:choose>
                                                        <c:when test="${not empty material.uploadDate}">
                                                            ${material.uploadDate.toLocalDate()}
                                                        </c:when>
                                                        <c:otherwise>-</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a href="${material.filePath}" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-sm"><i class="fas fa-eye"></i> View</a>
                                                    <button type="button" class="btn btn-secondary btn-sm" onclick="openEditMaterialModal(this, false)"
                                                            data-material-id="${material.materialId}"
                                                            data-title="<c:out value='${material.title}'/>"
                                                            data-type="<c:out value='${material.materialType}'/>"
                                                            data-version="<c:out value='${material.versionNumber}'/>"
                                                            data-order="<c:out value='${material.displayOrder}'/>"
                                                            data-description="<c:out value='${material.description}'/>"
                                                            data-external-url="${material.materialType == 'Link' ? material.filePath : ''}">
                                                        <i class="fas fa-edit"></i> Edit
                                                    </button>
                                                    <button type="button" class="btn btn-secondary btn-sm" onclick="openEditMaterialModal(this, true)"
                                                            data-material-id="${material.materialId}"
                                                            data-title="<c:out value='${material.title}'/>"
                                                            data-type="<c:out value='${material.materialType}'/>"
                                                            data-version="<c:out value='${material.versionNumber}'/>"
                                                            data-order="<c:out value='${material.displayOrder}'/>"
                                                            data-description="<c:out value='${material.description}'/>"
                                                            data-external-url="${material.materialType == 'Link' ? material.filePath : ''}">
                                                        <i class="fas fa-file-arrow-up"></i> Replace File
                                                    </button>
                                                    <a href="${pageContext.request.contextPath}/instructor/materials?action=delete&id=${material.materialId}&courseId=${selectedCourse.courseId}" class="btn btn-secondary btn-sm workspace-danger-link" onclick="return confirm('Archive this material?');">
                                                        <i class="fas fa-eye-slash"></i> Unpublish
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="archived-block">
                    <div class="section-header archived-section-header">
                        <div>
                            <h4 class="archived-title">Archived Materials</h4>
                            <p class="section-caption">Published state is controlled by archive and restore actions.</p>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty deletedMaterials}">
                            <p class="archived-empty">No archived materials.</p>
                        </c:when>
                        <c:otherwise>
                            <form id="archivedBulkForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" class="workspace-bulk-form">
                                <input type="hidden" name="action" value="bulkRestore">
                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                <div class="workspace-bulk-submit-row">
                                    <span class="workspace-bulk-help">Restore selected items to publish them again.</span>
                                    <button type="submit" class="btn btn-secondary btn-sm"><i class="fas fa-undo"></i> Restore Selected</button>
                                </div>
                            </form>

                            <div class="archived-table-wrap">
                                <table class="archived-table workspace-archived-table">
                                        <thead>
                                        <tr>
                                            <th class="material-select-head">
                                                <input type="checkbox" aria-label="Select all archived materials" onclick="selectAllMaterials('archivedMaterialIds', this.checked)">
                                            </th>
                                            <th>Material</th>
                                            <th>Type</th>
                                            <th>Order</th>
                                            <th>Version</th>
                                            <th>Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="material" items="${deletedMaterials}">
                                            <tr>
                                                <td class="material-select-cell">
                                                    <input type="checkbox" name="materialIds" value="${material.materialId}" form="archivedBulkForm" class="material-select-input archivedMaterialIds">
                                                </td>
                                                <td>
                                                    <div class="material-cell">
                                                        <div class="material-cell-title"><c:out value="${material.title}"/></div>
                                                        <div class="material-cell-subtitle">Archived from this course</div>
                                                    </div>
                                                </td>
                                                <td><span class="type-badge type-${material.materialType}"><c:out value="${material.materialType}"/></span></td>
                                                <td><span class="table-pill"><c:out value="${material.displayOrder}" default="N/A"/></span></td>
                                                <td><span class="table-pill table-pill-muted"><c:out value="${material.versionNumber}" default="N/A"/></span></td>
                                                <td>
                                                    <div class="row-actions">
                                                        <a href="${pageContext.request.contextPath}/instructor/materials?action=restore&id=${material.materialId}&courseId=${selectedCourse.courseId}" class="btn btn-secondary btn-sm">
                                                            <i class="fas fa-eye"></i> Publish
                                                        </a>
                                                        <a href="${material.filePath}" target="_blank" rel="noopener noreferrer" class="btn btn-secondary btn-sm">
                                                            <i class="fas fa-up-right-from-square"></i> View
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </section>

        <section class="workspace-panel" data-workspace-panel="assessments">
            <div class="workspace-panel-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Assessments</h3>
                        <p class="section-caption">Assessment coverage and grading status for this course.</p>
                    </div>
                    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=drafts&courseId=${selectedCourse.courseId}">
                        <i class="fas fa-pen-ruler"></i> Open Assessments
                    </a>
                </div>
                <c:choose>
                    <c:when test="${empty assessments}">
                        <div class="empty-state-box workspace-empty-box">
                            <i class="fas fa-clipboard-list"></i>
                            <p>No assessments created for this course yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="workspace-list-grid">
                            <c:forEach var="assessment" items="${assessments}">
                                <article class="workspace-list-card">
                                    <div class="workspace-list-head">
                                        <div>
                                            <strong><c:out value="${assessment.title}"/></strong>
                                            <span><c:out value="${assessment.type}"/></span>
                                        </div>
                                        <span class="assessment-type-badge type-${assessment.type}">${assessment.type}</span>
                                    </div>
                                    <p>
                                        <c:out value="${not empty assessment.totalMarks ? assessment.totalMarks : 'N/A'}"/> marks ·
                                        <c:out value="${not empty assessment.duration ? assessment.duration : 'Unlimited'}"/> mins ·
                                        <c:out value="${not empty assessment.gradingMode ? assessment.gradingMode : (assessment.type == 'Assignment' ? 'manual' : 'auto')}"/> grading
                                    </p>
                                    <div class="workspace-list-actions">
                                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}&assessmentId=${assessment.assessmentId}">Manage</a>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <section class="workspace-panel" data-workspace-panel="students" id="students">
            <div class="workspace-panel-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Students</h3>
                        <p class="section-caption">Enrolled learners and their current learning progress.</p>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${empty enrollments}">
                        <div class="empty-state-box workspace-empty-box">
                            <i class="fas fa-user-slash"></i>
                            <p>No students are enrolled in this course yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-container">
                            <table class="data-table workspace-table">
                                <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Status</th>
                                    <th>Progress</th>
                                    <th>Enrolled</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="enrollment" items="${enrollments}">
                                    <tr>
                                        <td><strong><c:out value="${enrollment.studentName}"/></strong><br><span class="table-muted"><c:out value="${enrollment.studentEmail}"/></span></td>
                                        <td><span class="status-badge status-${fn:toLowerCase(enrollment.status)}"><c:out value="${enrollment.status}"/></span></td>
                                        <td><c:out value="${not empty enrollment.progress ? enrollment.progress : 0}"/>%</td>
                                        <td><c:out value="${not empty enrollment.enrollmentDate ? enrollment.enrollmentDate : '-'}"/></td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <section class="workspace-panel" data-workspace-panel="analytics">
            <div class="workspace-panel-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Analytics</h3>
                        <p class="section-caption">A compact snapshot of course engagement and completion.</p>
                    </div>
                </div>
                <div class="workspace-analytics-grid">
                    <div class="workspace-analytics-card">
                        <span>Completed Students</span>
                        <strong>${completedStudents}</strong>
                    </div>
                    <div class="workspace-analytics-card">
                        <span>Active Students</span>
                        <strong>${totalStudents - completedStudents}</strong>
                    </div>
                    <div class="workspace-analytics-card">
                        <span>Average Progress</span>
                        <strong><fmt:formatNumber value="${averageProgress}" maxFractionDigits="0"/>%</strong>
                    </div>
                    <div class="workspace-analytics-card">
                        <span>Pending Grading</span>
                        <strong>${pendingGrading}</strong>
                    </div>
                </div>
                <div class="workspace-analytics-note">
                    Completion rate is based on enrolled students whose state has been synchronized into the existing enrollment progress model.
                </div>
            </div>
        </section>
    </div>
</main>

<!-- Upload Material Modal -->
<div id="uploadModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Upload New Material</h3>
            <button class="modal-close" onclick="closeUploadModal()">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="modal-body">
            <p class="modal-subtitle">Course: <strong><c:out value="${selectedCourse.courseName}"/></strong></p>
            <p class="modal-subtitle modal-subtitle-spaced">Set chapter/order number to control learning flow. Leave empty to append at the end.</p>
            <form id="uploadForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                <div class="upload-form-grid">
                    <div class="field">
                        <label>Title *</label>
                        <input type="text" name="title" placeholder="Material title" required>
                    </div>
                    <div class="field">
                        <label>Type *</label>
                        <select name="materialType" id="materialType" required>
                            <option value="">Select type</option>
                            <option value="PDF">PDF</option>
                            <option value="Video">Video</option>
                            <option value="Slides">Slides</option>
                            <option value="Link">Link</option>
                        </select>
                        <small id="uploadTypeHint" class="field-hint">Select a type to see allowed file formats.</small>
                    </div>
                    <div class="field">
                        <label>Version</label>
                        <input type="text" name="versionNumber" placeholder="e.g. v1.0">
                    </div>
                    <div class="field">
                        <label>Chapter / Order</label>
                        <input type="number" name="displayOrder" min="1" placeholder="e.g. 1">
                    </div>
                    <div class="field">
                        <label>File</label>
                        <input type="file" name="materialFile" id="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3">
                        <small id="uploadFileHint" class="field-hint">Allowed: PDF, DOC/DOCX, TXT, PPT/PPTX, ZIP, MP4/WEBM/MOV/M4V, MP3 (max 50MB).</small>
                    </div>
                    <div class="field">
                        <label>External URL (for Link type)</label>
                        <input type="url" name="externalUrl" id="externalUrl" placeholder="https://example.com/resource">
                        <small class="field-hint">Use only full HTTP/HTTPS links.</small>
                    </div>
                    <div class="field full">
                        <label>Description</label>
                        <textarea name="description" placeholder="Optional description" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeUploadModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-upload"></i> Publish Material</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div id="editMaterialModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Edit Material</h3>
            <button class="modal-close" onclick="closeEditMaterialModal()">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="modal-body">
            <p class="modal-subtitle">Course: <strong><c:out value="${selectedCourse.courseName}"/></strong></p>
            <form id="editMaterialForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="materialId" id="editMaterialId">
                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                <div class="upload-form-grid">
                    <div class="field">
                        <label>Title *</label>
                        <input id="editTitle" type="text" name="title" required>
                    </div>
                    <div class="field">
                        <label>Type *</label>
                        <select id="editType" name="materialType" required>
                            <option value="PDF">PDF</option>
                            <option value="Video">Video</option>
                            <option value="Slides">Slides</option>
                            <option value="Link">Link</option>
                        </select>
                        <small id="editTypeHint" class="field-hint">Update type carefully to avoid format mismatch.</small>
                    </div>
                    <div class="field">
                        <label>Version</label>
                        <input id="editVersion" type="text" name="versionNumber">
                    </div>
                    <div class="field">
                        <label>Chapter / Order</label>
                        <input id="editOrder" type="number" name="displayOrder" min="1">
                    </div>
                    <div class="field">
                        <label>Replace File</label>
                        <input id="editFile" type="file" name="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3">
                        <small id="editFileHint" class="field-hint">Upload a replacement only if needed. Current file remains otherwise.</small>
                    </div>
                    <div class="field">
                        <label>External URL (for Link type)</label>
                        <input id="editExternalUrl" type="url" name="externalUrl" placeholder="https://example.com/resource">
                    </div>
                    <div class="field full">
                        <label>Description</label>
                        <textarea id="editDescription" name="description" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeEditMaterialModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        const tabs = Array.from(document.querySelectorAll('[data-workspace-tab]'));
        const panels = Array.from(document.querySelectorAll('[data-workspace-panel]'));

        function activate(tabName) {
            tabs.forEach(function (tab) {
                const active = tab.getAttribute('data-workspace-tab') === tabName;
                tab.classList.toggle('is-active', active);
                tab.setAttribute('aria-selected', active ? 'true' : 'false');
            });
            panels.forEach(function (panel) {
                panel.classList.toggle('is-active', panel.getAttribute('data-workspace-panel') === tabName);
            });
        }

        tabs.forEach(function (tab) {
            tab.addEventListener('click', function () {
                activate(tab.getAttribute('data-workspace-tab'));
            });
        });

        const initialTab = window.location.hash ? window.location.hash.replace('#', '') : 'overview';
        activate(initialTab);

        window.addEventListener('hashchange', function () {
            const nextTab = window.location.hash ? window.location.hash.replace('#', '') : 'overview';
            activate(nextTab);
        });
    })();

    function openUploadModal() {
        const modal = document.getElementById('uploadModal');
        if (!modal) return;
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
    }

    function closeUploadModal() {
        const modal = document.getElementById('uploadModal');
        if (!modal) return;
        modal.classList.remove('show');
        document.body.style.overflow = 'auto';
        const form = document.getElementById('uploadForm');
        if (form) form.reset();
    }

    function openEditMaterialModal(button, focusFile) {
        document.getElementById('editMaterialId').value = button.dataset.materialId || '';
        document.getElementById('editTitle').value = button.dataset.title || '';
        document.getElementById('editType').value = button.dataset.type || 'PDF';
        document.getElementById('editVersion').value = button.dataset.version || '';
        document.getElementById('editOrder').value = button.dataset.order || '';
        document.getElementById('editDescription').value = button.dataset.description || '';
        document.getElementById('editExternalUrl').value = button.dataset.externalUrl || '';
        document.getElementById('editFile').value = '';

        const modal = document.getElementById('editMaterialModal');
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';

        if (focusFile) {
            window.setTimeout(function () {
                const fileInput = document.getElementById('editFile');
                if (fileInput) fileInput.focus();
            }, 0);
        }
    }

    function closeEditMaterialModal() {
        const modal = document.getElementById('editMaterialModal');
        if (!modal) return;
        modal.classList.remove('show');
        document.body.style.overflow = 'auto';
        const fileInput = document.getElementById('editFile');
        if (fileInput) fileInput.value = '';
    }

    function selectAllMaterials(className, checked) {
        document.querySelectorAll('.' + className).forEach(function (checkbox) {
            checkbox.checked = checked;
        });
    }

    function scrollToMaterialsOrder() {
        const anchor = document.getElementById('materials-order-anchor');
        if (anchor) anchor.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    function scrollToBulkActions() {
        const anchor = document.getElementById('bulk-actions-anchor');
        if (anchor) anchor.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    window.addEventListener('click', function (event) {
        const uploadModal = document.getElementById('uploadModal');
        const editModal = document.getElementById('editMaterialModal');
        if (uploadModal && event.target === uploadModal) {
            closeUploadModal();
        }
        if (editModal && event.target === editModal) {
            closeEditMaterialModal();
        }
    });

    window.addEventListener('keydown', function (event) {
        if (event.key !== 'Escape') return;
        const uploadModal = document.getElementById('uploadModal');
        const editModal = document.getElementById('editMaterialModal');
        if (uploadModal && uploadModal.classList.contains('show')) {
            closeUploadModal();
        }
        if (editModal && editModal.classList.contains('show')) {
            closeEditMaterialModal();
        }
    });

    (function () {
        const type = document.getElementById('materialType');
        const file = document.getElementById('materialFile');
        const url = document.getElementById('externalUrl');
        const typeHint = document.getElementById('uploadTypeHint');
        const fileHint = document.getElementById('uploadFileHint');
        const editType = document.getElementById('editType');
        const editFile = document.getElementById('editFile');
        const editUrl = document.getElementById('editExternalUrl');
        const editTypeHint = document.getElementById('editTypeHint');
        const editFileHint = document.getElementById('editFileHint');

        const typeMeta = {
            PDF: {
                accept: '.pdf,.doc,.docx,.txt',
                fileHint: 'Allowed: PDF, DOC, DOCX, TXT (max 50MB).',
                typeHint: 'Best for notes, handouts, and reading packs.'
            },
            Video: {
                accept: '.mp4,.webm,.mov,.m4v,.mp3',
                fileHint: 'Allowed: MP4, WEBM, MOV, M4V, MP3 (max 50MB).',
                typeHint: 'Best for lectures, demonstrations, and audio explainers.'
            },
            Slides: {
                accept: '.ppt,.pptx,.pdf,.zip',
                fileHint: 'Allowed: PPT, PPTX, PDF, ZIP (max 50MB).',
                typeHint: 'Best for presentation decks and session slide packs.'
            },
            Link: {
                accept: '',
                fileHint: 'No file needed for links. Provide a valid URL.',
                typeHint: 'Best for YouTube, docs, external labs, and reference pages.'
            }
        };

        const applyTypeRules = function (selectedType, fileInput, urlInput, typeHintNode, fileHintNode) {
            const meta = typeMeta[selectedType] || null;
            const isLink = selectedType === 'Link';

            if (fileInput) {
                fileInput.required = !!selectedType && !isLink;
                fileInput.disabled = !!selectedType && isLink;
                fileInput.accept = meta ? meta.accept : '.pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3';
            }
            if (urlInput) {
                urlInput.required = !!selectedType && isLink;
                urlInput.disabled = !!selectedType && !isLink;
            }
            if (typeHintNode) {
                typeHintNode.textContent = meta ? meta.typeHint : 'Select a type to see allowed file formats.';
            }
            if (fileHintNode) {
                fileHintNode.textContent = meta ? meta.fileHint : 'Allowed: PDF, DOC/DOCX, TXT, PPT/PPTX, ZIP, MP4/WEBM/MOV/M4V, MP3 (max 50MB).';
            }
        };

        const syncRequired = function () {
            const selected = type ? type.value : '';
            applyTypeRules(selected, file, url, typeHint, fileHint);
        };

        const syncEditRequired = function () {
            const selected = editType ? editType.value : '';
            applyTypeRules(selected, editFile, editUrl, editTypeHint, editFileHint);
        };

        if (type) type.addEventListener('change', syncRequired);
        if (editType) editType.addEventListener('change', syncEditRequired);
        syncRequired();
        syncEditRequired();
    })();
</script>
</body>
</html>
