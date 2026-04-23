<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css" />
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Users"/>
    <jsp:param name="pageSubtitle" value="Manage student, instructor, and administrator accounts"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
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

        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Users</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Identity Management</p>
                    <h2>Manage students, instructors, and administrators from one secure workspace</h2>
                    <p>Filter by role and account status, search quickly, and take actions on user records without leaving the admin workflow.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <span class="admin-orb admin-orb-a"></span>
                    <span class="admin-orb admin-orb-b"></span>
                    <span class="admin-shape admin-shape-a"></span>
                    <span class="admin-shape admin-shape-b"></span>
                    <div class="admin-scene-panel admin-scene-panel-a">
                        <span>Total Users</span>
                        <strong>${totalUsers}</strong>
                    </div>
                    <div class="admin-scene-panel admin-scene-panel-b">
                        <span>Active</span>
                        <strong>${activeCount}</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>User Overview</h2>
                <button type="button" class="admin-btn primary js-open-user-modal" data-user-url="${pageContext.request.contextPath}/admin/users?action=create&modal=1" data-modal-title="Create User"><i class="fas fa-plus"></i>&nbsp;Create User</button>
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

        <section class="section-card">
            <div class="section-header">
                <h2>Filters and Search</h2>
            </div>
            <div class="section-actions-inset">
                <form method="get" action="${pageContext.request.contextPath}/admin/users" class="filters-grid">
                    <div>
                        <label for="roleFilter" class="admin-filter-label">Role</label>
                        <select name="role" id="roleFilter">
                            <option value="">All Roles</option>
                            <option value="Student" ${param.role == 'Student' ? 'selected' : ''}>Student</option>
                            <option value="Instructor" ${param.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                            <option value="Admin" ${param.role == 'Admin' ? 'selected' : ''}>Admin</option>
                        </select>
                    </div>
                    <div>
                        <label for="statusFilter" class="admin-filter-label">Status</label>
                        <select name="status" id="statusFilter">
                            <option value="">All Statuses</option>
                            <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                            <option value="Suspended" ${param.status == 'Suspended' ? 'selected' : ''}>Suspended</option>
                        </select>
                    </div>
                    <div>
                        <label for="searchQuery" class="admin-filter-label">Search</label>
                        <input type="text" name="search" id="searchQuery" placeholder="Search by name or email" value="${fn:escapeXml(param.search)}">
                    </div>
                    <div class="form-actions-inline">
                        <button type="submit" class="admin-btn primary"><i class="fas fa-search"></i>&nbsp;Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/users" class="admin-btn secondary">Clear</a>
                    </div>
                </form>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>All Users</h2>
            </div>
            <div class="admin-table-toolbar">
                <span class="section-caption">${totalUsers} total accounts</span>
                <button type="button" class="admin-btn primary js-open-user-modal" data-user-url="${pageContext.request.contextPath}/admin/users?action=create&modal=1" data-modal-title="Create User"><i class="fas fa-plus"></i>&nbsp;Create User</button>
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
                                    <td colspan="7">
                                        <div class="empty-state empty-state-inset">
                                            <i class="fas fa-inbox"></i>
                                            <p>No users found.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${users}" var="user">
                                    <tr>
                                        <td>${user.userId}</td>
                                        <td><strong>${user.fullName}</strong></td>
                                        <td>${user.email}</td>
                                        <td><c:out value="${not empty user.phone ? user.phone : '-'}"/></td>
                                        <td><span class="status-badge status-${user.role eq 'Student' ? 'success' : user.role eq 'Instructor' ? 'warning' : 'secondary'}">${user.role}</span></td>
                                        <td><span class="status-badge status-${user.status eq 'Active' or user.status eq 'active' ? 'success' : 'danger'}">${user.status}</span></td>
                                        <td>
                                            <div class="admin-table-actions">
                                                <button type="button" class="admin-btn secondary js-open-user-modal" data-user-url="${pageContext.request.contextPath}/admin/users?action=edit&userId=${user.userId}&modal=1" data-modal-title="Edit User">Edit</button>
                                                <a href="${pageContext.request.contextPath}/admin/users?action=toggle-status&userId=${user.userId}" class="admin-btn secondary" onclick="return confirm('Toggle status for ${user.fullName}?');">Toggle</a>
                                                <c:if test="${user.userId != sessionScope.user.userId}">
                                                    <a href="${pageContext.request.contextPath}/admin/users?action=delete&userId=${user.userId}" class="admin-btn danger" onclick="return confirm('Are you sure you want to delete ${user.fullName}?');">Delete</a>
                                                </c:if>
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
                window.__initUsersTable = function () {
                    if (!window.jQuery) {
                        return;
                    }
                    var $table = window.jQuery('#usersTable');
                    if ($table.length && window.jQuery('#usersTable tbody tr').length > 1) {
                        $table.DataTable({
                            order: [[0, 'desc']],
                            pageLength: 25,
                            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                            language: {
                                search: 'Search users:',
                                lengthMenu: 'Show _MENU_ entries',
                                info: 'Showing _START_ to _END_ of _TOTAL_ users',
                                infoEmpty: 'Showing 0 to 0 of 0 users',
                                infoFiltered: '(filtered from _MAX_ total users)',
                                zeroRecords: 'No matching users found',
                                emptyTable: 'No users available',
                                paginate: { first: 'First', last: 'Last', next: 'Next', previous: 'Previous' }
                            },
                            columnDefs: [
                                { orderable: true, targets: [0, 1, 2, 3] },
                                { orderable: false, targets: [4, 5, 6] }
                            ]
                        });
                    }
                };
            </script>
        </section>
    </div>
</main>

<div id="userActionModal" class="admin-modal" aria-hidden="true">
    <div class="admin-modal-backdrop" data-close-modal="userActionModal"></div>
    <div class="admin-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="userActionModalTitle">
        <div class="admin-modal-header">
            <h3 id="userActionModalTitle" class="admin-modal-title">User Action</h3>
            <button type="button" class="admin-modal-close" data-close-modal="userActionModal" aria-label="Close">x</button>
        </div>
        <iframe id="userActionModalFrame" class="admin-modal-iframe" title="User Action"></iframe>
    </div>
</div>

<script>
    (function() {
        var contextPath = '${pageContext.request.contextPath}';
        var modal = document.getElementById('userActionModal');
        var modalTitle = document.getElementById('userActionModalTitle');
        var frame = document.getElementById('userActionModalFrame');
        var openButtons = document.querySelectorAll('.js-open-user-modal');
        var closeButtons = document.querySelectorAll('[data-close-modal="userActionModal"]');

        function openModal(url, title) {
            frame.src = url;
            modalTitle.textContent = title || 'User Action';
            modal.classList.add('active');
            modal.setAttribute('aria-hidden', 'false');
            document.body.classList.add('admin-modal-open');
        }

        function closeModal() {
            modal.classList.remove('active');
            modal.setAttribute('aria-hidden', 'true');
            document.body.classList.remove('admin-modal-open');
            frame.src = 'about:blank';
        }

        openButtons.forEach(function(btn) {
            btn.addEventListener('click', function() {
                openModal(btn.getAttribute('data-user-url'), btn.getAttribute('data-modal-title'));
            });
        });

        closeButtons.forEach(function(btn) {
            btn.addEventListener('click', closeModal);
        });

        document.addEventListener('keydown', function(evt) {
            if (evt.key === 'Escape' && modal.classList.contains('active')) {
                closeModal();
            }
        });

        frame.addEventListener('load', function() {
            try {
                var currentPath = frame.contentWindow.location.pathname;
                var currentSearch = frame.contentWindow.location.search || '';
                var isFormAction = currentSearch.indexOf('action=create') !== -1 || currentSearch.indexOf('action=edit') !== -1;
                if (currentPath === contextPath + '/admin/users' && !isFormAction) {
                    window.location.href = contextPath + '/admin/users';
                }
            } catch (e) {
                // ignore cross-context access errors
            }
        });
    })();
</script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>
    if (typeof window.__initUsersTable === 'function') {
        window.__initUsersTable();
    }
</script>
</body>
</html>
