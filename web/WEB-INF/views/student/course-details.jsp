<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${course.courseName} - PSM E-Learning</title>
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
        .course-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 0 30px rgba(0,0,0,0.2);
        }
        .course-details-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
            padding: 30px;
        }
        .info-item {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            font-size: 1.1rem;
        }
        .info-item i {
            width: 30px;
            margin-right: 15px;
        }
        .price-display {
            font-size: 2.5rem;
            font-weight: bold;
            color: #28a745;
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
                        <h4 class="text-white">PSM Student</h4>
                        <p class="text-white-50">${sessionScope.userName}</p>
                    </div>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">
                                <i class="fas fa-home me-2"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white active bg-white bg-opacity-25" href="${pageContext.request.contextPath}/student/courses">
                                <i class="fas fa-book me-2"></i> Browse Courses
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/student/my-enrollments">
                                <i class="fas fa-graduation-cap me-2"></i> My Enrollments
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
                    <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-secondary mb-3">
                        <i class="fas fa-arrow-left me-2"></i> Back to Courses
                    </a>

                    <!-- Course Header -->
                    <div class="course-header mb-4">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <h1 class="display-5 mb-3">${course.courseName}</h1>
                                <div class="d-flex gap-3 mb-3">
                                    <span class="badge bg-light text-dark fs-6">${course.category}</span>
                                    <span class="badge ${course.level == 'Beginner' ? 'bg-success' : (course.level == 'Intermediate' ? 'bg-warning' : 'bg-danger')} fs-6">
                                        ${course.level}
                                    </span>
                                </div>
                            </div>
                            <div class="col-md-4 text-md-end">
                                <div class="price-display mb-3">
                                    <fmt:formatNumber value="${course.courseFee}" type="currency"/>
                                </div>
                                <a href="${pageContext.request.contextPath}/student/enrollment-summary?courseId=${course.courseId}" class="btn btn-success btn-lg w-100">
                                    <i class="fas fa-check-circle me-2"></i>Enroll Now
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Course Details -->
                    <div class="row">
                        <div class="col-md-8 mb-4">
                            <div class="course-details-card">
                                <h3 class="mb-4">Course Description</h3>
                                <p class="lead">${course.description}</p>

                                <hr class="my-4">

                                <h4 class="mb-3">What you'll learn</h4>
                                <ul class="list-unstyled">
                                    <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i> Comprehensive understanding of ${course.courseName}</li>
                                    <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i> Practical skills for ${course.level} level learners</li>
                                    <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i> Real-world applications in ${course.category}</li>
                                    <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i> Certificate of completion</li>
                                </ul>
                            </div>
                        </div>

                        <div class="col-md-4">
                            <div class="course-details-card">
                                <h4 class="mb-4">Course Information</h4>
                                
                                <div class="info-item">
                                    <i class="fas fa-clock text-primary"></i>
                                    <div>
                                        <strong>Duration</strong><br>
                                        ${course.duration} hours
                                    </div>
                                </div>

                                <div class="info-item">
                                    <i class="fas fa-signal text-success"></i>
                                    <div>
                                        <strong>Difficulty Level</strong><br>
                                        ${course.level}
                                    </div>
                                </div>

                                <div class="info-item">
                                    <i class="fas fa-layer-group text-info"></i>
                                    <div>
                                        <strong>Category</strong><br>
                                        ${course.category}
                                    </div>
                                </div>

                                <div class="info-item">
                                    <i class="fas fa-calendar text-warning"></i>
                                    <div>
                                        <strong>Created</strong><br>
                                        <c:choose>
                                            <c:when test="${not empty course.createdAt}">
                                                ${course.createdAt.toString().substring(0, 10)}
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <c:if test="${course.updatedAt != null}">
                                    <div class="info-item">
                                        <i class="fas fa-sync text-secondary"></i>
                                        <div>
                                            <strong>Last Updated</strong><br>
                                            ${course.updatedAt.toString().substring(0, 10)}
                                        </div>
                                    </div>
                                </c:if>

                                <hr class="my-4">

                                <div class="d-grid gap-2">
                                    <button class="btn btn-primary btn-lg" disabled>
                                        <i class="fas fa-play-circle me-2"></i> Start Learning (Coming Soon)
                                    </button>
                                    <button class="btn btn-outline-secondary" disabled>
                                        <i class="fas fa-heart me-2"></i> Add to Wishlist (Coming Soon)
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
