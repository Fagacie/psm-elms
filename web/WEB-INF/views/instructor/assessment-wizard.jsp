<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="wizardStep" value="${empty param.step ? (not empty selectedAssessment ? 'questions' : 'details') : param.step}" />
<c:set var="assessmentFormAction" value="${not empty selectedAssessment ? 'updateAssessment' : 'createAssessment'}" />
<c:set var="questionTotalCount" value="${empty questions ? 0 : questions.size()}" />

<section class="ia-wizard" data-ia-wizard data-course-id="${selectedCourse.courseId}" data-assessment-id="${not empty selectedAssessment ? selectedAssessment.assessmentId : ''}" data-active-step="${wizardStep}">
    <nav class="ins-flow-nav" role="tablist" aria-label="Assessment workflow" style="margin-bottom: 24px; border-bottom: 2px solid var(--iwm-border-soft); display: flex; gap: 12px;">
        <button type="button" class="ins-flow-link ${wizardStep == 'details' ? 'active' : ''}" data-step-target="details" style="background: none; border: none; cursor: pointer; padding: 12px 20px; font-size: 1rem;">
            <i class="fas fa-sliders"></i> <span>1. Details Settings</span>
        </button>
        <button type="button" class="ins-flow-link ${wizardStep == 'questions' ? 'active' : ''} ${empty selectedAssessment ? 'is-disabled' : ''}" data-step-target="questions" ${empty selectedAssessment ? 'disabled' : ''} style="background: none; border: none; cursor: pointer; padding: 12px 20px; font-size: 1rem;">
            <i class="fas fa-list-check"></i> <span>2. Questions Builder</span>
        </button>
    </nav>

    <article class="ia-card ia-step-panel ${wizardStep == 'details' ? 'is-active' : ''}" data-step-panel="details">
        <div class="ia-card-head ia-wizard-head">
            <div>
                <p class="ia-card-kicker">Step 1</p>
                <h3>${not empty selectedAssessment ? 'Assessment Details' : 'Create Assessment'}</h3>
                <p class="section-caption">Keep the form focused. Type-specific fields appear automatically so the page stays readable.</p>
            </div>
        </div>

        <div class="ia-step-layout">
            <div class="ia-step-main">
                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form ia-wizard-form" id="assessmentDetailsForm">
                    <input type="hidden" name="action" value="${assessmentFormAction}" />
                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                    <c:if test="${not empty selectedAssessment}">
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                    </c:if>
                    <input type="hidden" name="workflowAction" id="assessmentWorkflowAction" value="questions" />

                    <div class="ia-field-grid">
                        <div class="ia-field-span-2">
                            <label for="assessmentTitle">Assessment Title</label>
                            <input id="assessmentTitle" name="title" type="text" value="${not empty selectedAssessment ? selectedAssessment.title : ''}" placeholder="e.g., Final Exam, Week 1 Quiz" required />
                        </div>

                        <div>
                            <label for="assessmentType">Assessment Type</label>
                            <select id="assessmentType" name="type" data-question-preset-control required>
                                <option value="">Select type</option>
                                <option value="Quiz" ${not empty selectedAssessment and selectedAssessment.type == 'Quiz' ? 'selected' : ''}>Quiz</option>
                                <option value="Exam" ${not empty selectedAssessment and selectedAssessment.type == 'Exam' ? 'selected' : ''}>Exam</option>
                                <option value="Assignment" ${not empty selectedAssessment and selectedAssessment.type == 'Assignment' ? 'selected' : ''}>Assignment</option>
                            </select>
                        </div>

                        <div class="ia-field-span-2">
                            <label for="assessmentInstructions">Description</label>
                            <textarea id="assessmentInstructions" name="instructions" rows="4" placeholder="Short guidance for students and grading context.">${not empty selectedAssessment ? selectedAssessment.instructions : ''}</textarea>
                        </div>

                        <div data-type-visible="objective">
                            <label for="assessmentDuration">Duration (mins)</label>
                            <input id="assessmentDuration" name="duration" type="number" min="1" max="480" value="${not empty selectedAssessment and not empty selectedAssessment.duration ? selectedAssessment.duration : ''}" placeholder="Optional" />
                        </div>

                        <div data-type-visible="objective">
                            <label for="assessmentMaxAttempts">Attempts Allowed</label>
                            <input id="assessmentMaxAttempts" name="maxAttempts" type="number" min="1" max="10" value="${not empty selectedAssessment and not empty selectedAssessment.maxAttempts ? selectedAssessment.maxAttempts : 3}" />
                        </div>

                        <div>
                            <label for="assessmentTotalMarks">Total Marks</label>
                            <input id="assessmentTotalMarks" name="totalMarks" type="number" min="1" step="1" value="${not empty selectedAssessment and not empty selectedAssessment.totalMarks ? selectedAssessment.totalMarks : ''}" placeholder="Auto from questions" />
                        </div>

                        <div data-type-visible="assignment" class="ia-field-span-2">
                            <label for="submissionMode">Submission Mode</label>
                            <select id="submissionMode" name="submissionMode">
                                <option value="both" ${not empty selectedAssessment and selectedAssessment.submissionMode == 'both' ? 'selected' : ''}>Text + File</option>
                                <option value="file" ${not empty selectedAssessment and selectedAssessment.submissionMode == 'file' ? 'selected' : ''}>File only</option>
                                <option value="text" ${not empty selectedAssessment and selectedAssessment.submissionMode == 'text' ? 'selected' : ''}>Text only</option>
                            </select>
                        </div>

                        <div class="ia-field-span-2">
                            <label for="placement">Placement</label>
                            <select id="placement" name="placement" required>
                                <option value="final">Course Completion</option>
                                <option value="afterEveryMaterial">After Every Material</option>
                                <optgroup label="After Specific Material">
                                    <c:forEach var="m" items="${materials}">
                                        <option value="afterMaterial:${m.materialId}">${m.title}</option>
                                    </c:forEach>
                                </optgroup>
                            </select>
                        </div>
                    </div>

                    <div class="ia-form-actions">
                        <button class="btn btn-secondary" type="submit" data-workflow-action="questions"><i class="fas fa-floppy-disk"></i> Save and Continue</button>
                        <button class="btn btn-primary" type="submit" data-workflow-action="questions"><i class="fas fa-arrow-right"></i> Continue to Questions</button>
                    </div>
                </form>
            </div>

            <aside class="ia-step-side">
                <div class="ia-summary-card">
                    <p class="ia-card-kicker">Summary</p>
                    <h4>${selectedCourse.courseName}</h4>
                    <div class="ia-summary-list">
                        <div><span>Type</span><strong><c:out value="${not empty selectedAssessment ? selectedAssessment.type : 'Not set'}" default="Not set" /></strong></div>
                        <div><span>Duration</span><strong><c:out value="${not empty selectedAssessment and not empty selectedAssessment.duration ? selectedAssessment.duration : 'Open-ended'}" default="Open-ended" /></strong></div>
                        <div><span>Attempts</span><strong><c:out value="${not empty selectedAssessment and not empty selectedAssessment.maxAttempts ? selectedAssessment.maxAttempts : 3}" default="3" /></strong></div>
                    </div>
                </div>
            </aside>
        </div>
    </article>

    <c:if test="${not empty selectedAssessment}">
        <article class="ia-card ia-step-panel ${wizardStep == 'questions' ? 'is-active' : ''}" data-step-panel="questions">
            <div class="ia-card-head ia-wizard-head">
                <div>
                    <p class="ia-card-kicker">Step 2</p>
                    <h3>Add Questions</h3>
                    <p class="section-caption">Use the preset builder to keep objective and subjective questions cleanly separated.</p>
                </div>
                <div class="ia-inline-actions">
                    <button type="button" class="btn btn-secondary btn-sm" data-step-target="details"><i class="fas fa-arrow-left"></i> Back</button>
                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="display:inline-flex;">
                        <input type="hidden" name="action" value="publishAssessment" />
                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                        <button type="submit" class="btn btn-primary btn-sm" ${empty questions ? 'disabled' : ''}><i class="fas fa-paper-plane"></i> Publish</button>
                    </form>
                </div>
            </div>

            <div class="ia-question-summary-strip">
                <div class="ia-question-metric"><span>Total Questions</span><strong>${questionTotalCount}</strong></div>
                <div class="ia-question-metric"><span>Type</span><strong>${selectedAssessment.type}</strong></div>
                <div class="ia-question-metric"><span>Attempts</span><strong><c:out value="${not empty selectedAssessment.maxAttempts ? selectedAssessment.maxAttempts : 3}" default="3" /></strong></div>
                <div class="ia-question-metric"><span>Marks</span><strong><c:out value="${not empty selectedAssessment.totalMarks ? selectedAssessment.totalMarks : 'Auto'}" default="Auto" /></strong></div>
            </div>

            <div class="ia-question-builder">
                <div class="ia-question-builder-form">
                    <div class="ia-builder-toolbar">
                        <div>
                            <p class="ia-card-kicker">Question Presets</p>
                            <div class="ia-preset-row" role="tablist" aria-label="Question presets">
                                <button type="button" class="ia-preset-chip active" data-question-preset="mcq">MCQ</button>
                                <button type="button" class="ia-preset-chip" data-question-preset="truefalse">True / False</button>
                                <button type="button" class="ia-preset-chip" data-question-preset="short">Short Answer</button>
                                <button type="button" class="ia-preset-chip" data-question-preset="essay">Essay</button>
                                <button type="button" class="ia-preset-chip" data-question-preset="file">File Upload</button>
                            </div>
                        </div>
                        <button type="button" class="btn btn-secondary btn-sm" id="iaClearQuestionDraft"><i class="fas fa-eraser"></i> Clear</button>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form ia-question-form" id="questionCreateForm" data-question-form="create">
                        <input type="hidden" name="action" value="addQuestion" />
                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                        <input type="hidden" name="questionPreset" id="createQuestionPreset" value="mcq" />

                        <label for="createQuestionText">Question Text</label>
                        <textarea id="createQuestionText" name="questionText" rows="4" placeholder="Write the actual prompt students will see." required></textarea>

                        <div class="ia-question-split" data-question-options>
                            <div><label for="createOptionA">Option A</label><input id="createOptionA" name="optionA" type="text" placeholder="Option A" /></div>
                            <div><label for="createOptionB">Option B</label><input id="createOptionB" name="optionB" type="text" placeholder="Option B" /></div>
                            <div><label for="createOptionC">Option C</label><input id="createOptionC" name="optionC" type="text" placeholder="Option C" /></div>
                            <div><label for="createOptionD">Option D</label><input id="createOptionD" name="optionD" type="text" placeholder="Option D" /></div>
                        </div>

                        <div class="ia-question-split" data-question-answer>
                            <div>
                                <label for="createCorrectOption">Correct Option</label>
                                <select id="createCorrectOption" name="correctOption">
                                    <option value="">None</option>
                                    <option value="A">A</option>
                                    <option value="B">B</option>
                                    <option value="C">C</option>
                                    <option value="D">D</option>
                                </select>
                            </div>
                            <div>
                                <label for="createMarks">Marks</label>
                                <input id="createMarks" name="marks" type="number" min="0" step="0.1" value="1" />
                            </div>
                        </div>

                        <div class="ia-question-note">MCQ and True / False presets show answer choices. Short Answer, Essay, and File Upload focus on manual grading.</div>

                        <div class="ia-form-actions">
                            <button class="btn btn-primary" type="submit"><i class="fas fa-plus"></i> Add Question</button>
                        </div>
                    </form>
                </div>

                <div class="ia-question-rail">
                    <div class="ia-card-head ia-question-rail-head">
                        <div>
                            <p class="ia-card-kicker">Question Builder</p>
                            <h3>Current Questions</h3>
                        </div>
                        <span class="ia-soft-count">${questionTotalCount} item(s)</span>
                    </div>

                    <c:choose>
                        <c:when test="${empty questions}">
                            <div class="empty-state-box ia-question-empty">
                                <i class="fas fa-question-circle"></i>
                                <p>No questions yet. Use the preset builder to add the first one.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="ia-question-card-list">
                                <c:forEach var="q" items="${questions}" varStatus="status">
                                    <c:set var="hasOptions" value="${not empty q.optionA or not empty q.optionB or not empty q.optionC or not empty q.optionD}" />
                                    <c:set var="looksTrueFalse" value="${fn:toLowerCase(q.optionA) == 'true' and fn:toLowerCase(q.optionB) == 'false' and empty q.optionC and empty q.optionD}" />
                                    <article class="ia-question-card">
                                        <div class="ia-question-card-head">
                                            <div>
                                                <p class="ia-card-kicker">Question ${status.index + 1}</p>
                                                <h4><c:out value="${q.questionText}"/></h4>
                                            </div>
                                            <div class="ia-question-meta-stack">
                                                <span class="ia-question-marks-chip"><c:out value="${not empty q.marks ? q.marks : 0}" default="0" /> marks</span>
                                                <span class="status-badge">${hasOptions ? (looksTrueFalse ? 'True / False' : 'MCQ') : 'Written'}</span>
                                            </div>
                                        </div>

                                        <c:if test="${hasOptions}">
                                            <div class="ia-question-preview">
                                                <c:if test="${not empty q.optionA}"><span class="ia-answer-chip ${q.correctOption == 'A' ? 'is-correct' : ''}">A. <c:out value="${q.optionA}"/></span></c:if>
                                                <c:if test="${not empty q.optionB}"><span class="ia-answer-chip ${q.correctOption == 'B' ? 'is-correct' : ''}">B. <c:out value="${q.optionB}"/></span></c:if>
                                                <c:if test="${not empty q.optionC}"><span class="ia-answer-chip ${q.correctOption == 'C' ? 'is-correct' : ''}">C. <c:out value="${q.optionC}"/></span></c:if>
                                                <c:if test="${not empty q.optionD}"><span class="ia-answer-chip ${q.correctOption == 'D' ? 'is-correct' : ''}">D. <c:out value="${q.optionD}"/></span></c:if>
                                            </div>
                                        </c:if>

                                        <div class="ia-question-actions">
                                            <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                                <input type="hidden" name="action" value="moveQuestion" />
                                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                                                <input type="hidden" name="questionId" value="${q.questionId}" />
                                                <input type="hidden" name="direction" value="up" />
                                                <button class="btn btn-secondary btn-sm" type="submit" ${status.first ? 'disabled' : ''}><i class="fas fa-arrow-up"></i> Up</button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                                <input type="hidden" name="action" value="moveQuestion" />
                                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                                                <input type="hidden" name="questionId" value="${q.questionId}" />
                                                <input type="hidden" name="direction" value="down" />
                                                <button class="btn btn-secondary btn-sm" type="submit" ${status.last ? 'disabled' : ''}><i class="fas fa-arrow-down"></i> Down</button>
                                            </form>
                                            <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteQuestion&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&questionId=${q.questionId}" onclick="return confirm('Delete this question?')"><i class="fas fa-trash"></i> Delete</a>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </article>

    </c:if>
</section>

<script>
(function () {
    const wizard = document.querySelector('[data-ia-wizard]');
    if (!wizard) {
        return;
    }

    const stepButtons = wizard.querySelectorAll('[data-step-target]');
    const panels = wizard.querySelectorAll('[data-step-panel]');
    const workflowAction = wizard.querySelector('#assessmentWorkflowAction');
    const detailsForm = wizard.querySelector('#assessmentDetailsForm');
    const typeSelect = wizard.querySelector('#assessmentType');
    const questionPresetButtons = wizard.querySelectorAll('[data-question-preset]');
    const presetInput = wizard.querySelector('#createQuestionPreset');
    const createQuestionForm = wizard.querySelector('#questionCreateForm');
    const clearButton = wizard.querySelector('#iaClearQuestionDraft');

    function showStep(step) {
        panels.forEach((panel) => panel.classList.toggle('is-active', panel.getAttribute('data-step-panel') === step));
        stepButtons.forEach((button) => button.classList.toggle('active', button.getAttribute('data-step-target') === step));
        wizard.setAttribute('data-active-step', step);
        if (workflowAction) {
            workflowAction.value = step;
        }
    }

    function setQuestionPreset(preset) {
        if (!createQuestionForm || !presetInput) {
            return;
        }
        presetInput.value = preset;
        questionPresetButtons.forEach((item) => {
            item.classList.toggle('active', item.getAttribute('data-question-preset') === preset);
        });

        const optionsBlock = wizard.querySelector('[data-question-options]');
        const answerBlock = wizard.querySelector('[data-question-answer]');
        const noteBlock = wizard.querySelector('.ia-question-note');
        const optionInputs = [
            wizard.querySelector('#createOptionA'),
            wizard.querySelector('#createOptionB'),
            wizard.querySelector('#createOptionC'),
            wizard.querySelector('#createOptionD')
        ];
        const correctOption = wizard.querySelector('#createCorrectOption');

        const showOptions = preset === 'mcq' || preset === 'truefalse';
        const showCorrect = preset === 'mcq' || preset === 'truefalse';
        if (optionsBlock) {
            optionsBlock.style.display = showOptions ? '' : 'none';
        }
        if (answerBlock) {
            answerBlock.style.display = showCorrect ? '' : 'none';
        }
        if (noteBlock) {
            noteBlock.textContent = preset === 'truefalse'
                ? 'True / False uses two answer options only.'
                : preset === 'short'
                    ? 'Short answer is typically graded manually.'
                    : preset === 'essay'
                        ? 'Essay is best paired with manual grading.'
                        : preset === 'file'
                            ? 'File upload expects a document submission.'
                            : 'MCQ preset shows four answer choices.';
        }

        if (!showOptions) {
            optionInputs.forEach((input) => { if (input) input.value = ''; });
        }
        if (!showCorrect && correctOption) {
            correctOption.value = '';
        }
        if (preset === 'truefalse' && optionInputs[0] && optionInputs[1]) {
            optionInputs[0].value = 'True';
            optionInputs[1].value = 'False';
        }
    }

    function syncQuestionBuilder(type) {
        const isAssignment = type === 'Assignment';
        const isObjective = type === 'Quiz' || type === 'Exam';
        const objectiveFields = wizard.querySelectorAll('[data-type-visible="objective"]');
        const assignmentFields = wizard.querySelectorAll('[data-type-visible="assignment"]');
        const presetRow = wizard.querySelector('.ia-preset-row');
        const submissionMode = wizard.querySelector('#submissionMode');
        const maxAttempts = wizard.querySelector('#assessmentMaxAttempts');

        objectiveFields.forEach((node) => {
            node.style.display = isObjective ? '' : 'none';
        });
        assignmentFields.forEach((node) => {
            node.style.display = isAssignment ? '' : 'none';
        });

        if (presetRow) {
            presetRow.style.display = isAssignment ? 'none' : '';
        }

        if (submissionMode) {
            submissionMode.disabled = !isAssignment;
        }
        if (maxAttempts) {
            if (!isObjective) {
                maxAttempts.value = '1';
            }
            maxAttempts.disabled = isAssignment;
        }

        if (isAssignment) {
            setQuestionPreset('short');
        } else {
            setQuestionPreset('mcq');
        }
    }

    stepButtons.forEach((button) => {
        button.addEventListener('click', () => {
            const step = button.getAttribute('data-step-target');
            if (!button.disabled && step) {
                showStep(step);
            }
        });
    });

    if (detailsForm) {
        detailsForm.querySelectorAll('[data-workflow-action]').forEach((button) => {
            button.addEventListener('click', () => {
                if (workflowAction) {
                    workflowAction.value = button.getAttribute('data-workflow-action') || 'questions';
                }
            });
        });
    }

    questionPresetButtons.forEach((button) => {
        button.addEventListener('click', () => {
            questionPresetButtons.forEach((item) => item.classList.remove('active'));
            button.classList.add('active');
            setQuestionPreset(button.getAttribute('data-question-preset'));
        });
    });

    if (clearButton) {
        clearButton.addEventListener('click', () => {
            if (createQuestionForm) {
                createQuestionForm.reset();
            }
            setQuestionPreset('mcq');
            const questionText = wizard.querySelector('#createQuestionText');
            if (questionText) {
                questionText.focus();
            }
        });
    }

    if (typeSelect) {
        typeSelect.addEventListener('change', () => {
            syncQuestionBuilder(typeSelect.value);
        });
        syncQuestionBuilder(typeSelect.value);
    } else {
        setQuestionPreset('mcq');
    }

    const activeStep = wizard.getAttribute('data-active-step') || 'details';
    showStep(activeStep);
})();
</script>
