<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<section class="ax-stage" id="overviewStage" data-stage-current="true">
    <article class="ax-frame ax-overview">
        <span class="ax-overview__eyebrow"><i class="fas fa-clipboard-check"></i> Assessment Brief</span>
        <h1 class="ax-overview__title">${assessment.title}</h1>
        <p class="ax-overview__body">
            <c:choose>
                <c:when test="${not empty displayInstructions}">${displayInstructions}</c:when>
                <c:when test="${objectiveAssessment}">This assessment is timed and graded from the current question payload. Review the brief below before starting.</c:when>
                <c:otherwise>Prepare your file or written response using the current submission mode shown below.</c:otherwise>
            </c:choose>
        </p>

        <div class="ax-meta-grid">
            <div class="ax-meta-card">
                <i class="fas fa-clock"></i>
                <div><span>Time Limit</span><strong>${assessment.duration != null ? assessment.duration : '--'}${assessment.duration != null ? ' minutes' : ''}</strong></div>
            </div>
            <div class="ax-meta-card">
                <i class="fas fa-list-check"></i>
                <div><span>Total Questions</span><strong>${assessmentSummary.questionCount}</strong></div>
            </div>
            <div class="ax-meta-card">
                <i class="fas fa-trophy"></i>
                <div><span>Passing Score</span><strong>70%</strong></div>
            </div>
            <div class="ax-meta-card">
                <i class="fas fa-repeat"></i>
                <div><span>Attempts Allowed</span><strong>${allowedAttempts} total, ${remainingAttempts} left</strong></div>
            </div>
        </div>

        <div class="ax-overview__footer">
            <div class="ax-chip-row">
                <span class="ax-chip"><i class="fas fa-signal"></i> ${assessmentSummary.statusLabel}</span>
                <span class="ax-chip"><i class="fas fa-layer-group"></i> ${assessment.type}</span>
            </div>
            <div class="ax-cta-row">
                <c:choose>
                    <c:when test="${canAttempt and objectiveAssessment}">
                        <a class="ax-btn ax-btn--primary"
                           href="${pageContext.request.contextPath}/student/assessments?view=take&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&mode=attempt"
                           data-load-attempt-url="${pageContext.request.contextPath}/student/assessments?view=take&enrollmentId=${enrollment.enrollmentId}&assessmentId=${assessment.assessmentId}&mode=attempt">
                            <i class="fas fa-play"></i>
                            <span>Start Assessment</span>
                        </a>
                    </c:when>
                    <c:when test="${canAttempt}">
                        <button type="button" class="ax-btn ax-btn--primary" data-stage-target="assignmentWorkspace">
                            <i class="fas fa-pen-ruler"></i>
                            <span>Start Assessment</span>
                        </button>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="ax-btn ax-btn--danger" disabled="disabled">
                            <i class="fas fa-ban"></i>
                            <span>No Attempts Remaining</span>
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </article>
</section>

<c:if test="${not objectiveAssessment}">
    <section class="ax-stage" id="assignmentWorkspace" hidden>
        <article class="ax-frame ax-overview">
            <span class="ax-overview__eyebrow"><i class="fas fa-folder-open"></i> Submission Workspace</span>
            <h2 class="ax-focus__title" style="font-size: clamp(1.8rem, 3vw, 2.5rem);">Prepare Your Submission</h2>
            <p class="ax-focus__body">Upload a file, add a short written answer if needed, and submit through the current backend contract.</p>

            <c:if test="${not empty questions}">
                <div class="ax-review-list" style="margin-top: 18px;">
                    <c:forEach var="q" items="${questions}" varStatus="loop">
                        <div class="ax-inline-card">
                            <i class="fas fa-book-open"></i>
                            <div>
                                <span>Prompt ${loop.index + 1}</span>
                                <strong>${q.questionText}</strong>
                                <c:if test="${not empty q.attachmentUrl}">
                                    <div style="margin-top: 10px;">
                                        <a class="ax-btn ax-btn--secondary" href="${q.attachmentUrl}" target="_blank" rel="noopener noreferrer">
                                            <i class="fas fa-file-pdf"></i>
                                            <span>Open PDF Brief</span>
                                        </a>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <form method="post"
                  action="${pageContext.request.contextPath}/student/assessments"
                  enctype="multipart/form-data"
                  data-loading-submit
                  style="display: grid; gap: 20px; margin-top: 24px;">
                <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">

                <div class="ax-panel" style="padding: 22px;">
                    <span class="ax-section-label"><i class="fas fa-cloud-arrow-up"></i> Attach File</span>
                    <div class="ax-upload-zone" data-upload-zone style="margin-top: 16px;">
                        <input name="answerFile" type="file">
                        <div class="ax-upload-zone__icon"><i class="fas fa-file-arrow-up"></i></div>
                        <h3 class="ax-upload-zone__title">Drop your file here or browse</h3>
                        <p class="ax-upload-zone__copy">Supports PDF, DOC, DOCX, PPT, PPTX, ZIP, and image files up to 50MB.</p>
                    </div>
                    <div class="ax-file-list" data-file-list style="margin-top: 14px;"></div>
                </div>

                <div class="ax-panel" style="padding: 22px;">
                    <span class="ax-section-label"><i class="fas fa-pen"></i> Written Answer</span>
                    <div style="margin-top: 16px;">
                        <textarea class="ax-textarea" name="answerText" maxlength="255" placeholder="Add a concise response if required."></textarea>
                    </div>
                    <div class="ax-field-meta">
                        <span>Styled workspace, current plain-text payload.</span>
                        <span>255 character limit</span>
                    </div>
                </div>

                <div class="ax-actions">
                    <button type="button" class="ax-btn ax-btn--secondary" data-stage-target="overviewStage">
                        <i class="fas fa-arrow-left"></i>
                        <span>Back to Overview</span>
                    </button>
                    <button type="submit" class="ax-btn ax-btn--primary" data-submit-button data-loading-label="Submitting your work...">
                        <i class="fas fa-paper-plane"></i>
                        <span>Submit Assessment</span>
                    </button>
                </div>
            </form>
        </article>
    </section>
</c:if>
