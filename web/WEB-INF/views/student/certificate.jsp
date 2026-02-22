<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=Source+Sans+3:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --ink: #0a1f2d;
            --muted: #4b5563;
            --accent: #0a2a43;
            --gold: #c4a24a;
            --paper: #f7f4ee;
        }
        body { background: #e9edf2; margin: 0; font-family: 'Source Sans 3', sans-serif; color: var(--ink); }
        .wrap { max-width: 1100px; margin: 24px auto; padding: 0 12px; }
        .toolbar { display:flex; gap:10px; margin-bottom: 14px; }
        .btn { display:inline-block; padding:10px 14px; text-decoration:none; border:1px solid #111827; color:#111827; background:#fff; }
        .btn.primary { background:#111827; color:#fff; }
        .msg { background:#fff6df; border:1px solid #9a7a22; padding:14px; color:#7a5b12; }

        .certificate {
            background: var(--paper);
            border: 16px solid var(--accent);
            padding: 42px 52px;
            position: relative;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.12);
            overflow: hidden;
        }
        .certificate:before,
        .certificate:after {
            content: "";
            position:absolute;
            inset: 10px;
            border: 2px solid var(--gold);
            pointer-events:none;
        }
        .watermark {
            position: absolute;
            inset: 0;
            background:
                radial-gradient(circle at 18% 18%, rgba(11,59,102,0.08), transparent 40%),
                radial-gradient(circle at 82% 70%, rgba(179,139,46,0.08), transparent 45%);
            pointer-events: none;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            text-transform: uppercase;
            letter-spacing: 3px;
            font-size: 12px;
            color: var(--muted);
        }
        .seal {
            border: 2px solid var(--gold);
            padding: 10px 14px;
            font-weight: 600;
            color: var(--accent);
        }
        .title { text-align:center; font-family: 'Playfair Display', serif; font-size: 48px; font-weight:700; color: var(--accent); margin-top: 18px; }
        .subtitle { text-align:center; color: var(--muted); margin-top: 6px; font-size: 14px; text-transform: uppercase; letter-spacing: 3px; }
        .line { text-align:center; margin-top: 26px; font-size: 18px; color: var(--muted); }
        .name { text-align:center; margin-top: 12px; font-family: 'Playfair Display', serif; font-size: 44px; color: var(--ink); font-weight:700; border-bottom: 2px solid var(--gold); display:inline-block; padding: 0 18px 8px; }
        .center { text-align:center; }
        .details { margin-top: 18px; text-align:center; color: var(--ink); font-size: 18px; line-height:1.7; }
        .details strong { color: var(--accent); }
        .meta { margin-top: 32px; display:grid; grid-template-columns: repeat(3,1fr); gap: 22px; }
        .meta-box { border-top:2px solid var(--gold); padding-top:10px; font-size: 13px; color: var(--muted); text-transform: uppercase; letter-spacing: 1px; }
        .meta-value { font-size: 15px; color: var(--ink); font-weight: 600; margin-top:6px; word-break: break-word; text-transform:none; letter-spacing: 0; }
        .verify { margin-top: 22px; text-align:center; font-size: 12px; color: var(--muted); word-break: break-all; }
        .qr { display:flex; justify-content:center; margin-top: 22px; }
        .qr img { width: 120px; height: 120px; border: 2px solid var(--gold); padding: 6px; background: #fff; }

        @media print {
            .toolbar { display:none; }
            .wrap { margin:0; max-width:none; }
            body { background:#fff; }
            .certificate { box-shadow:none; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="toolbar">
        <a class="btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}">Back</a>
        <button class="btn primary" onclick="window.print()">Download / Print</button>
        <c:if test="${not empty certificate}">
            <a class="btn" target="_blank" href="${certificate.verificationURL}">Verify</a>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${not eligible}">
            <div class="msg">
                Certificate is not available yet. Requirements not met.
                <div style="margin-top:10px; padding-top:10px; border-top:1px solid #b89b49;">
                    <div><strong>Eligibility Diagnostics</strong></div>
                    <div style="margin-top:6px;">Payment Status: <strong>${diagPaid ? 'Paid' : 'Not Paid'}</strong></div>
                    <div>Course Completion: <strong>${diagCompleted ? 'Completed' : 'Not Completed'}</strong> (Progress: ${diagProgress}%)</div>
                    <div>Assessments: <strong>${diagPassedAllAssessments ? 'All Passed' : 'Pending/Failed'}</strong> (${diagPassedAssessments}/${diagTotalAssessments})</div>
                    <div>Materials Viewed: <strong>${diagViewedMaterials}/${diagTotalMaterials}</strong></div>
                </div>
            </div>
        </c:when>
        <c:when test="${empty certificate}">
            <div class="msg">
                <c:choose>
                    <c:when test="${canGenerate}">
                        Certificate not generated yet. Click generate to create it.
                        <form method="post" action="${pageContext.request.contextPath}/student/certificate" style="margin-top:10px;">
                            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                            <button class="btn primary" type="submit">Generate Certificate</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        Certificate generation failed. Please refresh and try again.
                    </c:otherwise>
                </c:choose>
            </div>
        </c:when>
        <c:otherwise>
            <c:if test="${certificate.status == 'Revoked'}">
                <div class="msg" style="margin-bottom:12px;">
                    This certificate has been revoked. Please contact support for clarification.
                </div>
            </c:if>
            <section class="certificate">
                <div class="watermark"></div>
                <div class="header">
                    <span>PSM E-Learning</span>
                    <span class="seal">Official Certificate</span>
                </div>
                <div class="subtitle">PSM E-Learning Platform</div>
                <div class="title">Certificate of Completion</div>

                <div class="line">This is to certify that</div>
                <div class="center"><div class="name">${studentUser.fullName}</div></div>

                <div class="details">
                    Registration Number: <strong><c:out value="${studentProfile.regNumber}" default="N/A"/></strong><br>
                    has successfully completed the course<br>
                    <strong>${course.courseName}</strong>
                </div>

                <div class="meta">
                    <div class="meta-box">
                        Certificate Number
                        <div class="meta-value">${certificate.certificateNo}</div>
                    </div>
                    <div class="meta-box">
                        Issue Date
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
                        Generated By
                        <div class="meta-value">${certificate.generatedBy}</div>
                    </div>
                </div>

                <c:if test="${not empty certificate.qrCodePath}">
                    <div class="qr">
                        <img src="${certificate.qrCodePath}" alt="Certificate QR Code">
                    </div>
                </c:if>
                <div class="verify">
                    Verification URL: ${certificate.verificationURL}
                </div>
            </section>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>

