<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate Verification | PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Landing.module.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="lp_landing_page">
<header class="lp_header" id="siteHeader">
    <div class="lp_container lp_shell">
        <a class="lp_brand" href="${pageContext.request.contextPath}/landing" aria-label="PSM E-Learning home">
            <span class="lp_brand_mark">PSM</span>
            <span class="lp_brand_text">E-Learning</span>
        </a>
        <nav class="lp_nav" aria-label="Primary navigation">
            <a href="${pageContext.request.contextPath}/landing">Home</a>
        </nav>
        <div class="lp_header_actions">
            <a class="lp_btn lp_btn_ghost" href="${pageContext.request.contextPath}/login">Login</a>
        </div>
    </div>
</header>

<main>
    <section class="lp_section lp_verify" style="padding-top: 80px;">
        <div class="lp_container">
            <div class="lp_verify_wrapper" data-aos="fade-up">
                <p class="lp_eyebrow">Trusted Verification</p>
                <h2>Certificate Verification</h2>
                <p style="margin-top: 16px; max-width: 600px; margin-left: auto; margin-right: auto;">Public verification portal for employers, institutions, and third-party reviewers.</p>
                
                <form class="lp_verify_console" method="get" action="${pageContext.request.contextPath}/certificate/verify" style="margin-top: 40px; margin-bottom: 24px;">
                    <div class="lp_verify_search_bar">
                        <i data-lucide="search"></i>
                        <input id="code" class="lp_verify_input" type="text" name="code" value="${checkedCode}" placeholder="e.g. PSM-CERT-20260223-ABC123" required>
                        <button class="lp_verify_btn" type="submit">
                            Verify <i data-lucide="arrow-right" style="margin-left: 4px; color: white;"></i>
                        </button>
                    </div>
                </form>
                <p style="color: var(--lp-slate-light); font-size: 0.85rem;"><i data-lucide="info" style="width: 14px; height: 14px; display: inline-block; vertical-align: middle; margin-right: 4px;"></i> Tip: QR links are also supported and can include additional enrollment reference checks.</p>
            </div>

            <div style="max-width: 800px; margin: 40px auto 0;" data-aos="fade-up" data-aos-delay="100">
                <c:choose>
                    <c:when test="${hasResult and valid}">
                        <div style="background: var(--lp-white); border: 1px solid #10b981; border-radius: var(--lp-radius); box-shadow: var(--lp-shadow-soft); overflow: hidden;">
                            <div style="background: rgba(16, 185, 129, 0.1); padding: 24px 32px; display: flex; align-items: center; gap: 16px; border-bottom: 1px solid #10b981;">
                                <i data-lucide="check-circle" style="color: #10b981; width: 32px; height: 32px;"></i>
                                <div>
                                    <h3 style="color: #065f46; margin: 0 0 4px; font-size: 1.25rem;">Valid Certificate</h3>
                                    <p style="color: #047857; margin: 0; font-size: 0.95rem;">This certificate is authentic and issued by PSM E-Learning.</p>
                                </div>
                            </div>
                            <div style="padding: 32px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px;">
                                <div><div class="lp_eyebrow" style="margin-bottom: 4px; color: var(--lp-slate-light);">Certificate Number</div><div style="font-weight: 600; font-family: monospace; font-size: 1.05rem;">${certificate.certificateNo}</div></div>
                                <div><div class="lp_eyebrow" style="margin-bottom: 4px; color: var(--lp-slate-light);">Student Name</div><div style="font-weight: 600; font-size: 1.05rem;"><c:out value="${studentUser.fullName}" default="-"/></div></div>
                                <div><div class="lp_eyebrow" style="margin-bottom: 4px; color: var(--lp-slate-light);">Registration Number</div><div style="font-weight: 600; font-size: 1.05rem;"><c:out value="${studentProfile.regNumber}" default="-"/></div></div>
                                <div><div class="lp_eyebrow" style="margin-bottom: 4px; color: var(--lp-slate-light);">Course</div><div style="font-weight: 600; font-size: 1.05rem;"><c:out value="${course.courseName}" default="-"/></div></div>
                                <div>
                                    <div class="lp_eyebrow" style="margin-bottom: 4px; color: var(--lp-slate-light);">Issue Date</div>
                                    <div style="font-weight: 600; font-size: 1.05rem;">
                                        <c:choose>
                                            <c:when test="${not empty certificate.issueDate}">${certificate.issueDate.toLocalDate()}</c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div><div class="lp_eyebrow" style="margin-bottom: 4px; color: var(--lp-slate-light);">Generated By</div><div style="font-weight: 600; font-size: 1.05rem;"><c:out value="${certificate.generatedBy}" default="-"/></div></div>
                            </div>
                        </div>
                    </c:when>
                    <c:when test="${hasResult}">
                        <div style="background: #fef2f2; border: 1px solid #ef4444; border-radius: var(--lp-radius); padding: 32px; display: flex; align-items: flex-start; gap: 16px; box-shadow: var(--lp-shadow-soft);">
                            <i data-lucide="alert-triangle" style="color: #ef4444; width: 32px; height: 32px; flex-shrink: 0;"></i>
                            <div>
                                <h3 style="color: #991b1b; margin: 0 0 8px; font-size: 1.25rem;">Verification Failed</h3>
                                <p style="color: #b91c1c; margin: 0; font-size: 1rem;"><c:out value="${message}" default="Certificate was not found."/></p>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="background: var(--lp-white); border: 1px dashed var(--lp-gray-border); border-radius: var(--lp-radius); padding: 40px; text-align: center; color: var(--lp-slate-gray);">
                            <i data-lucide="shield-check" style="width: 48px; height: 48px; color: var(--lp-slate-light); margin-bottom: 16px; opacity: 0.5;"></i>
                            <h3 style="margin: 0 0 8px; font-size: 1.25rem;">Ready to Verify</h3>
                            <p style="margin: 0; max-width: 400px; margin-left: auto; margin-right: auto;">Enter a certificate code above to check authenticity against official issuance records.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
                
                <div style="margin-top: 32px; text-align: center; color: var(--lp-slate-light); font-size: 0.85rem; display: flex; justify-content: center; align-items: center; gap: 8px;">
                    <i data-lucide="lock" style="width: 14px; height: 14px;"></i>
                    <span>Verification results are generated from official issuance records.</span>
                </div>
            </div>
        </div>
    </section>
</main>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script src="https://unpkg.com/lucide@latest"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof AOS !== 'undefined') {
            AOS.init({ once: true, offset: 50, duration: 800, easing: 'ease-out-cubic' });
        }
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
        
        const header = document.getElementById('siteHeader');
        window.addEventListener('scroll', () => {
            if (header) header.classList.toggle('lp_header_scrolled', window.scrollY > 12);
        }, { passive: true });
    });
</script>
</body>
</html>
