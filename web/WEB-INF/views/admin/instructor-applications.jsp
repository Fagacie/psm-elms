<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructor Applications - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Instructor Applications"/>
    <jsp:param name="pageSubtitle" value="Review public instructor requests and convert approved applicants into active instructors"/>
    <jsp:param name="showNotifications" value="true"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Instructor Applications</span>
            </div>
            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Application Review</p>
                    <h2>Approve qualified instructors without leaving the admin workflow.</h2>
                    <p>Each submission includes contact details, specialization, CV attachment, and a short cover note so you can make a quick decision.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <div class="admin-scene-panel">
                        <span>Pending</span>
                        <strong>${pendingCount}</strong>
                    </div>
                    <div class="admin-scene-panel">
                        <span>Approved</span>
                        <strong>${approvedCount}</strong>
                    </div>
                    <div class="admin-scene-panel">
                        <span>Rejected</span>
                        <strong>${rejectedCount}</strong>
                    </div>
                </div>
            </div>
        </section>

        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <c:out value="${sessionScope.success}"/>
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.error}"/>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.warning}">
            <div class="alert alert-warning">
                <i class="fas fa-info-circle"></i> <c:out value="${sessionScope.warning}"/>
            </div>
            <c:remove var="warning" scope="session"/>
        </c:if>

        <c:if test="${not empty selectedApplication}">
            <section class="section-card application-detail-card">
                <div class="section-header application-detail-header">
                    <div>
                        <h2>Application Detail</h2>
                        <p class="section-caption">Review the full submission before making a decision.</p>
                    </div>
                    <div class="detail-actions-inline">
                        <a href="${pageContext.request.contextPath}/admin/instructor-applications" class="admin-btn secondary">Back to queue</a>
                    </div>
                </div>
                <div class="application-detail-grid">
                    <div class="application-detail-panel">
                        <div class="detail-status-row">
                            <strong><c:out value="${selectedApplication.fullName}"/></strong>
                            <span class="status-badge status-${selectedApplication.status eq 'Approved' ? 'success' : selectedApplication.status eq 'Rejected' ? 'danger' : 'warning'}"><c:out value="${selectedApplication.status}"/></span>
                        </div>
                        <div class="detail-meta-grid">
                            <div><span>Applicant email</span><strong><c:out value="${selectedApplication.email}"/></strong></div>
                            <div><span>Phone</span><strong><c:out value="${selectedApplication.phone}"/></strong></div>
                            <div><span>Specialization</span><strong><c:out value="${selectedApplication.specialization}"/></strong></div>
                            <div><span>Qualification</span><strong><c:out value="${selectedApplication.qualification}"/></strong></div>
                            <div><span>Experience</span><strong><c:out value="${not empty selectedApplication.yearsOfExperience ? selectedApplication.yearsOfExperience : '-'}"/></strong></div>
                            <div><span>Submitted</span><strong><c:out value="${selectedApplication.createdAt}"/></strong></div>
                            <div><span>Reviewed by</span><strong><c:out value="${selectedReviewerName != null ? selectedReviewerName : '-'}"/></strong></div>
                            <div><span>Reviewed at</span><strong><c:out value="${selectedApplication.reviewedAt != null ? selectedApplication.reviewedAt : '-'}"/></strong></div>
                        </div>
                    </div>
                    <div class="application-detail-panel application-detail-message">
                        <div>
                            <span class="detail-label">Cover message</span>
                            <p><c:out value="${not empty selectedApplication.coverMessage ? selectedApplication.coverMessage : 'No cover message provided.'}"/></p>
                        </div>
                        <div>
                            <span class="detail-label">CV</span>
                            <c:choose>
                                <c:when test="${not empty selectedApplication.cvPath}">
                                    <a href="${selectedApplication.cvPath}" target="_blank" rel="noopener">Open uploaded CV</a>
                                </c:when>
                                <c:otherwise>
                                    <p>CV not available.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <span class="detail-label">Admin notes</span>
                            <p><c:out value="${not empty selectedApplication.adminNotes ? selectedApplication.adminNotes : 'No notes recorded yet.'}"/></p>
                        </div>
                    </div>
                </div>

                <c:if test="${selectedApplication.status eq 'Pending'}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/instructor-applications" class="application-decision-form admin-form-layout">
                        <input type="hidden" name="applicationId" value="${selectedApplication.applicationId}">
                        <div class="admin-form-group full-width">
                            <label for="adminNotes">Review notes</label>
                            <textarea id="adminNotes" name="adminNotes" rows="5" placeholder="Add approval context, improvement notes, or rejection reasons."></textarea>
                            <small class="section-caption">These notes are stored with the application and included in the applicant email when provided.</small>
                        </div>
                        <div class="detail-actions-inline">
                            <button type="submit" name="action" value="approve" class="admin-btn primary">Approve application</button>
                            <button type="submit" name="action" value="reject" class="admin-btn danger">Reject application</button>
                        </div>
                    </form>
                </c:if>
            </section>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Filters</h2>
            </div>
            <div class="section-actions-inset">
                <form method="get" action="${pageContext.request.contextPath}/admin/instructor-applications" class="filters-grid">
                    <div>
                        <label for="statusFilter" class="admin-filter-label">Status</label>
                        <select name="status" id="statusFilter">
                            <option value="">All Statuses</option>
                            <option value="Pending" ${statusFilter == 'Pending' ? 'selected' : ''}>Pending</option>
                            <option value="Approved" ${statusFilter == 'Approved' ? 'selected' : ''}>Approved</option>
                            <option value="Rejected" ${statusFilter == 'Rejected' ? 'selected' : ''}>Rejected</option>
                        </select>
                    </div>
                    <div class="form-actions-inline">
                        <button type="submit" class="admin-btn primary"><i class="fas fa-search"></i>&nbsp;Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/instructor-applications" class="admin-btn secondary">Clear</a>
                    </div>
                </form>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Application Queue</h2>
            </div>
            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Applicant</th>
                            <th>Contact</th>
                            <th>Specialization</th>
                            <th>Experience</th>
                            <th>Status</th>
                            <th>CV</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty applications}">
                                <tr>
                                    <td colspan="8">
                                        <div class="empty-state empty-state-inset">
                                            <i class="fas fa-inbox"></i>
                                            <p>No instructor applications found.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="application" items="${applications}">
                                    <tr>
                                        <td>${application.applicationId}</td>
                                        <td>
                                            <strong><c:out value="${application.fullName}"/></strong><br>
                                            <span class="section-caption"><c:out value="${application.qualification}"/></span>
                                        </td>
                                        <td>
                                            <div><c:out value="${application.email}"/></div>
                                            <div class="section-caption"><c:out value="${application.phone}"/></div>
                                        </td>
                                        <td><c:out value="${application.specialization}"/></td>
                                        <td><c:out value="${not empty application.yearsOfExperience ? application.yearsOfExperience : '-'}"/></td>
                                        <td><span class="status-badge status-${application.status eq 'Approved' ? 'success' : application.status eq 'Rejected' ? 'danger' : 'warning'}"><c:out value="${application.status}"/></span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty application.cvPath}">
                                                    <a href="${application.cvPath}" target="_blank" rel="noopener">Open CV</a>
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="admin-table-actions">
                                                <a href="${pageContext.request.contextPath}/admin/instructor-applications?applicationId=${application.applicationId}" class="admin-btn secondary">View details</a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</main>
</body>
</html>