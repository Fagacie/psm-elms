<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificates | PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    
    <!-- CSS Module & Global Certificate Styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Certificates.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-certificate-v2.css">
    
    <!-- React, Animation & Lucide CDNs -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    
    <!-- Dynamic A4 Background Compiler Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body class="sv-page">
<c:set var="revokedCount" value="0" />
<c:forEach var="issued" items="${issuedCertificates}">
    <c:if test="${issued.status == 'Revoked'}">
        <c:set var="revokedCount" value="${revokedCount + 1}" />
    </c:if>
</c:forEach>
<c:set var="activeCount" value="${fn:length(issuedCertificates) - revokedCount}" />

<c:set var="topbarTitle" value="Certificates"/>
<c:set var="topbarSubtitle" value="Generate, manage, and share credentials"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="certificates"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main cert-page trophy_pageWrapper">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <span>/</span>
            <span>Certificates</span>
        </div>

        <c:if test="${param.success == 'generated'}">
            <div class="alert alert-success" style="margin-bottom: 24px; border-radius: 8px;">
                <i class="fas fa-check-circle"></i> Certificate generated successfully and added to your issued list.
            </div>
        </c:if>
        <c:if test="${param.error == 'noteligible'}">
            <div class="alert alert-error" style="margin-bottom: 24px; border-radius: 8px;">
                <i class="fas fa-exclamation-triangle"></i>
                This enrollment is not yet eligible for certificate generation.
                <c:if test="${fn:contains(param.reason, 'payment')}"> Payment is pending.</c:if>
                <c:if test="${fn:contains(param.reason, 'materials')}"> Some materials are still not viewed.</c:if>
                <c:if test="${fn:contains(param.reason, 'assessments')}"> Required assessments are not fully passed.</c:if>
            </div>
        </c:if>
        <c:if test="${param.error == 'generatefail'}">
            <div class="alert alert-error" style="margin-bottom: 24px; border-radius: 8px;">
                <i class="fas fa-triangle-exclamation"></i> Certificate generation failed. Please retry.
            </div>
        </c:if>

        <!-- React Trophy Room Root Target -->
        <div id="trophy-room-react-root"></div>
    </main>
</div>

<div id="svOverlay" class="sv-overlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>

<!-- Server JSTL Data Bridge to Browser-side React Context -->
<script>
    window.issuedCertificatesData = [
        <c:forEach var="cert" items="${issuedCertificates}" varStatus="status">
            {
                certificateNo: "${cert.certificateNo}",
                courseName: `${fn:escapeXml(cert.courseName)}`,
                issueDate: "<c:choose><c:when test="${not empty cert.issueDate}">${cert.issueDate.toLocalDate()}</c:when><c:otherwise>-</c:otherwise></c:choose>",
                status: "${cert.status}",
                enrollmentId: "${cert.enrollmentId}",
                qrCodePath: "${cert.qrCodePath}",
                regNumber: "<c:out value="${cert.regNumber}" default="N/A"/>"
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];

    window.readyToGenerateData = [
        <c:forEach var="enrollment" items="${readyToGenerate}" varStatus="status">
            {
                enrollmentId: "${enrollment.enrollmentId}",
                courseName: `${fn:escapeXml(enrollment.courseName)}`
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];

    window.blockedEnrollmentsData = [
        <c:forEach var="item" items="${blockedEnrollments}" varStatus="status">
            {
                courseName: `${fn:escapeXml(item.enrollment.courseName)}`,
                paid: ${item.syncResult.paid},
                viewedMaterials: ${item.syncResult.viewedMaterials},
                totalMaterials: ${item.syncResult.totalMaterials},
                passedAssessments: ${item.syncResult.passedAssessments},
                totalAssessments: ${item.syncResult.totalAssessments},
                viewedAllMaterials: ${item.syncResult.viewedAllMaterials},
                passedRequiredAssessments: ${item.syncResult.passedRequiredAssessments}
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];

    window.studentName = "${fn:escapeXml(sessionScope.userName)}";
    window.contextPath = "${pageContext.request.contextPath}";
</script>

<!-- React Frontend Script compiled with Babel in Browser -->

    <script type="module" src="${pageContext.request.contextPath}/js/dist/certificates.js"></script>
</body>
</html>
