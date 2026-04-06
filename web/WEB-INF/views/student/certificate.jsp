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
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-certificate-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Certificate"/>
<c:set var="topbarSubtitle" value="View and download your course credential"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="certificates"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

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
        <c:if test="${param.error == 'nocertificatefree'}">
            <div class="alert alert-info">
                <i class="fas fa-circle-info"></i>
                Free courses do not issue certificates. Continue learning directly from your learning hub.
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
                    <div class="sc-header">
                        <div>
                            <div class="sc-kicker">PSM E-Learning Platform</div>
                            <h2 class="sc-title">Certificate of Completion</h2>
                            <p class="sc-sub">Official Learning Credential</p>
                        </div>
                        <div class="sc-header-meta">
                            <span class="sc-seal">Digitally Issued</span>
                            <span class="status-badge ${certificate.status == 'Revoked' ? 'status-Archived' : 'status-Approved'}">${certificate.status == 'Revoked' ? 'Revoked' : 'Active'}</span>
                        </div>
                    </div>

                    <p class="sc-line">This certifies that</p>
                    <div class="sc-name-wrap"><div class="sc-name">${studentUser.fullName}</div></div>

                    <div class="sc-details">
                        Registration Number: <strong><c:out value="${studentProfile.regNumber}" default="N/A"/></strong><br>
                        Student Email: <strong><c:out value="${studentUser.email}" default="N/A"/></strong><br>
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
                            <span>Enrollment ID</span>
                            <strong>#${enrollment.enrollmentId}</strong>
                        </div>
                    </div>

                    <div class="sc-endorsements">
                        <div class="sc-signature-block">
                            <div class="sc-sign-line"></div>
                            <strong><c:out value="${certificate.instructorName}" default="Instructor of Record"/></strong>
                            <span>Instructor Signature</span>
                        </div>
                        <div class="sc-stamp-block" aria-label="Institutional validation stamp">
                            <span>PSM</span>
                            <small>Verified Credential</small>
                        </div>
                        <div class="sc-signature-block">
                            <div class="sc-sign-line"></div>
                            <strong>${certificate.generatedBy}</strong>
                            <span>Authorized Signatory</span>
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
                        <span class="sc-verify-help">Verify at: <c:out value="${certificate.verificationURL}" default="${pageContext.request.contextPath}/certificate/verify"/></span>
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

