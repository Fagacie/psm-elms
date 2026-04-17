<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${enrollment.courseName} - Learning Hub</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-details-v2.css">
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Learning Hub"/>
<c:set var="topbarSubtitle" value="Track progress and continue learning"/>
<c:set var="topbarShowSearch" value="false"/>
<c:set var="navContext" value="course"/>
<c:set var="navContextPage" value="${activeTab == 'overview' ? 'overview' : (activeTab == 'materials' ? 'materials' : (activeTab == 'assessments' ? 'assessments' : 'progress'))}"/>
<c:set var="navCourseEnrollmentId" value="${enrollment.enrollmentId}"/>
<c:set var="navCourseTitle" value="${enrollment.courseName}"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="my-courses"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>Learning Hub</span>
        </div>

        <c:set var="isPaymentComplete" value="${enrollment.paymentStatus == 'Paid' || enrollment.paymentStatus == 'COMPLETED' || enrollment.paymentStatus == 'Completed' || enrollment.paymentStatus == 'SUCCESS' || enrollment.paymentStatus == 'success'}"/>

        <section class="ed-hero">
            <div class="ed-hero-top">
                <div>
                    <h2>${enrollment.courseName}</h2>
                    <p class="ed-sub">${enrollment.courseDescription}</p>
                </div>
                <span class="status-badge ${isPaymentComplete ? 'status-Approved' : 'status-Pending'}">
                    <i class="fas fa-${isPaymentComplete ? 'check-circle' : 'clock'}"></i>
                    ${isPaymentComplete ? 'Paid' : 'Payment Pending'}
                </span>
            </div>

            <div class="ed-progress-wrap">
                <div class="sv-progress"><div class="sv-progress-bar" style="width:${progressPercent}%;"></div></div>
            </div>

            <div class="ed-meta">
                <div class="ed-meta-item"><span>Instructor</span><strong>${enrollment.instructorName}</strong></div>
                <div class="ed-meta-item"><span>Enrolled</span><strong><c:out value="${enrollment.enrollmentDate != null ? enrollment.enrollmentDate.toLocalDate() : '-'}"/></strong></div>
                <div class="ed-meta-item"><span>Course Fee</span><strong><fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong></div>
                <div class="ed-meta-item"><span>Progress</span><strong id="edProgressPercent">${progressPercent}%</strong></div>
                <div class="ed-meta-item"><span>Materials Viewed</span><strong id="edMaterialsViewedCount" data-total-materials="${materialCount}">${materialsViewedCount} / ${materialCount}</strong></div>
            </div>
        </section>

        <c:set var="materialsViewedSafe" value="${empty materialsViewedCount ? 0 : materialsViewedCount}"/>
        <c:set var="materialsTotalSafe" value="${empty materialCount ? 0 : materialCount}"/>
        <c:set var="assessmentsPassedSafe" value="${empty passedAssessmentsCount ? 0 : passedAssessmentsCount}"/>
        <c:set var="assessmentsTotalSafe" value="${empty totalAssessmentsCount ? 0 : totalAssessmentsCount}"/>

        <div class="ed-tabs" role="tablist" aria-label="Learning hub sections">
            <a class="ed-tab ${activeTab == 'learning' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/student/enrollment-details?enrollmentId=${enrollment.enrollmentId}&tab=learning">
                <i class="fas fa-route"></i> Learning
            </a>
            <a class="ed-tab ${activeTab == 'overview' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/student/enrollment-details?enrollmentId=${enrollment.enrollmentId}&tab=overview">
                <i class="fas fa-table-columns"></i> Overview
            </a>
            <a class="ed-tab ${activeTab == 'materials' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/student/enrollment-details?enrollmentId=${enrollment.enrollmentId}&tab=materials">
                <i class="fas fa-book"></i> Materials
            </a>
            <a class="ed-tab ${activeTab == 'assessments' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/student/enrollment-details?enrollmentId=${enrollment.enrollmentId}&tab=assessments">
                <i class="fas fa-clipboard-check"></i> Assessments
            </a>
        </div>

        <c:choose>
            <c:when test="${activeTab == 'learning'}">
                <section class="sv-card">
                    <div class="sv-card-head"><h3>Learning Sequence</h3></div>
                    <div class="sv-card-body">
                        <c:if test="${not paidAccess}">
                            <div class="alert alert-error">
                                Payment is required to open materials and take assessments.
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/payment?enrollmentId=${enrollment.enrollmentId}">
                                    <i class="fas fa-credit-card"></i>&nbsp;Complete Payment
                                </a>
                            </div>
                        </c:if>
                        <c:if test="${not empty recommendedItem}">
                            <div class="ed-next-step">
                                <div class="ed-next-copy">
                                    <span class="ed-next-kicker">Recommended Next Step</span>
                                    <h4>${recommendedItem.title}</h4>
                                    <p>
                                        <c:choose>
                                            <c:when test="${not empty recommendedItem.description}">${recommendedItem.description}</c:when>
                                            <c:otherwise>Continue your course in sequence and keep your progress moving toward completion.</c:otherwise>
                                        </c:choose>
                                    </p>
                                    <div class="ed-learning-meta">
                                        <c:if test="${not empty recommendedItem.metaPrimary}"><span><i class="fas fa-clock"></i> ${recommendedItem.metaPrimary}</span></c:if>
                                        <c:if test="${not empty recommendedItem.metaSecondary}"><span><i class="fas fa-list-check"></i> ${recommendedItem.metaSecondary}</span></c:if>
                                    </div>
                                </div>
                                <div class="ed-next-actions">
                                    <span class="status-badge ${recommendedItem.statusClass}">${recommendedItem.statusLabel}</span>
                                    <c:if test="${not recommendedItem.locked and not empty recommendedItem.primaryActionUrl}">
                                        <a id="edContinueAction" class="sv-btn primary" href="${recommendedItem.primaryActionUrl}">
                                            <i class="fas ${recommendedItem.primaryActionIcon}"></i>&nbsp;${recommendedItem.primaryActionLabel}
                                        </a>
                                    </c:if>
                                    <c:if test="${not recommendedItem.locked and empty recommendedItem.primaryActionUrl and not empty recommendedItem.secondaryActionUrl}">
                                        <a id="edContinueAction" class="sv-btn primary" href="${recommendedItem.secondaryActionUrl}">
                                            <i class="fas ${recommendedItem.secondaryActionIcon}"></i>&nbsp;${recommendedItem.secondaryActionLabel}
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>
                        <c:choose>
                            <c:when test="${not empty learningItems}">
                                <div class="ed-learning-list">
                                    <c:set var="currentGroup" value="" />
                                    <c:forEach var="item" items="${learningItems}">
                                        <c:if test="${currentGroup != item.groupLabel}">
                                            <div class="ed-group-header">
                                                <div class="ed-group-header-copy">
                                                    <span class="ed-group-kicker">Sequence Block</span>
                                                    <h4>${item.groupLabel}</h4>
                                                    <p>${item.groupHint}</p>
                                                </div>
                                                <div class="ed-group-summary">
                                                    <span class="status-badge ${item.groupStatusClass}">${item.groupStatusLabel}</span>
                                                    <strong>${item.groupCompletedItems} / ${item.groupTotalItems}</strong>
                                                    <span>${item.groupCompletionPercent}% complete</span>
                                                </div>
                                            </div>
                                            <c:set var="currentGroup" value="${item.groupLabel}" />
                                        </c:if>
                                        <article class="ed-learning-item">
                                            <div class="ed-learning-main">
                                                <div class="ed-learning-icon"><i class="fas ${item.iconClass}"></i></div>
                                                <div>
                                                    <span class="ed-learning-type">${item.type}</span>
                                                    <h4 class="ed-learning-title">${item.title}</h4>
                                                    <c:if test="${not empty item.description}"><p class="ed-learning-desc">${item.description}</p></c:if>
                                                    <div class="ed-learning-meta">
                                                        <c:if test="${not empty item.metaPrimary}"><span><i class="fas fa-clock"></i> ${item.metaPrimary}</span></c:if>
                                                        <c:if test="${not empty item.metaSecondary}"><span><i class="fas fa-chart-bar"></i> ${item.metaSecondary}</span></c:if>
                                                        <c:if test="${not empty item.metaTertiary}"><span><i class="fas fa-award"></i> ${item.metaTertiary}</span></c:if>
                                                    </div>
                                                    <c:if test="${item.locked}"><div class="ed-learning-lock"><i class="fas fa-lock"></i> ${item.lockReason}</div></c:if>
                                                </div>
                                                <span class="status-badge ${item.statusClass}">${item.statusLabel}</span>
                                            </div>
                                            <div class="ed-learning-actions">
                                                <c:if test="${not item.locked and not empty item.primaryActionUrl}"><a class="sv-btn primary" href="${item.primaryActionUrl}"><i class="fas ${item.primaryActionIcon}"></i>&nbsp;${item.primaryActionLabel}</a></c:if>
                                                <c:if test="${not item.locked and not empty item.secondaryActionUrl}"><a class="sv-btn" href="${item.secondaryActionUrl}"><i class="fas ${item.secondaryActionIcon}"></i>&nbsp;${item.secondaryActionLabel}</a></c:if>
                                                <c:if test="${item.locked and not paidAccess}">
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/payment?enrollmentId=${enrollment.enrollmentId}">
                                                        <i class="fas fa-credit-card"></i>&nbsp;Unlock with Payment
                                                    </a>
                                                </c:if>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state-box"><i class="fas fa-layer-group"></i><p>No learning items available yet.</p></div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </section>
            </c:when>

            <c:when test="${activeTab == 'overview'}">
                <section class="ed-grid">
                    <article class="sv-card">
                        <div class="sv-card-head"><h3>Course Summary</h3></div>
                        <div class="sv-card-body">
                            <div class="ed-stat-block"><strong>Enrollment Status:</strong> ${enrollment.status}</div>
                            <div class="ed-stat-block"><strong>Completion Status:</strong> ${enrollment.completionStatus}</div>
                            <div class="ed-stat-block"><strong>Materials:</strong> ${materialCount}</div>
                            <div class="ed-stat-block"><strong>Assessments:</strong> ${assessmentCount}</div>
                            <c:if test="${not empty enrollment.instructorEmail}"><div class="ed-stat-block"><strong>Instructor Email:</strong> ${enrollment.instructorEmail}</div></c:if>
                            <c:if test="${not empty enrollment.paymentRef}"><div class="ed-stat-block"><strong>Payment Reference:</strong> ${enrollment.paymentRef}</div></c:if>
                        </div>
                    </article>
                    <article class="sv-card">
                        <div class="sv-card-head"><h3>Announcements</h3></div>
                        <div class="sv-card-body">
                            <c:choose>
                                <c:when test="${not empty announcements}">
                                    <c:forEach var="ann" items="${announcements}">
                                        <div class="ed-ann">
                                            <h4>${ann.title}</h4>
                                            <p>${ann.content}</p>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state-box"><i class="fas fa-bell-slash"></i><p>No announcements yet.</p></div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </article>
                </section>
            </c:when>

            <c:when test="${activeTab == 'materials'}">
                <section class="sv-card">
                    <div class="sv-card-head"><h3>Course Materials</h3></div>
                    <div class="sv-card-body">
                        <c:if test="${not paidAccess}">
                            <div class="alert alert-error">
                                Payment is required to view and download materials.
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/payment?enrollmentId=${enrollment.enrollmentId}">
                                    <i class="fas fa-credit-card"></i>&nbsp;Complete Payment
                                </a>
                            </div>
                        </c:if>
                        <c:if test="${paidAccess}">
                            <c:if test="${not empty focusMaterial}">
                                <c:set var="focusRule" value="${fn:toLowerCase(focusMaterial.materialType) == 'video' ? 'video' : (fn:toLowerCase(focusMaterial.materialType) == 'pdf' ? 'pdf' : 'default')}"/>
                                <div class="ed-material-nav">
                                    <div class="ed-material-nav-copy">
                                        <span class="ed-next-kicker">Continue Sequence</span>
                                        <h4>${focusMaterial.title}</h4>
                                        <p>
                                            <c:choose>
                                                <c:when test="${viewedMaterialIds.contains(focusMaterial.materialId)}">You have reached the current end of your viewed materials. Revisit this chapter or continue to the next one.</c:when>
                                                <c:otherwise>This is the next chapter the system recommends based on your learning sequence.</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                    <div class="ed-material-nav-actions">
                                        <c:if test="${not empty previousMaterial}">
                                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${previousMaterial.materialId}&enrollmentId=${enrollment.enrollmentId}">
                                                <i class="fas fa-arrow-left"></i>&nbsp;Previous
                                            </a>
                                        </c:if>
                                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${focusMaterial.materialId}&enrollmentId=${enrollment.enrollmentId}">
                                            <i class="fas fa-book-open"></i>&nbsp;Open
                                        </a>
                                        <c:if test="${not empty nextMaterial}">
                                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${nextMaterial.materialId}&enrollmentId=${enrollment.enrollmentId}">
                                                Next&nbsp;<i class="fas fa-arrow-right"></i>
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </c:if>

                            <c:choose>
                                <c:when test="${not empty materials}">
                                    <table class="ed-table">
                                        <thead><tr><th>Material</th><th>Chapter</th><th>Type</th><th>Status</th><th>Uploaded</th><th>Actions</th></tr></thead>
                                        <tbody>
                                        <c:forEach var="m" items="${materials}">
                                            <c:set var="materialStatus" value="${materialStatusById[m.materialId]}"/>
                                            <c:set var="materialTypeLower" value="${fn:toLowerCase(m.materialType)}"/>
                                            <c:set var="completionRule" value="${materialTypeLower == 'video' ? 'video' : (materialTypeLower == 'pdf' ? 'pdf' : 'default')}"/>
                                            <tr>
                                                <td>
                                                    <strong>${m.title}</strong>
                                                    <c:if test="${not empty m.description}"><div class="sv-course-line">${m.description}</div></c:if>
                                                </td>
                                                <td><c:out value="${not empty m.displayOrder ? m.displayOrder : '-'}"/></td>
                                                <td><span class="assessment-type-badge assessment-type-Assignment">${m.materialType}</span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${materialStatus == 'completed'}">
                                                            <span class="status-badge status-Approved">Completed</span>
                                                        </c:when>
                                                        <c:when test="${materialStatus == 'in_progress'}">
                                                            <span class="status-badge status-Pending">In Progress</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-Archived">Available</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><c:out value="${not empty m.uploadDate ? m.uploadDate.toLocalDate() : '-'}"/></td>
                                                <td>
                                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=preview&id=${m.materialId}&enrollmentId=${enrollment.enrollmentId}">Open</a>
                                                    <c:if test="${fn:toLowerCase(m.materialType) != 'link'}">
                                                        <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=download&id=${m.materialId}">Download</a>
                                                    </c:if>
                                                    <c:if test="${materialStatus != 'completed'}">
                                                        <button type="button"
                                                                class="sv-btn js-mark-material-completed"
                                                                data-material-id="${m.materialId}"
                                                                data-enrollment-id="${enrollment.enrollmentId}"
                                                                data-material-title="${fn:escapeXml(m.title)}"
                                                                <c:if test="${completionRule != 'default'}">disabled="disabled"</c:if>
                                                                <c:if test="${completionRule != 'default'}">title="Open the preview page to complete this material."</c:if>>
                                                            <c:choose>
                                                                <c:when test="${completionRule != 'default'}">Complete in Preview</c:when>
                                                                <c:otherwise>Mark as Completed</c:otherwise>
                                                            </c:choose>
                                                        </button>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise><div class="empty-state-box"><i class="fas fa-folder-open"></i><p>No materials available yet.</p></div></c:otherwise>
                            </c:choose>
                        </c:if>
                    </div>
                </section>
            </c:when>

            <c:when test="${activeTab == 'assessments'}">
                <section class="sv-card">
                    <div class="sv-card-head"><h3>Course Assessments</h3></div>
                    <div class="sv-card-body">
                        <c:if test="${not paidAccess}">
                            <div class="alert alert-error">
                                Payment is required before taking assessments.
                                <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/payment?enrollmentId=${enrollment.enrollmentId}">
                                    <i class="fas fa-credit-card"></i>&nbsp;Complete Payment
                                </a>
                            </div>
                        </c:if>
                        <c:choose>
                            <c:when test="${not empty assessments}">
                                <table class="ed-table">
                                    <thead><tr><th>Assessment</th><th>Type</th><th>Duration</th><th>Attempts</th><th>Latest</th><th>Actions</th></tr></thead>
                                    <tbody>
                                    <c:forEach var="a" items="${assessments}">
                                        <c:set var="usedAttempts" value="${usedAttemptsByAssessment[a.assessmentId]}"/>
                                        <c:set var="allowedAttempts" value="${allowedAttemptsByAssessment[a.assessmentId]}"/>
                                        <c:set var="latest" value="${latestSubmissionByAssessment[a.assessmentId]}"/>
                                        <c:set var="hasActiveAttempt" value="${activeAttemptByAssessment[a.assessmentId]}"/>
                                        <tr>
                                            <td>${a.title}</td>
                                            <td><span class="assessment-type-badge assessment-type-${a.type}">${a.type}</span></td>
                                            <td>${a.duration} min</td>
                                            <td>${usedAttempts} / ${allowedAttempts}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty latest}">
                                                        <div><c:out value="${empty latest.status ? 'Submitted' : latest.status}"/></div>
                                                        <c:if test="${latest.score != null}"><div class="sv-course-line">${latest.score}</div></c:if>
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:if test="${paidAccess}">
                                                    <c:choose>
                                                        <c:when test="${hasActiveAttempt}">
                                                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}&mode=attempt&fromHub=1&enrollmentId=${enrollment.enrollmentId}">Continue</a>
                                                        </c:when>
                                                        <c:when test="${usedAttempts < allowedAttempts}">
                                                            <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}&fromHub=1&enrollmentId=${enrollment.enrollmentId}">Start</a>
                                                        </c:when>
                                                    </c:choose>
                                                </c:if>
                                                <a class="sv-btn" href="${pageContext.request.contextPath}/student/assessments?courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}&fromHub=1&enrollmentId=${enrollment.enrollmentId}">Details</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise><div class="empty-state-box"><i class="fas fa-clipboard-list"></i><p>No assessments published yet.</p></div></c:otherwise>
                        </c:choose>
                    </div>
                </section>
            </c:when>
        </c:choose>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script>
(function () {
    var completionButtons = document.querySelectorAll('.js-mark-material-completed');
    var progressPercentNode = document.getElementById('edProgressPercent');
    var materialsViewedNode = document.getElementById('edMaterialsViewedCount');

    function updateProgressUI(progressPercent) {
        var progressBars = document.querySelectorAll('.sv-progress-bar');
        for (var i = 0; i < progressBars.length; i++) {
            progressBars[i].style.width = progressPercent + '%';
        }

        if (progressPercentNode) {
            progressPercentNode.textContent = progressPercent + '%';
        }
    }

    function updateContinueAction(label, url) {
        var continueLink = document.getElementById('edContinueAction');
        if (!continueLink || !label || !url) {
            return;
        }
        continueLink.setAttribute('href', url);
        continueLink.innerHTML = '<i class="fas fa-play"></i>&nbsp;' + label;
    }

    function setRowCompleted(button) {
        var row = button.closest('tr');
        if (!row) {
            return;
        }
        var statusCell = row.children[3];
        if (statusCell) {
            statusCell.innerHTML = '<span class="status-badge status-Approved">Completed</span>';
        }
        button.remove();
    }

    function updateMaterialsViewed(viewedMaterials, totalMaterials) {
        if (!materialsViewedNode || typeof viewedMaterials !== 'number') {
            return;
        }
        var total = typeof totalMaterials === 'number'
            ? totalMaterials
            : parseInt(materialsViewedNode.getAttribute('data-total-materials'), 10);
        if (isNaN(total)) {
            total = 0;
        }
        materialsViewedNode.setAttribute('data-total-materials', total);
        materialsViewedNode.textContent = viewedMaterials + ' / ' + total;
    }

    for (var i = 0; i < completionButtons.length; i++) {
        completionButtons[i].addEventListener('click', function () {
            var button = this;
            var materialId = button.getAttribute('data-material-id');
            var enrollmentId = button.getAttribute('data-enrollment-id');
            if (!materialId || !enrollmentId) {
                return;
            }

            if (button.disabled) {
                return;
            }

            button.disabled = true;
            var oldText = button.textContent;
            button.textContent = 'Saving...';

            var payload = 'materialId=' + encodeURIComponent(materialId) + '&enrollmentId=' + encodeURIComponent(enrollmentId);

            fetch('${pageContext.request.contextPath}/student/mark-material-completed', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: payload
            })
                .then(function (response) {
                    if (!response.ok) {
                        throw new Error('Failed to save completion');
                    }
                    return response.json();
                })
                .then(function (data) {
                    if (!data.success) {
                        throw new Error(data.message || 'Completion failed');
                    }
                    setRowCompleted(button);
                    if (typeof data.progressPercent === 'number') {
                        updateProgressUI(data.progressPercent);
                    }
                    updateMaterialsViewed(data.viewedMaterials, data.totalMaterials);
                    updateContinueAction(data.continueLabel, data.continueUrl);
                })
                .catch(function (error) {
                    button.disabled = false;
                    button.textContent = oldText;
                    alert(error.message || 'Unable to mark material as completed.');
                });
        });
    }
})();
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>

