<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="assessmentFormAction" value="${not empty selectedAssessment ? 'updateAssessment' : 'createAssessment'}" />
<c:set var="selectedQuestionCount" value="${not empty selectedAssessment and questionCountByAssessmentId[selectedAssessment.assessmentId] != null ? questionCountByAssessmentId[selectedAssessment.assessmentId] : 0}" />

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessment-builder.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessment-flow.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Assessment Builder"/>
</jsp:include>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>


<main class="app-main">
    <div class="content-wrapper ia-workspace">
        <jsp:include page="/WEB-INF/views/instructor/fragments/assessment-breadcrumb.jsp">
            <jsp:param name="currentLabel" value="${not empty selectedAssessment ? 'Settings' : 'New Assessment'}"/>
        </jsp:include>

            <c:set var="currentCourseFlow" value="assessments"/>
            <jsp:include page="/WEB-INF/views/instructor/fragments/course-flow-nav.jsp"/>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Assessment Builder</p>
                <h2>${not empty selectedAssessment ? 'Assessment Settings' : 'Create New Assessment'}</h2>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard&courseId=${selectedCourse.courseId}" class="btn btn-secondary">
                    <i class="fas fa-layer-group"></i> Assessment Library
                </a>
                <c:if test="${not empty selectedAssessment}">
                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-inline-form">
                        <input type="hidden" name="action" value="publishAssessment" />
                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                        <button type="submit" class="btn btn-primary" ${selectedQuestionCount == 0 ? 'disabled' : ''} title="${selectedQuestionCount == 0 ? 'Add at least one question before publishing.' : 'Publish this assessment'}">
                            <i class="fas fa-paper-plane"></i> Publish
                        </button>
                    </form>
                    <a href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&courseId=${selectedCourse.courseId}&id=${selectedAssessment.assessmentId}" class="btn btn-danger" onclick="return confirm('Archive this assessment? You can restore it later from archive.');">
                        <i class="fas fa-box-archive"></i> Archive Assessment
                    </a>
                </c:if>
            </div>
        </section>

        <c:if test="${param.success == 'created'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment details saved. Continue with question setup.</div>
        </c:if>
        <c:if test="${param.success == 'updated'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment settings updated successfully.</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>

        <div class="ia-stepper">
            <div class="ia-step active">
                <div class="ia-step-circle">1</div>
                <div class="ia-step-label">Assessment Settings</div>
            </div>
            <div class="ia-step-line"></div>
            <div class="ia-step ${not empty selectedAssessment ? '' : 'disabled'}">
                <div class="ia-step-circle">2</div>
                <div class="ia-step-label">Question Bank</div>
            </div>
        </div>

        <div class="ia-flow-grid-single">
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
                                    <option value="Assignment" ${not empty selectedAssessment and selectedAssessment.type == 'Assignment' ? 'selected' : ''}>Assignment (Written / PDF)</option>
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

                    <div class="builder-actions" style="margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--ins-border); display: flex; gap: 12px; justify-content: flex-end;">
                        <c:choose>
                            <c:when test="${not empty selectedAssessment}">
                                <button class="btn btn-secondary" type="submit" data-workflow-action="details">
                                    <i class="fas fa-floppy-disk"></i> Save Settings
                                </button>
                                <button class="btn btn-primary" type="submit" data-workflow-action="questions">
                                    <i class="fas fa-arrow-right"></i> Save & Continue to Questions
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-primary" type="submit" data-workflow-action="questions">
                                    <i class="fas fa-arrow-right"></i> Create & Continue to Questions
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </div>

            <!-- Right-side configuration panel removed per UX update -->
        </div>
    </div>
</main>


<script src="${pageContext.request.contextPath}/js/instructor-assessment-builder.js"></script>
</body>
</html>
