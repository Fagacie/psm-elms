<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty user ? 'Create' : 'Edit'} User - PSM E-Learning</title>
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
        .form-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .role-specific-fields {
            display: none;
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
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2>${empty user ? 'Create New' : 'Edit'} User</h2>
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-2"></i>Back to List
                        </a>
                    </div>

                    <!-- Success/Error Messages -->
                    <c:if test="${not empty sessionScope.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${sessionScope.error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="error" scope="session"/>
                    </c:if>

                    <!-- User Form -->
                    <div class="form-card p-4">
                        <form method="post" action="${pageContext.request.contextPath}/admin/users">
                            <c:if test="${not empty requestScope.user}">
                                <input type="hidden" name="userId" value="${requestScope.user.userId}">
                                <input type="hidden" name="action" value="edit">
                            </c:if>
                            <c:if test="${empty requestScope.user}">
                                <input type="hidden" name="action" value="create">
                            </c:if>

                            <!-- Common Fields -->
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="fullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" 
                                           value="${requestScope.user.fullName}" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                                    <input type="email" class="form-control" id="email" name="email" 
                                           value="${requestScope.user.email}" ${not empty requestScope.user ? 'readonly' : ''} required>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="phone" class="form-label">Phone</label>
                                    <input type="tel" class="form-control" id="phone" name="phone" value="${requestScope.user.phone}">
                                </div>
                                <div class="col-md-6">
                                    <label for="password" class="form-label">
                                        Password ${empty requestScope.user ? '<span class="text-danger">*</span>' : '(leave blank to keep current)'}
                                    </label>
                                    <input type="password" class="form-control" id="password" name="password" 
                                           ${empty requestScope.user ? 'required' : ''}>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="role" class="form-label">Role <span class="text-danger">*</span></label>
                                    <select class="form-select" id="role" name="role" required>
                                        <option value="">Select Role</option>
                                        <option value="Student" ${not empty requestScope.user && requestScope.user.role == 'Student' ? 'selected' : ''}>Student</option>
                                        <option value="Instructor" ${not empty requestScope.user && requestScope.user.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                                        <option value="Admin" ${not empty requestScope.user && requestScope.user.role == 'Admin' ? 'selected' : ''}>Admin</option>
                                    </select>
                                    <c:if test="${not empty requestScope.user}">
                                        <small class="text-muted">Role cannot be changed after creation</small>
                                    </c:if>
                                </div>
                                <c:if test="${empty requestScope.user}">
                                    <div class="col-md-6">
                                        <label for="status" class="form-label">Status</label>
                                        <select class="form-select" id="status" name="status">
                                            <option value="Active" selected>Active</option>
                                            <option value="Suspended">Suspended</option>
                                        </select>
                                    </div>
                                </c:if>
                            </div>

                            <!-- Student Specific Fields -->
                            <div id="studentFields" class="role-specific-fields">
                                <h5 class="mt-4 mb-3">Student Information</h5>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="qualification" class="form-label">Qualification</label>
                                        <input type="text" class="form-control" id="qualification" name="qualification" 
                                               value="${student.qualification}">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="country" class="form-label">Country</label>
                                        <input type="text" class="form-control" id="country" name="country" 
                                               value="${student.country}">
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="state" class="form-label">State</label>
                                        <input type="text" class="form-control" id="state" name="state" 
                                               value="${student.state}">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="dob" class="form-label">Date of Birth</label>
                                        <input type="date" class="form-control" id="dob" name="dob" 
                                               value="${student.dob}">
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="gender" class="form-label">Gender</label>
                                        <select class="form-select" id="gender" name="gender">
                                            <option value="">Select Gender</option>
                                            <option value="Male" ${student.gender == 'Male' ? 'selected' : ''}>Male</option>
                                            <option value="Female" ${student.gender == 'Female' ? 'selected' : ''}>Female</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="emergencyContact" class="form-label">Emergency Contact</label>
                                        <input type="text" class="form-control" id="emergencyContact" name="emergencyContact" 
                                               value="${student.emergencyContact}">
                                    </div>
                                </div>
                            </div>

                            <!-- Instructor Specific Fields -->
                            <div id="instructorFields" class="role-specific-fields">
                                <h5 class="mt-4 mb-3">Instructor Information</h5>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="specialization" class="form-label">Specialization</label>
                                        <input type="text" class="form-control" id="specialization" name="specialization" 
                                               value="${instructor.specialization}">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="certification" class="form-label">Certification</label>
                                        <input type="text" class="form-control" id="certification" name="certification" 
                                               value="${instructor.certification}">
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="yearsOfExperience" class="form-label">Years of Experience</label>
                                        <input type="number" class="form-control" id="yearsOfExperience" name="yearsOfExperience" 
                                               value="${instructor.yearsOfExperience}" min="0">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="hireDate" class="form-label">Hire Date</label>
                                        <input type="date" class="form-control" id="hireDate" name="hireDate" 
                                               value="${instructor.hireDate}">
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label for="bio" class="form-label">Bio</label>
                                    <textarea class="form-control" id="bio" name="bio" rows="3">${instructor.bio}</textarea>
                                </div>
                            </div>

                            <!-- Admin Specific Fields -->
                            <div id="adminFields" class="role-specific-fields">
                                <h5 class="mt-4 mb-3">Admin Information</h5>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="position" class="form-label">Position</label>
                                        <input type="text" class="form-control" id="position" name="position" 
                                               value="${admin.position}">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="permissionLevel" class="form-label">Permission Level</label>
                                        <select class="form-select" id="permissionLevel" name="permissionLevel">
                                            <option value="SuperAdmin" ${admin.permissionLevel == 'SuperAdmin' ? 'selected' : ''}>Super Admin</option>
                                            <option value="Admin" ${admin.permissionLevel == 'Admin' ? 'selected' : ''}>Admin</option>
                                            <option value="Moderator" ${admin.permissionLevel == 'Moderator' ? 'selected' : ''}>Moderator</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label for="assignedDepartment" class="form-label">Assigned Department</label>
                                    <input type="text" class="form-control" id="assignedDepartment" name="assignedDepartment" 
                                           value="${admin.assignedDepartment}">
                                </div>
                            </div>

                            <!-- Submit Button -->
                            <div class="mt-4">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save me-2"></i>${empty user ? 'Create User' : 'Update User'}
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                                    Cancel
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Show/hide role-specific fields based on selected role
        document.addEventListener('DOMContentLoaded', function() {
            const roleSelect = document.getElementById('role');
            const studentFields = document.getElementById('studentFields');
            const instructorFields = document.getElementById('instructorFields');
            const adminFields = document.getElementById('adminFields');
            const isEditMode = ${not empty requestScope.user ? 'true' : 'false'};

            function updateRoleFields() {
                const selectedRole = roleSelect.value;
                
                // Hide all fields first
                studentFields.style.display = 'none';
                instructorFields.style.display = 'none';
                adminFields.style.display = 'none';

                // Show relevant fields based on selection
                if (selectedRole === 'Student') {
                    studentFields.style.display = 'block';
                } else if (selectedRole === 'Instructor') {
                    instructorFields.style.display = 'block';
                } else if (selectedRole === 'Admin') {
                    adminFields.style.display = 'block';
                }
            }

            // Listen for role changes (only if not in edit mode)
            if (!isEditMode) {
                roleSelect.addEventListener('change', updateRoleFields);
            } else {
                // In edit mode, prevent role changes
                roleSelect.addEventListener('mousedown', function(e) {
                    e.preventDefault();
                    this.blur();
                });
                roleSelect.style.pointerEvents = 'none';
                roleSelect.style.backgroundColor = '#e9ecef';
            }
            
            // Initialize on page load
            updateRoleFields();
        });
    </script>
</body>
</html>
