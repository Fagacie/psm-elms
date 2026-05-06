<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submissions & Grading - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessment-flow.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Submissions & Grading"/>
</jsp:include>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>


<main class="app-main">
    <div class="content-wrapper">
        <jsp:include page="/WEB-INF/views/instructor/fragments/assessment-breadcrumb.jsp">
            <jsp:param name="currentLabel" value="Submissions"/>
        </jsp:include>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Submissions & Grading</p>
                <h2>
                    <c:choose>
                        <c:when test="${selectedAssessment.type == 'Assignment'}">Assignment Review: ${selectedAssessment.title}</c:when>
                        <c:otherwise>Assessment Results: ${selectedAssessment.title}</c:otherwise>
                    </c:choose>
                </h2>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}#assessments" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Course Workspace
                </a>
                <a href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}" class="btn btn-secondary">
                    <i class="fas fa-pen-to-square"></i> Modify
                </a>
                <a href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&courseId=${selectedCourse.courseId}&id=${selectedAssessment.assessmentId}" class="btn btn-danger" onclick="return confirm('Archive this assessment? You can restore it later from archive.');">
                    <i class="fas fa-box-archive"></i> Archive
                </a>
            </div>
        </section>

        <!-- Messages -->
        <c:if test="${param.success == 'graded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Grade saved for student.</div></c:if>
        <c:if test="${param.success == 'autoregraded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> MCQ auto-graded successfully.</div></c:if>
        <c:if test="${param.error == 'graderange'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Invalid score. Must be between 0 and ${selectedAssessment.totalMarks}.</div></c:if>
        <c:if test="${not empty errorMessage}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div></c:if>

        <div class="ia-flow-grid-single">
            <!-- Modern Submissions Table with Inline Grading -->
            <div class="section-card" style="padding: 0; overflow: hidden;">
                <div class="ia-roster-head">
                    <h3>
                        <c:choose>
                            <c:when test="${selectedAssessment.type == 'Assignment'}">
                                <i class="fas fa-file-pen"></i> Assignment Submissions
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-chart-column"></i> Assessment Results
                            </c:otherwise>
                        </c:choose>
                    </h3>
                    <span class="ia-roster-count">
                        <strong>${fn:length(assessmentRosterRows)}</strong> Enrolled
                    </span>
                    <div style="display:flex; gap:8px; align-items:center;">
                        <button id="ia-fullview-toggle" type="button" class="btn btn-sm btn-secondary" title="Toggle full view">
                            <i class="fas fa-expand"></i> Full View
                        </button>
                    </div>
                </div>
                
                <c:choose>
                    <c:when test="${empty assessmentRosterRows}">
                        <div class="ia-empty-state" style="padding: 60px 24px;">
                            <div class="ia-empty-icon"><i class="fas fa-users-slash"></i></div>
                            <h3>No Students</h3>
                            <p>There are currently no students enrolled in this course.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="ia-submissions-table">
                                <thead>
                                    <tr>
                                        <th class="col-expand"></th>
                                        <th class="col-student">Student</th>
                                        <th class="col-status">Status</th>
                                        <th class="col-date">Submitted</th>
                                        <th class="col-attempt">Attempt</th>
                                        <th class="col-score">Score</th>
                                        <th class="col-actions">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="row" items="${assessmentRosterRows}">
                                        <c:set var="submission" value="${row.latestSubmission}"/>
                                        <tr class="ia-submission-row ${not empty selectedSubmission and submission.submissionId == selectedSubmission.submissionId ? 'ia-expanded' : ''}" data-submission-id="${not empty submission ? submission.submissionId : ''}">
                                            <td class="col-expand">
                                                <c:if test="${not empty submission}">
                                                    <button type="button" class="ia-expand-btn" data-submission-id="${submission.submissionId}" title="Toggle grading panel">
                                                        <i class="fas fa-chevron-down"></i>
                                                    </button>
                                                </c:if>
                                            </td>
                                            <td class="col-student">
                                                <div class="ia-student-meta">
                                                    <strong>${row.studentName}</strong>
                                                    <span>${row.studentEmail}</span>
                                                </div>
                                            </td>
                                            <td class="col-status">
                                                <c:if test="${not empty submission}">
                                                    <span class="status-badge status-${fn:toLowerCase(fn:replace(row.studentStatusLabel, ' ', '-'))}" style="font-size: 0.75rem;">
                                                        ${row.studentStatusLabel}
                                                    </span>
                                                </c:if>
                                                <c:if test="${empty submission}">
                                                    <span class="status-badge status-not-submitted" style="font-size: 0.75rem;">Not Submitted</span>
                                                </c:if>
                                            </td>
                                            <td class="col-date">
                                                <c:choose>
                                                    <c:when test="${not empty submission and not empty submission.submitDate}">
                                                        <span class="ia-date-cell">${fn:replace(submission.submitDate, 'T', ' ')}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="ia-muted-dash">--</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="col-attempt">
                                                <c:choose>
                                                    <c:when test="${not empty submission}">
                                                        <span class="ia-attempt-chip">#${submission.attemptNumber}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="ia-muted-dash">--</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="col-score">
                                                <c:choose>
                                                    <c:when test="${not empty submission and submission.score != null}">
                                                        <strong class="ia-score-value">${submission.score}</strong>
                                                        <span class="ia-score-total">/ ${selectedAssessment.totalMarks}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="ia-muted-dash">--</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="col-actions">
                                                <c:if test="${not empty submission}">
                                                    <div class="ia-action-buttons">
                                                        <button type="button" class="btn btn-sm btn-secondary ia-grade-btn" data-submission-id="${submission.submissionId}" title="Open grading panel">
                                                            <i class="fas fa-pen-to-square"></i>
                                                        </button>
                                                        <a href="#" class="btn btn-sm btn-secondary ia-view-btn" data-submission-id="${submission.submissionId}" title="View full details">
                                                            <c:choose>
                                                                <c:when test="${selectedAssessment.type == 'Assignment'}">
                                                                    <i class="fas fa-file"></i>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="fas fa-eye"></i>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </a>
                                                    </div>
                                                </c:if>
                                                <c:if test="${empty submission}">
                                                    <span class="ia-no-work">No submission</span>
                                                </c:if>
                                            </td>
                                        </tr>

                                        <!-- Grading Detail Row (Hidden by default, shown on expand) -->
                                        <c:if test="${not empty submission}">
                                            <tr class="ia-detail-row" id="detail-${submission.submissionId}" style="display: none;">
                                                <td colspan="7">
                                                    <div class="ia-grading-detail">
                                                        <c:set var="submissionPayload" value="${submission.answersFilePath}"/>
                                                        <c:set var="submissionIsUrl" value="${not empty submissionPayload and (fn:startsWith(submissionPayload, 'http://') or fn:startsWith(submissionPayload, 'https://'))}"/>

                                                        <!-- Submission Content Preview -->
                                                        <div class="ia-detail-section">
                                                            <h4 class="ia-detail-title">Submission Content</h4>
                                                            
                                                            <c:if test="${selectedAssessment.type == 'Assignment' and not empty submissionPayload}">
                                                                <div class="ia-submission-file-box">
                                                                    <div style="width: 40px; height: 40px; border-radius: 10px; background: var(--ins-accent-soft); display: flex; align-items: center; justify-content: center; color: var(--ins-primary); flex-shrink: 0;">
                                                                        <i class="fas fa-file-arrow-up" style="font-size: 1.2rem;"></i>
                                                                    </div>
                                                                    <div style="flex: 1;">
                                                                        <strong style="display: block; font-size: 0.9rem; color: var(--ins-text);">Submitted File</strong>
                                                                        <a href="${submissionIsUrl ? submissionPayload : pageContext.request.contextPath.concat('/uploads/').concat(submissionPayload)}" target="_blank" rel="noopener noreferrer" style="font-size: 0.85rem; color: var(--ins-primary); font-weight: 600; text-decoration: none;">
                                                                            Open File <i class="fas fa-up-right-from-square" style="font-size: 0.65rem; margin-left: 4px;"></i>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </c:if>

                                                            <c:if test="${(selectedAssessment.type == 'Quiz' or selectedAssessment.type == 'Exam') and not empty submissionPayload}">
                                                                <div class="ia-submission-file-box">
                                                                    <div style="width: 40px; height: 40px; border-radius: 10px; background: var(--ins-accent-soft); display: flex; align-items: center; justify-content: center; color: var(--ins-primary); flex-shrink: 0;">
                                                                        <i class="fas fa-list-check" style="font-size: 1.2rem;"></i>
                                                                    </div>
                                                                    <div style="flex: 1;">
                                                                        <strong style="display: block; font-size: 0.9rem; color: var(--ins-text); margin-bottom: 8px;">Submitted Answers</strong>
                                                                        <div class="ia-answer-chip-wrap">
                                                                            <c:forEach var="entry" items="${fn:split(submissionPayload, ';')}">
                                                                                <c:if test="${not empty entry}">
                                                                                    <span class="ia-answer-chip">${entry}</span>
                                                                                </c:if>
                                                                            </c:forEach>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:if>

                                                            <c:if test="${empty submissionPayload}">
                                                                <div class="ia-submission-file-box" style="background: #fef8f8; border-color: #fecaca;">
                                                                    <div style="width: 40px; height: 40px; border-radius: 10px; background: #fee2e2; display: flex; align-items: center; justify-content: center; color: #991b1b; flex-shrink: 0;">
                                                                        <i class="fas fa-exclamation-circle" style="font-size: 1.2rem;"></i>
                                                                    </div>
                                                                    <div style="flex: 1;">
                                                                        <strong style="display: block; font-size: 0.9rem; color: var(--ins-text);">No submission content</strong>
                                                                        <span style="font-size: 0.85rem; color: var(--ins-muted);">Score/status recorded, no file or answers stored.</span>
                                                                    </div>
                                                                </div>
                                                            </c:if>
                                                        </div>

                                                        <!-- Grading Form -->
                                                        <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-detail-section ia-grading-form">
                                                            <h4 class="ia-detail-title">Grade & Feedback</h4>
                                                            
                                                            <input type="hidden" name="action" value="gradeSubmission" />
                                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                                                            <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                                                            <input type="hidden" name="submissionId" value="${submission.submissionId}" />
                                                            <input type="hidden" name="workflowAction" value="submissions" />

                                                            <div class="ia-form-grid">
                                                                <div style="flex: 1;">
                                                                    <label for="score-${submission.submissionId}" class="ia-form-label">Final Score <span style="color: #dc2626;">*</span></label>
                                                                    <div style="position: relative; display: flex; gap: 8px; align-items: center;">
                                                                        <input 
                                                                            id="score-${submission.submissionId}" 
                                                                            name="score" 
                                                                            type="number" 
                                                                            min="0" 
                                                                            max="${selectedAssessment.totalMarks}" 
                                                                            step="0.5" 
                                                                            value="${submission.score}" 
                                                                            class="ia-score-input"
                                                                            required />
                                                                        <span class="ia-score-max">/ ${selectedAssessment.totalMarks}</span>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <div>
                                                                <label for="feedback-${submission.submissionId}" class="ia-form-label">Feedback for Student</label>
                                                                <textarea 
                                                                    id="feedback-${submission.submissionId}" 
                                                                    name="feedback" 
                                                                    rows="3" 
                                                                    class="ia-feedback-textarea"
                                                                    placeholder="Provide constructive feedback on the student's work...">${submission.feedback}</textarea>
                                                            </div>

                                                            <div class="ia-form-actions">
                                                                <button class="btn btn-primary" type="submit">
                                                                    <i class="fas fa-check-double"></i> Save Grade
                                                                </button>
                                                                
                                                                <c:if test="${selectedAssessment.type == 'Quiz' or selectedAssessment.type == 'Exam'}">
                                                                    <button 
                                                                        type="submit" 
                                                                        formaction="${pageContext.request.contextPath}/instructor/assessments?action=autoRegradeSubmission&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&submissionId=${submission.submissionId}" 
                                                                        class="btn btn-secondary"
                                                                        onclick="return confirm('Recalculate score based on current MCQ bank answers?');">
                                                                        <i class="fas fa-wand-sparkles"></i> Auto-Regrade
                                                                    </button>
                                                                </c:if>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</main>



<script>
    function toggleGradingPanel(button, submissionId) {
        let row = button.closest('.ia-submission-row');
        if (!row) return;
        const detailRow = document.getElementById('detail-' + submissionId);
        if (!detailRow) return;

        const isExpanded = row.classList.contains('ia-expanded');

        // close others
        document.querySelectorAll('.ia-submission-row.ia-expanded').forEach(r => {
            if (r !== row) {
                r.classList.remove('ia-expanded');
                const otherId = r.getAttribute('data-submission-id');
                const otherDetail = document.getElementById('detail-' + otherId);
                if (otherDetail) otherDetail.style.display = 'none';
            }
        });

        if (isExpanded) {
            row.classList.remove('ia-expanded');
            detailRow.style.display = 'none';
        } else {
            row.classList.add('ia-expanded');
            detailRow.style.display = 'table-row';
            setTimeout(() => {
                const scoreInput = document.getElementById('score-' + submissionId);
                if (scoreInput) { scoreInput.focus(); scoreInput.select(); }
            }, 50);
        }
    }

    // Submit grading forms via AJAX so UI updates and table resets cleanly
    async function submitGradingForm(form, submitBtn) {
        const action = (submitBtn && submitBtn.formAction) ? submitBtn.formAction : form.action;
        const fd = new FormData(form);
        try {
            const resp = await fetch(action, {
                method: 'POST',
                body: fd,
                credentials: 'same-origin'
            });

            if (resp.redirected) {
                // follow server redirect (e.g., to same page with success params)
                window.location.href = resp.url;
                return;
            }

            // Prefer JSON responses so we can update the row in-place.
            const ct = resp.headers.get('content-type') || '';
            if (ct.indexOf('application/json') !== -1) {
                const data = await resp.json();
                if (data && data.success) {
                    const subId = data.submissionId || form.querySelector('input[name=submissionId]')?.value;
                    if (subId) {
                        const row = document.querySelector('.ia-submission-row[data-submission-id="' + subId + '"]');
                        if (row) {
                            // update score
                            const scoreEl = row.querySelector('.ia-score-value');
                            if (scoreEl && data.score !== undefined && data.score !== null) scoreEl.textContent = data.score;
                            // update total if provided
                            const totalEl = row.querySelector('.ia-score-total');
                            if (totalEl && data.totalMarks) totalEl.textContent = '/ ' + data.totalMarks;
                            // update submitted date
                            const dateEl = row.querySelector('.col-date .ia-date-cell');
                            if (dateEl && data.submitDate) dateEl.textContent = data.submitDate.replace('T',' ');
                            // update status badge
                            const statusEl = row.querySelector('.col-status .status-badge');
                            if (statusEl && data.statusLabel) statusEl.textContent = data.statusLabel;
                        }
                    }

                    // close modal if open
                    try { closeModal(); } catch (e) {}

                    // re-enable buttons
                    form.querySelectorAll('button, input[type=submit]').forEach(b => b.disabled = false);

                    // show transient success (optional)
                    // You could show an inline toast here; for now use a simple alert if requested by server
                    if (data.message) console.log('Grade saved:', data.message);
                    return;
                } else {
                    alert(data.message || 'Failed to save grade.');
                    form.querySelectorAll('button, input[type=submit]').forEach(b => b.disabled = false);
                    return;
                }
            }

            if (resp.ok) {
                // Fallback: refresh page to ensure data integrity
                window.location.reload();
            } else {
                const txt = await resp.text();
                console.error('Grading save failed:', txt);
                alert('Failed to save grade. See console for details.');
            }
        } catch (err) {
            console.error('Network error saving grade', err);
            alert('Network error while saving grade.');
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        const toggleBtn = document.getElementById('instructorMenuToggle');
        if (toggleBtn) toggleBtn.addEventListener('click', () => document.body.classList.toggle('ins-shell-collapsed'));

        // bind grade and expand buttons
        // Grade buttons open modal with grading detail
        document.querySelectorAll('.ia-grade-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                const submissionId = this.getAttribute('data-submission-id') || (this.closest('.ia-submission-row') && this.closest('.ia-submission-row').getAttribute('data-submission-id'));
                if (submissionId) openModal(submissionId);
            });
        });

        // Expand inline detail rows remain available
        document.querySelectorAll('.ia-expand-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                const submissionId = this.getAttribute('data-submission-id') || (this.closest('.ia-submission-row') && this.closest('.ia-submission-row').getAttribute('data-submission-id'));
                if (submissionId) toggleGradingPanel(this, submissionId);
            });
        });

        // View buttons open modal too
        document.querySelectorAll('.ia-view-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                const submissionId = this.getAttribute('data-submission-id');
                if (submissionId) openModal(submissionId);
            });
        });

        // Intercept grading form submissions (handles Save Grade and Auto-Regrade)
        // Handles forms both inside modal and inline detail rows
        function bindGradingForms(root) {
            root.querySelectorAll('.ia-grading-form').forEach(form => {
                // ensure not bound twice
                if (form.__iaBound) return; form.__iaBound = true;
                form.addEventListener('submit', function(e) {
                    e.preventDefault();
                    const submitBtn = e.submitter || form.querySelector('button[type=submit]');
                    // disable buttons to prevent double submits
                    form.querySelectorAll('button, input[type=submit]').forEach(b => b.disabled = true);
                    submitGradingForm(form, submitBtn);
                });
            });
        }

        bindGradingForms(document);

        // Full view toggle
        const fv = document.getElementById('ia-fullview-toggle');
        if (fv) fv.addEventListener('click', function() {
            document.body.classList.toggle('ia-fullview-active');
            this.classList.toggle('active');
        });
    });

    // Modal handling: clone detail content into modal and bind form handlers
    function openModal(submissionId) {
        const modal = document.getElementById('ia-modal');
        const contentWrap = modal.querySelector('.ia-modal-content-body');
        contentWrap.innerHTML = '';
        const detail = document.getElementById('detail-' + submissionId);
        if (!detail) return alert('Submission details not available.');

        // clone grading detail and strip duplicate ids
        const node = detail.querySelector('.ia-grading-detail');
        if (!node) return alert('Submission details not available.');
        const clone = node.cloneNode(true);
        // remove id attributes to avoid duplicates
        clone.querySelectorAll('[id]').forEach(el => el.removeAttribute('id'));

        contentWrap.appendChild(clone);

        // bind forms inside cloned content
        clone.querySelectorAll('.ia-grading-form').forEach(f => {
            f.addEventListener('submit', function(e) {
                e.preventDefault();
                const submitBtn = e.submitter || f.querySelector('button[type=submit]');
                f.querySelectorAll('button, input[type=submit]').forEach(b => b.disabled = true);
                submitGradingForm(f, submitBtn);
            });
        });

        modal.classList.add('is-open');
    }

    function closeModal() {
        const modal = document.getElementById('ia-modal');
        if (!modal) return;
        modal.classList.remove('is-open');
        modal.querySelector('.ia-modal-content-body').innerHTML = '';
    }

    // close modal on backdrop click or escape
    document.addEventListener('click', function(e) {
        const modal = document.getElementById('ia-modal');
        if (!modal || !modal.classList.contains('is-open')) return;
        if (e.target.classList && e.target.classList.contains('ia-modal-backdrop')) closeModal();
    });
    document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });
</script>

<!-- Modal Markup -->
<div id="ia-modal" class="ia-modal" aria-hidden="true">
    <div class="ia-modal-backdrop"></div>
    <div class="ia-modal-content" role="dialog" aria-modal="true">
        <button type="button" class="ia-modal-close btn btn-sm" aria-label="Close" onclick="closeModal()"><i class="fas fa-xmark"></i></button>
        <div class="ia-modal-content-body" style="padding-top:8px;"></div>
    </div>
</div>
</body>
</html>
