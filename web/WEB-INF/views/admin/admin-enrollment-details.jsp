<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollment Details - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body>
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
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Student Information</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Student Name</strong><span>${enrollment.studentName}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Email</strong><span>${enrollment.studentEmail}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>User ID</strong><span>#${enrollment.userId}</span></div></div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>Course Information</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Course Name</strong><span>${enrollment.courseName}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Instructor</strong><span>${enrollment.instructorName}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Course ID</strong><span>#${enrollment.courseId}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Description</strong><span>${enrollment.courseDescription}</span></div></div>
                </div>
            </section>
        </section>

        <section class="admin-grid-2">
            <section class="section-card">
                <div class="section-header">
                    <h2>Enrollment Timeline</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Enrollment Status</strong><span>${enrollment.status}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Completion Status</strong><span>${enrollment.completionStatus}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Enrolled Date</strong><span><c:choose><c:when test="${enrollment.enrollmentDate != null}">${enrollment.enrollmentDate.toString().substring(0, 10)}</c:when><c:otherwise>N/A</c:otherwise></c:choose></span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Last Updated</strong><span><c:choose><c:when test="${enrollment.updatedDate != null}">${enrollment.updatedDate.toString().substring(0, 10)}</c:when><c:otherwise>N/A</c:otherwise></c:choose></span></div></div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <h2>Payment Information</h2>
                </div>
                <div class="panel-stack">
                    <div class="status-item"><div class="status-item-copy"><strong>Payment Status</strong><span>${not empty enrollment.paymentStatus ? enrollment.paymentStatus : 'Pending'}</span></div></div>
                    <div class="status-item"><div class="status-item-copy"><strong>Amount</strong><span>NGN <fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span></div></div>
                    <c:if test="${not empty enrollment.paymentRef}">
                        <div class="status-item"><div class="status-item-copy"><strong>Payment Reference</strong><span>${enrollment.paymentRef}</span></div></div>
                    </c:if>
                </div>
            </section>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Actions</h2>
            </div>
            <div class="section-actions-inset">
                <a href="${pageContext.request.contextPath}/admin/enrollments" class="admin-btn secondary">Back to List</a>
                <a href="${pageContext.request.contextPath}/admin/users?action=edit&userId=${enrollment.userId}" class="admin-btn primary">Open Student</a>
                <a href="${pageContext.request.contextPath}/admin/courses" class="admin-btn secondary">Open Courses</a>
            </div>
        </section>
    </div>
</main>
</body>
</html>
