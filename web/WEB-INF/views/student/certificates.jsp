<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="studentProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
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
<c:set var="topbarSubtitle" value="Generate and share your learning credentials"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="certificates"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main cert-page">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fas fa-angle-right"></i>
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

        <section class="sv-card cert-hero cert-card-animated">
            <div class="sv-card-body cert-hero-body">
                <div class="cert-hero-copy">
                    <p class="cert-kicker">Credential Center</p>
                    <h2>Earned Credentials</h2>
                    <p>Generate certificates after completion, confirm eligibility quickly, and keep every issued credential in one trusted place.</p>
                    <div class="cert-hero-actions">
                        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn primary">Open My Courses</a>
                        <a href="${pageContext.request.contextPath}/student/courses" class="sv-btn">Browse Courses</a>
                    </div>
                </div>
                <div class="cert-hero-scene" aria-hidden="true">
                    <span class="cert-orb cert-orb-a" data-depth="18"></span>
                    <span class="cert-orb cert-orb-b" data-depth="26"></span>
                    <span class="cert-orb cert-orb-c" data-depth="14"></span>
                    <div class="cert-scene-panel cert-scene-panel-a">
                        <span>Eligible</span>
                        <strong>${fn:length(readyToGenerate)}</strong>
                    </div>
                    <div class="cert-scene-panel cert-scene-panel-b">
                        <span>Issued</span>
                        <strong>${fn:length(issuedCertificates)}</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="sv-metrics cert-metrics">
            <article class="sv-metric cert-metric">
                <h3 class="cert-count" data-counter="${fn:length(readyToGenerate)}">${fn:length(readyToGenerate)}</h3>
                <p>Ready to Generate</p>
            </article>
            <article class="sv-metric cert-metric">
                <h3 class="cert-count" data-counter="${fn:length(issuedCertificates)}">${fn:length(issuedCertificates)}</h3>
                <p>Issued Certificates</p>
            </article>
            <article class="sv-metric cert-metric">
                <h3 class="cert-count" data-counter="${activeCount}">${activeCount}</h3>
                <p>Active</p>
            </article>
            <article class="sv-metric cert-metric">
                <h3 class="cert-count" data-counter="${revokedCount}">${revokedCount}</h3>
                <p>Revoked</p>
            </article>
        </section>

        <section class="sv-card cert-card cert-card-animated cert-public-verify-note">
            <div class="sv-card-body">
                <div class="cert-public-verify-copy">
                    <i class="fas fa-shield-check"></i>
                    <div>
                        <strong>Verification is public.</strong>
                        <p>Share certificate code with employers or institutions. They can verify authenticity from the landing page under Public Certificate Verification.</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="sv-card cert-controls cert-card cert-card-animated">
            <div class="sv-card-body cert-controls-body" aria-label="Certificate list controls">
                <div class="cert-filter-group">
                    <button type="button" class="cert-filter active" data-filter="all">All</button>
                    <button type="button" class="cert-filter" data-filter="active">Active</button>
                    <button type="button" class="cert-filter" data-filter="revoked">Revoked</button>
                </div>
                <div class="cert-search-wrap">
                    <label for="certQuickSearch" class="cert-sr-only">Search certificates</label>
                    <input id="certQuickSearch" type="text" placeholder="Search course or certificate no..." autocomplete="off">
                </div>
            </div>
        </section>

        <section class="sv-card cert-card cert-card-animated">
            <div class="sv-card-head">
                <h2>Ready to Generate</h2>
                <span class="cert-head-count">${fn:length(readyToGenerate)} Enrollment(s)</span>
            </div>
            <div class="sv-card-body">
                <div class="cert-section-intro">
                    <div>
                        <strong>Certificates are unlocked only when the course is fully ready.</strong>
                        <p>Eligible enrollments have synced completion, passed required assessments, and successful payment before generation is enabled.</p>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${empty readyToGenerate}">
                        <div class="sv-empty">
                            <i class="fas fa-award"></i>
                            <p>No completed and paid enrollments are waiting for generation.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="cert-table-wrap">
                            <table class="history-table cert-table">
                                <thead>
                                <tr>
                                    <th>Course</th>
                                    <th>Status</th>
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
                                            <span class="sv-chip done">${enrollment.completionStatus}</span>
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

        <section class="sv-card cert-card cert-card-animated cert-card-delay">
            <div class="sv-card-head">
                <h2>Not Yet Eligible</h2>
                <span class="cert-head-count">${fn:length(blockedEnrollments)} Enrollment(s)</span>
            </div>
            <div class="sv-card-body">
                <div class="cert-section-intro cert-section-intro-compact">
                    <div>
                        <strong>These enrollments are close but still blocked by one or more requirements.</strong>
                        <p>Open each learning hub to complete remaining steps, then return here to generate instantly.</p>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${empty blockedEnrollments}">
                        <div class="sv-empty">
                            <i class="fas fa-circle-check"></i>
                            <p>No enrollments are currently blocked.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="cert-table-wrap">
                            <table class="history-table cert-table">
                                <thead>
                                <tr>
                                    <th>Course</th>
                                    <th>Payment</th>
                                    <th>Materials</th>
                                    <th>Assessments</th>
                                    <th>Action</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="item" items="${blockedEnrollments}">
                                    <tr>
                                        <td><div class="cert-course-name">${item.enrollment.courseName}</div></td>
                                        <td><span class="sv-chip ${item.syncResult.paid ? 'done' : 'status-Pending'}">${item.syncResult.paid ? 'Done' : 'Pending'}</span></td>
                                        <td><span class="sv-chip ${item.syncResult.viewedAllMaterials ? 'done' : 'status-Pending'}">${item.syncResult.viewedMaterials}/${item.syncResult.totalMaterials}</span></td>
                                        <td><span class="sv-chip ${item.syncResult.passedRequiredAssessments ? 'done' : 'status-Pending'}">${item.syncResult.passedAssessments}/${item.syncResult.totalAssessments}</span></td>
                                        <td>
                                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${item.enrollment.enrollmentId}&tab=learning">
                                                <i class="fas fa-route"></i>
                                                <span>Complete Requirements</span>
                                            </a>
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

        <section class="sv-card cert-card cert-card-animated cert-card-delay">
            <div class="sv-card-head">
                <h2>Issued Certificates</h2>
                <span class="cert-head-count">${fn:length(issuedCertificates)} Certificate(s)</span>
            </div>
            <div class="sv-card-body">
                <div class="cert-section-intro cert-section-intro-compact">
                    <div>
                        <strong>Review and share every issued certificate.</strong>
                        <p>Use search and filters to find a certificate, open the template, then share certificate code for public verification on the landing page.</p>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${empty issuedCertificates}">
                        <div class="sv-empty">
                            <i class="fas fa-scroll"></i>
                            <p>No certificates generated yet.</p>
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
                                    <tr class="cert-row" data-status="${cert.status == 'Revoked' ? 'revoked' : 'active'}" data-course="${cert.courseName}" data-cert="${cert.certificateNo}">
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
                                                <a class="sv-btn" href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${cert.enrollmentId}">
                                                    <i class="fas fa-award"></i>
                                                    <span>Open</span>
                                                </a>
                                                <button type="button" class="sv-btn cert-copy-code-btn" data-cert-copy="${cert.certificateNo}">
                                                    <i class="fas fa-copy"></i>
                                                    <span>Copy Code</span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <div class="sv-empty cert-empty-hidden" id="certNoRows">
                            <i class="fas fa-magnifying-glass"></i>
                            <p>No certificates match your filter/search.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>
</div>

<div id="svOverlay" class="sv-overlay"></div>
<div id="certCopyToast" class="cert-copy-toast" role="status" aria-live="polite">Certificate code copied</div>

<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/certificates-v2.js"></script>
</body>
</html>
