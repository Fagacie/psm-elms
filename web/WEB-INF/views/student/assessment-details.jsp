<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${assessment.title} - Assessment Overview</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-experience.css">
</head>
<body class="sv-page ax-page">
<c:set var="topbarTitle" value="Assessment Overview"/>
<c:set var="topbarSubtitle" value="Review the format, timing, and submission requirements"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="course"/>
<c:set var="navContextPage" value="assessments"/>
<c:set var="navCourseEnrollmentId" value="${enrollment.enrollmentId}"/>
<c:set var="navCourseTitle" value="${enrollment.courseName}"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main ax-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">Assessments</a>
            <span>/</span>
            <span>Overview</span>
        </div>

        <section class="ax-shell">
            <div class="ax-stage-host" data-assessment-stage-host>
                <section class="ax-stage" id="overviewStage" data-stage-current="true">
                    <article class="ax-frame ax-overview">
                        <span class="ax-overview__eyebrow"><i class="fas fa-clipboard-check"></i> Assessment Brief</span>
                        <h1 class="ax-overview__title">${assessment.title}</h1>
                        <p class="ax-overview__body">
                            <c:choose>
                                <c:when test="${not empty displayInstructions}">${displayInstructions}</c:when>
                                <c:when test="${objectiveAssessment}">This assessment is timed and graded from the current question payload. Review the requirements below before starting.</c:when>
                                <c:otherwise>Prepare your response using the current submission rules below. You can upload a file, provide a short written response, or both depending on this assessment mode.</c:otherwise>
                            </c:choose>
                        </p>

                        <div class="ax-meta-grid">
                            <div class="ax-meta-card">
                                <i class="fas fa-clock"></i>
                                <div>
                                    <span>Time Limit</span>
                                    <strong>${assessment.duration != null ? assessment.duration : '--'}${assessment.duration != null ? ' minutes' : ''}</strong>
                                </div>
                            </div>
                            <div class="ax-meta-card">
                                <i class="fas fa-list-check"></i>
                                <div>
                                    <span>Total Questions</span>
                                    <strong>${assessmentSummary.questionCount}</strong>
                                </div>
                            </div>
                            <div class="ax-meta-card">
                                <i class="fas fa-trophy"></i>
                                <div>
                                    <span>Passing Score</span>
                                    <strong>70%</strong>
                                </div>
                            </div>
                            <div class="ax-meta-card">
                                <i class="fas fa-repeat"></i>
                                <div>
                                    <span>Attempts Allowed</span>
                                    <strong>${allowedAttempts} total, ${remainingAttempts} left</strong>
                                </div>
                            </div>
                            <div class="ax-meta-card">
                                <i class="fas fa-layer-group"></i>
                                <div>
                                    <span>Assessment Type</span>
                                    <strong>${assessment.type}</strong>
                                </div>
                            </div>
                            <div class="ax-meta-card">
                                <i class="fas fa-file-signature"></i>
                                <div>
                                    <span>Submission Mode</span>
                                    <strong>
                                        <c:choose>
                                            <c:when test="${objectiveAssessment}">Multiple Choice</c:when>
                                            <c:when test="${submissionMode == 'file'}">File Upload</c:when>
                                            <c:when test="${submissionMode == 'text'}">Written Response</c:when>
                                            <c:otherwise>Written Response + File</c:otherwise>
                                        </c:choose>
                                    </strong>
                                </div>
                            </div>
                        </div>

                        <div class="ax-overview__footer">
                            <div class="ax-chip-row">
                                <span class="ax-chip"><i class="fas fa-signal"></i> ${assessmentSummary.statusLabel}</span>
                                <span class="ax-chip"><i class="fas fa-chart-line"></i> ${usedAttempts} used of ${allowedAttempts}</span>
                                <c:if test="${assessment.totalMarks != null}">
                                    <span class="ax-chip"><i class="fas fa-star"></i> ${assessment.totalMarks} marks</span>
                                </c:if>
                            </div>
                            <div class="ax-cta-row">
                                <a class="ax-btn ax-btn--secondary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                                    <i class="fas fa-arrow-left"></i>
                                    <span>Back to Course</span>
                                </a>
                                <c:choose>
                                    <c:when test="${enrollment.daysRemaining < 0 && enrollment.courseDuration != null && enrollment.courseDuration > 0}">
                                        <button type="button" class="ax-btn ax-btn--danger" disabled="disabled">
                                            <i class="fas fa-calendar-times"></i>
                                            <span>Course Expired</span>
                                        </button>
                                    </c:when>
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

                        <c:if test="${not empty materialBlockReason}">
                            <div class="ax-alert ax-alert--warning">
                                <strong><i class="fas fa-lock"></i> Assessment Locked</strong>
                                <span>${materialBlockReason}</span>
                                <c:if test="${not empty prerequisiteMaterial}">
                                    <span>Required material: ${prerequisiteMaterial.title}</span>
                                </c:if>
                            </div>
                        </c:if>

                        <c:if test="${objectiveAssessment}">
                            <div class="ax-alert ax-alert--info">
                                <strong><i class="fas fa-hourglass-half"></i> Timed attempt</strong>
                                <span>Once you start, the countdown continues until you submit or time expires.</span>
                            </div>
                        </c:if>
                    </article>
                </section>

                <c:if test="${not objectiveAssessment}">
                    <section class="ax-stage" id="assignmentWorkspace" hidden>
                        <article class="ax-frame ax-overview">
                            <span class="ax-overview__eyebrow"><i class="fas fa-folder-open"></i> Submission Workspace</span>
                            <h2 class="ax-overview__title" style="font-size: clamp(1.8rem, 3vw, 2.5rem);">Prepare Your Submission</h2>
                            <p class="ax-overview__body">
                                Upload your file, add a short written answer if required, then submit using the current assessment payload. Text responses are limited to 255 characters by the existing backend.
                            </p>

                            <c:if test="${not empty questions}">
                                <div class="ax-review-list">
                                    <c:forEach var="q" items="${questions}" varStatus="loop">
                                        <div class="ax-inline-card">
                                            <i class="fas fa-file-lines"></i>
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

                                <div class="ax-composer__grid">
                                    <div class="ax-panel" style="padding: 22px;">
                                        <span class="ax-section-label"><i class="fas fa-cloud-arrow-up"></i> Attach File</span>
                                        <div class="ax-upload-zone" data-upload-zone style="margin-top: 16px;">
                                            <input id="answerFileInline" name="answerFile" type="file">
                                            <div class="ax-upload-zone__icon"><i class="fas fa-file-arrow-up"></i></div>
                                            <h3 class="ax-upload-zone__title">Drag and drop your PDF or source files here</h3>
                                            <p class="ax-upload-zone__copy">Accepted formats include PDF, DOC, DOCX, PPT, PPTX, ZIP, and image files. Maximum file size: 50MB.</p>
                                        </div>
                                        <div class="ax-file-list" data-file-list style="margin-top: 14px;"></div>
                                    </div>

                                    <div class="ax-panel" style="padding: 22px;">
                                        <span class="ax-section-label"><i class="fas fa-pen"></i> Written Response</span>
                                        <div style="margin-top: 16px;">
                                            <textarea class="ax-textarea" name="answerText" maxlength="255" placeholder="Add a concise written answer if this assessment accepts text responses.">${param.answerText}</textarea>
                                        </div>
                                        <div class="ax-field-meta">
                                            <span>Styled for longer writing, submitted as the current plain-text payload.</span>
                                            <span>Maximum 255 characters</span>
                                        </div>
                                    </div>
                                </div>

                                <c:if test="${param.error == 'missingAnswerFile'}">
                                    <div class="ax-alert ax-alert--danger">Add a file or a written response before submitting.</div>
                                </c:if>
                                <c:if test="${param.error == 'assignmentFileTooLarge'}">
                                    <div class="ax-alert ax-alert--danger">The uploaded file exceeds the 50MB limit.</div>
                                </c:if>
                                <c:if test="${param.error == 'assignmentUploadFailed'}">
                                    <div class="ax-alert ax-alert--danger">The upload failed. Please try again.</div>
                                </c:if>
                                <c:if test="${param.error == 'answerTooLong'}">
                                    <div class="ax-alert ax-alert--danger">The written response is longer than the current backend limit.</div>
                                </c:if>
                                <c:if test="${param.success == 'submitted'}">
                                    <div class="ax-alert ax-alert--success">Your assignment was submitted successfully.</div>
                                </c:if>

                                <c:if test="${not empty latestSubmission}">
                                    <div class="ax-note ax-note--info">
                                        <strong><i class="fas fa-history"></i> Latest submission</strong>
                                        <span>Status: ${latestSubmission.status}</span>
                                        <span>Submitted: ${latestSubmission.submitDate}</span>
                                    </div>
                                </c:if>

                                <div class="ax-actions">
                                    <button type="button" class="ax-btn ax-btn--secondary" data-stage-target="overviewStage">
                                        <i class="fas fa-arrow-left"></i>
                                        <span>Back to Overview</span>
                                    </button>
                                    <button type="submit"
                                            class="ax-btn ax-btn--primary"
                                            data-submit-button
                                            data-loading-label="Submitting your work...">
                                        <i class="fas fa-paper-plane"></i>
                                        <span>Submit Assessment</span>
                                    </button>
                                </div>
                            </form>
                        </article>
                    </section>
                </c:if>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
</body>
</html>
