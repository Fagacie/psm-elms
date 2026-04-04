<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="studentProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate | PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-certificate-v2.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Certificate</h1><p>View and download your course credential</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/profile" class="sv-profile-link"><c:choose><c:when test="${not empty studentProfilePicture}"><c:choose><c:when test="${fn:startsWith(studentProfilePicture, 'http')}"><img src="${studentProfilePicture}" alt="Profile" class="sv-avatar-img"></c:when><c:otherwise><img src="${pageContext.request.contextPath}${studentProfilePicture}" alt="Profile" class="sv-avatar-img"></c:otherwise></c:choose></c:when><c:otherwise><i class="fas fa-user"></i></c:otherwise></c:choose><span>${sessionScope.userName}</span></a><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link active"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main sc-page">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>Certificate</span>
        </div>

        <c:if test="${param.error == 'noteligible'}">
            <div class="alert alert-error">
                <i class="fas fa-circle-exclamation"></i>
                Certificate cannot be generated yet. ${eligibilitySummary}
            </div>
        </c:if>
        <c:if test="${param.error == 'generatefail'}">
            <div class="alert alert-error">
                <i class="fas fa-triangle-exclamation"></i>
                Certificate generation did not complete. Please retry in a moment.
            </div>
        </c:if>

        <section class="sv-card sc-header-card">
            <div class="sv-card-body sc-header-body">
                <div class="sc-header-copy">
                    <span class="sc-label">Verified Learning Credential</span>
                    <h2>Your Course Certificate</h2>
                    <p>Designed for printing and PDF export with verification details preserved.</p>
                </div>
                <div class="sc-toolbar" role="group" aria-label="Certificate actions">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning">
                        <i class="fas fa-arrow-left"></i>
                        <span>Back to Learning Hub</span>
                    </a>
                    <button class="sv-btn primary sc-print-btn" type="button" onclick="window.print()">
                        <i class="fas fa-download"></i>
                        <span>Download / Print</span>
                    </button>
                </div>
            </div>
        </section>

        <c:choose>
            <c:when test="${not eligible}">
                <section class="sv-card">
                    <div class="sv-card-body">
                        <div class="alert alert-error">Certificate is not available yet. ${eligibilitySummary}</div>
                        <div class="sc-diag">
                            <strong>Eligibility Diagnostics</strong>
                            <div class="sc-diag-grid">
                                <div class="sc-diag-item"><span>Payment Status</span><strong>${diagPaid ? 'Paid' : 'Not Paid'}</strong></div>
                                <div class="sc-diag-item"><span>Course Completion</span><strong>${diagCompleted ? 'Completed' : 'Not Completed'} (Progress: ${diagProgress}%)</strong></div>
                                <div class="sc-diag-item"><span>Assessments</span><strong>${diagPassedRequiredAssessments ? 'All Passed' : 'Pending/Failed'} (${diagPassedAssessments}/${diagTotalAssessments})</strong></div>
                                <div class="sc-diag-item"><span>Materials Viewed</span><strong>${diagViewedMaterials}/${diagTotalMaterials}</strong></div>
                            </div>
                            <div class="sv-gap-top-10">
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning">Open Learning Checklist</a>
                                <a class="sv-btn" href="${pageContext.request.contextPath}/student/certificates">Back to Certificate Center</a>
                            </div>
                        </div>
                    </div>
                </section>
            </c:when>
            <c:when test="${empty certificate}">
                <section class="sv-card">
                    <div class="sv-card-body">
                        <c:choose>
                            <c:when test="${canGenerate}">
                                <div class="alert alert-info">Certificate not generated yet. Generate it to create a verifiable credential.</div>
                                <form method="post" action="${pageContext.request.contextPath}/student/certificate" class="sv-gap-top-10">
                                    <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                    <button class="sv-btn primary" type="submit">Generate Certificate</button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-error">Certificate generation failed. Please refresh and try again.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </section>
            </c:when>
            <c:otherwise>
                <c:if test="${certificate.status == 'Revoked'}">
                    <div class="alert alert-error">This certificate has been revoked. Please contact support for clarification.</div>
                </c:if>
                <section class="sc-sheet">
                    <div class="sc-corners" aria-hidden="true">
                        <span></span><span></span><span></span><span></span>
                    </div>
                    <div class="sc-header">
                        <div>
                            <div class="sc-kicker">PSM E-Learning Platform</div>
                            <h2 class="sc-title">Certificate of Completion</h2>
                            <p class="sc-sub">Official Learning Credential</p>
                        </div>
                        <span class="sc-seal">Official Certificate</span>
                    </div>

                    <p class="sc-line">This is to certify that</p>
                    <div class="sc-name-wrap"><div class="sc-name">${studentUser.fullName}</div></div>

                    <div class="sc-details">
                        Registration Number: <strong><c:out value="${studentProfile.regNumber}" default="N/A"/></strong><br>
                        has successfully completed the course<br>
                        <strong>${course.courseName}</strong>
                    </div>

                    <div class="sc-grid">
                        <div class="sc-box">
                            <span>Certificate Number</span>
                            <strong>${certificate.certificateNo}</strong>
                        </div>
                        <div class="sc-box">
                            <span>Issue Date</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>
                        <div class="sc-box">
                            <span>Generated By</span>
                            <strong>${certificate.generatedBy}</strong>
                        </div>
                    </div>

                    <c:if test="${not empty certificate.qrCodePath}">
                        <div class="sc-qr">
                            <c:choose>
                                <c:when test="${certificate.qrCodePath.startsWith('http')}">
                                    <img src="${certificate.qrCodePath}" alt="Certificate QR Code">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/${certificate.qrCodePath}" alt="Certificate QR Code">
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                    <div class="sc-verify">
                        <strong>Verification Code:</strong> ${certificate.certificateNo}
                        <span class="sc-verify-help">Use this code on the public verification page from the landing site.</span>
                    </div>
                </section>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

