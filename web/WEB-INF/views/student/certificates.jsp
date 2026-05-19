<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificates | PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/certificates-v2.css">
</head>
<body class="sv-page">
<c:set var="revokedCount" value="0" />
<c:forEach var="issued" items="${issuedCertificates}">
    <c:if test="${issued.status == 'Revoked'}">
        <c:set var="revokedCount" value="${revokedCount + 1}" />
    </c:if>
</c:forEach>
<c:set var="activeCount" value="${fn:length(issuedCertificates) - revokedCount}" />

<c:set var="topbarTitle" value="Certificates"/>
<c:set var="topbarSubtitle" value="Generate, manage, and share credentials"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="certificates"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main cert-page">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <span>/</span>
            <span>Certificates</span>
        </div>

        <c:if test="${param.success == 'generated'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Certificate generated successfully and added to your issued list.
            </div>
        </c:if>
        <c:if test="${param.error == 'noteligible'}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-triangle"></i>
                This enrollment is not yet eligible for certificate generation.
                <c:if test="${fn:contains(param.reason, 'payment')}"> Payment is pending.</c:if>
                <c:if test="${fn:contains(param.reason, 'materials')}"> Some materials are still not viewed.</c:if>
                <c:if test="${fn:contains(param.reason, 'assessments')}"> Required assessments are not fully passed.</c:if>
            </div>
        </c:if>
        <c:if test="${param.error == 'generatefail'}">
            <div class="alert alert-error">
                <i class="fas fa-triangle-exclamation"></i> Certificate generation failed. Please retry.
            </div>
        </c:if>

        <%-- Beautiful self-contained Certificates Page Header --%>
        <section class="sv-card cert-hero">
            <div class="sv-card-body cert-hero-body">
                <div class="cert-hero-content">
                    <span class="cert-kicker"><i class="fas fa-certificate"></i> Certificates & Credentials</span>
                    <h2>Your Course Certificates</h2>
                    <p class="cert-hero-intro">View and manage your officially issued course certificates, verify your academic completion status, or instantly generate newly earned credentials.</p>
                    <div class="cert-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn"><i class="fas fa-book-open"></i>&nbsp;My Courses</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn primary"><i class="fas fa-search"></i>&nbsp;Browse Catalog</a>
                    </div>
                </div>
                <div class="cert-hero-scene">
                    <div class="cert-scene-panel cert-scene-panel-a">
                        <span>Issued</span>
                        <strong>${fn:length(issuedCertificates)}</strong>
                    </div>
                    <div class="cert-scene-panel cert-scene-panel-b">
                        <span>Ready</span>
                        <strong>${fn:length(readyToGenerate)}</strong>
                    </div>
                    <div class="cert-orb cert-orb-a"></div>
                    <div class="cert-orb cert-orb-b"></div>
                    <div class="cert-orb cert-orb-c"></div>
                </div>
            </div>
        </section>

        <%-- Dynamic Metrics strip (Now self-contained and perfectly styled) --%>
        <div class="cert-metrics-strip">
            <div class="cert-metric-tile">
                <div class="cert-metric-icon-wrap"><i class="fas fa-certificate"></i></div>
                <div class="cert-metric-body">
                    <span class="cert-metric-label">Issued Certificates</span>
                    <strong class="cert-metric-value">${fn:length(issuedCertificates)}</strong>
                </div>
            </div>
            <div class="cert-metric-tile cert-metric-tile--green">
                <div class="cert-metric-icon-wrap"><i class="fas fa-circle-check"></i></div>
                <div class="cert-metric-body">
                    <span class="cert-metric-label">Active Credentials</span>
                    <strong class="cert-metric-value">${activeCount}</strong>
                </div>
            </div>
            <div class="cert-metric-tile cert-metric-tile--blue">
                <div class="cert-metric-icon-wrap"><i class="fas fa-circle-play"></i></div>
                <div class="cert-metric-body">
                    <span class="cert-metric-label">Ready to Generate</span>
                    <strong class="cert-metric-value">${fn:length(readyToGenerate)}</strong>
                </div>
            </div>
            <div class="cert-metric-tile cert-metric-tile--amber">
                <div class="cert-metric-icon-wrap"><i class="fas fa-lock"></i></div>
                <div class="cert-metric-body">
                    <span class="cert-metric-label">Blocked/Pending</span>
                    <strong class="cert-metric-value">${fn:length(blockedEnrollments)}</strong>
                </div>
            </div>
        </div>

        <%-- Primary Section: Already Issued Certificates --%>
        <section class="sv-card cert-card">
            <div class="sv-card-head">
                <div>
                    <h2>Issued Certificates</h2>
                    <p class="cert-section-intro-desc">Review, view templates, download PDFs, or copy verification codes.</p>
                </div>
            </div>
            
            <div class="cert-controls-body" aria-label="Certificate list controls">
                <div class="cert-filter-group">
                    <button type="button" class="cert-filter active" data-filter="all">All</button>
                    <button type="button" class="cert-filter" data-filter="active">Active</button>
                    <button type="button" class="cert-filter" data-filter="revoked">Revoked</button>
                </div>
                <div class="cert-search-wrap">
                    <label for="certQuickSearch" class="cert-sr-only">Search certificates</label>
                    <input id="certQuickSearch" type="text" placeholder="Search by course or certificate code..." autocomplete="off">
                </div>
            </div>

            <div class="sv-card-body">
                <c:choose>
                    <c:when test="${empty issuedCertificates}">
                        <div class="empty-state-box">
                            <i class="fas fa-scroll"></i>
                            <p>No certificates have been issued to your account yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="cert-table-wrap">
                            <table class="history-table cert-table">
                                <thead>
                                <tr>
                                    <th>Certificate No</th>
                                    <th>Course</th>
                                    <th>Issue Date</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="cert" items="${issuedCertificates}">
                                    <tr class="cert-row"
                                        data-status="${cert.status == 'Revoked' ? 'revoked' : 'active'}"
                                        data-course="${cert.courseName}"
                                        data-cert="${cert.certificateNo}">
                                        <td><span class="cert-no">${cert.certificateNo}</span></td>
                                        <td><div class="cert-course-name">${cert.courseName}</div></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty cert.issueDate}">
                                                    ${cert.issueDate.toLocalDate()}
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${cert.status == 'Revoked'}"><span class="sv-chip cert-chip-revoked">Revoked</span></c:when>
                                                <c:otherwise><span class="sv-chip done">Active</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="cert-actions">
                                                <a class="sv-btn primary cert-table-btn" href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${cert.enrollmentId}">
                                                    <i class="fas fa-eye"></i>
                                                    <span>View</span>
                                                </a>
                                                <button type="button" class="sv-btn cert-table-btn" style="border-color: var(--sv-border-strong); background: var(--sv-surface-soft);" data-cert-download="${pageContext.request.contextPath}/student/certificate?enrollmentId=${cert.enrollmentId}&download=pdf">
                                                    <i class="fas fa-file-pdf" style="color: #ef4444;"></i>
                                                    <span>PDF</span>
                                                </button>
                                                <button type="button" class="sv-btn cert-copy-code-btn cert-table-btn" data-cert-copy="${cert.certificateNo}">
                                                    <i class="fas fa-copy"></i>
                                                    <span>Code</span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <div class="empty-state-box cert-empty-hidden" id="certNoRows">
                            <i class="fas fa-magnifying-glass"></i>
                            <p>No certificates match your search query.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <%-- Stacked Section: Ready to Generate & Blocked Enrollments --%>
        <div class="cert-sections-grid">
            <%-- Ready to Generate --%>
            <section class="sv-card cert-card">
                <div class="sv-card-head">
                    <div>
                        <h2>Ready to Generate</h2>
                        <p class="me-card-intro">Enrollments fully completed and waiting to generate official certificates.</p>
                    </div>
                </div>
                <div class="sv-card-body">
                    <c:choose>
                        <c:when test="${empty readyToGenerate}">
                            <div class="empty-state-box">
                                <i class="fas fa-award"></i>
                                <p>No completed and paid enrollments are currently waiting for generation.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="cert-table-wrap">
                                <table class="history-table cert-table" style="min-width: auto; width: 100%;">
                                    <thead>
                                    <tr>
                                        <th>Course</th>
                                        <th>Action</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="enrollment" items="${readyToGenerate}">
                                        <tr>
                                            <td>
                                                <div class="cert-course-name">${enrollment.courseName}</div>
                                            </td>
                                            <td>
                                                <form method="post" action="${pageContext.request.contextPath}/student/certificate" class="cert-inline-form">
                                                    <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                    <input type="hidden" name="redirectTo" value="certificates">
                                                    <button class="sv-btn primary cert-generate-btn" type="submit">
                                                        <i class="fas fa-file-signature"></i>
                                                        <span>Generate</span>
                                                    </button>
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
            </section>

            <%-- Not Yet Eligible --%>
            <section class="sv-card cert-card">
                <div class="sv-card-head">
                    <div>
                        <h2>Not Yet Eligible</h2>
                        <p class="me-card-intro">Active courses requiring one or more criteria to be completed.</p>
                    </div>
                </div>
                <div class="sv-card-body">
                    <c:choose>
                        <c:when test="${empty blockedEnrollments}">
                            <div class="empty-state-box">
                                <i class="fas fa-circle-check"></i>
                                <p>All active enrollments are either fully complete or already issued.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="cert-table-wrap">
                                <table class="history-table cert-table" style="min-width: auto; width: 100%;">
                                    <thead>
                                    <tr>
                                        <th>Course</th>
                                        <th>Pending Requirements</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="item" items="${blockedEnrollments}">
                                        <tr>
                                            <td><div class="cert-course-name">${item.enrollment.courseName}</div></td>
                                            <td>
                                                <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                                    <span class="sv-chip ${item.syncResult.paid ? 'done' : 'status-Pending'}"><i class="fas fa-wallet"></i> Paid: ${item.syncResult.paid ? 'Yes' : 'No'}</span>
                                                    <span class="sv-chip ${item.syncResult.viewedAllMaterials ? 'done' : 'status-Pending'}"><i class="fas fa-book-open"></i> Materials: ${item.syncResult.viewedMaterials}/${item.syncResult.totalMaterials}</span>
                                                    <span class="sv-chip ${item.syncResult.passedRequiredAssessments ? 'done' : 'status-Pending'}"><i class="fas fa-layer-group"></i> Quiz: ${item.syncResult.passedAssessments}/${item.syncResult.totalAssessments}</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>
        </div>
    </main>
</div>

<div id="svOverlay" class="sv-overlay"></div>
<div id="certCopyToast" class="cert-copy-toast" role="status" aria-live="polite">Certificate code copied</div>

<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/certificates-v2.js"></script>
</body>
</html>
