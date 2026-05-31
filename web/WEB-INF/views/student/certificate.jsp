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
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400;1,600&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <!-- Redesigned Certificate CSS Sheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-certificate-v2.css">
    <!-- Scoped ViewCertificate CSS Module -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ViewCertificate.module.css">
</head>
<body class="vc_viewport">

    <!-- Navigation Breadcrumb -->
    <a class="vc_backLink" href="${pageContext.request.contextPath}/student/certificates">
        <i class="fas fa-arrow-left"></i> <span>Back to Certificate Center</span>
    </a>

    <!-- Error & Info Alerts -->
    <div style="max-width: 900px; width: 100%; box-sizing: border-box; margin-bottom: 20px;">
        <c:if test="${param.error == 'noteligible'}">
            <div class="alert alert-error" style="border-radius: 8px; margin: 0;">
                <i class="fas fa-circle-exclamation"></i>
                <span>Certificate cannot be generated yet. ${eligibilitySummary}</span>
            </div>
        </c:if>
        <c:if test="${param.error == 'generatefail'}">
            <div class="alert alert-error" style="border-radius: 8px; margin: 0;">
                <i class="fas fa-triangle-exclamation"></i>
                <span>Certificate generation did not complete. Please retry in a moment.</span>
            </div>
        </c:if>
        <c:if test="${param.error == 'nocertificatefree'}">
            <div class="alert alert-info" style="border-radius: 8px; margin: 0;">
                <i class="fas fa-circle-info"></i>
                <span>Free courses do not issue certificates. Continue learning directly from your learning hub.</span>
            </div>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${not eligible}">
            <!-- Redesigned Minimal Sharp Diagnostics when not eligible -->
            <section class="sc-diag-card" style="width: 100%; max-width: 900px; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05); border-radius: 12px !important; border: 1px solid #cbd5e1 !important; background-color: #ffffff !important; color: #0f172a !important; padding: 32px; box-sizing: border-box;">
                <h3 class="sc-diag-title" style="color: #0f172a !important; font-size: 1.25rem; font-weight: 800; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-chart-bar" style="color: #2B5A8E;"></i> Eligibility Diagnostics
                </h3>
                <div class="alert alert-error" style="margin-bottom: 24px; border-radius: 8px; font-weight: 500;">
                    <i class="fas fa-circle-xmark"></i> Certificate is not available yet. ${eligibilitySummary}
                </div>
                <div class="sc-diag-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 28px;">
                    <div class="sc-diag-item" style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 8px !important; padding: 16px;">
                        <span style="color: #64748b !important; font-size: 0.72rem; text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Payment Status</span>
                        <strong class="${diagPaid ? 'success' : 'danger'}" style="display: block; margin-top: 6px; font-size: 1.05rem; font-weight: 700; color: ${diagPaid ? '#059669' : '#dc2626'} !important;">
                            ${diagPaid ? 'Paid' : 'Not Paid'}
                        </strong>
                    </div>
                    <div class="sc-diag-item" style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 8px !important; padding: 16px;">
                        <span style="color: #64748b !important; font-size: 0.72rem; text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Course Completion</span>
                        <strong class="${diagCompleted ? 'success' : 'danger'}" style="display: block; margin-top: 6px; font-size: 1.05rem; font-weight: 700; color: ${diagCompleted ? '#059669' : '#dc2626'} !important;">
                            ${diagCompleted ? 'Completed' : 'Not Completed'} (${diagProgress}%)
                        </strong>
                    </div>
                    <div class="sc-diag-item" style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 8px !important; padding: 16px;">
                        <span style="color: #64748b !important; font-size: 0.72rem; text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Required Assessments</span>
                        <strong class="${diagPassedRequiredAssessments ? 'success' : 'danger'}" style="display: block; margin-top: 6px; font-size: 1.05rem; font-weight: 700; color: ${diagPassedRequiredAssessments ? '#059669' : '#dc2626'} !important;">
                            ${diagPassedRequiredAssessments ? 'Passed' : 'Pending/Failed'} (${diagPassedAssessments}/${diagTotalAssessments})
                        </strong>
                    </div>
                    <div class="sc-diag-item" style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 8px !important; padding: 16px;">
                        <span style="color: #64748b !important; font-size: 0.72rem; text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Materials Viewed</span>
                        <strong class="${diagViewedAllMaterials ? 'success' : 'danger'}" style="display: block; margin-top: 6px; font-size: 1.05rem; font-weight: 700; color: ${diagViewedAllMaterials ? '#059669' : '#dc2626'} !important;">
                            ${diagViewedMaterials}/${diagTotalMaterials} Viewed
                        </strong>
                    </div>
                </div>
                <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                    <a class="vc_primaryBtn" style="width: auto;" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning">Open Learning Checklist</a>
                    <a class="vc_primaryBtn" style="width: auto; background-color: #ffffff !important; color: #0f172a !important; border: 1px solid #cbd5e1 !important;" href="${pageContext.request.contextPath}/student/certificates">Back to Certificate Center</a>
                </div>
            </section>
        </c:when>
        <c:when test="${empty certificate}">
            <!-- Unissued State Certificate Unlock -->
            <section class="sc-diag-card" style="width: 100%; max-width: 900px; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05); border-radius: 12px !important; border: 1px solid #cbd5e1 !important; background-color: #ffffff !important; color: #0f172a !important; padding: 32px; box-sizing: border-box;">
                <h3 class="sc-diag-title" style="color: #0f172a !important; font-size: 1.25rem; font-weight: 800; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-award" style="color: #2B5A8E;"></i> Certificate Issuance
                </h3>
                <c:choose>
                    <c:when test="${canGenerate}">
                        <div class="alert alert-info" style="margin-bottom: 24px; border-radius: 8px;">
                            <i class="fas fa-circle-info"></i> Your certificate is unlocked! Generate it now to create your official, verifiable digital credential.
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/student/certificate" style="margin: 0;">
                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                            <button class="vc_primaryBtn" style="width: auto;" type="submit">
                                <i class="fas fa-file-signature"></i> Generate Certificate
                            </button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-error" style="border-radius: 8px;">
                            <i class="fas fa-circle-exclamation"></i> Certificate generation failed. Please refresh and try again.
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </c:when>
        <c:otherwise>
            <c:if test="${certificate.status == 'Revoked'}">
                <div style="max-width: 900px; width: 100%; box-sizing: border-box; margin-bottom: 20px;">
                    <div class="alert alert-error" style="margin: 0; border-radius: 8px;">
                        <i class="fas fa-circle-xmark"></i> This certificate has been revoked. Please contact support for clarification.
                    </div>
                </div>
            </c:if>

            <!-- A4 locked container with heavy dropshadow placed flat on a slate desk -->
            <div class="vc_certificateWrapper">
                <section class="sc-sheet">
                    <div class="sc-inner-border"></div>

                    <!-- Top Platform Crest -->
                    <div class="sc-crest">
                        <svg class="sc-crest-svg" viewBox="0 0 100 100" width="56" height="56">
                            <path d="M50 15 L80 25 V55 C80 72 68 83 50 88 C32 83 20 72 20 55 V25 Z" fill="none" stroke="#1e293b" stroke-width="2.5"></path>
                            <path d="M50 19 L76 28 V54 C76 69 65 79 50 84 C35 79 24 69 24 54 V28 Z" fill="#2B5A8E" opacity="0.08"></path>
                            <line x1="50" y1="15" x2="50" y2="88" stroke="#1e293b" stroke-width="1.5"></line>
                            <line x1="20" y1="46" x2="80" y2="46" stroke="#1e293b" stroke-width="1.5"></line>
                            <circle cx="35" cy="33" r="3.5" fill="#1e293b"></circle>
                            <circle cx="65" cy="33" r="3.5" fill="#1e293b"></circle>
                            <path d="M38 64 C42 60 48 60 50 63 C52 60 58 60 62 64 V52 C58 49 52 49 50 51 C48 49 42 49 38 52 Z" fill="none" stroke="#1e293b" stroke-width="1.5"></path>
                        </svg>
                        <h4 class="sc-platform-name">PSM E-Learning Academy</h4>
                        <h1 class="sc-title">Certificate of Completion</h1>
                    </div>

                    <!-- Centered Recipient & Program Description -->
                    <div class="sc-body-content">
                        <p class="sc-recipient-lbl">This programmatically verified credential is proudly presented to</p>
                        <h2 class="sc-recipient-name">${studentUser.fullName}</h2>
                        <p class="sc-award-statement">
                            who has successfully fulfilled all academic requirements and completed the certified program of study in
                        </p>
                        <h3 class="sc-course-name">${course.courseName}</h3>
                    </div>

                    <!-- Structured Security Metadata & Signatures -->
                    <div class="sc-footer-row">
                        <!-- Left Block: Issue Data & Id -->
                        <div class="sc-footer-col">
                            <div class="sc-sec-info">
                                <strong>Credential Details</strong><br>
                                Student Reg: <c:out value="${studentProfile.regNumber}" default="N/A"/><br>
                                Certificate No: ${certificate.certificateNo}<br>
                                Date Issued: 
                                <c:choose>
                                    <c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Center Block: Structured QR Security Stamp -->
                        <div class="sc-footer-col center">
                            <c:if test="${not empty certificate.qrCodePath}">
                                <div class="sc-qr-stamp">
                                    <div class="sc-verify-text">
                                        Scan QR to verify<br>
                                        <strong>Official Stamp</strong>
                                    </div>
                                    <c:choose>
                                        <c:when test="${certificate.qrCodePath.startsWith('http')}">
                                            <img class="sc-qr-image" src="${certificate.qrCodePath}" alt="Verification QR Code">
                                        </c:when>
                                        <c:otherwise>
                                            <img class="sc-qr-image" src="${pageContext.request.contextPath}/${certificate.qrCodePath}" alt="Verification QR Code">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:if>
                        </div>

                        <!-- Right Block: Signature Representation -->
                        <div class="sc-footer-col">
                            <img class="sc-sig-image" src="${pageContext.request.contextPath}/img/registrar-sig.png" alt="Sulaiman Sani Signature">
                            <div class="sc-sig-line">
                                <h4 class="sc-sig-title">Sulaiman Sani</h4>
                                <span class="sc-sig-sub">Registrar Office</span>
                            </div>
                        </div>
                    </div>
                </section>
            </div>

            <!-- Sleek verification board below the certificate frame -->
            <div class="vc_metaBoard">
                <div class="vc_metaHeader">
                    <span class="vc_metaIcon">
                        <i class="fas fa-check-circle" style="font-size: 1.5rem;"></i>
                    </span>
                    <h4 class="vc_metaTitle">Verified Institutional Credential</h4>
                </div>

                <div class="vc_metaGrid">
                    <div class="vc_gridItem">
                        <span class="vc_itemLabel">Recipient Student</span>
                        <span class="vc_itemValue">${studentUser.fullName}</span>
                    </div>
                    <div class="vc_gridItem">
                        <span class="vc_itemLabel">Course Program</span>
                        <span class="vc_itemValue">${course.courseName}</span>
                    </div>
                    <div class="vc_gridItem">
                        <span class="vc_itemLabel">Issued Date</span>
                        <span class="vc_itemValue">
                            <c:choose>
                                <c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="vc_gridItem">
                        <span class="vc_itemLabel">Credential ID</span>
                        <span class="vc_itemValue">${certificate.certificateNo}</span>
                    </div>
                </div>

                <c:if test="${certificate.status != 'Revoked'}">
                    <!-- Action Buttons Side-by-Side -->
                    <div style="display: flex; gap: 12px; margin-top: 16px;">
                        <button id="studentCertDownloadPdfBtn" class="vc_primaryBtn" style="flex: 2;" type="button">
                            <i class="fas fa-file-pdf"></i> Download Official High-Res PDF
                        </button>
                        <button id="studentCertShareBtn" class="vc_primaryBtn" style="flex: 1; background-color: #ffffff !important; color: #0f172a !important; border: 1px solid #cbd5e1 !important;" type="button">
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

                    // Force strictly locked A4 landscape dimensions (1123px by 794px)
                    certificateNode.style.setProperty('width', '1123px', 'important');
                    certificateNode.style.setProperty('height', '794px', 'important');
                    certificateNode.style.setProperty('max-width', 'none', 'important');
                    certificateNode.style.setProperty('aspect-ratio', '1123 / 794', 'important');

                    // Ensure Google fonts are fully drawn to the canvas before compiling PDF
                    document.fonts.ready.then(function() {
                        return html2canvas(certificateNode, {
                            scale: 2, // Double scaling for high-resolution vector and text quality
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
                        navigator.clipboard.writeText(copyText).then(showToast).catch(function() {
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
    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
