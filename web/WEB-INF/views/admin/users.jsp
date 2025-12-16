<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - PSM E-Learning</title>
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
        .user-table {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .badge-role {
            padding: 0.5em 1em;
            border-radius: 20px;
        }
        .role-Student { background-color: #28a745; color: white; }
        .role-Instructor { background-color: #17a2b8; color: white; }
        .role-Admin { background-color: #dc3545; color: white; }
        .status-Active { color: #28a745; }
        .status-Suspended { color: #dc3545; }
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
                            <a class="nav-link text-white active bg-white bg-opacity-25" href="${pageContext.request.contextPath}/admin/users">
                                <i class="fas fa-users me-2"></i> Users
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/courses">
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
                    <h2 class="mb-4">User Management</h2>

                    <!-- Success/Error Messages -->
                    <c:if test="${not empty sessionScope.success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            ${sessionScope.success}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="success" scope="session"/>
                    </c:if>
                    <c:if test="${not empty sessionScope.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${sessionScope.error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="error" scope="session"/>
                    </c:if>
                    <c:if test="${not empty sessionScope.warning}">
                        <div class="alert alert-warning alert-dismissible fade show" role="alert">
                            ${sessionScope.warning}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="warning" scope="session"/>
                    </c:if>

                    <!-- Filters and Search -->
                    <div class="card mb-4">
                        <div class="card-body">
                            <form method="get" action="${pageContext.request.contextPath}/admin/users" class="row g-3">
                                <div class="col-md-3">
                                    <label for="roleFilter" class="form-label">Role</label>
                                    <select name="role" id="roleFilter" class="form-select">
                                        <option value="">All Roles</option>
                                        <option value="Student" ${param.role == 'Student' ? 'selected' : ''}>Student</option>
                                        <option value="Instructor" ${param.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                                        <option value="Admin" ${param.role == 'Admin' ? 'selected' : ''}>Admin</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label for="statusFilter" class="form-label">Status</label>
                                    <select name="status" id="statusFilter" class="form-select">
                                        <option value="">All Statuses</option>
                                        <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                                        <option value="Suspended" ${param.status == 'Suspended' ? 'selected' : ''}>Suspended</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label for="searchQuery" class="form-label">Search</label>
                                    <input type="text" name="search" id="searchQuery" class="form-control" 
                                           placeholder="Search by name or email" value="${param.search}">
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="submit" class="btn btn-primary w-100">
                                        <i class="fas fa-search me-2"></i>Filter
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Create New User Button -->
                    <div class="mb-3">
                        <a href="${pageContext.request.contextPath}/admin/users?action=create" class="btn btn-success">
                            <i class="fas fa-plus me-2"></i>Create New User
                        </a>
                    </div>

                    <!-- Users Table -->
                    <div class="user-table p-4">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Full Name</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty users}">
                                            <tr>
                                                <td colspan="7" class="text-center text-muted py-4">
                                                    No users found
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${users}" var="user">
                                                <tr>
                                                    <td>${user.userId}</td>
                                                    <td>${user.fullName}</td>
                                                    <td>${user.email}</td>
                                                    <td>${user.phone}</td>
                                                    <td>
                                                        <span class="badge badge-role role-${user.role}">
                                                            ${user.role}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <i class="fas fa-circle status-${user.status}"></i>
                                                        ${user.status}
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/admin/users?action=edit&userId=${user.userId}" 
                                                           class="btn btn-sm btn-primary" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/admin/users?action=toggle-status&userId=${user.userId}" 
                                                           class="btn btn-sm btn-warning" title="Toggle Status"
                                                           onclick="return confirm('Toggle status for ${user.fullName}?')">
                                                            <i class="fas fa-toggle-on"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/admin/users?action=delete&userId=${user.userId}" 
                                                           class="btn btn-sm btn-danger" title="Delete"
                                                           onclick="return confirm('Are you sure you want to delete ${user.fullName}?')">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
