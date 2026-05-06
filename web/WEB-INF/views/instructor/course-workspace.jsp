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
</jsp:include>

<c:set var="activeInstructorPage" value="courses"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper course-workspace-page">
        <section class="ins-section-head" style="margin-bottom: 24px;">
            <div style="display: flex; gap: 16px; align-items: center;">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary btn-sm">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
                <h2 style="margin: 0;"><c:out value="${selectedCourse.courseName}"/></h2>
                <span class="status-badge status-${selectedCourse.status}"><c:out value="${selectedCourse.status}"/></span>
            </div>
            <div class="workspace-meta-row" style="margin-top: 12px; display: flex; gap: 16px; color: var(--ins-muted); font-size: 0.9rem;">
                <span><i class="fas fa-tag"></i> <c:out value="${empty selectedCourse.category ? 'General' : selectedCourse.category}"/></span>
                <span><i class="fas fa-signal"></i> <c:out value="${selectedCourse.level}"/></span>
                <span><i class="fas fa-clock"></i> <c:out value="${selectedCourse.displayDuration}"/></span>
                <span><i class="fas fa-calendar-alt"></i> Updated: <c:out value="${not empty selectedCourse.updatedAt ? selectedCourse.updatedAt.toLocalDate() : (not empty selectedCourse.createdAt ? selectedCourse.createdAt.toLocalDate() : '-') }"/></span>
            </div>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/></div>
        </c:if>

        <c:url var="assessmentWorkspaceBaseUrl" value="/instructor/assessments">
            <c:param name="courseId" value="${selectedCourse.courseId}"/>
        </c:url>

        <%-- HEADER KPI GRID --%>
        <section class="workspace-kpi-grid" style="margin-bottom: 24px;">
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
        </section>

        <%-- ACTION BAR --%>
        <section class="ws-action-bar section-card" style="margin-bottom: 32px; padding: 16px 24px; display: flex; gap: 12px; align-items: center; background: var(--ins-surface);">
            <a href="${pageContext.request.contextPath}/instructor/materials?courseId=${selectedCourse.courseId}" class="btn btn-primary">
                <i class="fas fa-folder-open"></i> Material Hub
            </a>
            <a href="${assessmentWorkspaceBaseUrl}&view=dashboard" class="btn btn-secondary">
                <i class="fas fa-clipboard-list"></i> Assessment Hub
            </a>
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('students').scrollIntoView({behavior: 'smooth'})">
                <i class="fas fa-users"></i> View Students
            </button>
        </section>

        <%-- SECTION 1: MATERIALS --%>
        <section class="ins-section" id="materials" style="margin-bottom: 32px;">
            <div class="section-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Course Materials</h3>
                    </div>
                    <div class="workspace-header-actions">
                        <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('activeMaterialIds', true)">Select All</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('activeMaterialIds', false)">Clear</button>
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
                        <form id="activeBulkForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" class="workspace-bulk-form" style="margin-bottom: 16px;">
                            <input type="hidden" name="action" value="bulkArchive">
                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                            <div style="display: flex; gap: 12px; align-items: center;">
                                <button type="submit" class="btn btn-secondary btn-sm"><i class="fas fa-archive"></i> Archive Selected</button>
                            </div>
                        </form>

                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                <tr>
                                    <th style="width: 40px;"></th>
                                    <th>Material</th>
                                    <th>Type</th>
                                    <th>Order</th>
                                    <th>Uploaded</th>
                                    <th>Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="material" items="${materials}">
                                    <tr>
                                        <td>
                                            <input type="checkbox" name="materialIds" value="${material.materialId}" form="activeBulkForm" class="activeMaterialIds">
                                        </td>
                                        <td>
                                            <strong><c:out value="${material.title}"/></strong><br>
                                            <span style="color: var(--ins-muted); font-size: 0.85rem;"><c:out value="${material.description}" default="Course asset"/></span>
                                        </td>
                                        <td><span class="type-badge type-${material.materialType}"><c:out value="${material.materialType}"/></span></td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <span class="table-pill"><c:out value="${material.displayOrder}" default="N/A"/></span>
                                                <div style="display: flex; flex-direction: column; gap: 2px;">
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/materials" style="margin: 0;">
                                                        <input type="hidden" name="action" value="reorder">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <input type="hidden" name="materialId" value="${material.materialId}">
                                                        <input type="hidden" name="direction" value="up">
                                                        <button type="submit" class="icon-btn" style="padding: 2px 4px; background: transparent; border: none; cursor: pointer; color: var(--ins-muted);"><i class="fas fa-chevron-up"></i></button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/materials" style="margin: 0;">
                                                        <input type="hidden" name="action" value="reorder">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <input type="hidden" name="materialId" value="${material.materialId}">
                                                        <input type="hidden" name="direction" value="down">
                                                        <button type="submit" class="icon-btn" style="padding: 2px 4px; background: transparent; border: none; cursor: pointer; color: var(--ins-muted);"><i class="fas fa-chevron-down"></i></button>
                                                    </form>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span style="color: var(--ins-muted);">
                                                <c:choose>
                                                    <c:when test="${not empty material.uploadDate}">${material.uploadDate.toLocalDate()}</c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td>
                                            <div style="display: flex; gap: 8px;">
                                                <a href="${material.filePath}" target="_blank" rel="noopener noreferrer" class="btn btn-secondary btn-sm"><i class="fas fa-eye"></i></a>
                                                <button type="button" class="btn btn-secondary btn-sm" onclick="openEditMaterialModal(this, false)"
                                                        data-material-id="${material.materialId}"
                                                        data-title="<c:out value='${material.title}'/>"
                                                        data-type="<c:out value='${material.materialType}'/>"
                                                        data-order="<c:out value='${material.displayOrder}'/>"
                                                        data-description="<c:out value='${material.description}'/>"
                                                        data-external-url="${material.materialType == 'Link' ? material.filePath : ''}">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                                <button type="button" class="btn btn-secondary btn-sm" onclick="openEditMaterialModal(this, true)"
                                                        data-material-id="${material.materialId}"
                                                        data-title="<c:out value='${material.title}'/>"
                                                        data-type="<c:out value='${material.materialType}'/>"
                                                        data-order="<c:out value='${material.displayOrder}'/>"
                                                        data-description="<c:out value='${material.description}'/>"
                                                        data-external-url="${material.materialType == 'Link' ? material.filePath : ''}">
                                                    <i class="fas fa-file-arrow-up"></i>
                                                </button>
                                                <a href="${pageContext.request.contextPath}/instructor/materials?action=delete&id=${material.materialId}&courseId=${selectedCourse.courseId}" class="btn btn-danger btn-sm" onclick="return confirm('Archive this material?');">
                                                    <i class="fas fa-eye-slash"></i>
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

                <%-- Archived Materials --%>
                <div style="margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--ins-border);">
                    <h4 style="margin: 0 0 16px; color: var(--ins-muted);">Archived Materials</h4>
                    <c:choose>
                        <c:when test="${empty deletedMaterials}">
                            <p style="color: var(--ins-muted); font-size: 0.9rem;">No archived materials.</p>
                        </c:when>
                        <c:otherwise>
                            <form id="archivedBulkForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" class="workspace-bulk-form" style="margin-bottom: 16px;">
                                <input type="hidden" name="action" value="bulkRestore">
                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                <div style="display: flex; gap: 12px; align-items: center;">
                                    <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('archivedMaterialIds', true)">Select All</button>
                                    <button type="button" class="btn btn-secondary btn-sm" onclick="selectAllMaterials('archivedMaterialIds', false)">Clear</button>
                                    <button type="submit" class="btn btn-secondary btn-sm"><i class="fas fa-undo"></i> Restore Selected</button>
                                </div>
                            </form>
                            <div class="table-container">
                                <table class="data-table">
                                    <thead>
                                    <tr>
                                        <th style="width: 40px;"></th>
                                        <th>Material</th>
                                        <th>Type</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="material" items="${deletedMaterials}">
                                        <tr>
                                            <td>
                                                <input type="checkbox" name="materialIds" value="${material.materialId}" form="archivedBulkForm" class="archivedMaterialIds">
                                            </td>
                                            <td>
                                                <strong><c:out value="${material.title}"/></strong>
                                            </td>
                                            <td><span class="type-badge type-${material.materialType}"><c:out value="${material.materialType}"/></span></td>
                                            <td>
                                                <div style="display: flex; gap: 8px;">
                                                    <a href="${pageContext.request.contextPath}/instructor/materials?action=restore&id=${material.materialId}&courseId=${selectedCourse.courseId}" class="btn btn-secondary btn-sm">
                                                        <i class="fas fa-undo"></i> Publish
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


        <%-- SECTION 2: ASSESSMENTS --%>
        <section class="ins-section" id="assessments" style="margin-bottom: 32px;">
            <div class="section-card">
                <div class="section-header" style="margin-bottom: 24px;">
                    <h3 class="section-title">Course Assessments</h3>
                    <a href="${assessmentWorkspaceBaseUrl}" class="btn btn-secondary btn-sm">View Hub</a>
                </div>

                <c:choose>
                    <c:when test="${empty assessments}">
                        <div class="empty-state-box workspace-empty-box">
                            <i class="fas fa-clipboard-list"></i>
                            <p>No assessments created for this course yet.</p>
                            <a href="${assessmentWorkspaceBaseUrl}&view=editor" class="btn btn-primary btn-sm">Create First</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="workspace-assessment-grid" style="display: grid; gap: 20px; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));">
                            <c:forEach var="assessment" items="${assessments}">
                                <article class="ia-assessment-card" style="padding: 20px; border: 1px solid var(--ins-border); border-radius: 12px; background: #fff; position: relative; transition: all 0.2s ease;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                                        <div>
                                            <span style="font-size: 0.65rem; font-weight: 800; text-transform: uppercase; color: var(--ins-primary); letter-spacing: 0.05em; display: block; margin-bottom: 4px;">${assessment.type}</span>
                                            <strong style="display: block; font-size: 1.1rem; color: var(--ins-text);"><c:out value="${assessment.title}"/></strong>
                                        </div>
                                        <div style="width: 32px; height: 32px; border-radius: 8px; background: var(--ins-accent-soft); color: var(--ins-primary); display: flex; align-items: center; justify-content: center;">
                                            <i class="fas ${assessment.type == 'Assignment' ? 'fa-file-signature' : 'fa-stopwatch'}"></i>
                                        </div>
                                    </div>
                                    
                                    <div style="display: flex; gap: 12px; margin-bottom: 20px; font-size: 0.8rem; color: var(--ins-muted);">
                                        <span><i class="fas fa-users" style="margin-right: 4px;"></i> ${submissionCountByAssessmentId[assessment.assessmentId]}</span>
                                        <span style="color: #ea580c; font-weight: 600;"><i class="fas fa-clock-rotate-left" style="margin-right: 4px;"></i> ${not empty pendingCountByAssessmentId[assessment.assessmentId] ? pendingCountByAssessmentId[assessment.assessmentId] : 0} pending</span>
                                    </div>

                                    <div style="display: flex; gap: 8px; border-top: 1px solid var(--ins-border); padding-top: 16px;">
                                        <button type="button" class="btn btn-secondary btn-sm" onclick="openAssessmentPage('submissions', ${assessment.assessmentId})" style="flex: 1; justify-content: center;">
                                            <c:choose>
                                                <c:when test="${assessment.type == 'Assignment'}">Review Files</c:when>
                                                <c:otherwise>View Results</c:otherwise>
                                            </c:choose>
                                        </button>
                                        <button type="button" class="btn btn-secondary btn-sm" onclick="openAssessmentPage('${assessment.type == 'Assignment' ? 'editor' : 'questions'}', ${assessment.assessmentId})" style="width: 40px; justify-content: center;" title="${assessment.type == 'Assignment' ? 'Assignment Settings' : 'Question Bank'}">
                                            <i class="fas ${assessment.type == 'Assignment' ? 'fa-cog' : 'fa-list-check'}"></i>
                                        </button>
                                        <a href="${pageContext.request.contextPath}/instructor/assessments?action=archiveAssessment&courseId=${selectedCourse.courseId}&id=${assessment.assessmentId}" class="btn btn-danger btn-sm" style="width: 40px; justify-content: center;" onclick="return confirm('Archive this assessment?')" title="Archive Assessment"><i class="fas fa-box-archive"></i></a>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>

                <%-- Archived Assessments --%>
                <c:if test="${not empty archivedAssessments}">
                    <div style="margin-top: 24px; padding: 16px; background: #f8fafc; border-radius: 12px; display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-size: 0.85rem; color: var(--ins-muted);">You have <strong>${fn:length(archivedAssessments)}</strong> archived assessments.</span>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="openAssessmentPage('archive')">Manage Archive</button>
                    </div>
                </c:if>
            </div>
        </section>


        <%-- SECTION 3: STUDENTS --%>
        <section class="ins-section" id="students" style="margin-bottom: 32px;">
            <div class="section-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Students</h3>
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
                            <table class="data-table">
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
                                        <td><strong><c:out value="${enrollment.studentName}"/></strong><br><span style="color: var(--ins-muted); font-size: 0.85rem;"><c:out value="${enrollment.studentEmail}"/></span></td>
                                        <td><span class="status-badge status-${fn:toLowerCase(enrollment.status)}"><c:out value="${enrollment.status}"/></span></td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 12px;">
                                                <span style="font-weight: 600; min-width: 32px;"><c:out value="${not empty enrollment.progress ? enrollment.progress : 0}"/>%</span>
                                            </div>
                                        </td>
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

        <%-- SECTION 4: ANALYTICS --%>
        <section class="ins-section" id="analytics" style="margin-bottom: 32px;">
            <div class="section-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Analytics Snapshot</h3>
                    </div>
                </div>
                <div class="workspace-analytics-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;">
                    <div style="padding: 20px; border: 1px solid var(--ins-border); border-radius: 12px; background: #fafafa;">
                        <span style="display: block; color: var(--ins-muted); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">Completed Students</span>
                        <strong style="font-size: 1.8rem; color: var(--ins-text);">${completedStudents}</strong>
                    </div>
                    <div style="padding: 20px; border: 1px solid var(--ins-border); border-radius: 12px; background: #fafafa;">
                        <span style="display: block; color: var(--ins-muted); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">Active Students</span>
                        <strong style="font-size: 1.8rem; color: var(--ins-text);">${totalStudents - completedStudents}</strong>
                    </div>
                    <div style="padding: 20px; border: 1px solid var(--ins-border); border-radius: 12px; background: #fafafa;">
                        <span style="display: block; color: var(--ins-muted); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">Average Progress</span>
                        <strong style="font-size: 1.8rem; color: var(--ins-text);"><fmt:formatNumber value="${averageProgress}" maxFractionDigits="0"/>%</strong>
                    </div>
                    <div style="padding: 20px; border: 1px solid var(--ins-border); border-radius: 12px; background: #fafafa;">
                        <span style="display: block; color: var(--ins-muted); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">Pending Grading</span>
                        <strong style="font-size: 1.8rem; color: var(--ins-text);">${pendingGrading}</strong>
                    </div>
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
            <button class="modal-close" onclick="closeUploadModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p class="modal-subtitle">Course: <strong><c:out value="${selectedCourse.courseName}"/></strong></p>
            <form id="uploadForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                <div class="upload-form-grid">
                    <div class="field">
                        <label>Title *</label>
                        <input type="text" name="title" required>
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
                    </div>
                    <div class="field">
                        <label>Chapter / Order</label>
                        <input type="number" name="displayOrder" min="1">
                    </div>
                    <div class="field">
                        <label>File</label>
                        <input type="file" name="materialFile" id="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3">
                    </div>
                    <div class="field">
                        <label>External URL (for Link type)</label>
                        <input type="url" name="externalUrl" id="externalUrl">
                    </div>
                    <div class="field full">
                        <label>Description</label>
                        <textarea name="description" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeUploadModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-upload"></i> Publish</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div id="editMaterialModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Edit Material</h3>
            <button class="modal-close" onclick="closeEditMaterialModal()"><i class="fas fa-times"></i></button>
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
                    </div>
                    <div class="field">
                        <label>Chapter / Order</label>
                        <input id="editOrder" type="number" name="displayOrder" min="1">
                    </div>
                    <div class="field">
                        <label>Replace File</label>
                        <input id="editFile" type="file" name="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3">
                    </div>
                    <div class="field">
                        <label>External URL (for Link type)</label>
                        <input id="editExternalUrl" type="url" name="externalUrl">
                    </div>
                    <div class="field full">
                        <label>Description</label>
                        <textarea id="editDescription" name="description" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeEditMaterialModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
<script>
    (function(){
        var btn = document.getElementById('insMenuBtn');
        if(btn) btn.addEventListener('click', function(){ document.body.classList.toggle('ins-shell-collapsed'); });
    })();

    // Changed from iframe setting to window.location navigation
    function openAssessmentPage(view, assessmentId) {
        const baseUrl = '${assessmentWorkspaceBaseUrl}';
        const resolvedView = view || 'editor';
        let nextUrl = baseUrl + '&view=' + encodeURIComponent(resolvedView);
        if (assessmentId) {
            nextUrl += '&assessmentId=' + encodeURIComponent(assessmentId);
        }
        window.location.href = nextUrl;
    }

    function openUploadModal() {
        document.getElementById('uploadModal').classList.add('show');
        document.body.style.overflow = 'hidden';
    }

    function closeUploadModal() {
        document.getElementById('uploadModal').classList.remove('show');
        document.body.style.overflow = 'auto';
        document.getElementById('uploadForm').reset();
    }

    function openEditMaterialModal(button, focusFile) {
        document.getElementById('editMaterialId').value = button.dataset.materialId || '';
        document.getElementById('editTitle').value = button.dataset.title || '';
        document.getElementById('editType').value = button.dataset.type || 'PDF';
        document.getElementById('editOrder').value = button.dataset.order || '';
        document.getElementById('editDescription').value = button.dataset.description || '';
        document.getElementById('editExternalUrl').value = button.dataset.externalUrl || '';
        document.getElementById('editFile').value = '';

        document.getElementById('editMaterialModal').classList.add('show');
        document.body.style.overflow = 'hidden';

        if (focusFile) {
            window.setTimeout(function () {
                const fileInput = document.getElementById('editFile');
                if (fileInput) fileInput.focus();
            }, 0);
        }
    }

    function closeEditMaterialModal() {
        document.getElementById('editMaterialModal').classList.remove('show');
        document.body.style.overflow = 'auto';
        const fileInput = document.getElementById('editFile');
        if (fileInput) fileInput.value = '';
    }

    function selectAllMaterials(className, checked) {
        document.querySelectorAll('.' + className).forEach(function (checkbox) {
            checkbox.checked = checked;
        });
    }

    window.addEventListener('click', function (event) {
        const uploadModal = document.getElementById('uploadModal');
        const editModal = document.getElementById('editMaterialModal');
        if (uploadModal && event.target === uploadModal) closeUploadModal();
        if (editModal && event.target === editModal) closeEditMaterialModal();
    });

    window.addEventListener('keydown', function (event) {
        if (event.key !== 'Escape') return;
        closeUploadModal();
        closeEditMaterialModal();
    });

    (function () {
        const type = document.getElementById('materialType');
        const file = document.getElementById('materialFile');
        const url = document.getElementById('externalUrl');
        const editType = document.getElementById('editType');
        const editFile = document.getElementById('editFile');
        const editUrl = document.getElementById('editExternalUrl');

        const applyTypeRules = function (selectedType, fileInput, urlInput) {
            const isLink = selectedType === 'Link';
            if (fileInput) {
                fileInput.required = !!selectedType && !isLink;
                fileInput.disabled = !!selectedType && isLink;
            }
            if (urlInput) {
                urlInput.required = !!selectedType && isLink;
                urlInput.disabled = !!selectedType && !isLink;
            }
        };

        if (type) type.addEventListener('change', () => applyTypeRules(type.value, file, url));
        if (editType) editType.addEventListener('change', () => applyTypeRules(editType.value, editFile, editUrl));
        if (type) applyTypeRules(type.value, file, url);
        if (editType) applyTypeRules(editType.value, editFile, editUrl);
    })();
</script>
</body>
</html>
