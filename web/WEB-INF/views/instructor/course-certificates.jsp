<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Certificates - Instructor</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<header class="app-header">
    <div class="header-left">
        <div class="logo-section">
            <i class="fas fa-graduation-cap"></i>
            <span>PSM E-Learning</span>
        </div>
        <h1 class="page-title">Course Certificates</h1>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item">
            <i class="fas fa-book"></i><span>My Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item active">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="section-card">
            <h3>Issued Certificates in Your Courses</h3>
            <c:if test="${param.success == 'revoked'}">
                <div class="alert alert-success" style="margin-bottom:12px;">Certificate revoked successfully.</div>
            </c:if>
            <c:if test="${param.error == 'revoke'}">
                <div class="alert alert-error" style="margin-bottom:12px;">Unable to revoke certificate.</div>
            </c:if>
            <c:choose>
                <c:when test="${empty certificates}">
                    <p>No certificates issued yet.</p>
                </c:when>
                <c:otherwise>
                    <table class="data-table" style="width:100%;">
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
                                    <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/certificate/template?certificateId=${cert.certificateId}&back=${pageContext.request.contextPath}/instructor/certificates">Template</a>
                                    <a class="btn btn-primary btn-sm" target="_blank" href="${cert.verificationURL}">Verify</a>
                                    <c:if test="${cert.status != 'Revoked'}">
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/certificates" style="display:inline;">
                                            <input type="hidden" name="action" value="revoke">
                                            <input type="hidden" name="certificateId" value="${cert.certificateId}">
                                            <button class="btn btn-danger btn-sm" type="submit" onclick="return confirm('Revoke this certificate?');">Revoke</button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="section-card" style="margin-top:16px;">
            <h3>Template Preview</h3>
            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/certificate/template?back=${pageContext.request.contextPath}/instructor/certificates">Open Preview Template</a>
        </div>
    </div>
</main>
</body>
</html>
