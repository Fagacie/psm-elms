<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate Management - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Certificates"/>
    <jsp:param name="pageSubtitle" value="Review issued credentials and revocations"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <c:set var="totalCertificates" value="${empty certificates ? 0 : fn:length(certificates)}"/>
        <c:set var="activeCertificates" value="0"/>
        <c:set var="revokedCertificates" value="0"/>
        <c:forEach var="cert" items="${certificates}">
            <c:choose>
                <c:when test="${fn:toLowerCase(cert.status) == 'revoked'}"><c:set var="revokedCertificates" value="${revokedCertificates + 1}"/></c:when>
                <c:otherwise><c:set var="activeCertificates" value="${activeCertificates + 1}"/></c:otherwise>
            </c:choose>
        </c:forEach>

        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Certificates</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Credential Governance</p>
                    <h2>Manage issued certificates, verification flow, and revocation actions</h2>
                    <p>Review every issued credential, preview templates, open verification links, and run enrollment state backfill when certificate eligibility data needs resyncing.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <span class="admin-orb admin-orb-a"></span>
                    <span class="admin-orb admin-orb-b"></span>
                    <span class="admin-shape admin-shape-a"></span>
                    <span class="admin-shape admin-shape-b"></span>
                    <div class="admin-scene-panel admin-scene-panel-a">
                        <span>Issued</span>
                        <strong>${totalCertificates}</strong>
                    </div>
                    <div class="admin-scene-panel admin-scene-panel-b">
                        <span>Revoked</span>
                        <strong>${revokedCertificates}</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Certificate Overview</h2>
                <span class="section-caption">Credential operations</span>
            </div>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-label">Total Issued</div>
                    <div class="metric-value">${totalCertificates}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Active</div>
                    <div class="metric-value">${activeCertificates}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Revoked</div>
                    <div class="metric-value">${revokedCertificates}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Template Access</div>
                    <div class="metric-value">Ready</div>
                </div>
            </div>
            <div class="admin-action-bar">
                <div class="admin-action-bar-copy">
                    <strong>Registry actions</strong>
                    <span>Backfill certificate eligibility data or open the live preview template before issuing support guidance.</span>
                </div>
                <div class="admin-action-bar-actions">
                    <a class="admin-btn secondary" href="${pageContext.request.contextPath}/certificate/template?back=${pageContext.request.contextPath}/admin/certificates">Preview Template</a>
                    <form method="post" action="${pageContext.request.contextPath}/admin/certificates" class="form-actions-inline">
                        <input type="hidden" name="action" value="backfill">
                        <button class="admin-btn primary" type="submit" onclick="return confirm('Run enrollment backfill now? This recalculates payment, progress, and completion for all enrollments.');">Backfill Enrollment State</button>
                    </form>
                </div>
            </div>
        </section>

        <c:if test="${param.success == 'revoked'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Certificate revoked successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'backfill'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Enrollment backfill completed. Updated: ${param.updated}, Errors: ${param.errors}.
            </div>
        </c:if>
        <c:if test="${param.error == 'revoke'}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> Unable to revoke certificate.
            </div>
        </c:if>
        <c:if test="${param.error == 'invalid'}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> Invalid certificate action request.
            </div>
        </c:if>
        <c:if test="${param.error == 'certificate'}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> The requested certificate record could not be found.
            </div>
        </c:if>
        <c:if test="${param.error == 'permission'}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> You do not have permission to open that certificate record.
            </div>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Issued Certificates</h2>
            </div>
            <div class="admin-table-toolbar">
                <span class="section-caption">${totalCertificates} certificates</span>
            </div>
            <c:choose>
                <c:when test="${empty certificates}">
                    <div class="empty-state empty-state-inset">
                        <i class="fas fa-certificate"></i>
                        <strong>No certificates issued yet</strong>
                        <p>Issued records will appear here once students meet eligibility and certificates are generated by the system.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-wrapper">
                        <table class="data-table admin-cert-table">
                            <thead>
                            <tr>
                                <th>Certificate No</th>
                                <th>Student</th>
                                <th>Registration No</th>
                                <th>Course</th>
                                <th>Issue Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="cert" items="${certificates}">
                                <c:set var="isRevoked" value="${fn:toLowerCase(cert.status) == 'revoked'}"/>
                                <c:url var="verifyUrl" value="/certificate/verify">
                                    <c:param name="code" value="${cert.certificateNo}"/>
                                </c:url>
                                <tr>
                                    <td>
                                        <span class="admin-code admin-cert-code">${cert.certificateNo}</span>
                                        <div class="table-subtext">Verification code</div>
                                    </td>
                                    <td>
                                        <strong>${cert.studentName}</strong>
                                        <div class="table-subtext">${cert.studentEmail}</div>
                                    </td>
                                    <td><c:out value="${cert.regNumber}" default="-"/></td>
                                    <td>${cert.courseName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty cert.issueDate}">
                                                ${cert.issueDate.toLocalDate()}
                                                <div class="table-subtext">${cert.issueDate.toLocalTime()}</div>
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${isRevoked}">
                                                <span class="status-badge status-danger">Revoked</span>
                                                <div class="table-subtext">
                                                    <c:choose>
                                                        <c:when test="${not empty cert.revokedAt}">Revoked on ${cert.revokedAt.toLocalDate()}</c:when>
                                                        <c:otherwise>Revocation recorded</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:when>
                                            <c:otherwise><span class="status-badge status-success">Active</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="admin-table-actions">
                                            <a class="admin-btn primary" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}${verifyUrl}">Verify</a>
                                            <c:if test="${not isRevoked}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/certificates" class="admin-inline-form">
                                                    <input type="hidden" name="action" value="revoke">
                                                    <input type="hidden" name="certificateId" value="${cert.certificateId}">
                                                    <button class="admin-btn danger" type="submit" onclick="return confirm('Revoke this certificate?');">Revoke</button>
                                                </form>
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
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Template Preview</h2>
                <span class="section-caption">Live sample</span>
            </div>
            <div class="section-actions-inset">
                <a class="admin-btn primary" href="${pageContext.request.contextPath}/certificate/template?back=${pageContext.request.contextPath}/admin/certificates">Open Preview Template</a>
            </div>
        </section>
    </div>
</main>
</body>
</html>
