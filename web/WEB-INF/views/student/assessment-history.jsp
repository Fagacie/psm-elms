<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Performance - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-module.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Course Performance"/>
<c:set var="topbarSubtitle" value="All assessments in one place with score and submission history"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="course"/>
<c:set var="navContextPage" value="assessments"/>
<c:set var="navCourseEnrollmentId" value="${enrollment.enrollmentId}"/>
<c:set var="navCourseTitle" value="${enrollment.courseName}"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}">Assessments</a>
            <span>/</span>
            <span>Performance</span>
        </div>

        <section class="sa-shell">
            <article class="sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: linear-gradient(135deg, var(--sv-surface) 0%, var(--sv-surface-soft) 100%); padding: 24px !important; margin-bottom: 20px;">
                <div style="display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; align-items: start;">
                    <div style="max-width: 760px;">
                        <span style="display: inline-flex; align-items: center; gap: 8px; padding: 6px 10px; border-radius: 999px; background: rgba(37, 99, 235, 0.08); color: #2563eb; font-weight: 700; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 12px;">
                            <i class="fas fa-chart-column"></i> Standalone performance view
                        </span>
                        <h2 style="margin: 0 0 8px; font-size: 1.6rem; font-weight: 800; letter-spacing: -0.03em; color: var(--sv-foreground);">${enrollment.courseName}</h2>
                        <p style="margin: 0; color: var(--sv-muted); line-height: 1.65;">This page brings every assessment in the course into one place so the student can compare attempts, best scores, and result status without opening each item separately.</p>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}" style="height: 40px; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px; font-size: 0.88rem;"><i class="fas fa-grid-2"></i> Assessment Dashboard</a>
                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments" style="height: 40px; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px; font-size: 0.88rem;"><i class="fas fa-layer-group"></i> Learning Hub</a>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-top: 18px;">
                    <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: var(--sv-surface-soft); padding: 16px;">
                        <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Assessments</span>
                        <strong style="font-size: 1.35rem; color: var(--sv-foreground);">${assessmentTotalCount}</strong>
                    </div>
                    <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(59, 130, 246, 0.06); padding: 16px;">
                        <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Attempted</span>
                        <strong style="font-size: 1.35rem; color: #2563eb;">${assessmentAttemptedCount}</strong>
                    </div>
                    <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(16, 185, 129, 0.06); padding: 16px;">
                        <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Graded</span>
                        <strong style="font-size: 1.35rem; color: #10b981;">${assessmentGradedCount}</strong>
                    </div>
                    <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(245, 158, 11, 0.08); padding: 16px;">
                        <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Average best score</span>
                        <strong style="font-size: 1.35rem; color: #d97706;">
                            <c:choose>
                                <c:when test="${not empty assessmentAverageBestScore}"><fmt:formatNumber value="${assessmentAverageBestScore}" maxFractionDigits="1"/></c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </strong>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; margin-top: 12px;">
                    <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(16, 185, 129, 0.06); padding: 16px;">
                        <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Highest performing assessment</span>
                        <strong style="display: block; font-size: 1.05rem; color: var(--sv-foreground); margin-bottom: 4px;">
                            <c:choose>
                                <c:when test="${not empty highestAssessmentSummary}">${highestAssessmentSummary.assessmentTitle}</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </strong>
                        <span style="color: #10b981; font-weight: 700;">
                            <c:choose>
                                <c:when test="${not empty highestAssessmentPercentage}"><fmt:formatNumber value="${highestAssessmentPercentage}" maxFractionDigits="1"/>%</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div style="border: 1px solid var(--sv-border); border-radius: 12px; background: rgba(239, 68, 68, 0.06); padding: 16px;">
                        <span style="display: block; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--sv-muted); margin-bottom: 6px;">Lowest performing assessment</span>
                        <strong style="display: block; font-size: 1.05rem; color: var(--sv-foreground); margin-bottom: 4px;">
                            <c:choose>
                                <c:when test="${not empty lowestAssessmentSummary}">${lowestAssessmentSummary.assessmentTitle}</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </strong>
                        <span style="color: #ef4444; font-weight: 700;">
                            <c:choose>
                                <c:when test="${not empty lowestAssessmentPercentage}"><fmt:formatNumber value="${lowestAssessmentPercentage}" maxFractionDigits="1"/>%</c:when>
                                <c:otherwise>--</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
            </article>

            <article class="sa-panel sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 24px !important;">
                <div class="sa-panel-head" style="display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 20px; flex-wrap: wrap;">
                    <div>
                        <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.02em;">Assessment Performance Table</h3>
                        <p style="margin: 6px 0 0; color: var(--sv-muted); font-size: 0.88rem;">Each row summarizes one assessment in the course.</p>
                    </div>
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}" style="height: 40px; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px; font-size: 0.88rem;"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                </div>

                <c:choose>
                    <c:when test="${empty assessmentSummaries}">
                        <div class="sa-empty">
                            <h3>No attempts yet</h3>
                            <p>Once you submit assessments, they will appear here.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="overflow-x: auto;">
                            <table style="width: 100%; border-collapse: collapse; min-width: 980px;">
                                <thead>
                                    <tr style="text-align: left; color: var(--sv-muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em;">
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Assessment</th>
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Attempts</th>
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Best Score</th>
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Best %</th>
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Mastery</th>
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Latest Submission</th>
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Status</th>
                                        <th style="padding: 14px 10px; border-bottom: 1px solid var(--sv-border);">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${assessmentSummaries}">
                                        <tr style="border-bottom: 1px solid var(--sv-border);">
                                            <td style="padding: 16px 10px; vertical-align: top;">
                                                <strong style="display: block; color: var(--sv-foreground);">${item.assessmentTitle}</strong>
                                                <span style="display: block; margin-top: 4px; color: var(--sv-muted); font-size: 0.82rem;">${item.assessmentType}</span>
                                            </td>
                                            <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap; color: var(--sv-foreground); font-weight: 600;">${item.usedAttempts} / ${item.allowedAttempts}</td>
                                            <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap; color: var(--sv-foreground); font-weight: 600;">
                                                <c:choose>
                                                    <c:when test="${not empty item.bestScore}"><fmt:formatNumber value="${item.bestScore}" maxFractionDigits="1"/></c:when>
                                                    <c:otherwise>--</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap; color: var(--sv-foreground); font-weight: 600;">
                                                <c:choose>
                                                    <c:when test="${not empty item.bestScore and not empty item.assessment.totalMarks and item.assessment.totalMarks > 0}">
                                                        <fmt:formatNumber value="${(item.bestScore / item.assessment.totalMarks) * 100}" maxFractionDigits="1"/>%
                                                    </c:when>
                                                    <c:otherwise>--</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap;">
                                                <c:choose>
                                                    <c:when test="${not empty item.bestScore and not empty item.assessment.totalMarks and item.assessment.totalMarks > 0}">
                                                        <c:set var="bestPercent" value="${(item.bestScore / item.assessment.totalMarks) * 100}" />
                                                        <c:choose>
                                                            <c:when test="${bestPercent >= 85}"><span class="sa-status status-Approved" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Excellent</span></c:when>
                                                            <c:when test="${bestPercent >= 70}"><span class="sa-status status-Pending" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px; background: rgba(59, 130, 246, 0.1); color: #2563eb;">Strong</span></c:when>
                                                            <c:when test="${bestPercent >= 50}"><span class="sa-status status-Pending" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px; background: rgba(245, 158, 11, 0.12); color: #d97706;">Developing</span></c:when>
                                                            <c:otherwise><span class="sa-status status-Archived" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">Needs Review</span></c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="sa-status status-Pending" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px; background: rgba(148, 163, 184, 0.15); color: #64748b;">No Score</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="padding: 16px 10px; vertical-align: top; color: var(--sv-muted); white-space: nowrap;">
                                                <c:choose>
                                                    <c:when test="${not empty item.latestSubmission}">${fn:replace(item.latestSubmission.submitDate, 'T', ' ')}</c:when>
                                                    <c:otherwise>--</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="padding: 16px 10px; vertical-align: top;">
                                                <span class="sa-status sa-status-${fn:toLowerCase(fn:replace(item.statusLabel, ' ', ''))}" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">${item.statusLabel}</span>
                                            </td>
                                            <td style="padding: 16px 10px; vertical-align: top; white-space: nowrap;">
                                                <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=details&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; border: 1px solid var(--sv-border);">
                                                        <i class="fas fa-eye"></i> Open
                                                    </a>
                                                    <c:if test="${not empty item.latestSubmission}">
                                                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=result&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}&submissionId=${item.latestSubmission.submissionId}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem;">
                                                            Result
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </article>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
