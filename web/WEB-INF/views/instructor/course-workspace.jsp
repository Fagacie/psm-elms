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
        <section class="ins-section-head ws-page-head">
            <div class="ws-head-title">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary btn-sm">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
                <h2><c:out value="${selectedCourse.courseName}"/></h2>
                <span class="status-badge status-${selectedCourse.status}"><c:out value="${selectedCourse.status}"/></span>
            </div>
            <div class="workspace-meta-row">
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
        <%-- ACTION BAR --%>
        <section class="ws-action-bar section-card">
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

        <%-- SECTION 1: MATERIALS (Summary) --%>
        <section class="ins-section ws-section" id="materials">
            <div class="section-card">
                <div class="section-header">
                    <h3 class="section-title">Recent Course Materials</h3>
                    <a href="${pageContext.request.contextPath}/instructor/materials?courseId=${selectedCourse.courseId}" class="btn btn-secondary btn-sm">Manage Hub</a>
                </div>
                <c:choose>
                    <c:when test="${empty materials}">
                        <div class="empty-state-box workspace-empty-box">
                            <i class="fas fa-folder-open"></i>
                            <p>No active materials uploaded for this course yet.</p>
                            <button class="btn btn-primary btn-sm" onclick="openUploadModal()">Upload Material</button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="ws-summary-grid">
                            <c:forEach var="material" items="${materials}" end="3">
                                <article class="ws-summary-card">
                                    <div class="ws-summary-icon">
                                        <i class="fas fa-file-alt"></i>
                                    </div>
                                    <div class="ws-summary-content">
                                        <strong><c:out value="${material.title}"/></strong>
                                        <span><c:out value="${material.materialType}"/></span>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                        <c:if test="${fn:length(materials) > 4}">
                            <div class="ws-view-more">
                                <a href="${pageContext.request.contextPath}/instructor/materials?courseId=${selectedCourse.courseId}">View all ${fn:length(materials)} materials &rarr;</a>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>


        <%-- SECTION 2: ASSESSMENTS (Summary) --%>
        <section class="ins-section ws-section" id="assessments">
            <div class="section-card">
                <div class="section-header">
                    <h3 class="section-title">Recent Assessments</h3>
                    <a href="${assessmentWorkspaceBaseUrl}" class="btn btn-secondary btn-sm">Manage Hub</a>
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
                        <div class="ws-summary-grid">
                            <c:forEach var="assessment" items="${assessments}" end="3">
                                <article class="ws-summary-card">
                                    <div class="ws-summary-icon">
                                        <i class="fas ${assessment.type == 'Assignment' ? 'fa-file-signature' : 'fa-stopwatch'}"></i>
                                    </div>
                                    <div class="ws-summary-content">
                                        <strong><c:out value="${assessment.title}"/></strong>
                                        <span>${assessment.type} &bull; ${submissionCountByAssessmentId[assessment.assessmentId]} subs</span>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                        <c:if test="${fn:length(assessments) > 4}">
                            <div class="ws-view-more">
                                <a href="${assessmentWorkspaceBaseUrl}">View all ${fn:length(assessments)} assessments &rarr;</a>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>


        <%-- SECTION 3: STUDENTS --%>
        <section class="ins-section ws-section" id="students">
            <div class="section-card">
                <div class="section-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                    <h3 class="section-title" style="margin: 0;">Students Overview</h3>
                    <div style="position: relative; flex: 1; max-width: 300px;">
                        <i class="fas fa-search" style="position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--ins-muted);"></i>
                        <input type="text" placeholder="Search students..." 
                               data-search-target="#ws-student-list-container" 
                               data-search-item=".ws-student-row"
                               style="width: 100%; padding: 8px 16px 8px 42px; border: 1px solid var(--ins-border); border-radius: 8px; font-family: inherit;">
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
                        <div class="ws-student-list" id="ws-student-list-container">
                            <c:forEach var="enrollment" items="${enrollments}" end="5">
                                <article class="ws-student-row">
                                    <div class="ws-student-info">
                                        <div class="ws-student-avatar">
                                            <c:out value="${fn:substring(enrollment.studentName, 0, 1)}"/>
                                        </div>
                                        <div class="ws-student-details">
                                            <strong data-search-text><c:out value="${enrollment.studentName}"/></strong>
                                            <span data-search-text><c:out value="${enrollment.studentEmail}"/></span>
                                        </div>
                                    </div>
                                    <div class="ws-student-status">
                                        <span class="status-badge status-${fn:toLowerCase(enrollment.status)}"><c:out value="${enrollment.status}"/></span>
                                    </div>
                                    <div class="ws-student-progress">
                                        <div class="ws-progress-bar">
                                            <div class="ws-progress-fill" style="width: ${not empty enrollment.progress ? enrollment.progress : 0}%;"></div>
                                        </div>
                                        <span class="ws-progress-text"><c:out value="${not empty enrollment.progress ? enrollment.progress : 0}"/>% Completed</span>
                                    </div>
                                    <div class="ws-student-date">
                                        <i class="far fa-calendar-alt"></i> Enrolled:<br>
                                        <c:out value="${not empty enrollment.enrollmentDate ? enrollment.enrollmentDate : '-'}"/>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                        <c:if test="${fn:length(enrollments) > 6}">
                            <div class="ws-view-more">
                                <a href="#">View all ${fn:length(enrollments)} students &rarr;</a>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <%-- SECTION 4: ANALYTICS --%>
        <section class="ins-section ws-section" id="analytics">
            <div class="section-card">
                <div class="section-header">
                    <h3 class="section-title">Analytics Snapshot</h3>
                </div>
                <div class="ws-analytics-grid">
                    <div class="ws-analytics-card">
                        <span>Completed Students</span>
                        <strong>${completedStudents}</strong>
                    </div>
                    <div class="ws-analytics-card">
                        <span>Active Students</span>
                        <strong>${totalStudents - completedStudents}</strong>
                    </div>
                    <div class="ws-analytics-card">
                        <span>Average Progress</span>
                        <strong><fmt:formatNumber value="${averageProgress}" maxFractionDigits="0"/>%</strong>
                    </div>
                    <div class="ws-analytics-card">
                        <span>Pending Grading</span>
                        <strong>${pendingGrading}</strong>
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
                            <option value="Video">Video File</option>
                            <option value="Slides">Slides</option>
                            <option value="Link">External Link</option>
                            <option value="YouTube">YouTube Video</option>
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
                            <option value="Video">Video File</option>
                            <option value="Slides">Slides</option>
                            <option value="Link">External Link</option>
                            <option value="YouTube">YouTube Video</option>
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

<script>
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
            const isUrlBased = selectedType === 'Link' || selectedType === 'YouTube';
            if (fileInput) {
                fileInput.required = !!selectedType && !isUrlBased;
                fileInput.disabled = !!selectedType && isUrlBased;
            }
            if (urlInput) {
                urlInput.required = !!selectedType && isUrlBased;
                urlInput.disabled = !!selectedType && !isUrlBased;
                urlInput.placeholder = selectedType === 'YouTube' ? 'https://www.youtube.com/watch?v=...' : 'https://';
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
