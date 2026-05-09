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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css" />
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    <style>
        .user-filter-panel-premium {
            background: #f8fafc !important;
            border: 1px solid #e2e8f0 !important;
            border-radius: 12px !important;
            padding: 14px 20px !important;
            margin: 16px 0 !important;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: all 0.3s ease;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.02);
        }
        .user-filter-panel-premium .filter-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .user-filter-panel-premium label {
            font-size: 0.85rem !important;
            font-weight: 600 !important;
            color: #475569 !important;
        }
        .user-filter-panel-premium select {
            background-color: #ffffff !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 8px !important;
            padding: 8px 16px !important;
            font-size: 0.85rem !important;
            font-weight: 500 !important;
            color: #1e293b !important;
            min-width: 160px !important;
            cursor: pointer;
            outline: none;
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        .user-filter-panel-premium select:hover {
            border-color: #94a3b8 !important;
            background-color: #f8fafc !important;
        }
        .user-filter-panel-premium select:focus {
            border-color: #1e293b !important;
            box-shadow: 0 0 0 3px rgba(30, 41, 59, 0.1) !important;
        }
    </style>
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

        <section class="course-board-shell section-card">
            <div class="course-board-header">
                <div class="course-board-copy">
                    <p class="admin-kicker">User Governance</p>
                    <h2>User Directory</h2>
                    <p>Manage, audit, and inspect student, instructor, and admin profiles from a modern directory.</p>
                </div>
                <div class="course-board-controls">
                    <label class="course-search-box" for="userSearchInput">
                        <i class="fas fa-search"></i>
                        <input type="search" id="userSearchInput" placeholder="Search by name, email, phone, role" aria-label="Search users">
                    </label>
                    <button type="button" class="admin-btn secondary" id="toggleUserFilters">
                        <i class="fas fa-sliders-h"></i>&nbsp;Filter
                    </button>
                    <button type="button" class="admin-btn primary js-open-user-modal" data-user-url="${pageContext.request.contextPath}/admin/users?action=create&modal=1" data-modal-title="Create User">
                        <i class="fas fa-plus"></i>&nbsp;Create User
                    </button>
                </div>
            </div>
            <div class="user-filter-panel-premium" id="userFilterPanel" style="display:none;">
                <div class="filter-group">
                    <label for="roleFilter">Role</label>
                    <select id="roleFilter">
                        <option value="">All Roles</option>
                        <option value="Student">Student</option>
                        <option value="Instructor">Instructor</option>
                        <option value="Admin">Admin</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="statusFilter">Status</label>
                    <select id="statusFilter">
                        <option value="">All Statuses</option>
                        <option value="Active">Active</option>
                        <option value="Suspended">Suspended</option>
                    </select>
                </div>
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
                                    <c:set var="uid" value="${user.userId}"/>
                                    <tr
                                        data-user-id="${uid}"
                                        data-user-fullname="${fn:escapeXml(user.fullName)}"
                                        data-user-email="${fn:escapeXml(user.email)}"
                                        data-user-phone="${fn:escapeXml(not empty user.phone ? user.phone : '-')}"
                                        data-user-role="${fn:escapeXml(user.role)}"
                                        data-user-status="${fn:escapeXml(user.status)}"
                                        
                                        <%-- Student details --%>
                                        data-student-reg="${fn:escapeXml(studentDetailsMap[uid].regNumber)}"
                                        data-student-qualification="${fn:escapeXml(studentDetailsMap[uid].qualification)}"
                                        data-student-country="${fn:escapeXml(studentDetailsMap[uid].country)}"
                                        data-student-state="${fn:escapeXml(studentDetailsMap[uid].state)}"
                                        data-student-gender="${fn:escapeXml(studentDetailsMap[uid].gender)}"
                                        data-student-emergency="${fn:escapeXml(studentDetailsMap[uid].emergencyContact)}"
                                        data-student-enrollments="${fn:escapeXml(studentEnrollmentsMap[uid])}"
                                        
                                        <%-- Instructor details --%>
                                        data-instructor-specialization="${fn:escapeXml(instructorDetailsMap[uid].specialization)}"
                                        data-instructor-certification="${fn:escapeXml(instructorDetailsMap[uid].certification)}"
                                        data-instructor-experience="${fn:escapeXml(instructorDetailsMap[uid].yearsOfExperience)}"
                                        data-instructor-bio="${fn:escapeXml(instructorDetailsMap[uid].bio)}"
                                        data-instructor-courses="${fn:escapeXml(instructorCoursesMap[uid])}"
                                        data-instructor-materials="${empty instructorMaterialsCountMap[uid] ? 0 : instructorMaterialsCountMap[uid]}"
                                        data-instructor-assessments="${empty instructorAssessmentsCountMap[uid] ? 0 : instructorAssessmentsCountMap[uid]}"
                                    >
                                        <td>${user.userId}</td>
                                        <td><strong>${user.fullName}</strong></td>
                                        <td>${user.email}</td>
                                        <td><c:out value="${not empty user.phone ? user.phone : '-'}"/></td>
                                        <td><span class="status-badge status-${user.role eq 'Student' ? 'success' : user.role eq 'Instructor' ? 'warning' : 'secondary'}">${user.role}</span></td>
                                        <td><span class="status-badge status-${user.status eq 'Active' or user.status eq 'active' ? 'success' : 'danger'}">${user.status}</span></td>
                                        <td>
                                            <div class="admin-table-actions">
                                                <button type="button" class="admin-btn secondary js-view-user-details">Details</button>
                                                <button type="button" class="admin-btn secondary js-open-user-modal" data-user-url="${pageContext.request.contextPath}/admin/users?action=edit&userId=${user.userId}&modal=1" data-modal-title="Edit User">Edit</button>
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
                    if ($table.length) {
                        var table = $table.DataTable({
                            order: [[0, 'desc']],
                            pageLength: 25,
                            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                            dom: 'rtip',
                            language: {
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

                        // Custom search input binding
                        var searchInput = document.getElementById('userSearchInput');
                        if (searchInput) {
                            searchInput.addEventListener('input', function () {
                                table.search(searchInput.value).draw();
                            });
                        }

                        // Custom filter binding
                        var roleFilter = document.getElementById('roleFilter');
                        var statusFilter = document.getElementById('statusFilter');

                        function applyFilters() {
                            var rVal = roleFilter.value;
                            var sVal = statusFilter.value;

                            // Apply custom filters on columns
                            if (rVal) {
                                table.column(4).search('^' + rVal + '$', true, false).draw();
                            } else {
                                table.column(4).search('').draw();
                            }

                            if (sVal) {
                                table.column(5).search('^' + sVal + '$', true, false).draw();
                            } else {
                                table.column(5).search('').draw();
                            }
                        }

                        if (roleFilter) {
                            roleFilter.addEventListener('change', applyFilters);
                        }
                        if (statusFilter) {
                            statusFilter.addEventListener('change', applyFilters);
                        }

                        // Toggle filter panel animation
                        var filterToggle = document.getElementById('toggleUserFilters');
                        var filterPanel = document.getElementById('userFilterPanel');
                        if (filterToggle && filterPanel) {
                            filterPanel.style.display = 'none';
                            filterToggle.addEventListener('click', function () {
                                filterPanel.classList.toggle('is-open');
                                filterPanel.style.display = filterPanel.classList.contains('is-open') ? 'flex' : 'none';
                            });
                        }
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

<div id="userDetailsModal" class="admin-modal" aria-hidden="true">
    <div class="admin-modal-backdrop" data-close-modal="userDetailsModal"></div>
    <div class="admin-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="userDetailsModalTitle" style="max-width: 650px;">
        <div class="admin-modal-header">
            <h3 id="userDetailsModalTitle" class="admin-modal-title">User Profile Details</h3>
            <button type="button" class="admin-modal-close" data-close-modal="userDetailsModal" aria-label="Close">x</button>
        </div>
        <div class="course-details-shell" style="padding: 20px; display: flex; flex-direction: column; gap: 18px;">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 12px;">
                <div>
                    <h4 id="detailUserFullName" style="font-size: 20px; font-weight: 700; margin: 0; color: var(--text);">John Doe</h4>
                    <span id="detailUserEmail" style="font-size: 13px; color: var(--text-muted); display: block; margin-top: 2px;">john@example.com</span>
                </div>
                <span id="detailUserRoleBadge" class="status-badge status-primary">Student</span>
            </div>

            <!-- Student specific details -->
            <div id="studentDetailsSection" style="display: none; flex-direction: column; gap: 16px;">
                <div class="course-detail-grid">
                    <div class="course-detail-card">
                        <span>Reg Number</span>
                        <strong id="detailStudentReg">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Qualification</span>
                        <strong id="detailStudentQual">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Country</span>
                        <strong id="detailStudentCountry">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>State</span>
                        <strong id="detailStudentState">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Gender</span>
                        <strong id="detailStudentGender">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Emergency Contact</span>
                        <strong id="detailStudentEmergency">-</strong>
                    </div>
                </div>
                <div>
                    <h5 style="margin: 0 0 10px; font-size: 14px; font-weight: 600; color: var(--text); border-bottom: 1px solid var(--border); padding-bottom: 6px;">Course Enrollments & Status</h5>
                    <div id="detailStudentEnrollments" class="panel-stack" style="gap: 8px; display: flex; flex-direction: column;">
                        <!-- Dynamic content -->
                    </div>
                </div>
            </div>

            <!-- Instructor specific details -->
            <div id="instructorDetailsSection" style="display: none; flex-direction: column; gap: 16px;">
                <div class="course-detail-grid">
                    <div class="course-detail-card">
                        <span>Specialization</span>
                        <strong id="detailInstructorSpec">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Certification</span>
                        <strong id="detailInstructorCert">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Experience</span>
                        <strong id="detailInstructorExp">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Materials Uploaded</span>
                        <strong id="detailInstructorMaterials">0</strong>
                    </div>
                    <div class="course-detail-card" style="grid-column: span 2;">
                        <span>Assessments Created</span>
                        <strong id="detailInstructorAssessments">0</strong>
                    </div>
                </div>
                <div>
                    <h5 style="margin: 0 0 6px; font-size: 14px; font-weight: 600; color: var(--text);">Bio / Executive Summary</h5>
                    <p id="detailInstructorBio" style="margin: 0; font-size: 13px; color: var(--text-muted); line-height: 1.6; background: var(--panel-bg); padding: 12px; border-radius: 8px; border: 1px solid var(--border);">Instructor biography goes here.</p>
                </div>
                <div>
                    <h5 style="margin: 0 0 8px; font-size: 14px; font-weight: 600; color: var(--text); border-bottom: 1px solid var(--border); padding-bottom: 6px;">Assigned Courses</h5>
                    <div id="detailInstructorCourses" style="font-size: 13px; color: var(--text); padding: 12px; background: var(--panel-bg); border-radius: 8px; border: 1px solid var(--border); line-height: 1.5;">
                        None
                    </div>
                </div>
            </div>

            <!-- Admin specific details -->
            <div id="adminDetailsSection" style="display: none; flex-direction: column; gap: 12px;">
                <p style="margin: 0; font-size: 13px; color: var(--text-muted); line-height: 1.5; background: var(--panel-bg); padding: 12px; border-radius: 8px; border: 1px solid var(--border);">
                    Administrative accounts have unrestricted global access. Permission details and positions can be modified via the account editor.
                </p>
            </div>
            
            <div style="display: flex; gap: 10px; margin-top: 10px; border-top: 1px solid var(--border); padding-top: 14px; justify-content: flex-end;">
                <button type="button" class="admin-btn secondary" data-close-modal="userDetailsModal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
    (function() {
        var detailModal = document.getElementById('userDetailsModal');
        var closeDetailButtons = document.querySelectorAll('[data-close-modal="userDetailsModal"]');

        function openDetailModal(row) {
            if (!row) return;
            var data = row.dataset;
            
            document.getElementById('detailUserFullName').textContent = data.userFullname || '';
            document.getElementById('detailUserEmail').textContent = data.userEmail || '';
            
            var role = data.userRole || '';
            var rBadge = document.getElementById('detailUserRoleBadge');
            rBadge.textContent = role;
            rBadge.className = 'status-badge status-' + (role === 'Student' ? 'success' : role === 'Instructor' ? 'warning' : 'secondary');

            // Hide all first
            document.getElementById('studentDetailsSection').style.display = 'none';
            document.getElementById('instructorDetailsSection').style.display = 'none';
            document.getElementById('adminDetailsSection').style.display = 'none';

            if (role === 'Student') {
                document.getElementById('studentDetailsSection').style.display = 'flex';
                document.getElementById('detailStudentReg').textContent = data.studentReg || '-';
                document.getElementById('detailStudentQual').textContent = data.studentQualification || '-';
                document.getElementById('detailStudentCountry').textContent = data.studentCountry || '-';
                document.getElementById('detailStudentState').textContent = data.studentState || '-';
                document.getElementById('detailStudentGender').textContent = data.studentGender || '-';
                document.getElementById('detailStudentEmergency').textContent = data.studentEmergency || '-';

                var enrollWrap = document.getElementById('detailStudentEnrollments');
                enrollWrap.innerHTML = '';
                var enrolls = data.studentEnrollments || '';
                if (enrolls && enrolls !== 'None') {
                    enrolls.split('; ').forEach(function(item) {
                        var div = document.createElement('div');
                        div.style.padding = '10px 14px';
                        div.style.background = 'var(--panel-bg)';
                        div.style.borderRadius = '8px';
                        div.style.border = '1px solid var(--border)';
                        div.style.display = 'flex';
                        div.style.justifyContent = 'space-between';
                        div.style.alignItems = 'center';
                        
                        // Parse status for styling
                        var statusClass = 'status-badge status-secondary';
                        var cleanStatus = 'Not Started';
                        if (item.indexOf('Completed') !== -1) {
                            statusClass = 'status-badge status-success';
                            cleanStatus = 'Completed';
                        } else if (item.indexOf('In Progress') !== -1) {
                            statusClass = 'status-badge status-warning';
                            cleanStatus = 'In Progress';
                        } else if (item.indexOf('Not Started') !== -1) {
                            statusClass = 'status-badge status-secondary';
                            cleanStatus = 'Not Started';
                        }

                        var courseTitle = item.substring(0, item.lastIndexOf('(')).trim();
                        var percentInfo = item.substring(item.lastIndexOf('(')); // e.g. (In Progress, 45%)
                        
                        div.innerHTML = '<div style="display:flex; flex-direction:column; gap:2px;"><strong style="font-size:13px; color:var(--text);">' + courseTitle + '</strong><span style="font-size:11px; color:var(--text-muted);">' + percentInfo + '</span></div><span class="' + statusClass + '">' + cleanStatus + '</span>';
                        enrollWrap.appendChild(div);
                    });
                } else {
                    enrollWrap.innerHTML = '<div style="font-size:13px; color:var(--text-muted); padding:10px 14px; background:var(--panel-bg); border-radius:8px; border:1px solid var(--border);">No active enrollments for this student.</div>';
                }
            } else if (role === 'Instructor') {
                document.getElementById('instructorDetailsSection').style.display = 'flex';
                document.getElementById('detailInstructorSpec').textContent = data.instructorSpecialization || '-';
                document.getElementById('detailInstructorCert').textContent = data.instructorCertification || '-';
                document.getElementById('detailInstructorExp').textContent = (data.instructorExperience && data.instructorExperience !== 'null' ? data.instructorExperience + ' years' : '-');
                document.getElementById('detailInstructorMaterials').textContent = data.instructorMaterials || '0';
                document.getElementById('detailInstructorAssessments').textContent = data.instructorAssessments || '0';
                document.getElementById('detailInstructorBio').textContent = (data.instructorBio && data.instructorBio !== 'null' ? data.instructorBio : 'No biography details provided.');
                
                var courses = data.instructorCourses || '';
                document.getElementById('detailInstructorCourses').textContent = (courses && courses !== 'None') ? courses : 'No courses currently assigned.';
            } else if (role === 'Admin') {
                document.getElementById('adminDetailsSection').style.display = 'flex';
            }

            detailModal.classList.add('active');
            detailModal.setAttribute('aria-hidden', 'false');
            document.body.classList.add('admin-modal-open');
        }

        function closeDetailModal() {
            detailModal.classList.remove('active');
            detailModal.setAttribute('aria-hidden', 'true');
            document.body.classList.remove('admin-modal-open');
        }

        // Delegate click for Details button in table
        document.addEventListener('click', function(evt) {
            var btn = evt.target.closest('.js-view-user-details');
            if (btn) {
                var row = btn.closest('tr');
                openDetailModal(row);
            }
        });

        closeDetailButtons.forEach(function(btn) {
            btn.addEventListener('click', closeDetailModal);
        });

        document.addEventListener('keydown', function(evt) {
            if (evt.key === 'Escape' && detailModal.classList.contains('active')) {
                closeDetailModal();
            }
        });
    })();
</script>

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
