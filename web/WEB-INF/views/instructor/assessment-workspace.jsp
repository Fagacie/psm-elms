<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Assessment Hub - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Assessment Hub"/>
</jsp:include>

<c:if test="${param.success == 'deleted' or param.success == 'archived'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment archived successfully.</div></c:if>
<c:if test="${param.success == 'restored'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment restored successfully.</div></c:if>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper ia-workspace">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Course Assessment Hub</span>
        </nav>

        <section class="ia-topbar ia-topbar-split">
            <div>
                <p class="ia-card-kicker">Course Assessment Hub</p>
                <h2>
                    <c:choose>
                        <c:when test="${not empty selectedCourse}">For <c:out value="${selectedCourse.courseName}"/></c:when>
                        <c:otherwise>Workspace requires a course</c:otherwise>
                    </c:choose>
                </h2>
                <p class="ia-topbar-subtitle">Keep each course's assessment library, builder, questions, grading, and archive in one flow.</p>
            </div>
            <div class="ia-topbar-actions">
                <c:if test="${not empty selectedCourse}">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}">
                        <i class="fas fa-plus-circle"></i> Create Assessment
                    </a>
                </c:if>
            </div>
        </section>

        <c:if test="${not empty selectedCourse}">
            <section class="ia-workspace-nav-grid" aria-label="Assessment workspace sections">
                <a class="ia-workspace-nav-card ${activeView == 'dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard&courseId=${selectedCourse.courseId}">
                    <i class="fas fa-layer-group"></i>
                    <strong>Library</strong>
                    <span>Published assessments and actions.</span>
                </a>
                <a class="ia-workspace-nav-card ${activeView == 'editor' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}">
                    <i class="fas fa-pen-to-square"></i>
                    <strong>Builder</strong>
                    <span>Set details, grading mode, and attempt rules.</span>
                </a>
                <a class="ia-workspace-nav-card ${activeView == 'questions' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=questions&courseId=${selectedCourse.courseId}">
                    <i class="fas fa-list-check"></i>
                    <strong>Question Bank</strong>
                    <span>Add questions, options, answers, and order.</span>
                </a>
                <a class="ia-workspace-nav-card ${activeView == 'archive' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=archive&courseId=${selectedCourse.courseId}">
                    <i class="fas fa-box-archive"></i>
                    <strong>Archive</strong>
                    <span>Restore past assessments when needed.</span>
                </a>
            </section>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>
        <c:if test="${param.success == 'created'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment created successfully.</div></c:if>
        <c:if test="${param.success == 'updated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment updated successfully.</div></c:if>
        <c:if test="${param.success == 'deleted' or param.success == 'archived'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment archived successfully.</div></c:if>
        <c:if test="${param.success == 'qcreated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question added successfully.</div></c:if>
        <c:if test="${param.success == 'qdeleted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question deleted successfully.</div></c:if>
        <c:if test="${param.success == 'qupdated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question updated successfully.</div></c:if>
        <c:if test="${param.success == 'qmoved'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question order updated.</div></c:if>
        <c:if test="${param.success == 'published'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment published successfully.</div></c:if>
        <c:if test="${param.success == 'rreviewed'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Retake request reviewed successfully.</div></c:if>
        <c:if test="${param.success == 'graded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Submission graded successfully.</div></c:if>
        <c:if test="${param.success == 'autoregraded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Submission auto-regraded successfully.</div></c:if>
        <c:if test="${param.success == 'autoregradedall'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Bulk auto-regrade completed. Updated submissions: <strong><c:out value="${param.regradedCount}" default="0"/></strong>.</div></c:if>
        <c:if test="${param.error != null}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Action failed. Please verify input and retry.</div></c:if>

        <c:if test="${activeView == 'editor'}">
            <jsp:include page="/WEB-INF/views/instructor/assessment-wizard.jsp"/>
        </c:if>

        <c:choose>
            <c:when test="${empty selectedCourse}">
                <section class="ia-card ia-empty">
                    <i class="fas fa-book-open"></i>
                    <h3>Start with a Course</h3>
                </section>
            </c:when>

            <c:when test="${activeView == 'dashboard'}">
                <section class="ia-card ia-card--soft">
                    <div class="ia-card-head">
                        <div>
                            <h3>Assessment Library</h3>
                            <p class="section-caption">All assessments for this course.</p>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty assessments}">
                            <div class="ia-empty-inline">No assessments created for this course yet.</div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="data-table ia-table">
                                    <thead>
                                    <tr>
                                        <th>Title</th>
                                        <th>Type</th>
                                        <th>Duration</th>
                                        <th>Attempts</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="a" items="${assessments}">
                                        <tr>
                                            <td data-label="Title">
                                                <strong>${a.title}</strong>
                                                <div class="ia-subline">${not empty a.totalMarks ? a.totalMarks : 'N/A'} marks</div>
                                            </td>
                                            <td data-label="Type"><span class="assessment-type-badge type-${fn:replace(a.type, ' ', '-')}">${a.type}</span></td>
                                            <td data-label="Duration">${not empty a.duration ? a.duration : '--'}${not empty a.duration ? ' min' : ''}</td>
                                            <td data-label="Attempts">${not empty a.maxAttempts ? a.maxAttempts : 1}</td>
                                            <td data-label="Actions" class="ia-actions-cell">
                                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">Open Builder</a>
                                                <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=questions&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">Questions</a>
                                                <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=archiveAssessment&courseId=${selectedCourse.courseId}&id=${a.assessmentId}" onclick="return confirm('Archive this assessment?')">Archive</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <c:if test="${not empty selectedAssessment and not empty assessmentRosterRows}">
                                <div class="ia-card-head ia-card-head--spaced">
                                    <div>
                                        <h3>Student Participation</h3>
                                        <p class="section-caption">Who has attempted the assessment and who has not started yet.</p>
                                    </div>
                                </div>
                                <div class="table-responsive">
                                    <table class="data-table ia-table">
                                        <thead>
                                            <tr>
                                                <th>Student</th>
                                                <th>Email</th>
                                                <th>Status</th>
                                                <th>Attempts</th>
                                                <th>Latest Submission</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="row" items="${assessmentRosterRows}">
                                            <tr>
                                                <td data-label="Student"><strong>${row.studentName}</strong></td>
                                                <td data-label="Email">${row.studentEmail}</td>
                                                <td data-label="Status"><span class="assessment-type-badge">${row.studentStatusLabel}</span></td>
                                                <td data-label="Attempts">${row.submissionCount}</td>
                                                <td data-label="Latest Submission">
                                                    <c:choose>
                                                        <c:when test="${not empty row.latestSubmission}">
                                                            Attempt #${row.latestSubmission.attemptNumber}
                                                            <c:if test="${not empty row.latestSubmission.score}"> - Score ${row.latestSubmission.score}</c:if>
                                                        </c:when>
                                                        <c:otherwise>--</c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>

                            <c:if test="${empty assessments and not empty archivedAssessments}">
                                <div class="ia-empty-inline">No active assessments. Open the Archived tab to restore past assessments.</div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </section>
            </c:when>

            <c:when test="${activeView == 'archive'}">
                <section class="ia-card ia-card--soft">
                    <div class="ia-card-head">
                        <div>
                            <h3>Archived Assessments</h3>
                            <p class="section-caption">Recover assessments that were archived from the main library.</p>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty archivedAssessments}">
                            <div class="ia-empty-inline">No archived assessments for this course.</div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="data-table ia-table">
                                    <thead>
                                    <tr>
                                        <th>Title</th>
                                        <th>Type</th>
                                        <th>Duration</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="a" items="${archivedAssessments}">
                                        <tr>
                                            <td data-label="Title"><strong>${a.title}</strong></td>
                                            <td data-label="Type"><span class="assessment-type-badge type-${fn:replace(a.type, ' ', '-')}">${a.type}</span></td>
                                            <td data-label="Duration">${not empty a.duration ? a.duration : '--'}${not empty a.duration ? ' min' : ''}</td>
                                            <td data-label="Actions" class="ia-actions-cell">
                                                <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=restoreAssessment&courseId=${selectedCourse.courseId}&id=${a.assessmentId}" onclick="return confirm('Restore this assessment?')"><i class="fas fa-undo"></i> Restore</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>
            </c:when>

            <c:when test="${false}">
                <section class="ia-grid-2">
                    <article class="ia-card">
                        <div class="ia-card-head">
                            <h3>Create Assessment</h3>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form">
                            <input type="hidden" name="action" value="createAssessment"/>
                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>

                            <label for="title">Title</label>
                            <input id="title" name="title" type="text" required/>

                            <label for="type">Type</label>
                            <select id="type" name="type" onchange="syncAssessmentType(this, 'create')" required>
                                <option value="Quiz">Quiz</option>
                                <option value="Exam">Exam</option>
                                <option value="Assignment">Assignment</option>
                            </select>

                            <div class="ia-form-row">
                                <div>
                                    <label for="gradingMode-create">Grading</label>
                                    <select id="gradingMode-create" name="gradingMode">
                                        <option value="auto">Auto</option>
                                        <option value="manual">Manual</option>
                                    </select>
                                </div>
                                <div>
                                    <label for="submissionMode-create">Submission</label>
                                    <select id="submissionMode-create" name="submissionMode">
                                        <option value="both">Text + File</option>
                                        <option value="file">File only</option>
                                        <option value="text">Text only</option>
                                    </select>
                                </div>
                            </div>

                            <div class="ia-form-row">
                                <div>
                                    <label for="duration">Duration (minutes)</label>
                                    <input id="duration" name="duration" type="number" min="0"/>
                                </div>
                                <div>
                                    <label for="totalMarks">Total Marks</label>
                                    <input id="totalMarks" name="totalMarks" type="number" step="0.1" min="1"/>
                                </div>
                            </div>

                            <div class="ia-form-row">
                                <div>
                                    <label for="maxAttempts">Max Attempts</label>
                                    <input id="maxAttempts" name="maxAttempts" type="number" min="1" value="3"/>
                                </div>
                            </div>

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

                            <label for="instructions">Instructions</label>
                            <textarea id="instructions" name="instructions" rows="4"></textarea>

                            <button class="btn btn-primary" type="submit"><i class="fas fa-save"></i> Save Assessment</button>
                        </form>
                    </article>

                    <article class="ia-card">
                        <div class="ia-card-head">
                            <h3>Assessment Editing</h3>
                        </div>

                        <c:choose>
                            <c:when test="${empty selectedAssessment}">
                                <div class="ia-empty-inline">Pick an assessment from All Assessments to continue editing in the workspace.</div>
                            </c:when>
                            <c:otherwise>
                                <div class="ia-empty-inline">
                                    <p><strong>${selectedAssessment.title}</strong></p>
                                            <p>Open the editor to continue with questions and publish.</p>
                                    <div class="ia-inline-actions">
                                                <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}"><i class="fas fa-pen"></i> Open Editor</a>
                                        <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&courseId=${selectedCourse.courseId}&id=${selectedAssessment.assessmentId}" onclick="return confirm('Delete this assessment?')">
                                            <i class="fas fa-trash"></i> Delete
                                        </a>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </article>
                </section>
            </c:when>

            <c:when test="${activeView == 'questions'}">
                <c:if test="${empty selectedAssessment}">
                </c:if>
                <c:if test="${not empty selectedAssessment}">
                    <section class="ia-grid-2">
                        <article class="ia-card">
                            <div class="ia-card-head">
                                <h3>Question Builder</h3>
                                <span class="assessment-type-badge type-${fn:replace(selectedAssessment.type, ' ', '-')}">${selectedAssessment.type}</span>
                            </div>
                            <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form" id="questionCreateForm">
                                <input type="hidden" name="action" value="addQuestion"/>
                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>

                                <label for="questionText">Question</label>
                                <textarea id="questionText" name="questionText" rows="4" required></textarea>

                                <div class="ia-options-grid" id="choiceInputs">
                                    <div>
                                        <label for="optionA">Option A</label>
                                        <input id="optionA" name="optionA" type="text"/>
                                    </div>
                                    <div>
                                        <label for="optionB">Option B</label>
                                        <input id="optionB" name="optionB" type="text"/>
                                    </div>
                                    <div>
                                        <label for="optionC">Option C</label>
                                        <input id="optionC" name="optionC" type="text"/>
                                    </div>
                                    <div>
                                        <label for="optionD">Option D</label>
                                        <input id="optionD" name="optionD" type="text"/>
                                    </div>
                                </div>

                                <div class="ia-form-row">
                                    <div>
                                        <label for="correctOption">Correct Option</label>
                                        <select id="correctOption" name="correctOption">
                                            <option value="">No correct option</option>
                                            <option value="A">A</option>
                                            <option value="B">B</option>
                                            <option value="C">C</option>
                                            <option value="D">D</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label for="marks">Marks</label>
                                        <input id="marks" name="marks" type="number" min="0" step="0.1" value="1"/>
                                    </div>
                                </div>

                                <button class="btn btn-primary" type="submit"><i class="fas fa-plus"></i> Add Question</button>
                            </form>
                        </article>

                        <article class="ia-card">
                            <div class="ia-card-head">
                                <h3>Question List</h3>
                                <span>${questions.size()} item(s)</span>
                            </div>
                            <c:choose>
                                <c:when test="${empty questions}">
                                </c:when>
                                <c:otherwise>
                                    <div class="ia-question-list">
                                        <c:forEach var="q" items="${questions}" varStatus="loop">
                                            <details class="ia-question-item">
                                                <summary>
                                                    <div>
                                                        <strong>Q${loop.index + 1}.</strong> ${q.questionText}
                                                    </div>
                                                    <span class="ia-question-meta">${q.marks != null ? q.marks : 1} marks</span>
                                                </summary>

                                                <div class="ia-question-actions">
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                                        <input type="hidden" name="action" value="moveQuestion"/>
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                                        <input type="hidden" name="questionId" value="${q.questionId}"/>
                                                        <input type="hidden" name="direction" value="up"/>
                                                        <button class="btn btn-secondary btn-sm" type="submit"><i class="fas fa-arrow-up"></i> Move Up</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                                        <input type="hidden" name="action" value="moveQuestion"/>
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                                        <input type="hidden" name="questionId" value="${q.questionId}"/>
                                                        <input type="hidden" name="direction" value="down"/>
                                                        <button class="btn btn-secondary btn-sm" type="submit"><i class="fas fa-arrow-down"></i> Move Down</button>
                                                    </form>
                                                    <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteQuestion&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&id=${q.questionId}" onclick="return confirm('Delete this question?')">
                                                        <i class="fas fa-trash"></i> Delete
                                                    </a>
                                                </div>

                                                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form ia-question-edit">
                                                    <input type="hidden" name="action" value="updateQuestion"/>
                                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                                    <input type="hidden" name="questionId" value="${q.questionId}"/>

                                                    <label>Question</label>
                                                    <textarea name="questionText" rows="3" required>${q.questionText}</textarea>

                                                    <div class="ia-options-grid">
                                                        <div><label>Option A</label><input name="optionA" type="text" value="${q.optionA}"/></div>
                                                        <div><label>Option B</label><input name="optionB" type="text" value="${q.optionB}"/></div>
                                                        <div><label>Option C</label><input name="optionC" type="text" value="${q.optionC}"/></div>
                                                        <div><label>Option D</label><input name="optionD" type="text" value="${q.optionD}"/></div>
                                                    </div>

                                                    <div class="ia-form-row">
                                                        <div>
                                                            <label>Correct Option</label>
                                                            <select name="correctOption">
                                                                <option value="" <c:if test="${empty q.correctOption}">selected</c:if>>No correct option</option>
                                                                <option value="A" <c:if test="${q.correctOption == 'A'}">selected</c:if>>A</option>
                                                                <option value="B" <c:if test="${q.correctOption == 'B'}">selected</c:if>>B</option>
                                                                <option value="C" <c:if test="${q.correctOption == 'C'}">selected</c:if>>C</option>
                                                                <option value="D" <c:if test="${q.correctOption == 'D'}">selected</c:if>>D</option>
                                                            </select>
                                                        </div>
                                                        <div>
                                                            <label>Marks</label>
                                                            <input name="marks" type="number" min="0" step="0.1" value="${q.marks}"/>
                                                        </div>
                                                    </div>

                                                    <button class="btn btn-primary btn-sm" type="submit"><i class="fas fa-floppy-disk"></i> Save Question</button>
                                                </form>
                                            </details>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </article>
                    </section>
                </c:if>
            </c:when>

        </c:choose>
    </div>
</main>

<script>
    function syncAssessmentType(selectEl, mode) {
        const type = (selectEl && selectEl.value) ? selectEl.value : '';
        const grading = document.getElementById('gradingMode-' + mode);
        const submission = document.getElementById('submissionMode-' + mode);
        if (!grading || !submission) {
            return;
        }

        if (type === 'Assignment') {
            grading.value = 'manual';
            grading.disabled = true;
            submission.disabled = false;
        } else {
            grading.disabled = false;
            submission.value = 'both';
            submission.disabled = true;
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        const createType = document.getElementById('type');
        if (createType) {
            syncAssessmentType(createType, 'create');
        }
        const editType = document.getElementById('edit-type');
        if (editType) {
            syncAssessmentType(editType, 'edit');
        }
    });
</script>
</body>
</html>
