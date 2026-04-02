<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Management - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Courses"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <c:set var="courseCount" value="${empty courses ? 0 : fn:length(courses)}"/>
        <c:set var="totalCourses" value="${courseCount}"/>
        <c:set var="pendingCount" value="0"/>
        <c:set var="approvedCount" value="0"/>
        <c:set var="archivedCount" value="0"/>
        <c:forEach items="${courses}" var="c">
            <c:choose>
                <c:when test="${c.status eq 'Pending'}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:when>
                <c:when test="${c.status eq 'Approved'}"><c:set var="approvedCount" value="${approvedCount + 1}"/></c:when>
                <c:when test="${c.status eq 'Archived'}"><c:set var="archivedCount" value="${archivedCount + 1}"/></c:when>
            </c:choose>
        </c:forEach>

        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="fas fa-angle-right"></i>
                <span>Courses</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Course Governance</p>
                    <h2>Review approvals, archive inactive content, and keep the course catalog clean</h2>
                    <p>Track course status across the platform and take fast moderation actions on pending, approved, and archived learning products.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <span class="admin-orb admin-orb-a"></span>
                    <span class="admin-orb admin-orb-b"></span>
                    <span class="admin-shape admin-shape-a"></span>
                    <span class="admin-shape admin-shape-b"></span>
                    <div class="admin-scene-panel admin-scene-panel-a">
                        <span>Total Courses</span>
                        <strong>${totalCourses}</strong>
                    </div>
                    <div class="admin-scene-panel admin-scene-panel-b">
                        <span>Pending</span>
                        <strong>${pendingCount}</strong>
                    </div>
                </div>
            </div>
        </section>

        <c:if test="${param.success == 'approved'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Course approved successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'rejected'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Course rejected successfully.
            </div>
        </c:if>
        <c:if test="${param.error != null}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> An error occurred. Please try again.
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
            </div>
        </c:if>

        <section class="section-card">
            <div class="section-header">
                <h2>Course Overview</h2>
            </div>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-label">Total Courses</div>
                    <div class="metric-value">${totalCourses}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Pending Review</div>
                    <div class="metric-value">${pendingCount}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Approved</div>
                    <div class="metric-value">${approvedCount}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Archived</div>
                    <div class="metric-value">${archivedCount}</div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Status Filters</h2>
            </div>
            <div style="padding: 14px 16px 16px; display:flex; gap:10px; flex-wrap:wrap;">
                <a href="${pageContext.request.contextPath}/admin/courses" class="admin-btn ${empty param.status ? 'primary' : 'secondary'}">All Courses</a>
                <a href="${pageContext.request.contextPath}/admin/courses?status=Pending" class="admin-btn ${param.status == 'Pending' ? 'primary' : 'secondary'}">Pending Review</a>
                <a href="${pageContext.request.contextPath}/admin/courses?status=Approved" class="admin-btn ${param.status == 'Approved' ? 'primary' : 'secondary'}">Approved</a>
                <a href="${pageContext.request.contextPath}/admin/courses?status=Archived" class="admin-btn ${param.status == 'Archived' ? 'primary' : 'secondary'}">Archived</a>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>All Courses</h2>
            </div>
            <div class="table-wrapper">
                <table id="coursesTable" class="data-table">
                    <thead>
                        <tr>
                            <th>Course Name</th>
                            <th>Category</th>
                            <th>Level</th>
                            <th>Duration (hrs)</th>
                            <th>Fee (NGN)</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty courses}">
                                <tr>
                                    <td colspan="8">
                                        <div class="empty-state" style="margin:12px;">
                                            <i class="fas fa-inbox"></i>
                                            <p>No courses found.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="course" items="${courses}">
                                    <tr>
                                        <td>
                                            <strong>${course.courseName}</strong>
                                            <c:if test="${not empty course.description}">
                                                <div style="font-size:12px; color:var(--admin-muted); margin-top:4px;">
                                                    <c:set var="desc" value="${course.description}"/>
                                                    <c:choose>
                                                        <c:when test="${fn:length(desc) > 70}">${fn:substring(desc, 0, 70)}...</c:when>
                                                        <c:otherwise>${desc}</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>${course.category}</td>
                                        <td><span class="status-badge status-${course.level eq 'Beginner' ? 'success' : course.level eq 'Intermediate' ? 'warning' : 'secondary'}">${course.level}</span></td>
                                        <td>${course.duration}</td>
                                        <td><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
                                        <td><span class="status-badge status-${course.status eq 'Pending' ? 'warning' : course.status eq 'Approved' ? 'success' : 'secondary'}">${course.status}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty course.createdAt}">
                                                    <c:set var="createdStr" value="${course.createdAt.toString()}"/>
                                                    ${fn:length(createdStr) >= 10 ? fn:substring(createdStr, 0, 10) : createdStr}
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div style="display:flex; gap:8px; flex-wrap:wrap;">
                                                <c:choose>
                                                    <c:when test="${course.status eq 'Pending'}">
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=approve&id=${course.courseId}" class="admin-btn primary" onclick="return confirm('Approve this course?');">Approve</a>
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=reject&id=${course.courseId}" class="admin-btn secondary" style="border-color:#a55058; color:#ffc2c6;" onclick="return confirm('Reject this course?');">Reject</a>
                                                    </c:when>
                                                    <c:when test="${course.status eq 'Approved'}">
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=archive&id=${course.courseId}" class="admin-btn secondary" onclick="return confirm('Archive this course? Students will no longer see it.');">Archive</a>
                                                    </c:when>
                                                    <c:when test="${course.status eq 'Archived'}">
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=restore&id=${course.courseId}" class="admin-btn secondary" onclick="return confirm('Restore this course to Approved?');">Restore</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: var(--admin-muted);">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
            <style>
                .dataTables_wrapper { padding: 14px 16px 16px; color: var(--admin-muted); }
                .dataTables_length, .dataTables_filter { margin-bottom: 15px; }
                .dataTables_length label, .dataTables_filter label { display:flex; align-items:center; gap:10px; color: var(--admin-muted); font-weight:500; }
                .dataTables_length select, .dataTables_filter input { margin:0 5px; }
                .dataTables_info { padding:15px 0; color: var(--admin-muted); }
                .dataTables_paginate { padding:15px 0; }
                .dataTables_paginate .paginate_button { padding:6px 12px; margin:0 2px; border:1px solid var(--admin-border); background: rgba(17, 39, 64, 0.6); color: #d8ebff !important; cursor:pointer; font-size:14px; }
                .dataTables_paginate .paginate_button:hover { border-color: var(--admin-accent); color: #fff !important; }
                .dataTables_paginate .paginate_button.current { background: linear-gradient(120deg, #19a3d7, #2485ff); border-color:#1e78e0; color:#fff !important; font-weight:600; }
                .dataTables_paginate .paginate_button.disabled { opacity:0.5; cursor:not-allowed; }
                .dataTables_length { float:left; } .dataTables_filter { float:right; }
                .dataTables_info { float:left; clear:both; } .dataTables_paginate { float:right; clear:both; }
                @media (max-width:768px){ .dataTables_length, .dataTables_filter, .dataTables_info, .dataTables_paginate { float:none; text-align:center; margin:10px 0; } .dataTables_length label, .dataTables_filter label { justify-content:center; } }
            </style>
            <script>
                $(function(){
                    if ($('#coursesTable').length && $('#coursesTable tbody tr').length > 1) {
                        $('#coursesTable').DataTable({
                            order: [[6,'desc']],
                            pageLength: 25,
                            lengthMenu: [[10,25,50,100,-1],[10,25,50,100,'All']],
                            language: {
                                search: 'Search courses:',
                                lengthMenu: 'Show _MENU_ entries',
                                info: 'Showing _START_ to _END_ of _TOTAL_ courses',
                                infoEmpty: 'Showing 0 to 0 of 0 courses',
                                infoFiltered: '(filtered from _MAX_ total courses)',
                                zeroRecords: 'No matching courses found',
                                emptyTable: 'No courses available',
                                paginate: { first:'First', last:'Last', next:'Next', previous:'Previous' }
                            },
                            columnDefs: [
                                { orderable: true, targets: [0,2,3,4,6] },
                                { orderable: false, targets: [1,5,7] }
                            ]
                        });
                    }
                });
            </script>
        </section>
    </div>
</main>
</body>
</html>
