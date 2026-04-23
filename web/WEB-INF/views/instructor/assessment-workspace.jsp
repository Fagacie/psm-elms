<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessment Workspace - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Assessment Workspace"/>
</jsp:include>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper ia-workspace">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Assessments</span>
        </nav>

        <section class="ia-topbar ia-topbar-split">
            <div>
                <p class="ia-card-kicker">Assessments</p>
                <h2>
                    <c:choose>
                        <c:when test="${not empty selectedCourse}">For <c:out value="${selectedCourse.courseName}"/></c:when>
                        <c:otherwise>Workspace requires a course</c:otherwise>
                    </c:choose>
                </h2>
                <c:choose>
                    <c:when test="${not empty selectedCourse}">
                        <p class="ia-topbar-subtitle">Design, publish, and grade assessments from a single course workspace.</p>
                    </c:when>
                    <c:otherwise>
                        <p class="ia-topbar-subtitle">Choose a course from <a href="${pageContext.request.contextPath}/instructor/courses">My Courses</a> to continue.</p>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="ia-topbar-actions">
                <c:if test="${not empty selectedCourse}">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/instructor/assessments?view=drafts&courseId=${selectedCourse.courseId}">
                        <i class="fas fa-plus-circle"></i> New Assessment
                    </a>
                </c:if>
            </div>
        </section>

        <c:if test="${not empty selectedCourse}">
            <c:set var="assessmentListFilter" value="${empty param.status ? 'all' : fn:toLowerCase(param.status)}"/>
            <section class="ia-view-nav" aria-label="Assessment module views">
                <a class="ia-view-pill ${activeView == 'dashboard' && assessmentListFilter == 'all' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard&courseId=${selectedCourse.courseId}">
                    <i class="fas fa-table-columns"></i> All
                </a>
                <a class="ia-view-pill ${activeView == 'dashboard' && assessmentListFilter == 'drafts' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard&courseId=${selectedCourse.courseId}&status=drafts">
                    <i class="fas fa-pen-ruler"></i> Drafts
                </a>
                <a class="ia-view-pill ${activeView == 'dashboard' && assessmentListFilter == 'active' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=dashboard&courseId=${selectedCourse.courseId}&status=active">
                    <i class="fas fa-bolt"></i> Active
                </a>
                <a class="ia-view-pill ${activeView == 'submissions' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${not empty selectedAssessment ? selectedAssessment.assessmentId : (not empty assessments ? assessments[0].assessmentId : '')}">
                    <i class="fas fa-inbox"></i> Submissions
                </a>
                <a class="ia-view-pill ${activeView == 'grade' || activeView == 'pending-grading' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=pending-grading&courseId=${selectedCourse.courseId}&assessmentId=${not empty selectedAssessment ? selectedAssessment.assessmentId : (not empty assessments ? assessments[0].assessmentId : '')}">
                    <i class="fas fa-marker"></i> Pending Grading
                </a>
                <a class="ia-view-pill ${activeView == 'analytics' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=analytics&courseId=${selectedCourse.courseId}&assessmentId=${not empty selectedAssessment ? selectedAssessment.assessmentId : (not empty assessments ? assessments[0].assessmentId : '')}">
                    <i class="fas fa-chart-line"></i> Analytics
                </a>
            </section>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>
        <c:if test="${param.success == 'created'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment created successfully.</div></c:if>
        <c:if test="${param.success == 'updated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment updated successfully.</div></c:if>
        <c:if test="${param.success == 'deleted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment deleted successfully.</div></c:if>
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

        <c:if test="${activeView == 'editor' || activeView == 'drafts'}">
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
                <section class="ia-card">
                    <div class="ia-card-head">
                        <div>
                            <h3>Assessment Library</h3>
                            <p class="section-caption">All assessments for this course, with draft and active filters built into the workspace.</p>
                        </div>
                    </div>

                    <c:set var="visibleAssessmentCount" value="0"/>
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
                                        <th>Due Date</th>
                                        <th>Attempts</th>
                                        <th>Submissions</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="a" items="${assessments}">
                                        <c:set var="rowStatus" value="${statusByAssessmentId[a.assessmentId]}"/>
                                        <c:set var="matchesFilter" value="${assessmentListFilter == 'all' or (assessmentListFilter == 'drafts' and rowStatus == 'Draft') or (assessmentListFilter == 'active' and (rowStatus == 'Active' or rowStatus == 'Published'))}"/>
                                        <c:if test="${matchesFilter}">
                                            <c:set var="visibleAssessmentCount" value="${visibleAssessmentCount + 1}"/>
                                            <tr>
                                                <td data-label="Title">
                                                    <strong>${a.title}</strong>
                                                    <div class="ia-subline">${not empty a.totalMarks ? a.totalMarks : 'N/A'} marks</div>
                                                </td>
                                                <td data-label="Type"><span class="assessment-type-badge type-${fn:replace(a.type, ' ', '-')}">${a.type}</span></td>
                                                <td data-label="Due Date">
                                                    <c:choose>
                                                        <c:when test="${not empty a.dueDateDisplay}">${a.dueDateDisplay}</c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td data-label="Attempts">${not empty a.maxAttempts ? a.maxAttempts : 1}</td>
                                                <td data-label="Submissions">${submissionCountByAssessmentId[a.assessmentId]}</td>
                                                <td data-label="Status"><span class="status-badge">${rowStatus}</span></td>
                                                <td data-label="Actions" class="ia-actions-cell">
                                                    <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=drafts&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">Edit</a>
                                                    <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">View Submissions</a>
                                                    <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=pending-grading&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">Grade</a>
                                                    <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&courseId=${selectedCourse.courseId}&id=${a.assessmentId}" onclick="return confirm('Deactivate this assessment?');">Deactivate</a>
                                                    <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=analytics&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">Analytics</a>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <c:if test="${visibleAssessmentCount == 0}">
                                <div class="ia-empty-inline">No assessments match this filter.</div>
                            </c:if>
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

                            <label for="dueDate">Due Date / Deadline</label>
                            <input id="dueDate" name="dueDate" type="datetime-local"/>

                            <div class="ia-form-row">
                                <div>
                                    <label for="maxAttempts">Max Attempts</label>
                                    <input id="maxAttempts" name="maxAttempts" type="number" min="1" value="3"/>
                                </div>
                                <div>
                                    <label for="questionsPerPage">Questions per Page</label>
                                    <input id="questionsPerPage" name="questionsPerPage" type="number" min="1" value="2"/>
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
                                    <p>Use Drafts for the full editor, or continue in Questions after opening the assessment.</p>
                                    <div class="ia-inline-actions">
                                        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=drafts&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}"><i class="fas fa-pen"></i> Open Editor</a>
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

            <c:when test="${activeView == 'submissions'}">
                <c:if test="${empty selectedAssessment}">
                </c:if>
                <c:if test="${not empty selectedAssessment}">
                    <section class="ia-card">
                        <div class="ia-card-head">
                            <div>
                                <h3>Submissions Inbox: ${selectedAssessment.title}</h3>
                            </div>
                            <div class="ia-inline-actions">
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/instructor/assessments?action=exportSubmissionsCsv&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=${gradeFilter}">
                                    <i class="fas fa-file-csv"></i> Export CSV
                                </a>
                                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                    <input type="hidden" name="action" value="autoRegradeAllObjective"/>
                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                    <input type="hidden" name="gradeFilter" value="${gradeFilter}"/>
                                    <button class="btn btn-secondary" type="submit"><i class="fas fa-rotate"></i> Auto-Regrade All</button>
                                </form>
                            </div>
                        </div>

                        <div class="ia-filter-row">
                            <a class="ia-filter-chip ${gradeFilter == 'all' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=all">All</a>
                            <a class="ia-filter-chip ${gradeFilter == 'graded' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=graded">Graded</a>
                            <a class="ia-filter-chip ${gradeFilter == 'ungraded' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=ungraded">Pending</a>
                            <a class="ia-filter-chip ${gradeFilter == 'timedout' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=timedout">Late</a>
                        </div>

                        <div class="table-responsive">
                            <table class="data-table ia-table">
                                <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Attempt</th>
                                    <th>Submitted</th>
                                    <th>Status</th>
                                    <th>Score</th>
                                    <th>Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="s" items="${submissions}">
                                    <tr>
                                        <td data-label="Student">
                                            <strong>${s.studentName}</strong>
                                            <div class="ia-subline">${s.studentEmail}</div>
                                        </td>
                                        <td data-label="Attempt">${s.attemptNumber}</td>
                                        <td data-label="Submitted">${s.submitDate}</td>
                                        <td data-label="Status"><span class="status-badge">${submissionWorkflowStatus[s.submissionId]}</span></td>
                                        <td data-label="Score">
                                            <c:choose>
                                                <c:when test="${not empty s.score}">${s.score}</c:when>
                                                <c:otherwise>--</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td data-label="Actions" class="ia-actions-cell">
                                            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=grade&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&submissionId=${s.submissionId}&gradeFilter=${gradeFilter}">
                                                <i class="fas fa-marker"></i> Grade
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </section>

                    <section class="ia-card">
                        <div class="ia-card-head">
                            <h3>Retake Requests</h3>
                            <span>${retakeRequests.size()} request(s)</span>
                        </div>
                        <c:choose>
                            <c:when test="${empty retakeRequests}">
                            </c:when>
                            <c:otherwise>
                                <div class="ia-retake-list">
                                    <c:forEach var="rr" items="${retakeRequests}">
                                        <article class="ia-retake-item">
                                            <div>
                                                <strong>${rr.studentName}</strong>
                                                <p>${rr.studentEmail} • Requested on ${rr.requestDate}</p>
                                                <small>Reason: ${rr.reason}</small>
                                            </div>
                                            <div class="ia-inline-actions">
                                                <span class="status-badge">${rr.status}</span>
                                                <c:if test="${rr.status == 'Pending'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                                        <input type="hidden" name="action" value="reviewRetake"/>
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                                        <input type="hidden" name="requestId" value="${rr.requestId}"/>
                                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}"/>
                                                        <input type="hidden" name="decision" value="approve"/>
                                                        <button class="btn btn-primary btn-sm" type="submit">Approve</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                                        <input type="hidden" name="action" value="reviewRetake"/>
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                                        <input type="hidden" name="requestId" value="${rr.requestId}"/>
                                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}"/>
                                                        <input type="hidden" name="decision" value="reject"/>
                                                        <button class="btn btn-danger btn-sm" type="submit">Reject</button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </section>
                </c:if>
            </c:when>

            <c:when test="${activeView == 'grade' || activeView == 'pending-grading'}">
                <c:if test="${empty selectedAssessment}">
                </c:if>
                <c:if test="${not empty selectedAssessment}">
                    <section class="ia-grid-2">
                        <article class="ia-card">
                            <div class="ia-card-head">
                                <h3>Submission Detail</h3>
                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=${gradeFilter}">
                                    <i class="fas fa-arrow-left"></i> Back to Inbox
                                </a>
                            </div>

                            <c:choose>
                                <c:when test="${empty selectedSubmission}">
                                </c:when>
                                <c:otherwise>
                                    <div class="ia-meta-grid">
                                        <div><strong>Student</strong><span>${selectedSubmission.studentName}</span></div>
                                        <div><strong>Email</strong><span>${selectedSubmission.studentEmail}</span></div>
                                        <div><strong>Attempt</strong><span>${selectedSubmission.attemptNumber}</span></div>
                                        <div><strong>Status</strong><span>${submissionWorkflowStatus[selectedSubmission.submissionId]}</span></div>
                                        <div><strong>Submitted</strong><span>${selectedSubmission.submitDate}</span></div>
                                        <div><strong>Current Score</strong><span>${not empty selectedSubmission.score ? selectedSubmission.score : '--'}</span></div>
                                    </div>

                                    <c:if test="${not empty selectedSubmission.answersFilePath}">
                                        <div class="ia-submission-block">
                                            <h4>Submission Payload</h4>
                                            <c:choose>
                                                <c:when test="${fn:startsWith(selectedSubmission.answersFilePath, 'http')}">
                                                    <a href="${selectedSubmission.answersFilePath}" target="_blank" rel="noopener noreferrer" class="file-link">
                                                        <i class="fas fa-file-download"></i> Open submitted assessment
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="answer-chip-list">
                                                        <c:forEach var="answerPart" items="${fn:split(selectedSubmission.answersFilePath, ';')}">
                                                            <c:if test="${not empty fn:trim(answerPart)}">
                                                                <span class="answer-chip">${fn:replace(answerPart, ':', ' -> ')}</span>
                                                            </c:if>
                                                        </c:forEach>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
                        </article>

                        <article class="ia-card">
                            <div class="ia-card-head">
                                <h3>Grade Submission</h3>
                            </div>

                            <c:if test="${not empty selectedSubmission}">
                                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form">
                                    <input type="hidden" name="action" value="gradeSubmission"/>
                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                    <input type="hidden" name="submissionId" value="${selectedSubmission.submissionId}"/>
                                    <input type="hidden" name="gradeFilter" value="${gradeFilter}"/>

                                    <label for="score">Score (0 to ${selectedAssessment.totalMarks != null ? selectedAssessment.totalMarks : 'max'})</label>
                                    <input id="score" name="score" type="number" min="0" step="0.1" value="${selectedSubmission.score}"/>

                                    <label for="feedback">Feedback</label>
                                    <textarea id="feedback" name="feedback" rows="5">${selectedSubmission.feedback}</textarea>

                                    <button class="btn btn-primary" type="submit"><i class="fas fa-floppy-disk"></i> Save Grade</button>
                                </form>

                                <c:if test="${selectedAssessment.type == 'Quiz' or selectedAssessment.type == 'Practice Test' or selectedAssessment.type == 'Exam'}">
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-inline-form">
                                        <input type="hidden" name="action" value="autoRegradeSubmission"/>
                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}"/>
                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}"/>
                                        <input type="hidden" name="submissionId" value="${selectedSubmission.submissionId}"/>
                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}"/>
                                        <button class="btn btn-secondary" type="submit"><i class="fas fa-rotate"></i> Auto-Regrade This Submission</button>
                                    </form>
                                </c:if>
                            </c:if>

                            <div class="ia-audit-trail">
                                <h4>Grading Audit Trail</h4>
                                <c:choose>
                                    <c:when test="${empty selectedSubmissionAudits}">
                                    </c:when>
                                    <c:otherwise>
                                        <ul>
                                            <c:forEach var="audit" items="${selectedSubmissionAudits}">
                                                <li>
                                                    <strong>${audit.actionType}</strong> by ${audit.gradedByName} on ${audit.gradedAt}
                                                    <span>Score: ${audit.oldScore} → ${audit.newScore}</span>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </article>
                    </section>
                </c:if>
            </c:when>

            <c:when test="${activeView == 'analytics'}">
                <c:if test="${empty selectedAssessment}">
                </c:if>
                <c:if test="${not empty selectedAssessment}">
                    <section class="ia-card">
                        <div class="ia-card-head">
                            <div>
                                <h3>Analytics: ${selectedAssessment.title}</h3>
                            </div>
                        </div>

                        <div class="ia-stats-grid">
                            <div class="ia-stat"><span>Total Submissions</span><strong>${assessmentAnalytics.totalSubmissions}</strong></div>
                            <div class="ia-stat"><span>Graded</span><strong>${assessmentAnalytics.gradedSubmissions}</strong></div>
                            <div class="ia-stat"><span>Pending Review</span><strong>${assessmentAnalytics.pendingSubmissions}</strong></div>
                            <div class="ia-stat"><span>Average Score</span><strong><c:choose><c:when test="${not empty assessmentAnalytics.averageScore}"><fmt:formatNumber value="${assessmentAnalytics.averageScore}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></strong></div>
                            <div class="ia-stat"><span>Top Score</span><strong><c:choose><c:when test="${not empty assessmentAnalytics.topScore}">${assessmentAnalytics.topScore}</c:when><c:otherwise>--</c:otherwise></c:choose></strong></div>
                            <div class="ia-stat"><span>Lowest Score</span><strong><c:choose><c:when test="${not empty assessmentAnalytics.lowScore}">${assessmentAnalytics.lowScore}</c:when><c:otherwise>--</c:otherwise></c:choose></strong></div>
                        </div>

                        <div class="ia-progress-panel">
                            <div class="ia-progress-meta">
                                <span>Grading Completion</span>
                                <strong><fmt:formatNumber value="${assessmentAnalytics.completionRate}" maxFractionDigits="1"/>%</strong>
                            </div>
                            <div class="ia-progress-track">
                                <div class="ia-progress-fill" style="width: ${assessmentAnalytics.completionRate}%;"></div>
                            </div>
                        </div>
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
