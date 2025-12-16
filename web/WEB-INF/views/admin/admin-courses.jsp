<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Management - PSM E-Learning</title>
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
        .course-table {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
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
                        <h4 class="text-white">PSM Admin</h4>
                        <p class="text-white-50">${sessionScope.userName}</p>
                    </div>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">
                                <i class="fas fa-home me-2"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/users">
                                <i class="fas fa-users me-2"></i> Users
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white active bg-white bg-opacity-25" href="${pageContext.request.contextPath}/admin/courses">
                                <i class="fas fa-book me-2"></i> Courses
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
                    <h2 class="mb-4">Course Management</h2>

                    <!-- Success/Error Messages -->
                    <c:if test="${param.success == 'approved'}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            Course approved successfully!
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${param.success == 'rejected'}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            Course rejected successfully!
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

                    <!-- Filter Buttons -->
                    <div class="mb-4">
                        <div class="btn-group" role="group">
                            <a href="${pageContext.request.contextPath}/admin/courses" 
                               class="btn ${empty statusFilter ? 'btn-primary' : 'btn-outline-primary'}">
                                All Courses
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/courses?status=Pending" 
                               class="btn ${statusFilter == 'Pending' ? 'btn-warning' : 'btn-outline-warning'}">
                                Pending
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/courses?status=Approved" 
                               class="btn ${statusFilter == 'Approved' ? 'btn-success' : 'btn-outline-success'}">
                                Approved
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/courses?status=Archived" 
                               class="btn ${statusFilter == 'Archived' ? 'btn-secondary' : 'btn-outline-secondary'}">
                                Archived
                            </a>
                        </div>
                    </div>

                    <!-- Courses Table -->
                    <div class="course-table p-4">
                        <c:choose>
                            <c:when test="${empty courses}">
                                <div class="alert alert-info text-center">
                                    <i class="fas fa-info-circle me-2"></i>
                                    No courses found.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Course Name</th>
                                                <th>Category</th>
                                                <th>Level</th>
                                                <th>Duration</th>
                                                <th>Fee</th>
                                                <th>Status</th>
                                                <th>Created</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="course" items="${courses}">
                                                <tr>
                                                    <td>
                                                        <strong>${course.courseName}</strong>
                                                        <c:if test="${not empty course.description}">
                                                            <br><small class="text-muted">
                                                                ${course.description.length() > 50 ? 
                                                                  course.description.substring(0, 50).concat('...') : course.description}
                                                            </small>
                                                        </c:if>
                                                    </td>
                                                    <td>${course.category}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${course.level == 'Beginner'}">
                                                                <span class="badge bg-success">${course.level}</span>
                                                            </c:when>
                                                            <c:when test="${course.level == 'Intermediate'}">
                                                                <span class="badge bg-warning text-dark">${course.level}</span>
                                                            </c:when>
                                                            <c:when test="${course.level == 'Advanced'}">
                                                                <span class="badge bg-danger">${course.level}</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td>${course.duration} hrs</td>
                                                    <td><fmt:formatNumber value="${course.courseFee}" type="currency"/></td>
                                                    <td><span class="badge status-${course.status}">${course.status}</span></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty course.createdAt}">
                                                                ${course.createdAt.toString().substring(0, 10)}
                                                            </c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${course.status == 'Pending'}">
                                                            <a href="${pageContext.request.contextPath}/admin/courses?action=approve&id=${course.courseId}" 
                                                               class="btn btn-sm btn-success" 
                                                               onclick="return confirm('Approve this course?');">
                                                                <i class="fas fa-check"></i> Approve
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/admin/courses?action=reject&id=${course.courseId}" 
                                                               class="btn btn-sm btn-danger" 
                                                               onclick="return confirm('Reject this course?');">
                                                                <i class="fas fa-times"></i> Reject
                                                            </a>
                                                        </c:if>
                                                        <c:if test="${course.status != 'Pending'}">
                                                            <span class="text-muted">No action</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
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
