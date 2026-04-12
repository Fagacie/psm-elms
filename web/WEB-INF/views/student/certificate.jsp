<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate | PSM E-Learning</title>
    <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-certificate-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Certificate"/>
<c:set var="topbarSubtitle" value="View, download, and verify this credential"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="certificates"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main sc-page">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/certificates">Certificates</a>
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
                    <h2>Course Certificate</h2>
                    <p>System auto generated credential for completed learning.</p>
                </div>
                <div class="sc-toolbar" role="group" aria-label="Certificate actions">
                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning">
                        <i class="fas fa-arrow-left"></i>
                        <span>Back to Learning Hub</span>
                    </a>
                    <button id="studentCertDownloadPngBtn" class="sv-btn primary" type="button">
                        <i class="fas fa-image"></i>
                        <span>Download PNG</span>
                    </button>
                    <button class="sv-btn sc-print-btn" type="button" onclick="window.print()">
                        <i class="fas fa-download"></i>
                        <span>Print</span>
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
                    <div class="sc-top-art">
                        <div class="sc-wave sc-wave-back"></div>
                        <div class="sc-wave sc-wave-mid"></div>
                        <div class="sc-wave sc-wave-front"></div>
                        <div class="sc-award-badge" aria-hidden="true">
                            <div class="sc-award-core">
                                <span>PSM</span>
                                <strong>AWARD</strong>
                            </div>
                        </div>
                        <div class="sc-title-panel">
                            <span class="sc-title-main">CERTIFICATE</span>
                            <span class="sc-title-sub">OF ACHIEVEMENT</span>
                        </div>
                    </div>

                    <div class="sc-body">
                        <div class="sc-content">
                            <p class="sc-kicker">Proudly Presented To</p>
                            <div class="sc-name-wrap"><div class="sc-name">${studentUser.fullName}</div></div>
                            <p class="sc-statement">
                                This certifies that registration number
                                <strong><c:out value="${studentProfile.regNumber}" default="N/A"/></strong>
                                has successfully completed the approved learning requirements for
                            </p>
                            <div class="sc-course-pill">${course.courseName}</div>
                            <div class="sc-meta-inline">
                                <span><strong>Reg No:</strong> <c:out value="${studentProfile.regNumber}" default="N/A"/></span>
                                <span>
                                    <strong>Issue Date:</strong>
                                    <c:choose>
                                        <c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </span>
                                <span><strong>Certificate No:</strong> ${certificate.certificateNo}</span>
                            </div>
                        </div>

                        <div class="sc-footer">
                            <div class="sc-signature-block">
                                <strong>PSM E-Learning Platform</strong>
                                <small>Academic Records</small>
                            </div>

                            <div class="sc-signature-block">
                                <strong>Registrar</strong>
                                <small>
                                    <c:choose>
                                        <c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when>
                                        <c:otherwise>Issue date pending</c:otherwise>
                                    </c:choose>
                                </small>
                            </div>

                            <div class="sc-verify-panel">
                                <span class="sc-verify-label">Verification Code</span>
                                <strong>${certificate.certificateNo}</strong>
                                <small><c:out value="${certificate.verificationURL}" default="${pageContext.request.contextPath}/certificate/verify"/></small>
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
                    </div>
                </section>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
    (function () {
        var downloadBtn = document.getElementById('studentCertDownloadPngBtn');
        var certificateNode = document.querySelector('.sc-sheet');

        if (!downloadBtn || !certificateNode) {
            return;
        }

        function waitForImages(node) {
            var images = Array.prototype.slice.call(node.querySelectorAll('img'));
            if (!images.length) {
                return Promise.resolve();
            }

            return Promise.all(images.map(function (img) {
                if (img.complete) {
                    return Promise.resolve();
                }
                return new Promise(function (resolve) {
                    img.addEventListener('load', resolve, { once: true });
                    img.addEventListener('error', resolve, { once: true });
                });
            }));
        }

        function exportPng() {
            if (typeof html2canvas === 'undefined') {
                alert('PNG export is unavailable right now. Please try print.');
                return;
            }

            var targetWidth = 2000;
            var targetHeight = 1414;
            var originalLabel = downloadBtn.innerHTML;
            downloadBtn.disabled = true;
            downloadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i><span>Preparing PNG...</span>';

            var afterFonts = document.fonts && document.fonts.ready
                ? document.fonts.ready
                : Promise.resolve();

            afterFonts
                .then(function () {
                    return waitForImages(certificateNode);
                })
                .then(function () {
                    var ratioScale = Math.max(targetWidth / Math.max(certificateNode.clientWidth, 1), 2);
                    return html2canvas(certificateNode, {
                        backgroundColor: '#ffffff',
                        useCORS: true,
                        allowTaint: false,
                        scale: Math.min(ratioScale, 4)
                    });
                })
                .then(function (canvas) {
                var output = document.createElement('canvas');
                output.width = targetWidth;
                output.height = targetHeight;
                var ctx = output.getContext('2d');
                ctx.fillStyle = '#ffffff';
                ctx.fillRect(0, 0, targetWidth, targetHeight);

                var fitScale = Math.min(targetWidth / canvas.width, targetHeight / canvas.height);
                var drawWidth = canvas.width * fitScale;
                var drawHeight = canvas.height * fitScale;
                var dx = (targetWidth - drawWidth) / 2;
                var dy = (targetHeight - drawHeight) / 2;
                ctx.drawImage(canvas, dx, dy, drawWidth, drawHeight);

                var certNo = '${certificate.certificateNo}' || 'certificate';
                var filename = certNo.replace(/[^a-z0-9_-]+/gi, '_').replace(/^_+|_+$/g, '') + '.png';
                if (filename === '.png') {
                    filename = 'certificate.png';
                }

                var link = document.createElement('a');
                link.href = output.toDataURL('image/png');
                link.download = filename;
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }).catch(function (error) {
                console.error('Student certificate PNG export failed:', error);
                alert('Could not export PNG. Please try again or use print.');
            }).finally(function () {
                downloadBtn.disabled = false;
                downloadBtn.innerHTML = originalLabel;
            });
        }

        downloadBtn.addEventListener('click', exportPng);

        if ('${param.download}' === 'png') {
            var triggerAutoExport = function () {
                window.setTimeout(exportPng, 220);
            };
            if (document.readyState === 'complete') {
                triggerAutoExport();
            } else {
                window.addEventListener('load', triggerAutoExport, { once: true });
            }
        }
    })();
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
