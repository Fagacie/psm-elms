<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Materials - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-materials.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Materials"/>
    <jsp:param name="pageSubtitle" value="Organize learning assets by course and content type"/>
</jsp:include>

<c:set var="activeInstructorPage" value="materials"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Materials</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Learning Content</p>
                <h2>Organize course materials with clearer teaching flow</h2>
                <p>This page now follows the instructor workspace pattern so uploading, ordering, editing, and archiving materials feels more like a professional content studio.</p>
            </div>
            <div class="ins-hero-actions">
                <c:if test="${not empty selectedCourse}">
                    <button class="btn btn-primary" type="button" onclick="openUploadModal()">
                        <i class="fas fa-plus"></i> Add Material
                    </button>
                </c:if>
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                    <i class="fas fa-book"></i> Open Courses
                </a>
            </div>
        </section>

        <div class="section-card course-filter-card">
            <form method="get" action="${pageContext.request.contextPath}/instructor/materials" class="course-filter-form">
                <label for="courseId"><strong>Select Course</strong></label>
                <select id="courseId" name="courseId" required>
                    <option value="">-- Select --</option>
                    <c:forEach var="c" items="${courses}">
                        <option value="${c.courseId}" <c:if test="${not empty selectedCourse and selectedCourse.courseId == c.courseId}">selected</c:if>>
                            ${c.courseName}
                        </option>
                    </c:forEach>
                </select>
                <button class="btn btn-primary btn-sm" type="submit"><i class="fas fa-filter"></i> Load Materials</button>
            </form>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>
        <c:if test="${param.success == 'created'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Material uploaded successfully.</div>
        </c:if>
        <c:if test="${param.success == 'updated'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Material updated successfully.</div>
        </c:if>
        <c:if test="${param.success == 'deleted'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Material moved to archive.</div>
        </c:if>
        <c:if test="${param.success == 'restored'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Material restored successfully.</div>
        </c:if>
        <c:if test="${param.error == 'missing'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Required fields are missing.</div>
        </c:if>
        <c:if test="${param.error == 'nofile'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please choose a file to upload.</div>
        </c:if>
        <c:if test="${param.error == 'filesize'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> File is too large. Maximum upload size is 50MB.</div>
        </c:if>
        <c:if test="${param.error == 'filetype'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Unsupported file format.</div>
        </c:if>
        <c:if test="${param.error == 'link'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Valid URL is required for Link type (http/https).</div>
        </c:if>
        <c:if test="${param.error == 'upload'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Upload failed. Please try again.</div>
        </c:if>
        <c:if test="${param.error == 'restore'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Unable to restore material.</div>
        </c:if>

        <c:if test="${not empty selectedCourse}">
            <section class="ins-hero-card materials-hero">
                <div class="ins-hero-grid">
                    <div>
                        <h3>${selectedCourse.courseName}</h3>
                        <p>Use the display order to place content exactly where students should encounter it. That gives you flexibility when chapters are uploaded later or revised out of sequence.</p>
                    </div>
                    <div class="ins-hero-metrics">
                        <div class="ins-metric">
                            <strong>${materials.size()}</strong>
                            <span>Published materials</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${deletedMaterials.size()}</strong>
                            <span>Archived items</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${empty materials ? 'Empty' : 'Structured'}</strong>
                            <span>Content state</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${param.success != null ? 'Updated' : 'Ready'}</strong>
                            <span>Workspace signal</span>
                        </div>
                    </div>
                </div>
            </section>

            <div class="page-actions">
                <div class="materials-summary">
                    <div class="summary-item">
                        <div class="summary-value">${materials.size()}</div>
                        <div class="summary-label">Active Materials</div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-value">${deletedMaterials.size()}</div>
                        <div class="summary-label">Archived</div>
                    </div>
                </div>
                <button class="btn btn-primary" onclick="openUploadModal()">
                    <i class="fas fa-plus"></i> Add New Material
                </button>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <div>
                        <h3 class="section-title">Materials Library</h3>
                        <p class="section-caption">Review published materials, edit details, or archive outdated resources.</p>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${empty materials}">
                        <div class="empty-state-box">
                            <i class="fas fa-folder-open"></i>
                            <p>No materials uploaded for this course yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="materials-table-wrap">
                            <table class="materials-table">
                                <thead>
                                <tr>
                                    <th>Material</th>
                                    <th>Type</th>
                                    <th>Order</th>
                                    <th>Version</th>
                                    <th>Uploaded</th>
                                    <th>Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="m" items="${materials}">
                                    <tr>
                                        <td>
                                            <div class="material-cell">
                                                <div class="material-cell-title"><c:out value="${m.title}"/></div>
                                                <div class="material-cell-subtitle">
                                                    <c:choose>
                                                        <c:when test="${not empty m.description && m.description.length() > 90}">
                                                            <c:out value="${m.description.substring(0, 90)}"/>...
                                                        </c:when>
                                                        <c:when test="${not empty m.description}">
                                                            <c:out value="${m.description}"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:choose>
                                                                <c:when test="${m.materialType == 'Link'}">External link resource</c:when>
                                                                <c:otherwise>Course asset</c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </td>
                                        <td><span class="type-badge type-${m.materialType}">${m.materialType}</span></td>
                                        <td><span class="table-pill"><c:out value="${m.displayOrder}" default="N/A"/></span></td>
                                        <td><span class="table-pill table-pill-muted"><c:out value="${m.versionNumber}" default="N/A"/></span></td>
                                        <td>
                                            <span class="table-muted">
                                                <c:choose>
                                                    <c:when test="${not empty m.uploadDate}">
                                                        ${m.uploadDate.toLocalDate()}
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td>
                                            <div class="row-actions">
                                                <a href="${m.filePath}" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-sm">
                                                    <i class="fas fa-eye"></i> View
                                                </a>
                                                <button type="button"
                                                        class="btn btn-secondary btn-sm"
                                                        onclick="openEditMaterialModal(this)"
                                                        data-material-id="${m.materialId}"
                                                        data-title="<c:out value='${m.title}'/>"
                                                        data-type="<c:out value='${m.materialType}'/>"
                                                        data-version="<c:out value='${m.versionNumber}'/>"
                                                        data-order="<c:out value='${m.displayOrder}'/>"
                                                        data-description="<c:out value='${m.description}'/>"
                                                        data-external-url="${m.materialType == 'Link' ? m.filePath : ''}">
                                                    <i class="fas fa-edit"></i> Edit
                                                </button>
                                                <details class="more-actions" data-menu="material-actions">
                                                    <summary class="btn btn-secondary btn-sm" aria-label="Open more actions">
                                                        <i class="fas fa-ellipsis-h"></i> More
                                                    </summary>
                                                    <div class="more-actions-menu" role="menu" aria-label="Material actions menu">
                                                        <form method="get" action="${pageContext.request.contextPath}/instructor/materials">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="id" value="${m.materialId}">
                                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                            <button type="submit" class="more-action-item is-danger" onclick="return confirm('Archive this material?');">
                                                                <i class="fas fa-archive"></i> Archive
                                                            </button>
                                                        </form>
                                                        <a href="${m.filePath}" target="_blank" rel="noopener noreferrer" class="more-action-item">
                                                            <i class="fas fa-up-right-from-square"></i> Open
                                                        </a>
                                                    </div>
                                                </details>
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
                    <h4 class="archived-title">Archived Materials</h4>
                    <c:choose>
                        <c:when test="${empty deletedMaterials}">
                            <p class="archived-empty">No archived materials.</p>
                        </c:when>
                        <c:otherwise>
                            <div class="archived-table-wrap">
                                <table class="archived-table">
                                    <thead>
                                    <tr>
                                        <th>Material</th>
                                        <th>Type</th>
                                        <th>Order</th>
                                        <th>Version</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="m" items="${deletedMaterials}">
                                        <tr>
                                            <td>
                                                <div class="material-cell">
                                                    <div class="material-cell-title">${m.title}</div>
                                                    <div class="material-cell-subtitle">Archived from this course</div>
                                                </div>
                                            </td>
                                            <td><span class="type-badge type-${m.materialType}">${m.materialType}</span></td>
                                            <td><span class="table-pill"><c:out value="${m.displayOrder}" default="N/A"/></span></td>
                                            <td><span class="table-pill table-pill-muted"><c:out value="${m.versionNumber}" default="N/A"/></span></td>
                                            <td>
                                                <div class="row-actions">
                                                    <form method="get" action="${pageContext.request.contextPath}/instructor/materials" class="inline-form">
                                                        <input type="hidden" name="action" value="restore">
                                                        <input type="hidden" name="id" value="${m.materialId}">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <button class="btn btn-secondary btn-sm" type="submit">
                                                            <i class="fas fa-undo"></i> Restore
                                                        </button>
                                                    </form>
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
        </c:if>
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
            <c:if test="${not empty selectedCourse}">
                <p class="modal-subtitle">Course: <strong>${selectedCourse.courseName}</strong></p>
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
            </c:if>
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
            <c:if test="${not empty selectedCourse}">
                <p class="modal-subtitle">Course: <strong>${selectedCourse.courseName}</strong></p>
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
            </c:if>
        </div>
    </div>
</div>

<script>
    // Modal functions
    function openUploadModal() {
        const modal = document.getElementById('uploadModal');
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
    }
    
    function closeUploadModal() {
        const modal = document.getElementById('uploadModal');
        modal.classList.remove('show');
        document.body.style.overflow = 'auto';
        document.getElementById('uploadForm').reset();
    }

    function openEditMaterialModal(button) {
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
    }

    function closeEditMaterialModal() {
        const modal = document.getElementById('editMaterialModal');
        modal.classList.remove('show');
        document.body.style.overflow = 'auto';
        document.getElementById('editFile').value = '';
    }
    
    // Close modal on outside click
    window.onclick = function(event) {
        const uploadModal = document.getElementById('uploadModal');
        const editModal = document.getElementById('editMaterialModal');
        if (event.target === uploadModal) {
            closeUploadModal();
        }
        if (event.target === editModal) {
            closeEditMaterialModal();
        }
    }

    window.addEventListener('keydown', function(event) {
        if (event.key !== 'Escape') return;
        const uploadModal = document.getElementById('uploadModal');
        const editModal = document.getElementById('editMaterialModal');
        if (uploadModal.classList.contains('show')) {
            closeUploadModal();
        }
        if (editModal.classList.contains('show')) {
            closeEditMaterialModal();
        }
    });
    
    // File requirement based on material type
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

