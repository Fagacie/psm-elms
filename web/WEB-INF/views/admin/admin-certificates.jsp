<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate Management - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Certificate Management"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <section class="section-card">
            <div class="section-header">
                <h2>Issued Certificates</h2>
                <form method="post" action="${pageContext.request.contextPath}/admin/certificates" style="margin-left:auto;">
                    <input type="hidden" name="action" value="backfill">
                    <button class="btn btn-primary btn-sm" type="submit" onclick="return confirm('Run enrollment backfill now? This recalculates payment/progress/completion for all enrollments.');">Backfill Enrollment State</button>
                </form>
            </div>
            <c:if test="${param.success == 'revoked'}">
                <div class="alert alert-success" style="margin-bottom:12px;">Certificate revoked successfully.</div>
            </c:if>
            <c:if test="${param.success == 'backfill'}">
                <div class="alert alert-success" style="margin-bottom:12px;">Enrollment backfill completed. Updated: ${param.updated}, Errors: ${param.errors}.</div>
            </c:if>
            <c:if test="${param.error == 'revoke'}">
                <div class="alert alert-error" style="margin-bottom:12px;">Unable to revoke certificate.</div>
            </c:if>
            <div class="table-wrapper">
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
                    <c:choose>
                        <c:when test="${empty certificates}">
                            <tr><td colspan="7" style="text-align:center;">No certificates issued yet.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="cert" items="${certificates}">
                                <tr>
                                    <td>${cert.certificateNo}</td>
                                    <td>${cert.studentName}<br><small>${cert.studentEmail}</small></td>
                                    <td><c:out value="${cert.regNumber}" default="-"/></td>
                                    <td>${cert.courseName}</td>
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
                                            <c:when test="${cert.status == 'Revoked'}"><span class="badge badge-danger">Revoked</span></c:when>
                                            <c:otherwise><span class="badge badge-success">Active</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/certificate/template?certificateId=${cert.certificateId}&back=${pageContext.request.contextPath}/admin/certificates">Template</a>
                                        <a class="btn btn-primary btn-sm" target="_blank" href="${cert.verificationURL}">Verify</a>
                                        <c:if test="${cert.status != 'Revoked'}">
                                            <form method="post" action="${pageContext.request.contextPath}/admin/certificates" style="display:inline;">
                                                <input type="hidden" name="action" value="revoke">
                                                <input type="hidden" name="certificateId" value="${cert.certificateId}">
                                                <button class="btn btn-danger btn-sm" type="submit" onclick="return confirm('Revoke this certificate?');">Revoke</button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="section-card" style="margin-top: 16px;">
            <div class="section-header">
                <h2>Template Preview</h2>
            </div>
            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/certificate/template?back=${pageContext.request.contextPath}/admin/certificates">Open Preview Template</a>
        </section>
    </div>
</main>
</body>
</html>
