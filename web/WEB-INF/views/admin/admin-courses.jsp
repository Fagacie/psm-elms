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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Courses"/>
    <jsp:param name="pageSubtitle" value="Review approvals and keep the course catalog organized"/>
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
                <span>&gt;</span>
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
            <div class="section-actions-inset">
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
            <div class="admin-table-toolbar">
                <span class="section-caption">${totalCourses} courses in view</span>
                <a href="${pageContext.request.contextPath}/admin/courses" class="admin-btn secondary">Reset Filters</a>
            </div>
            <div class="table-wrapper">
                <table id="coursesTable" class="data-table">
                    <thead>
                        <tr>
                            <th>Course Name</th>
                            <th>Category</th>
                            <th>Level</th>
                            <th>Duration</th>
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
                                        <div class="empty-state empty-state-inset">
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
                                                <div class="table-subtext">
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
                                        <td>${course.displayDuration}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${course.courseFee == 0}">Free</c:when>
                                                <c:otherwise><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                                            </c:choose>
                                        </td>
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
                                            <div class="admin-table-actions">
                                                <c:choose>
                                                    <c:when test="${course.status eq 'Pending'}">
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=approve&id=${course.courseId}" class="admin-btn primary" onclick="return confirm('Approve this course?');">Approve</a>
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=reject&id=${course.courseId}" class="admin-btn danger" onclick="return confirm('Reject this course?');">Reject</a>
                                                    </c:when>
                                                    <c:when test="${course.status eq 'Approved'}">
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=archive&id=${course.courseId}" class="admin-btn secondary" onclick="return confirm('Archive this course? Students will no longer see it.');">Archive</a>
                                                    </c:when>
                                                    <c:when test="${course.status eq 'Archived'}">
                                                        <a href="${pageContext.request.contextPath}/admin/courses?action=restore&id=${course.courseId}" class="admin-btn secondary" onclick="return confirm('Restore this course to Approved?');">Restore</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted-inline">-</span>
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
