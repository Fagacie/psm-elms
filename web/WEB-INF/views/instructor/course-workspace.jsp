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
    <script defer src="${pageContext.request.contextPath}/js/instructor-course-workspace.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme-toggle.css">
    <script defer src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
    <script defer src="${pageContext.request.contextPath}/js/instructor-shell.js"></script>
    
    <style>
    /* ==========================================================================
       Premium UI System — Course Workspace tabbed redesign
       ========================================================================== */

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
        <section class="ws-page-head-slim">
            <div class="ws-head-left-slim">
                <h2><c:out value="${selectedCourse.courseName}"/></h2>
            </div>
        </section>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error" style="margin-bottom: 24px;"><i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/></div>
        </c:if>

        <c:url var="assessmentWorkspaceBaseUrl" value="/instructor/assessments">
            <c:param name="courseId" value="${selectedCourse.courseId}"/>
        </c:url>

        <%-- WORKSPACE NAVIGATION --%>
        <nav class="ins-flow-nav" aria-label="Workspace navigation">
            <a class="ins-flow-link active" href="#overview" data-section-link="overview">
                <i class="fas fa-chart-pie"></i> Overview
            </a>
            <a class="ins-flow-link" href="#materials" data-section-link="materials">
                <i class="fas fa-book-open"></i> Materials
            </a>
            <a class="ins-flow-link" href="#assessments" data-section-link="assessments">
                <i class="fas fa-tasks"></i> Assessments
            </a>
            <a class="ins-flow-link" href="#students" data-section-link="students">
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
            <div class="section-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                    <h3 class="section-title" style="margin: 0; font-weight: 800; font-size: 1.25rem;">Course Curriculum Materials (${fn:length(materials)} items)</h3>
                    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                        <button class="ws-btn ws-btn-primary" onclick="openUploadModal()">
                            <i class="fas fa-upload"></i> Upload Material
                        </button>
                        <button id="saveOrderBtn" class="ws-btn ws-btn-secondary" onclick="saveMaterialsOrder()" disabled style="opacity: 0.5; cursor: not-allowed;">
                            <i class="fas fa-save"></i> Save Order
                        </button>
                        <a href="${pageContext.request.contextPath}/instructor/content-organizer?courseId=${selectedCourse.courseId}" class="ws-btn ws-btn-secondary">
                            <i class="fas fa-folder-open"></i> Full Organizer View
                        </a>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty materials}">
                        <div class="empty-state-box workspace-empty-box" style="padding: 40px; text-align: center;">
                            <i class="fas fa-folder-open" style="font-size: 3rem; color: var(--ins-muted); margin-bottom: 16px;"></i>
                            <p style="font-weight: 600; margin-bottom: 12px;">No active materials uploaded for this course yet.</p>
                            <button class="ws-btn ws-btn-primary ws-btn-sm" onclick="openUploadModal()">Upload First Material</button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="pm-materials-list" id="materialsContainer">
                            <c:forEach var="material" items="${materials}">
                                <div class="pm-material-card" draggable="true" data-id="${material.materialId}">
                                    <div class="pm-material-drag-handle" title="Drag to reorder">
                                        <i class="fas fa-grip-vertical"></i>
                                    </div>
                                    <div class="pm-material-type-icon type-${fn:toLowerCase(material.materialType)}">
                                        <i class="fas <c:choose>
                                            <c:when test="${material.materialType == 'PDF'}">fa-file-pdf</c:when>
                                            <c:when test="${material.materialType == 'Video'}">fa-file-video</c:when>
                                            <c:when test="${material.materialType == 'Slides'}">fa-file-powerpoint</c:when>
                                            <c:when test="${material.materialType == 'Link'}">fa-link</c:when>
                                            <c:when test="${material.materialType == 'YouTube'}">fa-play-circle</c:when>
                                            <c:otherwise>fa-file-alt</c:otherwise>
                                        </c:choose>"></i>
                                    </div>
                                    <div class="pm-material-details">
                                        <div class="pm-material-title-row">
                                            <span class="pm-material-title"><c:out value="${material.title}"/></span>
                                            <span class="type-badge badge-${fn:toLowerCase(material.materialType)}"><c:out value="${material.materialType}"/></span>
                                            <span style="font-weight: 700; font-size: 0.8rem; color: var(--ws-primary);">#${not empty material.displayOrder ? material.displayOrder : '-'}</span>
                                        </div>
                                        <p class="pm-material-desc"><c:out value="${material.description}" default="No description has been written for this module block."/></p>
                                    </div>
                                    <div class="pm-material-actions">
                                        <c:choose>
                                            <c:when test="${not empty material.filePath}">
                                                <a href="${pageContext.request.contextPath}/instructor/materials-preview?action=preview&id=${material.materialId}" target="_blank" class="ws-btn ws-btn-secondary ws-btn-xs" style="padding: 6px 10px;"><i class="fas fa-eye"></i> Preview</a>
                                            </c:when>
                                        </c:choose>
                                        <button class="ws-btn ws-btn-secondary ws-btn-xs" style="padding: 6px 10px;"
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
                                            <button type="submit" class="ws-btn ws-btn-danger ws-btn-xs" style="padding: 6px 10px; font-weight: 600;"><i class="fas fa-trash"></i> Delete</button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
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
                        <input type="file" name="materialFile" id="materialFile" accept=".pdf,.doc,.docx,.txt,.ppt,.pptx,.zip,.mp4,.webm,.mov,.m4v,.mp3" style="display: none;">
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
