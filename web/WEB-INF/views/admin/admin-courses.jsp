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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
        <jsp:param name="pageTitle" value="Course Management"/>
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

            <!-- Alerts -->
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

            <!-- Course Statistics -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Course Statistics</h2>
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

            <!-- Filters and Search -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Filters & Status</h2>
                </div>
                <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 15px;">
                    <a href="${pageContext.request.contextPath}/admin/courses" class="link" style="padding: 8px 16px; border: 1px solid ${empty param.status ? 'var(--color-primary)' : 'var(--color-light-grey)'}; background: ${empty param.status ? 'var(--color-primary)' : 'var(--color-white)'}; color: ${empty param.status ? 'white' : 'var(--color-text)'}; text-decoration: none; font-size: 14px; font-weight: 600; border-radius: 2px; cursor: pointer;">All Courses</a>
                    <a href="${pageContext.request.contextPath}/admin/courses?status=Pending" class="link" style="padding: 8px 16px; border: 1px solid ${param.status == 'Pending' ? 'var(--color-primary)' : 'var(--color-light-grey)'}; background: ${param.status == 'Pending' ? 'var(--color-primary)' : 'var(--color-white)'}; color: ${param.status == 'Pending' ? 'white' : 'var(--color-text)'}; text-decoration: none; font-size: 14px; font-weight: 600; border-radius: 2px; cursor: pointer;">Pending Review</a>
                    <a href="${pageContext.request.contextPath}/admin/courses?status=Approved" class="link" style="padding: 8px 16px; border: 1px solid ${param.status == 'Approved' ? 'var(--color-primary)' : 'var(--color-light-grey)'}; background: ${param.status == 'Approved' ? 'var(--color-primary)' : 'var(--color-white)'}; color: ${param.status == 'Approved' ? 'white' : 'var(--color-text)'}; text-decoration: none; font-size: 14px; font-weight: 600; border-radius: 2px; cursor: pointer;">Approved</a>
                    <a href="${pageContext.request.contextPath}/admin/courses?status=Archived" class="link" style="padding: 8px 16px; border: 1px solid ${param.status == 'Archived' ? 'var(--color-primary)' : 'var(--color-light-grey)'}; background: ${param.status == 'Archived' ? 'var(--color-primary)' : 'var(--color-white)'}; color: ${param.status == 'Archived' ? 'white' : 'var(--color-text)'}; text-decoration: none; font-size: 14px; font-weight: 600; border-radius: 2px; cursor: pointer;">Archived</a>
                </div>
            </section>

            <!-- Courses Table -->
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
                                <th>Fee (₦)</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty courses}">
                                    <tr>
                                        <td colspan="8" style="text-align: center; padding: 40px; color: var(--color-text-light);"><i class="fas fa-inbox fa-2x" style="display: block; margin-bottom: 10px;"></i>No courses found.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="course" items="${courses}">
                                        <tr>
                                            <td>
                                                <strong>${course.courseName}</strong>
                                                <c:if test="${not empty course.description}">
                                                    <div style="font-size: 12px; color: var(--color-text-light); margin-top: 3px;">
                                                        <c:set var="desc" value="${course.description}"/>
                                                        <c:choose>
                                                            <c:when test="${fn:length(desc) > 50}">
                                                                ${fn:substring(desc, 0, 50)}...
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${desc}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:if>
                                            </td>
                                            <td>${course.category}</td>
                                            <td><span class="status-badge status-${course.level eq 'Beginner' ? 'success' : course.level eq 'Intermediate' ? 'warning' : 'secondary'}">${course.level}</span></td>
                                            <td style="text-align: center;">${course.duration}</td>
                                            <td style="text-align: right;"><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
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
                                            <td style="font-size: 13px;">
                                                <c:choose>
                                                    <c:when test="${course.status eq 'Pending'}">
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=approve&id=${course.courseId}" class="link" style="color: var(--color-success);" onclick="return confirm('Approve this course?');"><i class="fas fa-check"></i> Approve</a> |
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=reject&id=${course.courseId}" class="link" style="color: var(--color-danger);" onclick="return confirm('Reject this course?');"><i class="fas fa-times"></i> Reject</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: var(--color-text-light);">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- DataTables styling and initialization -->
            <style>
                .dataTables_wrapper { padding: 15px 0; }
                .dataTables_length, .dataTables_filter { margin-bottom: 15px; }
                .dataTables_length label, .dataTables_filter label { display:flex; align-items:center; gap:10px; font-size:14px; color: var(--color-text); font-weight:500; }
                .dataTables_length select, .dataTables_filter input { padding:8px 12px; border:1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); font-size:14px; margin:0 5px; border-radius: 2px; }
                .dataTables_length select:focus, .dataTables_filter input:focus { outline:none; border-color: var(--color-primary); }
                .dataTables_info { padding:15px 0; color: var(--color-text-light); font-size:14px; }
                .dataTables_paginate { padding:15px 0; }
                .dataTables_paginate .paginate_button { padding:6px 12px; margin:0 2px; border:1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); cursor:pointer; font-size:14px; border-radius: 2px; }
                .dataTables_paginate .paginate_button:hover { background: var(--color-background); border-color: var(--color-primary); color: var(--color-primary); }
                .dataTables_paginate .paginate_button.current { background: var(--color-primary); border-color: var(--color-primary); color:#fff; font-weight:600; }
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
        </div>
    </main>
</body>
</html>
