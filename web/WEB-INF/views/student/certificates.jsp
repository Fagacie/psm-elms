<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Certificates</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<nav class="top-navbar">
    <div class="top-navbar-inner">
        <div class="top-navbar-left">
            <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                <span class="logo-text">PSM</span><span class="logo-subtext">E-Learning</span>
            </a>
            <h1 class="page-title-nav">My Certificates</h1>
        </div>
        <div class="top-navbar-right">
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </div>
</nav>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item"><i class="fas fa-home"></i><span>Dashboard</span></a>
        <a href="${pageContext.request.contextPath}/student/courses" class="nav-item"><i class="fas fa-book"></i><span>Browse Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item"><i class="fas fa-graduation-cap"></i><span>My Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="nav-item"><i class="fas fa-clipboard-list"></i><span>Assessments</span></a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="nav-item active"><i class="fas fa-certificate"></i><span>Certificates</span></a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item"><i class="fas fa-user"></i><span>Profile</span></a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="section-card" style="margin-bottom:16px;">
            <h3>Ready to Generate</h3>
            <c:choose>
                <c:when test="${empty readyToGenerate}">
                    <p>No completed and paid enrollment waiting for certificate generation.</p>
                </c:when>
                <c:otherwise>
                    <table class="data-table" style="width:100%;">
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
                                <td>${enrollment.courseName}</td>
                                <td>${enrollment.completionStatus}</td>
                                <td>
                                    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/certificate?enrollmentId=${enrollment.enrollmentId}">Generate Certificate</a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="section-card">
            <h3>Issued Certificates</h3>
            <c:choose>
                <c:when test="${empty issuedCertificates}">
                    <p>No certificates generated yet.</p>
                </c:when>
                <c:otherwise>
                    <table class="data-table" style="width:100%;">
                        <thead>
                        <tr>
                            <th>Certificate No</th>
                            <th>Course</th>
                            <th>Issue Date</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="cert" items="${issuedCertificates}">
                            <tr>
                                <td>${cert.certificateNo}</td>
                                <td>${cert.courseName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty cert.issueDate}">
                                            <c:set var="dateText" value="${cert.issueDate.toString()}"/>
                                            ${fn:length(dateText) >= 10 ? fn:substring(dateText, 0, 10) : dateText}
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/certificate/template?certificateId=${cert.certificateId}&back=${pageContext.request.contextPath}/student/certificates">Template</a>
                                    <a class="btn btn-primary btn-sm" target="_blank" href="${cert.verificationURL}">Verify</a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>
</body>
</html>
