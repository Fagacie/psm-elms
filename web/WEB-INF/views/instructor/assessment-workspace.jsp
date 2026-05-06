<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Assessments - Instructor</title>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/></div>
        </c:if>

        <c:url var="assessmentWorkspaceBaseUrl" value="/instructor/assessments">
            <c:param name="courseId" value="${selectedCourse.courseId}"/>
        </c:url>

        <section class="workspace-kpi-grid" style="margin-bottom: 24px;">
            <div class="workspace-kpi-card"><strong>${totalStudents}</strong><span>Students enrolled</span></div>
            <div class="workspace-kpi-card"><strong>${publishedMaterials}</strong><span>Materials count</span></div>
            <div class="workspace-kpi-card"><strong>${assessmentCount}</strong><span>Assessments count</span></div>
            <div class="workspace-kpi-card"><strong><fmt:formatNumber value="${completionRate}" maxFractionDigits="0"/>%</strong><span>Completion rate</span></div>
        </section>

        <c:choose>
            <c:when test="${empty selectedCourse}">
                <section class="section-card">
                    <div class="empty-state-box workspace-empty-box">
                        <i class="fas fa-chalkboard"></i>
                        <p>Select a course from the sidebar to view its assessment workspace.</p>
                    </div>
                </section>
            </c:when>
            <c:when test="${activeView == 'archive'}">
                <section class="section-card">
                    <div class="section-header"><div><h3 class="section-title">Archived Assessments</h3></div></div>
                    <c:choose>
                        <c:when test="${empty archivedAssessments}">
                            <div class="empty-state-box workspace-empty-box">
                                <i class="fas fa-box-archive"></i>
                                <p>No archived assessments for this course.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-container">
                                <table class="data-table">
                                    <thead>
                                    <tr><th>Title</th><th>Type</th><th>Archived On</th><th>Actions</th></tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="a" items="${archivedAssessments}">
                                        <tr>
                                            <td><strong><c:out value="${a.title}"/></strong><div class="sv-course-line">${not empty a.totalMarks ? a.totalMarks : 'N/A'} marks</div></td>
                                            <td><span class="assessment-type-badge type-${fn:replace(a.type, ' ', '-')}">${a.type}</span></td>
                                            <td>${not empty a.deletedAt ? a.deletedAt.toLocalDate() : '-'}</td>
                                            <td>
                                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">Open Builder</a>
                                                <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=restoreAssessment&courseId=${selectedCourse.courseId}&id=${a.assessmentId}" onclick="return confirm('Restore this assessment?')">Restore</a>
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
            <c:otherwise>
                <section class="section-card">
                    <div class="section-header">
                        <div><h3 class="section-title">Assessment Library</h3><p class="section-caption">All assessments for this course.</p></div>
                        <a class="btn btn-primary btn-sm" href="${assessmentWorkspaceBaseUrl}&view=editor">Create First</a>
                    </div>

                    <c:choose>
                        <c:when test="${empty assessments}">
                            <div class="empty-state-box workspace-empty-box">
                                <i class="fas fa-clipboard-list"></i>
                                <p>No assessments created for this course yet.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="workspace-assessment-grid" style="display:grid; gap:20px; grid-template-columns:repeat(auto-fill, minmax(300px, 1fr));">
                                <c:forEach var="assessment" items="${assessments}">
                                    <article class="ia-assessment-card" style="padding:20px; border:1px solid var(--ins-border); border-radius:12px; background:#fff;">
                                        <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:12px;">
                                            <div>
                                                <span style="font-size:0.65rem; font-weight:800; text-transform:uppercase; color:var(--ins-primary); letter-spacing:0.05em; display:block; margin-bottom:4px;">${assessment.type}</span>
                                                <strong style="display:block; font-size:1.1rem; color:var(--ins-text);"><c:out value="${assessment.title}"/></strong>
                                            </div>
                                            <div style="width:32px; height:32px; border-radius:8px; background:var(--ins-accent-soft); color:var(--ins-primary); display:flex; align-items:center; justify-content:center;">
                                                <i class="fas ${assessment.type == 'Assignment' ? 'fa-file-signature' : 'fa-stopwatch'}"></i>
                                            </div>
                                        </div>
                                        <div style="display:flex; gap:12px; margin-bottom:20px; font-size:0.8rem; color:var(--ins-muted);">
                                            <span><i class="fas fa-users" style="margin-right:4px;"></i> ${submissionCountByAssessmentId[assessment.assessmentId]}</span>
                                            <span style="color:#ea580c; font-weight:600;"><i class="fas fa-clock-rotate-left" style="margin-right:4px;"></i> ${not empty pendingCountByAssessmentId[assessment.assessmentId] ? pendingCountByAssessmentId[assessment.assessmentId] : 0} pending</span>
                                        </div>
                                        <div style="display:flex; gap:8px; border-top:1px solid var(--ins-border); padding-top:16px;">
                                            <button type="button" class="btn btn-secondary btn-sm" onclick="openAssessmentPage('submissions', ${assessment.assessmentId})" style="flex:1; justify-content:center;">Review</button>
                                            <button type="button" class="btn btn-secondary btn-sm" onclick="openAssessmentPage('editor', ${assessment.assessmentId})" style="width:40px; justify-content:center;"><i class="fas fa-cog"></i></button>
                                            <a href="${pageContext.request.contextPath}/instructor/assessments?action=archiveAssessment&courseId=${selectedCourse.courseId}&id=${assessment.assessmentId}" class="btn btn-danger btn-sm" style="width:40px; justify-content:center;" onclick="return confirm('Archive this assessment?')" title="Archive Assessment"><i class="fas fa-box-archive"></i></a>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>

                            <c:if test="${not empty archivedAssessments}">
                                <div style="margin-top:24px; padding:16px; background:#f8fafc; border-radius:12px; display:flex; justify-content:space-between; align-items:center;">
                                    <span style="font-size:0.85rem; color:var(--ins-muted);">You have <strong>${fn:length(archivedAssessments)}</strong> archived assessments.</span>
                                    <button type="button" class="btn btn-secondary btn-sm" onclick="openAssessmentPage('archive')">Manage Archive</button>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </section>
            </c:otherwise>
        </c:choose>
                                            <td><span class="assessment-type-badge type-${fn:replace(a.type, ' ', '-')}">${a.type}</span></td>
                                            <td>${not empty a.deletedAt ? a.deletedAt.toLocalDate() : '-'}</td>
                                            <td>
                                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">Open Builder</a>
                                                <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=restoreAssessment&courseId=${selectedCourse.courseId}&id=${a.assessmentId}" onclick="return confirm('Restore this assessment?')">Restore</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </section>
        </c:when>

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
