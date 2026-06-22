<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Credential Verification Hub | PSM E-Learning</title>
                <!-- Vector/HTML Capturing -->
                <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
                <!-- PDF Document Compiler -->
                <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
                <!-- Academic Serif & Sans Fonts -->
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
                <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />
                <!-- Redesigned Certificate CSS Sheet -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-certificate-v2.css">
                <!-- Scoped ViewCertificate CSS Module -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ViewCertificate.module.css">
            </head>

            <body class="sv-page">
                <c:set var="topbarTitle" value="Certificate Details" />
                <c:set var="topbarSubtitle" value="View, print, and verify your course credential" />
                <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

                <div class="sv-layout">
                    <c:set var="activePage" value="certificates" />
                    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

                    <main class="sv-main cert-page" style="display: flex; flex-direction: column; align-items: center; padding: 32px 24px; min-height: calc(100vh - 68px); background-color: var(--surface-bg);">
                        
                        <!-- Navigation Breadcrumb -->
                        <div class="sv-breadcrumb" style="width: 100%; max-width: 1000px; margin-bottom: 32px;">
                            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                            <span>/</span>
                            <a href="${pageContext.request.contextPath}/student/certificates">Certificates</a>
                            <span>/</span>
                            <span style="color: var(--text-primary); font-weight: 600;">View Certificate</span>
                        </div>

                        <div style="width: 100%; max-width: 1000px; display: flex; flex-direction: column; gap: 24px;">

                            <!-- Error & Info Alerts -->
                            <c:if test="${param.error == 'noteligible'}">
                                <div class="lh-alert lh-alert-error" style="background: var(--danger-soft); color: var(--danger); padding: 16px; border-radius: 8px; display: flex; align-items: center; gap: 12px;">
                                    <i class="fas fa-circle-exclamation"></i>
                                    <span>Certificate cannot be generated yet. ${eligibilitySummary}</span>
                                </div>
                            </c:if>
                            <c:if test="${param.error == 'generatefail'}">
                                <div class="lh-alert lh-alert-error" style="background: var(--danger-soft); color: var(--danger); padding: 16px; border-radius: 8px; display: flex; align-items: center; gap: 12px;">
                                    <i class="fas fa-triangle-exclamation"></i>
                                    <span>Certificate generation did not complete. Please retry in a moment.</span>
                                </div>
                            </c:if>
                            <c:if test="${param.error == 'nocertificatefree'}">
                                <div class="lh-alert lh-alert-info" style="background: var(--info-soft); color: var(--info); padding: 16px; border-radius: 8px; display: flex; align-items: center; gap: 12px;">
                                    <i class="fas fa-circle-info"></i>
                                    <span>Free courses do not issue certificates. Continue learning directly from your learning hub.</span>
                                </div>
                            </c:if>

                            <c:choose>
                                <c:when test="${not eligible}">
                                    <!-- Elegantly designed Eligibility Diagnostics Card -->
                                    <section class="lh-post-assessment-card" style="max-width: 100%; margin: 0 auto;">
                                        <div class="lh-post-status-icon is-error" style="width: 4rem; height: 4rem; font-size: 2rem;">
                                            <i class="fas fa-lock"></i>
                                        </div>
                                        <h2 class="lh-post-title" style="font-size: 1.5rem;">Certificate Locked</h2>
                                        <p class="lh-post-desc" style="max-width: 600px;">
                                            You must complete all syllabus milestones and achieve passing performance before your official credential can be issued.
                                        </p>

                                        <div class="lh-post-score-section" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; text-align: left; margin: 32px 0;">
                                            <div class="lh-post-score-metric" style="background: var(--surface-primary); padding: 16px; border-radius: 8px; border: 1px solid var(--border-subtle);">
                                                <span>Payment Status</span>
                                                <strong style="color: ${diagPaid ? 'var(--success)' : 'var(--danger)'}; font-size: 1.25rem;">
                                                    ${diagPaid ? 'Paid' : 'Not Paid'}
                                                </strong>
                                            </div>
                                            <div class="lh-post-score-metric" style="background: var(--surface-primary); padding: 16px; border-radius: 8px; border: 1px solid var(--border-subtle);">
                                                <span>Course Progress</span>
                                                <strong style="color: ${diagCompleted ? 'var(--success)' : 'var(--danger)'}; font-size: 1.25rem;">
                                                    ${diagCompleted ? 'Completed' : 'Incomplete'} (${diagProgress}%)
                                                </strong>
                                            </div>
                                            <div class="lh-post-score-metric" style="background: var(--surface-primary); padding: 16px; border-radius: 8px; border: 1px solid var(--border-subtle);">
                                                <span>Assessments</span>
                                                <strong style="color: ${diagPassedRequiredAssessments ? 'var(--success)' : 'var(--danger)'}; font-size: 1.25rem;">
                                                    ${diagPassedRequiredAssessments ? 'Passed' : 'Pending'} (${diagPassedAssessments}/${diagTotalAssessments})
                                                </strong>
                                            </div>
                                        </div>

                                        <div class="lh-post-actions">
                                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning">
                                                <i class="fas fa-book-open"></i> Resume Learning
                                            </a>
                                            <a class="sv-btn secondary" href="${pageContext.request.contextPath}/student/certificates">
                                                Back to Certificates
                                            </a>
                                        </div>
                                    </section>
                                </c:when>
                                
                                <c:when test="${empty certificate}">
                                    <!-- Unissued State Certificate Unlock -->
                                    <section class="lh-post-assessment-card" style="max-width: 100%; margin: 0 auto;">
                                        <div class="lh-post-status-icon is-success" style="width: 4rem; height: 4rem; font-size: 2rem;">
                                            <i class="fas fa-award"></i>
                                        </div>
                                        <h2 class="lh-post-title" style="font-size: 1.5rem;">Certificate Unlocked!</h2>
                                        
                                        <c:choose>
                                            <c:when test="${canGenerate}">
                                                <p class="lh-post-desc" style="max-width: 600px;">
                                                    Congratulations! You have completed all course requirements. Generate your official, verifiable digital credential now.
                                                </p>
                                                <div class="lh-post-actions" style="margin-top: 24px;">
                                                    <form method="post" action="${pageContext.request.contextPath}/student/certificate" style="margin: 0;">
                                                        <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                                                        <button class="sv-btn primary" type="submit">
                                                            <i class="fas fa-file-signature"></i> Generate Certificate
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="lh-post-desc" style="max-width: 600px; color: var(--danger);">
                                                    Certificate generation failed. Please refresh and try again.
                                                </p>
                                            </c:otherwise>
                                        </c:choose>
                                    </section>
                                </c:when>
                                
                                <c:otherwise>
                                    <c:if test="${certificate.status == 'Revoked'}">
                                        <div class="lh-alert lh-alert-error" style="background: var(--danger-soft); color: var(--danger); padding: 16px; border-radius: 8px; display: flex; align-items: center; gap: 12px; margin-bottom: 24px;">
                                            <i class="fas fa-circle-xmark"></i>
                                            <span>This certificate has been revoked. Please contact support for clarification.</span>
                                        </div>
                                    </c:if>

                                    <!-- A4 locked container with heavy dropshadow placed flat on a slate desk -->
                                    <div class="vc_certificateWrapper">
                                        <section class="sc-sheet">
                                            <!-- Border and Corners -->
                                            <div class="sc-border-outer"></div>
                                            <div class="sc-border-inner"></div>
                                            <div class="sc-corner-tl"></div>
                                            <div class="sc-corner-tr"></div>
                                            <div class="sc-corner-bl"></div>
                                            <div class="sc-corner-br"></div>
                                            
                                            <!-- Left Banner -->
                                            <div class="sc-left-banner">
                                                <div class="sc-banner-text">
                                                    <span>P</span>
                                                    <span class="sc-banner-dot">&bull;</span>
                                                    <span>S</span>
                                                    <span class="sc-banner-dot">&bull;</span>
                                                    <span>M</span>
                                                </div>
                                            </div>

                                            <div class="sc-content-wrapper">
                                                <!-- Watermark -->
                                                <div class="sc-watermark">
                                                    <svg viewBox="0 0 100 100" width="450" height="450">
                                                        <path d="M50 15 L80 25 V55 C80 72 68 83 50 88 C32 83 20 72 20 55 V25 Z" fill="none" stroke="#0f172a" stroke-width="2.5"></path>
                                                        <line x1="50" y1="15" x2="50" y2="88" stroke="#0f172a" stroke-width="1.5"></line>
                                                        <line x1="20" y1="46" x2="80" y2="46" stroke="#0f172a" stroke-width="1.5"></line>
                                                        <circle cx="35" cy="33" r="3.5" fill="#0f172a"></circle>
                                                        <circle cx="65" cy="33" r="3.5" fill="#0f172a"></circle>
                                                        <path d="M38 64 C42 60 48 60 50 63 C52 60 58 60 62 64 V52 C58 49 52 49 50 51 C48 49 42 49 38 52 Z" fill="none" stroke="#0f172a" stroke-width="1.5"></path>
                                                    </svg>
                                                </div>
                                                <!-- Top Crest -->
                                                <div class="sc-crest">
                                                    <svg class="sc-crest-svg" viewBox="0 0 100 100" width="44" height="44">
                                                        <path d="M50 15 L80 25 V55 C80 72 68 83 50 88 C32 83 20 72 20 55 V25 Z" fill="none" stroke="#0f172a" stroke-width="2.5"></path>
                                                        <line x1="50" y1="15" x2="50" y2="88" stroke="#0f172a" stroke-width="1.5"></line>
                                                        <line x1="20" y1="46" x2="80" y2="46" stroke="#0f172a" stroke-width="1.5"></line>
                                                        <circle cx="35" cy="33" r="3.5" fill="#0f172a"></circle>
                                                        <circle cx="65" cy="33" r="3.5" fill="#0f172a"></circle>
                                                        <path d="M38 64 C42 60 48 60 50 63 C52 60 58 60 62 64 V52 C58 49 52 49 50 51 C48 49 42 49 38 52 Z" fill="none" stroke="#0f172a" stroke-width="1.5"></path>
                                                    </svg>
                                                    <h4 class="sc-platform-name">PSM E-LEARNING ACADEMY</h4>
                                                </div>

                                                <h1 class="sc-title">CERTIFICATE OF COMPLETION</h1>
                                                
                                                <div class="sc-divider-diamond"><span></span></div>

                                                <!-- Centered Recipient & Program Description -->
                                                <div class="sc-body-content">
                                                    <p class="sc-recipient-lbl">PRESENTED TO</p>
                                                    <h2 class="sc-recipient-name">${studentUser.fullName}</h2>
                                                    <p class="sc-award-statement">FOR SUCCESSFULLY COMPLETING THE PROGRAM</p>
                                                    <h3 class="sc-course-name">${course.courseName}</h3>
                                                </div>

                                                <!-- Structured Metadata & QR -->
                                                <div class="sc-footer-row">
                                                    <div class="sc-footer-info">
                                                        <div class="sc-info-col">
                                                            <div class="sc-info-icon"><i class="fas fa-user-circle"></i></div>
                                                            <span class="sc-info-label">STUDENT ID</span>
                                                            <span class="sc-info-val"><c:out value="${studentProfile.regNumber}" default="N/A" /></span>
                                                        </div>
                                                        <div class="sc-info-divider"></div>
                                                        <div class="sc-info-col">
                                                            <div class="sc-info-icon"><i class="fas fa-file-contract"></i></div>
                                                            <span class="sc-info-label">CERTIFICATE NO.</span>
                                                            <span class="sc-info-val">${certificate.certificateNo}</span>
                                                        </div>
                                                        <div class="sc-info-divider"></div>
                                                        <div class="sc-info-col">
                                                            <div class="sc-info-icon"><i class="fas fa-calendar-alt"></i></div>
                                                            <span class="sc-info-label">ISSUED ON</span>
                                                            <span class="sc-info-val">
                                                                <c:choose>
                                                                    <c:when test="${not empty certificate.issueDate}">
                                                                        ${certificate.issueDate.toLocalDate()}</c:when>
                                                                    <c:otherwise>-</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="sc-qr-section">
                                                        <c:if test="${not empty certificate.qrCodePath}">
                                                            <c:choose>
                                                                <c:when test="${certificate.qrCodePath.startsWith('http')}">
                                                                    <img class="sc-qr-image" src="${certificate.qrCodePath}" alt="Verification QR Code">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <img class="sc-qr-image" src="${pageContext.request.contextPath}/${certificate.qrCodePath}" alt="Verification QR Code">
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:if>
                                                        <div class="sc-qr-text">
                                                            <strong>SCAN TO VERIFY</strong>THIS CERTIFICATE
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Verification Bottom Text -->
                                                <div class="sc-footer-bottom">
                                                    <div class="sc-divider-diamond-small"><span></span></div>
                                                    <p class="sc-verification-text">THIS CERTIFICATE IS DIGITALLY GENERATED AND CAN BE VERIFIED USING THE QR CODE.</p>
                                                </div>
                                            </div>
                                        </section>
                                    </div>

                                    <!-- Sleek verification board below the certificate frame -->
                                    <div class="lh-post-assessment-card" style="max-width: 900px; margin: 32px auto 0; text-align: left; align-items: flex-start;">
                                        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 24px;">
                                            <div class="lh-post-status-icon is-success" style="width: 3rem; height: 3rem; font-size: 1.5rem; margin: 0;">
                                                <i class="fas fa-check-circle"></i>
                                            </div>
                                            <h4 class="lh-post-title" style="font-size: 1.25rem; margin: 0;">Verified Institutional Credential</h4>
                                        </div>

                                        <div class="lh-post-score-section" style="width: 100%; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin: 0; padding: 24px; background: var(--surface-bg);">
                                            <div class="lh-post-score-metric" style="align-items: flex-start; text-align: left;">
                                                <span>Recipient Student</span>
                                                <strong style="font-size: 1.1rem; font-weight: 700;">${studentUser.fullName}</strong>
                                            </div>
                                            <div class="lh-post-score-metric" style="align-items: flex-start; text-align: left;">
                                                <span>Course Program</span>
                                                <strong style="font-size: 1.1rem; font-weight: 700;">${course.courseName}</strong>
                                            </div>
                                            <div class="lh-post-score-metric" style="align-items: flex-start; text-align: left;">
                                                <span>Issued Date</span>
                                                <strong style="font-size: 1.1rem; font-weight: 700;">
                                                    <c:choose>
                                                        <c:when test="${not empty certificate.issueDate}">
                                                            ${certificate.issueDate.toLocalDate()}</c:when>
                                                        <c:otherwise>-</c:otherwise>
                                                    </c:choose>
                                                </strong>
                                            </div>
                                            <div class="lh-post-score-metric" style="align-items: flex-start; text-align: left;">
                                                <span>Credential ID</span>
                                                <strong style="font-size: 1.1rem; font-weight: 700; font-family: monospace;">${certificate.certificateNo}</strong>
                                            </div>
                                        </div>

                                        <c:if test="${certificate.status != 'Revoked'}">
                                            <!-- Action Buttons Side-by-Side -->
                                            <div style="display: flex; gap: 16px; margin-top: 24px; width: 100%;">
                                                <button id="studentCertDownloadPdfBtn" class="sv-btn primary" type="button" style="flex: 2; justify-content: center;">
                                                    <i class="fas fa-file-pdf"></i> Download Official High-Res PDF
                                                </button>
                                                <button id="studentCertShareBtn" class="sv-btn secondary" type="button" style="flex: 1; justify-content: center;">
                                                    <i class="fas fa-share-nodes"></i> Share Credential
                                                </button>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <!-- Simple Sleek Copy Toast -->
                            <div class="sc-toast" id="scToast">Certificate link copied to clipboard</div>

                            <!-- Interaction Script for PDF Rendering & Action Handling -->
                            <script>
                                (function () {
                                    var downloadBtn = document.getElementById('studentCertDownloadPdfBtn');
                                    var certificateNode = document.querySelector('.sc-sheet');

                                    if (downloadBtn && certificateNode) {
                                        downloadBtn.addEventListener('click', function () {
                                            var originalHTML = downloadBtn.innerHTML;
                                            downloadBtn.disabled = true;
                                            downloadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> <span>Compiling PDF...</span>';

                                            // Save original responsive styles
                                            var originalStyle = certificateNode.getAttribute('style');

                                            // Ensure Google fonts are fully drawn to the canvas before compiling PDF
                                            document.fonts.ready.then(function () {
                                                return html2canvas(certificateNode, {
                                                    scale: 4, // Quad scaling for ultra high-resolution print quality
                                                    useCORS: true,
                                                    allowTaint: false,
                                                    backgroundColor: '#ffffff'
                                                });
                                            }).then(function (canvas) {
                                                var imgData = canvas.toDataURL('image/png');

                                                // PDF Dimensions corresponding perfectly to A4 Landscape bounds (297mm x 210mm)
                                                var { jsPDF } = window.jspdf;
                                                var pdf = new jsPDF({
                                                    orientation: 'landscape',
                                                    unit: 'mm',
                                                    format: 'a4',
                                                    compress: true
                                                });

                                                pdf.addImage(imgData, 'PNG', 0, 0, 297, 210, undefined, 'FAST');

                                                var certNo = '${certificate.certificateNo}' || 'PSM_Certificate';
                                                var filename = certNo.replace(/[^a-z0-9_-]+/gi, '_') + '.pdf';

                                                pdf.save(filename);
                                            }).catch(function (err) {
                                                console.error('High-fidelity PDF generation failed:', err);
                                                alert('High-resolution PDF generation failed. Please use Chrome Print options.');
                                            }).finally(function () {
                                                // Restore original styling properties
                                                if (originalStyle) {
                                                    certificateNode.setAttribute('style', originalStyle);
                                                } else {
                                                    certificateNode.removeAttribute('style');
                                                }
                                                downloadBtn.disabled = false;
                                                downloadBtn.innerHTML = originalHTML;
                                            });
                                        });
                                    }

                                    // Automatic PDF Trigger for direct list-view commands
                                    if ('${param.download}' === 'pdf') {
                                        window.addEventListener('load', function () {
                                            window.setTimeout(function () {
                                                if (downloadBtn) downloadBtn.click();
                                            }, 400);
                                        }, { once: true });
                                    }

                                    // Elegant Share Button Integration
                                    var shareBtn = document.getElementById('studentCertShareBtn');
                                    var toast = document.getElementById('scToast');

                                    if (shareBtn) {
                                        shareBtn.addEventListener('click', function () {
                                            var copyText = '${certificate.verificationURL}' || (window.location.origin + '${pageContext.request.contextPath}/certificate/verify?code=${certificate.certificateNo}');

                                            function showToast() {
                                                if (toast) {
                                                    toast.classList.add('show');
                                                    window.setTimeout(function () {
                                                        toast.classList.remove('show');
                                                    }, 2500);
                                                }
                                            }

                                            if (navigator.clipboard && navigator.clipboard.writeText) {
                                                navigator.clipboard.writeText(copyText).then(showToast).catch(function () {
                                                    fallbackCopy(copyText, showToast);
                                                });
                                            } else {
                                                fallbackCopy(copyText, showToast);
                                            }
                                        });
                                    }

                                    function fallbackCopy(text, cb) {
                                        var input = document.createElement('input');
                                        input.value = text;
                                        input.style.position = 'fixed';
                                        input.style.opacity = '0';
                                        document.body.appendChild(input);
                                        input.select();
                                        try {
                                            document.execCommand('copy');
                                            cb();
                                        } catch (err) {
                                            console.error('Copy action helper failed', err);
                                        }
                                        document.body.removeChild(input);
                                    }
                                })();
                            </script>
                        </div>
                    </main>
                </div>

                <div id="svOverlay" class="sv-overlay"></div>
                <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
            </body>

            </html>