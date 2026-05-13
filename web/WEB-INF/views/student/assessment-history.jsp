<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessment History - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessment-module.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Assessment History"/>
<c:set var="topbarSubtitle" value="Review attempts, best scores, and latest submission status"/>
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
            <span>History</span>
        </div>

        <section class="sa-shell">


            <article class="sa-panel sv-card" style="border-radius: 16px; border: 1px solid var(--sv-border); background: var(--sv-surface); padding: 24px !important;">
                <div class="sa-panel-head" style="display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 24px;">
                    <div>
                        <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: var(--sv-foreground); letter-spacing: -0.02em;">Assessment History</h3>
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
                        <!-- High-Fidelity Responsive History List -->
                        <div style="display: flex; flex-direction: column; gap: 14px;">
                            <c:forEach var="item" items="${assessmentSummaries}">
                                <div style="display: flex; align-items: center; justify-content: space-between; gap: 20px; padding: 18px 0; border-bottom: 1px solid var(--sv-border); transition: all 0.25s ease;">
                                    <div style="display: flex; align-items: center; gap: 16px; flex: 1; min-width: 0;">
                                        <div style="width: 44px; height: 44px; border-radius: 10px; background: var(--sv-surface-soft); border: 1px solid var(--sv-border); display: flex; align-items: center; justify-content: center; color: var(--sv-foreground); font-size: 1.15rem; flex-shrink: 0;">
                                            <i class="fas fa-history"></i>
                                        </div>
                                        <div style="display: flex; flex-direction: column; gap: 4px; min-width: 0;">
                                            <strong style="font-size: 1.02rem; font-weight: 700; color: var(--sv-foreground); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block;"><c:out value="${item.assessmentTitle}"/></strong>
                                            <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap; font-size: 0.82rem; color: var(--sv-muted);">
                                                <span>Attempts Used: <strong>${item.usedAttempts} / ${item.allowedAttempts}</strong></span>
                                                <span style="display: inline-flex; align-items: center; gap: 4px;"><i class="far fa-star"></i> Best Score: <strong><c:choose><c:when test="${not empty item.bestScore}"><fmt:formatNumber value="${item.bestScore}" maxFractionDigits="1"/></c:when><c:otherwise>--</c:otherwise></c:choose></strong></span>
                                                <span style="display: inline-flex; align-items: center; gap: 4px;"><i class="far fa-calendar"></i> <c:choose><c:when test="${not empty item.latestSubmission}">${fn:replace(item.latestSubmission.submitDate, 'T', ' ')}</c:when><c:otherwise>--</c:otherwise></c:choose></span>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div style="display: flex; align-items: center; gap: 14px; flex-shrink: 0; flex-wrap: wrap;">
                                        <span class="sa-status sa-status-${fn:toLowerCase(fn:replace(item.statusLabel, ' ', ''))}" style="min-height: 28px; font-size: 0.7rem; padding: 0 12px; border-radius: 999px;">${item.statusLabel}</span>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=details&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; border: 1px solid var(--sv-border);">
                                                <i class="fas fa-eye"></i> Open
                                            </a>
                                            <c:if test="${not empty item.latestSubmission}">
                                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments&view=result&assessmentId=${item.assessment.assessmentId}&submissionId=${item.latestSubmission.submissionId}" style="height: 36px; padding: 0 14px; border-radius: 8px; display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem;">
                                                    Result
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
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
