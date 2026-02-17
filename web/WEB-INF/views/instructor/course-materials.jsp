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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/materials.css">
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
            <div class="materials-summary" style="margin-bottom: 16px;">
                <div class="summary-item">
                    <div class="summary-value">${materials.size()}</div>
                    <div class="summary-label">Active Materials</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">${deletedMaterials.size()}</div>
                    <div class="summary-label">Archived</div>
                </div>
            </div>

            <div class="section-card" style="margin-bottom:16px;">
                <h3>Upload New Material: ${selectedCourse.courseName}</h3>
                <p class="text-muted">Set chapter/order number to control learning flow. Leave empty to append at the end.</p>
                <form method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                    <div class="upload-form-grid">
                        <div class="field">
                            <label>Title</label>
                            <input type="text" name="title" placeholder="Material title" required>
                        </div>
                        <div class="field">
                            <label>Type</label>
                            <select name="materialType" required>
                                <option value="">Type</option>
                                <option value="PDF">PDF</option>
                                <option value="Video">Video</option>
                                <option value="Slides">Slides</option>
                                <option value="Link">Link</option>
                            </select>
                        </div>
                        <div class="field">
                            <label>Version</label>
                            <input type="text" name="versionNumber" placeholder="Version (e.g. v1.0)">
                        </div>
                        <div class="field">
                            <label>Chapter / Order</label>
                            <input type="number" name="displayOrder" min="1" placeholder="e.g. 1">
                        </div>
                        <div class="field">
                            <label>File</label>
                            <input type="file" name="materialFile">
                        </div>
                        <div class="field">
                            <label>External URL (for Link type)</label>
                            <input type="url" name="externalUrl" placeholder="https://example.com/resource">
                        </div>
                        <div class="field full">
                            <label>Description</label>
                            <textarea name="description" placeholder="Description" rows="3"></textarea>
                        </div>
                    </div>
                    <div style="margin-top:12px;">
                        <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-upload"></i> Publish Material</button>
                    </div>
                </form>
            </div>

            <div class="section-card">
                <h3>Materials List</h3>
                <c:choose>
                    <c:when test="${empty materials}">
                        <p>No materials uploaded for this course yet.</p>
                    </c:when>
                    <c:otherwise>
                        <table class="data-table" style="width:100%;">
                            <thead>
                            <tr>
                                <th>Title</th>
                                <th>Order</th>
                                <th>Type</th>
                                <th>Version</th>
                                <th>Uploaded</th>
                                <th>Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="m" items="${materials}">
                                <tr>
                                    <td>${m.title}</td>
                                    <td><c:out value="${m.displayOrder}" default="-"/></td>
                                    <td>${m.materialType}</td>
                                    <td>${m.versionNumber}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty m.uploadDate}">
                                                ${m.uploadDate.toLocalDate()}
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="material-actions">
                                            <a class="btn btn-secondary btn-sm" href="${m.filePath}" target="_blank" rel="noopener noreferrer">
                                                <i class="fas fa-eye"></i> Open Source
                                            </a>
                                            <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/materials?courseId=${selectedCourse.courseId}">
                                                <i class="fas fa-user-graduate"></i> Student View
                                            </a>
                                            <form method="get" action="${pageContext.request.contextPath}/instructor/materials" style="display:inline;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${m.materialId}">
                                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                <button class="btn btn-danger btn-sm" type="submit" onclick="return confirm('Archive this material?');">
                                                    <i class="fas fa-archive"></i> Archive
                                                </button>
                                            </form>
                                            <details style="display:inline-block;">
                                                <summary class="btn btn-secondary btn-sm" style="display:inline-flex; list-style:none; cursor:pointer;">
                                                    <i class="fas fa-pen"></i> Edit
                                                </summary>
                                                <form method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data" style="margin-top:8px; min-width:300px;">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="materialId" value="${m.materialId}">
                                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                    <input type="text" name="title" value="${m.title}" required style="width:100%; margin-bottom:6px;">
                                                    <select name="materialType" required style="width:100%; margin-bottom:6px;">
                                                        <option value="PDF" ${m.materialType == 'PDF' ? 'selected' : ''}>PDF</option>
                                                        <option value="Video" ${m.materialType == 'Video' ? 'selected' : ''}>Video</option>
                                                        <option value="Slides" ${m.materialType == 'Slides' ? 'selected' : ''}>Slides</option>
                                                        <option value="Link" ${m.materialType == 'Link' ? 'selected' : ''}>Link</option>
                                                    </select>
                                                    <input type="number" name="displayOrder" min="1" value="${m.displayOrder}" placeholder="Order (1,2,3...)" style="width:100%; margin-bottom:6px;">
                                                    <input type="text" name="versionNumber" value="${m.versionNumber}" style="width:100%; margin-bottom:6px;">
                                                    <input type="url" name="externalUrl" value="${m.materialType == 'Link' ? m.filePath : ''}" placeholder="External URL (for Link type)" style="width:100%; margin-bottom:6px;">
                                                    <input type="file" name="materialFile" style="width:100%; margin-bottom:6px;">
                                                    <textarea name="description" rows="2" style="width:100%;">${m.description}</textarea>
                                                    <button type="submit" class="btn btn-primary btn-sm" style="margin-top:6px;">Save</button>
                                                </form>
                                            </details>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>

                <div class="archived-materials">
                    <h4>Archived Materials</h4>
                    <c:choose>
                        <c:when test="${empty deletedMaterials}">
                            <p class="text-muted">No archived materials.</p>
                        </c:when>
                        <c:otherwise>
                            <table class="data-table" style="width:100%;">
                                <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Order</th>
                                    <th>Type</th>
                                    <th>Version</th>
                                    <th>Action</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="m" items="${deletedMaterials}">
                                    <tr>
                                        <td>${m.title}</td>
                                        <td><c:out value="${m.displayOrder}" default="-"/></td>
                                        <td>${m.materialType}</td>
                                        <td>${m.versionNumber}</td>
                                        <td>
                                            <form method="get" action="${pageContext.request.contextPath}/instructor/materials">
                                                <input type="hidden" name="action" value="restore">
                                                <input type="hidden" name="id" value="${m.materialId}">
                                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                <button class="btn btn-secondary btn-sm" type="submit"><i class="fas fa-undo"></i> Restore</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>
    </div>
</main>
<script>
    (function () {
        const form = document.querySelector('form[action$="/instructor/materials"][enctype="multipart/form-data"]');
        if (!form) return;
        const type = form.querySelector('select[name="materialType"]');
        const file = form.querySelector('input[name="materialFile"]');
        const url = form.querySelector('input[name="externalUrl"]');
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
