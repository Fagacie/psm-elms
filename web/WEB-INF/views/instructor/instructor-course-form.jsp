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
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
    <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
        <jsp:param name="pageTitle" value="${mode == 'create' ? 'Create New Course' : 'Edit Course'}"/>
        <jsp:param name="pageSubtitle" value="Build and update course details cleanly"/>
    </jsp:include>

    <c:set var="activeInstructorPage" value="courses"/>
    <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

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
                </div>
            </section>

            <section class="ins-hero-card">
                <div class="ins-hero-grid">
                    <div>
                        <h3>${mode == 'create' ? 'Publishing checklist' : 'Editing checklist'}</h3>
                    </div>
                    <div class="ins-hero-metrics">
                        <div class="ins-metric">
                            <strong>${mode == 'create' ? 'Draft' : 'Live Edit'}</strong>
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
                                <small class="text-muted">Set 0 for a free course (students enroll without payment).</small>
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
                                <label for="duration">Duration</label>
                                <div class="duration-combo">
                                    <input type="number" id="duration" name="duration" class="form-input" min="1" value="${course != null ? course.durationValueForDisplay : ''}">
                                    <select id="durationUnit" name="durationUnit" class="form-select">
                                        <option value="days" ${course != null && course.durationUnitGuess == 'days' ? 'selected' : ''}>Days</option>
                                        <option value="weeks" ${course != null && course.durationUnitGuess == 'weeks' ? 'selected' : ''}>Weeks</option>
                                        <option value="months" ${course != null && course.durationUnitGuess == 'months' ? 'selected' : ''}>Months</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="courseBanner">Course Banner (JPG, PNG, WEBP)</label>
                            <input type="file" id="courseBanner" name="courseBanner" class="form-input" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp">
                            <small class="text-muted">Recommended size: 1280x720. Max: 5MB.</small>
                            <c:if test="${mode == 'edit' && not empty course.courseBanner}">
                                <div style="margin-top:12px;">
                                    <img src="${course.courseBanner}" alt="Current course banner" class="course-banner-preview">
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

