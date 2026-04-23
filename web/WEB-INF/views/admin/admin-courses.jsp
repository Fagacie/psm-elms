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
        <c:set var="totalCourses" value="${empty courses ? 0 : fn:length(courses)}"/>
        <c:set var="pendingCount" value="0"/>
        <c:set var="approvedCount" value="0"/>
        <c:set var="archivedCount" value="0"/>
        <c:set var="unassignedCount" value="0"/>
        <c:forEach items="${courses}" var="course">
            <c:set var="courseHasInstructor" value="false"/>
            <c:choose>
                <c:when test="${course.status eq 'Pending'}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:when>
                <c:when test="${course.status eq 'Approved'}"><c:set var="approvedCount" value="${approvedCount + 1}"/></c:when>
                <c:when test="${course.status eq 'Archived'}"><c:set var="archivedCount" value="${archivedCount + 1}"/></c:when>
            </c:choose>
            <c:forEach items="${instructors}" var="ins">
                <c:if test="${ins.userId == course.createdBy}">
                    <c:set var="courseHasInstructor" value="true"/>
                </c:if>
            </c:forEach>
            <c:if test="${not courseHasInstructor}">
                <c:set var="unassignedCount" value="${unassignedCount + 1}"/>
            </c:if>
        </c:forEach>

        <section class="course-board-shell section-card">
            <div class="admin-breadcrumb course-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Courses</span>
            </div>
            <div class="course-board-header">
                <div class="course-board-copy">
                    <p class="admin-kicker">Course Governance</p>
                    <h2>Professional course management dashboard</h2>
                    <p>Keep the catalog organized, assign instructors quickly, and manage lifecycle actions from a cleaner workspace.</p>
                </div>
                <div class="course-board-controls">
                    <label class="course-search-box" for="courseSearchInput">
                        <i class="fas fa-search"></i>
                        <input type="search" id="courseSearchInput" placeholder="Search courses, categories, instructors" aria-label="Search courses">
                    </label>
                    <button type="button" class="admin-btn secondary" id="toggleCourseFilters">
                        <i class="fas fa-sliders-h"></i>&nbsp;Filter
                    </button>
                    <button type="button" class="admin-btn primary" data-open-course-drawer>
                        <i class="fas fa-plus"></i>&nbsp;Create Course
                    </button>
                </div>
            </div>
            <div class="course-filter-panel" id="courseFilterPanel" style="display:none;">
                <a href="${pageContext.request.contextPath}/admin/courses" class="admin-btn ${empty param.status ? 'primary' : 'secondary'}">All Courses</a>
                <a href="${pageContext.request.contextPath}/admin/courses?status=Pending" class="admin-btn ${param.status == 'Pending' ? 'primary' : 'secondary'}">Pending Review</a>
                <a href="${pageContext.request.contextPath}/admin/courses?status=Approved" class="admin-btn ${param.status == 'Approved' ? 'primary' : 'secondary'}">Approved</a>
                <a href="${pageContext.request.contextPath}/admin/courses?status=Archived" class="admin-btn ${param.status == 'Archived' ? 'primary' : 'secondary'}">Archived</a>
                <span class="course-filter-note">The custom search box filters the table live without reloading the page.</span>
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
        <c:if test="${param.success == 'created'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Course created successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'assigned'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Instructor assignment updated successfully.
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

        <div class="course-stats-grid">
            <div class="metric-card course-stat-card">
                <div class="metric-label">Total Courses</div>
                <div class="metric-value">${totalCourses}</div>
                <div class="metric-meta">Complete catalog records</div>
            </div>
            <div class="metric-card course-stat-card">
                <div class="metric-label">Active Courses</div>
                <div class="metric-value">${approvedCount}</div>
                <div class="metric-meta">Published and visible to students</div>
            </div>
            <div class="metric-card course-stat-card">
                <div class="metric-label">Archived</div>
                <div class="metric-value">${archivedCount}</div>
                <div class="metric-meta">Hidden from the live catalog</div>
            </div>
            <div class="metric-card course-stat-card">
                <div class="metric-label">Unassigned</div>
                <div class="metric-value">${unassignedCount}</div>
                <div class="metric-meta">Records without a valid instructor profile</div>
            </div>
        </div>

        <section class="section-card">
            <div class="section-header course-table-header">
                <div>
                    <h2>All Courses</h2>
                    <p class="section-caption">The table keeps the essential fields visible and moves supporting details into the course drawer.</p>
                </div>
                <span class="section-caption">${totalCourses} course${totalCourses == 1 ? '' : 's'} in view</span>
            </div>
            <div class="table-wrapper course-table-wrapper">
                <table id="coursesTable" class="data-table course-table">
                    <thead>
                        <tr>
                            <th>Course</th>
                            <th class="course-hidden-column">Category</th>
                            <th>Level</th>
                            <th class="course-hidden-column">Duration</th>
                            <th>Fee</th>
                            <th>Status</th>
                            <th>Instructor</th>
                            <th class="course-hidden-column">Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty courses}">
                                <tr>
                                    <td colspan="9">
                                        <div class="empty-state empty-state-inset">
                                            <i class="fas fa-inbox"></i>
                                            <p>No courses found.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="course" items="${courses}">
                                    <c:set var="assignedLabel" value="Unassigned"/>
                                    <c:set var="assignedId" value=""/>
                                    <c:set var="courseHasInstructor" value="false"/>
                                    <c:forEach items="${instructors}" var="ins">
                                        <c:if test="${ins.userId == course.createdBy}">
                                            <c:set var="assignedLabel" value="${ins.fullName}"/>
                                            <c:set var="assignedId" value="${ins.userId}"/>
                                            <c:set var="courseHasInstructor" value="true"/>
                                        </c:if>
                                    </c:forEach>
                                    <c:set var="courseDescription" value="${not empty course.description ? course.description : ''}"/>
                                    <c:set var="courseCreatedValue" value="${not empty course.createdAt ? course.createdAt.toString() : ''}"/>
                                    <tr
                                        data-course-id="${course.courseId}"
                                        data-course-name="${fn:escapeXml(course.courseName)}"
                                        data-course-category="${fn:escapeXml(not empty course.category ? course.category : 'Uncategorized')}"
                                        data-course-level="${fn:escapeXml(not empty course.level ? course.level : 'Beginner')}"
                                        data-course-duration="${fn:escapeXml(not empty course.displayDuration ? course.displayDuration : '-') }"
                                        data-course-fee="${course.courseFee != null ? course.courseFee : 0}"
                                        data-course-status="${fn:escapeXml(course.status)}"
                                        data-course-instructor-id="${assignedId}"
                                        data-course-instructor-label="${fn:escapeXml(assignedLabel)}"
                                        data-course-created="${fn:escapeXml(courseCreatedValue)}"
                                        data-course-description="${fn:escapeXml(courseDescription)}"
                                        data-course-approve-url="${pageContext.request.contextPath}/admin/courses?action=approve&id=${course.courseId}"
                                        data-course-reject-url="${pageContext.request.contextPath}/admin/courses?action=reject&id=${course.courseId}"
                                        data-course-archive-url="${pageContext.request.contextPath}/admin/courses?action=archive&id=${course.courseId}"
                                        data-course-restore-url="${pageContext.request.contextPath}/admin/courses?action=restore&id=${course.courseId}"
                                    >
                                        <td>
                                            <strong><c:out value="${course.courseName}"/></strong>
                                            <c:if test="${not empty course.description}">
                                                <div class="table-subtext">
                                                    <c:choose>
                                                        <c:when test="${fn:length(course.description) > 78}">${fn:substring(course.description, 0, 78)}...</c:when>
                                                        <c:otherwise><c:out value="${course.description}"/></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td class="course-hidden-column"><c:out value="${not empty course.category ? course.category : 'Uncategorized'}"/></td>
                                        <td><span class="status-badge status-${course.level eq 'Beginner' ? 'success' : course.level eq 'Intermediate' ? 'warning' : 'secondary'}"><c:out value="${not empty course.level ? course.level : 'Beginner'}"/></span></td>
                                        <td class="course-hidden-column"><c:out value="${not empty course.displayDuration ? course.displayDuration : '-'}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${course.courseFee == 0}">Free</c:when>
                                                <c:otherwise><fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="status-badge status-${course.status eq 'Pending' ? 'warning' : course.status eq 'Approved' ? 'success' : 'secondary'}"><c:out value="${course.status}"/></span>
                                        </td>
                                        <td>
                                            <span class="course-instructor-label ${courseHasInstructor ? '' : 'is-empty'}"><c:out value="${assignedLabel}"/></span>
                                        </td>
                                        <td class="course-hidden-column">
                                            <c:choose>
                                                <c:when test="${not empty course.createdAt}">
                                                    <c:out value="${fn:length(course.createdAt.toString()) >= 10 ? fn:substring(course.createdAt.toString(), 0, 10) : course.createdAt.toString()}"/>
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="course-actions">
                                                <button type="button" class="course-actions-trigger" data-course-menu-toggle aria-label="Open course actions">
                                                    <i class="fas fa-ellipsis-v"></i>
                                                </button>
                                                <div class="course-actions-menu" role="menu" aria-label="Course actions" style="display:none;">
                                                    <button type="button" class="course-menu-item js-course-view" data-course-view>View Details</button>
                                                    <button type="button" class="course-menu-item js-course-assign" data-course-assign>Assign Instructor</button>
                                                    <c:choose>
                                                        <c:when test="${course.status eq 'Pending'}">
                                                            <a href="${pageContext.request.contextPath}/admin/courses?action=approve&id=${course.courseId}" class="course-menu-item" onclick="return confirm('Approve this course?');">Approve</a>
                                                            <a href="${pageContext.request.contextPath}/admin/courses?action=reject&id=${course.courseId}" class="course-menu-item" onclick="return confirm('Reject this course?');">Reject</a>
                                                        </c:when>
                                                        <c:when test="${course.status eq 'Approved'}">
                                                            <a href="${pageContext.request.contextPath}/admin/courses?action=archive&id=${course.courseId}" class="course-menu-item" onclick="return confirm('Archive this course? Students will no longer see it.');">Archive</a>
                                                        </c:when>
                                                        <c:when test="${course.status eq 'Archived'}">
                                                            <a href="${pageContext.request.contextPath}/admin/courses?action=restore&id=${course.courseId}" class="course-menu-item" onclick="return confirm('Restore this course to Approved?');">Restore</a>
                                                        </c:when>
                                                    </c:choose>
                                                </div>
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
                window.__initCoursesDashboard = function () {
                    if (!window.jQuery) {
                        return;
                    }

                    var $ = window.jQuery;
                    var $table = $('#coursesTable');
                    var dataTable = null;

                    if ($table.length && $('#coursesTable tbody tr').length > 1 && $.fn.DataTable) {
                        dataTable = $table.DataTable({
                            order: [[7, 'desc']],
                            pageLength: 10,
                            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                            dom: 'rtip',
                            autoWidth: false,
                            language: {
                                info: 'Showing _START_ to _END_ of _TOTAL_ courses',
                                infoEmpty: 'Showing 0 to 0 of 0 courses',
                                infoFiltered: '(filtered from _MAX_ total courses)',
                                zeroRecords: 'No matching courses found',
                                emptyTable: 'No courses available',
                                paginate: { first: 'First', last: 'Last', next: 'Next', previous: 'Previous' }
                            },
                            columnDefs: [
                                { targets: [1, 3, 7], visible: false, searchable: true },
                                { orderable: false, targets: [8] },
                                { orderable: true, targets: [0, 2, 4, 5, 6] }
                            ]
                        });
                    }

                    var searchInput = document.getElementById('courseSearchInput');
                    if (searchInput && !searchInput.dataset.bound) {
                        searchInput.dataset.bound = '1';
                        searchInput.addEventListener('input', function () {
                            if (dataTable) {
                                dataTable.search(searchInput.value).draw();
                            }
                        });
                    }

                    var filterToggle = document.getElementById('toggleCourseFilters');
                    var filterPanel = document.getElementById('courseFilterPanel');
                    if (filterToggle && filterPanel && !filterToggle.dataset.bound) {
                        filterToggle.dataset.bound = '1';
                        filterPanel.style.display = 'none';
                        filterToggle.addEventListener('click', function () {
                            filterPanel.classList.toggle('is-open');
                            filterPanel.style.display = filterPanel.classList.contains('is-open') ? 'flex' : 'none';
                        });
                    }

                    var createModal = document.getElementById('courseCreateModal');
                    var assignModal = document.getElementById('courseAssignModal');
                    var detailsModal = document.getElementById('courseDetailsModal');
                    var assignCourseIdInput = document.getElementById('courseAssignId');
                    var assignInstructorSelect = document.getElementById('courseAssignInstructorId');
                    var assignCourseName = document.getElementById('courseAssignCourseName');
                    var detailsTitle = document.getElementById('courseDetailsTitle');
                    var detailsStatus = document.getElementById('courseDetailsStatus');
                    var detailsInstructor = document.getElementById('courseDetailsInstructor');
                    var detailsCategory = document.getElementById('courseDetailsCategory');
                    var detailsLevel = document.getElementById('courseDetailsLevel');
                    var detailsDuration = document.getElementById('courseDetailsDuration');
                    var detailsFee = document.getElementById('courseDetailsFee');
                    var detailsCreated = document.getElementById('courseDetailsCreated');
                    var detailsDescription = document.getElementById('courseDetailsDescription');
                    var detailsPrimaryAction = document.getElementById('courseDetailsPrimaryAction');
                    var detailsPrimaryActionLabel = document.getElementById('courseDetailsPrimaryActionLabel');
                    var detailsAssignAction = document.getElementById('courseDetailsAssignAction');

                    function openModal(modal) {
                        if (!modal) {
                            return;
                        }
                        modal.classList.add('active');
                        modal.setAttribute('aria-hidden', 'false');
                        document.body.classList.add('admin-modal-open');
                    }

                    function closeModal(modal) {
                        if (!modal) {
                            return;
                        }
                        modal.classList.remove('active');
                        modal.setAttribute('aria-hidden', 'true');
                        document.body.classList.remove('admin-modal-open');
                    }

                    function formatMoney(value) {
                        var amount = Number(value || 0);
                        if (!isFinite(amount)) {
                            return '-';
                        }
                        if (amount === 0) {
                            return 'Free';
                        }
                        return amount.toLocaleString('en-NG', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                    }

                    function populateDetails(row) {
                        if (!row) {
                            return;
                        }
                        var data = row.dataset;
                        var courseName = data.courseName || 'Course details';
                        var status = data.courseStatus || 'Unknown';
                        var fee = formatMoney(data.courseFee);

                        detailsTitle.textContent = courseName;
                        detailsStatus.textContent = status;
                        detailsStatus.className = 'status-badge status-' + (status === 'Pending' ? 'warning' : status === 'Approved' ? 'success' : 'secondary');
                        detailsInstructor.textContent = data.courseInstructorLabel || 'Unassigned';
                        detailsCategory.textContent = data.courseCategory || 'Uncategorized';
                        detailsLevel.textContent = data.courseLevel || 'Beginner';
                        detailsDuration.textContent = data.courseDuration || '-';
                        detailsFee.textContent = fee;
                        detailsCreated.textContent = data.courseCreated ? data.courseCreated.substring(0, 10) : '-';
                        detailsDescription.textContent = data.courseDescription || 'No description provided for this course yet.';

                        var primaryUrl = '';
                        var primaryLabel = '';
                        if (status === 'Pending') {
                            primaryUrl = data.courseApproveUrl || '#';
                            primaryLabel = 'Approve';
                        } else if (status === 'Approved') {
                            primaryUrl = data.courseArchiveUrl || '#';
                            primaryLabel = 'Archive';
                        } else if (status === 'Archived') {
                            primaryUrl = data.courseRestoreUrl || '#';
                            primaryLabel = 'Restore';
                        }

                        detailsPrimaryAction.href = primaryUrl;
                        detailsPrimaryActionLabel.textContent = primaryLabel || 'Status Action';
                        detailsPrimaryAction.style.display = primaryLabel ? 'inline-flex' : 'none';
                        detailsAssignAction.dataset.courseId = data.courseId;
                        detailsAssignAction.dataset.courseName = courseName;
                        detailsAssignAction.dataset.courseInstructorId = data.courseInstructorId || '';
                        assignCourseIdInput.value = data.courseId || '';
                        assignCourseName.textContent = courseName;
                        if (assignInstructorSelect) {
                            assignInstructorSelect.value = data.courseInstructorId || '';
                        }
                    }

                    document.querySelectorAll('[data-open-course-drawer]').forEach(function (button) {
                        if (button.dataset.bound) {
                            return;
                        }
                        button.dataset.bound = '1';
                        button.addEventListener('click', function () {
                            openModal(createModal);
                        });
                    });

                    document.querySelectorAll('[data-close-modal]').forEach(function (button) {
                        if (button.dataset.bound) {
                            return;
                        }
                        button.dataset.bound = '1';
                        button.addEventListener('click', function () {
                            closeModal(document.getElementById(button.getAttribute('data-close-modal')));
                        });
                    });

                    document.querySelectorAll('[data-course-menu-toggle]').forEach(function (button) {
                        if (button.dataset.bound) {
                            return;
                        }
                        button.dataset.bound = '1';
                        button.addEventListener('click', function (event) {
                            event.stopPropagation();
                            var actionWrap = button.closest('.course-actions');
                            var openState = actionWrap.classList.contains('is-open');
                            document.querySelectorAll('.course-actions.is-open').forEach(function (menu) {
                                menu.classList.remove('is-open');
                                var hiddenMenu = menu.querySelector('.course-actions-menu');
                                if (hiddenMenu) {
                                    hiddenMenu.style.display = 'none';
                                }
                            });
                            if (!openState) {
                                actionWrap.classList.add('is-open');
                                var activeMenu = actionWrap.querySelector('.course-actions-menu');
                                if (activeMenu) {
                                    activeMenu.style.display = 'grid';
                                }
                            }
                        });
                    });

                    document.querySelectorAll('.js-course-view').forEach(function (button) {
                        if (button.dataset.bound) {
                            return;
                        }
                        button.dataset.bound = '1';
                        button.addEventListener('click', function (event) {
                            event.stopPropagation();
                            var row = button.closest('tr');
                            populateDetails(row);
                            openModal(detailsModal);
                            document.querySelectorAll('.course-actions.is-open').forEach(function (menu) {
                                menu.classList.remove('is-open');
                                var hiddenMenu = menu.querySelector('.course-actions-menu');
                                if (hiddenMenu) {
                                    hiddenMenu.style.display = 'none';
                                }
                            });
                        });
                    });

                    document.querySelectorAll('.js-course-assign').forEach(function (button) {
                        if (button.dataset.bound) {
                            return;
                        }
                        button.dataset.bound = '1';
                        button.addEventListener('click', function (event) {
                            event.stopPropagation();
                            var row = button.closest('tr');
                            populateDetails(row);
                            openModal(assignModal);
                            document.querySelectorAll('.course-actions.is-open').forEach(function (menu) {
                                menu.classList.remove('is-open');
                                var hiddenMenu = menu.querySelector('.course-actions-menu');
                                if (hiddenMenu) {
                                    hiddenMenu.style.display = 'none';
                                }
                            });
                        });
                    });

                    if (detailsAssignAction && !detailsAssignAction.dataset.bound) {
                        detailsAssignAction.dataset.bound = '1';
                        detailsAssignAction.addEventListener('click', function () {
                            closeModal(detailsModal);
                            openModal(assignModal);
                        });
                    }

                    document.addEventListener('click', function (event) {
                        if (!event.target.closest('.course-actions')) {
                            document.querySelectorAll('.course-actions.is-open').forEach(function (menu) {
                                menu.classList.remove('is-open');
                                var hiddenMenu = menu.querySelector('.course-actions-menu');
                                if (hiddenMenu) {
                                    hiddenMenu.style.display = 'none';
                                }
                            });
                        }
                    });

                    document.addEventListener('keydown', function (event) {
                        if (event.key === 'Escape') {
                            closeModal(createModal);
                            closeModal(assignModal);
                            closeModal(detailsModal);
                            document.querySelectorAll('.course-actions.is-open').forEach(function (menu) {
                                menu.classList.remove('is-open');
                                var hiddenMenu = menu.querySelector('.course-actions-menu');
                                if (hiddenMenu) {
                                    hiddenMenu.style.display = 'none';
                                }
                            });
                        }
                    });
                };
            </script>
        </section>
    </div>
</main>

<div id="courseCreateModal" class="admin-modal admin-course-drawer" aria-hidden="true">
    <div class="admin-modal-backdrop" data-close-modal="courseCreateModal"></div>
    <div class="admin-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="courseCreateModalTitle">
        <div class="admin-modal-header">
            <h3 id="courseCreateModalTitle" class="admin-modal-title">Create Course</h3>
            <button type="button" class="admin-modal-close" data-close-modal="courseCreateModal" aria-label="Close">x</button>
        </div>
        <div class="course-drawer-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/courses" enctype="multipart/form-data" class="course-drawer-form">
                <input type="hidden" name="action" value="create"/>
                <div class="course-form-grid course-form-grid-create">
                    <div class="form-group">
                        <label for="courseName">Course Name</label>
                        <input id="courseName" name="courseName" type="text" required class="form-control" placeholder="e.g. Strategic Digital Marketing"/>
                    </div>
                    <div class="form-group">
                        <label for="category">Category</label>
                        <input id="category" name="category" type="text" class="form-control" placeholder="Business, Technology, Design"/>
                    </div>
                    <div class="form-group">
                        <label for="level">Level</label>
                        <select id="level" name="level" class="form-control">
                            <option value="Beginner">Beginner</option>
                            <option value="Intermediate">Intermediate</option>
                            <option value="Advanced">Advanced</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="duration">Duration</label>
                        <input id="duration" name="duration" type="number" min="1" class="form-control" placeholder="Days"/>
                    </div>
                    <div class="form-group">
                        <label for="courseFee">Fee (NGN)</label>
                        <input id="courseFee" name="courseFee" type="number" min="0" step="0.01" required class="form-control" placeholder="0.00"/>
                    </div>
                    <div class="form-group">
                        <label for="instructorId">Instructor</label>
                        <select id="instructorId" name="instructorId" class="form-control">
                            <option value="">No instructor assigned</option>
                            <c:forEach items="${instructors}" var="ins">
                                <option value="${ins.userId}"><c:out value="${ins.fullName}"/> (<c:out value="${ins.email}"/>)</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group form-group-full">
                        <label for="courseBanner">Course Banner</label>
                        <input id="courseBanner" name="courseBanner" type="file" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp" class="form-control"/>
                        <small class="text-muted">Recommended: 1280x720. JPG, PNG, or WEBP up to 5MB.</small>
                    </div>
                    <div class="form-group form-group-full course-description-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" rows="5" class="form-control" placeholder="Write a concise summary of the course, its purpose, and what the learner will gain."></textarea>
                    </div>
                </div>
                <div class="course-drawer-footer">
                    <button type="button" class="admin-btn secondary" data-close-modal="courseCreateModal">Cancel</button>
                    <button type="submit" class="admin-btn primary"><i class="fas fa-save"></i>&nbsp;Create Course</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div id="courseAssignModal" class="admin-modal admin-course-drawer" aria-hidden="true">
    <div class="admin-modal-backdrop" data-close-modal="courseAssignModal"></div>
    <div class="admin-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="courseAssignModalTitle">
        <div class="admin-modal-header">
            <h3 id="courseAssignModalTitle" class="admin-modal-title">Assign Instructor</h3>
            <button type="button" class="admin-modal-close" data-close-modal="courseAssignModal" aria-label="Close">x</button>
        </div>
        <div class="course-drawer-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/courses" class="course-drawer-form">
                <input type="hidden" name="action" value="assign"/>
                <input type="hidden" name="courseId" id="courseAssignId" value=""/>
                <div class="course-inline-note">
                    <span class="course-inline-label">Course</span>
                    <strong id="courseAssignCourseName">Select a course</strong>
                </div>
                <div class="form-group">
                    <label for="courseAssignInstructorId">Instructor</label>
                    <select id="courseAssignInstructorId" name="instructorId" required class="form-control">
                        <option value="">Select instructor</option>
                        <c:forEach items="${instructors}" var="ins">
                            <option value="${ins.userId}"><c:out value="${ins.fullName}"/> (<c:out value="${ins.email}"/>)</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="course-drawer-footer">
                    <button type="button" class="admin-btn secondary" data-close-modal="courseAssignModal">Cancel</button>
                    <button type="submit" class="admin-btn primary"><i class="fas fa-link"></i>&nbsp;Assign Instructor</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div id="courseDetailsModal" class="admin-modal admin-course-details-modal" aria-hidden="true">
    <div class="admin-modal-backdrop" data-close-modal="courseDetailsModal"></div>
    <div class="admin-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="courseDetailsModalTitle">
        <div class="admin-modal-header">
            <h3 id="courseDetailsModalTitle" class="admin-modal-title">Course Details</h3>
            <button type="button" class="admin-modal-close" data-close-modal="courseDetailsModal" aria-label="Close">x</button>
        </div>
        <div class="course-details-shell">
            <div class="course-details-main">
                <div class="detail-status-row">
                    <div>
                        <p class="detail-label">Course</p>
                        <h4 id="courseDetailsTitle">Course title</h4>
                    </div>
                    <span id="courseDetailsStatus" class="status-badge status-secondary">Status</span>
                </div>
                <p id="courseDetailsDescription" class="course-details-description">Course description appears here.</p>
                <div class="course-detail-grid">
                    <div class="course-detail-card">
                        <span>Instructor</span>
                        <strong id="courseDetailsInstructor">Unassigned</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Category</span>
                        <strong id="courseDetailsCategory">Uncategorized</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Level</span>
                        <strong id="courseDetailsLevel">Beginner</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Duration</span>
                        <strong id="courseDetailsDuration">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Fee</span>
                        <strong id="courseDetailsFee">-</strong>
                    </div>
                    <div class="course-detail-card">
                        <span>Created</span>
                        <strong id="courseDetailsCreated">-</strong>
                    </div>
                </div>
            </div>
            <div class="course-details-aside">
                <div class="course-details-panel">
                    <h4>Quick Actions</h4>
                    <p>Open the assignment drawer or apply the next lifecycle step for this course.</p>
                    <div class="course-details-actions">
                        <a id="courseDetailsPrimaryAction" class="admin-btn primary" href="#"><span id="courseDetailsPrimaryActionLabel">Status Action</span></a>
                        <button type="button" id="courseDetailsAssignAction" class="admin-btn secondary">Assign Instructor</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>
    if (typeof window.__initCoursesDashboard === 'function') {
        window.__initCoursesDashboard();
    }
</script>
</body>
</html>
