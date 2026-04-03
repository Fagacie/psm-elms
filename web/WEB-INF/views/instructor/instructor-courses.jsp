<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-courses.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="instructor-ui">
    <header class="app-header">
        <div class="header-left">
            <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
                <span class="dashboard-brand-main">PSM</span>
                <span class="dashboard-brand-sub">E-Learning</span>
            </a>
            <div class="dashboard-title-copy">
                <h1 class="page-title">My Courses</h1>
                <p>Manage courses, content, and enrollments from one workspace</p>
            </div>
        </div>
        <div class="header-right">
            <div class="user-menu">
                <div class="user-info">
                    <span class="user-name"><c:out value="${empty user ? sessionScope.user.fullName : user.fullName}"/></span>
                    <span class="user-role">Instructor</span>
                </div>
                <div class="user-avatar"><i class="fas fa-user"></i></div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
                <i class="fas fa-sign-out-alt"></i>
                Logout
            </a>
        </div>
    </header>

    <aside class="app-sidebar">
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item active">
                <i class="fas fa-book"></i>
                <span>Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item">
                <i class="fas fa-folder-open"></i>
                <span>Materials</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item">
                <i class="fas fa-clipboard-list"></i>
                <span>Assessments</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item">
                <i class="fas fa-certificate"></i>
                <span>Certificates</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="nav-item">
                <i class="fas fa-user"></i>
                <span>Profile / Settings</span>
            </a>
        </nav>
    </aside>

    <main class="app-main">
        <div class="content-wrapper">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
                <span>&gt;</span>
                <span>My Courses</span>
            </nav>

            <section class="ins-page-head">
                <div>
                    <p class="ins-page-kicker">Course Management</p>
                    <h2>Manage your teaching catalog professionally</h2>
                    <p>Use this table to operate course setup, content, assessments, student rosters, and lifecycle controls from one structured workspace.</p>
                </div>
                <div class="ins-hero-actions">
                    <button type="button" class="btn btn-primary" onclick="openCreateCourseModal()">
                        <i class="fas fa-plus"></i> Create New Course
                    </button>
                </div>
            </section>

            <c:if test="${param.success == 'created'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Course created successfully! Pending admin approval.
                </div>
            </c:if>
            <c:if test="${param.success == 'updated'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Course updated successfully!
                </div>
            </c:if>
            <c:if test="${param.success == 'deleted'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Course deleted successfully!
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

            <c:choose>
                <c:when test="${empty courses}">
                    <div class="empty-state-box">
                        <i class="fas fa-book"></i>
                        <p>You haven't created any courses yet.</p>
                        <button type="button" class="btn btn-primary" onclick="openCreateCourseModal()">Create Your First Course</button>
                    </div>
                </c:when>
                <c:otherwise>
                    <section class="section-card courses-table-section">
                        <div class="section-header">
                            <div>
                                <h3 class="section-title">My Courses</h3>
                                <p class="section-caption">Primary actions are always visible. Secondary actions are grouped under More for a cleaner row.</p>
                            </div>
                            <span class="courses-count">${courses.size()} courses</span>
                        </div>

                        <div class="table-container">
                            <table class="data-table courses-table">
                                <thead>
                                    <tr>
                                        <th>Course</th>
                                        <th>Category</th>
                                        <th>Level</th>
                                        <th>Duration</th>
                                        <th>Fee</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="course" items="${courses}">
                                        <tr>
                                            <td>
                                                <div class="course-cell">
                                                    <div class="course-thumb-wrap">
                                                        <c:choose>
                                                            <c:when test="${not empty course.courseBanner}">
                                                                <img class="course-thumb" src="${course.courseBanner}" alt="${course.courseName} banner">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="course-thumb course-thumb-placeholder">
                                                                    <i class="fas fa-image"></i>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="course-primary">
                                                        <div class="course-name"><c:out value="${course.courseName}"/></div>
                                                        <div class="course-summary">
                                                            <c:choose>
                                                                <c:when test="${not empty course.description && course.description.length() > 90}">
                                                                    <c:out value="${course.description.substring(0, 90)}"/>...
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:out value="${course.description}"/>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><c:out value="${course.category}"/></td>
                                            <td><c:out value="${course.level}"/></td>
                                            <td><c:out value="${course.duration}"/> hrs</td>
                                            <td>₦<fmt:formatNumber value="${course.courseFee}" type="number" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>
                                                <span class="status-badge status-${course.status}"><c:out value="${course.status}"/></span>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a href="${pageContext.request.contextPath}/instructor/content-organizer?courseId=${course.courseId}" class="btn btn-primary btn-sm">
                                                        <i class="fas fa-layer-group"></i> Organize
                                                    </a>
                                                    <button type="button"
                                                            class="btn btn-secondary btn-sm"
                                                            onclick="openEditCourseModal(this)"
                                                            data-course-id="${course.courseId}"
                                                            data-course-name="<c:out value='${course.courseName}'/>"
                                                            data-course-fee="<c:out value='${course.courseFee}'/>"
                                                            data-category="<c:out value='${course.category}'/>"
                                                            data-level="<c:out value='${course.level}'/>"
                                                            data-duration="<c:out value='${course.duration}'/>"
                                                            data-description="<c:out value='${course.description}'/>"
                                                            data-course-banner="<c:out value='${course.courseBanner}'/>">
                                                        <i class="fas fa-edit"></i> Edit
                                                    </button>
                                                    <details class="more-actions" data-menu="course-actions">
                                                        <summary class="btn btn-secondary btn-sm" aria-label="Open more actions">
                                                            <i class="fas fa-ellipsis-h"></i> More
                                                        </summary>
                                                        <div class="more-actions-menu" role="menu" aria-label="Course actions menu">
                                                            <a href="${pageContext.request.contextPath}/instructor/materials?courseId=${course.courseId}" class="more-action-item">
                                                                <i class="fas fa-folder-open"></i> Materials
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${course.courseId}" class="more-action-item">
                                                                <i class="fas fa-clipboard-list"></i> Assessments
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/instructor/courses?action=students&courseId=${course.courseId}" class="more-action-item">
                                                                <i class="fas fa-users"></i> Students
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/instructor/courses?action=delete&id=${course.courseId}" 
                                                               class="more-action-item is-danger"
                                                               onclick="return confirm('Are you sure you want to delete this course?');">
                                                                <i class="fas fa-trash"></i> Delete
                                                            </a>
                                                        </div>
                                                    </details>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <div id="createCourseModal" class="create-course-modal" aria-hidden="true">
        <div class="create-course-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="createCourseModalTitle">
            <div class="create-course-modal-header">
                <div>
                    <p class="create-course-modal-kicker">Course Publishing</p>
                    <h3 id="createCourseModalTitle">Create New Course</h3>
                    <p>Set the core details, publish with a clean structure, and send for approval.</p>
                </div>
                <button type="button" class="create-course-modal-close" aria-label="Close create course modal" onclick="closeCreateCourseModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <form class="create-course-form" method="post" action="${pageContext.request.contextPath}/instructor/courses" enctype="multipart/form-data">
                <input type="hidden" name="action" value="create">
                <div class="form-feedback" data-feedback="create" hidden></div>

                <div class="create-course-grid">
                    <div class="field-group">
                        <label for="modalCourseName">Course Name *</label>
                        <input id="modalCourseName" name="courseName" type="text" required>
                        <small>Use a short, specific title learners can recognize quickly.</small>
                    </div>
                    <div class="field-group">
                        <label for="modalCourseFee">Course Fee (Naira) *</label>
                        <input id="modalCourseFee" name="courseFee" type="number" min="0" step="0.01" required>
                        <small>Set to 0 for a free course.</small>
                    </div>
                    <div class="field-group">
                        <label for="modalCategory">Category</label>
                        <input id="modalCategory" name="category" type="text" placeholder="e.g. Programming">
                    </div>
                    <div class="field-group">
                        <label for="modalLevel">Level</label>
                        <select id="modalLevel" name="level">
                            <option value="Beginner">Beginner</option>
                            <option value="Intermediate">Intermediate</option>
                            <option value="Advanced">Advanced</option>
                        </select>
                    </div>
                    <div class="field-group">
                        <label for="modalDuration">Duration (hours)</label>
                        <input id="modalDuration" name="duration" type="number" min="1">
                    </div>
                    <div class="field-group">
                        <label for="modalBanner">Course Banner</label>
                        <input id="modalBanner" name="courseBanner" type="file" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp">
                        <small>JPG, PNG, WEBP up to 5MB.</small>
                    </div>
                    <div class="field-group field-full">
                        <label for="modalDescription">Description</label>
                        <textarea id="modalDescription" name="description" rows="4"></textarea>
                    </div>
                </div>

                <div class="create-course-modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeCreateCourseModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Submit for Approval
                    </button>
                </div>
            </form>
        </div>
    </div>

    <div id="editCourseModal" class="create-course-modal" aria-hidden="true">
        <div class="create-course-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="editCourseModalTitle">
            <div class="create-course-modal-header">
                <div>
                    <p class="create-course-modal-kicker">Course Maintenance</p>
                    <h3 id="editCourseModalTitle">Edit Course</h3>
                    <p>Update core details and keep your catalog accurate and professional.</p>
                </div>
                <button type="button" class="create-course-modal-close" aria-label="Close edit course modal" onclick="closeEditCourseModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <form class="create-course-form" id="editCourseForm" method="post" action="${pageContext.request.contextPath}/instructor/courses" enctype="multipart/form-data">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="courseId" id="editCourseId">
                <div class="form-feedback" data-feedback="edit" hidden></div>

                <div class="create-course-grid">
                    <div class="field-group">
                        <label for="editCourseName">Course Name *</label>
                        <input id="editCourseName" name="courseName" type="text" required>
                    </div>
                    <div class="field-group">
                        <label for="editCourseFee">Course Fee (Naira) *</label>
                        <input id="editCourseFee" name="courseFee" type="number" min="0" step="0.01" required>
                    </div>
                    <div class="field-group">
                        <label for="editCategory">Category</label>
                        <input id="editCategory" name="category" type="text">
                    </div>
                    <div class="field-group">
                        <label for="editLevel">Level</label>
                        <select id="editLevel" name="level">
                            <option value="Beginner">Beginner</option>
                            <option value="Intermediate">Intermediate</option>
                            <option value="Advanced">Advanced</option>
                        </select>
                    </div>
                    <div class="field-group">
                        <label for="editDuration">Duration (hours)</label>
                        <input id="editDuration" name="duration" type="number" min="1">
                    </div>
                    <div class="field-group">
                        <label for="editBanner">Replace Banner</label>
                        <input id="editBanner" name="courseBanner" type="file" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp">
                        <small>Optional. Leave empty to keep current banner.</small>
                    </div>
                    <div class="field-group field-full" id="currentBannerWrap" hidden>
                        <label>Current Banner</label>
                        <img id="currentBannerPreview" class="current-banner-preview" alt="Current course banner">
                    </div>
                    <div class="field-group field-full">
                        <label for="editDescription">Description</label>
                        <textarea id="editDescription" name="description" rows="4"></textarea>
                    </div>
                </div>

                <div class="create-course-modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeEditCourseModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        (function () {
            const menus = Array.from(document.querySelectorAll('details[data-menu="course-actions"]'));
            const createModal = document.getElementById('createCourseModal');
            const editModal = document.getElementById('editCourseModal');

            const createForm = createModal ? createModal.querySelector('form') : null;
            const editForm = document.getElementById('editCourseForm');

            function lockBody(lock) {
                document.body.style.overflow = lock ? 'hidden' : '';
            }

            function setModalState(modal, open, focusSelector) {
                if (!modal) {
                    return;
                }
                if (open) {
                    modal.classList.add('is-open');
                    modal.setAttribute('aria-hidden', 'false');
                    lockBody(true);
                    if (focusSelector) {
                        const el = modal.querySelector(focusSelector);
                        if (el) {
                            el.focus();
                        }
                    }
                } else {
                    modal.classList.remove('is-open');
                    modal.setAttribute('aria-hidden', 'true');
                    lockBody(false);
                }
            }

            function showFeedback(form, message) {
                const box = form ? form.querySelector('.form-feedback') : null;
                if (!box) {
                    return;
                }
                box.textContent = message;
                box.hidden = false;
            }

            function clearFeedback(form) {
                const box = form ? form.querySelector('.form-feedback') : null;
                if (!box) {
                    return;
                }
                box.textContent = '';
                box.hidden = true;
            }

            function isSupportedBanner(fileName) {
                return /\.(jpg|jpeg|png|webp)$/i.test(fileName || '');
            }

            function validateCourseForm(form) {
                clearFeedback(form);
                const name = form.querySelector('input[name="courseName"]');
                const fee = form.querySelector('input[name="courseFee"]');
                const banner = form.querySelector('input[name="courseBanner"]');

                if (!name || !name.value.trim()) {
                    showFeedback(form, 'Course name is required.');
                    if (name) name.focus();
                    return false;
                }

                if (!fee || fee.value.trim() === '') {
                    showFeedback(form, 'Course fee is required.');
                    if (fee) fee.focus();
                    return false;
                }

                const feeNum = Number(fee.value);
                if (Number.isNaN(feeNum) || feeNum < 0) {
                    showFeedback(form, 'Course fee must be zero or a positive number.');
                    fee.focus();
                    return false;
                }

                if (banner && banner.files && banner.files[0]) {
                    const file = banner.files[0];
                    if (!isSupportedBanner(file.name)) {
                        showFeedback(form, 'Banner must be JPG, PNG, or WEBP.');
                        banner.focus();
                        return false;
                    }
                    if (file.size > 5 * 1024 * 1024) {
                        showFeedback(form, 'Banner file size must be 5MB or less.');
                        banner.focus();
                        return false;
                    }
                }

                return true;
            }

            window.openCreateCourseModal = function () {
                setModalState(createModal, true, '#modalCourseName');
            };

            window.closeCreateCourseModal = function () {
                setModalState(createModal, false);
            };

            window.openEditCourseModal = function (trigger) {
                if (!trigger || !editModal || !editForm) {
                    return;
                }
                clearFeedback(editForm);

                const byId = function (id) { return document.getElementById(id); };
                byId('editCourseId').value = trigger.dataset.courseId || '';
                byId('editCourseName').value = trigger.dataset.courseName || '';
                byId('editCourseFee').value = trigger.dataset.courseFee || '';
                byId('editCategory').value = trigger.dataset.category || '';
                byId('editLevel').value = trigger.dataset.level || 'Beginner';
                byId('editDuration').value = trigger.dataset.duration || '';
                byId('editDescription').value = trigger.dataset.description || '';
                byId('editBanner').value = '';

                const bannerWrap = byId('currentBannerWrap');
                const bannerPreview = byId('currentBannerPreview');
                const bannerSrc = trigger.dataset.courseBanner || '';
                if (bannerSrc && bannerPreview && bannerWrap) {
                    bannerPreview.src = bannerSrc;
                    bannerWrap.hidden = false;
                } else if (bannerWrap) {
                    bannerWrap.hidden = true;
                }

                setModalState(editModal, true, '#editCourseName');
            };

            window.closeEditCourseModal = function () {
                setModalState(editModal, false);
            };

            [createModal, editModal].forEach(function (modal) {
                if (!modal) {
                    return;
                }
                modal.addEventListener('click', function (event) {
                    if (event.target === modal) {
                        setModalState(modal, false);
                    }
                });
            });

            if (createForm) {
                createForm.addEventListener('submit', function (event) {
                    if (!validateCourseForm(createForm)) {
                        event.preventDefault();
                    }
                });
            }

            if (editForm) {
                editForm.addEventListener('submit', function (event) {
                    if (!validateCourseForm(editForm)) {
                        event.preventDefault();
                    }
                });
            }

            function closeOthers(current) {
                menus.forEach(function (menu) {
                    if (menu !== current) {
                        menu.removeAttribute('open');
                    }
                });
            }

            menus.forEach(function (menu) {
                const summary = menu.querySelector('summary');
                menu.addEventListener('toggle', function () {
                    if (menu.open) {
                        closeOthers(menu);
                    }
                });

                if (summary) {
                    summary.addEventListener('keydown', function (event) {
                        if (event.key === ' ' || event.key === 'Enter') {
                            event.preventDefault();
                            menu.open = !menu.open;
                        }
                        if (event.key === 'Escape') {
                            menu.removeAttribute('open');
                            summary.focus();
                        }
                    });
                }
            });

            document.addEventListener('click', function (event) {
                menus.forEach(function (menu) {
                    if (!menu.contains(event.target)) {
                        menu.removeAttribute('open');
                    }
                });
            });

            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                    menus.forEach(function (menu) {
                        menu.removeAttribute('open');
                    });
                    setModalState(createModal, false);
                    setModalState(editModal, false);
                }
            });
        })();
    </script>
</body>
</html>
