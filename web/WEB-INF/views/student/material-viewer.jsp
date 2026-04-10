<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material Preview - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/material-viewer-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Material Preview"/>
<c:set var="topbarSubtitle" value="In-course preview and quick access"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main mv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${backToHubUrl}">Learning Hub</a>
            <span>/</span>
            <span>Preview</span>
        </div>

        <section class="sv-card mv-head-card">
            <div class="sv-card-body mv-head-body">
                <div>
                    <p class="mv-kicker">${material.materialType}</p>
                    <h2>${material.title}</h2>
                    <p class="mv-description">
                        <c:choose>
                            <c:when test="${not empty material.description}">${material.description}</c:when>
                            <c:otherwise>No description provided for this material.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="mv-head-actions">
                    <a class="sv-btn" href="${backToHubUrl}">${backToHubLabel}</a>
                    <a class="sv-btn" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${material.materialId}">Open in New Tab</a>
                    <c:if test="${material.materialType != 'Link'}">
                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=download&id=${material.materialId}">Download</a>
                    </c:if>
                </div>
            </div>
        </section>

        <section class="sv-card mv-viewer-card">
            <div class="sv-card-body">
                <c:choose>
                    <c:when test="${isLinkMaterial}">
                        <div class="mv-link-state">
                            <i class="fas fa-link"></i>
                            <h3>External Resource</h3>
                            <p>This material is an external link. Open it in a new tab.</p>
                            <a class="sv-btn primary" target="_blank" rel="noopener noreferrer" href="${pageContext.request.contextPath}/student/materials?action=view&id=${material.materialId}">Open Resource</a>
                        </div>
                    </c:when>
                    <c:when test="${isVideoMaterial}">
                        <div class="mv-player-wrap">
                            <video class="mv-video" controls preload="metadata" playsinline>
                                <source src="${streamUrl}">
                                Your browser does not support embedded video playback.
                            </video>
                        </div>
                    </c:when>
                    <c:when test="${isAudioMaterial}">
                        <div class="mv-audio-wrap">
                            <audio controls preload="metadata" class="mv-audio">
                                <source src="${streamUrl}">
                                Your browser does not support audio playback.
                            </audio>
                        </div>
                    </c:when>
                    <c:when test="${isPdfMaterial}">
                        <div class="mv-frame-wrap">
                            <iframe class="mv-frame" src="${streamUrl}" title="Material PDF preview"></iframe>
                        </div>
                    </c:when>
                    <c:when test="${canInlinePreview}">
                        <div class="mv-frame-wrap">
                            <iframe class="mv-frame" src="${streamUrl}" title="Material preview"></iframe>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mv-link-state">
                            <i class="fas fa-file-arrow-down"></i>
                            <h3>Preview Not Available</h3>
                            <p>This file type cannot be embedded reliably in-browser. Use download or open in a new tab.</p>
                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=download&id=${material.materialId}">Download File</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
