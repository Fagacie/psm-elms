<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${empty user ? 'Create' : 'Edit'}"/> User - PSM E-Learning</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-users.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <header class="app-header">
        <div class="header-left">
            <div class="logo-section">
                <i class="fas fa-university"></i>
                <span>PSM E-Learning</span>
            </div>
            <h1 class="page-title"><c:out value="${empty user ? 'Create User' : 'Edit User'}"/></h1>
        </div>
        <div class="header-right">
            <div class="user-menu">
                <div class="user-info">
                    <span class="user-name"><c:out value="${sessionScope.user.fullName}"/></span>
                    <span class="user-role">Administrator</span>
                </div>
                <div class="user-avatar"><i class="fas fa-user-shield"></i></div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </header>

    <aside class="app-sidebar">
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
                <i class="fas fa-chart-line"></i><span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-item active">
                <i class="fas fa-users"></i><span>User Management</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/courses" class="nav-item">
                <i class="fas fa-book"></i><span>Course Management</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/instructors" class="nav-item">
                <i class="fas fa-chalkboard-teacher"></i><span>Instructor Management</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/students" class="nav-item">
                <i class="fas fa-user-graduate"></i><span>Student Management</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/enrollments" class="nav-item">
                <i class="fas fa-id-card"></i><span>Enrollment Management</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/assessments" class="nav-item">
                <i class="fas fa-clipboard-list"></i><span>Assessment Management</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/certificates" class="nav-item">
                <i class="fas fa-certificate"></i><span>Certificates</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/announcements" class="nav-item">
                <i class="fas fa-bullhorn"></i><span>Announcements</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/settings" class="nav-item">
                <i class="fas fa-cog"></i><span>System Settings</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="nav-item">
                <i class="fas fa-user"></i><span>Profile / Settings</span>
            </a>
        </nav>
    </aside>

    <main class="app-main">
        <div class="content-wrapper">
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <c:out value="${sessionScope.success}"/>
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.error}"/>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.warning}">
                <div class="alert alert-warning">
                    <i class="fas fa-info-circle"></i> <c:out value="${sessionScope.warning}"/>
                </div>
                <c:remove var="warning" scope="session"/>
            </c:if>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <p class="section-eyebrow">User</p>
                        <h2><c:out value="${empty user ? 'Create New User' : 'Edit User'}"/></h2>
                    </div>
                    <div class="form-actions-inline">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to List
                        </a>
                    </div>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/admin/users" class="form-layout">
                    <c:choose>
                        <c:when test="${not empty requestScope.user}">
                            <input type="hidden" name="userId" value="${requestScope.user.userId}">
                            <input type="hidden" name="action" value="edit">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="create">
                        </c:otherwise>
                    </c:choose>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="fullName">Full Name <span class="required">*</span></label>
                            <input type="text" id="fullName" name="fullName" class="form-input" required
                                   value="${fn:escapeXml(requestScope.user.fullName)}">
                        </div>
                        <div class="form-group">
                            <label for="email">Email <span class="required">*</span></label>
                            <input type="email" id="email" name="email" class="form-input" required
                                   value="${fn:escapeXml(requestScope.user.email)}" ${not empty requestScope.user ? 'readonly' : ''}>
                            <c:if test="${not empty requestScope.user}">
                                <div class="field-note">Email cannot be changed after creation.</div>
                            </c:if>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="phone">Phone</label>
                            <input type="tel" id="phone" name="phone" class="form-input"
                                   value="${fn:escapeXml(requestScope.user.phone)}">
                        </div>
                        <div class="form-group">
                            <label for="password">Password <span class="required">*</span></label>
                            <input type="password" id="password" name="password" class="form-input" ${empty requestScope.user ? 'required' : ''}>
                            <c:if test="${not empty requestScope.user}">
                                <div class="field-note">Leave blank to keep the current password.</div>
                            </c:if>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="role">Role <span class="required">*</span></label>
                            <select id="role" name="role" class="form-select" required>
                                <option value="">Select Role</option>
                                <option value="Student" ${not empty requestScope.user && requestScope.user.role == 'Student' ? 'selected' : ''}>Student</option>
                                <option value="Instructor" ${not empty requestScope.user && requestScope.user.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                                <option value="Admin" ${not empty requestScope.user && requestScope.user.role == 'Admin' ? 'selected' : ''}>Admin</option>
                            </select>
                            <c:if test="${not empty requestScope.user}">
                                <div class="field-note">Role cannot be changed after creation.</div>
                            </c:if>
                        </div>
                        <c:if test="${empty requestScope.user}">
                            <div class="form-group">
                                <label for="status">Status</label>
                                <select id="status" name="status" class="form-select">
                                    <option value="Active" selected>Active</option>
                                    <option value="Suspended">Suspended</option>
                                </select>
                            </div>
                        </c:if>
                    </div>

                    <div id="studentFields" class="role-panel">
                        <div class="panel-header">
                            <h3>Student Information</h3>
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="qualification">Qualification</label>
                                <input type="text" id="qualification" name="qualification" class="form-input"
                                       value="${fn:escapeXml(empty student.qualification ? '' : student.qualification)}">
                            </div>
                            <div class="form-group">
                                <label for="country">Country</label>
                                <input type="text" id="country" name="country" class="form-input"
                                       value="${fn:escapeXml(empty student.country ? '' : student.country)}">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="state">State</label>
                                <input type="text" id="state" name="state" class="form-input"
                                       value="${fn:escapeXml(empty student.state ? '' : student.state)}">
                            </div>
                            <div class="form-group">
                                <label for="dob">Date of Birth</label>
                                <input type="date" id="dob" name="dob" class="form-input"
                                       value="${fn:escapeXml(empty student.dob ? '' : student.dob)}">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="gender">Gender</label>
                                <select id="gender" name="gender" class="form-select">
                                    <option value="">Select Gender</option>
                                    <option value="Male" ${student.gender == 'Male' ? 'selected' : ''}>Male</option>
                                    <option value="Female" ${student.gender == 'Female' ? 'selected' : ''}>Female</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="emergencyContact">Emergency Contact</label>
                                <input type="text" id="emergencyContact" name="emergencyContact" class="form-input"
                                       value="${fn:escapeXml(empty student.emergencyContact ? '' : student.emergencyContact)}">
                            </div>
                        </div>
                    </div>

                    <div id="instructorFields" class="role-panel">
                        <div class="panel-header">
                            <h3>Instructor Information</h3>
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="specialization">Specialization</label>
                                <input type="text" id="specialization" name="specialization" class="form-input"
                                       value="${fn:escapeXml(empty instructor.specialization ? '' : instructor.specialization)}">
                            </div>
                            <div class="form-group">
                                <label for="certification">Certification</label>
                                <input type="text" id="certification" name="certification" class="form-input"
                                       value="${fn:escapeXml(empty instructor.certification ? '' : instructor.certification)}">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="yearsOfExperience">Years of Experience</label>
                                <input type="number" id="yearsOfExperience" name="yearsOfExperience" class="form-input" min="0"
                                       value="${fn:escapeXml(empty instructor.yearsOfExperience ? '' : instructor.yearsOfExperience)}">
                            </div>
                            <div class="form-group">
                                <label for="hireDate">Hire Date</label>
                                <input type="date" id="hireDate" name="hireDate" class="form-input"
                                       value="${fn:escapeXml(empty instructor.hireDate ? '' : instructor.hireDate)}">
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="bio">Bio</label>
                            <textarea id="bio" name="bio" class="form-input" rows="3">${fn:escapeXml(empty instructor.bio ? '' : instructor.bio)}</textarea>
                        </div>
                    </div>

                    <div id="adminFields" class="role-panel">
                        <div class="panel-header">
                            <h3>Admin Information</h3>
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="position">Position</label>
                                <input type="text" id="position" name="position" class="form-input"
                                       value="${fn:escapeXml(empty admin.position ? '' : admin.position)}">
                            </div>
                            <div class="form-group">
                                <label for="permissionLevel">Permission Level</label>
                                <select id="permissionLevel" name="permissionLevel" class="form-select">
                                    <option value="SuperAdmin" ${admin.permissionLevel == 'SuperAdmin' ? 'selected' : ''}>Super Admin</option>
                                    <option value="Admin" ${admin.permissionLevel == 'Admin' ? 'selected' : ''}>Admin</option>
                                    <option value="Moderator" ${admin.permissionLevel == 'Moderator' ? 'selected' : ''}>Moderator</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="assignedDepartment">Assigned Department</label>
                            <input type="text" id="assignedDepartment" name="assignedDepartment" class="form-input"
                                   value="${fn:escapeXml(empty admin.assignedDepartment ? '' : admin.assignedDepartment)}">
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> <c:out value="${empty user ? 'Create User' : 'Update User'}"/>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </section>
        </div>
    </main>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const roleSelect = document.getElementById('role');
            const studentFields = document.getElementById('studentFields');
            const instructorFields = document.getElementById('instructorFields');
            const adminFields = document.getElementById('adminFields');
            const isEditMode = ${not empty requestScope.user ? 'true' : 'false'};

            function updateRoleFields() {
                const selectedRole = roleSelect.value;
                studentFields.style.display = 'none';
                instructorFields.style.display = 'none';
                adminFields.style.display = 'none';

                if (selectedRole === 'Student') {
                    studentFields.style.display = 'block';
                } else if (selectedRole === 'Instructor') {
                    instructorFields.style.display = 'block';
                } else if (selectedRole === 'Admin') {
                    adminFields.style.display = 'block';
                }
            }

            if (!isEditMode) {
                roleSelect.addEventListener('change', updateRoleFields);
            } else {
                roleSelect.addEventListener('mousedown', function(e) { e.preventDefault(); });
                roleSelect.style.pointerEvents = 'none';
                roleSelect.style.backgroundColor = '#f3f4f6';
            }

            updateRoleFields();
        });
    </script>
</body>
</html>
