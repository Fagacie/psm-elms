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

                                    <!-- Certificate: minimal, elegant A4 landscape design -->
                                    <div class="vc_certificateWrapper">
                                        <section class="sc-sheet" id="certificateDocument">
                                            <!-- Subtle watermark behind content -->
                                            <div class="sc-watermark" aria-hidden="true">
                                                <svg viewBox="0 0 100 120" width="380" height="380" xmlns="http://www.w3.org/2000/svg">
                                                    <!-- Shield shape -->
                                                    <path d="M50 8 L88 22 V58 C88 80 72 98 50 106 C28 98 12 80 12 58 V22 Z" fill="none" stroke="#1e3a5f" stroke-width="1.8"/>
                                                    <!-- Book inside -->
                                                    <line x1="50" y1="38" x2="50" y2="82" stroke="#1e3a5f" stroke-width="1.2"/>
                                                    <path d="M26 45 C35 40 45 40 50 44 C55 40 65 40 74 45 L74 80 C65 75 55 75 50 78 C45 75 35 75 26 80 Z" fill="none" stroke="#1e3a5f" stroke-width="1.2"/>
                                                    <path d="M50 30 L58 36 L50 42 L42 36 Z" fill="none" stroke="#1e3a5f" stroke-width="1.2"/>
                                                </svg>
                                            </div>

                                            <!-- Outer double-rule border frame -->
                                            <div class="sc-frame-outer"></div>
                                            <div class="sc-frame-inner"></div>

                                            <!-- Main content, centered -->
                                            <div class="sc-content-area">
                                                <!-- Institution seal + name -->
                                                <div class="sc-seal-row">
                                                    <svg class="sc-seal-icon" viewBox="0 0 60 72" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                                                        <path d="M30 4 L54 13 V36 C54 50 44 61 30 66 C16 61 6 50 6 36 V13 Z" fill="#1e3a5f"/>
                                                        <line x1="30" y1="22" x2="30" y2="54" stroke="white" stroke-width="1.5"/>
                                                        <path d="M14 29 C20 25 27 25 30 28 C33 25 40 25 46 29 L46 52 C40 48 33 48 30 50 C27 48 20 48 14 52 Z" fill="none" stroke="white" stroke-width="1.5"/>
                                                        <path d="M30 16 L35 21 L30 26 L25 21 Z" fill="white"/>
                                                    </svg>
                                                    <div class="sc-institution-block">
                                                        <p class="sc-institution-name">PSM E-LEARNING ACADEMY</p>
                                                        <p class="sc-institution-sub">Office of Academic Records &amp; Certification</p>
                                                    </div>
                                                </div>

                                                <!-- Certificate title with elegant rule -->
                                                <div class="sc-title-block">
                                                    <h1 class="sc-title">Certificate of Completion</h1>
                                                    <div class="sc-title-rule"><span></span></div>
                                                </div>

                                                <!-- Presentation copy -->
                                                <p class="sc-presented-text">This is to certify that</p>

                                                <!-- Recipient name — the visual centrepiece -->
                                                <h2 class="sc-recipient-name">${studentUser.fullName}</h2>

                                                <!-- Course statement -->
                                                <p class="sc-completion-text">has successfully completed the course</p>
                                                <h3 class="sc-course-name">${course.courseName}</h3>

                                                <!-- Thin divider rule -->
                                                <div class="sc-mid-rule"></div>

                                                <!-- Footer metadata row -->
                                                <div class="sc-footer-row">
                                                    <div class="sc-meta-items">
                                                        <div class="sc-meta-item">
                                                            <span class="sc-meta-label">Student ID</span>
                                                            <span class="sc-meta-val"><c:out value="${studentProfile.regNumber}" default="N/A"/></span>
                                                        </div>
                                                        <div class="sc-meta-sep"></div>
                                                        <div class="sc-meta-item">
                                                            <span class="sc-meta-label">Certificate No.</span>
                                                            <span class="sc-meta-val">${certificate.certificateNo}</span>
                                                        </div>
                                                        <div class="sc-meta-sep"></div>
                                                        <div class="sc-meta-item">
                                                            <span class="sc-meta-label">Issued On</span>
                                                            <span class="sc-meta-val">
                                                                <c:choose>
                                                                    <c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                    </div>
                                                    <!-- QR Code -->
                                                    <div class="sc-qr-block">
                                                        <c:if test="${not empty certificate.qrCodePath}">
                                                            <c:choose>
                                                                <c:when test="${certificate.qrCodePath.startsWith('http')}">
                                                                    <img class="sc-qr-img" src="${certificate.qrCodePath}" alt="Verification QR">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <img class="sc-qr-img" src="${pageContext.request.contextPath}/${certificate.qrCodePath}" alt="Verification QR">
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:if>
                                                        <p class="sc-qr-caption">Scan to verify</p>
                                                    </div>
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
                                    // Updated selector to match new redesigned certificate element
                                    var certificateNode = document.getElementById('certificateDocument') || document.querySelector('.sc-sheet');

                                    if (downloadBtn && certificateNode) {
                                        downloadBtn.addEventListener('click', function () {
                                            var originalHTML = downloadBtn.innerHTML;
                                            downloadBtn.disabled = true;
                                            downloadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> <span>Generating PDF...</span>';

                                            // Wait for fonts to fully render before capturing
                                            document.fonts.ready.then(function () {
                                                return html2canvas(certificateNode, {
                                                    scale: 4,
                                                    useCORS: true,
                                                    allowTaint: false,
                                                    backgroundColor: '#ffffff',
                                                    logging: false,
                                                    imageTimeout: 0
                                                });
                                            }).then(function (canvas) {
                                                var imgData = canvas.toDataURL('image/png');
                                                var { jsPDF } = window.jspdf;
                                                var pdf = new jsPDF({
                                                    orientation: 'landscape',
                                                    unit: 'mm',
                                                    format: 'a4',
                                                    compress: true
                                                });
                                                // Fill the entire A4 page
                                                pdf.addImage(imgData, 'PNG', 0, 0, 297, 210, undefined, 'FAST');
                                                var certNo = '${certificate.certificateNo}' || 'PSM_Certificate';
                                                var filename = certNo.replace(/[^a-z0-9_-]+/gi, '_') + '.pdf';
                                                // Always use .save() — never output('datauristring') which opens new tab
                                                pdf.save(filename);
                                            }).catch(function (err) {
                                                console.error('PDF generation failed:', err);
                                                alert('PDF generation failed. Please try again or use your browser Print option (Ctrl+P).');
                                            }).finally(function () {
                                                downloadBtn.disabled = false;
                                                downloadBtn.innerHTML = originalHTML;
                                            });
                                        });
                                    }

                                    // Auto-trigger download if ?download=pdf param is set
                                    if ('${param.download}' === 'pdf') {
                                        window.addEventListener('load', function () {
                                            // Delay slightly to ensure all assets are ready
                                            window.setTimeout(function () {
                                                if (downloadBtn) downloadBtn.click();
                                            }, 800);
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
