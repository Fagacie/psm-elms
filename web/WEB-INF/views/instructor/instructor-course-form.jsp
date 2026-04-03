<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${mode == 'create' ? 'Create' : 'Edit'} Course - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-course-form.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="instructor-ui">
    <!-- Top Navigation Bar -->
    <header class="app-header">
        <div class="header-left">
            <a href="${pageContext.request.contextPath}/dashboard" class="dashboard-brand" aria-label="PSM E-Learning home">
                <span class="dashboard-brand-main">PSM</span>
                <span class="dashboard-brand-sub">E-Learning</span>
            </a>
            <div class="dashboard-title-copy">
                <h1 class="page-title">${mode == 'create' ? 'Create New Course' : 'Edit Course'}</h1>
                <p>Build and update course details cleanly</p>
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

    <!-- Left Sidebar Navigation -->
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

    <!-- Main Content Area -->
    <main class="app-main">
        <div class="content-wrapper">
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
                <span>&gt;</span>
                <span>Course Form</span>
            </nav>

            <section class="ins-page-head">
                <div>
                    <p class="ins-page-kicker">Course Editor</p>
                    <h2>${mode == 'create' ? 'Create a course students will want to open' : 'Refine the course workspace and presentation'}</h2>
                    <p>${mode == 'create' ? 'Set the title, banner, pricing, level, and teaching context cleanly from one form. This page should feel like a proper publishing studio, not a raw admin form.' : 'Update the metadata, banner, and learning details while keeping the course approval flow clear.'}</p>
                </div>
            </section>

            <section class="ins-hero-card">
                <div class="ins-hero-grid">
                    <div>
                        <h3>${mode == 'create' ? 'Publishing checklist' : 'Editing checklist'}</h3>
                        <p>Use a strong title, a clean banner, the correct level, and accurate pricing. Those four details shape how professional the student-facing catalog feels.</p>
                    </div>
                    <div class="ins-hero-metrics">
                        <div class="ins-metric">
                            <strong>${mode == 'create' ? 'Draft' : 'Live Edit'}</strong>
                            <span>Current workflow state</span>
                        </div>
                        <div class="ins-metric">
                            <strong>Banner</strong>
                            <span>JPG, PNG, WEBP up to 5MB</span>
                        </div>
                        <div class="ins-metric">
                            <strong>Pricing</strong>
                            <span>Keep catalog display accurate</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${mode == 'edit' && course.status == 'Approved' ? 'Re-Approval' : 'Submit'}</strong>
                            <span>${mode == 'edit' && course.status == 'Approved' ? 'Changes return course to pending review' : 'Ready for course publishing'}</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Breadcrumb Navigation -->
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/instructor/courses">
                    <i class="fas fa-arrow-left"></i> Back to Courses
                </a>
            </div>

            <!-- Error Messages -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <!-- Course Form -->
            <div class="form-section">
                <div class="form-header">
                    <h2>${mode == 'create' ? 'Create New Course' : 'Update Course'}</h2>
                    <p class="form-description">${mode == 'create' ? 'Fill in the course details below. Your course will be submitted for admin approval.' : 'Update the course information. Changes to approved courses require re-approval.'}</p>
                </div>
                
                <div class="form-card">
                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses" enctype="multipart/form-data" class="course-form">
                        <input type="hidden" name="action" value="${mode == 'create' ? 'create' : 'update'}">
                        <c:if test="${mode == 'edit'}">
                            <input type="hidden" name="courseId" value="${course.courseId}">
                        </c:if>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="courseName">Course Name <span class="required">*</span></label>
                                <input type="text" id="courseName" name="courseName" class="form-input" value="${course != null ? course.courseName : ''}" required>
                            </div>
                            <div class="form-group">
                                <label for="courseFee">Course Fee (₦) <span class="required">*</span></label>
                                <input type="number" id="courseFee" name="courseFee" class="form-input" step="0.01" min="0" value="${course != null ? course.courseFee : ''}" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea id="description" name="description" class="form-textarea" rows="5">${course != null ? course.description : ''}</textarea>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="category">Category</label>
                                <input type="text" id="category" name="category" class="form-input" value="${course != null ? course.category : ''}" placeholder="e.g., Programming, Design, Business">
                            </div>
                            <div class="form-group">
                                <label for="level">Level</label>
                                <select id="level" name="level" class="form-select">
                                    <option value="Beginner" ${course != null && course.level == 'Beginner' ? 'selected' : ''}>Beginner</option>
                                    <option value="Intermediate" ${course != null && course.level == 'Intermediate' ? 'selected' : ''}>Intermediate</option>
                                    <option value="Advanced" ${course != null && course.level == 'Advanced' ? 'selected' : ''}>Advanced</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="duration">Duration (hours)</label>
                                <input type="number" id="duration" name="duration" class="form-input" min="1" value="${course != null ? course.duration : ''}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="courseBanner">Course Banner (JPG, PNG, WEBP)</label>
                            <input type="file" id="courseBanner" name="courseBanner" class="form-input" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp">
                            <small class="text-muted">Recommended size: 1280x720. Max: 5MB.</small>
                            <c:if test="${mode == 'edit' && not empty course.courseBanner}">
                                <div style="margin-top:12px;">
                                    <img src="${course.courseBanner}" alt="Current course banner" style="max-width:320px; width:100%; border:1px solid #ddd; border-radius:12px;">
                                </div>
                            </c:if>
                        </div>

                        <c:if test="${mode == 'edit' && course.status == 'Approved'}">
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle"></i>
                                <span>Editing an approved course will reset its status to "Pending" and require admin re-approval.</span>
                            </div>
                        </c:if>

                        <div class="form-actions">
                            <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i>
                                ${mode == 'create' ? 'Submit for Approval' : 'Save Changes'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</body>
</html>

