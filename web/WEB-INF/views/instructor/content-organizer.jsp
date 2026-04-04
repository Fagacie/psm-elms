<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organize Course Content - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-organizer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="instructor-ui">
<header class="app-header">
    <div class="header-left">
        <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
            <span class="dashboard-brand-main">PSM</span>
            <span class="dashboard-brand-sub">E-Learning</span>
        </a>
        <div class="dashboard-title-copy">
            <h1 class="page-title">Content Organizer</h1>
            <p>Arrange materials and assessments into a clear course flow</p>
        </div>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/profile" class="user-menu user-menu-link">
            <div class="user-info">
                <span class="user-name"><c:out value="${empty user ? sessionScope.user.fullName : user.fullName}"/></span>
                <span class="user-role">Instructor</span>
            </div>
            <c:set var="topProfilePicture" value="${empty user ? sessionScope.user.profilePicture : user.profilePicture}"/>
            <div class="user-avatar">
                <c:choose>
                    <c:when test="${not empty topProfilePicture}">
                        <c:choose>
                            <c:when test="${topProfilePicture.startsWith('http')}">
                                <img src="${topProfilePicture}" alt="Profile picture">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/${topProfilePicture}" alt="Profile picture">
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <i class="fas fa-user"></i>
                    </c:otherwise>
                </c:choose>
            </div>
        </a>
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
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item active">
            <i class="fas fa-book"></i><span>Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item">
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
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Organizer</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Course Flow Studio</p>
                <h2>Arrange materials and assessments in the order students should experience them</h2>
                <p>This workspace connects the learning sequence into one visual flow. Reorder materials, attach assessments after the right chapter, and keep final evaluations clearly separated at the end of the course.</p>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Courses
                </a>
                <button class="btn btn-primary" type="button" onclick="saveContentOrder()">
                    <i class="fas fa-save"></i> Save Order
                </button>
            </div>
        </section>

        <section class="ins-hero-card organizer-hero">
            <div class="ins-hero-grid">
                <div>
                    <h3>${course.courseName}</h3>
                    <p>Drag materials to change chapter sequence. Drag assessments beneath a material to make them appear after that chapter, or place them in the final section to position them after all learning materials.</p>
                </div>
                <div class="ins-hero-metrics">
                    <div class="ins-metric">
                        <strong>${materials.size()}</strong>
                        <span>Materials in sequence</span>
                    </div>
                    <div class="ins-metric">
                        <strong>${finalAssessments.size()}</strong>
                        <span>Final assessments</span>
                    </div>
                    <div class="ins-metric">
                        <strong>${param.success == 'reordered' ? 'Saved' : 'Ready'}</strong>
                        <span>Flow state</span>
                    </div>
                    <div class="ins-metric">
                        <strong>${empty materials ? 'Empty' : 'Structured'}</strong>
                        <span>Learning path</span>
                    </div>
                </div>
            </div>
        </section>

        <c:if test="${param.success == 'reordered'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Course content order saved successfully.
            </div>
        </c:if>
        <c:if test="${param.error == 'invalid'}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> Unable to save the current arrangement. Please try again.
            </div>
        </c:if>

        <section class="section-card organizer-section">
            <div class="section-header">
                <div>
                    <h3 class="section-title">Course Content Flow</h3>
                    <p class="section-caption">Materials create the main learning path. Assessments can be attached after a material or moved to the final assessment area.</p>
                </div>
            </div>

            <c:if test="${empty materials}">
                <div class="empty-state-box">
                    <i class="fas fa-folder-open"></i>
                    <p>No materials or assessments yet. Add materials and assessments first, then organize them here.</p>
                    <a href="${pageContext.request.contextPath}/instructor/materials" class="btn btn-primary">Add Materials</a>
                </div>
            </c:if>

            <c:if test="${not empty materials}">
                <div class="organizer-shell">
                    <div class="organizer-section-label">
                        <i class="fas fa-layer-group"></i> Learning Sequence
                    </div>

                    <div id="materialsContainer" class="organizer-list">
                        <c:forEach var="material" items="${materials}">
                            <div class="organizer-item organizer-item-material" draggable="true" data-id="${material.materialId}">
                                <div class="organizer-item-header">
                                    <i class="fas fa-grip-vertical organizer-drag-handle"></i>
                                    <div class="organizer-item-icon">
                                        <i class="fas fa-file-alt"></i>
                                    </div>
                                    <div class="organizer-item-content">
                                        <div class="organizer-item-title">${material.title}</div>
                                        <div class="organizer-item-meta">Material • Order: <c:out value="${material.displayOrder}" default="N/A"/></div>
                                    </div>
                                    <div class="organizer-item-actions">
                                        <a href="${pageContext.request.contextPath}/instructor/materials?courseId=${course.courseId}" class="btn btn-secondary btn-sm" title="Edit Material">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <c:forEach var="assessment" items="${assessmentsAfterMaterial[material.materialId]}">
                                <div class="organizer-item organizer-item-assessment" draggable="true" data-id="${assessment.assessmentId}" data-type="assessment" data-material-id="${material.materialId}">
                                    <div class="organizer-item-header">
                                        <i class="fas fa-grip-vertical organizer-drag-handle"></i>
                                        <div class="organizer-item-icon">
                                            <i class="fas fa-clipboard-check"></i>
                                        </div>
                                        <div class="organizer-item-content">
                                            <div class="organizer-item-title">${assessment.title}</div>
                                            <div class="organizer-item-meta">Assessment (${assessment.type}) • Placed after this material</div>
                                        </div>
                                        <div class="organizer-item-actions">
                                            <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${course.courseId}&assessmentId=${assessment.assessmentId}" class="btn btn-secondary btn-sm" title="Edit Assessment">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:forEach>
                    </div>

                    <div class="organizer-final-section">
                        <div class="organizer-section-label">
                            <i class="fas fa-flag-checkered"></i> Final Assessments
                        </div>
                        <div id="finalAssessmentsContainer" class="final-assessments-container">
                            <c:forEach var="assessment" items="${finalAssessments}">
                                <div class="organizer-item organizer-item-assessment organizer-item-final" draggable="true" data-id="${assessment.assessmentId}" data-type="assessment" data-material-id="final">
                                    <div class="organizer-item-header">
                                        <i class="fas fa-grip-vertical organizer-drag-handle"></i>
                                        <div class="organizer-item-icon">
                                            <i class="fas fa-clipboard-list"></i>
                                        </div>
                                        <div class="organizer-item-content">
                                            <div class="organizer-item-title">${assessment.title}</div>
                                            <div class="organizer-item-meta">Assessment (${assessment.type}) • Appears after all materials</div>
                                        </div>
                                        <div class="organizer-item-actions">
                                            <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${course.courseId}&assessmentId=${assessment.assessmentId}" class="btn btn-secondary btn-sm" title="Edit Assessment">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty finalAssessments}">
                                <div class="drop-zone-placeholder">
                                    <i class="fas fa-hand-point-up"></i>
                                    <span>Drop assessments here to place them at the end of the course.</span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </c:if>
        </section>
    </div>
</main>

<script>
let draggedElement = null;
let draggedType = null;

document.addEventListener('DOMContentLoaded', function() {
    initializeDragAndDrop();
});

function initializeDragAndDrop() {
    const container = document.getElementById('materialsContainer');
    const finalSection = document.getElementById('finalAssessmentsContainer');

    if (!container) {
        return;
    }

    const materials = container.querySelectorAll('.organizer-item-material');
    materials.forEach(item => {
        item.addEventListener('dragstart', handleDragStart);
        item.addEventListener('dragend', handleDragEnd);
        item.addEventListener('dragover', handleDragOver);
        item.addEventListener('drop', handleDrop);
        item.addEventListener('dragenter', handleDragEnter);
        item.addEventListener('dragleave', handleDragLeave);
    });

    const assessments = document.querySelectorAll('.organizer-item-assessment');
    assessments.forEach(item => {
        item.addEventListener('dragstart', handleDragStart);
        item.addEventListener('dragend', handleDragEnd);
    });

    if (finalSection) {
        finalSection.addEventListener('dragover', handleDragOver);
        finalSection.addEventListener('drop', handleDropInFinal);
        finalSection.addEventListener('dragenter', handleDragEnter);
        finalSection.addEventListener('dragleave', handleDragLeave);
    }
}

function handleDragStart(e) {
    draggedElement = this;
    draggedType = this.dataset.type || 'material';
    this.classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/html', this.innerHTML);
}

function handleDragEnd() {
    this.classList.remove('dragging');
    document.querySelectorAll('.organizer-item-material, #finalAssessmentsContainer').forEach(item => {
        item.classList.remove('drag-over');
    });
    draggedElement = null;
    draggedType = null;
}

function handleDragOver(e) {
    if (e.preventDefault) {
        e.preventDefault();
    }
    e.dataTransfer.dropEffect = 'move';
    return false;
}

function handleDragEnter() {
    if (draggedElement !== this) {
        this.classList.add('drag-over');
    }
}

function handleDragLeave() {
    this.classList.remove('drag-over');
}

function handleDrop(e) {
    if (e.stopPropagation) {
        e.stopPropagation();
    }
    if (e.preventDefault) {
        e.preventDefault();
    }

    this.classList.remove('drag-over');

    if (!draggedElement || draggedElement === this) {
        return false;
    }

    if (draggedType === 'material') {
        const container = document.getElementById('materialsContainer');
        const allMaterials = Array.from(container.querySelectorAll('.organizer-item-material'));
        const draggedIndex = allMaterials.indexOf(draggedElement);
        const targetIndex = allMaterials.indexOf(this);

        if (draggedIndex < targetIndex) {
            this.parentNode.insertBefore(draggedElement, this.nextSibling);
        } else {
            this.parentNode.insertBefore(draggedElement, this);
        }

        moveAssociatedAssessments(draggedElement);
    } else if (draggedType === 'assessment') {
        const targetMaterialId = this.dataset.id;
        draggedElement.remove();

        let insertAfter = this;
        let nextSibling = this.nextElementSibling;
        while (nextSibling && nextSibling.classList.contains('organizer-item-assessment')) {
            insertAfter = nextSibling;
            nextSibling = nextSibling.nextElementSibling;
        }
        insertAfter.parentNode.insertBefore(draggedElement, insertAfter.nextSibling);
        draggedElement.dataset.materialId = targetMaterialId;

        const metaElement = draggedElement.querySelector('.organizer-item-meta');
        if (metaElement) {
            const typeText = metaElement.textContent.split('•')[0].trim();
            metaElement.textContent = typeText + ' • Placed after this material';
        }
    }

    return false;
}

function handleDropInFinal(e) {
    if (e.stopPropagation) {
        e.stopPropagation();
    }
    if (e.preventDefault) {
        e.preventDefault();
    }

    this.classList.remove('drag-over');

    if (!draggedElement || draggedType !== 'assessment') {
        return false;
    }

    const placeholder = this.querySelector('.drop-zone-placeholder');
    if (placeholder) {
        placeholder.remove();
    }

    draggedElement.remove();
    this.appendChild(draggedElement);
    draggedElement.dataset.materialId = 'final';

    const metaElement = draggedElement.querySelector('.organizer-item-meta');
    if (metaElement) {
        const typeText = metaElement.textContent.split('•')[0].trim();
        metaElement.textContent = typeText + ' • Appears after all materials';
    }

    return false;
}

function moveAssociatedAssessments(materialElement) {
    let nextElement = materialElement.nextElementSibling;
    const associatedAssessments = [];

    while (nextElement && nextElement.classList.contains('organizer-item-assessment')) {
        associatedAssessments.push(nextElement);
        nextElement = nextElement.nextElementSibling;
    }

    associatedAssessments.forEach(assessment => {
        materialElement.parentNode.insertBefore(assessment, materialElement.nextSibling);
    });
}

function saveContentOrder() {
    const container = document.getElementById('materialsContainer');
    if (!container) {
        return;
    }

    const materialItems = container.querySelectorAll('.organizer-item-material');
    const materialIds = Array.from(materialItems).map(item => item.dataset.id);

    const assessmentPlacements = [];
    const allAssessments = document.querySelectorAll('.organizer-item-assessment');
    allAssessments.forEach(assessment => {
        assessmentPlacements.push({
            id: assessment.dataset.id,
            materialId: assessment.dataset.materialId
        });
    });

    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/instructor/content-organizer';

    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'saveContentOrder';
    form.appendChild(actionInput);

    const courseIdInput = document.createElement('input');
    courseIdInput.type = 'hidden';
    courseIdInput.name = 'courseId';
    courseIdInput.value = '${course.courseId}';
    form.appendChild(courseIdInput);

    materialIds.forEach(id => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'materialIds[]';
        input.value = id;
        form.appendChild(input);
    });

    assessmentPlacements.forEach(placement => {
        const idInput = document.createElement('input');
        idInput.type = 'hidden';
        idInput.name = 'assessmentIds[]';
        idInput.value = placement.id;
        form.appendChild(idInput);

        const materialInput = document.createElement('input');
        materialInput.type = 'hidden';
        materialInput.name = 'assessmentMaterials[]';
        materialInput.value = placement.materialId;
        form.appendChild(materialInput);
    });

    document.body.appendChild(form);
    form.submit();
}
</script>
</body>
</html>

