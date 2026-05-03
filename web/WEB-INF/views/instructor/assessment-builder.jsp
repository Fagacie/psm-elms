<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="assessmentFormAction" value="${not empty selectedAssessment ? 'updateAssessment' : 'createAssessment'}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty selectedAssessment ? 'Edit Assessment' : 'Create Assessment'} - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    <style>
        .hidden-field {
            display: none !important;
        }
    </style>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Assessment Builder"/>
</jsp:include>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>


<main class="app-main">
    <div class="content-wrapper ia-workspace">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <c:if test="${not empty selectedCourse}">
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}">${selectedCourse.courseName}</a>
            </c:if>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}">Assessment Hub</a>
            <span>&gt;</span>
            <span>${not empty selectedAssessment ? 'Settings' : 'New Assessment'}</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Assessment Builder</p>
                <h2>${not empty selectedAssessment ? 'Assessment Settings' : 'Create New Assessment'}</h2>
                <p>Configure the foundational settings for this assessment. Changes here impact how students interact with and submit their work.</p>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Hub
                </a>
            </div>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>

        <div style="display: grid; grid-template-columns: 1fr 340px; gap: 32px; align-items: start;">
            <!-- Main Form Column -->
            <div class="section-card">
                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-wizard-form" id="assessmentDetailsForm">
                    <input type="hidden" name="action" value="${assessmentFormAction}" />
                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                    <c:if test="${not empty selectedAssessment}">
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                    </c:if>
                    <input type="hidden" name="workflowAction" id="assessmentWorkflowAction" value="details" />

                    <div style="display: grid; gap: 24px;">
                        <div>
                            <label for="assessmentTitle" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Assessment Title <span style="color: #dc2626;">*</span></label>
                            <input id="assessmentTitle" name="title" type="text" value="${not empty selectedAssessment ? selectedAssessment.title : ''}" placeholder="e.g., Mid-Term Exam, Final Project" required style="width: 100%; padding: 14px; font-size: 1.05rem; font-weight: 600;" />
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div>
                                <label for="assessmentType" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Type <span style="color: #dc2626;">*</span></label>
                                <select id="assessmentType" name="type" required style="width: 100%; padding: 12px;">
                                    <option value="">Select type</option>
                                    <option value="Quiz" ${not empty selectedAssessment and selectedAssessment.type == 'Quiz' ? 'selected' : ''}>Quiz (Auto-graded MCQ)</option>
                                    <option value="Exam" ${not empty selectedAssessment and selectedAssessment.type == 'Exam' ? 'selected' : ''}>Exam (Auto-graded MCQ)</option>
                                    <option value="Assignment" ${not empty selectedAssessment and selectedAssessment.type == 'Assignment' ? 'selected' : ''}>Assignment (Manual Upload)</option>
                                </select>
                            </div>

                            <div class="dynamic-field" data-type-visible="objective">
                                <label for="assessmentDuration" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Duration (Minutes) <span style="color: #dc2626;">*</span></label>
                                <input id="assessmentDuration" name="duration" type="number" min="1" max="480" value="${not empty selectedAssessment and not empty selectedAssessment.duration ? selectedAssessment.duration : ''}" placeholder="e.g., 60" style="width: 100%; padding: 12px;" />
                            </div>

                            <div class="dynamic-field" data-type-visible="assignment">
                                <label for="submissionMode" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Submission Format</label>
                                <select id="submissionMode" name="submissionMode" style="width: 100%; padding: 12px;">
                                    <option value="both" ${not empty selectedAssessment and selectedAssessment.submissionMode == 'both' ? 'selected' : ''}>File & Text</option>
                                    <option value="file" ${not empty selectedAssessment and selectedAssessment.submissionMode == 'file' ? 'selected' : ''}>File Only</option>
                                    <option value="text" ${not empty selectedAssessment and selectedAssessment.submissionMode == 'text' ? 'selected' : ''}>Text Only</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <label for="assessmentInstructions" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Instructions & Description</label>
                            <textarea id="assessmentInstructions" name="instructions" rows="5" placeholder="What should students know before starting?" style="width: 100%; padding: 14px;">${not empty selectedAssessment ? selectedAssessment.instructions : ''}</textarea>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div class="dynamic-field" data-type-visible="objective">
                                <label for="assessmentMaxAttempts" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Attempts Allowed</label>
                                <input id="assessmentMaxAttempts" name="maxAttempts" type="number" min="1" max="10" value="${not empty selectedAssessment and not empty selectedAssessment.maxAttempts ? selectedAssessment.maxAttempts : 1}" style="width: 100%; padding: 12px;" />
                            </div>

                            <div class="dynamic-field" data-type-visible="assignment">
                                <label for="assessmentTotalMarks" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Total Marks <span style="color: #dc2626;">*</span></label>
                                <input id="assessmentTotalMarks" name="totalMarks" type="number" min="1" step="1" value="${not empty selectedAssessment and not empty selectedAssessment.totalMarks ? selectedAssessment.totalMarks : ''}" placeholder="e.g., 100" style="width: 100%; padding: 12px;" />
                            </div>

                            <div>
                                <label for="placement" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Release Logic (Placement)</label>
                                <select id="placement" name="placement" required style="width: 100%; padding: 12px;">
                                    <option value="final">Release upon Course Completion</option>
                                    <option value="afterEveryMaterial">Release after each material</option>
                                    <optgroup label="After Specific Material">
                                        <c:forEach var="m" items="${materials}">
                                            <option value="afterMaterial:${m.materialId}">${m.title}</option>
                                        </c:forEach>
                                    </optgroup>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div style="margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--ins-border); display: flex; gap: 12px; justify-content: flex-end;">
                        <button class="btn btn-primary" type="submit">
                            <i class="fas fa-save"></i> ${not empty selectedAssessment ? 'Update Settings' : 'Create & Continue'}
                        </button>
                    </div>
                </form>
            </div>

            <!-- Sidebar Info Column -->
            <aside>
                <div class="section-card" style="padding: 24px; background: #f8fafc;">
                    <h4 style="margin: 0 0 16px; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--ins-muted);">Configuration Context</h4>
                    <div style="display: grid; gap: 16px;">
                        <div class="ia-metric" style="padding: 16px; background: #fff; border: 1px solid var(--ins-border); border-radius: 12px;">
                            <span style="font-size: 0.75rem; color: var(--ins-muted); display: block; margin-bottom: 4px;">Course Workspace</span>
                            <strong style="font-size: 1rem; color: var(--ins-primary);">${selectedCourse.courseName}</strong>
                        </div>
                        
                        <c:if test="${not empty selectedAssessment}">
                            <div class="ia-metric" style="padding: 16px; background: #fff; border: 1px solid var(--ins-border); border-radius: 12px;">
                                <span style="font-size: 0.75rem; color: var(--ins-muted); display: block; margin-bottom: 4px;">Live Submissions</span>
                                <strong style="font-size: 1.2rem; color: var(--ins-text);">${submissionCountByAssessmentId[selectedAssessment.assessmentId]}</strong>
                            </div>
                        </c:if>

                        <div style="padding: 16px; background: var(--ins-accent-soft); border: 1px solid rgba(20, 83, 45, 0.1); border-radius: 12px; font-size: 0.85rem; line-height: 1.6;">
                            <i class="fas fa-circle-info" style="color: var(--ins-primary); margin-right: 6px;"></i>
                            <strong>Pro Tip:</strong> Quizzes and Exams are auto-graded based on the Question Bank. Assignments require you to grade them manually.
                        </div>
                        
                        <c:if test="${not empty selectedAssessment and (selectedAssessment.type == 'Quiz' or selectedAssessment.type == 'Exam')}">
                            <a href="${pageContext.request.contextPath}/instructor/assessments?view=questions&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}" class="btn btn-secondary" style="width: 100%; justify-content: center;">
                                <i class="fas fa-list-check"></i> Edit Question Bank
                            </a>
                        </c:if>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</main>


<script>
    document.addEventListener("DOMContentLoaded", () => {
        // Sidebar Toggle
        const toggleBtn = document.getElementById("instructorMenuToggle");
        if (toggleBtn) {
            toggleBtn.addEventListener("click", () => {
                document.body.classList.toggle("ins-shell-collapsed");
            });
        }

        // Dynamic Form Logic
        const typeSelect = document.getElementById('assessmentType');
        const durationInput = document.getElementById('assessmentDuration');
        const marksInput = document.getElementById('assessmentTotalMarks');
        const objectiveFields = document.querySelectorAll('[data-type-visible="objective"]');
        const assignmentFields = document.querySelectorAll('[data-type-visible="assignment"]');

        function updateFormFields() {
            const type = typeSelect.value;
            
            if (type === 'Quiz' || type === 'Exam') {
                objectiveFields.forEach(f => f.classList.remove('hidden-field'));
                assignmentFields.forEach(f => f.classList.add('hidden-field'));
                durationInput.setAttribute('required', 'required');
                marksInput.removeAttribute('required');
            } else if (type === 'Assignment') {
                assignmentFields.forEach(f => f.classList.remove('hidden-field'));
                objectiveFields.forEach(f => f.classList.add('hidden-field'));
                durationInput.removeAttribute('required');
                marksInput.setAttribute('required', 'required');
            } else {
                objectiveFields.forEach(f => f.classList.add('hidden-field'));
                assignmentFields.forEach(f => f.classList.add('hidden-field'));
                durationInput.removeAttribute('required');
                marksInput.removeAttribute('required');
            }
        }

        typeSelect.addEventListener('change', updateFormFields);
        
        // Initialize state on load
        updateFormFields();
    });
</script>
</body>
</html>
