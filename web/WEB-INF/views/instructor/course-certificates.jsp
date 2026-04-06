<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Certificates - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-certificates.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Certificates"/>
    <jsp:param name="pageSubtitle" value="Monitor certificate templates and issuance"/>
</jsp:include>

<c:set var="activeInstructorPage" value="certificates"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Certificates</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Certificate Oversight</p>
                <h2>Track issued credentials and protect certificate integrity</h2>
                <p>This page now presents certificate records as a professional review workspace so instructors can inspect issued documents, verify status quickly, and revoke only when necessary.</p>
            </div>
            <div class="ins-hero-actions">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/certificate/template?back=${pageContext.request.contextPath}/instructor/certificates">
                    <i class="fas fa-eye"></i> Open Template Preview
                </a>
            </div>
        </section>

        <section class="ins-hero-card certificates-hero">
            <div class="ins-hero-grid">
                <div>
                    <h3>Issued certificates across your courses</h3>
                    <p>Use this registry to review who has already been certified, verify each certificate link, and manage revocations in a controlled and visible way.</p>
                </div>
                <div class="ins-hero-metrics">
                    <div class="ins-metric">
                        <strong>${fn:length(certificates)}</strong>
                        <span>Total issued</span>
                    </div>
                    <div class="ins-metric">
                        <strong>${fn:length(certificates)}</strong>
                        <span>Records in view</span>
                    </div>
                    <div class="ins-metric">
                        <strong>${param.success == 'revoked' ? 'Updated' : 'Stable'}</strong>
                        <span>Registry status</span>
                    </div>
                    <div class="ins-metric">
                        <strong>${param.error == 'revoke' ? 'Check' : 'Ready'}</strong>
                        <span>Action signal</span>
                    </div>
                </div>
            </div>
        </section>

        <c:if test="${param.success == 'revoked'}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Certificate revoked successfully.</div>
        </c:if>
        <c:if test="${param.error == 'revoke'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Unable to revoke certificate.</div>
        </c:if>

        <section class="section-card certificates-section">
            <div class="section-header">
                <div>
                    <h3 class="section-title">Issued Certificates</h3>
                    <p class="section-caption">Review active and revoked certificates linked to the courses you manage.</p>
                </div>
                <div class="student-count-badge">${fn:length(certificates)} Records</div>
            </div>

            <c:choose>
                <c:when test="${empty certificates}">
                    <div class="empty-state-box">
                        <i class="fas fa-certificate"></i>
                        <p>No certificates have been issued yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="data-table">
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
                                    <tr>
                                        <td class="cert-no">${cert.certificateNo}</td>
                                        <td>
                                            <div class="student-name">${cert.studentName}</div>
                                            <div class="student-email">${cert.studentEmail}</div>
                                        </td>
                                        <td><c:out value="${cert.regNumber}" default="-"/></td>
                                        <td>${cert.courseName}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty cert.issueDate}">
                                                    ${cert.issueDate.toLocalDate()}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="table-muted">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${cert.status == 'Revoked'}">
                                                    <span class="status-badge status-revoked">Revoked</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-active">Active</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="certificate-actions">
                                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/certificate/template?certificateId=${cert.certificateId}&back=${pageContext.request.contextPath}/instructor/certificates">
                                                    <i class="fas fa-eye"></i> Template
                                                </a>
                                                <a class="btn btn-primary btn-sm" target="_blank" rel="noopener noreferrer" href="${cert.verificationURL}">
                                                    <i class="fas fa-shield-check"></i> Verify
                                                </a>
                                                <c:if test="${cert.status != 'Revoked'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/certificates">
                                                        <input type="hidden" name="action" value="revoke">
                                                        <input type="hidden" name="certificateId" value="${cert.certificateId}">
                                                        <button class="btn btn-danger btn-sm" type="submit" onclick="return confirm('Revoke this certificate?');">
                                                            <i class="fas fa-ban"></i> Revoke
                                                        </button>
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
    </div>
</main>
</body>
</html>

