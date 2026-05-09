<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Details | Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Enrollment Details"/>
    <jsp:param name="pageSubtitle" value="Inspect one enrollment record in detail"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/admin/enrollments">Enrollments</a>
                <span>&gt;</span>
                <span>#${enrollment.enrollmentId}</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Enrollment Record</p>
                    <h2>Review the full enrollment, course, and payment state for this student</h2>
                    <p>Use this page to inspect the operational details of one enrollment record before following up on payment, completion, or course access issues.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <span class="admin-orb admin-orb-a"></span>
                    <span class="admin-orb admin-orb-b"></span>
                    <span class="admin-shape admin-shape-a"></span>
                    <span class="admin-shape admin-shape-b"></span>
                    <div class="admin-scene-panel admin-scene-panel-a">
                        <span>Status</span>
                        <strong>${enrollment.status}</strong>
                    </div>
                    <div class="admin-scene-panel admin-scene-panel-b">
                        <span>Payment</span>
                        <strong>${not empty enrollment.paymentStatus ? enrollment.paymentStatus : 'Pending'}</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Enrollment Header</h2>
                <div>
                    <c:choose>
                        <c:when test="${enrollment.status == 'Enrolled'}"><span class="status-badge status-success">Enrolled</span></c:when>
                        <c:when test="${enrollment.status == 'Pending'}"><span class="status-badge status-warning">Pending</span></c:when>
                        <c:when test="${enrollment.status == 'Cancelled'}"><span class="status-badge status-danger">Cancelled</span></c:when>
                        <c:otherwise><span class="status-badge status-secondary">${enrollment.status}</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-label">Enrollment ID</div>
                    <div class="metric-value">#${enrollment.enrollmentId}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Completion</div>
                    <div class="metric-value">${enrollment.completionStatus}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Payment State</div>
                    <div class="metric-value">${not empty enrollment.paymentStatus ? enrollment.paymentStatus : 'Pending'}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Course Fee</div>
                    <div class="metric-value">NGN <fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                </div>
            </div>
            <div class="admin-action-bar">
                <div class="admin-action-bar-copy">
                    <strong>Enrollment operations</strong>
                    <span>Use these quick actions to move from this record into the related student account or course management workspace.</span>
                </div>
                <div class="admin-action-bar-actions">
                    <a href="${pageContext.request.contextPath}/admin/enrollments" class="admin-btn secondary">Back to List</a>
                    <a href="${pageContext.request.contextPath}/admin/users?action=edit&userId=${enrollment.userId}" class="admin-btn primary">Open Student</a>
                    <a href="${pageContext.request.contextPath}/admin/courses" class="admin-btn secondary">Open Courses</a>
                    <a href="${pageContext.request.contextPath}/admin/payments" class="admin-btn secondary">Open Payments</a>
                </div>
            </div>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Student Information</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Student Name</strong><span><c:out value="${enrollment.studentName}"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Email</strong><span><c:out value="${enrollment.studentEmail}"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>User ID</strong><span>#${enrollment.userId}</span></div></div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>Course Information</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Course Name</strong><span><c:out value="${enrollment.courseName}"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Instructor</strong><span><c:out value="${not empty enrollment.instructorName ? enrollment.instructorName : 'Not assigned'}"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Course ID</strong><span>#${enrollment.courseId}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Description</strong><span><c:out value="${not empty enrollment.courseDescription ? enrollment.courseDescription : 'No course description available.'}"/></span></div></div>
                </div>
            </section>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Enrollment Timeline</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Enrollment Status</strong><span><c:out value="${enrollment.status}"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Completion Status</strong><span><c:out value="${not empty enrollment.completionStatus ? enrollment.completionStatus : 'Not Started'}"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Enrolled Date</strong><span><c:choose><c:when test="${enrollment.enrollmentDate != null}"><c:out value="${enrollment.enrollmentDate.toLocalDate()}"/></c:when><c:otherwise>N/A</c:otherwise></c:choose></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Last Updated</strong><span><c:choose><c:when test="${enrollment.updatedDate != null}"><c:out value="${enrollment.updatedDate.toLocalDate()}"/></c:when><c:otherwise>N/A</c:otherwise></c:choose></span></div></div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>Payment Information</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Payment Status</strong><span><c:out value="${not empty enrollment.paymentStatus ? enrollment.paymentStatus : 'Pending'}"/></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Amount</strong><span>NGN <fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span></div></div>
                    <c:if test="${not empty enrollment.paymentRef}">
                        <div class="status-item"><div class="status-item-copy"><strong>Payment Reference</strong><span><c:out value="${enrollment.paymentRef}"/></span></div></div>
                    </c:if>
                </div>
            </section>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Support Follow-up</h2>
                <span class="section-caption">Reference actions</span>
            </div>
            <div class="section-actions-inset">
                <a href="${pageContext.request.contextPath}/admin/settings" class="admin-btn secondary">Admin Settings</a>
                <a href="${pageContext.request.contextPath}/admin/certificates" class="admin-btn secondary">Certificates</a>
            </div>
        </section>
    </div>
</main>
</body>
</html>
