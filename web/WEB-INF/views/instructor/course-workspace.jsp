<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Workspace - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-materials.css?v=3">
    <script defer src="${pageContext.request.contextPath}/js/instructor-course-workspace.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme-toggle.css">
    <script defer src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
    <script defer src="${pageContext.request.contextPath}/js/instructor-shell.js"></script>
    
    <style>
    /* Modern Glassmorphic Workspace Design System */
    :root {
        --ws-primary: #6366f1;
        --ws-primary-glow: rgba(99, 102, 241, 0.15);
        --ws-success: #10b981;
        --ws-warning: #f59e0b;
        --ws-danger: #ef4444;
        --ws-bg-glass: rgba(255, 255, 255, 0.7);
        --ws-border-glass: rgba(226, 232, 240, 0.8);
        --ws-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
        --ws-shadow-hover: 0 20px 40px rgba(15, 23, 42, 0.08);
    }

    [data-theme="dark"] {
        --ws-bg-glass: rgba(30, 41, 59, 0.7);
        --ws-border-glass: rgba(71, 85, 105, 0.5);
        --ws-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        --ws-shadow-hover: 0 20px 40px rgba(0, 0, 0, 0.3);
    }

    .course-workspace-page {
        padding-top: 0px;
    }



    /* Tab Display and Animations */
    .ws-tab-content {
        display: none !important;
        opacity: 0;
        transform: translateY(12px);
        transition: none;
    }

    .ws-tab-content.active {
        display: block !important;
        opacity: 1 !important;
        transform: translateY(0) !important;
        animation: wsFadeInUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards !important;
    }

    @keyframes wsFadeInUp {
        from {
            opacity: 0;
            transform: translateY(12px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .workspace-flow-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 16px;
        margin-top: 18px;
    }

    .workspace-flow-card {
        background: var(--ws-bg-glass);
        border: 1px solid var(--ws-border-glass);
        border-radius: 16px;
        padding: 18px;
        box-shadow: var(--ws-shadow);
        display: flex;
        flex-direction: column;
        gap: 10px;
        min-height: 160px;
    }

    .workspace-flow-card h4 {
        margin: 0;
        font-size: 1rem;
        font-weight: 800;
        color: var(--ins-heading, #0f172a);
    }

    .workspace-flow-card p {
        margin: 0;
        font-size: 0.88rem;
        line-height: 1.45;
        color: var(--ins-muted, #64748b);
    }

    .workspace-flow-card .btn {
        margin-top: auto;
        align-self: flex-start;
    }

    /* KPI Cards Layout */
    .workspace-kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }

    .workspace-kpi-card {
        background: var(--ws-bg-glass);
        border: 1px solid var(--ws-border-glass);
        border-radius: 16px;
        padding: 22px;
        display: flex;
        flex-direction: column;
        gap: 8px;
        box-shadow: var(--ws-shadow);
        transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        position: relative;
        overflow: hidden;
    }

    .workspace-kpi-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--ws-shadow-hover);
        border-color: var(--ws-primary-glow);
    }

    .workspace-kpi-card strong {
        font-size: 2.2rem;
        font-weight: 800;
        color: var(--ins-heading, #0f172a);
        line-height: 1;
        letter-spacing: -0.03em;
    }

    .workspace-kpi-card span {
        font-size: 0.75rem;
        color: var(--ins-muted, #64748b);
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    /* Tables and Lists */
    .premium-table-wrapper {
        background: var(--ws-bg-glass);
        border: 1px solid var(--ws-border-glass);
        border-radius: 16px;
        overflow-x: auto;
        box-shadow: var(--ws-shadow);
        margin-top: 16px;
    }

    .premium-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
        min-width: 600px;
    }

    .premium-table th {
        background: rgba(99, 102, 241, 0.03);
        padding: 16px 20px;
        font-size: 0.78rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: var(--ws-primary);
        border-bottom: 1px solid var(--ws-border-glass);
    }

    .premium-table td {
        padding: 18px 20px;
        border-bottom: 1px solid var(--ws-border-glass);
        color: var(--ins-heading, #0f172a);
        font-size: 0.9rem;
    }

    .premium-table tbody tr:last-child td {
        border-bottom: none;
    }

    .premium-table tr {
        transition: background-color 0.2s ease;
    }

    .premium-table tbody tr:hover {
        background-color: rgba(99, 102, 241, 0.02);
    }

    /* Material Layout */
    .material-name-block {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .material-avatar {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        flex-shrink: 0;
    }

    .material-avatar.type-pdf { background: rgba(239, 68, 68, 0.1); color: #ef4444; }
    .material-avatar.type-video { background: rgba(59, 130, 246, 0.1); color: #3b82f6; }
    .material-avatar.type-slides { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
    .material-avatar.type-link { background: rgba(16, 185, 129, 0.1); color: #10b981; }
    .material-avatar.type-youtube { background: rgba(220, 38, 38, 0.1); color: #dc2626; }

    .material-title {
        font-size: 0.95rem;
        font-weight: 700;
        color: var(--ins-heading, #0f172a);
    }

    .material-desc {
        font-size: 0.8rem;
        color: var(--ins-muted, #64748b);
        margin: 4px 0 0;
        line-height: 1.4;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    /* Badges */
    .type-badge {
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 0.72rem;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        text-transform: uppercase;
    }

    .badge-pdf { background: rgba(239, 68, 68, 0.1); color: #ef4444; }
    .badge-video { background: rgba(59, 130, 246, 0.1); color: #3b82f6; }
    .badge-slides { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
    .badge-link { background: rgba(16, 185, 129, 0.1); color: #10b981; }
    .badge-youtube { background: rgba(220, 38, 38, 0.1); color: #dc2626; }

    .table-link {
        color: var(--ws-primary);
        text-decoration: none;
        font-weight: 600;
        font-size: 0.85rem;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .table-link:hover {
        text-decoration: underline;
    }

    /* Assessments Grid */
    .assessments-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 20px;
        margin-top: 16px;
    }

    .assessment-card {
        background: var(--ws-bg-glass);
        border: 1px solid var(--ws-border-glass);
        border-radius: 16px;
        padding: 20px;
        box-shadow: var(--ws-shadow);
        display: flex;
        flex-direction: column;
        gap: 16px;
        transition: all 0.3s ease;
    }

    .assessment-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--ws-shadow-hover);
        border-color: var(--ws-primary-glow);
    }

    .assessment-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .assessment-icon-circle {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem;
    }

    .assessment-icon-circle.quiz { background: rgba(99, 102, 241, 0.1); color: var(--ws-primary); }
    .assessment-icon-circle.exam { background: rgba(239, 68, 68, 0.1); color: #ef4444; }
    .assessment-icon-circle.assignment { background: rgba(16, 185, 129, 0.1); color: #10b981; }

    .assessment-title {
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--ins-heading, #0f172a);
        margin: 0;
    }

    .assessment-desc {
        font-size: 0.82rem;
        color: var(--ins-muted, #64748b);
        line-height: 1.45;
        margin: 0;
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .assessment-stats-row {
        display: flex;
        gap: 12px;
        margin-top: auto;
    }

    .stat-bubble {
        flex: 1;
        background: rgba(99, 102, 241, 0.02);
        border: 1px solid var(--ws-border-glass);
        border-radius: 12px;
        padding: 8px 12px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 2px;
    }

    .stat-num {
        font-size: 1.05rem;
        font-weight: 800;
        color: var(--ins-heading, #0f172a);
    }

    .stat-lbl {
        font-size: 0.65rem;
        color: var(--ins-muted, #64748b);
        font-weight: 700;
        text-transform: uppercase;
    }

    .assessment-actions {
        display: flex;
        gap: 10px;
    }

    /* Student search & list */
    .student-search-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
        margin-bottom: 20px;
        flex-wrap: wrap;
    }

    .search-input-wrap {
        position: relative;
        max-width: 320px;
        width: 100%;
    }

    .search-input-wrap i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--ins-muted, #64748b);
    }

    .search-input-wrap input {
        width: 100%;
        padding: 10px 16px 10px 38px;
        border: 1px solid var(--ws-border-glass);
        background: var(--ws-bg-glass);
        border-radius: 10px;
        font-family: inherit;
        font-size: 0.88rem;
        outline: none;
        transition: all 0.25s ease;
    }

    .search-input-wrap input:focus {
        border-color: var(--ws-primary);
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
    }

    /* Analytics Cards Style */
    .ws-analytics-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-top: 16px;
    }

    .ws-analytics-card {
        background: var(--ws-bg-glass);
        border: 1px solid var(--ws-border-glass);
        border-radius: 14px;
        padding: 20px;
        box-shadow: var(--ws-shadow);
        display: flex;
        flex-direction: column;
        gap: 6px;
        transition: all 0.25s ease;
    }

    .ws-analytics-card:hover {
        border-color: var(--ws-primary);
        transform: translateY(-2px);
    }

    .ws-analytics-card span {
        font-size: 0.8rem;
        font-weight: 600;
        color: var(--ins-muted, #64748b);
    }

    .ws-analytics-card strong {
        font-size: 1.6rem;
        font-weight: 800;
        color: var(--ins-heading, #0f172a);
    }

    /* Button override for tables */
    .btn-xs {
        padding: 6px 12px;
        font-size: 0.75rem;
        border-radius: 6px;
    }

    /* Student listing cards v2 */
    .ws-student-row-v2 {
        display: grid;
        grid-template-columns: 2fr 1fr 1.5fr 1fr;
        align-items: center;
        gap: 16px;
        padding: 16px 20px;
        border-bottom: 1px solid var(--ws-border-glass);
        transition: background-color 0.2s ease;
    }

    .ws-student-row-v2:last-child {
        border-bottom: none;
    }

    .ws-student-row-v2:hover {
        background: rgba(99, 102, 241, 0.02);
    }

    @media (max-width: 768px) {
        .ws-navbar {
            flex-direction: column;
            gap: 4px;
        }
        .ws-student-row-v2 {
            grid-template-columns: 1fr;
            gap: 12px;
            padding: 16px;
        }
        .col-actions {
            justify-content: flex-start;
        }
    }
    </style>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Workspace"/>
</jsp:include>

<c:set var="activeInstructorPage" value="courses"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper course-workspace-page">
        
        <%-- HEADER --%>
        <section class="ws-page-head-slim" style="margin-bottom: 24px;">
            <div class="ws-head-left-slim">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary btn-sm" style="height: 38px; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
                <h2><c:out value="${selectedCourse.courseName}"/></h2>
                <span class="status-badge status-${selectedCourse.status}"><c:out value="${selectedCourse.status}"/></span>
            </div>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error" style="margin-bottom: 24px;"><i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/></div>
        </c:if>

        <c:url var="assessmentWorkspaceBaseUrl" value="/instructor/assessments">
            <c:param name="courseId" value="${selectedCourse.courseId}"/>
        </c:url>

        <%-- WORKSPACE NAVIGATION --%>
        <nav class="ws-navbar-modern" aria-label="Workspace navigation">
            <a class="ws-nav-link-modern active" href="#overview" data-section-link="overview">
                <i class="fas fa-chart-pie"></i> Overview
            </a>
            <a class="ws-nav-link-modern" href="#materials" data-section-link="materials">
                <i class="fas fa-book-open"></i> Materials
            </a>
            <a class="ws-nav-link-modern" href="#assessments" data-section-link="assessments">
                <i class="fas fa-tasks"></i> Assessments
            </a>
            <a class="ws-nav-link-modern" href="#students" data-section-link="students">
                <i class="fas fa-users"></i> Students
            </a>
        </nav>

        <%-- SECTION 1: OVERVIEW DASHBOARD --%>
        <div id="overview" class="ws-tab-content active">
            <div class="overview-dashboard-container">
                
                <%-- TOP SECTION: COURSE DETAILS --%>
                <section class="overview-top-section">
                    <div class="overview-meta-chips">
                        <div class="meta-badge-chip">
                            <i class="fas fa-tag"></i>
                            <span>Category: <c:out value="${empty selectedCourse.category ? 'General' : selectedCourse.category}"/></span>
                        </div>
                        <div class="meta-badge-chip">
                            <i class="fas fa-signal"></i>
                            <span>Level: <c:out value="${selectedCourse.level}"/></span>
                        </div>
                        <div class="meta-badge-chip">
                            <i class="fas fa-clock"></i>
                            <span>Duration: <c:out value="${selectedCourse.displayDuration}"/></span>
                        </div>
                        <div class="meta-badge-chip">
                            <i class="fas fa-calendar-alt"></i>
                            <span>Updated: <c:out value="${not empty selectedCourse.updatedAt ? selectedCourse.updatedAt.toLocalDate() : (not empty selectedCourse.createdAt ? selectedCourse.createdAt.toLocalDate() : '-') }"/></span>
                        </div>
                    </div>
                    
                    <c:if test="${not empty selectedCourse.description}">
                        <p class="overview-course-desc">
                            <c:out value="${selectedCourse.description}"/>
                        </p>
                    </c:if>
                </section>

                <%-- MIDDLE SECTION: COURSE KPIS GRID --%>
                <section class="overview-kpis-grid-modern">
                    <%-- KPI 1: Enrolled Students --%>
                    <div class="kpi-card-modern">
                        <div class="kpi-icon-wrapper students">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="kpi-data-wrapper">
                            <strong><c:out value="${totalStudents}"/></strong>
                            <span>Total Enrolled Students</span>
                        </div>
                    </div>

                    <%-- KPI 2: Materials Uploaded --%>
                    <div class="kpi-card-modern">
                        <div class="kpi-icon-wrapper materials">
                            <i class="fas fa-book-open"></i>
                        </div>
                        <div class="kpi-data-wrapper">
                            <strong><c:out value="${publishedMaterials}"/></strong>
                            <span>Materials Uploaded</span>
                        </div>
                    </div>

                    <%-- KPI 3: Assessments Created --%>
                    <div class="kpi-card-modern">
                        <div class="kpi-icon-wrapper assessments">
                            <i class="fas fa-tasks"></i>
                        </div>
                        <div class="kpi-data-wrapper">
                            <strong><c:out value="${assessmentCount}"/></strong>
                            <span>Assessments Created</span>
                        </div>
                    </div>

                    <%-- KPI 4: Pending Submissions --%>
                    <div class="kpi-card-modern">
                        <div class="kpi-icon-wrapper pending">
                            <i class="fas fa-file-signature"></i>
                        </div>
                        <div class="kpi-data-wrapper">
                            <strong style="color: ${pendingGrading > 0 ? 'var(--ws-danger, #ef4444)' : 'inherit'}"><c:out value="${pendingGrading}"/></strong>
                            <span>Pending Submissions</span>
                        </div>
                    </div>
                </section>

                <%-- BOTTOM SECTION: QUICK ACTIONS --%>
                <section class="overview-actions-section">
                    <h3>Quick Actions</h3>
                    <div class="overview-actions-grid">
                        <button onclick="openUploadModal()" class="action-pill-btn" style="cursor: pointer;">
                            <i class="fas fa-upload"></i>
                            <span>Upload New Material</span>
                        </button>
                        <a href="${assessmentWorkspaceBaseUrl}&view=editor" class="action-pill-btn">
                            <i class="fas fa-plus"></i>
                            <span>Create Assessment</span>
                        </a>
                        <a href="#students" class="action-pill-btn">
                            <i class="fas fa-users"></i>
                            <span>View Roster</span>
                        </a>
                    </div>
                </section>
                
            </div>
        </div>

        <%-- SECTION 2: CURRICULUM MATERIALS --%>
        <div id="materials" class="ws-tab-content">
            <div class="section-card" style="padding: 16px; border-radius: 12px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 16px;">
                    <h3 class="section-title" style="margin: 0; font-weight: 800; font-size: 1.25rem;">Course Curriculum Materials (${fn:length(materials)} items)</h3>
                    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                        <button class="btn btn-primary" onclick="openUploadModal()">
                            <i class="fas fa-upload"></i> Upload Material
                        </button>
                        <a href="${pageContext.request.contextPath}/instructor/content-organizer?courseId=${selectedCourse.courseId}" class="btn btn-secondary">
                            <i class="fas fa-folder-open"></i> Open Material Organizer
                        </a>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty materials}">
                        <div class="empty-state-box workspace-empty-box" style="padding: 40px; text-align: center;">
                            <i class="fas fa-folder-open" style="font-size: 3rem; color: var(--ins-muted); margin-bottom: 16px;"></i>
                            <p style="font-weight: 600; margin-bottom: 12px;">No active materials uploaded for this course yet.</p>
                            <button class="btn btn-primary btn-sm" onclick="openUploadModal()">Upload First Material</button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="premium-table-wrapper">
                            <table class="premium-table">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">Order</th>
                                        <th>Title & Summary Description</th>
                                        <th style="width: 140px;">Type</th>
                                        <th style="width: 160px;">Reference</th>
                                        <th style="width: 120px; text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="material" items="${materials}">
                                        <tr>
                                            <td style="font-weight: 800; color: var(--ws-primary);">#${not empty material.displayOrder ? material.displayOrder : '-'}</td>
                                            <td>
                                                <div class="material-name-block">
                                                    <div class="material-avatar type-${fn:toLowerCase(material.materialType)}">
                                                        <i class="fas <c:choose>
                                                            <c:when test="${material.materialType == 'PDF'}">fa-file-pdf</c:when>
                                                            <c:when test="${material.materialType == 'Video'}">fa-file-video</c:when>
                                                            <c:when test="${material.materialType == 'Slides'}">fa-file-powerpoint</c:when>
                                                            <c:when test="${material.materialType == 'Link'}">fa-link</c:when>
                                                            <c:when test="${material.materialType == 'YouTube'}">fa-play-circle</c:when>
                                                            <c:otherwise>fa-file-alt</c:otherwise>
                                                        </c:choose>"></i>
                                                    </div>
                                                    <div>
                                                        <strong class="material-title"><c:out value="${material.title}"/></strong>
                                                        <p class="material-desc" style="margin: 4px 0 0;"><c:out value="${material.description}" default="No description has been written for this module block."/></p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="type-badge badge-${fn:toLowerCase(material.materialType)}">
                                                    <c:out value="${material.materialType}"/>
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty material.filePath}">
                                                        <a href="${(material.materialType == 'Link' || material.materialType == 'YouTube') ? material.filePath : pageContext.request.contextPath.concat('/uploads/').concat(material.filePath)}" target="_blank" class="btn btn-secondary btn-xs" style="background: transparent; border: 1px solid var(--ws-border-glass); color: var(--ins-muted); padding: 4px 8px; font-size: 0.75rem;"><i class="fas fa-eye"></i> Preview</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: var(--ins-muted); font-size: 0.85rem; font-style: italic;">No file</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: right; display: flex; gap: 8px; justify-content: flex-end;">
                                                <button class="btn btn-secondary btn-xs" 
                                                        data-material-id="${material.materialId}"
                                                        data-title="<c:out value='${material.title}'/>"
                                                        data-type="<c:out value='${material.materialType}'/>"
                                                        data-order="${material.displayOrder}"
                                                        data-description="<c:out value='${material.description}'/>"
                                                        data-external-url="<c:out value='${material.filePath}'/>"
                                                        onclick="openEditMaterialModal(this, false)">
                                                    <i class="fas fa-edit"></i> Edit
                                                </button>
                                                <form action="${pageContext.request.contextPath}/instructor/materials" method="get" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this material?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${material.materialId}">
                                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                    <input type="hidden" name="source" value="workspace">
                                                    <button type="submit" class="btn btn-xs" style="background: transparent; color: var(--ws-danger); border: 1px solid transparent; padding: 6px 10px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; gap: 4px; font-weight: 600;"><i class="fas fa-trash"></i> Delete</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- SECTION 3: ASSESSMENTS LIBRARY --%>
        <div id="assessments" class="ws-tab-content">
            <div class="section-card" style="padding: 16px; border-radius: 12px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 16px;">
                    <h3 class="section-title" style="margin: 0; font-weight: 800; font-size: 1.25rem;">Course Assessments Library (${fn:length(assessments)} items)</h3>
                    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                        <a href="${assessmentWorkspaceBaseUrl}&view=editor" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Create Assessment
                        </a>
                        <a href="${assessmentWorkspaceBaseUrl}" class="btn btn-secondary">
                            <i class="fas fa-clipboard-list"></i> Assessments Hub
                        </a>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty assessments}">
                        <div class="empty-state-box workspace-empty-box" style="padding: 40px; text-align: center;">
                            <i class="fas fa-clipboard-list" style="font-size: 3rem; color: var(--ins-muted); margin-bottom: 16px;"></i>
                            <p style="font-weight: 600; margin-bottom: 12px;">No assessments created for this course yet.</p>
                            <a href="${assessmentWorkspaceBaseUrl}&view=editor" class="btn btn-primary btn-sm">Create First Assessment</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="assessments-grid">
                            <c:forEach var="assessment" items="${assessments}">
                                <div class="assessment-card">
                                    <div class="assessment-card-header">
                                        <div class="assessment-icon-circle ${fn:toLowerCase(assessment.type)}">
                                            <i class="fas ${assessment.type == 'Assignment' ? 'fa-file-signature' : 'fa-stopwatch'}"></i>
                                        </div>
                                        <span class="type-badge badge-${fn:toLowerCase(assessment.type)}">${assessment.type}</span>
                                    </div>
                                    <h4 class="assessment-title" style="margin: 0; font-weight: 700;"><c:out value="${assessment.title}"/></h4>
                                    <p class="assessment-desc"><c:out value="${assessment.instructions}" default="No instruction details provided for this evaluation module."/></p>
                                    <div class="assessment-stats-row">
                                        <div class="stat-bubble">
                                            <span class="stat-num">${submissionCountByAssessmentId[assessment.assessmentId] != null ? submissionCountByAssessmentId[assessment.assessmentId] : 0}</span>
                                            <span class="stat-lbl">Attempts</span>
                                        </div>
                                        <div class="stat-bubble">
                                            <span class="stat-num">
                                                <c:choose>
                                                    <c:when test="${not empty assessment.duration and assessment.duration > 0}"><c:out value="${assessment.duration}"/>m</c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <span class="stat-lbl">Time Limit</span>
                                        </div>
                                        <div class="stat-bubble">
                                            <span class="stat-num">
                                                <c:choose>
                                                    <c:when test="${not empty assessment.totalMarks}"><c:out value="${assessment.totalMarks}"/></c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <span class="stat-lbl">Points</span>
                                        </div>
                                    </div>
                                    <div class="assessment-actions">
                                        <a href="${assessmentWorkspaceBaseUrl}&view=editor&assessmentId=${assessment.assessmentId}" class="btn btn-secondary btn-sm" style="flex: 1;"><i class="fas fa-edit"></i> Edit</a>
                                        <a href="${assessmentWorkspaceBaseUrl}&view=submissions&assessmentId=${assessment.assessmentId}" class="btn btn-primary btn-sm" style="flex: 1;"><i class="fas fa-inbox"></i> Grades</a>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- SECTION 4: ENROLLED STUDENTS --%>
        <div id="students" class="ws-tab-content">
            <div class="section-card" style="padding: 16px; border-radius: 12px;">
                <div class="student-search-bar">
                    <h3 class="section-title" style="margin: 0; font-weight: 800; font-size: 1.25rem;">Active Roster (${fn:length(enrollments)} students)</h3>
                    <div class="search-input-wrap">
                        <i class="fas fa-search"></i>
                        <input type="text" id="wsRosterSearchInput" placeholder="Filter roster by student name or email..." oninput="filterRosterTable()">
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty enrollments}">
                        <div class="empty-state-box workspace-empty-box" style="padding: 40px; text-align: center;">
                            <i class="fas fa-user-slash" style="font-size: 3rem; color: var(--ins-muted); margin-bottom: 16px;"></i>
                            <p style="font-weight: 600;">No students are registered or enrolled in this course syllabus yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="premium-table-wrapper">
                            <table class="premium-table" id="wsRosterTable">
                                <thead>
                                    <tr>
                                        <th>Student Details</th>
                                        <th style="width: 140px;">Status</th>
                                        <th style="width: 200px;">Progress Tracking</th>
                                        <th style="width: 150px;">Registration</th>
                                        <th style="width: 160px; text-align: right;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="enrollment" items="${enrollments}">
                                        <tr class="student-table-row">
                                            <td>
                                                <div class="material-name-block">
                                                    <div class="ws-student-avatar" style="width: 28px; height: 28px; border-radius: 50%; background: var(--ws-primary-glow); color: var(--ws-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;">
                                                        <c:out value="${fn:substring(enrollment.studentName, 0, 1)}"/>
                                                    </div>
                                                    <div>
                                                        <strong class="student-search-name" style="font-size: 0.95rem; color: var(--ins-heading, #0f172a);"><c:out value="${enrollment.studentName}"/></strong>
                                                        <p class="student-search-email" style="font-size: 0.8rem; color: var(--ins-muted, #64748b); margin: 2px 0 0;"><c:out value="${enrollment.studentEmail}"/></p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="status-badge status-${fn:toLowerCase(enrollment.status)}">
                                                    <c:out value="${enrollment.status}"/>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="ws-student-progress" style="display: flex; flex-direction: column; gap: 6px;">
                                                    <div class="ws-progress-bar" style="width: 100%; height: 6px; background: rgba(99, 102, 241, 0.08); border-radius: 4px; overflow: hidden;">
                                                        <div class="ws-progress-fill" style="width: ${not empty enrollment.progress ? enrollment.progress : 0}%; height: 100%; background: var(--ws-primary); border-radius: 4px;"></div>
                                                    </div>
                                                    <span class="ws-progress-text" style="font-size: 0.78rem; font-weight: 700; color: var(--ins-muted);"><c:out value="${not empty enrollment.progress ? enrollment.progress : 0}"/>% Completed</span>
                                                </div>
                                            </td>
                                            <td style="color: var(--ins-muted); font-size: 0.85rem;">
                                                <i class="far fa-calendar-alt" style="margin-right: 6px;"></i>
                                                <c:out value="${fn:substring(enrollment.enrollmentDate, 0, 10)}"/>
                                            </td>
                                            <td style="text-align: right; display: flex; gap: 8px; justify-content: flex-end;">
                                                <a href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}" class="btn btn-secondary btn-xs" title="View Grades">
                                                    <i class="fas fa-chart-bar"></i> Grades
                                                </a>
                                                <c:if test="${enrollment.progress == 100 || fn:toLowerCase(enrollment.status) == 'completed' || fn:toLowerCase(enrollment.completionStatus) == 'completed'}">
                                                    <a href="${pageContext.request.contextPath}/certificate/verify?enrollmentId=${enrollment.enrollmentId}" class="btn btn-xs" title="Issue/View Certificate" target="_blank" style="background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.2); color: var(--ws-success); font-weight: 600;">
                                                        <i class="fas fa-certificate"></i> Cert
                                                    </a>
                                                </c:if>
                                            </td>
                                        </tr>
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

<!-- Upload Material Modal -->
<div id="uploadModal" class="modal">
    <div class="modal-content" style="border-radius: 16px; overflow: hidden; border: none; box-shadow: 0 20px 50px rgba(0,0,0,0.15);">
        <div class="modal-header" style="background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%); color: #ffffff; padding: 20px 24px;">
            <h3 style="margin: 0; font-size: 1.25rem; font-weight: 800; color: #ffffff;">Upload New Material</h3>
            <button class="modal-close" onclick="closeUploadModal()" style="color: rgba(255,255,255,0.8); background: transparent; border: none; font-size: 1.2rem; cursor: pointer;"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" style="padding: 24px;">
            <p class="modal-subtitle" style="margin-top: 0; margin-bottom: 20px; font-size: 0.9rem; color: var(--ins-muted);">Course: <strong style="color: var(--ins-heading);"><c:out value="${selectedCourse.courseName}"/></strong></p>
            <form id="uploadForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                <input type="hidden" name="source" value="workspace">
                <div class="upload-form-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Title *</label>
                        <input type="text" name="title" required style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit;">
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Type *</label>
                        <select name="materialType" id="materialType" required style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit; background: #fff;">
                            <option value="">Select type</option>
                            <option value="PDF">PDF Document</option>
                            <option value="Video">Video File</option>
                            <option value="Slides">Slides Presentation</option>
                            <option value="Link">External Web Link</option>
                            <option value="YouTube">YouTube Embed Video</option>
                        </select>
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Chapter / Sequence Order</label>
                        <input type="number" name="displayOrder" min="1" placeholder="Auto-sequence if blank" style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit;">
                    </div>
                    <div class="field" id="fileFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Upload Attachment File</label>
                        <input type="file" name="materialFile" id="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3" style="display: none;">
                        <div class="modern-drag-drop-zone" id="uploadDragDropZone">
                            <i class="fas fa-cloud-upload-alt upload-icon"></i>
                            <p class="drag-drop-text">Click or drag file here to upload</p>
                            <span class="file-name-preview" id="uploadFileNamePreview" style="display: none;"></span>
                        </div>
                    </div>
                    <div class="field" id="urlFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2; display: none;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Material URL / Embed Link</label>
                        <input type="url" name="externalUrl" id="externalUrl" placeholder="https://..." style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit; width: 100%; box-sizing: border-box;">
                    </div>
                    <div class="field full" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Curriculum Description</label>
                        <textarea name="description" rows="3" style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit; resize: vertical;"></textarea>
                    </div>
                </div>
                <div class="modal-footer" style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--ws-border-glass); display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" class="btn btn-secondary" onclick="closeUploadModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-upload"></i> Publish Material</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Material Modal -->
<div id="editMaterialModal" class="modal">
    <div class="modal-content" style="border-radius: 16px; overflow: hidden; border: none; box-shadow: 0 20px 50px rgba(0,0,0,0.15);">
        <div class="modal-header" style="background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%); color: #ffffff; padding: 20px 24px;">
            <h3 style="margin: 0; font-size: 1.25rem; font-weight: 800; color: #ffffff;">Edit Course Material</h3>
            <button class="modal-close" onclick="closeEditMaterialModal()" style="color: rgba(255,255,255,0.8); background: transparent; border: none; font-size: 1.2rem; cursor: pointer;"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" style="padding: 24px;">
            <p class="modal-subtitle" style="margin-top: 0; margin-bottom: 20px; font-size: 0.9rem; color: var(--ins-muted);">Course: <strong style="color: var(--ins-heading);"><c:out value="${selectedCourse.courseName}"/></strong></p>
            <form id="editMaterialForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="materialId" id="editMaterialId">
                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                <input type="hidden" name="source" value="workspace">
                <div class="upload-form-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Title *</label>
                        <input id="editTitle" type="text" name="title" required style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit;">
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Type *</label>
                        <select id="editType" name="materialType" required style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit; background: #fff;">
                            <option value="PDF">PDF Document</option>
                            <option value="Video">Video File</option>
                            <option value="Slides">Slides Presentation</option>
                            <option value="Link">External Web Link</option>
                            <option value="YouTube">YouTube Embed Video</option>
                        </select>
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Chapter / Sequence Order</label>
                        <input id="editOrder" type="number" name="displayOrder" min="1" placeholder="Auto-sequence if blank" style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit;">
                    </div>
                    <div class="field" id="editFileFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Replace Attachment File</label>
                        <input id="editFile" type="file" name="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3" style="display: none;">
                        <div class="modern-drag-drop-zone" id="editDragDropZone">
                            <i class="fas fa-cloud-upload-alt upload-icon"></i>
                            <p class="drag-drop-text">Click or drag file here to replace</p>
                            <span class="file-name-preview" id="editFileNamePreview" style="display: none;"></span>
                        </div>
                    </div>
                    <div class="field" id="editUrlFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2; display: none;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Material URL / Embed Link</label>
                        <input id="editExternalUrl" type="url" name="externalUrl" placeholder="https://..." style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit; width: 100%; box-sizing: border-box;">
                    </div>
                    <div class="field full" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label style="font-size: 0.82rem; font-weight: 700; color: var(--ins-heading);">Curriculum Description</label>
                        <textarea id="editDescription" name="description" rows="3" style="padding: 10px 14px; border: 1px solid var(--ws-border-glass); border-radius: 8px; font-family: inherit; resize: vertical;"></textarea>
                    </div>
                </div>
                <div class="modal-footer" style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--ws-border-glass); display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" class="btn btn-secondary" onclick="closeEditMaterialModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Anchor navigation state for workspace sections.
    document.addEventListener("DOMContentLoaded", function() {
        const links = document.querySelectorAll("[data-section-link]");

        function syncActiveSection() {
            const activeSection = window.location.hash.replace("#", "") || "overview";
            
            // Toggle links
            links.forEach(link => {
                link.classList.toggle("active", link.dataset.sectionLink === activeSection);
            });
            
            // Toggle content panes
            document.querySelectorAll(".ws-tab-content").forEach(pane => {
                pane.classList.remove("active");
                if (pane.id === activeSection) {
                    pane.classList.add("active");
                }
            });
        }

        syncActiveSection();
        window.addEventListener("hashchange", syncActiveSection);
    });

    // Client-side quick keyword filter for Enrolled Students roster table
    function filterRosterTable() {
        const query = document.getElementById("wsRosterSearchInput").value.toLowerCase();
        const rows = document.querySelectorAll("#wsRosterTable .student-table-row");
        
        rows.forEach(row => {
            const name = row.querySelector(".student-search-name").textContent.toLowerCase();
            const email = row.querySelector(".student-search-email").textContent.toLowerCase();
            if (name.includes(query) || email.includes(query)) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    }

    function openAssessmentPage(view, assessmentId) {
        const baseUrl = '${assessmentWorkspaceBaseUrl}';
        const resolvedView = view || 'editor';
        let nextUrl = baseUrl + '&view=' + encodeURIComponent(resolvedView);
        if (assessmentId) {
            nextUrl += '&assessmentId=' + encodeURIComponent(assessmentId);
        }
        window.location.href = nextUrl;
    }

    function openUploadModal() {
        document.getElementById('uploadModal').classList.add('show');
        document.body.style.overflow = 'hidden';
    }

    function closeUploadModal() {
        document.getElementById('uploadModal').classList.remove('show');
        document.body.style.overflow = 'auto';
        document.getElementById('uploadForm').reset();
        document.getElementById('fileFieldContainer').style.display = 'flex';
        document.getElementById('urlFieldContainer').style.display = 'none';
        
        const preview = document.getElementById('uploadFileNamePreview');
        if (preview) {
            preview.style.display = 'none';
            preview.textContent = '';
        }
    }

    function openEditMaterialModal(button, focusFile) {
        document.getElementById('editMaterialId').value = button.dataset.materialId || '';
        document.getElementById('editTitle').value = button.dataset.title || '';
        document.getElementById('editType').value = button.dataset.type || 'PDF';
        document.getElementById('editOrder').value = button.dataset.order || '';
        document.getElementById('editDescription').value = button.dataset.description || '';
        document.getElementById('editExternalUrl').value = button.dataset.externalUrl || '';
        document.getElementById('editFile').value = '';

        // Trigger change event to set field visibility
        const editTypeSelect = document.getElementById('editType');
        const event = new Event('change');
        editTypeSelect.dispatchEvent(event);

        document.getElementById('editMaterialModal').classList.add('show');
        document.body.style.overflow = 'hidden';

        if (focusFile) {
            window.setTimeout(function () {
                const fileInput = document.getElementById('editFile');
                if (fileInput) fileInput.focus();
            }, 0);
        }
    }

    function closeEditMaterialModal() {
        document.getElementById('editMaterialModal').classList.remove('show');
        document.body.style.overflow = 'auto';
        const fileInput = document.getElementById('editFile');
        if (fileInput) fileInput.value = '';
        
        const preview = document.getElementById('editFileNamePreview');
        if (preview) {
            preview.style.display = 'none';
            preview.textContent = '';
        }
    }

    window.addEventListener('click', function (event) {
        const uploadModal = document.getElementById('uploadModal');
        const editModal = document.getElementById('editMaterialModal');
        if (uploadModal && event.target === uploadModal) closeUploadModal();
        if (editModal && event.target === editModal) closeEditMaterialModal();
    });

    window.addEventListener('keydown', function (event) {
        if (event.key !== 'Escape') return;
        closeUploadModal();
        closeEditMaterialModal();
    });

    (function () {
        const type = document.getElementById('materialType');
        const file = document.getElementById('materialFile');
        const url = document.getElementById('externalUrl');
        const editType = document.getElementById('editType');
        const editFile = document.getElementById('editFile');
        const editUrl = document.getElementById('editExternalUrl');

        const fileFieldContainer = document.getElementById('fileFieldContainer');
        const urlFieldContainer = document.getElementById('urlFieldContainer');
        const editFileFieldContainer = document.getElementById('editFileFieldContainer');
        const editUrlFieldContainer = document.getElementById('editUrlFieldContainer');

        const applyTypeRules = function (selectedType, fileInput, urlInput, fileContainer, urlContainer) {
            const isUrlBased = selectedType === 'Link' || selectedType === 'YouTube';
            if (fileInput) {
                fileInput.required = !!selectedType && !isUrlBased && !fileInput.id.includes('edit'); // Edit replace file is not strictly required
                fileInput.disabled = !!selectedType && isUrlBased;
            }
            if (urlInput) {
                urlInput.required = !!selectedType && isUrlBased;
                urlInput.disabled = !!selectedType && !isUrlBased;
                urlInput.placeholder = selectedType === 'YouTube' ? 'https://www.youtube.com/watch?v=...' : 'https://';
            }
            if (fileContainer) {
                fileContainer.style.display = isUrlBased ? 'none' : 'flex';
            }
            if (urlContainer) {
                urlContainer.style.display = isUrlBased ? 'flex' : 'none';
            }
        };

        if (type) type.addEventListener('change', () => applyTypeRules(type.value, file, url, fileFieldContainer, urlFieldContainer));
        if (editType) editType.addEventListener('change', () => applyTypeRules(editType.value, editFile, editUrl, editFileFieldContainer, editUrlFieldContainer));
        
        if (type) applyTypeRules(type.value, file, url, fileFieldContainer, urlFieldContainer);
        if (editType) applyTypeRules(editType.value, editFile, editUrl, editFileFieldContainer, editUrlFieldContainer);
    })();

    // Drag and Drop Area Handler
    function setupDragAndDropZone(zoneId, inputId, previewId) {
        const zone = document.getElementById(zoneId);
        const input = document.getElementById(inputId);
        const preview = document.getElementById(previewId);

        if (!zone || !input) return;

        // Click zone triggers file selection
        zone.addEventListener('click', () => input.click());

        // File selection change event
        input.addEventListener('change', () => {
            if (input.files && input.files[0]) {
                preview.textContent = input.files[0].name;
                preview.style.display = 'inline-block';
            } else {
                preview.style.display = 'none';
                preview.textContent = '';
            }
        });

        // Drag events
        ['dragenter', 'dragover'].forEach(eventName => {
            zone.addEventListener(eventName, (e) => {
                e.preventDefault();
                e.stopPropagation();
                zone.classList.add('dragover');
            }, false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            zone.addEventListener(eventName, (e) => {
                e.preventDefault();
                e.stopPropagation();
                zone.classList.remove('dragover');
            }, false);
        });

        // Drop file event
        zone.addEventListener('drop', (e) => {
            const dt = e.dataTransfer;
            const files = dt.files;

            if (files && files[0]) {
                input.files = files;
                preview.textContent = files[0].name;
                preview.style.display = 'inline-block';
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        setupDragAndDropZone('uploadDragDropZone', 'materialFile', 'uploadFileNamePreview');
        setupDragAndDropZone('editDragDropZone', 'editFile', 'editFileNamePreview');

        // Form Submission loading states
        const uploadForm = document.getElementById('uploadForm');
        if (uploadForm) {
            uploadForm.addEventListener('submit', function() {
                const btn = this.querySelector('button[type="submit"]');
                if (btn) {
                    btn.disabled = true;
                    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Publishing...';
                }
            });
        }

        const editForm = document.getElementById('editMaterialForm');
        if (editForm) {
            editForm.addEventListener('submit', function() {
                const btn = this.querySelector('button[type="submit"]');
                if (btn) {
                    btn.disabled = true;
                    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
                }
            });
        }

        // URL Query parameter Success Toast alert trigger
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('success')) {
            const successType = urlParams.get('success');
            let message = "Action completed successfully!";
            if (successType === 'created') message = "New material published successfully!";
            if (successType === 'updated') message = "Material updated successfully!";
            if (successType === 'deleted') message = "Material deleted successfully!";
            if (successType === 'restored') message = "Material restored successfully!";
            
            showSuccessToast(message);
            // Clean URL query params to avoid repeating toast on refresh
            window.history.replaceState({}, document.title, window.location.pathname + window.location.hash);
        }
    });

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
