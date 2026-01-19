<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${mode == 'create' ? 'Create' : 'Edit'} Course - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-course-form.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <!-- Top Navigation Bar -->
    <header class="app-header">
        <div class="header-left">
            <div class="logo-section">
                <i class="fas fa-graduation-cap"></i>
                <span>PSM E-Learning</span>
            </div>
            <h1 class="page-title">${mode == 'create' ? 'Create New Course' : 'Edit Course'}</h1>
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
                <span>My Courses</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/assignments" class="nav-item">
                <i class="fas fa-tasks"></i>
                <span>Assignments</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/quizzes" class="nav-item">
                <i class="fas fa-clipboard-question"></i>
                <span>Quizzes / Exams</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/submissions" class="nav-item">
                <i class="fas fa-inbox"></i>
                <span>Student Submissions</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/grades" class="nav-item">
                <i class="fas fa-chart-line"></i>
                <span>Grades / Evaluation</span>
            </a>
            <a href="${pageContext.request.contextPath}/instructor/announcements" class="nav-item">
                <i class="fas fa-bullhorn"></i>
                <span>Announcements</span>
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
                <form method="post" action="${pageContext.request.contextPath}/instructor/courses" class="course-form">
                    <input type="hidden" name="action" value="${mode == 'create' ? 'create' : 'update'}">
                    <c:if test="${mode == 'edit'}">
                        <input type="hidden" name="courseId" value="${course.courseId}">
                    </c:if>

                    <!-- Course Name & Fee Row -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="courseName">Course Name <span class="required">*</span></label>
                            <input type="text" id="courseName" name="courseName" class="form-input" 
                                   value="${course != null ? course.courseName : ''}" required>
                        </div>
                        <div class="form-group">
                            <label for="courseFee">Course Fee (₦) <span class="required">*</span></label>
                            <input type="number" id="courseFee" name="courseFee" class="form-input" 
                                   step="0.01" min="0" 
                                   value="${course != null ? course.courseFee : ''}" required>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" class="form-textarea" rows="5">${course != null ? course.description : ''}</textarea>
                    </div>

                    <!-- Category, Level, Duration Row -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="category">Category</label>
                            <input type="text" id="category" name="category" class="form-input" 
                                   value="${course != null ? course.category : ''}"
                                   placeholder="e.g., Programming, Design, Business">
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
                            <input type="number" id="duration" name="duration" class="form-input" 
                                   min="1" value="${course != null ? course.duration : ''}">
                        </div>
                    </div>

                    <!-- Status Warning -->
                    <c:if test="${mode == 'edit' && course.status == 'Approved'}">
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle"></i>
                            <span>Editing an approved course will reset its status to "Pending" and require admin re-approval.</span>
                        </div>
                    </c:if>

                    <!-- Form Actions -->
                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                            Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i>
                            ${mode == 'create' ? 'Submit for Approval' : 'Save Changes'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>
