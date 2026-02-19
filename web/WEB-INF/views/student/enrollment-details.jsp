<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Details - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/course-details.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/materials.css">
</head>
<body>
<nav class="top-navbar">
    <div class="top-navbar-inner">
        <div class="top-navbar-left">
            <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                <span class="logo-text">PSM</span>
                <span class="logo-subtext">E-Learning</span>
            </a>
            <h1 class="page-title-nav">Course Details</h1>
        </div>
        <div class="top-navbar-right">
            <button class="notification-btn" aria-label="Notifications">
                <i class="fas fa-bell"></i>
                <span class="notification-badge">3</span>
            </button>
            <div class="user-display">
                <div class="user-avatar-small"><i class="fas fa-user"></i></div>
                <span class="user-name-display">${sessionScope.userName}</span>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </div>
</nav>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item"><i class="fas fa-home"></i><span>Dashboard</span></a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item active"><i class="fas fa-graduation-cap"></i><span>My Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/courses" class="nav-item"><i class="fas fa-book"></i><span>Browse Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/materials" class="nav-item"><i class="fas fa-folder-open"></i><span>Materials</span></a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="nav-item"><i class="fas fa-clipboard-list"></i><span>Assessments</span></a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="nav-item"><i class="fas fa-certificate"></i><span>Certificates</span></a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item"><i class="fas fa-user"></i><span>Profile</span></a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Home</a>
            <span class="separator">/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
            <span class="separator">/</span>
            <span>${enrollment.courseName}</span>
        </div>
        <section class="section-card course-hero">
            <div class="page-header">
                <div>
                    <h2><i class="fas fa-graduation-cap"></i> ${enrollment.courseName}</h2>
                    <p class="text-muted"><i class="fas fa-chalkboard-teacher"></i> ${enrollment.instructorName}</p>
                    <p class="text-muted" style="margin-top: 8px;">${enrollment.courseDescription}</p>
                </div>
            </div>
            <div class="summary-block">
                <div class="progress-wrap progress-wrap-wide">
                    <div class="progress-title-row">
                        <span>Course Progress</span><span>${progressPercent}%</span>
                    </div>
                    <div class="progress-track progress-track-lg">
                        <div class="progress-fill" style="width:${progressPercent}%"></div>
                    </div>
                    <div class="meta-row">
                        <span><i class="fas fa-calendar-check"></i> Enrolled: <c:out value="${enrollment.enrollmentDate != null ? enrollment.enrollmentDate.toLocalDate() : '-'}"/></span>
                        <span><i class="fas fa-money-bill-wave"></i> Fee: NGN <fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                        <span>
                            <i class="fas fa-${enrollment.paymentStatus == 'COMPLETED' ? 'check-circle' : 'clock'}"></i> 
                            Payment: 
                            <c:choose>
                                <c:when test="${enrollment.paymentStatus == 'COMPLETED'}">
                                    <span class="badge badge-success">${enrollment.paymentStatus}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-warning">${enrollment.paymentStatus}</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="tab-links">
                <a class="tab-link ${activeTab == 'overview' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=overview">
                    <i class="fas fa-info-circle"></i> Overview
                </a>
                <a class="tab-link ${activeTab == 'materials' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=materials">
                    <i class="fas fa-folder-open"></i> Materials
                </a>
                <a class="tab-link ${activeTab == 'assessments' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                    <i class="fas fa-clipboard-list"></i> Assessments
                </a>
            </div>

            <c:choose>
                <c:when test="${activeTab == 'assessments'}">
                    <h3 class="section-title-lg"><i class="fas fa-clipboard-list"></i> Course Assessments</h3>
                    <c:if test="${not paidAccess}">
                        <div class="alert alert-warning" style="margin-top:12px;">Payment is required before taking assessments.</div>
                    </c:if>
                    <div class="stats-grid stats-tight">
                        <div class="stat-card"><div class="stat-content"><h3>${assessmentCount}</h3><p>Assessments</p></div></div>
                        <div class="stat-card"><div class="stat-content"><h3>${materialCount}</h3><p>Learning Materials</p></div></div>
                    </div>
                    <c:if test="${not empty assessments}">
                        <table class="course-table">
                            <thead>
                            <tr><th>Assessment</th><th>Type</th><th>Duration</th><th>Attempts</th><th>Latest Result</th><th>Action</th></tr>
                            </thead>
                            <tbody>
                            <c:forEach var="a" items="${assessments}">
                                <c:set var="usedAttempts" value="${usedAttemptsByAssessment[a.assessmentId]}"/>
                                <c:set var="allowedAttempts" value="${allowedAttemptsByAssessment[a.assessmentId]}"/>
                                <c:set var="latest" value="${latestSubmissionByAssessment[a.assessmentId]}"/>
                                <c:set var="hasActiveAttempt" value="${activeAttemptByAssessment[a.assessmentId]}"/>
                                <tr>
                                    <td>${a.title}</td>
                                    <td>${a.type}</td>
                                    <td>${a.duration} minutes</td>
                                    <td>${usedAttempts} / ${allowedAttempts}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty latest}">
                                                <c:out value="${empty latest.status ? 'Submitted' : latest.status}"/>
                                                <c:if test="${latest.score != null}"> | ${latest.score}</c:if>
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <c:if test="${paidAccess}">
                                                <c:choose>
                                                    <c:when test="${hasActiveAttempt}">
                                                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/assessments?courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}&mode=attempt">Continue</a>
                                                    </c:when>
                                                    <c:when test="${usedAttempts < allowedAttempts}">
                                                        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}">Start</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="${pageContext.request.contextPath}/student/assessments" method="post" class="inline-form">
                                                            <input type="hidden" name="action" value="requestRetake">
                                                            <input type="hidden" name="courseId" value="${enrollment.courseId}">
                                                            <input type="hidden" name="assessmentId" value="${a.assessmentId}">
                                                            <input type="hidden" name="reason" value="Requesting another attempt from course details page">
                                                            <button type="submit" class="btn btn-secondary btn-sm">Request Retake</button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>
                                            <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/assessments?courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}">Details</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:if>
                    <c:if test="${empty assessments}">
                        <p class="text-muted state-note">No assessments published yet.</p>
                    </c:if>
                </c:when>

                <c:when test="${activeTab == 'materials'}">
                    <h3 class="section-title-lg"><i class="fas fa-folder-open"></i> Course Materials</h3>
                    <c:if test="${not paidAccess}">
                        <div class="alert alert-warning" style="margin-top:12px;">Payment is required to view and download course materials.</div>
                    </c:if>
                    <c:if test="${paidAccess}">
                        <c:choose>
                            <c:when test="${empty materials}">
                                <div class="empty-inline">
                                    <i class="fas fa-folder-open"></i>
                                    <p>No materials available yet for this course.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="material-card-grid">
                                    <c:forEach var="m" items="${materials}">
                                        <article class="material-card">
                                            <div class="material-card-top">
                                                <span class="material-type-badge material-type-${m.materialType}">
                                                    <c:choose>
                                                        <c:when test="${m.materialType == 'PDF'}">
                                                            <i class="fas fa-file-pdf"></i>
                                                        </c:when>
                                                        <c:when test="${m.materialType == 'Video'}">
                                                            <i class="fas fa-play-circle"></i>
                                                        </c:when>
                                                        <c:when test="${m.materialType == 'Slides'}">
                                                            <i class="fas fa-file-powerpoint"></i>
                                                        </c:when>
                                                        <c:when test="${m.materialType == 'Link'}">
                                                            <i class="fas fa-link"></i>
                                                        </c:when>
                                                    </c:choose>
                                                    ${m.materialType}
                                                </span>
                                                <span class="material-version">
                                                    <c:choose>
                                                        <c:when test="${not empty m.displayOrder}">Ch ${m.displayOrder}</c:when>
                                                        <c:otherwise>${m.versionNumber}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <h5>${m.title}</h5>
                                            <c:if test="${not empty m.description}">
                                                <p>${m.description}</p>
                                            </c:if>
                                            <div class="material-meta">
                                                <span>
                                                    <i class="fas fa-calendar-alt"></i>
                                                    <c:choose>
                                                        <c:when test="${not empty m.uploadDate}">
                                                            ${m.uploadDate.toLocalDate()}
                                                        </c:when>
                                                        <c:otherwise>-</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <div class="material-actions">
                                                <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/materials?action=view&id=${m.materialId}" target="_blank" rel="noopener noreferrer">
                                                    <i class="fas fa-eye"></i> View
                                                </a>
                                                <c:if test="${m.materialType != 'Link'}">
                                                    <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/materials?action=download&id=${m.materialId}">
                                                        <i class="fas fa-download"></i> Download
                                                    </a>
                                                </c:if>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </c:when>

                <c:otherwise>
                    <h3 class="section-title-lg"><i class="fas fa-info-circle"></i> About This Course</h3>
                    <div style="padding: var(--spacing-lg); background: var(--color-bg); border-radius: var(--radius-md); margin-bottom: var(--spacing-xl);">
                        <p style="margin: 0; line-height: 1.6; color: var(--color-text-primary);">${enrollment.courseDescription}</p>
                    </div>
                    <div class="summary-block">
                        <table class="summary-table">
                            <tr><th>Instructor</th><td>${enrollment.instructorName}</td></tr>
                            <tr><th>Status</th><td>${enrollment.status}</td></tr>
                            <tr><th>Completion</th><td>${enrollment.completionStatus}</td></tr>
                            <tr><th>Payment Status</th><td>${enrollment.paymentStatus}</td></tr>
                            <tr><th>Payment Reference</th><td><c:out value="${empty enrollment.paymentRef ? '-' : enrollment.paymentRef}"/></td></tr>
                        </table>
                    </div>
                    <div class="actions actions-top">
                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=materials">Go To Materials</a>
                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">Go To Assessments</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <div class="back-row">
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Back to My Courses</a>
        </div>
    </div>
</main>
</body>
</html>
