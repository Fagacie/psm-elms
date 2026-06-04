<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <c:set var="isAssignment"
                value="${not empty selectedAssessment and selectedAssessment.type == 'Assignment'}" />

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Question Builder - Instructor</title>
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessment-flow.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/InstructorAssessment.module.css?v=6">
                <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp" />
            </head>

            <body class="instructor-ui">
                <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
                    <jsp:param name="pageTitle" value="Question Builder" />
                </jsp:include>

                <c:set var="activeInstructorPage" value="assessments" />
                <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp" />


                <main class="app-main">
                    <div class="content-wrapper">
                        <jsp:include page="/WEB-INF/views/instructor/fragments/assessment-breadcrumb.jsp">
                            <jsp:param name="currentLabel" value="Question Bank" />
                        </jsp:include>

                        <c:set var="currentCourseFlow" value="assessments" scope="request" />
                        <jsp:include page="/WEB-INF/views/instructor/fragments/course-flow-nav.jsp" />

                        <section class="ins-page-head">
                            <div>
                                <p class="ins-page-kicker">
                                    <c:out
                                        value="${isAssignment ? 'Assignment Prompt Builder' : 'MCQ Question Engine'}" />
                                </p>
                                <h2>
                                    <c:out value="${isAssignment ? 'Assignment Items for ' : 'Bank for '}" />
                                    ${selectedAssessment.title}
                                </h2>
                            </div>
                            <div class="ins-hero-actions">
                                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}#assessments"
                                    class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Back to Course Workspace
                                </a>
                                <a href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}"
                                    class="btn btn-secondary">
                                    <i class="fas fa-sliders"></i> Settings
                                </a>
                                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}&success=draftsaved#assessments"
                                    class="btn btn-secondary">
                                    <i class="fas fa-floppy-disk"></i> Save Draft
                                </a>
                                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}&success=finished#assessments"
                                    class="btn btn-secondary">
                                    <i class="fas fa-check"></i> Finish Setup
                                </a>
                                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments"
                                    class="ia-inline-form">
                                    <input type="hidden" name="action" value="publishAssessment" />
                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                                    <input type="hidden" name="assessmentId"
                                        value="${selectedAssessment.assessmentId}" />
                                    <button type="submit" class="btn btn-primary" ${empty questions ? 'disabled' : '' }
                                        title="${empty questions ? 'Add at least one question before publishing.' : 'Publish this assessment'}">
                                        <i class="fas fa-paper-plane"></i> Publish Assessment
                                    </button>
                                </form>
                                <a href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&courseId=${selectedCourse.courseId}&id=${selectedAssessment.assessmentId}"
                                    class="btn btn-danger"
                                    onclick="return confirm('Archive this assessment? You can restore it later from archive.');">
                                    <i class="fas fa-box-archive"></i> Archive
                                </a>
                            </div>
                        </section>

                        <!-- Messages -->
                        <c:if test="${param.success == 'created'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment created.
                                Continue by adding questions, then save draft or publish.</div>
                        </c:if>
                        <c:if test="${param.success == 'draftsaved'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Draft saved. You can
                                publish anytime when ready.</div>
                        </c:if>
                        <c:if test="${param.success == 'finished'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment setup
                                completed. You can continue editing anytime.</div>
                        </c:if>
                        <c:if test="${param.success == 'published'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment published
                                successfully.</div>
                        </c:if>
                        <c:if test="${param.success == 'qcreated'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Question added to bank.
                            </div>
                        </c:if>
                        <c:if test="${param.success == 'qupdated'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assignment item updated successfully.
                            </div>
                        </c:if>
                        <c:if test="${param.success == 'qdeleted'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Question removed.</div>
                        </c:if>
                        <c:if test="${param.error == 'qupdate'}">
                            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Failed to update assignment item.</div>
                        </c:if>
                        <c:if test="${param.error == 'qoptions'}">
                            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Invalid options.
                                Please provide A/B and a correct choice.</div>
                        </c:if>
                        <c:if test="${param.error == 'publish_no_questions'}">
                            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Add at least one
                                question before publishing this assessment.</div>
                        </c:if>
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}
                            </div>
                        </c:if>

                        <div class="ia-stepper">
                            <a href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}"
                                class="ia-step completed" style="text-decoration: none;">
                                <div class="ia-step-circle"><i class="fas fa-check"></i></div>
                                <div class="ia-step-label">Assessment Settings</div>
                            </a>
                            <div class="ia-step-line"></div>
                            <div class="ia-step active">
                                <div class="ia-step-circle">2</div>
                                <div class="ia-step-label">Question Bank</div>
                            </div>
                        </div>

                        <div class="ia-flow-grid-question">
                            <!-- Left Side: Add/Edit Question Form -->
                            <div class="section-card ia-flow-sticky" style="padding: 24px;">

                                <c:choose>
                                    <%-- ASSIGNMENT EDIT MODE: item already exists --%>
                                    <c:when test="${isAssignment and not empty questions}">
                                        <c:set var="existingQ" value="${questions[0]}" />
                                        <div class="ia-panel-head">
                                            <h3><i class="fas fa-pen-to-square ia-panel-title-icon"></i> Edit Assignment Item</h3>
                                        </div>

                                        <form method="post" action="${pageContext.request.contextPath}/instructor/assessments"
                                            class="ia-form ia-question-form" enctype="multipart/form-data">
                                            <input type="hidden" name="action" value="updateQuestion" />
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                                            <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                                            <input type="hidden" name="questionId" value="${existingQ.questionId}" />
                                            <input type="hidden" name="workflowAction" value="questions" />
                                            <input type="hidden" name="deleteAttachment" id="deleteAttachmentFlag" value="false" />

                                            <div class="ia-question-form-block">
                                                <label for="createQuestionText" class="field-label">
                                                    Assignment Prompt / Questions
                                                </label>
                                                <textarea id="createQuestionText" name="questionText" rows="4"
                                                    placeholder="Enter the assignment instructions or question text...">${existingQ.questionText}</textarea>
                                            </div>

                                            <%-- File Preview / Upload Toggle --%>
                                            <div class="ia-question-form-block">
                                                <c:choose>
                                                    <c:when test="${not empty existingQ.attachmentUrl}">
                                                        <%-- Existing file preview block --%>
                                                        <div id="iaFilePreview" class="ia-file-preview-block">
                                                            <div class="ia-file-preview-info">
                                                                <span class="ia-file-preview-icon"><i class="fas fa-file-pdf"></i></span>
                                                                <span class="ia-file-preview-name">
                                                                    <c:out value="${not empty existingQ.attachmentName ? existingQ.attachmentName : 'Attachment.pdf'}" />
                                                                </span>
                                                            </div>
                                                            <div class="ia-file-preview-actions">
                                                                <a href="${existingQ.attachmentUrl}" target="_blank" rel="noopener noreferrer" class="btn btn-secondary btn-sm">
                                                                    <i class="fas fa-up-right-from-square"></i> Open
                                                                </a>
                                                                <button type="button" class="btn btn-secondary btn-sm" style="color: #dc2626; border-color: #fee2e2;" id="iaRemoveFileBtn">
                                                                    <i class="fas fa-trash-can"></i> Remove / Replace
                                                                </button>
                                                            </div>
                                                        </div>

                                                        <%-- Hidden upload input, shown after Remove --%>
                                                        <div id="iaFileUploadBlock" style="display: none;">
                                                            <label for="assignmentAttachment" class="field-label">Replace Attachment PDF</label>
                                                            <input id="assignmentAttachment" name="assignmentAttachment" type="file" accept="application/pdf,.pdf" />
                                                            <small style="color: var(--ins-muted); display: block; margin-top: 8px;">
                                                                Select a new PDF, or leave empty to remove the existing one.
                                                            </small>
                                                            <button type="button" class="btn btn-secondary btn-sm" style="margin-top: 8px;" id="iaCancelRemoveBtn">
                                                                <i class="fas fa-undo"></i> Cancel
                                                            </button>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <%-- No existing file, show upload input directly --%>
                                                        <label for="assignmentAttachment" class="field-label">Attach PDF Instructions</label>
                                                        <input id="assignmentAttachment" name="assignmentAttachment" type="file" accept="application/pdf,.pdf" />
                                                        <small style="color: var(--ins-muted); display: block; margin-top: 8px;">Optional. Upload a PDF if you want students to open the assignment brief directly.</small>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="ia-question-form-split">
                                                <div>
                                                    <label for="createMarks" class="field-label">Marks <span style="color: #dc2626;">*</span></label>
                                                    <input id="createMarks" name="marks" type="number" min="0.5" step="0.5"
                                                        value="${existingQ.marks}" required />
                                                </div>
                                            </div>

                                            <button class="btn btn-primary" type="submit">
                                                <i class="fas fa-save"></i> Save Assignment Item
                                            </button>
                                        </form>

                                        <script>
                                            document.addEventListener('DOMContentLoaded', function () {
                                                var previewBlock = document.getElementById('iaFilePreview');
                                                var uploadBlock = document.getElementById('iaFileUploadBlock');
                                                var removeBtn = document.getElementById('iaRemoveFileBtn');
                                                var cancelBtn = document.getElementById('iaCancelRemoveBtn');
                                                var deleteFlag = document.getElementById('deleteAttachmentFlag');
                                                var textField = document.getElementById('createQuestionText');
                                                var fileField = document.getElementById('assignmentAttachment');

                                                if (removeBtn && previewBlock && uploadBlock) {
                                                    removeBtn.addEventListener('click', function () {
                                                        previewBlock.style.display = 'none';
                                                        uploadBlock.style.display = 'block';
                                                        deleteFlag.value = 'true';
                                                    });
                                                }

                                                if (cancelBtn && previewBlock && uploadBlock) {
                                                    cancelBtn.addEventListener('click', function () {
                                                        previewBlock.style.display = '';
                                                        uploadBlock.style.display = 'none';
                                                        deleteFlag.value = 'false';
                                                        if (fileField) fileField.value = '';
                                                    });
                                                }

                                                function syncRequirement() {
                                                    if (!textField) return;
                                                    var hasExisting = previewBlock && previewBlock.style.display !== 'none';
                                                    var hasNewFile = fileField && fileField.files && fileField.files.length > 0;
                                                    textField.required = !(hasExisting || hasNewFile);
                                                }

                                                if (fileField) fileField.addEventListener('change', syncRequirement);
                                                syncRequirement();
                                            });
                                        </script>
                                    </c:when>

                                    <%-- DEFAULT: Add New Question/Assignment --%>
                                    <c:otherwise>
                                        <div class="ia-panel-head">
                                            <h3><i class="fas fa-plus-circle ia-panel-title-icon"></i> New Question</h3>
                                        </div>

                                        <form method="post" action="${pageContext.request.contextPath}/instructor/assessments"
                                            class="ia-form ia-question-form" enctype="multipart/form-data">
                                            <input type="hidden" name="action" value="addQuestion" />
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                                            <input type="hidden" name="assessmentId"
                                                value="${selectedAssessment.assessmentId}" />
                                            <input type="hidden" name="workflowAction" value="questions" />

                                            <div class="ia-question-form-block">
                                                <label for="createQuestionText" class="field-label">
                                                    <c:out
                                                        value="${isAssignment ? 'Assignment Prompt / Questions' : 'Question Prompt'}" />
                                                    <span style="color: #dc2626;">*</span>
                                                </label>
                                                <textarea id="createQuestionText" name="questionText" rows="4"
                                                    placeholder="${isAssignment ? 'Enter the assignment instructions or question text...' : 'Enter the question text...'}"
                                                    ${isAssignment ? '' : 'required' }></textarea>
                                            </div>

                                            <c:if test="${not isAssignment}">
                                                <div class="ia-question-form-grid">
                                                    <div>
                                                        <label class="field-label">Option A <span
                                                                style="color: #dc2626;">*</span></label>
                                                        <input name="optionA" type="text" placeholder="First option" required />
                                                    </div>
                                                    <div>
                                                        <label class="field-label">Option B <span
                                                                style="color: #dc2626;">*</span></label>
                                                        <input name="optionB" type="text" placeholder="Second option"
                                                            required />
                                                    </div>
                                                    <div>
                                                        <label class="field-label">Option C</label>
                                                        <input name="optionC" type="text" placeholder="Optional" />
                                                    </div>
                                                    <div>
                                                        <label class="field-label">Option D</label>
                                                        <input name="optionD" type="text" placeholder="Optional" />
                                                    </div>
                                                </div>

                                                <div class="ia-question-form-split">
                                                    <div>
                                                        <label for="createCorrectOption" class="field-label">Answer <span
                                                                style="color: #dc2626;">*</span></label>
                                                        <select id="createCorrectOption" name="correctOption" required>
                                                            <option value="">Choice</option>
                                                            <option value="A">A</option>
                                                            <option value="B">B</option>
                                                            <option value="C">C</option>
                                                            <option value="D">D</option>
                                                        </select>
                                                    </div>
                                                    <div>
                                                        <label for="createMarks" class="field-label">Marks <span
                                                                style="color: #dc2626;">*</span></label>
                                                        <input id="createMarks" name="marks" type="number" min="0.5" step="0.5"
                                                            value="1" required />
                                                    </div>
                                                </div>
                                            </c:if>

                                            <c:if test="${isAssignment}">
                                                <div class="ia-question-form-block">
                                                    <label for="assignmentAttachment" class="field-label">Attach PDF
                                                        Instructions</label>
                                                    <input id="assignmentAttachment" name="assignmentAttachment" type="file"
                                                        accept="application/pdf,.pdf" />
                                                    <small
                                                        style="color: var(--ins-muted); display: block; margin-top: 8px;">Optional.
                                                        Upload a PDF if you want students to open the assignment brief
                                                        directly.</small>
                                                </div>

                                                <div class="ia-question-form-split">
                                                    <div>
                                                        <label for="createMarks" class="field-label">Marks <span
                                                                style="color: #dc2626;">*</span></label>
                                                        <input id="createMarks" name="marks" type="number" min="0.5" step="0.5"
                                                            value="1" required />
                                                    </div>
                                                </div>
                                            </c:if>

                                            <button class="btn btn-primary" type="submit">
                                                <i class="fas fa-save"></i>
                                                <c:out value="${isAssignment ? 'Add Assignment Item' : 'Add to Bank'}" />
                                            </button>
                                        </form>

                                        <c:if test="${isAssignment}">
                                            <script>
                                                document.addEventListener('DOMContentLoaded', function () {
                                                    var textField = document.getElementById('createQuestionText');
                                                    var fileField = document.getElementById('assignmentAttachment');

                                                    function syncRequirement() {
                                                        if (!textField) {
                                                            return;
                                                        }
                                                        var hasFile = fileField && fileField.files && fileField.files.length > 0;
                                                        textField.required = !hasFile;
                                                    }

                                                    if (fileField) {
                                                        fileField.addEventListener('change', syncRequirement);
                                                    }
                                                    syncRequirement();
                                                });
                                            </script>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Right Side: Questions List -->
                            <div>
                                <div class="ia-title-row">
                                    <h3>Existing Questions</h3>
                                    <span class="ia-count-pill"><strong>${fn:length(questions)}</strong> Total
                                        Items</span>
                                </div>

                                <c:choose>
                                    <c:when test="${empty questions}">
                                        <div class="ia-empty-state">
                                            <div class="ia-empty-icon"><i class="fas fa-layer-group"></i></div>
                                            <h3>Empty Bank</h3>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="display: grid; gap: 20px;">
                                            <c:forEach var="q" items="${questions}" varStatus="status">
                                                <article class="section-card ia-question-card">
                                                    <div class="ia-question-card-head">
                                                        <div style="display: flex; gap: 12px;">
                                                            <div class="ia-question-index">
                                                                ${status.index + 1}
                                                            </div>
                                                            <div class="ia-question-title">
                                                                ${q.questionText}
                                                            </div>
                                                        </div>
                                                        <div style="display: flex; gap: 8px;">
                                                            <span class="ia-question-points">
                                                                ${q.marks} PTS
                                                            </span>
                                                        </div>
                                                    </div>

                                                    <c:choose>
                                                        <c:when test="${isAssignment}">
                                                            <div style="display:grid; gap: 12px; margin-top: 8px;">
                                                                <div class="ia-option-item"
                                                                    style="justify-content: space-between;">
                                                                    <span><strong>Assignment prompt:</strong>
                                                                        ${q.questionText}</span>
                                                                </div>
                                                                <c:if test="${not empty q.attachmentUrl}">
                                                                    <div class="ia-option-item"
                                                                        style="justify-content: space-between;">
                                                                        <span><strong>Attachment:</strong> ${not empty
                                                                            q.attachmentName ? q.attachmentName : 'Open
                                                                            PDF'}</span>
                                                                        <a class="btn btn-secondary btn-sm"
                                                                            href="${q.attachmentUrl}" target="_blank"
                                                                            rel="noopener noreferrer">
                                                                            <i class="fas fa-up-right-from-square"></i>
                                                                            Open PDF
                                                                        </a>
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="ia-options-grid">
                                                                <div
                                                                    class="ia-option-item ${q.correctOption == 'A' ? 'is-correct' : ''}">
                                                                    <span
                                                                        style="font-weight: 800; opacity: 0.5;">A.</span>
                                                                    ${q.optionA}
                                                                    <c:if test="${q.correctOption == 'A'}"><i
                                                                            class="fas fa-check-circle"
                                                                            style="margin-left: auto; color: var(--ins-primary);"></i>
                                                                    </c:if>
                                                                </div>
                                                                <div
                                                                    class="ia-option-item ${q.correctOption == 'B' ? 'is-correct' : ''}">
                                                                    <span
                                                                        style="font-weight: 800; opacity: 0.5;">B.</span>
                                                                    ${q.optionB}
                                                                    <c:if test="${q.correctOption == 'B'}"><i
                                                                            class="fas fa-check-circle"
                                                                            style="margin-left: auto; color: var(--ins-primary);"></i>
                                                                    </c:if>
                                                                </div>
                                                                <c:if test="${not empty q.optionC}">
                                                                    <div
                                                                        class="ia-option-item ${q.correctOption == 'C' ? 'is-correct' : ''}">
                                                                        <span
                                                                            style="font-weight: 800; opacity: 0.5;">C.</span>
                                                                        ${q.optionC}
                                                                        <c:if test="${q.correctOption == 'C'}"><i
                                                                                class="fas fa-check-circle"
                                                                                style="margin-left: auto; color: var(--ins-primary);"></i>
                                                                        </c:if>
                                                                    </div>
                                                                </c:if>
                                                                <c:if test="${not empty q.optionD}">
                                                                    <div
                                                                        class="ia-option-item ${q.correctOption == 'D' ? 'is-correct' : ''}">
                                                                        <span
                                                                            style="font-weight: 800; opacity: 0.5;">D.</span>
                                                                        ${q.optionD}
                                                                        <c:if test="${q.correctOption == 'D'}"><i
                                                                                class="fas fa-check-circle"
                                                                                style="margin-left: auto; color: var(--ins-primary);"></i>
                                                                        </c:if>
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <div class="ia-question-actions">
                                                        <a href="${pageContext.request.contextPath}/instructor/assessments?action=deleteQuestion&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&questionId=${q.questionId}"
                                                            class="btn btn-secondary btn-sm"
                                                            style="color: #dc2626; border-color: #fee2e2;"
                                                            onclick="return confirm('Are you sure you want to delete this question?');">
                                                            <i class="fas fa-trash-can"></i> Remove
                                                        </a>
                                                    </div>
                                                </article>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </main>



            </body>

            </html>
