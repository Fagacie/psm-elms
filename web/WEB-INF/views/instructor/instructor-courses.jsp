<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - PSM E-Learning</title>
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
        .course-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .course-card:hover {
            transform: translateY(-5px);
        }
        .status-Pending { background-color: #ffc107; color: #000; }
        .status-Approved { background-color: #28a745; color: white; }
        .status-Archived { background-color: #6c757d; color: white; }
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
                        <h2>My Courses</h2>
                        <a href="${pageContext.request.contextPath}/instructor/courses?action=create" class="btn btn-primary">
                            <i class="fas fa-plus me-2"></i> Create New Course
                        </a>
                    </div>

                    <!-- Success/Error Messages -->
                    <c:if test="${param.success == 'created'}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            Course created successfully! Pending admin approval.
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${param.success == 'updated'}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            Course updated successfully!
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${param.success == 'deleted'}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            Course deleted successfully!
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${param.error != null}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            An error occurred. Please try again.
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Courses Grid -->
                    <div class="row">
                        <c:choose>
                            <c:when test="${empty courses}">
                                <div class="col-12">
                                    <div class="alert alert-info text-center">
                                        <i class="fas fa-info-circle me-2"></i>
                                        You haven't created any courses yet. Click "Create New Course" to get started.
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="course" items="${courses}">
                                    <div class="col-md-6 col-lg-4 mb-4">
                                        <div class="card course-card h-100">
                                            <div class="card-body">
                                                <div class="d-flex justify-content-between align-items-start mb-3">
                                                    <h5 class="card-title">${course.courseName}</h5>
                                                    <span class="badge status-${course.status}">${course.status}</span>
                                                </div>
                                                <p class="card-text text-muted small">
                                                    ${course.description != null && course.description.length() > 100 ? 
                                                      course.description.substring(0, 100).concat('...') : course.description}
                                                </p>
                                                <ul class="list-unstyled">
                                                    <li><i class="fas fa-layer-group text-primary me-2"></i> ${course.category}</li>
                                                    <li><i class="fas fa-signal text-success me-2"></i> ${course.level}</li>
                                                    <li><i class="fas fa-clock text-info me-2"></i> ${course.duration} hours</li>
                                                    <li><i class="fas fa-dollar-sign text-warning me-2"></i> 
                                                        <fmt:formatNumber value="${course.courseFee}" type="currency"/>
                                                    </li>
                                                </ul>
                                                <div class="mt-3">
                                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=edit&id=${course.courseId}" 
                                                       class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-edit me-1"></i> Edit
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/instructor/courses?action=delete&id=${course.courseId}" 
                                                       class="btn btn-sm btn-outline-danger" 
                                                       onclick="return confirm('Are you sure you want to delete this course?');">
                                                        <i class="fas fa-trash me-1"></i> Delete
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
