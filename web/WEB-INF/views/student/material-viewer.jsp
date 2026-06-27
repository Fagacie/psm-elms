<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material Preview - PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/learning-hub-modern.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/material-viewer-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Material Preview"/>
<c:set var="topbarSubtitle" value="Review the current material."/>
<c:set var="previewEnrollmentId" value="${not empty previewEnrollment ? previewEnrollment.enrollmentId : ''}"/>
<c:set var="courseProgressPercent" value="${not empty previewEnrollment and not empty previewEnrollment.progress ? previewEnrollment.progress : 0}"/>

<c:set var="navContext" value="${not empty previewEnrollmentId ? 'course' : 'default'}"/>
<c:set var="navContextPage" value="materials"/>
<c:set var="navCourseEnrollmentId" value="${previewEnrollmentId}"/>
<c:set var="navCourseTitle" value="${not empty previewEnrollment.courseName ? previewEnrollment.courseName : material.title}"/>
<c:choose>
    <c:when test="${isInstructorPreview or not empty sessionScope.instructor or sessionScope.role eq 'Instructor' or sessionScope.role eq 'Admin'}">
        <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
            <jsp:param name="pageTitle" value="Material Preview"/>
        </jsp:include>
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>
    </c:otherwise>
</c:choose>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <c:choose>
        <c:when test="${isInstructorPreview or not empty sessionScope.instructor or sessionScope.role eq 'Instructor' or sessionScope.role eq 'Admin'}">
            <c:set var="activeInstructorPage" value="courses" scope="request"/>
            <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>
        </c:when>
        <c:otherwise>
            <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>
        </c:otherwise>
    </c:choose>

    <main class="sv-main mv-main">

        <section class="lh-workspace mv-shell">
            <header class="lh-stage-head">
                <div class="lh-stage-head__copy">
                    <span class="lh-stage-eyebrow">${material.materialType}</span>
                    <h2>${material.title}</h2>
                    <p>
                        <c:choose>
                            <c:when test="${not empty material.description}">${material.description}</c:when>
                            <c:otherwise>Review the material here, then continue.</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="lh-stage-head__status">
                    <c:choose>
                        <c:when test="${isInstructorPreview or not empty sessionScope.instructor or sessionScope.role eq 'Instructor' or sessionScope.role eq 'Admin'}">
                            <span class="status-badge status-published" style="background:#e0e7ff; color:#4f46e5;"><i class="fas fa-eye"></i> Instructor Preview Mode</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-badge ${materialStatusClass}" id="mvStatusBadge">${materialStatusLabel}</span>
                        </c:otherwise>
                    </c:choose>
                    <span class="lh-stage-access is-ready">
                        <i class="fas fa-layer-group"></i>
                        ${(isInstructorPreview or not empty sessionScope.instructor or sessionScope.role eq 'Instructor' or sessionScope.role eq 'Admin') ? 'Instructor Curriculum View' : (not empty previewEnrollmentId ? 'Course-linked viewer' : 'Standalone viewer')}
                    </span>
                </div>
            </header>

            <div class="lh-stage-meta">
                <span class="lh-stage-chip"><i class="fas fa-tag"></i> ${material.materialType}</span>
                <c:if test="${materialPosition > 0}">
                    <span class="lh-stage-chip"><i class="fas fa-list-ol"></i> ${materialPosition} / ${totalMaterialsInCourse}</span>
                </c:if>
                <c:if test="${not (isInstructorPreview or not empty sessionScope.instructor or sessionScope.role eq 'Instructor' or sessionScope.role eq 'Admin')}">
                    <span class="lh-stage-chip"><i class="fas fa-chart-line"></i> <strong id="mvCourseProgressPercent">${courseProgressPercent}%</strong></span>
                    <span class="lh-stage-chip"><i class="fas fa-circle-check"></i> <span id="mvStatusChip">${materialStatusLabel}</span></span>
                </c:if>
            </div>

            <div class="lh-stage-body">
                <jsp:include page="/WEB-INF/views/student/fragments/material-viewer-fragment.jsp"/>
            </div>

            <footer class="mv-footer">
                <div class="mv-footer-left">
                    <c:if test="${not empty previousMaterial}">
                        <a class="sv-btn" href="${pageContext.request.contextPath}${(isInstructorPreview or not empty sessionScope.instructor or sessionScope.role eq 'Instructor' or sessionScope.role eq 'Admin') ? '/instructor/materials-preview' : '/student/materials'}?action=preview&id=${previousMaterial.materialId}${not empty previewEnrollmentId ? '&enrollmentId='.concat(previewEnrollmentId) : ''}">
                            &larr; Previous Module
                        </a>
                    </c:if>
                </div>
                <div class="mv-footer-right">
                    <c:choose>
                        <c:when test="${isInstructorPreview or not empty sessionScope.instructor or sessionScope.role eq 'Instructor' or sessionScope.role eq 'Admin'}">
                            <a class="sv-btn primary" href="${backToHubUrl}" style="background:#4f46e5; color:white; font-weight:600;">
                                <i class="fas fa-arrow-left"></i> Back to Course Workspace
                            </a>
                            <c:if test="${not empty nextMaterial}">
                                <a class="sv-btn" href="${pageContext.request.contextPath}/instructor/materials-preview?action=preview&id=${nextMaterial.materialId}" style="margin-left: 8px;">
                                    Next Material &rarr;
                                </a>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                        <c:when test="${previewEnrollment.daysRemaining < 0 && previewEnrollment.courseDuration != null && previewEnrollment.courseDuration > 0}">
                            <button
                                type="button"
                                class="sv-btn"
                                style="background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); cursor: not-allowed;"
                                disabled="disabled">
                                <i class="fas fa-calendar-times"></i>
                                <span>Expired (Read-Only)</span>
                            </button>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${isCompletedMaterial}">
                                    <a class="sv-btn primary" href="${not empty nextMaterial ? pageContext.request.contextPath.concat('/student/materials?action=preview&id=').concat(nextMaterial.materialId).concat('&enrollmentId=').concat(previewEnrollmentId) : backToHubUrl}">
                                        Next Module &rarr;
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button
                                        id="mvMarkCompleted"
                                        type="button"
                                        class="sv-btn primary"
                                        data-material-id="${material.materialId}"
                                        data-enrollment-id="${previewEnrollmentId}"
                                        data-completed="${isCompletedMaterial}"
                                        data-complete-url="${completeActionUrl}">
                                        Complete & Continue &rarr;
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                        </c:otherwise>
                    </c:choose>
                </div>
            </footer>
        </section>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
(function () {
    var completeButton = document.getElementById('mvMarkCompleted');
    if (!completeButton) return;
    var statusBadge = document.getElementById('mvStatusBadge');
    var statusChip = document.getElementById('mvStatusChip');
    var courseProgressBadge = document.getElementById('mvCourseProgressPercent');
    var completedNote = 'This material is already part of your course progress.';
    var viewerState = {
        unlocked: '${isCompletedMaterial}' === 'true',
        completed: '${isCompletedMaterial}' === 'true'
    };

    if (!completeButton) {
        return;
    }

    function setButtonState(disabled, label) {
        completeButton.disabled = !!disabled;
        if (label) {
            completeButton.innerHTML = '<span>' + label + '</span>';
        }
    }

    function applyCompletedState() {
        viewerState.completed = true;
        viewerState.unlocked = true;
        if (statusBadge) {
            statusBadge.className = 'status-badge status-Approved';
            statusBadge.textContent = 'Completed';
        }
        if (statusChip) {
            statusChip.textContent = 'Completed';
        }
    }

    function unlockCompletion() {
        if (viewerState.completed) {
            return;
        }
        viewerState.unlocked = true;
        setButtonState(false, 'Complete & Continue &rarr;');
    }

    function setWaitingState() {
        if (viewerState.completed) {
            return;
        }
        setButtonState(true, 'Reviewing...');
    }

    if (viewerState.completed) {
        applyCompletedState();
    } else {
        setWaitingState();
    }

    completeButton.addEventListener('click', function () {
        if (completeButton.disabled || viewerState.completed) {
            return;
        }

        var materialId = completeButton.getAttribute('data-material-id');
        var enrollmentId = completeButton.getAttribute('data-enrollment-id');
        var completeUrl = completeButton.getAttribute('data-complete-url');
        if (!materialId || !completeUrl) {
            return;
        }

        setButtonState(true, 'Saving...');
        var payload = 'materialId=' + encodeURIComponent(materialId);
        if (enrollmentId) {
            payload += '&enrollmentId=' + encodeURIComponent(enrollmentId);
        }

        fetch(completeUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: payload
        })
        .then(function (response) {
            if (!response.ok) {
                throw new Error('Unable to save completion.');
            }
            return response.json();
        })
        .then(function (data) {
            if (!data.success) {
                throw new Error(data.message || 'Unable to save completion.');
            }
            applyCompletedState();
            
            // Auto redirect upon successful completion
            var nextUrl = '${not empty nextMaterial ? pageContext.request.contextPath.concat("/student/materials?action=preview&id=").concat(nextMaterial.materialId).concat("&enrollmentId=").concat(previewEnrollmentId) : backToHubUrl}';
            window.location.href = nextUrl;
        })
        .catch(function (error) {
            viewerState.unlocked = false;
            setWaitingState();
            unlockCompletion();
        });
    });

    window.addEventListener('message', function (event) {
        if (event.origin !== window.location.origin || !event.data) {
            return;
        }

        if (event.data.type === 'lhViewerState') {
            if (event.data.completed) {
                applyCompletedState();
                return;
            }
        }

        if (event.data.type === 'lhViewerUnlock') {
            unlockCompletion();
        }
    });
})();
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
