<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Courses - PSM E-Learning</title>
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
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
            transition: all 0.3s;
            height: 100%;
        }
        .course-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 5px 30px rgba(0,0,0,0.2);
        }
        .course-badge {
            position: absolute;
            top: 15px;
            right: 15px;
        }
        .price-tag {
            font-size: 1.5rem;
            font-weight: bold;
            color: #28a745;
        }
        .search-filter-section {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
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
                    <h2 class="mb-4">Available Courses</h2>

                    <!-- Error Messages -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Search and Filter Section -->
                    <div class="search-filter-section">
                        <form method="get" action="${pageContext.request.contextPath}/student/courses">
                            <div class="row">
                                <!-- Search -->
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Search Courses</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control" name="keyword" 
                                               placeholder="Search by name, category..." value="${searchKeyword}">
                                        <button class="btn btn-primary" type="submit" name="action" value="search">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </div>

                                <!-- Category Filter -->
                                <div class="col-md-2 mb-3">
                                    <label class="form-label">Category</label>
                                    <input type="text" class="form-control" name="category" 
                                           placeholder="e.g., Programming" value="${filterCategory}">
                                </div>

                                <!-- Level Filter -->
                                <div class="col-md-2 mb-3">
                                    <label class="form-label">Level</label>
                                    <select class="form-select" name="level">
                                        <option value="">All Levels</option>
                                        <option value="Beginner" ${filterLevel == 'Beginner' ? 'selected' : ''}>Beginner</option>
                                        <option value="Intermediate" ${filterLevel == 'Intermediate' ? 'selected' : ''}>Intermediate</option>
                                        <option value="Advanced" ${filterLevel == 'Advanced' ? 'selected' : ''}>Advanced</option>
                                    </select>
                                </div>

                                <!-- Fee Range -->
                                <div class="col-md-2 mb-3">
                                    <label class="form-label">Min Fee ($)</label>
                                    <input type="number" class="form-control" name="minFee" 
                                           step="0.01" min="0" value="${filterMinFee}">
                                </div>

                                <div class="col-md-2 mb-3">
                                    <label class="form-label">Max Fee ($)</label>
                                    <input type="number" class="form-control" name="maxFee" 
                                           step="0.01" min="0" value="${filterMaxFee}">
                                </div>
                            </div>
                            <div class="d-flex justify-content-end gap-2">
                                <button type="submit" name="action" value="filter" class="btn btn-primary">
                                    <i class="fas fa-filter me-2"></i> Apply Filters
                                </button>
                                <a href="${pageContext.request.contextPath}/student/courses" class="btn btn-secondary">
                                    <i class="fas fa-redo me-2"></i> Clear
                                </a>
                            </div>
                        </form>
                    </div>

                    <!-- Courses Grid -->
                    <c:choose>
                        <c:when test="${empty courses}">
                            <div class="alert alert-info text-center">
                                <i class="fas fa-info-circle me-2"></i>
                                No courses available at the moment.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row">
                                <c:forEach var="course" items="${courses}">
                                    <div class="col-md-6 col-lg-4 mb-4">
                                        <div class="card course-card">
                                            <div class="card-body position-relative">
                                                <span class="badge course-badge bg-${course.level == 'Beginner' ? 'success' : (course.level == 'Intermediate' ? 'warning' : 'danger')}">
                                                    ${course.level}
                                                </span>
                                                <h5 class="card-title mt-3">${course.courseName}</h5>
                                                <p class="card-text text-muted">
                                                    ${course.description != null && course.description.length() > 120 ? 
                                                      course.description.substring(0, 120).concat('...') : course.description}
                                                </p>
                                                <ul class="list-unstyled">
                                                    <li><i class="fas fa-layer-group text-primary me-2"></i> ${course.category}</li>
                                                    <li><i class="fas fa-clock text-info me-2"></i> ${course.duration} hours</li>
                                                </ul>
                                                <div class="d-flex justify-content-between align-items-center mt-3">
                                                    <div class="price-tag">
                                                        <fmt:formatNumber value="${course.courseFee}" type="currency"/>
                                                    </div>
                                                    <a href="${pageContext.request.contextPath}/student/courses?action=details&id=${course.courseId}" 
                                                       class="btn btn-primary">
                                                        View Details <i class="fas fa-arrow-right ms-2"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
