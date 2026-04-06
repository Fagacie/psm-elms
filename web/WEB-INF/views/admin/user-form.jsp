<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="embeddedMode" value="${param.modal eq '1'}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${empty user ? 'Create' : 'Edit'}"/> User - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="${embeddedMode ? 'admin-embedded' : ''}">
<c:if test="${not embeddedMode}">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="${empty user ? 'Create User' : 'Edit User'}"/>
    <jsp:param name="pageSubtitle" value="Configure account records and role profile details"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>
</c:if>

<main class="app-main">
    <div class="content-wrapper">
        <c:if test="${not embeddedMode}">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/admin/users">Users</a>
                <span>&gt;</span>
                <span><c:out value="${empty user ? 'Create User' : 'Edit User'}"/></span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">Identity Configuration</p>
                    <h2><c:out value="${empty user ? 'Create a new user account with role-specific details' : 'Update the selected user account and role profile'}"/></h2>
                    <p>Use this form to configure the root user record and attach the correct student, instructor, or admin profile information without leaving the admin workspace.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <span class="admin-orb admin-orb-a"></span>
                    <span class="admin-orb admin-orb-b"></span>
                    <span class="admin-shape admin-shape-a"></span>
                    <span class="admin-shape admin-shape-b"></span>
                    <div class="admin-scene-panel admin-scene-panel-a">
                        <span>Mode</span>
                        <strong><c:out value="${empty user ? 'Create' : 'Edit'}"/></strong>
                    </div>
                    <div class="admin-scene-panel admin-scene-panel-b">
                        <span>Role</span>
                        <strong><c:out value="${empty requestScope.user.role ? 'Select' : requestScope.user.role}"/></strong>
                    </div>
                </div>
            </div>
        </section>
        </c:if>

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
                <h2><c:out value="${empty user ? 'Create New User' : 'Edit User'}"/></h2>
                <c:if test="${not embeddedMode}">
                <a href="${pageContext.request.contextPath}/admin/users" class="admin-btn secondary"><i class="fas fa-arrow-left"></i>&nbsp;Back to List</a>
                </c:if>
            </div>

            <div style="padding:14px 16px 16px;">
                <form method="post" action="${pageContext.request.contextPath}/admin/users" class="admin-form-layout">
                    <c:choose>
                        <c:when test="${not empty requestScope.user}">
                            <input type="hidden" name="userId" value="${requestScope.user.userId}">
                            <input type="hidden" name="action" value="edit">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="create">
                        </c:otherwise>
                    </c:choose>

                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="fullName">Full Name <span class="admin-required">*</span></label>
                            <input type="text" id="fullName" name="fullName" class="form-input" required value="${fn:escapeXml(requestScope.user.fullName)}">
                        </div>
                        <div class="admin-form-group">
                            <label for="email">Email <span class="admin-required">*</span></label>
                            <input type="email" id="email" name="email" class="form-input" required value="${fn:escapeXml(requestScope.user.email)}" ${not empty requestScope.user ? 'readonly' : ''}>
                            <c:if test="${not empty requestScope.user}"><div class="admin-note">Email cannot be changed after creation.</div></c:if>
                        </div>
                    </div>

                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="phone">Phone</label>
                            <input type="tel" id="phone" name="phone" class="form-input" value="${fn:escapeXml(requestScope.user.phone)}">
                        </div>
                        <div class="admin-form-group">
                            <label for="password">Password <span class="admin-required">*</span></label>
                            <input type="password" id="password" name="password" class="form-input" ${empty requestScope.user ? 'required' : ''}>
                            <c:if test="${not empty requestScope.user}"><div class="admin-note">Leave blank to keep the current password.</div></c:if>
                        </div>
                    </div>

                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="role">Role <span class="admin-required">*</span></label>
                            <select id="role" name="role" class="form-select" required>
                                <option value="">Select Role</option>
                                <option value="Student" ${not empty requestScope.user && requestScope.user.role == 'Student' ? 'selected' : ''}>Student</option>
                                <option value="Instructor" ${not empty requestScope.user && requestScope.user.role == 'Instructor' ? 'selected' : ''}>Instructor</option>
                                <option value="Admin" ${not empty requestScope.user && requestScope.user.role == 'Admin' ? 'selected' : ''}>Admin</option>
                            </select>
                            <c:if test="${not empty requestScope.user}"><div class="admin-note">Role cannot be changed after creation.</div></c:if>
                        </div>
                        <c:if test="${empty requestScope.user}">
                            <div class="admin-form-group">
                                <label for="status">Status</label>
                                <select id="status" name="status" class="form-select">
                                    <option value="Active" selected>Active</option>
                                    <option value="Suspended">Suspended</option>
                                </select>
                            </div>
                        </c:if>
                    </div>

                    <div id="studentFields" class="admin-role-panel">
                        <div class="admin-role-panel-head"><h3>Student Information</h3></div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="qualification">Qualification</label>
                                <input type="text" id="qualification" name="qualification" class="form-input" value="${fn:escapeXml(empty student.qualification ? '' : student.qualification)}">
                            </div>
                            <div class="admin-form-group">
                                <label for="country">Country</label>
                                <input type="text" id="country" name="country" class="form-input" value="${fn:escapeXml(empty student.country ? '' : student.country)}">
                            </div>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="state">State</label>
                                <input type="text" id="state" name="state" class="form-input" value="${fn:escapeXml(empty student.state ? '' : student.state)}">
                            </div>
                            <div class="admin-form-group">
                                <label for="dob">Date of Birth</label>
                                <input type="date" id="dob" name="dob" class="form-input" value="${fn:escapeXml(empty student.dob ? '' : student.dob)}">
                            </div>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="gender">Gender</label>
                                <select id="gender" name="gender" class="form-select">
                                    <option value="">Select Gender</option>
                                    <option value="Male" ${student.gender == 'Male' ? 'selected' : ''}>Male</option>
                                    <option value="Female" ${student.gender == 'Female' ? 'selected' : ''}>Female</option>
                                </select>
                            </div>
                            <div class="admin-form-group">
                                <label for="emergencyContact">Emergency Contact</label>
                                <input type="text" id="emergencyContact" name="emergencyContact" class="form-input" value="${fn:escapeXml(empty student.emergencyContact ? '' : student.emergencyContact)}">
                            </div>
                        </div>
                    </div>

                    <div id="instructorFields" class="admin-role-panel">
                        <div class="admin-role-panel-head"><h3>Instructor Information</h3></div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="specialization">Specialization</label>
                                <input type="text" id="specialization" name="specialization" class="form-input" value="${fn:escapeXml(empty instructor.specialization ? '' : instructor.specialization)}">
                            </div>
                            <div class="admin-form-group">
                                <label for="certification">Certification</label>
                                <input type="text" id="certification" name="certification" class="form-input" value="${fn:escapeXml(empty instructor.certification ? '' : instructor.certification)}">
                            </div>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="yearsOfExperience">Years of Experience</label>
                                <input type="number" id="yearsOfExperience" name="yearsOfExperience" class="form-input" min="0" value="${fn:escapeXml(empty instructor.yearsOfExperience ? '' : instructor.yearsOfExperience)}">
                            </div>
                            <div class="admin-form-group">
                                <label for="hireDate">Hire Date</label>
                                <input type="date" id="hireDate" name="hireDate" class="form-input" value="${fn:escapeXml(empty instructor.hireDate ? '' : instructor.hireDate)}">
                            </div>
                        </div>
                        <div class="admin-form-group">
                            <label for="bio">Bio</label>
                            <textarea id="bio" name="bio" class="form-input">${fn:escapeXml(empty instructor.bio ? '' : instructor.bio)}</textarea>
                        </div>
                    </div>

                    <div id="adminFields" class="admin-role-panel">
                        <div class="admin-role-panel-head"><h3>Admin Information</h3></div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="position">Position</label>
                                <input type="text" id="position" name="position" class="form-input" value="${fn:escapeXml(empty admin.position ? '' : admin.position)}">
                            </div>
                            <div class="admin-form-group">
                                <label for="permissionLevel">Permission Level</label>
                                <select id="permissionLevel" name="permissionLevel" class="form-select">
                                    <option value="SuperAdmin" ${admin.permissionLevel == 'SuperAdmin' ? 'selected' : ''}>Super Admin</option>
                                    <option value="Admin" ${admin.permissionLevel == 'Admin' ? 'selected' : ''}>Admin</option>
                                    <option value="Moderator" ${admin.permissionLevel == 'Moderator' ? 'selected' : ''}>Moderator</option>
                                </select>
                            </div>
                        </div>
                        <div class="admin-form-group">
                            <label for="assignedDepartment">Assigned Department</label>
                            <input type="text" id="assignedDepartment" name="assignedDepartment" class="form-input" value="${fn:escapeXml(empty admin.assignedDepartment ? '' : admin.assignedDepartment)}">
                        </div>
                    </div>

                    <div class="admin-form-actions">
                        <button type="submit" class="admin-btn primary"><i class="fas fa-save"></i>&nbsp;<c:out value="${empty user ? 'Create User' : 'Update User'}"/></button>
                        <a href="${pageContext.request.contextPath}/admin/users" class="admin-btn secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </section>
    </div>
</main>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const roleSelect = document.getElementById('role');
        const studentFields = document.getElementById('studentFields');
        const instructorFields = document.getElementById('instructorFields');
        const adminFields = document.getElementById('adminFields');
        const isEditMode = '<c:out value="${not empty requestScope.user}" />' === 'true';

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
            roleSelect.style.opacity = '0.8';
        }

        updateRoleFields();
    });
</script>
</body>
</html>
