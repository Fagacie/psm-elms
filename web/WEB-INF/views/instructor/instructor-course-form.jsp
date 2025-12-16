<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${mode == 'create' ? 'Create' : 'Edit'} Course - PSM E-Learning</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .main-content {
            min-height: 100vh;
            background-color: #f8f9fa;
        }
        .form-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            padding: 30px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-2 d-md-block sidebar p-0">
                <div class="position-sticky pt-3">
                    <div class="text-center mb-4">
                        <h4 class="text-white">PSM Instructor</h4>
                        <p class="text-white-50">${sessionScope.userName}</p>
                    </div>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">
                                <i class="fas fa-home me-2"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white active bg-white bg-opacity-25" href="${pageContext.request.contextPath}/instructor/courses">
                                <i class="fas fa-book me-2"></i> My Courses
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">
                                <i class="fas fa-user me-2"></i> Profile
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/logout">
                                <i class="fas fa-sign-out-alt me-2"></i> Logout
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-10 ms-sm-auto px-md-4 main-content">
                <div class="py-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2>${mode == 'create' ? 'Create New Course' : 'Edit Course'}</h2>
                        <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-2"></i> Back to Courses
                        </a>
                    </div>

                    <!-- Error Messages -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Course Form -->
                    <div class="form-container">
                        <form method="post" action="${pageContext.request.contextPath}/instructor/courses">
                            <input type="hidden" name="action" value="${mode == 'create' ? 'create' : 'update'}">
                            <c:if test="${mode == 'edit'}">
                                <input type="hidden" name="courseId" value="${course.courseId}">
                            </c:if>

                            <div class="row">
                                <div class="col-md-8 mb-3">
                                    <label for="courseName" class="form-label">Course Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="courseName" name="courseName" 
                                           value="${course != null ? course.courseName : ''}" required>
                                </div>

                                <div class="col-md-4 mb-3">
                                    <label for="courseFee" class="form-label">Course Fee ($) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="courseFee" name="courseFee" 
                                           step="0.01" min="0" value="${course != null ? course.courseFee : ''}" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="description" class="form-label">Description</label>
                                <textarea class="form-control" id="description" name="description" rows="4">${course != null ? course.description : ''}</textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label for="category" class="form-label">Category</label>
                                    <input type="text" class="form-control" id="category" name="category" 
                                           value="${course != null ? course.category : ''}" 
                                           placeholder="e.g., Programming, Design, Business">
                                </div>

                                <div class="col-md-4 mb-3">
                                    <label for="level" class="form-label">Level</label>
                                    <select class="form-select" id="level" name="level">
                                        <option value="Beginner" ${course != null && course.level == 'Beginner' ? 'selected' : ''}>Beginner</option>
                                        <option value="Intermediate" ${course != null && course.level == 'Intermediate' ? 'selected' : ''}>Intermediate</option>
                                        <option value="Advanced" ${course != null && course.level == 'Advanced' ? 'selected' : ''}>Advanced</option>
                                    </select>
                                </div>

                                <div class="col-md-4 mb-3">
                                    <label for="duration" class="form-label">Duration (hours)</label>
                                    <input type="number" class="form-control" id="duration" name="duration" 
                                           min="1" value="${course != null ? course.duration : ''}">
                                </div>
                            </div>

                            <c:if test="${mode == 'edit' && course.status == 'Approved'}">
                                <div class="alert alert-warning" role="alert">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    Note: Editing an approved course will reset its status to "Pending" and require admin re-approval.
                                </div>
                            </c:if>

                            <div class="d-flex justify-content-end gap-2">
                                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-secondary">Cancel</a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save me-2"></i> ${mode == 'create' ? 'Create Course' : 'Update Course'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
