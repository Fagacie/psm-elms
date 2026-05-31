<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate Preview | PSM E-Learning</title>
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
    <a class="vc_backLink" href="${backUrl}">
        <i class="fas fa-arrow-left"></i> <span>Back</span>
    </a>

    <!-- A4 locked container with heavy dropshadow placed flat on a slate desk -->
    <div class="vc_certificateWrapper">
        <section class="sc-sheet">
            <div class="sc-corner-tl"></div>
            <div class="sc-corner-tr"></div>
            <div class="sc-corner-bl"></div>
            <div class="sc-corner-br"></div>
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
                <h2 class="sc-recipient-name">${certificate.studentName}</h2>
                <p class="sc-award-statement">
                    who has successfully fulfilled all academic requirements and completed the certified program of study in
                </p>
                <h3 class="sc-course-name">${certificate.courseName}</h3>
            </div>

            <!-- Structured Security Metadata & Signatures -->
            <div class="sc-footer-row">
                <!-- Left Block: Issue Data & Id -->
                <div class="sc-footer-col">
                    <div class="sc-sec-info">
                        <strong>Credential Details</strong><br>
                        Student Reg: <c:out value="${certificate.regNumber}" default="N/A"/><br>
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
                    <div class="sc-qr-stamp">
                        <div class="sc-verify-text">
                            Scan QR to verify<br>
                            <strong>Official Stamp</strong>
                        </div>
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
                    </div>
                </div>

                <!-- Right Block: Signature Representation -->
                <div class="sc-footer-col" style="position: relative;">
                    <img class="sc-sig-image" src="${pageContext.request.contextPath}/img/registrar-sig.png" alt="Sulaiman Sani Signature">
                    <div class="sc-verify-stamp">
                        <svg viewBox="0 0 100 100" width="56" height="56">
                            <circle cx="50" cy="50" r="40" fill="none" stroke="rgba(37, 99, 235, 0.65)" stroke-width="2" stroke-dasharray="3 1.5" />
                            <circle cx="50" cy="50" r="34" fill="none" stroke="rgba(37, 99, 235, 0.65)" stroke-width="0.8" />
                            <path id="stampTextPathTemp" d="M18 50 A32 32 0 1 1 82 50" fill="none" stroke="none" />
                            <text fill="rgba(37, 99, 235, 0.65)" font-size="6" font-weight="bold" letter-spacing="0.8">
                                <textPath href="#stampTextPathTemp" startOffset="50%" text-anchor="middle">OFFICIAL VERIFICATION</textPath>
                            </text>
                            <text x="50" y="46" fill="rgba(37, 99, 235, 0.75)" font-size="9" font-weight="900" text-anchor="middle">PSM</text>
                            <text x="50" y="58" fill="rgba(37, 99, 235, 0.75)" font-size="7" font-weight="bold" text-anchor="middle">APPROVED</text>
                            <text x="50" y="66" fill="rgba(37, 99, 235, 0.65)" font-size="4.5" font-weight="bold" text-anchor="middle">REGISTRAR</text>
                        </svg>
                    </div>
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
            <c:choose>
                <c:when test="${previewMode == true}">
                    <span class="vc_metaIcon" style="color: #f59e0b;">
                        <i class="fas fa-eye" style="font-size: 1.5rem;"></i>
                    </span>
                    <h4 class="vc_metaTitle" style="color: #f59e0b;">Certificate Template Preview</h4>
                </c:when>
                <c:otherwise>
                    <span class="vc_metaIcon">
                        <i class="fas fa-check-circle" style="font-size: 1.5rem;"></i>
                    </span>
                    <h4 class="vc_metaTitle">Verified Institutional Credential</h4>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="vc_metaGrid">
            <div class="vc_gridItem">
                <span class="vc_itemLabel">Recipient Student</span>
                <span class="vc_itemValue">${certificate.studentName}</span>
            </div>
            <div class="vc_gridItem">
                <span class="vc_itemLabel">Course Program</span>
                <span class="vc_itemValue">${certificate.courseName}</span>
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

        <!-- Action Buttons Side-by-Side -->
        <div style="display: flex; gap: 12px; margin-top: 16px;">
            <button id="studentCertDownloadPdfBtn" class="vc_primaryBtn" style="flex: 2;" type="button">
                <i class="fas fa-file-pdf"></i> Download Official High-Res PDF
            </button>
            <button id="studentCertShareBtn" class="vc_primaryBtn" style="flex: 1; background-color: #ffffff !important; color: #0f172a !important; border: 1px solid #cbd5e1 !important;" type="button">
                <i class="fas fa-share-nodes"></i> Share Credential
            </button>
        </div>
    </div>

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
</body>
</html>
