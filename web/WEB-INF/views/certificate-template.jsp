<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate Template</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --ink: #14263a;
            --muted: #5f7085;
            --accent: #1e4f86;
            --line: #d8e1ec;
            --soft: #f6f9fc;
        }
        @page {
            size: A4 landscape;
            margin: 10mm;
        }
        body { background: #eef3f8; margin: 0; font-family: 'Inter', sans-serif; color: var(--ink); }
        .wrap { max-width: 1100px; margin: 24px auto; padding: 0 12px; }
        .toolbar { display:flex; gap:10px; margin-bottom: 14px; flex-wrap: wrap; }
        .btn { display:inline-block; padding:10px 14px; text-decoration:none; border:1px solid #223750; color:#162a40; background:#fff; border-radius: 8px; }
        .btn.primary { background:#162a40; color:#fff; cursor: pointer; }
        .badge { display:inline-block; padding:6px 10px; border:1px solid #cfe0f4; background:#f1f7ff; color:#2e5e8e; border-radius: 999px; font-size: 12px; font-weight: 700; }

        .certificate {
            position: relative;
            border: 1px solid var(--line);
            border-radius: 16px;
            background: #ffffff;
            box-shadow: 0 18px 40px rgba(17, 33, 52, 0.12);
            padding: 42px;
            position: relative;
        }
        .certificate:before,
        .certificate:after {
            content: "";
            position: absolute;
            inset: 14px;
            border: 1px solid #cfd9e5;
            border-radius: 10px;
            pointer-events: none;
        }
        .header,
        .line,
        .center,
        .details,
        .meta,
        .endorsements,
        .qr,
        .verify,
        .title,
        .subtitle {
            position: relative;
            z-index: 1;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 1px solid var(--line);
            padding-bottom: 18px;
        }
        .seal {
            border: 1px solid #c8d6e8;
            border-radius: 999px;
            background: #f7fbff;
            color: #315b88;
            padding: 8px 14px;
            font-size: 0.74rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
        }
        .kicker {
            color: var(--accent);
            text-transform: uppercase;
            letter-spacing: 0.16em;
            font-size: 0.72rem;
            font-weight: 700;
        }
        .title { text-align:center; font-size: 44px; font-weight:800; color: var(--ink); margin: 18px 0 0; letter-spacing: -0.03em; }
        .subtitle { text-align:center; color: var(--muted); margin-top: 8px; font-size: 0.92rem; text-transform: uppercase; letter-spacing: 0.1em; }
        .line { text-align:center; margin-top: 26px; font-size: 0.95rem; color: var(--muted); }
        .name { text-align:center; margin-top: 16px; font-size: 40px; color: var(--ink); font-weight:800; border-bottom: 2px solid #c9d6e4; display:inline-block; padding: 0 20px 10px; letter-spacing: -0.02em; }
        .center { text-align:center; }
        .details { margin-top: 18px; text-align:center; color: #22374e; font-size: 0.98rem; line-height:1.85; }
        .details strong { color: #163454; }
        .meta { margin-top: 28px; display:grid; grid-template-columns: repeat(3,1fr); gap: 14px; }
        .meta-box { border: 1px solid var(--line); border-radius: 12px; background: var(--soft); padding: 16px; }
        .meta-box span { display: block; color: #63758a; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; font-weight: 700; }
        .meta-value { font-size: 15px; color: #10253d; font-weight: 700; margin-top:8px; word-break: break-word; line-height: 1.5; }
        .endorsements {
            margin-top: 26px;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 160px minmax(0, 1fr);
            gap: 16px;
            align-items: end;
        }
        .signature-block { display: grid; gap: 6px; justify-items: center; }
        .sign-line { width: 100%; border-bottom: 1px solid #8da5c0; height: 24px; }
        .signature-block strong { color: #14324f; font-size: 0.92rem; }
        .signature-block span { color: var(--muted); font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.08em; }
        .stamp-block {
            width: 140px;
            height: 140px;
            border: 2px solid #8aa8c7;
            border-radius: 50%;
            display: grid;
            align-content: center;
            justify-items: center;
            text-align: center;
            color: #285784;
            background: #f7fbff;
        }
        .stamp-block span { font-size: 1.45rem; font-weight: 800; letter-spacing: 0.04em; }
        .stamp-block small { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; font-weight: 700; }
        .verify { margin-top: 20px; text-align:center; font-size: 12px; color: var(--muted); word-break: break-all; }
        .verify-help { display: block; margin-top: 6px; font-size: 11px; word-break: break-word; }
        .qr { display:flex; justify-content:center; margin-top: 22px; }
        .qr img { width: 122px; height: 122px; border: 1px solid #d1dce8; border-radius: 12px; padding: 8px; background: #fff; }

        @media print {
            * { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .toolbar { display:none; }
            .wrap { margin:0; max-width:none; }
            body { background:#fff; }
            .certificate { box-shadow:none; border-radius: 0; }
        }

        @media (max-width: 920px) {
            .header { flex-direction: column; gap: 12px; }
            .meta,
            .endorsements { grid-template-columns: 1fr; }
            .stamp-block { margin-inline: auto; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="toolbar">
        <a class="btn" href="${backUrl}">Back</a>
        <button class="btn primary" onclick="window.print()">Download / Print</button>
        <c:if test="${previewMode == true}">
            <span class="badge">Preview Template</span>
        </c:if>
    </div>

    <section class="certificate">
        <div class="header">
            <span class="kicker">PSM E-Learning Platform</span>
            <span class="seal">Official Certificate</span>
        </div>
        <div class="subtitle">PSM E-Learning Platform</div>
        <div class="title">Certificate of Completion</div>

        <div class="line">This is to certify that</div>
        <div class="center"><div class="name">${certificate.studentName}</div></div>

        <div class="details">
            Registration Number: <strong><c:out value="${certificate.regNumber}" default="N/A"/></strong><br>
            Student Email: <strong><c:out value="${certificate.studentEmail}" default="N/A"/></strong><br>
            has successfully completed the course<br>
            <strong>${certificate.courseName}</strong>
        </div>

        <div class="meta">
            <div class="meta-box">
                <span>Certificate Number</span>
                <div class="meta-value">${certificate.certificateNo}</div>
            </div>
            <div class="meta-box">
                <span>Issue Date</span>
                <div class="meta-value">
                    <c:choose>
                        <c:when test="${not empty certificate.issueDate}">
                            ${certificate.issueDate.toLocalDate()}
                        </c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="meta-box">
                <span>Status</span>
                <div class="meta-value">
                    <c:choose>
                        <c:when test="${certificate.status == 'Revoked'}">Revoked</c:when>
                        <c:otherwise>Active</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="endorsements">
            <div class="signature-block">
                <div class="sign-line"></div>
                <strong><c:out value="${certificate.instructorName}" default="Instructor of Record"/></strong>
                <span>Instructor Signature</span>
            </div>
            <div class="stamp-block" aria-label="Institutional validation stamp">
                <span>PSM</span>
                <small>Verified Credential</small>
            </div>
            <div class="signature-block">
                <div class="sign-line"></div>
                <strong><c:out value="${certificate.generatedBy}" default="Registrar"/></strong>
                <span>Authorized Signatory</span>
            </div>
        </div>

        <c:if test="${not empty certificate.qrCodePath}">
            <div class="qr">
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
        <div class="verify">
            Verification Code: ${certificate.certificateNo}
            <span class="verify-help">Public verification URL: <c:out value="${certificate.verificationURL}" default="${pageContext.request.contextPath}/certificate/verify"/></span>
        </div>
    </section>
</div>
</body>
</html>
