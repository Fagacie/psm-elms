<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${enrollment.courseName} - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="student-page enrollment-details-page">
<!-- Top Navigation Bar -->
<header class="app-header">
    <div class="header-left">
        <div class="logo-section">
            <i class="fas fa-graduation-cap"></i>
            <span>PSM E-Learning</span>
        </div>
        <h1 class="page-title">${enrollment.courseName}</h1>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i>
            Logout
        </a>
    </div>
</header>

<!-- Left Sidebar Navigation -->
<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="fas fa-home"></i>
            <span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item active">
            <i class="fas fa-graduation-cap"></i>
            <span>My Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/courses" class="nav-item">
            <i class="fas fa-book"></i>
            <span>Browse Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="nav-item">
            <i class="fas fa-clipboard-list"></i>
            <span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="nav-item">
            <i class="fas fa-certificate"></i>
            <span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i>
            <span>Profile</span>
        </a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <!-- Breadcrumb Navigation -->
        <div class="page-breadcrumb details-breadcrumb" style="margin-bottom: 24px; font-size: 14px; color: #5f6368;">
            <a href="${pageContext.request.contextPath}/dashboard" style="color: #1a73e8; text-decoration: none;">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <span style="margin: 0 8px;">/</span>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" style="color: #1a73e8; text-decoration: none;">
                My Courses
            </a>
            <span style="margin: 0 8px;">/</span>
            <span>${enrollment.courseName}</span>
        </div>

        <!-- Page Actions with Payment Badge -->
        <c:set var="isPaymentComplete" value="${enrollment.paymentStatus == 'Paid' || enrollment.paymentStatus == 'COMPLETED' || enrollment.paymentStatus == 'Completed' || enrollment.paymentStatus == 'SUCCESS' || enrollment.paymentStatus == 'success'}"/>
        <div class="page-actions details-page-actions" style="justify-content: space-between; align-items: center;">
            <div>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to My Courses
                </a>
            </div>
            <span class="status-badge details-payment-badge ${isPaymentComplete ? 'status-Approved' : 'status-Pending'}" style="font-size: 14px;">
                <i class="fas fa-${isPaymentComplete ? 'check-circle' : 'clock'}"></i>
                ${isPaymentComplete ? 'Paid' : 'Payment Pending'}
            </span>
        </div>

        <!-- Course Info Card -->
        <div class="course-card details-hero-card">
            <div class="course-header">
                <h2 class="course-title">${enrollment.courseName}</h2>
                <c:choose>
                    <c:when test="${isPaymentComplete}">
                        <span class="status-badge status-Approved">Paid</span>
                    </c:when>
                    <c:otherwise>
                        <span class="status-badge status-Pending">Pending Payment</span>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <p class="course-description">${enrollment.courseDescription}</p>
            
            <div class="course-meta">
                <div class="meta-item">
                    <i class="fas fa-chalkboard-teacher"></i>
                    <span>${enrollment.instructorName}</span>
                </div>
                <div class="meta-item">
                    <i class="fas fa-calendar-check"></i>
                    <span>Enrolled: <c:out value="${enrollment.enrollmentDate != null ? enrollment.enrollmentDate.toLocalDate() : '-'}"/></span>
                </div>
                <div class="meta-item">
                    <i class="fas fa-money-bill-wave"></i>
                    <span>Fee: ₦<fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                </div>
                <div class="meta-item">
                    <i class="fas fa-chart-line"></i>
                    <span>Progress: ${progressPercent}%</span>
                </div>
            </div>
        </div>

        <!-- Tabs Navigation -->
        <div class="tab-links">
            <a class="tab-link ${activeTab == 'learning' ? 'active' : ''}" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning">
                <i class="fas fa-layer-group"></i> Learning Hub
            </a>
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

        <!-- Tab Content -->
        <c:choose>
            <c:when test="${activeTab == 'learning'}">
                <div class="course-card">
                    <div class="learning-header">
                        <div>
                            <h3 style="margin: 0; font-size: 18px; font-weight: 600; color: #202124;">Learning Hub</h3>
                            <p style="margin: 6px 0 0; color: #5f6368; font-size: 14px;">Follow the sequence to complete materials and assessments in one place.</p>
                        </div>
                    </div>

                    <c:if test="${not paidAccess}">
                        <div class="alert alert-error" style="margin: 16px 0 20px;">
                            <i class="fas fa-exclamation-circle"></i>
                            Payment is required to open materials and take assessments.
                        </div>
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty learningItems}">
                            <div class="learning-list">
                                <c:forEach var="item" items="${learningItems}">
                                    <div class="course-card learning-item ${item.type == 'Material' ? 'learning-item-material' : 'learning-item-assessment'} ${item.locked ? 'learning-item-locked' : ''}">
                                        <div class="learning-item-main">
                                            <div class="learning-item-icon">
                                                <i class="fas ${item.iconClass}"></i>
                                            </div>
                                            <div class="learning-item-content">
                                                <div class="learning-item-title-row">
                                                    <span class="learning-item-type">${item.type}</span>
                                                    <span class="status-badge ${item.badgeClass}">${item.badgeText}</span>
                                                </div>
                                                <h4 class="learning-item-title">${item.title}</h4>
                                                <c:if test="${not empty item.description}">
                                                    <p class="learning-item-desc">${item.description}</p>
                                                </c:if>
                                                <div class="learning-item-meta">
                                                    <c:if test="${not empty item.metaPrimary}">
                                                        <span><i class="fas fa-clock"></i> ${item.metaPrimary}</span>
                                                    </c:if>
                                                    <c:if test="${not empty item.metaSecondary}">
                                                        <span><i class="fas fa-chart-bar"></i> ${item.metaSecondary}</span>
                                                    </c:if>
                                                    <c:if test="${not empty item.metaTertiary}">
                                                        <span><i class="fas fa-award"></i> ${item.metaTertiary}</span>
                                                    </c:if>
                                                </div>
                                                <c:if test="${item.locked}">
                                                    <div class="learning-item-lock">
                                                        <i class="fas fa-lock"></i> ${item.lockReason}
                                                    </div>
                                                </c:if>
                                            </div>
                                            <div class="learning-item-status">
                                                <c:if test="${not empty item.statusLabel}">
                                                    <span class="status-badge ${item.statusClass}">${item.statusLabel}</span>
                                                </c:if>
                                            </div>
                                        </div>
                                        <div class="learning-item-actions">
                                            <c:if test="${not item.locked}">
                                                <c:if test="${not empty item.primaryActionUrl}">
                                                    <a class="btn btn-primary btn-sm" href="${item.primaryActionUrl}">
                                                        <i class="fas ${item.primaryActionIcon}"></i> ${item.primaryActionLabel}
                                                    </a>
                                                </c:if>
                                                <c:if test="${not empty item.secondaryActionUrl}">
                                                    <a class="btn btn-secondary btn-sm" href="${item.secondaryActionUrl}">
                                                        <i class="fas ${item.secondaryActionIcon}"></i> ${item.secondaryActionLabel}
                                                    </a>
                                                </c:if>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state-box">
                                <i class="fas fa-layer-group"></i>
                                <p>No learning items available yet.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:when>
            <c:when test="${activeTab == 'overview'}">
                <!-- Overview Section -->
                <div class="course-card details-overview-card">
                    <h3 style="margin: 0 0 20px 0; font-size: 18px; font-weight: 600; color: #202124;">Course Information</h3>
                    
                    <div class="details-table-wrap" style="overflow-x: auto;">
                    <table class="details-table" style="width: 100%; border-collapse: collapse;">
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 12px 0; font-weight: 500; color: #5f6368; width: 180px;">
                                <i class="fas fa-chalkboard-teacher" style="margin-right: 8px;"></i>Instructor
                            </td>
                            <td style="padding: 12px 0; color: #202124;">${enrollment.instructorName}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 12px 0; font-weight: 500; color: #5f6368;">
                                <i class="fas fa-envelope" style="margin-right: 8px;"></i>Instructor Email
                            </td>
                            <td style="padding: 12px 0; color: #202124;">
                                <c:if test="${not empty enrollment.instructorEmail}">
                                    <a href="mailto:${enrollment.instructorEmail}" style="color: #1a73e8; text-decoration: none;">
                                        ${enrollment.instructorEmail}
                                    </a>
                                </c:if>
                                <c:if test="${empty enrollment.instructorEmail}">
                                    <span style="color: #9ca3af;">Not available</span>
                                </c:if>
                            </td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 12px 0; font-weight: 500; color: #5f6368;">
                                <i class="fas fa-folder-open" style="margin-right: 8px;"></i>Materials
                            </td>
                            <td style="padding: 12px 0; color: #202124;">${materialCount} Learning Materials</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 12px 0; font-weight: 500; color: #5f6368;">
                                <i class="fas fa-clipboard-list" style="margin-right: 8px;"></i>Assessments
                            </td>
                            <td style="padding: 12px 0; color: #202124;">${assessmentCount} Assessments</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 12px 0; font-weight: 500; color: #5f6368;">
                                <i class="fas fa-chart-line" style="margin-right: 8px;"></i>Progress
                            </td>
                            <td style="padding: 12px 0; color: #202124;">${progressPercent}%</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 12px 0; font-weight: 500; color: #5f6368;">
                                <i class="fas fa-user-check" style="margin-right: 8px;"></i>Enrollment Status
                            </td>
                            <td style="padding: 12px 0; color: #202124;">${enrollment.status}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 12px 0; font-weight: 500; color: #5f6368;">
                                <i class="fas fa-check-circle" style="margin-right: 8px;"></i>Completion
                            </td>
                            <td style="padding: 12px 0; color: #202124;">${enrollment.completionStatus}</td>
                        </tr>
                        <c:if test="${not empty enrollment.paymentRef}">
                            <tr style="border-bottom: 1px solid #e5e7eb;">
                                <td style="padding: 12px 0; font-weight: 500; color: #5f6368;">
                                    <i class="fas fa-receipt" style="margin-right: 8px;"></i>Payment Reference
                                </td>
                                <td style="padding: 12px 0; color: #202124; font-family: monospace;">${enrollment.paymentRef}</td>
                            </tr>
                        </c:if>
                    </table>
                    </div>

                    <!-- Announcements Section -->
                    <div class="details-announcements" style="margin-top: 32px;">
                        <h3 style="font-size: 16px; font-weight: 600; color: #202124; margin-bottom: 16px;">
                            <i class="fas fa-megaphone" style="margin-right: 8px;"></i>Course Announcements
                        </h3>
                        <div id="announcementsContainer">
                            <c:choose>
                                <c:when test="${not empty announcements}">
                                    <c:forEach var="ann" items="${announcements}" varStatus="annStatus">
                                        <div class="course-card details-announcement-card ${annStatus.index > 2 ? 'extra-announcement' : ''}" style="margin-bottom: 12px; ${annStatus.index > 2 ? 'display: none;' : ''}">
                                            <div style="padding: 16px;">
                                                <div class="announcement-row" style="display: flex; justify-content: space-between; align-items: flex-start;">
                                                    <div style="flex: 1;">
                                                        <h4 style="font-size: 14px; font-weight: 600; color: #202124; margin-bottom: 4px;">
                                                            ${ann.title}
                                                        </h4>
                                                        <div style="font-size: 13px; color: #5f6368; margin-bottom: 8px;">
                                                            <i class="fas fa-calendar-alt" style="margin-right: 4px;"></i>
                                                            <c:choose>
                                                                <c:when test="${not empty ann.createdDate}">
                                                                    ${ann.createdDate.toLocalDate()}
                                                                </c:when>
                                                                <c:otherwise>Recently</c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <div style="font-size: 13px; color: #3c4043; line-height: 1.5;">
                                                            ${ann.content}
                                                        </div>
                                                    </div>
                                                    <span class="status-badge status-Approved announcement-badge" style="margin-left: 12px; font-size: 11px;">
                                                        <i class="fas fa-thumbtack"></i> Pinned
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${announcements.size() > 3}">
                                        <div style="text-align: center; margin-top: 12px;">
                                            <button id="showMoreAnnouncementsBtn" class="btn btn-secondary btn-sm" onclick="showMoreAnnouncements()">
                                                <i class="fas fa-chevron-down"></i> Show More (${announcements.size() - 3})
                                            </button>
                                        </div>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <div style="text-align: center; padding: 24px; color: #5f6368;">
                                        <i class="fas fa-bell-slash" style="font-size: 24px; color: #dadce0; margin-bottom: 8px;"></i>
                                        <p>No announcements yet. Check back soon for course updates!</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="course-actions" style="margin-top: 24px;">
                        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=materials">
                            <i class="fas fa-folder-open"></i> View Materials
                        </a>
                        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=assessments">
                            <i class="fas fa-clipboard-list"></i> View Assessments
                        </a>
                    </div>
                </div>
            </c:when>

            <c:when test="${activeTab == 'materials'}">
                <!-- Materials Section -->
                <c:if test="${not paidAccess}">
                    <div class="alert alert-error" style="margin-bottom: 20px;">
                        <i class="fas fa-exclamation-circle"></i>
                        Payment is required to view and download course materials.
                    </div>
                </c:if>
                
                <c:if test="${paidAccess}">
                    <c:choose>
                        <c:when test="${not empty materials}">
                            <div class="course-card">
                                <div class="details-table-wrap" style="overflow-x: auto;">
                                <table class="details-table" style="width: 100%; border-collapse: collapse;">
                                    <thead>
                                        <tr style="border-bottom: 2px solid #e5e7eb;">
                                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #202124;">Material</th>
                                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #202124; width: 120px;">Type</th>
                                            <th style="padding: 12px; text-align: left; font-weight: 600; color: #202124; width: 150px;">Uploaded</th>
                                            <th style="padding: 12px; text-align: center; font-weight: 600; color: #202124; width: 200px;">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="m" items="${materials}">
                                            <tr style="border-bottom: 1px solid #e5e7eb;">
                                                <td style="padding: 12px;">
                                                    <div style="font-weight: 500; color: #202124; margin-bottom: 4px;">${m.title}</div>
                                                    <c:if test="${not empty m.description}">
                                                        <div style="font-size: 13px; color: #5f6368;">${m.description}</div>
                                                    </c:if>
                                                </td>
                                                <td style="padding: 12px;">
                                                    <span class="status-badge status-Approved" style="font-size: 12px;">
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
                                                </td>
                                                <td style="padding: 12px; color: #5f6368; font-size: 14px;">
                                                    <c:choose>
                                                        <c:when test="${not empty m.uploadDate}">
                                                            ${m.uploadDate.toLocalDate()}
                                                        </c:when>
                                                        <c:otherwise>-</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 12px; text-align: center;">
                                                    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/materials?action=view&id=${m.materialId}" target="_blank">
                                                        <i class="fas fa-eye"></i> View
                                                    </a>
                                                    <c:if test="${m.materialType != 'Link'}">
                                                        <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/materials?action=download&id=${m.materialId}">
                                                            <i class="fas fa-download"></i>
                                                        </a>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state-box">
                                <i class="fas fa-folder-open"></i>
                                <p>No materials available yet for this course.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </c:when>

            <c:when test="${activeTab == 'assessments'}">
                <!-- Assessments Section -->
                <c:if test="${not paidAccess}">
                    <div class="alert alert-error" style="margin-bottom: 20px;">
                        <i class="fas fa-exclamation-circle"></i>
                        Payment is required before taking assessments.
                    </div>
                </c:if>
                
                <c:choose>
                    <c:when test="${not empty assessments}">
                        <div class="course-card">
                            <div class="details-table-wrap" style="overflow-x: auto;">
                            <table class="details-table" style="width: 100%; border-collapse: collapse;">
                                <thead>
                                    <tr style="border-bottom: 2px solid #e5e7eb;">
                                        <th style="padding: 12px; text-align: left; font-weight: 600; color: #202124;">Assessment</th>
                                        <th style="padding: 12px; text-align: left; font-weight: 600; color: #202124; width: 100px;">Type</th>
                                        <th style="padding: 12px; text-align: center; font-weight: 600; color: #202124; width: 100px;">Duration</th>
                                        <th style="padding: 12px; text-align: center; font-weight: 600; color: #202124; width: 120px;">Attempts</th>
                                        <th style="padding: 12px; text-align: center; font-weight: 600; color: #202124; width: 150px;">Latest Result</th>
                                        <th style="padding: 12px; text-align: center; font-weight: 600; color: #202124; width: 200px;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="a" items="${assessments}">
                                        <c:set var="usedAttempts" value="${usedAttemptsByAssessment[a.assessmentId]}"/>
                                        <c:set var="allowedAttempts" value="${allowedAttemptsByAssessment[a.assessmentId]}"/>
                                        <c:set var="latest" value="${latestSubmissionByAssessment[a.assessmentId]}"/>
                                        <c:set var="hasActiveAttempt" value="${activeAttemptByAssessment[a.assessmentId]}"/>
                                        
                                        <tr style="border-bottom: 1px solid #e5e7eb;">
                                            <td style="padding: 12px; font-weight: 500; color: #202124;">${a.title}</td>
                                            <td style="padding: 12px;">
                                                <span class="status-badge status-${a.type == 'Quiz' ? 'Pending' : 'Approved'}" style="font-size: 12px;">
                                                    ${a.type}
                                                </span>
                                            </td>
                                            <td style="padding: 12px; text-align: center; color: #5f6368;">${a.duration} min</td>
                                            <td style="padding: 12px; text-align: center; color: #5f6368;">${usedAttempts} / ${allowedAttempts}</td>
                                            <td style="padding: 12px; text-align: center; color: #5f6368;">
                                                <c:choose>
                                                    <c:when test="${not empty latest}">
                                                        <div style="font-weight: 500; color: #202124;">
                                                            <c:out value="${empty latest.status ? 'Submitted' : latest.status}"/>
                                                        </div>
                                                        <c:if test="${latest.score != null}">
                                                            <div style="font-size: 13px; color: #1a73e8;">${latest.score}</div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="padding: 12px; text-align: center;">
                                                <c:if test="${paidAccess}">
                                                    <c:choose>
                                                        <c:when test="${hasActiveAttempt}">
                                                            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/assessments?courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}&mode=attempt">
                                                                <i class="fas fa-play"></i> Continue
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${usedAttempts < allowedAttempts}">
                                                            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}">
                                                                <i class="fas fa-play"></i> Start
                                                            </a>
                                                        </c:when>
                                                    </c:choose>
                                                </c:if>
                                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/assessments?courseId=${enrollment.courseId}&assessmentId=${a.assessmentId}">
                                                    <i class="fas fa-info-circle"></i> Details
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-box">
                            <i class="fas fa-clipboard-list"></i>
                            <p>No assessments published yet.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:when>
        </c:choose>
        </div>
    </div>
</main>
<script>
function showMoreAnnouncements() {
    const hiddenAnnouncements = document.querySelectorAll('.extra-announcement');
    hiddenAnnouncements.forEach(function(card) {
        card.style.display = 'block';
    });

    const button = document.getElementById('showMoreAnnouncementsBtn');
    if (button) {
        button.style.display = 'none';
    }
}
</script>
</body>
</html>
