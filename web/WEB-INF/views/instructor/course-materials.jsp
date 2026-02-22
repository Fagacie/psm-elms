<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Materials - Instructor</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-materials.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<header class="app-header">
    <div class="header-left">
        <div class="logo-section">
            <i class="fas fa-graduation-cap"></i>
            <span>PSM E-Learning</span>
        </div>
        <h1 class="page-title">Course Materials</h1>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item">
            <i class="fas fa-book"></i><span>My Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item active">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="section-card" style="margin-bottom:16px;">
            <form method="get" action="${pageContext.request.contextPath}/instructor/materials" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
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
                <h3 style="margin: 0 0 20px 0; font-size: 18px; font-weight: 600; padding-bottom: 12px; border-bottom: 2px solid var(--border-color);">Materials List</h3>
                <c:choose>
                    <c:when test="${empty materials}">
                        <div class="empty-state-box">
                            <i class="fas fa-folder-open"></i>
                            <p>No materials uploaded for this course yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="materials-grid">
                            <c:forEach var="m" items="${materials}">
                                <div class="material-card">
                                    <div class="material-header">
                                        <h4 class="material-title">${m.title}</h4>
                                        <span class="type-badge type-${m.materialType}">${m.materialType}</span>
                                    </div>
                                    <c:if test="${not empty m.description}">
                                        <p class="material-description">${m.description}</p>
                                    </c:if>
                                    <div class="material-meta">
                                        <div class="meta-item">
                                            <i class="fas fa-hashtag"></i>
                                            <span>Order: <c:out value="${m.displayOrder}" default="N/A"/></span>
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-code-branch"></i>
                                            <span>${m.versionNumber}</span>
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-calendar"></i>
                                            <span>
                                                <c:choose>
                                                    <c:when test="${not empty m.uploadDate}">
                                                        ${m.uploadDate.toLocalDate()}
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="material-actions">
                                        <a href="${m.filePath}" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-sm">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                        <button class="btn btn-secondary btn-sm" onclick="toggleEdit(${m.materialId})">
                                            <i class="fas fa-pen"></i> Edit
                                        </button>
                                        <form method="get" action="${pageContext.request.contextPath}/instructor/materials" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${m.materialId}">
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                            <button class="btn btn-danger btn-sm" type="submit" onclick="return confirm('Archive this material?');">
                                                <i class="fas fa-archive"></i> Archive
                                            </button>
                                        </form>
                                    </div>
                                    <div id="edit-form-${m.materialId}" class="edit-dropdown-content" style="display:none; margin-top:12px; border-top: 1px solid var(--border-color); padding-top: 12px;">
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="materialId" value="${m.materialId}">
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                            <div class="upload-form-grid">
                                                <div class="field">
                                                    <label>Title</label>
                                                    <input type="text" name="title" value="${m.title}" required>
                                                </div>
                                                <div class="field">
                                                    <label>Type</label>
                                                    <select name="materialType" required>
                                                        <option value="PDF" ${m.materialType == 'PDF' ? 'selected' : ''}>PDF</option>
                                                        <option value="Video" ${m.materialType == 'Video' ? 'selected' : ''}>Video</option>
                                                        <option value="Slides" ${m.materialType == 'Slides' ? 'selected' : ''}>Slides</option>
                                                        <option value="Link" ${m.materialType == 'Link' ? 'selected' : ''}>Link</option>
                                                    </select>
                                                </div>
                                                <div class="field">
                                                    <label>Version</label>
                                                    <input type="text" name="versionNumber" value="${m.versionNumber}">
                                                </div>
                                                <div class="field">
                                                    <label>Order</label>
                                                    <input type="number" name="displayOrder" min="1" value="${m.displayOrder}">
                                                </div>
                                                <div class="field">
                                                    <label>External URL</label>
                                                    <input type="url" name="externalUrl" value="${m.materialType == 'Link' ? m.filePath : ''}" placeholder="For Link type">
                                                </div>
                                                <div class="field">
                                                    <label>Replace File</label>
                                                    <input type="file" name="materialFile">
                                                </div>
                                                <div class="field full">
                                                    <label>Description</label>
                                                    <textarea name="description" rows="2">${m.description}</textarea>
                                                </div>
                                            </div>
                                            <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-save"></i> Save Changes</button>
                                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleEdit(${m.materialId})">Cancel</button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div style="margin-top: 32px; padding-top: 24px; border-top: 2px solid var(--border-color);">
                    <h4 style="font-size: 16px; font-weight: 600; color: var(--text-secondary); margin: 0 0 16px 0;">Archived Materials</h4>
                    <c:choose>
                        <c:when test="${empty deletedMaterials}">
                            <p style="color: var(--text-muted); font-size: 13px;">No archived materials.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="m" items="${deletedMaterials}">
                                <div class="archived-item">
                                    <div class="archived-item-info">
                                        <div class="archived-item-title">${m.title}</div>
                                        <div class="archived-item-meta">
                                            Order: <c:out value="${m.displayOrder}" default="N/A"/> | 
                                            Type: ${m.materialType} | 
                                            Version: ${m.versionNumber}
                                        </div>
                                    </div>
                                    <form method="get" action="${pageContext.request.contextPath}/instructor/materials">
                                        <input type="hidden" name="action" value="restore">
                                        <input type="hidden" name="id" value="${m.materialId}">
                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                        <button class="btn btn-secondary btn-sm" type="submit">
                                            <i class="fas fa-undo"></i> Restore
                                        </button>
                                    </form>
                                </div>
                            </c:forEach>
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
                <p class="modal-subtitle" style="margin-bottom: 20px;">Set chapter/order number to control learning flow. Leave empty to append at the end.</p>
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
                            <input type="file" name="materialFile" id="materialFile">
                        </div>
                        <div class="field">
                            <label>External URL (for Link type)</label>
                            <input type="url" name="externalUrl" id="externalUrl" placeholder="https://example.com/resource">
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
    
    // Close modal on outside click
    window.onclick = function(event) {
        const modal = document.getElementById('uploadModal');
        if (event.target === modal) {
            closeUploadModal();
        }
    }
    
    // Toggle edit form visibility
    function toggleEdit(materialId) {
        const editForm = document.getElementById('edit-form-' + materialId);
        if (editForm) {
            editForm.style.display = editForm.style.display === 'none' ? 'block' : 'none';
        }
    }
    
    // File requirement based on material type
    (function () {
        const type = document.getElementById('materialType');
        const file = document.getElementById('materialFile');
        const url = document.getElementById('externalUrl');
        
        const syncRequired = function () {
            const isLink = type && type.value === 'Link';
            if (file) file.required = !isLink;
            if (url) url.required = isLink;
        };
        
        if (type) type.addEventListener('change', syncRequired);
        syncRequired();
    })();
</script>
</body>
</html>
