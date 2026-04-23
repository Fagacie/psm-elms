<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<div class="cp-fragment assessment-fragment">
    <div class="cp-header">
        <div class="mv-head-top">
            <span class="status-badge sa-status-${fn:toLowerCase(assessmentSummary.statusLabel)}">${assessmentSummary.statusLabel}</span>
            <span class="cp-type-badge">${assessment.type}</span>
        </div>
        <h2>${assessment.title}</h2>
        <c:if test="${not empty displayInstructions}">
            <p class="mv-description">${fn:trim(displayInstructions)}</p>
        </c:if>

        <div class="sa-chips">
            <c:if test="${assessment.duration != null}">
                <span class="sa-chip"><i class="fas fa-clock"></i> ${assessment.duration} min</span>
            </c:if>
            <c:if test="${assessment.totalMarks != null}">
                <span class="sa-chip"><i class="fas fa-layer-group"></i> ${assessment.totalMarks} marks</span>
            </c:if>
            <span class="sa-chip"><i class="fas fa-repeat"></i> ${remainingAttempts} attempt(s) left</span>
        </div>
    </div>

    <div class="cp-viewer-container">
        <article class="sa-panel">
            <div class="sa-panel-head">
                <h3>Assessment Overview</h3>
            </div>

            <div class="sa-info-grid">
                <div class="sa-info-row">
                    <span class="sa-info-label">Deadline</span>
                    <span class="sa-info-value">${assessmentSummary.dueDateLabel}</span>
                </div>
                <div class="sa-info-row">
                    <span class="sa-info-label">Attempts Used</span>
                    <span class="sa-info-value">${usedAttempts} / ${allowedAttempts}</span>
                </div>
                <div class="sa-info-row">
                    <span class="sa-info-label">Questions</span>
                    <span class="sa-info-value">${assessmentSummary.questionCount}</span>
                </div>
                <div class="sa-info-row">
                    <span class="sa-info-label">Format</span>
                    <span class="sa-info-value">
                        <c:choose>
                            <c:when test="${objectiveAssessment}">Multiple Choice</c:when>
                            <c:when test="${submissionMode == 'file'}">File Upload</c:when>
                            <c:when test="${submissionMode == 'text'}">Written Response</c:when>
                            <c:otherwise>Text + File</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <c:if test="${objectiveAssessment}">
                <div class="sa-note-warning">
                    <i class="fas fa-hourglass-half"></i>
                    Once started, the timer runs until you submit or time expires.
                </div>
            </c:if>

            <div class="sa-footer-actions">
                <c:choose>
                    <c:when test="${canAttempt}">
                        <%-- Button fires CP_StartAssessment event so the hub loads it inline --%>
                        <button type="button" class="sv-btn primary"
                                id="btnStartAssessment"
                                data-attempt-url="${pageContext.request.contextPath}/student/assessments?view=take&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&mode=attempt">
                            <i class="fas fa-play"></i> Start Assessment
                        </button>
                    </c:when>
                    <c:otherwise>
                        <span class="sa-no-attempts"><i class="fas fa-ban"></i> No attempts remaining</span>
                        <c:if test="${assessmentSummary.latestSubmission != null}">
                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=result&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}">
                                <i class="fas fa-eye"></i> View Results
                            </a>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </article>
    </div>
</div>

<script>
(function () {
    var btn = document.getElementById('btnStartAssessment');
    if (!btn) return;
    btn.addEventListener('click', function () {
        var url = this.getAttribute('data-attempt-url');
        if (!url) return;
        // Fire event upward to the course player host page
        document.dispatchEvent(new CustomEvent('CP_StartAssessment', {
            bubbles: true,
            detail: { attemptUrl: url }
        }));
    });
})();
</script>
