<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
        <jsp:param name="pageTitle" value="User Management"/>
    </jsp:include>

    <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

    <main class="app-main">
        <div class="content-wrapper">
            <!-- User Statistics -->
            <c:set var="totalUsers" value="${fn:length(users)}"/>
            <c:set var="studentsCount" value="0"/>
            <c:set var="instructorsCount" value="0"/>
            <c:set var="adminsCount" value="0"/>
            <c:set var="activeCount" value="0"/>
            <c:set var="suspendedCount" value="0"/>
            <c:forEach items="${users}" var="u">
                <c:choose>
                    <c:when test="${u.role eq 'Student'}"><c:set var="studentsCount" value="${studentsCount + 1}"/></c:when>
                    <c:when test="${u.role eq 'Instructor'}"><c:set var="instructorsCount" value="${instructorsCount + 1}"/></c:when>
                    <c:when test="${u.role eq 'Admin'}"><c:set var="adminsCount" value="${adminsCount + 1}"/></c:when>
                </c:choose>
                <c:choose>
                    <c:when test="${u.status eq 'Active' or u.status eq 'active'}"><c:set var="activeCount" value="${activeCount + 1}"/></c:when>
                    <c:when test="${u.status eq 'Suspended' or u.status eq 'suspended'}"><c:set var="suspendedCount" value="${suspendedCount + 1}"/></c:when>
                </c:choose>
            </c:forEach>

            <section class="section-card">
                <div class="section-header">
                    <h2>User Statistics</h2>
                </div>
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-label">Total Users</div>
                        <div class="metric-value">${totalUsers}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Students</div>
                        <div class="metric-value">${studentsCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Instructors</div>
                        <div class="metric-value">${instructorsCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Admins</div>
                        <div class="metric-value">${adminsCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Active</div>
                        <div class="metric-value">${activeCount}</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">Suspended</div>
                        <div class="metric-value">${suspendedCount}</div>
                    </div>
                </div>
            </section>
            <!-- Alerts -->
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

            <!-- Filters and Search -->
            <section class="section-card">
                <div class="section-header">
                    <h2>Filters & Actions</h2>
                    <a href="${pageContext.request.contextPath}/admin/users?action=create" class="link" style="color: var(--color-primary); text-decoration: none; font-weight: 600; font-size: 14px;">
                        <i class="fas fa-plus"></i> Create New User
                    </a>
                </div>
                <form method="get" action="${pageContext.request.contextPath}/admin/users" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 15px;">
                    <div style="display: flex; flex-direction: column; gap: 5px;">
                        <label for="roleFilter" style="font-size: 14px; font-weight: 500; color: var(--color-text);">Role</label>
                        <select name="role" id="roleFilter" style="padding: 8px 12px; border: 1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); font-size: 14px; border-radius: 2px;">
                            <option value="">All Roles</option>
                            <option value="Student" ${param.role == 'Student' ? 'selected' : ''}>Student</option>
                            <option value="Instructor" ${param.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                            <option value="Admin" ${param.role == 'Admin' ? 'selected' : ''}>Admin</option>
                        </select>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 5px;">
                        <label for="statusFilter" style="font-size: 14px; font-weight: 500; color: var(--color-text);">Status</label>
                        <select name="status" id="statusFilter" style="padding: 8px 12px; border: 1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); font-size: 14px; border-radius: 2px;">
                            <option value="">All Statuses</option>
                            <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                            <option value="Suspended" ${param.status == 'Suspended' ? 'selected' : ''}>Suspended</option>
                        </select>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 5px;">
                        <label for="searchQuery" style="font-size: 14px; font-weight: 500; color: var(--color-text);">Search</label>
                        <input type="text" name="search" id="searchQuery" style="padding: 8px 12px; border: 1px solid var(--color-light-grey); background: var(--color-white); color: var(--color-text); font-size: 14px; border-radius: 2px;" 
                               placeholder="Search by name or email" value="${fn:escapeXml(param.search)}">
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 5px; justify-content: flex-end;">
                        <button type="submit" style="padding: 8px 16px; background: var(--color-primary); color: white; border: 1px solid var(--color-primary); font-size: 14px; font-weight: 600; cursor: pointer; border-radius: 2px;"><i class="fas fa-search"></i> Filter</button>
                    </div>
                </form>
                <a href="${pageContext.request.contextPath}/admin/users" style="display: inline-block; padding: 8px 16px; background: var(--color-background); border: 1px solid var(--color-light-grey); color: var(--color-text); text-decoration: none; font-size: 14px; font-weight: 600; cursor: pointer; border-radius: 2px;">Clear Filters</a>
            </section>

            <!-- Users Table -->
            <section class="section-card">
                <div class="section-header">
                    <h2>All Users</h2>
                </div>
                <div class="table-wrapper">
                    <table id="usersTable" class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty users}">
                                    <tr>
                                        <td colspan="7" style="text-align: center; padding: 40px; color: var(--color-text-light);"><i class="fas fa-inbox fa-2x" style="display: block; margin-bottom: 10px;"></i>No users found</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${users}" var="user">
                                        <tr>
                                            <td>${user.userId}</td>
                                            <td><strong>${user.fullName}</strong></td>
                                            <td>${user.email}</td>
                                            <td>${user.phone}</td>
                                            <td><span class="status-badge status-${user.role eq 'Student' ? 'success' : user.role eq 'Instructor' ? 'warning' : 'secondary'}">${user.role}</span></td>
                                            <td><span class="status-badge status-${user.status eq 'Active' or user.status eq 'active' ? 'success' : 'danger'}">${user.status}</span></td>
                                            <td style="font-size: 13px;">
                                                <a href="${pageContext.request.contextPath}/admin/users?action=edit&userId=${user.userId}" class="link"><i class="fas fa-edit"></i> Edit</a> |
                                                <a href="${pageContext.request.contextPath}/admin/users?action=toggle-status&userId=${user.userId}" class="link" onclick="return confirm('Toggle status for ${user.fullName}?');"><i class="fas fa-exchange-alt"></i> Toggle</a>
                                                <c:if test="${user.userId != sessionScope.user.userId}">
                                                    | <a href="${pageContext.request.contextPath}/admin/users?action=delete&userId=${user.userId}" class="link" style="color: var(--color-danger);" onclick="return confirm('Are you sure you want to delete ${user.fullName}?');"><i class="fas fa-trash"></i> Delete</a>
                                                </c:if>
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
                    if ($('#usersTable').length && $('#usersTable tbody tr').length > 1) {
                        $('#usersTable').DataTable({
                            order: [[0,'desc']],
                            pageLength: 25,
                            lengthMenu: [[10,25,50,100,-1],[10,25,50,100,'All']],
                            language: {
                                search: 'Search users:',
                                lengthMenu: 'Show _MENU_ entries',
                                info: 'Showing _START_ to _END_ of _TOTAL_ users',
                                infoEmpty: 'Showing 0 to 0 of 0 users',
                                infoFiltered: '(filtered from _MAX_ total users)',
                                zeroRecords: 'No matching users found',
                                emptyTable: 'No users available',
                                paginate: { first:'First', last:'Last', next:'Next', previous:'Previous' }
                            },
                            columnDefs: [
                                { orderable: true, targets: [0,1,2,3] },
                                { orderable: false, targets: [4,5,6] }
                            ]
                        });
                    }
                });
            </script>
        </div>
    </main>
</body>
</html>
