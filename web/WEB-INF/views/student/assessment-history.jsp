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
            <article class="sa-hero">
                <div class="sa-hero-top">
                    <div>
                        <h2>${enrollment.courseName}</h2>
                    </div>
                    <div class="sa-badges">
                        <span class="sa-chip"><i class="fas fa-clock-rotate-left"></i> Attempt history</span>
                    </div>
                </div>
            </article>

            <article class="sa-panel">
                <div class="sa-panel-head">
                    <div>
                        <h3>Assessment history</h3>
                    </div>
                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?view=dashboard&enrollmentId=${enrollment.enrollmentId}"><i class="fas fa-table-columns"></i> Back to Dashboard</a>
                </div>

                <c:choose>
                    <c:when test="${empty assessmentSummaries}">
                        <div class="sa-empty">
                            <h3>No attempts yet</h3>
                            <p>Once you submit assessments, they will appear here.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="sa-table-wrap">
                            <table class="sa-table">
                                <thead>
                                <tr>
                                    <th>Assessment</th>
                                    <th>Attempts Used</th>
                                    <th>Best Score</th>
                                    <th>Last Submitted</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="item" items="${assessmentSummaries}">
                                    <tr>
                                        <td data-label="Assessment">
                                            <strong>${item.assessmentTitle}</strong>
                                            <div class="sa-subtle">${item.courseName}</div>
                                        </td>
                                        <td data-label="Attempts Used">${item.usedAttempts} / ${item.allowedAttempts}</td>
                                        <td data-label="Best Score">
                                            <c:choose>
                                                <c:when test="${not empty item.bestScore}"><fmt:formatNumber value="${item.bestScore}" maxFractionDigits="1"/></c:when>
                                                <c:otherwise>--</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td data-label="Last Submitted">
                                            <c:choose>
                                                <c:when test="${not empty item.latestSubmission}">${fn:replace(item.latestSubmission.submitDate, 'T', ' ')}</c:when>
                                                <c:otherwise>--</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td data-label="Status"><span class="sa-status sa-status-${fn:toLowerCase(fn:replace(item.statusLabel, ' ', ''))}">${item.statusLabel}</span></td>
                                        <td data-label="Action">
                                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?view=details&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}">
                                                <i class="fas fa-eye"></i> Open
                                            </a>
                                            <c:if test="${not empty item.latestSubmission}">
                                                <a class="sa-subtle ass-inline-link" href="${pageContext.request.contextPath}/student/assessments?view=result&enrollmentId=${enrollment.enrollmentId}&assessmentId=${item.assessment.assessmentId}&submissionId=${item.latestSubmission.submissionId}">Result</a>
                                            </c:if>
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
