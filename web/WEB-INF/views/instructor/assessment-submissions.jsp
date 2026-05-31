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
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <style>
    /* ==========================================================================
       Grading Command Center Split-Screen Layout
       ========================================================================== */
    :root {
        --ws-primary: #6366f1;
        --ws-primary-glow: rgba(99, 102, 241, 0.12);
        --ws-success: #10b981;
        --ws-warning: #f59e0b;
        --ws-danger: #ef4444;
    }

    .ia-submissions-split-layout {
        display: grid;
        grid-template-columns: 320px 1fr 380px;
        height: calc(100vh - 340px);
        min-height: 580px;
        overflow: hidden;
        gap: 0;
        background-color: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.04), 0 1px 3px rgba(0, 0, 0, 0.02);
        margin-top: 1.5rem;
    }

    /* Left Sidebar: Student Queue */
    .grading-roster-sidebar {
        background-color: #ffffff;
        border-right: 1px solid #e2e8f0;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        height: 100%;
    }

    .roster-header {
        padding: 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .roster-header h3 {
        font-size: 1rem;
        font-weight: 700;
        color: #0f172a;
        margin: 0;
        letter-spacing: -0.01em;
    }

    .roster-count {
        font-size: 0.75rem;
        font-weight: 700;
        background: var(--ws-primary-glow);
        color: var(--ws-primary);
        padding: 4px 10px;
        border-radius: 20px;
    }

    .roster-search-box {
        padding: 16px 24px;
        border-bottom: 1px solid #f1f5f9;
        background-color: #fafbfc;
    }

    .roster-search-input {
        width: 100%;
        padding: 10px 14px 10px 36px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 0.85rem;
        outline: none;
        box-sizing: border-box;
        background-color: #ffffff;
        color: #0f172a;
        transition: all 0.2s ease;
    }
    
    .roster-search-input:focus {
        border-color: var(--ws-primary);
        box-shadow: 0 0 0 3px var(--ws-primary-glow);
    }

    .roster-search-wrap {
        position: relative;
    }

    .roster-search-wrap i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94a3b8;
        font-size: 0.85rem;
    }

    .roster-list {
        flex-grow: 1;
        overflow-y: auto;
        padding: 12px 0;
    }

    .roster-item {
        margin: 4px 12px;
        padding: 12px 16px;
        border-radius: 12px;
        border: 1px solid transparent;
        display: flex;
        align-items: center;
        gap: 14px;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        user-select: none;
    }

    .roster-item:hover {
        background-color: #f1f5f9;
        border-color: #e2e8f0;
    }

    .roster-item.active {
        background-color: var(--ws-primary-glow);
        border-color: var(--ws-primary, #6366f1);
        box-shadow: 0 0 0 3px var(--ws-primary-glow);
    }

    .roster-item.disabled-roster-item {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .roster-avatar {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        color: #475569;
        font-size: 0.9rem;
        flex-shrink: 0;
        box-shadow: inset 0 1px 2px rgba(255,255,255,0.2);
        transition: all 0.2s ease;
    }

    .roster-item.active .roster-avatar {
        background: linear-gradient(135deg, var(--ws-primary) 0%, #4f46e5 100%);
        color: #ffffff;
        box-shadow: 0 4px 10px rgba(99, 102, 241, 0.25);
    }

    .roster-meta {
        flex-grow: 1;
        min-width: 0;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .roster-name {
        font-size: 0.875rem;
        font-weight: 600;
        color: #0f172a;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .roster-item.active .roster-name {
        color: #4f46e5;
    }

    .roster-status-badge {
        font-size: 0.65rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        width: fit-content;
        padding: 3px 8px;
        border-radius: 8px;
        display: inline-block;
    }
    
    /* Elegant tag styling override */
    .status-badge.status-submitted, .status-badge.status-autosubmitted {
        background-color: #eff6ff;
        color: #2563eb;
        border: 1px solid #dbeafe;
    }
    
    .status-badge.status-graded, .status-badge.status-approved {
        background-color: #ecfdf5;
        color: #059669;
        border: 1px solid #d1fae5;
    }
    
    .status-badge.status-pending {
        background-color: #fffbeb;
        color: #d97706;
        border: 1px solid #fef3c7;
    }
    
    .status-badge.status-timedout, .status-badge.status-rejected {
        background-color: #fef2f2;
        color: #dc2626;
        border: 1px solid #fee2e2;
    }

    .roster-score-badge {
        font-size: 0.825rem;
        font-weight: 700;
        color: #64748b;
        flex-shrink: 0;
        font-variant-numeric: tabular-nums;
    }

    /* Center Pane: Document Viewer */
    .grading-document-viewer {
        background-color: #f8fafc;
        padding: 32px;
        overflow-y: hidden;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
        height: 100%;
        box-sizing: border-box;
    }

    .grading-doc-card {
        background: #ffffff;
        border-radius: 14px;
        box-shadow: 0 10px 30px -5px rgba(0, 0, 0, 0.04), 0 8px 16px -6px rgba(0, 0, 0, 0.03);
        border: 1px solid #e2e8f0;
        width: 100%;
        max-width: 850px;
        height: 100%;
        display: flex;
        flex-direction: column;
        box-sizing: border-box;
        overflow: hidden;
    }

    .grading-doc-header {
        padding: 16px 24px;
        border-bottom: 1px solid #e2e8f0;
        background-color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .grading-doc-title {
        font-size: 0.9rem;
        font-weight: 700;
        color: #334155;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .grading-iframe-viewer {
        width: 100%;
        flex-grow: 1;
        border: none;
        background: #ffffff;
    }

    .grading-text-viewer {
        padding: 40px;
        font-family: 'Inter', sans-serif;
        font-size: 0.95rem;
        line-height: 1.65;
        color: #334155;
        overflow-y: auto;
        flex-grow: 1;
        white-space: pre-wrap;
    }

    /* Right Sidebar: Scoring & Feedback */
    .grading-panel-sidebar {
        background: #ffffff;
        border-left: 1px solid #e2e8f0;
        padding: 32px 24px;
        display: flex;
        flex-direction: column;
        gap: 24px;
        height: 100%;
        overflow-y: auto;
        box-sizing: border-box;
    }

    .grading-panel-student {
        display: flex;
        align-items: center;
        gap: 14px;
        border-bottom: 1px solid #f1f5f9;
        padding-bottom: 20px;
    }

    .grading-panel-avatar {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        background: linear-gradient(135deg, var(--ws-primary-glow) 0%, rgba(99, 102, 241, 0.05) 100%);
        color: var(--ws-primary);
        font-size: 1.25rem;
        font-weight: 800;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 1px solid rgba(99, 102, 241, 0.1);
    }

    .grading-panel-meta {
        display: flex;
        flex-direction: column;
        gap: 2px;
        min-width: 0;
    }

    .grading-panel-name {
        font-size: 1.05rem;
        font-weight: 700;
        color: #0f172a;
        letter-spacing: -0.01em;
    }

    .grading-panel-email {
        font-size: 0.8rem;
        color: #64748b;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* Scoring Number Inputs */
    .grading-score-wrapper {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .grading-score-label {
        font-size: 0.75rem;
        font-weight: 700;
        color: #475569;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .grading-score-input-group {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .grading-score-input {
        width: 120px;
        border: 1.5px solid #cbd5e1 !important;
        border-radius: 10px !important;
        padding: 12px 16px !important;
        font-size: 1.25rem !important;
        font-weight: 700 !important;
        color: #0f172a !important;
        outline: none !important;
        transition: all 0.2s ease !important;
        box-shadow: inset 0 1px 2px rgba(0,0,0,0.02) !important;
        text-align: center;
        background-color: #fafbfc !important;
    }

    .grading-score-input:focus {
        border-color: var(--ws-primary, #6366f1) !important;
        background-color: #ffffff !important;
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12) !important;
    }

    .grading-score-total {
        font-size: 1.1rem;
        font-weight: 700;
        color: #64748b;
    }

    /* Feedback Textarea */
    .grading-feedback-wrapper {
        display: flex;
        flex-direction: column;
        gap: 8px;
        flex-grow: 1;
    }

    .grading-feedback-label {
        font-size: 0.75rem;
        font-weight: 700;
        color: #475569;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .grading-feedback-textarea {
        width: 100%;
        border: 1.5px solid #cbd5e1 !important;
        border-radius: 10px !important;
        padding: 14px !important;
        font-size: 0.9rem !important;
        color: #0f172a !important;
        outline: none !important;
        transition: all 0.2s ease !important;
        resize: none !important;
        flex-grow: 1;
        box-sizing: border-box;
        background-color: #fafbfc !important;
    }

    .grading-feedback-textarea:focus {
        border-color: var(--ws-primary, #6366f1) !important;
        background-color: #ffffff !important;
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12) !important;
    }

    .grading-submit-btn {
        width: 100%;
        padding: 14px !important;
        font-size: 0.95rem !important;
        border-radius: 10px !important;
        margin-top: auto;
        background: linear-gradient(135deg, var(--ws-primary, #6366f1) 0%, #4f46e5 100%);
        color: #ffffff;
        border: none;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.15);
    }
    
    .grading-submit-btn:hover:not(:disabled) {
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(99, 102, 241, 0.25);
    }
    
    .grading-submit-btn:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    /* Empty state */
    .grading-empty-selection {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
        padding: 48px 24px;
        color: #64748b;
        gap: 16px;
        width: 100%;
    }

    .grading-empty-selection i {
        font-size: 3rem;
        color: var(--ws-primary);
        opacity: 0.8;
    }

    /* Scoped premium buttons */
    .ws-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        font-family: inherit;
        font-size: 0.875rem;
        font-weight: 600;
        padding: 10px 20px;
        border-radius: 8px;
        border: 1px solid transparent;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        text-decoration: none;
    }

    .ws-btn-primary {
        background-color: var(--ws-primary, #6366f1);
        color: #ffffff;
    }

    .ws-btn-primary:hover {
        background-color: #4f46e5;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
    }

    .ws-btn-secondary {
        background-color: #ffffff;
        border-color: #cbd5e1;
        color: #334155;
    }

    .ws-btn-secondary:hover {
        background-color: #f8fafc;
        border-color: #94a3b8;
        color: #0f172a;
    }

    .ws-btn-xs {
        padding: 4px 8px;
        font-size: 0.75rem;
        border-radius: 4px;
    }

    /* Dark Mode split view */
    :root[data-theme="dark"] .ia-submissions-split-layout {
        border-color: rgba(255, 255, 255, 0.08);
        background-color: #0b0f19;
        box-shadow: none;
    }

    :root[data-theme="dark"] .grading-roster-sidebar {
        background-color: #0f172a;
        border-right-color: rgba(255, 255, 255, 0.08);
    }

    :root[data-theme="dark"] .roster-header {
        border-bottom-color: rgba(255, 255, 255, 0.08);
    }

    :root[data-theme="dark"] .roster-header h3 {
        color: #ffffff;
    }

    :root[data-theme="dark"] .roster-search-box {
        border-bottom-color: rgba(255, 255, 255, 0.08);
        background-color: #0b0f19;
    }

    :root[data-theme="dark"] .roster-search-input {
        background-color: #1e293b;
        border-color: rgba(255, 255, 255, 0.1);
        color: #ffffff;
    }
    
    :root[data-theme="dark"] .roster-search-input:focus {
        border-color: var(--ws-primary);
    }

    :root[data-theme="dark"] .roster-item:hover {
        background-color: #1e293b;
        border-color: rgba(255, 255, 255, 0.05);
    }

    :root[data-theme="dark"] .roster-item.active {
        background-color: rgba(99, 102, 241, 0.15);
        border-color: var(--ws-primary, #6366f1);
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.25);
    }

    :root[data-theme="dark"] .roster-name {
        color: #ffffff;
    }
    
    :root[data-theme="dark"] .roster-item.active .roster-name {
        color: #818cf8;
    }

    :root[data-theme="dark"] .roster-avatar {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        color: #94a3b8;
    }

    :root[data-theme="dark"] .grading-document-viewer {
        background-color: #0b0f19;
    }

    :root[data-theme="dark"] .grading-doc-card {
        background-color: #0f172a;
        border-color: rgba(255, 255, 255, 0.08);
    }

    :root[data-theme="dark"] .grading-doc-header {
        background-color: #0f172a;
        border-bottom-color: rgba(255, 255, 255, 0.08);
    }

    :root[data-theme="dark"] .grading-doc-title {
        color: #cbd5e1;
    }

    :root[data-theme="dark"] .grading-text-viewer {
        color: #cbd5e1;
        background-color: #0f172a;
    }

    :root[data-theme="dark"] .grading-panel-sidebar {
        background-color: #0f172a;
        border-left-color: rgba(255, 255, 255, 0.08);
    }

    :root[data-theme="dark"] .grading-panel-student {
        border-bottom-color: rgba(255, 255, 255, 0.08);
    }

    :root[data-theme="dark"] .grading-panel-name {
        color: #ffffff;
    }

    :root[data-theme="dark"] .grading-score-label,
    :root[data-theme="dark"] .grading-feedback-label {
        color: #94a3b8;
    }

    :root[data-theme="dark"] .grading-score-input,
    :root[data-theme="dark"] .grading-feedback-textarea {
        background-color: #1e293b !important;
        border-color: rgba(255, 255, 255, 0.1) !important;
        color: #ffffff !important;
    }

    :root[data-theme="dark"] .grading-score-input:focus,
    :root[data-theme="dark"] .grading-feedback-textarea:focus {
        border-color: var(--ws-primary, #6366f1) !important;
        background-color: #0f172a !important;
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2) !important;
    }
    </style>
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
        <c:if test="${param.error == 'graderange'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Invalid score. Must be between 0 and ${selectedAssessment.totalMarks}.</div></c:if>
        <c:if test="${not empty errorMessage}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div></c:if>

        <div class="ia-submissions-split-layout">
            <!-- Left Pane: Student Roster Queue -->
            <aside class="grading-roster-sidebar">
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
                                <span class="status-badge status-${fn:toLowerCase(fn:replace(row.studentStatusLabel, ' ', '-'))} roster-status-badge">
                                    ${row.studentStatusLabel}
                                </span>
                            </div>
                            <div class="roster-score">
                                <c:choose>
                                    <c:when test="${not empty submission and submission.score != null}">
                                        <span class="roster-score-badge">${submission.score}/${selectedAssessment.totalMarks}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="roster-score-badge" style="color: var(--ins-muted);">--</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </aside>

            <!-- Center Pane: Document Viewer -->
            <section class="grading-document-viewer" id="documentViewerPane">
                <div class="grading-doc-card" id="docCardViewer" style="display: none;">
                    <div class="grading-doc-header">
                        <span class="grading-doc-title" id="viewerDocTitle">
                            <i class="fas fa-file-pdf"></i> Student Submission Payload
                        </span>
                        <a id="viewerExternalLink" href="" target="_blank" class="ws-btn ws-btn-secondary ws-btn-xs" style="padding: 6px 12px;">
                            Open in New Tab <i class="fas fa-external-link-alt"></i>
                        </a>
                    </div>
                    <!-- Frame for PDFs -->
                    <iframe id="pdfViewerFrame" class="grading-iframe-viewer" src="" style="display: none;"></iframe>
                    <!-- Fallback panel for Text answers -->
                    <div id="textAnswersViewer" class="grading-text-viewer" style="display: none;"></div>
                </div>

                <div class="grading-empty-selection" id="viewerEmptyState">
                    <i class="fas fa-file-signature"></i>
                    <h3>No Submission Selected</h3>
                    <p>Select a student from the sidebar queue on the left to begin grading their work.</p>
                </div>
            </section>

            <!-- Right Pane: Scoring & Feedback Panel -->
            <aside class="grading-panel-sidebar">
                <div id="gradingSidebarActive" style="display: none; height: 100%; flex-direction: column; gap: 24px;">
                    <div class="grading-panel-student">
                        <div class="grading-panel-avatar" id="sidebarAvatar">A</div>
                        <div class="grading-panel-meta">
                            <span class="grading-panel-name" id="sidebarStudentName">Student Name</span>
                            <span class="grading-panel-email" id="sidebarStudentEmail">email@domain.com</span>
                        </div>
                    </div>

                    <!-- AJAX Grading Form -->
                    <form id="gradingDashboardForm" method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="display: flex; flex-direction: column; gap: 24px; flex-grow: 1;">
                        <input type="hidden" name="action" value="gradeSubmission" />
                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                        <input type="hidden" name="submissionId" id="formSubmissionId" value="" />
                        <input type="hidden" name="workflowAction" value="submissions" />

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

                <div class="grading-empty-selection" id="sidebarEmptyState" style="height: 100%;">
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
                         data-is-pdf="${fn:endsWith(fn:toLowerCase(submissionPayload), '.pdf')}"
                         data-type="${selectedAssessment.type}">
                    </div>
                </c:if>
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

        // Show active blocks
        document.getElementById("docCardViewer").style.display = "flex";
        document.getElementById("gradingSidebarActive").style.display = "flex";

        // Extract attributes
        const studentName = block.getAttribute("data-student-name");
        const studentEmail = block.getAttribute("data-student-email");
        const score = block.getAttribute("data-score");
        const feedback = block.getAttribute("data-feedback");
        const fileUrl = block.getAttribute("data-file-url");
        const isPdf = block.getAttribute("data-is-pdf") === "true";
        const payload = block.getAttribute("data-payload");

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

        // Load document preview
        const pdfFrame = document.getElementById("pdfViewerFrame");
        const textViewer = document.getElementById("textAnswersViewer");
        const extLink = document.getElementById("viewerExternalLink");

        if (payload && payload.trim() !== "") {
            extLink.style.display = "inline-flex";
            extLink.href = fileUrl;
            
            if (isPdf) {
                pdfFrame.style.display = "block";
                textViewer.style.display = "none";
                pdfFrame.src = fileUrl;
            } else {
                pdfFrame.style.display = "none";
                textViewer.style.display = "block";
                pdfFrame.src = "";
                textViewer.textContent = payload;
            }
        } else {
            extLink.style.display = "none";
            pdfFrame.style.display = "none";
            textViewer.style.display = "block";
            pdfFrame.src = "";
            textViewer.innerHTML = `<div style="text-align: center; padding: 48px; color: #94a3b8;">
                <i class="fas fa-exclamation-circle" style="font-size: 2rem; margin-bottom: 12px; display: block; color: var(--ws-primary);"></i>
                No submission file or text payload available for this student.
            </div>`;
        }
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
                                scoreBadge.style.color = "var(--ws-success, #10b981)";
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
            document.getElementById("textAnswersViewer").style.display = "block";
            document.getElementById("textAnswersViewer").innerHTML = `<div style="text-align: center; padding: 120px 40px; color: #94a3b8;">
                <i class="fas fa-trophy" style="font-size: 4rem; margin-bottom: 20px; display: block; color: var(--ws-warning);"></i>
                <h3 style="color: #0f172a; margin-bottom: 12px; font-weight: 800;">Roster Grading Completed!</h3>
                <p style="margin: 0; font-size: 0.95rem; color: #64748b;">Every student submission in this queue has been evaluated and scored.</p>
            </div>`;

            // Reset active card states
            document.querySelectorAll("#gradingRosterList .roster-item").forEach(item => {
                item.classList.remove("active");
            });
            document.getElementById("gradingSidebarActive").style.display = "none";
            document.getElementById("sidebarEmptyState").style.display = "flex";
            document.getElementById("sidebarEmptyState").innerHTML = `<i class="fas fa-check-circle" style="color: var(--ws-success); font-size: 2.5rem; margin-bottom: 12px;"></i>
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

<div id="premiumSuccessToast" class="premium-toast" style="position: fixed; bottom: 24px; right: 24px; background: var(--ws-success, #10b981); color: white; padding: 16px 24px; border-radius: 8px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); display: flex; align-items: center; gap: 10px; z-index: 9999; transform: translateY(100px); transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); pointer-events: none;">
    <i class="fas fa-check-circle"></i>
    <span id="premiumToastMsg">Saved successfully!</span>
</div>

<style>
    .premium-toast.show {
        transform: translateY(0) !important;
    }
</style>
</body>
</html>
