<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/InstructorAssessment.module.css?v=6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-workspace-modern.css?v=1">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- Styles moved to InstructorAssessment.module.css -->
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Submissions & Grading"/>
</jsp:include>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>


<main class="app-main">
    <div class="content-wrapper ia-grading-workspace">
        <jsp:include page="/WEB-INF/views/instructor/fragments/assessment-breadcrumb.jsp">
            <jsp:param name="currentLabel" value="Submissions"/>
        </jsp:include>

        <c:set var="currentCourseFlow" value="assessments"/>
        <jsp:include page="/WEB-INF/views/instructor/fragments/course-flow-nav.jsp"/>

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
        <c:if test="${param.success == 'rreviewed'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Retake request decision saved successfully.</div></c:if>
        <c:if test="${param.error == 'rreview'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Failed to submit retake request decision.</div></c:if>
        <c:if test="${param.error == 'graderange'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Invalid score. Must be between 0 and ${selectedAssessment.totalMarks}.</div></c:if>
        <c:if test="${not empty errorMessage}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div></c:if>

        <div class="ia-submissions-split-layout">
            <!-- Left Pane: Student Roster Queue -->
            <aside class="grading-roster-sidebar">
                <!-- Retake Requests Section -->
                <c:set var="pendingRetakesCount" value="0"/>
                <c:forEach var="req" items="${retakeRequests}">
                    <c:if test="${req.status == 'Pending'}">
                        <c:set var="pendingRetakesCount" value="${pendingRetakesCount + 1}"/>
                    </c:if>
                </c:forEach>

                <c:if test="${pendingRetakesCount > 0}">
                    <div class="roster-header" style="background-color: #fffbeb; border-bottom: 1px solid #fef3c7; border-top: 1px solid #fef3c7; padding: 12px 16px; margin-bottom: 0;">
                        <h3 style="color: #d97706; display: flex; align-items: center; gap: 6px; font-size: 0.875rem;">
                            <i class="fas fa-circle-exclamation"></i> Retake Requests
                        </h3>
                        <span class="roster-count" style="background-color: #d97706; color: #ffffff;">${pendingRetakesCount} Pending</span>
                    </div>
                    <div class="roster-list" style="border-bottom: 2px solid #e2e8f0; background-color: #fffdf5; max-height: 250px; overflow-y: auto;">
                        <c:forEach var="req" items="${retakeRequests}">
                            <c:if test="${req.status == 'Pending'}">
                                <div class="roster-item" style="cursor: default; padding: 12px 16px; border-bottom: 1px solid #fef3c7; display: flex; flex-direction: column; align-items: flex-start; gap: 6px; background-color: #fffdf5; opacity: 1;">
                                    <div style="display: flex; justify-content: space-between; width: 100%; align-items: center;">
                                        <strong class="roster-name" style="font-size: 0.875rem; color: #1e293b;">${req.studentName}</strong>
                                        <span class="status-badge status-pending" style="font-size: 0.6875rem; padding: 2px 6px;">Pending</span>
                                    </div>
                                    <div style="font-size: 0.75rem; color: #64748b; margin-top: -2px;">
                                        ${req.studentEmail}
                                    </div>
                                    <c:if test="${not empty req.reason}">
                                        <div style="font-size: 0.75rem; color: #475569; background-color: #ffffff; border: 1px solid #f1f5f9; border-radius: 4px; padding: 6px 8px; width: 100%; box-sizing: border-box; word-break: break-word;">
                                            "${req.reason}"
                                        </div>
                                    </c:if>
                                    <div style="display: flex; gap: 8px; width: 100%; margin-top: 4px;">
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="margin: 0; flex: 1;">
                                            <input type="hidden" name="action" value="reviewRetake">
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                            <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                            <input type="hidden" name="requestId" value="${req.requestId}">
                                            <input type="hidden" name="decision" value="approve">
                                            <button type="submit" class="ws-btn ws-btn-primary ws-btn-xs" style="width: 100%; background-color: #16a34a; border-color: #16a34a; font-size: 0.75rem; padding: 4px 8px; color: #ffffff; cursor: pointer; border-radius: 4px;">
                                                <i class="fas fa-check"></i> Approve
                                            </button>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="margin: 0; flex: 1;">
                                            <input type="hidden" name="action" value="reviewRetake">
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                            <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                            <input type="hidden" name="requestId" value="${req.requestId}">
                                            <input type="hidden" name="decision" value="reject">
                                            <button type="submit" class="ws-btn ws-btn-danger ws-btn-xs" style="width: 100%; font-size: 0.75rem; padding: 4px 8px; color: #ffffff; cursor: pointer; border-radius: 4px;">
                                                <i class="fas fa-xmark"></i> Reject
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:if>

                <!-- Reviewed Retake Requests History collapsible -->
                <c:set var="hasReviewedRetakes" value="false"/>
                <c:forEach var="req" items="${retakeRequests}">
                    <c:if test="${req.status != 'Pending'}">
                        <c:set var="hasReviewedRetakes" value="true"/>
                    </c:if>
                </c:forEach>

                <c:if test="${hasReviewedRetakes}">
                    <details style="margin: 8px 16px 12px 16px; font-size: 0.75rem; color: #64748b; border: 1px solid #e2e8f0; border-radius: 6px; padding: 8px;">
                        <summary style="cursor: pointer; font-weight: 600; user-select: none; color: #475569;">Retake History</summary>
                        <div style="margin-top: 6px; display: flex; flex-direction: column; gap: 6px; max-height: 150px; overflow-y: auto;">
                            <c:forEach var="req" items="${retakeRequests}">
                                <c:if test="${req.status != 'Pending'}">
                                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 6px; border: 1px solid #e2e8f0; border-radius: 4px; background-color: #f8fafc; gap: 6px;">
                                        <div style="word-break: break-all;">
                                            <strong style="color: #1e293b;">${req.studentName}</strong>
                                            <span style="display: block; font-size: 0.625rem; color: #94a3b8;">${req.studentEmail}</span>
                                        </div>
                                        <span class="status-badge <c:choose><c:when test="${req.status == 'Approved'}">status-graded</c:when><c:otherwise>status-timedout</c:otherwise></c:choose>" style="font-size: 0.625rem; padding: 2px 4px; margin: 0; white-space: nowrap; align-self: center;">
                                            ${req.status}
                                        </span>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </div>
                    </details>
                </c:if>

                <div class="roster-header">
                    <h3>Submissions Queue</h3>
                    <span class="roster-count">${fn:length(assessmentRosterRows)} Students</span>
                </div>
                <div class="roster-search-box">
                    <div class="roster-search-wrap">
                        <i class="fas fa-search"></i>
                        <input type="text" id="rosterSearch" class="roster-search-input" placeholder="Search student name..." oninput="filterGradingRoster()">
                    </div>
                </div>
                <div class="roster-list" id="gradingRosterList">
                    <c:forEach var="row" items="${assessmentRosterRows}">
                        <c:set var="submission" value="${row.latestSubmission}"/>
                        <div class="roster-item <c:if test='${empty submission}'>disabled-roster-item</c:if>" 
                             id="roster-item-${not empty submission ? submission.submissionId : 'none'}" 
                             data-submission-id="${not empty submission ? submission.submissionId : ''}"
                             data-student-name="${row.studentName}"
                             <c:if test="${not empty submission}">onclick="activateSubmission('${submission.submissionId}')"</c:if>>
                            <div class="roster-avatar">
                                ${fn:substring(row.studentName, 0, 1)}
                            </div>
                            <div class="roster-meta">
                                <strong class="roster-name">${row.studentName}</strong>
                                <span class="roster-title-meta">${selectedAssessment.title}</span>
                                <span class="roster-date-meta">
                                    <c:choose>
                                        <c:when test="${not empty submission}">
                                            Submitted: ${fn:replace(submission.submitDate, 'T', ' ')}
                                        </c:when>
                                        <c:otherwise>
                                            Not Submitted
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                                <span class="status-badge <c:choose><c:when test='${not empty submission and submission.score != null}'>status-graded</c:when><c:when test='${not empty submission}'>status-pending</c:when><c:otherwise>status-timedout</c:otherwise></c:choose> roster-status-badge">
                                    <c:choose>
                                        <c:when test="${not empty submission and submission.score != null}">Graded</c:when>
                                        <c:when test="${not empty submission}">Pending</c:when>
                                        <c:otherwise>Not Started</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="roster-score">
                                <c:choose>
                                    <c:when test="${not empty submission and submission.score != null}">
                                        <span class="roster-score-badge">${submission.score}/${selectedAssessment.totalMarks}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="roster-score-badge">--</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </aside>

            <!-- Center Pane: Document Viewer -->
            <section class="grading-document-viewer" id="documentViewerPane">
                <!-- Card for Assignments / Files -->
                <div class="grading-doc-card" id="docCardViewer" style="display: none;">
                    <div class="grading-doc-header">
                        <span class="grading-doc-title" id="viewerDocTitle">
                            <i class="fas fa-file-pdf"></i> Student Submission Payload
                        </span>
                        <a id="viewerExternalLink" href="" target="_blank" class="ws-btn ws-btn-secondary ws-btn-xs">
                            Open in New Tab <i class="fas fa-external-link-alt"></i>
                        </a>
                    </div>
                    
                    <!-- Sleek compact horizontal toolbar banner for PDF download -->
                    <div id="assignmentDownloadWrapper" style="display: none; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 16px; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 12px; margin-top: 12px; width: 100%; box-sizing: border-box;">
                        <div style="display: flex; align-items: center; gap: 8px; color: #1e293b; font-size: 0.875rem; font-weight: 500;">
                            <i class="fas fa-file-pdf" style="color: #ef4444; font-size: 1.125rem;"></i>
                            <span>Student Submitted Assignment PDF</span>
                        </div>
                        <a id="assignmentDownloadBtn" href="" download target="_blank" class="ws-btn ws-btn-primary ws-btn-xs" style="display: inline-flex; align-items: center; gap: 6px; margin: 0; padding: 6px 12px; font-size: 0.8125rem; font-weight: 500; text-decoration: none; border-radius: 4px; color: #ffffff; background-color: #3b82f6;">
                            <i class="fas fa-download"></i> Download File
                        </a>
                    </div>

                    <!-- Frame for PDFs -->
                    <iframe id="pdfViewerFrame" class="grading-iframe-viewer" src="" style="display: none;"></iframe>
                    <!-- Fallback panel for Text answers -->
                    <div id="textAnswersViewer" class="grading-text-viewer" style="display: none;"></div>
                </div>

                <!-- Questions list review for Quizzes -->
                <div id="quizQuestionsReview" class="grading-quiz-review" style="display: none;">
                    <div class="quiz-review-header">
                        <h3>Quiz Questions Review</h3>
                        <span class="quiz-review-score" id="quizReviewScoreText">Auto-graded Score: --</span>
                    </div>
                    <div class="quiz-review-qlist" id="quizReviewQuestionsList">
                        <!-- Dynamically populated via JS -->
                    </div>
                </div>

                <div class="grading-empty-selection" id="viewerEmptyState">
                    <i class="fas fa-file-signature"></i>
                    <h3>No Submission Selected</h3>
                    <p>Select a student from the sidebar queue on the left to begin grading their work.</p>
                </div>
            </section>

            <!-- Right Pane: Scoring & Feedback Panel -->
            <aside class="grading-panel-sidebar">
                <div id="gradingSidebarActive" class="grading-sidebar-active" style="display: none;">
                    <div class="grading-panel-student">
                        <div class="grading-panel-avatar" id="sidebarAvatar">A</div>
                        <div class="grading-panel-meta">
                            <span class="grading-panel-name" id="sidebarStudentName">Student Name</span>
                            <span class="grading-panel-email" id="sidebarStudentEmail">email@domain.com</span>
                        </div>
                    </div>

                    <!-- AJAX Grading Form -->
                    <form id="gradingDashboardForm" method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="grading-dashboard-form">
                        <input type="hidden" name="action" value="gradeSubmission" />
                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                        <input type="hidden" name="submissionId" id="formSubmissionId" value="" />
                        <input type="hidden" name="workflowAction" value="submissions" />

                        <!-- Dynamic quiz score display -->
                        <div id="quizSidebarScoreInfo" class="quiz-sidebar-score-info" style="display: none;">
                            <span>Auto-graded Score:</span>
                            <strong id="quizSidebarScoreText">--</strong>
                        </div>

                        <div class="grading-score-wrapper">
                            <label class="grading-score-label">Final Score *</label>
                            <div class="grading-score-input-group">
                                <input 
                                    id="formScoreInput" 
                                    name="score" 
                                    type="number" 
                                    min="0" 
                                    max="${selectedAssessment.totalMarks}" 
                                    step="0.5" 
                                    class="grading-score-input"
                                    required />
                                <span class="grading-score-total">/ ${selectedAssessment.totalMarks} Marks</span>
                            </div>
                        </div>

                        <div class="grading-feedback-wrapper">
                            <label class="grading-feedback-label">Constructive Feedback</label>
                            <textarea 
                                id="formFeedbackInput" 
                                name="feedback" 
                                class="grading-feedback-textarea"
                                placeholder="Enter feedback details..."></textarea>
                        </div>

                        <button type="submit" class="ws-btn ws-btn-primary grading-submit-btn" id="gradingFormSubmitBtn">
                            <i class="fas fa-check-double"></i> Submit Grade & Next Student
                        </button>
                    </form>
                </div>

                <div class="grading-empty-selection" id="sidebarEmptyState">
                    <i class="fas fa-user-check"></i>
                    <h3>Select Student</h3>
                    <p>Student metadata and score settings will load here.</p>
                </div>
            </aside>
        </div>

        <!-- Rendered Hidden Data Blocks for zero-latency client switching -->
        <div style="display: none;" id="hiddenSubmissionDataBlocks">
            <c:forEach var="row" items="${assessmentRosterRows}">
                <c:set var="submission" value="${row.latestSubmission}"/>
                <c:if test="${not empty submission}">
                    <c:set var="submissionPayload" value="${submission.answersFilePath}"/>
                    <c:set var="submissionIsUrl" value="${not empty submissionPayload and (fn:startsWith(submissionPayload, 'http://') or fn:startsWith(submissionPayload, 'https://'))}"/>
                    
                    <div id="data-block-${submission.submissionId}"
                         data-submission-id="${submission.submissionId}"
                         data-student-name="<c:out value='${row.studentName}'/>"
                         data-student-email="<c:out value='${row.studentEmail}'/>"
                         data-score="${submission.score != null ? submission.score : ''}"
                         data-feedback="<c:out value='${submission.feedback}'/>"
                         data-payload="<c:out value='${submissionPayload}'/>"
                         data-file-url="${submissionIsUrl ? submissionPayload : pageContext.request.contextPath.concat('/uploads/').concat(submissionPayload)}"
                         data-is-pdf="${fn:contains(fn:toLowerCase(submissionPayload), '.pdf')}"
                         data-type="${selectedAssessment.type}">
                    </div>
                </c:if>
            </c:forEach>
        </div>
        <!-- Rendered Hidden Questions Block for dynamic client quiz review -->
        <div style="display: none;" id="hiddenQuestionsBlock">
            <c:forEach var="q" items="${questions}">
                <div class="question-data" 
                     data-question-id="${q.questionId}" 
                     data-question-text="<c:out value='${q.questionText}'/>"
                     data-option-a="<c:out value='${q.optionA}'/>"
                     data-option-b="<c:out value='${q.optionB}'/>"
                     data-option-c="<c:out value='${q.optionC}'/>"
                     data-option-d="<c:out value='${q.optionD}'/>"
                     data-correct-option="${q.correctOption}"
                     data-marks="${q.marks}">
                </div>
            </c:forEach>
        </div>
    </div>
</main>



<script>
    function filterGradingRoster() {
        const query = document.getElementById("rosterSearch").value.toLowerCase();
        const items = document.querySelectorAll("#gradingRosterList .roster-item");
        items.forEach(item => {
            const name = item.dataset.studentName.toLowerCase();
            item.style.display = name.includes(query) ? "flex" : "none";
        });
    }

    function activateSubmission(submissionId) {
        // Toggle roster active class
        document.querySelectorAll("#gradingRosterList .roster-item").forEach(item => {
            item.classList.toggle("active", item.dataset.submissionId === submissionId);
        });

        const block = document.getElementById("data-block-" + submissionId);
        if (!block) return;

        // Hide empty states
        document.getElementById("viewerEmptyState").style.display = "none";
        document.getElementById("sidebarEmptyState").style.display = "none";

        // Extract attributes
        const studentName = block.getAttribute("data-student-name");
        const studentEmail = block.getAttribute("data-student-email");
        const score = block.getAttribute("data-score");
        const feedback = block.getAttribute("data-feedback");
        const fileUrl = block.getAttribute("data-file-url");
        const isPdf = block.getAttribute("data-is-pdf") === "true";
        const payload = block.getAttribute("data-payload");
        const type = block.getAttribute("data-type");

        // Show active grading sidebar
        document.getElementById("gradingSidebarActive").style.display = "flex";

        // Fill sidebar metadata
        document.getElementById("sidebarStudentName").textContent = studentName;
        document.getElementById("sidebarStudentEmail").textContent = studentEmail;
        document.getElementById("sidebarAvatar").textContent = studentName.substring(0, 1).toUpperCase();

        // Fill form fields
        document.getElementById("formSubmissionId").value = submissionId;
        document.getElementById("formScoreInput").value = score;
        document.getElementById("formFeedbackInput").value = feedback;

        // Reset submit button state
        const submitBtn = document.getElementById("gradingFormSubmitBtn");
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-check-double"></i> Submit Grade & Next Student';

        // Load correct panes based on assessment type
        const docCardViewer = document.getElementById("docCardViewer");
        const quizQuestionsReview = document.getElementById("quizQuestionsReview");
        const quizSidebarScoreInfo = document.getElementById("quizSidebarScoreInfo");

        if (type === "Quiz" || type === "Exam") {
            docCardViewer.style.display = "none";
            quizQuestionsReview.style.display = "flex";
            
            // Render quiz review
            populateQuizReview(payload, score);
            
            // Show quiz score info in sidebar
            if (quizSidebarScoreInfo) {
                quizSidebarScoreInfo.style.display = "flex";
                document.getElementById("quizSidebarScoreText").textContent = (score !== null && score !== "") ? (score + " / " + "${selectedAssessment.totalMarks}") : ("Not Graded");
            }
        } else {
            // Assignment or File Submission
            docCardViewer.style.display = "flex";
            quizQuestionsReview.style.display = "none";
            if (quizSidebarScoreInfo) {
                quizSidebarScoreInfo.style.display = "none";
            }

            const pdfFrame = document.getElementById("pdfViewerFrame");
            const textViewer = document.getElementById("textAnswersViewer");
            const extLink = document.getElementById("viewerExternalLink");
            const downloadWrap = document.getElementById("assignmentDownloadWrapper");
            const downloadBtn = document.getElementById("assignmentDownloadBtn");

            if (payload && payload.trim() !== "") {
                extLink.style.display = "inline-flex";
                extLink.href = fileUrl;
                
                if (isPdf) {
                    pdfFrame.style.display = "block";
                    pdfFrame.src = fileUrl;
                    downloadWrap.style.display = "flex";
                    downloadBtn.href = fileUrl;
                    textViewer.style.display = "none";
                } else {
                    pdfFrame.style.display = "none";
                    pdfFrame.src = "";
                    downloadWrap.style.display = "none";
                    textViewer.style.display = "block";
                    textViewer.textContent = payload;
                }
            } else {
                extLink.style.display = "none";
                pdfFrame.style.display = "none";
                pdfFrame.src = "";
                downloadWrap.style.display = "none";
                textViewer.style.display = "block";
                textViewer.innerHTML = `<div class="grading-no-submission">
                    <i class="fas fa-exclamation-circle grading-no-submission-icon"></i>
                    No submission file or text payload available for this student.
                </div>`;
            }
        }
    }

    function populateQuizReview(payload, score) {
        const quizReviewList = document.getElementById("quizReviewQuestionsList");
        quizReviewList.innerHTML = ""; // Clear old content
        
        // Populate quiz header score text
        const scoreText = document.getElementById("quizReviewScoreText");
        scoreText.textContent = "Auto-graded Score: " + ((score !== null && score !== "") ? score : "--") + " / " + "${selectedAssessment.totalMarks}";

        // Parse student answers from payload: "Q1:A;Q2:B;"
        const studentAnswers = {};
        if (payload) {
            const pairs = payload.split(';');
            pairs.forEach(pair => {
                if (pair.trim()) {
                    const parts = pair.split(':');
                    if (parts.length === 2) {
                        const qKey = parts[0].trim();
                        const qId = qKey.startsWith('Q') ? qKey.substring(1) : qKey;
                        studentAnswers[qId] = parts[1].trim().toUpperCase();
                    }
                }
            });
        }

        // Get all questions from the hidden questions block
        const questionDataNodes = document.querySelectorAll("#hiddenQuestionsBlock .question-data");
        
        if (questionDataNodes.length === 0) {
            quizReviewList.innerHTML = `<div class="grading-no-submission">No questions found for this quiz.</div>`;
            return;
        }

        questionDataNodes.forEach((node, index) => {
            const qId = node.getAttribute("data-question-id");
            const qText = node.getAttribute("data-question-text");
            const optA = node.getAttribute("data-option-a");
            const optB = node.getAttribute("data-option-b");
            const optC = node.getAttribute("data-option-c");
            const optD = node.getAttribute("data-option-d");
            const correctOpt = (node.getAttribute("data-correct-option") || "").trim().toUpperCase();
            const marks = node.getAttribute("data-marks");

            const studentSelected = studentAnswers[qId] || "";
            const isCorrect = (studentSelected === correctOpt && studentSelected !== "");

            // Create question card
            const qCard = document.createElement("div");
            qCard.className = "quiz-review-qcard";

            // Question Text with correct/incorrect icon
            const qTextDiv = document.createElement("div");
            qTextDiv.className = "quiz-review-qtext";
            
            const icon = document.createElement("i");
            if (isCorrect) {
                icon.className = "fas fa-check-circle";
            } else {
                icon.className = "fas fa-times-circle";
            }
            qTextDiv.appendChild(icon);

            const textSpan = document.createElement("span");
            textSpan.innerHTML = `<strong>Q${index + 1}.</strong> ${qText} <span class="roster-date-meta" style="display: inline; margin-left: 8px;">(${marks} Marks)</span>`;
            qTextDiv.appendChild(textSpan);
            
            qCard.appendChild(qTextDiv);

            // Options container
            const optionsDiv = document.createElement("div");
            optionsDiv.className = "quiz-review-options";

            const options = [
                { key: "A", text: optA },
                { key: "B", text: optB },
                { key: "C", text: optC },
                { key: "D", text: optD }
            ];

            options.forEach(opt => {
                if (!opt.text) return; // Skip empty options if any

                const optCard = document.createElement("div");
                let optClass = "quiz-review-option";
                
                // Add status styles
                if (opt.key === correctOpt) {
                    optClass += " is-correct";
                } else if (opt.key === studentSelected) {
                    optClass += " is-incorrect";
                }
                
                optCard.className = optClass;

                // Build option contents
                let innerHTML = `<strong>${opt.key}.</strong> <span>${opt.text}</span>`;
                if (opt.key === correctOpt) {
                    innerHTML += ` <i class="fas fa-check quiz-review-correct-icon"></i>`;
                } else if (opt.key === studentSelected) {
                    innerHTML += ` <i class="fas fa-times quiz-review-incorrect-icon"></i>`;
                }
                optCard.innerHTML = innerHTML;

                optionsDiv.appendChild(optCard);
            });

            qCard.appendChild(optionsDiv);
            quizReviewList.appendChild(qCard);
        });
    }

    // Dynamic queueing logic
    document.addEventListener("DOMContentLoaded", function() {
        const form = document.getElementById("gradingDashboardForm");
        if (form) {
            form.addEventListener("submit", async function(e) {
                e.preventDefault();
                
                const submitBtn = document.getElementById("gradingFormSubmitBtn");
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving Grade...';

                const fd = new FormData(form);
                const params = new URLSearchParams();
                for (const pair of fd.entries()) {
                    params.append(pair[0], pair[1]);
                }
                const submissionId = document.getElementById("formSubmissionId").value;
                const scoreValue = document.getElementById("formScoreInput").value;
                const feedbackValue = document.getElementById("formFeedbackInput").value;

                try {
                    const response = await fetch(form.action, {
                        method: "POST",
                        body: params,
                        credentials: "same-origin"
                    });

                    // If redirected to login or error, fallback to native form submission
                    if (response.ok && response.url && response.url.includes("success=graded")) {
                        // Success toast
                        showSuccessToast("Submission graded successfully!");

                        // Update Left Sidebar roster UI details
                        const rosterItem = document.getElementById("roster-item-" + submissionId);
                        if (rosterItem) {
                            const scoreBadge = rosterItem.querySelector(".roster-score-badge");
                            if (scoreBadge) {
                                scoreBadge.textContent = scoreValue + "/" + "${selectedAssessment.totalMarks}";
                            }
                            const statusBadge = rosterItem.querySelector(".roster-status-badge");
                            if (statusBadge) {
                                statusBadge.className = "status-badge status-graded roster-status-badge";
                                statusBadge.textContent = "Graded";
                            }
                        }

                        // Update local hidden block attributes
                        const block = document.getElementById("data-block-" + submissionId);
                        if (block) {
                            block.setAttribute("data-score", scoreValue);
                            block.setAttribute("data-feedback", feedbackValue);
                        }

                        // Switch to NEXT ungraded student in the queue automatically!
                        setTimeout(() => {
                            loadNextStudentSubmission(submissionId);
                        }, 500);
                    } else {
                        console.warn("AJAX save redirected or returned unexpected result. Falling back to native submit.", response.url);
                        form.submit();
                    }
                } catch (err) {
                    console.error("Error submitting grade via AJAX, falling back to native form submission:", err);
                    form.submit();
                }
            });
        }

        // Auto-activate the first student submission on page load!
        const firstRosterItem = document.querySelector("#gradingRosterList .roster-item:not(.disabled-roster-item)");
        if (firstRosterItem) {
            const firstSubId = firstRosterItem.dataset.submissionId;
            if (firstSubId) activateSubmission(firstSubId);
        }
    });

    function loadNextStudentSubmission(currentSubId) {
        const listItems = Array.from(document.querySelectorAll("#gradingRosterList .roster-item:not(.disabled-roster-item)"));
        const currentIndex = listItems.findIndex(item => item.dataset.submissionId === currentSubId);

        // Find the next student submission that is NOT graded (i.e. status is "submitted" or similar, or just next in order)
        let nextIndex = -1;
        for (let i = currentIndex + 1; i < listItems.length; i++) {
            const statusBadge = listItems[i].querySelector(".roster-status-badge");
            if (statusBadge && !statusBadge.textContent.toLowerCase().includes("graded")) {
                nextIndex = i;
                break;
            }
        }

        // If none found after, wrap-around search from beginning
        if (nextIndex === -1) {
            for (let i = 0; i < currentIndex; i++) {
                const statusBadge = listItems[i].querySelector(".roster-status-badge");
                if (statusBadge && !statusBadge.textContent.toLowerCase().includes("graded")) {
                    nextIndex = i;
                    break;
                }
            }
        }

        // If there's still an ungraded student, activate them!
        if (nextIndex !== -1) {
            activateSubmission(listItems[nextIndex].dataset.submissionId);
        } else {
            // Victory state: All submissions fully graded!
            showSuccessToast("All student submissions graded!");
            document.getElementById("pdfViewerFrame").src = "";
            document.getElementById("pdfViewerFrame").style.display = "none";
            document.getElementById("assignmentDownloadWrapper").style.display = "none";
            document.getElementById("docCardViewer").style.display = "none";
            document.getElementById("quizQuestionsReview").style.display = "none";
            
            const viewerPane = document.getElementById("documentViewerPane");
            const finishedViewer = document.createElement("div");
            finishedViewer.id = "rosterGradingFinishedViewer";
            finishedViewer.innerHTML = `<div class="grading-complete-wrap">
                <i class="fas fa-trophy grading-complete-icon"></i>
                <h3 class="grading-complete-title">Roster Grading Completed!</h3>
                <p class="grading-complete-text">Every student submission in this queue has been evaluated and scored.</p>
            </div>`;
            
            // Remove old finished viewer if it exists, then append new one
            const oldFinished = document.getElementById("rosterGradingFinishedViewer");
            if (oldFinished) oldFinished.remove();
            viewerPane.appendChild(finishedViewer);

            // Reset active card states
            document.querySelectorAll("#gradingRosterList .roster-item").forEach(item => {
                item.classList.remove("active");
            });
            document.getElementById("gradingSidebarActive").style.display = "none";
            document.getElementById("sidebarEmptyState").style.display = "flex";
            document.getElementById("sidebarEmptyState").innerHTML = `<i class="fas fa-check-circle grading-success-icon"></i>
                <h3>Grading Complete</h3>
                <p>All queue actions finished.</p>`;
        }
    }

    function showSuccessToast(message) {
        const toast = document.getElementById('premiumSuccessToast');
        const msgEl = document.getElementById('premiumToastMsg');
        if (toast && msgEl) {
            msgEl.textContent = message;
            toast.classList.add('show');
            setTimeout(() => {
                toast.classList.remove('show');
            }, 4000);
        }
    }
</script>

<div id="premiumSuccessToast" class="premium-toast">
    <i class="fas fa-check-circle"></i>
    <span id="premiumToastMsg">Saved successfully!</span>
</div>

</body>
</html>
