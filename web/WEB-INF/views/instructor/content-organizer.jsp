<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organize Course Content - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .organizer-item {
            padding: 12px 16px;
            margin-bottom: 8px;
            border-radius: 4px;
            cursor: move;
            transition: box-shadow 0.2s;
        }
        .organizer-item:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .organizer-item-material {
            border: 1px solid #bfdbfe;
            background: #f9fafb;
        }
        .organizer-item-assessment {
            border: 1px solid #fed7aa;
            background: #fefce8;
            margin-left: 24px;
        }
        .organizer-item-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 4px;
        }
        .organizer-drag-handle {
            color: #9ca3af;
            cursor: grab;
        }
        .organizer-drag-handle:active {
            cursor: grabbing;
        }
        .organizer-item-icon {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            color: #6b7280;
        }
        .organizer-item-content {
            flex: 1;
        }
        .organizer-item-title {
            font-weight: 600;
            color: #111827;
            margin: 0 0 4px 0;
            font-size: 14px;
        }
        .organizer-item-meta {
            font-size: 12px;
            color: #6b7280;
        }
        .organizer-item-actions {
            display: flex;
            gap: 8px;
        }
        .organizer-final-section {
            margin-top: 24px;
            padding-top: 24px;
            border-top: 2px dashed #e5e7eb;
        }
        .organizer-section-label {
            font-size: 12px;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 12px;
        }
        .dragging {
            opacity: 0.5;
        }
        .drag-over {
            border-top: 3px solid #1a73e8;
        }
    </style>
</head>
<body>
<header class="app-header">
    <div class="header-left">
        <div class="logo-section">
            <i class="fas fa-graduation-cap"></i>
            <span>PSM E-Learning</span>
        </div>
        <h1 class="page-title">Organize Course Content</h1>
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
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="page-actions" style="margin-bottom: 16px;">
            <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Courses
            </a>
            <button class="btn btn-primary" onclick="saveContentOrder()">
                <i class="fas fa-save"></i> Save Order
            </button>
        </div>

        <c:if test="${param.success == 'reordered'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Material order saved successfully!
            </div>
        </c:if>

        <div class="course-card">
            <h2 style="margin: 0 0 8px 0; font-size: 20px; font-weight: 600;">${course.courseName}</h2>
            <p style="margin: 0 0 20px 0; color: #6b7280; font-size: 14px;">
                Drag and drop materials to reorder them. Drag assessments to place them after any material or in the final section.
            </p>

            <div class="organizer-section-label">
                <i class="fas fa-layer-group"></i> Course Content Flow
            </div>

            <div id="materialsContainer">
                <c:forEach var="material" items="${materials}">
                    <div class="organizer-item organizer-item-material" draggable="true" data-id="${material.materialId}">
                        <div class="organizer-item-header">
                            <i class="fas fa-grip-vertical organizer-drag-handle"></i>
                            <div class="organizer-item-icon">
                                <i class="fas fa-file"></i>
                            </div>
                            <div class="organizer-item-content">
                                <div class="organizer-item-title">
                                    <i class="fas fa-folder"></i> ${material.title}
                                </div>
                                <div class="organizer-item-meta">
                                    Material • Order: ${material.displayOrder != null ? material.displayOrder : 'N/A'}
                                </div>
                            </div>
                            <div class="organizer-item-actions">
                                <a href="${pageContext.request.contextPath}/instructor/materials?courseId=${course.courseId}" 
                                   class="btn btn-secondary btn-sm" title="Edit Material">
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
                                    <i class="fas fa-clipboard-list"></i>
                                </div>
                                <div class="organizer-item-content">
                                    <div class="organizer-item-title">
                                        <i class="fas fa-arrow-right" style="font-size: 10px; margin-right: 4px;"></i>
                                        ${assessment.title}
                                    </div>
                                    <div class="organizer-item-meta">
                                        Assessment (${assessment.type}) • Placed after this material
                                    </div>
                                </div>
                                <div class="organizer-item-actions">
                                    <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${course.courseId}&assessmentId=${assessment.assessmentId}" 
                                       class="btn btn-secondary btn-sm" title="Change Placement">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:forEach>
            </div>

            <div class="organizer-final-section" id="finalSection">
                <div class="organizer-section-label">
                    <i class="fas fa-flag-checkered"></i> Final Assessments <small style="font-weight: normal; opacity: 0.7;">(Drop assessments here)</small>
                </div>
                <div id="finalAssessmentsContainer">
                    <c:forEach var="assessment" items="${finalAssessments}">
                        <div class="organizer-item organizer-item-assessment" draggable="true" data-id="${assessment.assessmentId}" data-type="assessment" data-material-id="final" style="margin-left: 0;">
                            <div class="organizer-item-header">
                                <i class="fas fa-grip-vertical organizer-drag-handle"></i>
                                <div class="organizer-item-icon">
                                    <i class="fas fa-clipboard-list"></i>
                                </div>
                                <div class="organizer-item-content">
                                    <div class="organizer-item-title">
                                        ${assessment.title}
                                    </div>
                                    <div class="organizer-item-meta">
                                        Assessment (${assessment.type}) • Appears after all materials
                                    </div>
                                </div>
                                <div class="organizer-item-actions">
                                    <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${course.courseId}&assessmentId=${assessment.assessmentId}" 
                                       class="btn btn-secondary btn-sm" title="Change Placement">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty finalAssessments}">
                        <div class="drop-zone-placeholder" style="padding: 24px; text-align: center; color: #9ca3af; border: 2px dashed #e5e7eb; border-radius: 4px; background: #f9fafb;">
                            <i class="fas fa-hand-point-up"></i> Drop assessments here to place them at the end of the course
                        </div>
                    </c:if>
                </div>
            </div>

            <c:if test="${empty materials}">
                <div class="empty-state-box">
                    <i class="fas fa-folder-open"></i>
                    <p>No materials or assessments yet. Add materials and assessments to organize them here.</p>
                    <a href="${pageContext.request.contextPath}/instructor/materials" class="btn btn-primary">Add Materials</a>
                </div>
            </c:if>
        </div>
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
    
    // Materials are drop targets
    const materials = container.querySelectorAll('.organizer-item-material');
    materials.forEach(item => {
        item.addEventListener('dragstart', handleDragStart);
        item.addEventListener('dragend', handleDragEnd);
        item.addEventListener('dragover', handleDragOver);
        item.addEventListener('drop', handleDrop);
        item.addEventListener('dragenter', handleDragEnter);
        item.addEventListener('dragleave', handleDragLeave);
    });
    
    // Assessments are draggable
    const assessments = document.querySelectorAll('.organizer-item-assessment');
    assessments.forEach(item => {
        item.addEventListener('dragstart', handleDragStart);
        item.addEventListener('dragend', handleDragEnd);
    });
    
    // Final section is a drop target
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

function handleDragEnd(e) {
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

function handleDragEnter(e) {
    if (draggedElement !== this) {
        this.classList.add('drag-over');
    }
}

function handleDragLeave(e) {
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
        // Material dropped on another material - reorder
        const container = document.getElementById('materialsContainer');
        const allMaterials = Array.from(container.querySelectorAll('.organizer-item-material'));
        const draggedIndex = allMaterials.indexOf(draggedElement);
        const targetIndex = allMaterials.indexOf(this);
        
        if (draggedIndex < targetIndex) {
            this.parentNode.insertBefore(draggedElement, this.nextSibling);
        } else {
            this.parentNode.insertBefore(draggedElement, this);
        }
        
        // Move associated assessments with the material
        moveAssociatedAssessments(draggedElement);
    } else if (draggedType === 'assessment') {
        // Assessment dropped on a material - place after it
        const targetMaterialId = this.dataset.id;
        
        // Remove assessment from current location
        draggedElement.remove();
        
        // Insert after the target material (after any existing assessments)
        let insertAfter = this;
        let nextSibling = this.nextElementSibling;
        while (nextSibling && nextSibling.classList.contains('organizer-item-assessment')) {
            insertAfter = nextSibling;
            nextSibling = nextSibling.nextElementSibling;
        }
        insertAfter.parentNode.insertBefore(draggedElement, insertAfter.nextSibling);
        
        // Update data attribute
        draggedElement.dataset.materialId = targetMaterialId;
        
        // Update visual feedback
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
    
    // Remove placeholder if exists
    const placeholder = this.querySelector('.drop-zone-placeholder');
    if (placeholder) {
        placeholder.remove();
    }
    
    // Remove assessment from current location
    draggedElement.remove();
    
    // Add to final section
    this.appendChild(draggedElement);
    
    // Update data attribute
    draggedElement.dataset.materialId = 'final';
    
    // Update visual feedback
    const metaElement = draggedElement.querySelector('.organizer-item-meta');
    if (metaElement) {
        const typeText = metaElement.textContent.split('•')[0].trim();
        metaElement.textContent = typeText + ' • Appears after all materials';
    }
    
    return false;
}

function moveAssociatedAssessments(materialElement) {
    const materialId = materialElement.dataset.id;
    let nextElement = materialElement.nextElementSibling;
    const associatedAssessments = [];
    
    // Collect all consecutive assessment items
    while (nextElement && nextElement.classList.contains('organizer-item-assessment')) {
        associatedAssessments.push(nextElement);
        nextElement = nextElement.nextElementSibling;
    }
    
    // Re-insert them after the material
    associatedAssessments.forEach(assessment => {
        materialElement.parentNode.insertBefore(assessment, materialElement.nextSibling);
    });
}

function saveContentOrder() {
    const container = document.getElementById('materialsContainer');
    const materialItems = container.querySelectorAll('.organizer-item-material');
    const materialIds = Array.from(materialItems).map(item => item.dataset.id);
    
    // Collect assessment placements
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
