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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/InstructorAssessment.module.css?v=6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-workspace-modern.css?v=1">
    <script defer src="${pageContext.request.contextPath}/js/instructor-course-workspace.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme-toggle.css">
    <script defer src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
    <script defer src="${pageContext.request.contextPath}/js/instructor-shell.js"></script>
    <!-- Lucide Icons UMD -->
    
    <!-- React & Babel for Workspace SPA -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    `n    
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    
    <style>
    /* ==========================================================================
       Premium UI Redesign — CSS Module Namespace (ins_ws_)
       ========================================================================== */
    .ins_ws_page_head {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin-top: 1rem;
        margin-bottom: 1.5rem;
    }
    .ins_ws_page_head h2 {
        font-size: 2.25rem !important;
        font-weight: 800 !important;
        color: #0f172a !important;
        margin: 0 !important;
        letter-spacing: -0.03em !important;
    }
    :root[data-theme="dark"] .ins_ws_page_head h2 {
        color: #ffffff !important;
    }

    /* Tabs Navigation Bar */
    .ins_ws_nav_bar {
        display: flex;
        gap: 2rem;
        align-items: center;
        background: transparent !important;
        border: none !important;
        border-bottom: 1px solid #e2e8f0 !important;
        border-radius: 0 !important;
        padding: 0 0 12px 0 !important;
        box-shadow: none !important;
        backdrop-filter: none !important;
        margin-bottom: 2rem !important;
        overflow-x: auto;
    }
    :root[data-theme="dark"] .ins_ws_nav_bar {
        border-bottom-color: rgba(255, 255, 255, 0.1) !important;
    }

    .ins_ws_nav_link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: #64748b !important;
        font-weight: 600 !important;
        font-size: 0.95rem !important;
        text-decoration: none !important;
        padding: 4px 8px 12px 8px !important;
        transition: all 0.2s ease !important;
        border-bottom: 2px solid transparent !important;
        margin-bottom: -14px !important;
        background: transparent !important;
        border-radius: 0 !important;
    }
    .ins_ws_nav_link svg, 
    .ins_ws_nav_link i {
        width: 16px;
        height: 16px;
        color: currentColor;
    }
    .ins_ws_nav_link:hover {
        color: #0f172a !important;
        background: transparent !important;
    }
    :root[data-theme="dark"] .ins_ws_nav_link:hover {
        color: #ffffff !important;
    }
    .ins_ws_nav_link.active {
        color: #6366f1 !important;
        border-bottom-color: #6366f1 !important;
        font-weight: 700 !important;
        background: transparent !important;
    }

    /* Metadata pills */
    .ins_ws_meta_chips {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-bottom: 20px;
    }
    .ins_ws_meta_pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background-color: #f1f5f9 !important;
        padding: 6px 14px !important;
        border-radius: 9999px !important;
        font-size: 0.8rem !important;
        color: #334155 !important;
        font-weight: 600 !important;
        border: none !important;
        box-shadow: none !important;
    }
    .ins_ws_meta_pill svg, 
    .ins_ws_meta_pill i {
        color: #64748b !important;
        width: 14px;
        height: 14px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }
    :root[data-theme="dark"] .ins_ws_meta_pill {
        background-color: #1e293b !important;
        color: #cbd5e1 !important;
    }
    :root[data-theme="dark"] .ins_ws_meta_pill svg,
    :root[data-theme="dark"] .ins_ws_meta_pill i {
        color: #94a3b8 !important;
    }

    /* Description */
    .ins_ws_desc {
        color: #475569 !important;
        font-size: 0.95rem !important;
        line-height: 1.65 !important;
        margin: 0 !important;
        max-width: 850px;
    }
    :root[data-theme="dark"] .ins_ws_desc {
        color: #94a3b8 !important;
    }

    /* KPI Grid */
    .ins_ws_kpi_grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)) !important;
        gap: 1.5rem !important;
        margin-top: 2rem !important;
        margin-bottom: 2.5rem !important;
    }
    .ins_ws_kpi_card {
        background: #ffffff !important;
        border: 1px solid #e2e8f0 !important;
        border-left: none !important; /* completely clear chunk legacy border */
        border-radius: 12px !important;
        padding: 24px !important;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 20px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05) !important;
        transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1) !important;
        box-sizing: border-box;
    }
    .ins_ws_kpi_card:hover {
        transform: translateY(-2px) !important;
        box-shadow: 0 8px 24px rgba(15, 23, 42, 0.05) !important;
        border-color: #cbd5e1 !important;
    }
    :root[data-theme="dark"] .ins_ws_kpi_card {
        background: #111827 !important;
        border-color: rgba(255, 255, 255, 0.08) !important;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2) !important;
    }
    :root[data-theme="dark"] .ins_ws_kpi_card:hover {
        border-color: rgba(255, 255, 255, 0.15) !important;
    }

    .ins_ws_kpi_icon {
        width: 44px;
        height: 44px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.15rem;
        flex-shrink: 0;
    }
    .ins_ws_kpi_icon svg,
    .ins_ws_kpi_icon i {
        width: 20px;
        height: 20px;
    }
    .ins_ws_kpi_icon.students { background: rgba(99, 102, 241, 0.08) !important; color: #6366f1 !important; }
    .ins_ws_kpi_icon.materials { background: rgba(16, 185, 129, 0.08) !important; color: #10b981 !important; }
    .ins_ws_kpi_icon.assessments { background: rgba(59, 130, 246, 0.08) !important; color: #3b82f6 !important; }
    .ins_ws_kpi_icon.pending { background: rgba(239, 68, 68, 0.08) !important; color: #ef4444 !important; }

    .ins_ws_kpi_data {
        display: flex;
        flex-direction: column;
        gap: 6px;
        align-items: flex-start;
        text-align: left;
    }
    .ins_ws_kpi_data strong {
        font-size: 2rem !important;
        font-weight: 800 !important;
        color: #0f172a !important;
        line-height: 1 !important;
    }
    .ins_ws_kpi_data span {
        font-size: 0.72rem !important;
        color: #64748b !important;
        text-transform: uppercase !important;
        font-weight: 700 !important;
        letter-spacing: 0.05em !important;
    }
    :root[data-theme="dark"] .ins_ws_kpi_data strong {
        color: #ffffff !important;
    }
    :root[data-theme="dark"] .ins_ws_kpi_data span {
        color: #94a3b8 !important;
    }

    /* Quick Actions */
    .ins_ws_actions_sec {
        border-top: 1px solid #e2e8f0 !important;
        padding-top: 2rem !important;
    }
    :root[data-theme="dark"] .ins_ws_actions_sec {
        border-top-color: rgba(255, 255, 255, 0.08) !important;
    }
    .ins_ws_actions_title {
        margin: 0 0 1.25rem 0 !important;
        font-size: 1.2rem !important;
        font-weight: 700 !important;
        color: #0f172a !important;
    }
    :root[data-theme="dark"] .ins_ws_actions_title {
        color: #ffffff !important;
    }

    .ins_ws_actions_grid {
        display: flex;
        flex-wrap: wrap;
        gap: 14px;
    }
    .ins_ws_action_btn {
        background-color: #ffffff !important;
        border: 1px solid #cbd5e1 !important;
        border-radius: 9999px !important; /* pill shape button */
        padding: 10px 24px !important;
        font-size: 0.88rem !important;
        font-weight: 600 !important;
        color: #334155 !important;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        transition: all 0.2s ease;
        cursor: pointer;
        outline: none;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02) !important;
    }
    .ins_ws_action_btn svg,
    .ins_ws_action_btn i {
        width: 15px;
        height: 15px;
        color: #475569;
    }
    .ins_ws_action_btn:hover {
        background-color: #6366f1 !important;
        color: #ffffff !important;
        border-color: #6366f1 !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2) !important;
    }
    .ins_ws_action_btn:hover svg,
    .ins_ws_action_btn:hover i {
        color: #ffffff !important;
    }
    :root[data-theme="dark"] .ins_ws_action_btn {
        background-color: #1f2937 !important;
        border-color: rgba(255, 255, 255, 0.1) !important;
        color: #cbd5e1 !important;
    }
    :root[data-theme="dark"] .ins_ws_action_btn:hover {
        background-color: #6366f1 !important;
        color: #ffffff !important;
        border-color: #6366f1 !important;
    }

    :root {
        --ws-primary: #6366f1;
        --ws-primary-glow: rgba(99, 102, 241, 0.15);
        --ws-success: #10b981;
        --ws-warning: #f59e0b;
        --ws-danger: #ef4444;
        --ws-border-glass: rgba(226, 232, 240, 0.8);
        --ws-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
        --ws-shadow-hover: 0 20px 40px rgba(15, 23, 42, 0.08);
    }

    [data-theme="dark"] {
        --ws-border-glass: rgba(71, 85, 105, 0.5);
        --ws-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        --ws-shadow-hover: 0 20px 40px rgba(0, 0, 0, 0.3);
    }

    body.instructor-ui {
        background-color: #f8fafc !important;
    }

    /* Enforce strict single column layout centered container */
    .course-workspace-page {
        max-width: 1400px !important;
        margin: 0 auto !important;
        padding: 2rem !important;
        display: flex;
        flex-direction: column;
        gap: 1.5rem;
    }

    /* Minimalist Course Header */
    .ws-page-head-slim {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin-bottom: 0.5rem !important;
        display: flex;
        flex-direction: column;
        align-items: flex-start !important;
        text-align: left !important;
        gap: 0.75rem;
    }

    .ws-head-left-slim {
        display: flex;
        align-items: flex-start !important;
        justify-content: flex-start !important;
        flex-wrap: wrap;
        text-align: left !important;
        gap: 1rem;
        width: 100%;
    }

    .ws-head-left-slim h2 {
        font-size: 2rem !important;
        font-weight: 700 !important;
        color: #0f172a !important;
        margin: 0 !important;
        line-height: 1.25;
        text-align: left !important;
    }

    .status-badge {
        border-radius: 9999px !important;
        padding: 4px 12px !important;
        font-size: 0.75rem !important;
        font-weight: 600 !important;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .status-badge.status-active,
    .status-badge.status-published,
    .status-badge.status-Published {
        background-color: hsla(142, 72%, 29%, 0.1) !important;
        color: hsl(142, 72%, 29%) !important;
    }

    .status-badge.status-draft,
    .status-badge.status-Draft {
        background-color: hsla(38, 92%, 38%, 0.1) !important;
        color: hsl(38, 92%, 38%) !important;
    }



    /* High-fidelity Content Canvas */
    .ws-tab-content {
        display: none !important;
        opacity: 0;
        transform: translateY(12px);
        background: #ffffff !important;
        border-radius: 12px !important;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05) !important;
        padding: 32px !important;
        border: none !important;
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

    /* Clean up nested section-card to sits natively inside Content Canvas */
    .ws-tab-content .section-card {
        padding: 0 !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        border-radius: 0 !important;
    }

    /* Overview Dashboard Styles */
    .overview-top-section {
        margin-bottom: 24px;
    }

    .overview-meta-chips {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-bottom: 16px;
    }

    .meta-badge-chip {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background-color: #f1f5f9;
        padding: 6px 12px;
        border-radius: 8px;
        font-size: 0.85rem;
        color: #475569;
        font-weight: 500;
    }

    .meta-badge-chip i {
        color: var(--ws-primary);
    }

    .overview-course-desc {
        color: #475569;
        font-size: 0.975rem;
        line-height: 1.6;
        margin: 0;
        max-width: 800px;
    }

    /* Course KPIs grid on Overview Tab */
    .overview-kpis-grid-modern {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 1.5rem;
        margin-bottom: 32px;
    }

    .kpi-card-modern {
        background: #ffffff;
        border: 1px solid #f1f5f9;
        border-radius: 12px;
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 16px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .kpi-card-modern:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.04);
    }

    .kpi-icon-wrapper {
        width: 48px;
        height: 48px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        flex-shrink: 0;
    }

    .kpi-icon-wrapper.students { background: rgba(99, 102, 241, 0.08); color: var(--ws-primary); }
    .kpi-icon-wrapper.materials { background: rgba(16, 185, 129, 0.08); color: #10b981; }
    .kpi-icon-wrapper.assessments { background: rgba(59, 130, 246, 0.08); color: #3b82f6; }
    .kpi-icon-wrapper.pending { background: rgba(239, 68, 68, 0.08); color: #ef4444; }

    .kpi-data-wrapper {
        display: flex;
        flex-direction: column;
    }

    .kpi-data-wrapper strong {
        font-size: 1.75rem;
        font-weight: 700;
        color: #0f172a;
        line-height: 1.1;
    }

    .kpi-data-wrapper span {
        font-size: 0.75rem;
        color: #64748b;
        text-transform: uppercase;
        font-weight: 600;
        letter-spacing: 0.05em;
        margin-top: 4px;
    }

    /* Quick Actions */
    .overview-actions-section {
        border-top: 1px solid #f1f5f9;
        padding-top: 24px;
    }

    .overview-actions-section h3 {
        margin: 0 0 16px;
        font-size: 1.1rem;
        font-weight: 700;
        color: #0f172a;
    }

    .overview-actions-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
    }

    .action-pill-btn {
        background-color: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 9999px;
        padding: 10px 20px;
        font-size: 0.9rem;
        font-weight: 600;
        color: #334155;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        transition: all 0.2s ease;
        cursor: pointer;
    }

    .action-pill-btn:hover {
        background-color: var(--ws-primary);
        color: #ffffff;
        border-color: var(--ws-primary);
        transform: translateY(-1px);
    }

    .action-pill-btn i {
        font-size: 0.9rem;
    }

    /* Materials curriculum structures */
    .premium-table-wrapper {
        background: #ffffff;
        border: 1px solid #f1f5f9;
        border-radius: 12px;
        overflow-x: auto;
        box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        margin-top: 16px;
    }

    .premium-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }

    .premium-table th {
        background: #fafafa;
        padding: 14px 20px;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #64748b;
        border-bottom: 1px solid #f1f5f9;
    }

    .premium-table td {
        padding: 16px 20px;
        border-bottom: 1px solid #f1f5f9;
        color: #334155;
        font-size: 0.9rem;
        vertical-align: middle;
    }

    .premium-table tbody tr:last-child td {
        border-bottom: none;
    }

    .premium-table tr {
        transition: background-color 0.2s ease;
    }

    .premium-table tbody tr:hover {
        background-color: #fafafa;
    }

    .material-name-block {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .material-avatar {
        width: 40px;
        height: 40px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.15rem;
        flex-shrink: 0;
    }

    .material-avatar.type-pdf { background: rgba(239, 68, 68, 0.08); color: #ef4444; }
    .material-avatar.type-video { background: rgba(59, 130, 246, 0.08); color: #3b82f6; }
    .material-avatar.type-slides { background: rgba(245, 158, 11, 0.08); color: #f59e0b; }
    .material-avatar.type-link { background: rgba(16, 185, 129, 0.08); color: #10b981; }
    .material-avatar.type-youtube { background: rgba(220, 38, 38, 0.08); color: #dc2626; }

    .material-title {
        font-size: 0.925rem;
        font-weight: 600;
        color: #0f172a;
    }

    .material-desc {
        font-size: 0.8rem;
        color: #64748b;
        margin: 2px 0 0;
        line-height: 1.4;
    }

    .type-badge {
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 0.7rem;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        text-transform: uppercase;
        letter-spacing: 0.02em;
    }

    .badge-pdf { background: rgba(239, 68, 68, 0.08); color: #ef4444; }
    .badge-video { background: rgba(59, 130, 246, 0.08); color: #3b82f6; }
    .badge-slides { background: rgba(245, 158, 11, 0.08); color: #f59e0b; }
    .badge-link { background: rgba(16, 185, 129, 0.08); color: #10b981; }
    .badge-youtube { background: rgba(220, 38, 38, 0.08); color: #dc2626; }

    /* Assessments Grid */
    .assessments-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 1.5rem;
        margin-top: 16px;
    }

    .assessment-card {
        background: #ffffff;
        border: 1px solid #f1f5f9;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        display: flex;
        flex-direction: column;
        gap: 14px;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .assessment-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.04);
        border-color: #e2e8f0;
    }

    .assessment-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .assessment-icon-circle {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
    }

    .assessment-icon-circle.quiz { background: rgba(99, 102, 241, 0.08); color: var(--ws-primary); }
    .assessment-icon-circle.exam { background: rgba(239, 68, 68, 0.08); color: #ef4444; }
    .assessment-icon-circle.assignment { background: rgba(16, 185, 129, 0.08); color: #10b981; }

    .assessment-title {
        font-size: 1rem;
        font-weight: 600;
        color: #0f172a;
        margin: 0;
    }

    .assessment-desc {
        font-size: 0.8rem;
        color: #64748b;
        line-height: 1.45;
        margin: 0;
    }

    .assessment-stats-row {
        display: flex;
        gap: 10px;
        margin-top: auto;
    }

    .stat-bubble {
        flex: 1;
        background: #f8fafc;
        border: 1px solid #f1f5f9;
        border-radius: 8px;
        padding: 6px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 2px;
    }

    .stat-num {
        font-size: 0.95rem;
        font-weight: 700;
        color: #0f172a;
    }

    .stat-lbl {
        font-size: 0.6rem;
        color: #64748b;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.02em;
    }

    .assessment-actions {
        display: flex;
        gap: 8px;
        margin-top: 4px;
    }

    /* Roster & Search */
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
        color: #64748b;
    }

    .search-input-wrap input {
        width: 100%;
        padding: 10px 16px 10px 38px;
        border: 1px solid #e2e8f0;
        background: #ffffff;
        border-radius: 8px;
        font-family: inherit;
        font-size: 0.88rem;
        outline: none;
        transition: all 0.2s ease;
    }

    .search-input-wrap input:focus {
        border-color: var(--ws-primary);
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
    }

    .ws-student-progress {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    /* Premium Slate Dark Theme Overrides */
    :root[data-theme="dark"] body.instructor-ui {
        background-color: #0b0f19 !important;
    }

    :root[data-theme="dark"] .ws-tab-content {
        background: #111827 !important;
        box-shadow: 0 4px 12px rgba(2, 6, 17, 0.3) !important;
    }

    :root[data-theme="dark"] .ws-head-left-slim h2 {
        color: #ffffff !important;
    }

    :root[data-theme="dark"] .meta-badge-chip {
        background-color: #1f2937;
        color: #9ca3af;
    }

    :root[data-theme="dark"] .overview-course-desc {
        color: #9ca3af;
    }

    :root[data-theme="dark"] .kpi-card-modern,
    :root[data-theme="dark"] .premium-table-wrapper,
    :root[data-theme="dark"] .assessment-card {
        background-color: #111827;
        border-color: rgba(255,255,255,0.05);
    }

    :root[data-theme="dark"] .kpi-data-wrapper strong,
    :root[data-theme="dark"] .premium-table td,
    :root[data-theme="dark"] .material-title,
    :root[data-theme="dark"] .assessment-title,
    :root[data-theme="dark"] .stat-num,
    :root[data-theme="dark"] .overview-actions-section h3 {
        color: #ffffff !important;
    }

    :root[data-theme="dark"] .premium-table th {
        background-color: #1f2937;
        color: #9ca3af;
        border-bottom-color: rgba(255,255,255,0.05);
    }

    :root[data-theme="dark"] .premium-table tbody tr:hover {
        background-color: #1f2937;
    }

    :root[data-theme="dark"] .stat-bubble {
        background: #111827;
        border-color: rgba(255,255,255,0.05);
    }

    :root[data-theme="dark"] .action-pill-btn {
        background-color: #111827;
        border-color: rgba(255,255,255,0.05);
        color: #cbd5e1;
    }

    :root[data-theme="dark"] .action-pill-btn:hover {
        background-color: var(--ws-primary);
        color: #ffffff;
        border-color: var(--ws-primary);
    }

    .ws-back-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background-color: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 0.85rem;
        font-weight: 600;
        color: #475569;
        text-decoration: none;
        transition: all 0.2s ease;
        cursor: pointer;
        align-self: flex-start;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
    }

    .ws-back-btn:hover {
        background-color: #f1f5f9;
        color: #0f172a;
        border-color: #cbd5e1;
        transform: translateX(-2px);
    }

    :root[data-theme="dark"] .ws-back-btn {
        background-color: #111827;
        border-color: rgba(255, 255, 255, 0.05);
        color: #cbd5e1;
    }

    :root[data-theme="dark"] .ws-back-btn:hover {
        background-color: #1f2937;
        color: #ffffff;
        border-color: rgba(255, 255, 255, 0.1);
    }

    /* ==========================================================================
       Premium Materials & Modal Redesign Styles
       ========================================================================== */

    /* Premium Buttons replacement for legacy Bootstrap */
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

    .ws-btn-primary:active {
        transform: translateY(0);
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

    .ws-btn-danger {
        background-color: rgba(239, 68, 68, 0.08);
        border-color: transparent;
        color: #ef4444;
    }

    .ws-btn-danger:hover {
        background-color: #ef4444;
        color: #ffffff;
    }

    .ws-btn-sm {
        padding: 6px 12px;
        font-size: 0.8rem;
        border-radius: 6px;
    }

    .ws-btn-xs {
        padding: 4px 8px;
        font-size: 0.75rem;
        border-radius: 4px;
    }

    /* Dark Mode Buttons */
    :root[data-theme="dark"] .ws-btn-secondary {
        background-color: #1f2937;
        border-color: rgba(255, 255, 255, 0.08);
        color: #cbd5e1;
    }

    :root[data-theme="dark"] .ws-btn-secondary:hover {
        background-color: #111827;
        color: #ffffff;
        border-color: rgba(255, 255, 255, 0.15);
    }

    /* Materials Sleek List Layout */
    .pm-materials-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-top: 16px;
    }

    .pm-material-card {
        background: #ffffff;
        border: 1px solid #f1f5f9;
        border-radius: 12px;
        padding: 16px 20px;
        display: flex;
        align-items: center;
        gap: 16px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        position: relative;
        user-select: none;
    }

    .pm-material-card:hover {
        border-color: #e2e8f0;
        box-shadow: 0 6px 12px -2px rgba(0, 0, 0, 0.06);
    }

    /* Drag Handle Style */
    .pm-material-drag-handle {
        color: #94a3b8;
        cursor: grab;
        padding: 6px;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
    }

    .pm-material-drag-handle:hover {
        color: #475569;
        background: #f1f5f9;
    }

    .pm-material-drag-handle:active {
        cursor: grabbing;
    }

    /* Active Drag State */
    .pm-material-card.dragging {
        opacity: 0.6;
        transform: scale(1.02);
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
        border-color: var(--ws-primary, #6366f1) !important;
        background-color: #fafafa;
    }

    .pm-material-card.drag-over {
        border-top: 3px solid var(--ws-primary, #6366f1);
    }

    /* Type-colored Icons styling */
    .pm-material-type-icon {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        flex-shrink: 0;
        transition: all 0.2s ease;
    }

    .pm-material-type-icon.type-pdf { background: rgba(239, 68, 68, 0.08); color: #ef4444; }
    .pm-material-type-icon.type-video { background: rgba(59, 130, 246, 0.08); color: #3b82f6; }
    .pm-material-type-icon.type-slides { background: rgba(245, 158, 11, 0.08); color: #f59e0b; }
    .pm-material-type-icon.type-link { background: rgba(16, 185, 129, 0.08); color: #10b981; }
    .pm-material-type-icon.type-youtube { background: rgba(220, 38, 38, 0.08); color: #dc2626; }

    .pm-material-details {
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .pm-material-title-row {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }

    .pm-material-title {
        font-size: 0.95rem;
        font-weight: 600;
        color: #0f172a;
    }

    .pm-material-desc {
        font-size: 0.825rem;
        color: #64748b;
        margin: 0;
        line-height: 1.4;
    }

    .pm-material-meta {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-top: 4px;
        flex-wrap: wrap;
    }

    .pm-material-meta-item {
        font-size: 0.75rem;
        color: #94a3b8;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }

    .pm-material-actions {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
    }

    /* Dark mode overrides for Materials list */
    :root[data-theme="dark"] .pm-material-card {
        background-color: #111827;
        border-color: rgba(255, 255, 255, 0.05);
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.2);
    }

    :root[data-theme="dark"] .pm-material-card:hover {
        border-color: rgba(255, 255, 255, 0.1);
    }

    :root[data-theme="dark"] .pm-material-title {
        color: #ffffff;
    }

    :root[data-theme="dark"] .pm-material-desc {
        color: #9ca3af;
    }

    :root[data-theme="dark"] .pm-material-drag-handle:hover {
        color: #cbd5e1;
        background: #1f2937;
    }

    /* Premium centered modal styling */
    .modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: rgba(15, 23, 42, 0.4) !important;
        backdrop-filter: blur(4px) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
        z-index: 2000 !important;
    }

    .modal.show {
        opacity: 1 !important;
        pointer-events: auto !important;
    }

    .modal-content {
        background: #ffffff !important;
        max-width: 600px !important;
        width: 90% !important;
        border-radius: 16px !important;
        box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.15) !important;
        border: 1px solid #f1f5f9 !important;
        overflow: hidden;
        transform: translateY(24px) scale(0.98);
        transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
        display: flex;
        flex-direction: column;
        padding: 0 !important;
    }

    .modal.show .modal-content {
        transform: translateY(0) scale(1) !important;
    }

    .modal-header {
        background: #ffffff !important;
        border-bottom: 1px solid #f1f5f9 !important;
        padding: 20px 32px !important;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .modal-header h3 {
        font-size: 1.25rem !important;
        font-weight: 700 !important;
        color: #0f172a !important;
        margin: 0 !important;
    }

    .modal-close {
        color: #94a3b8 !important;
        background: transparent;
        border: none;
        font-size: 1.2rem;
        cursor: pointer;
        padding: 4px;
        border-radius: 6px;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .modal-close:hover {
        color: #475569 !important;
        background: #f1f5f9;
    }

    .modal-body {
        padding: 32px !important;
        overflow-y: auto;
        max-height: calc(100vh - 160px);
    }

    /* Modern dashed upload dropzone */
    .modern-drag-drop-zone {
        border: 2px dashed #cbd5e1;
        background: #f8fafc;
        border-radius: 10px;
        padding: 36px 20px;
        text-align: center;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
    }

    .modern-drag-drop-zone:hover {
        border-color: var(--ws-primary, #6366f1);
        background: rgba(99, 102, 241, 0.02);
    }

    .modern-drag-drop-zone.dragover {
        border-color: var(--ws-primary, #6366f1);
        background: rgba(99, 102, 241, 0.06);
        transform: scale(1.01);
    }

    .modern-drag-drop-zone .upload-icon {
        font-size: 2.2rem;
        color: #94a3b8;
        transition: color 0.2s ease;
    }

    .modern-drag-drop-zone:hover .upload-icon {
        color: var(--ws-primary, #6366f1);
    }

    .drag-drop-text {
        font-size: 0.875rem;
        font-weight: 500;
        color: #475569;
        margin: 0;
    }

    .file-name-preview {
        font-size: 0.8rem;
        font-weight: 600;
        color: var(--ws-primary, #6366f1);
        background: rgba(99, 102, 241, 0.06);
        padding: 4px 12px;
        border-radius: 20px;
        border: 1px solid rgba(99, 102, 241, 0.1);
        display: inline-block;
        word-break: break-all;
    }

    /* Custom premium inputs in modal form */
    .upload-form-grid .field label {
        font-size: 0.825rem !important;
        font-weight: 600 !important;
        color: #475569 !important;
    }

    .upload-form-grid .field input[type="text"],
    .upload-form-grid .field input[type="number"],
    .upload-form-grid .field input[type="url"],
    .upload-form-grid .field select,
    .upload-form-grid .field textarea {
        border: 1px solid #cbd5e1 !important;
        border-radius: 8px !important;
        padding: 11px 14px !important;
        font-size: 0.9rem !important;
        color: #0f172a !important;
        background-color: #ffffff !important;
        outline: none !important;
        transition: all 0.2s ease !important;
        box-shadow: 0 1px 2px rgba(0,0,0,0.02) !important;
    }

    .upload-form-grid .field input:focus,
    .upload-form-grid .field select:focus,
    .upload-form-grid .field textarea:focus {
        border-color: var(--ws-primary, #6366f1) !important;
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12) !important;
    }

    /* Modal Dark Mode overrides */
    :root[data-theme="dark"] .modal-content {
        background-color: #111827 !important;
        border-color: rgba(255, 255, 255, 0.05) !important;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5) !important;
    }

    :root[data-theme="dark"] .modal-header {
        background-color: #111827 !important;
        border-bottom-color: rgba(255, 255, 255, 0.05) !important;
    }

    :root[data-theme="dark"] .modal-header h3 {
        color: #ffffff !important;
    }

    :root[data-theme="dark"] .modal-close:hover {
        background: #1f2937;
        color: #ffffff !important;
    }

    :root[data-theme="dark"] .modern-drag-drop-zone {
        border-color: rgba(255, 255, 255, 0.15);
        background: #1f2937;
    }

    :root[data-theme="dark"] .drag-drop-text {
        color: #9ca3af;
    }

    :root[data-theme="dark"] .upload-form-grid .field label {
        color: #9ca3af !important;
    }

    :root[data-theme="dark"] .upload-form-grid .field input[type="text"],
    :root[data-theme="dark"] .upload-form-grid .field input[type="number"],
    :root[data-theme="dark"] .upload-form-grid .field input[type="url"],
    :root[data-theme="dark"] .upload-form-grid .field select,
    :root[data-theme="dark"] .upload-form-grid .field textarea {
        background-color: #1f2937 !important;
        border-color: rgba(255, 255, 255, 0.1) !important;
        color: #ffffff !important;
    }

    :root[data-theme="dark"] .upload-form-grid .field input:focus,
    :root[data-theme="dark"] .upload-form-grid .field select:focus,
    :root[data-theme="dark"] .upload-form-grid .field textarea:focus {
        border-color: var(--ws-primary, #6366f1) !important;
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2) !important;
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
        <section class="ins_ws_page_head">
            <h2><c:out value="${selectedCourse.courseName}"/></h2>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error" style="margin-bottom: 24px;"><i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/></div>
        </c:if>

        <c:url var="assessmentWorkspaceBaseUrl" value="/instructor/assessments">
            <c:param name="courseId" value="${selectedCourse.courseId}"/>
        </c:url>


        <c:url var="assessmentWorkspaceBaseUrl" value="/instructor/assessments">
            <c:param name="courseId" value="${selectedCourse.courseId}"/>
        </c:url>

        <!-- Scoped React Sandbox Root -->
        <div id="workspace-react-root"></div>

        <!-- Serialize JSTL properties to window state for React execution -->
        <div id="workspace-data-json" style="display:none;" data-json="<c:out value='${workspaceDataJsonStr}' escapeXml='true'/>"></div>
        <script>
            // Safely parse JSON from data attribute to prevent backtick/quote injection syntax errors
            const rawJson = document.getElementById('workspace-data-json').getAttribute('data-json');
            
            // Check if backend Java servlet hot-reload failed
            if (!rawJson || rawJson.trim() === '') {
                console.error("Backend data missing! Tomcat may need a restart to load the new Servlet class.");
            }
            
            window.__WORKSPACE_DATA__ = JSON.parse(rawJson || '{}');
        </script>

        <!-- Load interactive workspace react application -->
        
    <script type="module" src="${pageContext.request.contextPath}/js/dist/course-workspace.js"></script>

<!-- Upload Material Modal -->
<div id="uploadModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Upload New Material</h3>
            <button class="modal-close" onclick="closeUploadModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p class="modal-subtitle" style="margin-top: 0; margin-bottom: 20px; font-size: 0.9rem; color: var(--ins-muted);">Course: <strong style="color: var(--ins-heading);"><c:out value="${selectedCourse.courseName}"/></strong></p>
            <form id="uploadForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                <input type="hidden" name="source" value="workspace">
                <div class="upload-form-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label>Title *</label>
                        <input type="text" name="title" required placeholder="Enter module block title">
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label>Type *</label>
                        <select name="materialType" id="materialType" required>
                            <option value="">Select type</option>
                            <option value="PDF">PDF Document</option>
                            <option value="Video">Video File</option>
                            <option value="Slides">Slides Presentation</option>
                            <option value="Link">External Web Link</option>
                            <option value="YouTube">YouTube Embed Video</option>
                        </select>
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label>Chapter / Sequence Order</label>
                        <input type="number" name="displayOrder" min="1" placeholder="Auto-sequence if blank">
                    </div>
                    <div class="field" id="fileFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label>Upload Attachment File</label>
                        <input type="file" name="materialFile" id="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3" style="opacity: 0.01; position: absolute; width: 1px; height: 1px;">
                        <div class="modern-drag-drop-zone" id="uploadDragDropZone">
                            <i class="fas fa-cloud-upload-alt upload-icon"></i>
                            <p class="drag-drop-text">Click or drag file here to upload</p>
                            <span class="file-name-preview" id="uploadFileNamePreview" style="display: none;"></span>
                        </div>
                    </div>
                    <div class="field" id="urlFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2; display: none;">
                        <label>Material URL / Embed Link</label>
                        <input type="url" name="externalUrl" id="externalUrl" placeholder="https://...">
                    </div>
                    <div class="field full" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label>Curriculum Description</label>
                        <textarea name="description" rows="3" placeholder="Provide an overview of the curriculum content..."></textarea>
                    </div>
                </div>
                <div class="modal-footer" style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--ws-border-glass); display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" class="ws-btn ws-btn-secondary" onclick="closeUploadModal()">Cancel</button>
                    <button type="submit" class="ws-btn ws-btn-primary"><i class="fas fa-upload"></i> Publish Material</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Material Modal -->
<div id="editMaterialModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Edit Course Material</h3>
            <button class="modal-close" onclick="closeEditMaterialModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p class="modal-subtitle" style="margin-top: 0; margin-bottom: 20px; font-size: 0.9rem; color: var(--ins-muted);">Course: <strong style="color: var(--ins-heading);"><c:out value="${selectedCourse.courseName}"/></strong></p>
            <form id="editMaterialForm" method="post" action="${pageContext.request.contextPath}/instructor/materials" enctype="multipart/form-data">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="materialId" id="editMaterialId">
                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                <input type="hidden" name="source" value="workspace">
                <div class="upload-form-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label>Title *</label>
                        <input id="editTitle" type="text" name="title" required placeholder="Enter module block title">
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label>Type *</label>
                        <select id="editType" name="materialType" required>
                            <option value="PDF">PDF Document</option>
                            <option value="Video">Video File</option>
                            <option value="Slides">Slides Presentation</option>
                            <option value="Link">External Web Link</option>
                            <option value="YouTube">YouTube Embed Video</option>
                        </select>
                    </div>
                    <div class="field" style="display: flex; flex-direction: column; gap: 6px;">
                        <label>Chapter / Sequence Order</label>
                        <input id="editOrder" type="number" name="displayOrder" min="1" placeholder="Auto-sequence if blank">
                    </div>
                    <div class="field" id="editFileFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label>Replace Attachment File</label>
                        <input id="editFile" type="file" name="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3" style="display: none;">
                        <div class="modern-drag-drop-zone" id="editDragDropZone">
                            <i class="fas fa-cloud-upload-alt upload-icon"></i>
                            <p class="drag-drop-text">Click or drag file here to replace</p>
                            <span class="file-name-preview" id="editFileNamePreview" style="display: none;"></span>
                        </div>
                    </div>
                    <div class="field" id="editUrlFieldContainer" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2; display: none;">
                        <label>Material URL / Embed Link</label>
                        <input id="editExternalUrl" type="url" name="externalUrl" placeholder="https://...">
                    </div>
                    <div class="field full" style="display: flex; flex-direction: column; gap: 6px; grid-column: span 2;">
                        <label>Curriculum Description</label>
                        <textarea id="editDescription" name="description" rows="3" placeholder="Provide an overview of the curriculum content..."></textarea>
                    </div>
                </div>
                <div class="modal-footer" style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--ws-border-glass); display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" class="ws-btn ws-btn-secondary" onclick="closeEditMaterialModal()">Cancel</button>
                    <button type="submit" class="ws-btn ws-btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // (Legacy Vanilla JS tab sync removed to prevent conflicts with React)

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

    // Workspace Materials Drag and Drop reordering
    let workspaceDraggedElement = null;

    function initializeWorkspaceDragAndDrop() {
        const container = document.getElementById('materialsContainer');
        if (!container) return;

        const cards = container.querySelectorAll('.pm-material-card');
        cards.forEach(card => {
            card.addEventListener('dragstart', handleWorkspaceDragStart);
            card.addEventListener('dragend', handleWorkspaceDragEnd);
            card.addEventListener('dragover', handleWorkspaceDragOver);
            card.addEventListener('dragenter', handleWorkspaceDragEnter);
            card.addEventListener('dragleave', handleWorkspaceDragLeave);
            card.addEventListener('drop', handleWorkspaceDrop);
        });
    }

    function handleWorkspaceDragStart(e) {
        workspaceDraggedElement = this;
        this.classList.add('dragging');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/html', this.innerHTML);
    }

    function handleWorkspaceDragEnd() {
        this.classList.remove('dragging');
        const container = document.getElementById('materialsContainer');
        if (container) {
            container.querySelectorAll('.pm-material-card').forEach(card => {
                card.classList.remove('drag-over');
            });
        }
        workspaceDraggedElement = null;
    }

    function handleWorkspaceDragOver(e) {
        if (e.preventDefault) {
            e.preventDefault();
        }
        e.dataTransfer.dropEffect = 'move';
        return false;
    }

    function handleWorkspaceDragEnter() {
        if (workspaceDraggedElement !== this) {
            this.classList.add('drag-over');
        }
    }

    function handleWorkspaceDragLeave() {
        this.classList.remove('drag-over');
    }

    function handleWorkspaceDrop(e) {
        if (e.stopPropagation) {
            e.stopPropagation();
        }
        if (e.preventDefault) {
            e.preventDefault();
        }

        this.classList.remove('drag-over');

        if (!workspaceDraggedElement || workspaceDraggedElement === this) {
            return false;
        }

        const container = document.getElementById('materialsContainer');
        const allCards = Array.from(container.querySelectorAll('.pm-material-card'));
        const draggedIndex = allCards.indexOf(workspaceDraggedElement);
        const targetIndex = allCards.indexOf(this);

        if (draggedIndex < targetIndex) {
            this.parentNode.insertBefore(workspaceDraggedElement, this.nextSibling);
        } else {
            this.parentNode.insertBefore(workspaceDraggedElement, this);
        }

        // Enable "Save Order" button after drag action
        const saveBtn = document.getElementById('saveOrderBtn');
        if (saveBtn) {
            saveBtn.disabled = false;
            saveBtn.style.opacity = '1';
            saveBtn.style.cursor = 'pointer';
            saveBtn.classList.remove('ws-btn-secondary');
            saveBtn.classList.add('ws-btn-primary'); // Highlight it to invite saving!
        }

        return false;
    }

    function saveMaterialsOrder() {
        const container = document.getElementById('materialsContainer');
        if (!container) return;

        const cards = container.querySelectorAll('.pm-material-card');
        const materialIds = Array.from(cards).map(card => card.dataset.id);

        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/instructor/content-organizer';

        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'saveContentOrder';
        form.appendChild(actionInput);

        const courseIdInput = document.createElement('input');
        courseIdInput.type = 'hidden';
        courseIdInput.name = 'courseId';
        courseIdInput.value = '${selectedCourse.courseId}';
        form.appendChild(courseIdInput);

        materialIds.forEach(id => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'materialIds[]';
            input.value = id;
            form.appendChild(input);
        });

        // Add loading spinner status to button
        const saveBtn = document.getElementById('saveOrderBtn');
        if (saveBtn) {
            saveBtn.disabled = true;
            saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
        }

        document.body.appendChild(form);
        form.submit();
    }

    document.addEventListener("DOMContentLoaded", function() {
        setupDragAndDropZone('uploadDragDropZone', 'materialFile', 'uploadFileNamePreview');
        setupDragAndDropZone('editDragDropZone', 'editFile', 'editFileNamePreview');
        initializeWorkspaceDragAndDrop();

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
