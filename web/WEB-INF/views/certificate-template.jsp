<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <style>
        :root {
            --ink: #0f172a;
            --muted: #64748b;
            --line: #e2e8f0;
            --soft: #f8fafc;
            --navy: #102a72;
            --navy-strong: #0b1d58;
            --blue: #1d8df0;
            --blue-strong: #0f65c9;
            --gold: #d9a520;
            --cert-export-width: 2000px;
            --cert-export-height: 1414px;
            --cert-screen-scale: 0.34;
        }
        @page { size: A4 landscape; margin: 10mm; }
        * { box-sizing: border-box; }
        body { margin: 0; background: #f8fafc; font-family: 'Inter', sans-serif; color: var(--ink); }
        .wrap { max-width: 920px; margin: 24px auto; padding: 0 12px; }
        .toolbar { display:flex; gap:10px; margin-bottom:14px; flex-wrap:wrap; align-items:center; }
        .btn { display:inline-flex; align-items:center; justify-content:center; min-height:42px; padding:0 15px; text-decoration:none; border:1px solid var(--line); color:var(--ink); background:#fff; border-radius:10px; font-weight:600; transition:transform .2s ease, box-shadow .2s ease; cursor:pointer; }
        .btn:hover { transform:translateY(-1px); box-shadow:0 10px 24px rgba(15,23,42,.06); }
        .btn.primary { background:var(--navy); color:#fff; border-color:var(--navy); }
        .badge { display:inline-flex; align-items:center; min-height:34px; padding:0 12px; border:1px solid rgba(16,42,114,.12); background:rgba(16,42,114,.06); color:var(--navy); border-radius:999px; font-size:.75rem; font-weight:700; letter-spacing:.08em; text-transform:uppercase; }
        .badge.revoked { color:#7f1d1d; border-color:rgba(127,29,29,.16); background:rgba(254,242,242,.95); }
        .toolbar-spacer { flex: 1 1 auto; }
        .toolbar-link { color: var(--navy); text-decoration: none; font-weight: 600; }

        .certificate { position:relative; width:min(100%, calc(var(--cert-export-width) * var(--cert-screen-scale))); aspect-ratio:2000 / 1414; min-height:0; max-width:100%; margin:0 auto; border:1px solid var(--line); border-radius:8px; background:#fff; box-shadow:0 18px 40px rgba(15,23,42,.08); overflow:hidden; }
        .top-art, .body { position:relative; z-index:1; }
        .top-art { position:relative; height:29%; min-height:168px; background:linear-gradient(180deg, var(--navy-strong) 0%, var(--navy) 100%); overflow:hidden; }
        .wave { position:absolute; left:-10%; right:-10%; border-bottom-left-radius:55% 100%; border-bottom-right-radius:55% 100%; }
        .wave-back { height:72%; bottom:-27%; background:rgba(14,111,218,.95); }
        .wave-mid { height:60%; bottom:-20%; background:rgba(31,144,245,.92); }
        .wave-front { height:58%; bottom:-32%; background:#ffffff; }
        .award-badge { position:absolute; left:84px; top:52px; width:108px; height:108px; border-radius:50%; border:4px solid var(--gold); background:#f7c94c; box-shadow:0 10px 24px rgba(15,23,42,.15); }
        .award-badge::before, .award-badge::after { content:""; position:absolute; bottom:-36px; width:22px; height:44px; background:var(--navy); clip-path:polygon(0 0,100% 0,80% 100%,50% 78%,20% 100%); }
        .award-badge::before { left:18px; }
        .award-badge::after { right:18px; }
        .award-core { position:absolute; inset:8px; border-radius:50%; border:2px solid rgba(16,42,114,.7); display:grid; place-items:center; text-align:center; color:#714d00; }
        .award-core span { font-size:.82rem; font-weight:800; letter-spacing:.14em; }
        .award-core strong { display:block; font-size:1.2rem; line-height:1; margin-top:2px; }
        .title-panel { position:absolute; right:80px; top:44px; display:grid; justify-items:end; gap:4px; color:#fff; text-align:right; }
        .title-main { font-size:2.95rem; font-weight:800; letter-spacing:.05em; }
        .title-sub { display:inline-flex; align-items:center; gap:12px; font-size:.98rem; letter-spacing:.18em; }
        .title-sub::before, .title-sub::after { content:""; width:86px; height:1px; background:rgba(255,255,255,.5); }
        .body { padding:4.8% 5.4% 4% 5.4%; display:flex; flex-direction:column; justify-content:space-between; }
        .content { max-width:70%; }
        .kicker { margin:0; color:#334155; font-size:.72rem; text-transform:uppercase; letter-spacing:.28em; font-weight:700; }
        .name-wrap { margin-top:16px; }
        .name { display:inline-block; font-family:'Great Vibes', cursive; font-size:clamp(3rem,4vw,4.35rem); line-height:1; color:#111; font-weight:400; }
        .details { max-width:760px; margin:18px 0 0; color:#334155; font-size:.84rem; line-height:1.65; }
        .details strong { color:var(--navy); }
        .course-pill { max-width:620px; margin-top:14px; padding:10px 14px; border-left:3px solid var(--blue-strong); background:var(--soft); font-size:.88rem; font-weight:700; letter-spacing:-.02em; }
        .detail-stack { margin-top: 14px; display: grid; gap: 10px; max-width: 720px; }
        .detail-card { display: grid; gap: 4px; padding: 12px 14px; border: 1px solid var(--line); border-radius: 12px; background: linear-gradient(180deg, #fbfdff 0%, #f8fbff 100%); }
        .detail-card span { font-size: .64rem; color: var(--muted); letter-spacing: .12em; text-transform: uppercase; font-weight: 700; }
        .detail-card strong { font-size: .82rem; color: var(--ink); }
        .meta-inline { margin-top:14px; display:flex; flex-wrap:wrap; gap:8px 18px; color:var(--muted); font-size:.68rem; letter-spacing:.04em; }
        .meta-inline strong { color:var(--ink); }
        .footer { margin-top:28px; display:grid; grid-template-columns:1fr 1fr 1.15fr; gap:16px; align-items:end; }
        .signature-block, .verify-panel { position:relative; padding-top:16px; }
        .signature-block::before { content:""; position:absolute; left:0; right:28%; top:0; height:1px; background:rgba(217,165,32,.8); }
        .signature-block strong, .verify-panel strong { display:block; font-size:.78rem; color:#111; }
        .signature-block small, .verify-panel small, .verify-label { display:block; color:var(--muted); font-size:.6rem; line-height:1.55; margin-top:4px; word-break:break-word; }
        .verify-label { margin-top:0; text-transform:uppercase; letter-spacing:.12em; font-weight:700; }
        .qr { position:absolute; right:5.4%; bottom:4%; }
        .qr img { width:64px; height:64px; border:1px solid var(--line); border-radius:8px; background:#fff; padding:4px; }
        @media print { * { -webkit-print-color-adjust: exact; print-color-adjust: exact; } .toolbar { display:none; } .wrap { margin:0; max-width:none; } body { background:#fff; } .certificate { box-shadow:none; border-radius:0; width:var(--cert-export-width); min-height:var(--cert-export-height); max-width:none; } .title-main { font-size:120px; } .name { font-size:110px; } }
        @media (max-width: 920px) { .top-art { height:220px; } .award-badge { left:24px; top:40px; width:88px; height:88px; } .title-panel { right:24px; top:32px; } .title-main { font-size:1.7rem; } .title-sub::before, .title-sub::after { width:36px; } .body { padding:24px 20px; } .content { max-width:100%; } .footer { grid-template-columns:1fr; } .qr { position:static; margin-top:14px; } }
    </style>
</head>
<body>
<div class="wrap">
    <div class="toolbar">
        <a class="btn" href="${backUrl}">Back</a>
        <button id="downloadPngBtn" class="btn primary" type="button">Download PNG</button>
        <button class="btn" type="button" onclick="window.print()">Print</button>
        <c:if test="${not empty certificate.verificationURL and previewMode != true}">
            <a class="toolbar-link" href="${certificate.verificationURL}" target="_blank" rel="noopener">Open verification</a>
        </c:if>
        <div class="toolbar-spacer"></div>
        <c:if test="${previewMode == true}"><span class="badge">Preview Template</span></c:if>
        <c:if test="${previewMode != true}">
            <span class="badge ${certificate.status == 'Revoked' ? 'revoked' : ''}">
                ${certificate.status == 'Revoked' ? 'Revoked' : 'Issued Credential'}
            </span>
        </c:if>
    </div>

    <section class="certificate">
        <div class="top-art">
            <div class="wave wave-back"></div>
            <div class="wave wave-mid"></div>
            <div class="wave wave-front"></div>
            <div class="award-badge" aria-hidden="true"><div class="award-core"><span>PSM</span><strong>AWARD</strong></div></div>
            <div class="title-panel"><span class="title-main">CERTIFICATE</span><span class="title-sub">OF ACHIEVEMENT</span></div>
        </div>
        <div class="body">
            <div class="content">
                <p class="kicker">Proudly Presented To</p>
                <div class="name-wrap"><div class="name">${certificate.studentName}</div></div>
                <div class="details">This certifies that registration number <strong><c:out value="${certificate.regNumber}" default="N/A"/></strong> has successfully completed the approved learning requirements for</div>
                <div class="course-pill">${certificate.courseName}</div>
                <div class="detail-stack">
                    <div class="detail-card">
                        <span>Learning Authority</span>
                        <strong><c:out value="${certificate.instructorName}" default="PSM E-Learning Academic Team"/></strong>
                    </div>
                </div>
                <div class="meta-inline">
                    <span><strong>Reg No:</strong> <c:out value="${certificate.regNumber}" default="N/A"/></span>
                    <span><strong>Issue Date:</strong> <c:choose><c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when><c:otherwise>-</c:otherwise></c:choose></span>
                    <span><strong>Certificate No:</strong> ${certificate.certificateNo}</span>
                </div>
            </div>
            <div class="footer">
                <div class="signature-block"><strong>PSM E-Learning Platform</strong><small>Academic Records</small></div>
                <div class="signature-block"><strong>Registrar</strong><small><c:choose><c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when><c:otherwise>Issue date pending</c:otherwise></c:choose></small></div>
                <div class="verify-panel"><span class="verify-label">Verification Code</span><strong>${certificate.certificateNo}</strong><small><c:out value="${certificate.verificationURL}" default="${pageContext.request.contextPath}/certificate/verify"/></small></div>
            </div>
            <c:if test="${not empty certificate.qrCodePath}"><div class="qr"><c:choose><c:when test="${certificate.qrCodePath.startsWith('http')}"><img src="${certificate.qrCodePath}" alt="Certificate QR Code"></c:when><c:otherwise><img src="${pageContext.request.contextPath}/${certificate.qrCodePath}" alt="Certificate QR Code"></c:otherwise></c:choose></div></c:if>
        </div>
    </section>
</div>
<script>
    (function () {
        var downloadBtn = document.getElementById('downloadPngBtn');
        var certificateNode = document.querySelector('.certificate');
        if (!downloadBtn || !certificateNode) return;
        function getExportDimension(cssVarName, fallback) { var raw = getComputedStyle(document.documentElement).getPropertyValue(cssVarName) || ''; var value = parseInt(raw.replace('px', '').trim(), 10); return Number.isFinite(value) ? value : fallback; }
        async function exportCertificateAsPng() {
            if (typeof html2canvas === 'undefined') { alert('PNG export is unavailable right now. Please try print for now.'); return; }
            var exportWidth = getExportDimension('--cert-export-width', 2000); var exportHeight = getExportDimension('--cert-export-height', 1414);
            var originalLabel = downloadBtn.textContent; downloadBtn.disabled = true; downloadBtn.textContent = 'Preparing PNG...';
            var sandbox = document.createElement('div'); sandbox.style.position = 'fixed'; sandbox.style.left = '-100000px'; sandbox.style.top = '0'; sandbox.style.width = exportWidth + 'px'; sandbox.style.height = exportHeight + 'px'; sandbox.style.background = '#ffffff'; sandbox.style.zIndex = '-1';
            var clone = certificateNode.cloneNode(true); clone.style.width = exportWidth + 'px'; clone.style.minHeight = exportHeight + 'px'; clone.style.maxWidth = 'none'; clone.style.margin = '0'; clone.style.boxSizing = 'border-box';
            clone.querySelectorAll('img').forEach(function (img) { img.setAttribute('crossorigin', 'anonymous'); });
            sandbox.appendChild(clone); document.body.appendChild(sandbox);
            try {
                var canvas = await html2canvas(clone, { backgroundColor:'#ffffff', scale:1, useCORS:true, allowTaint:false, width:exportWidth, height:exportHeight, windowWidth:exportWidth, windowHeight:exportHeight });
                var certNo = '${certificate.certificateNo}' || 'certificate'; var safeName = certNo.replace(/[^a-z0-9_-]+/gi, '_').replace(/^_+|_+$/g, ''); var filename = (safeName || 'certificate') + '.png';
                var link = document.createElement('a'); link.href = canvas.toDataURL('image/png'); link.download = filename; document.body.appendChild(link); link.click(); document.body.removeChild(link);
            } catch (error) { console.error('Certificate PNG export failed:', error); alert('Could not export PNG. Please try again or use Print.'); }
            finally { if (sandbox.parentNode) sandbox.parentNode.removeChild(sandbox); downloadBtn.disabled = false; downloadBtn.textContent = originalLabel; }
        }
        downloadBtn.addEventListener('click', function () { exportCertificateAsPng(); });

        if ('${param.download}' === 'png') {
            var autoExport = function () {
                window.setTimeout(exportCertificateAsPng, 220);
            };
            if (document.readyState === 'complete') {
                autoExport();
            } else {
                window.addEventListener('load', autoExport, { once: true });
            }
        }
    })();
</script>
</body>
</html>
