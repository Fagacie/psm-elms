<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${enrollment.courseName} - Learning Hub</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-details-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Learning Hub</h1><p>${enrollment.courseName}</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link active"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span>/</span>
            <span>${enrollment.courseName}</span>
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
                <div class="ed-meta-item"><span>Progress</span><strong>${progressPercent}%</strong></div>
                <div class="ed-meta-item"><span>Materials Viewed</span><strong>${materialsViewedCount} / ${materialCount}</strong></div>
            </div>
        </section>

        <section class="sv-card ed-readiness-card">
            <div class="sv-card-head">
                <div>
                    <h3>Certificate Readiness</h3>
                    <p class="sv-card-sub">Track the exact requirements the system uses before a certificate can be generated for this course.</p>
                </div>
                <span class="status-badge ${certificateEligible ? 'status-Approved' : 'status-Pending'}">
                    ${certificateEligible ? 'Ready to Generate' : 'Requirements Pending'}
                </span>
            </div>
            <div class="sv-card-body">
                <div class="ed-readiness-panel">
                    <div class="ed-readiness-overview">
                        <span class="ed-readiness-kicker">Completion Tracker</span>
                        <h4>${certificateReadinessPercent}% ready</h4>
                        <p>${certificateReadinessHint}</p>
                        <div class="ed-readiness-progress">
                            <span>${certificateReadinessStepsComplete} of 3 checks complete</span>
                            <div class="sv-progress"><div class="sv-progress-bar" style="width:${certificateReadinessPercent}%;"></div></div>
                        </div>
                        <div class="ed-readiness-actions">
                            <a class="sv-btn primary" href="${certificatePrimaryActionUrl}">
                                <i class="fas ${certificatePrimaryActionIcon}"></i>&nbsp;${certificatePrimaryActionLabel}
                            </a>
                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/certificates">
                                <i class="fas fa-arrow-up-right-from-square"></i>&nbsp;Certificate Area
                            </a>
                        </div>
                    </div>

                    <div class="ed-readiness-grid">
                        <div class="ed-readiness-item ${certificatePaidReady ? 'is-ready' : 'is-pending'}">
                            <div class="ed-readiness-item-top">
                                <strong>Payment</strong>
                                <span class="status-badge ${certificatePaidReady ? 'status-Approved' : 'status-Pending'}">${certificatePaidReady ? 'Done' : 'Pending'}</span>
                            </div>
                            <span>${certificatePaidReady ? 'Paid and verified' : 'Complete payment to continue'}</span>
                            <small>${not empty enrollment.paymentRef ? enrollment.paymentRef : 'No verified payment reference yet'}</small>
                        </div>
                        <div class="ed-readiness-item ${certificateCompletedReady ? 'is-ready' : 'is-pending'}">
                            <div class="ed-readiness-item-top">
                                <strong>Course Progress</strong>
                                <span class="status-badge ${certificateCompletedReady ? 'status-Approved' : 'status-Pending'}">${certificateCompletedReady ? 'Done' : 'Pending'}</span>
                            </div>
                            <span>
                                <c:choose>
                                    <c:when test="${certificateCompletedReady}">Learning requirements completed</c:when>
                                    <c:otherwise>${materialsViewedCount} / ${totalMaterialsCount} materials viewed</c:otherwise>
                                </c:choose>
                            </span>
                            <small>
                                <c:choose>
                                    <c:when test="${certificateRemainingMaterials > 0}">${certificateRemainingMaterials} material(s) still need to be opened or downloaded</c:when>
                                    <c:otherwise>All current materials have been accessed in sequence</c:otherwise>
                                </c:choose>
                            </small>
                        </div>
                        <div class="ed-readiness-item ${certificateAssessmentsReady ? 'is-ready' : 'is-pending'}">
                            <div class="ed-readiness-item-top">
                                <strong>Assessments</strong>
                                <span class="status-badge ${certificateAssessmentsReady ? 'status-Approved' : 'status-Pending'}">${certificateAssessmentsReady ? 'Done' : 'Pending'}</span>
                            </div>
                            <span>
                                <c:choose>
                                    <c:when test="${certificateAssessmentsReady}">All required assessments passed</c:when>
                                    <c:otherwise>${passedAssessmentsCount} / ${totalAssessmentsCount} assessments passed</c:otherwise>
                                </c:choose>
                            </span>
                            <small>
                                <c:choose>
                                    <c:when test="${certificateRemainingAssessments > 0}">${certificateRemainingAssessments} assessment(s) still need a passing result</c:when>
                                    <c:otherwise>No remaining assessment blockers</c:otherwise>
                                </c:choose>
                            </small>
                        </div>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${certificateEligible}">
                        <div class="alert alert-success">
                            You have met the current requirements for certificate generation. Open your certificate area to generate or review it.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-info">
                            Your certificate is not blocked by guesswork anymore. Use the checklist above to see exactly what is still missing.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <div class="ed-tabs">
            <a class="ed-tab ${activeTab == 'learning' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning"><i class="fas fa-layer-group"></i> Learning Hub</a>
            <a class="ed-tab ${activeTab == 'overview' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=overview"><i class="fas fa-info-circle"></i> Overview</a>
            <a class="ed-tab ${activeTab == 'materials' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=materials"><i class="fas fa-folder-open"></i> Materials</a>
            <a class="ed-tab ${activeTab == 'assessments' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments"><i class="fas fa-clipboard-check"></i> Assessments</a>
        </div>

        <c:choose>
            <c:when test="${activeTab == 'learning'}">
                <section class="sv-card">
                    <div class="sv-card-head"><h3>Learning Sequence</h3></div>
                    <div class="sv-card-body">
                        <c:if test="${not paidAccess}"><div class="alert alert-error">Payment is required to open materials and take assessments.</div></c:if>
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
                                        <a class="sv-btn primary" href="${recommendedItem.primaryActionUrl}">
                                            <i class="fas ${recommendedItem.primaryActionIcon}"></i>&nbsp;${recommendedItem.primaryActionLabel}
                                        </a>
                                    </c:if>
                                    <c:if test="${not recommendedItem.locked and empty recommendedItem.primaryActionUrl and not empty recommendedItem.secondaryActionUrl}">
                                        <a class="sv-btn primary" href="${recommendedItem.secondaryActionUrl}">
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
                        <c:if test="${not paidAccess}"><div class="alert alert-error">Payment is required to view and download materials.</div></c:if>
                        <c:if test="${paidAccess}">
                            <c:if test="${not empty focusMaterial}">
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
                                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=view&id=${previousMaterial.materialId}">
                                                <i class="fas fa-arrow-left"></i>&nbsp;Previous
                                            </a>
                                        </c:if>
                                        <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/materials?action=view&id=${focusMaterial.materialId}">
                                            <i class="fas fa-book-open"></i>&nbsp;${viewedMaterialIds.contains(focusMaterial.materialId) ? 'Review Chapter' : 'Open Chapter'}
                                        </a>
                                        <c:if test="${not empty nextMaterial}">
                                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=view&id=${nextMaterial.materialId}">
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
                                            <tr>
                                                <td>
                                                    <strong>${m.title}</strong>
                                                    <c:if test="${not empty m.description}"><div class="sv-course-line">${m.description}</div></c:if>
                                                </td>
                                                <td><c:out value="${not empty m.displayOrder ? m.displayOrder : '-'}"/></td>
                                                <td><span class="assessment-type-badge assessment-type-Assignment">${m.materialType}</span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${viewedMaterialIds.contains(m.materialId)}">
                                                            <span class="status-badge status-Approved">Viewed</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-Archived">Pending</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><c:out value="${not empty m.uploadDate ? m.uploadDate.toLocalDate() : '-'}"/></td>
                                                <td>
                                                    <a class="sv-btn" target="_blank" href="${pageContext.request.contextPath}/student/materials?action=view&id=${m.materialId}">${viewedMaterialIds.contains(m.materialId) ? 'Review' : 'Open'}</a>
                                                    <c:if test="${m.materialType != 'Link'}"><a class="sv-btn" href="${pageContext.request.contextPath}/student/materials?action=download&id=${m.materialId}">Download</a></c:if>
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
                        <c:if test="${not paidAccess}"><div class="alert alert-error">Payment is required before taking assessments.</div></c:if>
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
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
