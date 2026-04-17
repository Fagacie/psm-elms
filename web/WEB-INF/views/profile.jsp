<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="isAdminProfile" value="${sessionScope.userRole == 'Admin'}"/>
<c:set var="isStudentProfile" value="${sessionScope.userRole == 'Student'}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile | PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <c:if test="${isAdminProfile}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    </c:if>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile-v2.css">
</head>
<body class="sv-page ${isAdminProfile ? 'admin-page profile-admin' : ''}">
<c:choose>
    <c:when test="${isAdminProfile}">
        <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
            <jsp:param name="pageTitle" value="Profile"/>
            <jsp:param name="pageSubtitle" value="Manage your account details and personal information"/>
        </jsp:include>
    </c:when>
    <c:when test="${isStudentProfile}">
        <c:set var="topbarTitle" value="Profile"/>
        <c:set var="topbarSubtitle" value="Manage your account details and personal information"/>
        <c:set var="topbarShowSearch" value="false"/>
        <jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>
    </c:when>
    <c:otherwise>
        <c:set var="topbarTitle" value="Profile"/>
        <c:set var="topbarSubtitle" value="Manage your account details and personal information"/>
        <jsp:include page="/WEB-INF/views/common/account-topbar.jsp"/>
    </c:otherwise>
</c:choose>

<div class="sv-layout">
    <c:choose>
        <c:when test="${isAdminProfile}">
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>
        </c:when>
        <c:when test="${isStudentProfile}">
            <c:set var="activePage" value="profile"/>
            <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>
        </c:when>
        <c:otherwise>
            <c:set var="activePage" value="profile"/>
            <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>
        </c:otherwise>
    </c:choose>

    <main class="sv-main profile-page">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fas fa-angle-right"></i>
            <span>Profile</span>
        </div>

        <section class="profile-v2-hero" aria-label="Profile overview highlights">
            <div class="profile-v2-hero-copy">
                <p class="profile-v2-kicker">Account Center</p>
                <h2>Keep your profile complete and up to date.</h2>
                <p>Update your personal details, contact information, and account settings from one clean workspace.</p>
            </div>
            <div class="profile-v2-hero-actions">
                <button type="button" class="sv-btn primary" data-open-password-modal>Change Password</button>
                <a href="${pageContext.request.contextPath}/dashboard" class="sv-btn">Back to Dashboard</a>
            </div>
        </section>

        <c:if test="${not empty sessionScope.passwordSuccess}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.passwordSuccess}
            </div>
            <c:remove var="passwordSuccess" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.passwordError}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.passwordError}
            </div>
            <c:remove var="passwordError" scope="session"/>
        </c:if>

        <section class="sv-metrics profile-v2-metrics">
            <article class="sv-metric profile-v2-tilt">
                <h3 class="profile-v2-count" data-counter="1">1</h3>
                <p>Primary Profile</p>
            </article>
            <article class="sv-metric profile-v2-tilt">
                <h3 class="profile-v2-count" data-counter="${sessionScope.userRole == 'Student' ? 4 : 3}">${sessionScope.userRole == 'Student' ? 4 : 3}</h3>
                <p>Data Sections</p>
            </article>
            <article class="sv-metric profile-v2-tilt">
                <h3 class="profile-v2-count" data-counter="${not empty user.phone ? 1 : 0}">${not empty user.phone ? 1 : 0}</h3>
                <p>Contact Ready</p>
            </article>
            <article class="sv-metric profile-v2-tilt">
                <h3 class="profile-v2-count" data-counter="${sessionScope.userRole == 'Student' ? 1 : 0}">${sessionScope.userRole == 'Student' ? 1 : 0}</h3>
                <p>Student Mode</p>
            </article>
        </section>

        <c:if test="${not empty sessionScope.profileSuccess}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.profileSuccess}
            </div>
            <c:remove var="profileSuccess" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.profileError}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.profileError}
            </div>
            <c:remove var="profileError" scope="session"/>
        </c:if>

        <section class="profile-v2-grid">
            <aside class="sv-card profile-v2-side">
                <div class="sv-card-head">
                    <h2>Account Overview</h2>
                </div>
                <div class="sv-card-body">
                    <div class="profile-v2-photo">
                        <c:choose>
                            <c:when test="${not empty user.profilePicture}">
                                <c:choose>
                                    <c:when test="${user.profilePicture.startsWith('http')}">
                                        <img src="${user.profilePicture}" alt="Profile Picture">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/${user.profilePicture}" alt="Profile Picture">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:when test="${not empty student.passportPath}">
                                <c:choose>
                                    <c:when test="${student.passportPath.startsWith('http')}">
                                        <img src="${student.passportPath}" alt="Profile Picture">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/${student.passportPath}" alt="Profile Picture">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-user"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="profile-v2-name">${user.fullName}</div>
                    <div class="profile-v2-role">${sessionScope.userRole}</div>

                    <form action="${pageContext.request.contextPath}/profile-picture" method="post" enctype="multipart/form-data" id="photoUploadForm" class="profile-v2-photo-form">
                        <input type="file" name="passportPhoto" id="photoInput" accept="image/jpeg,image/png,image/gif" required>
                        <label for="photoInput" class="sv-btn profile-v2-upload-btn">
                            <i class="fas fa-camera"></i>
                            <span>Upload Photo</span>
                        </label>
                    </form>

                    <div class="profile-v2-meta">
                        <div class="profile-v2-meta-item">
                            <span>Full Name</span>
                            <strong>${user.fullName}</strong>
                        </div>
                        <c:if test="${sessionScope.userRole == 'Student'}">
                            <div class="profile-v2-meta-item">
                                <span>Student ID</span>
                                <strong>${student.regNumber}</strong>
                            </div>
                            <div class="profile-v2-meta-item">
                                <span>Status</span>
                                <strong><span class="sv-chip done">Active</span></strong>
                            </div>
                        </c:if>
                        <c:if test="${sessionScope.userRole == 'Instructor'}">
                            <c:if test="${not empty instructor.specialization}">
                                <div class="profile-v2-meta-item">
                                    <span>Specialization</span>
                                    <strong>${instructor.specialization}</strong>
                                </div>
                            </c:if>
                            <c:if test="${not empty instructor.yearsOfExperience}">
                                <div class="profile-v2-meta-item">
                                    <span>Experience</span>
                                    <strong>${instructor.yearsOfExperience} years</strong>
                                </div>
                            </c:if>
                        </c:if>
                    </div>
                </div>
            </aside>

            <section class="profile-v2-main">
                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <div class="sv-card profile-v2-card">
                        <div class="sv-card-head">
                            <h2>Personal Information</h2>
                        </div>
                        <div class="sv-card-body">
                            <div class="profile-v2-form-grid">
                                <div class="profile-v2-field">
                                    <label>Full Name *</label>
                                    <input type="text" name="fullName" value="${user.fullName}" required>
                                </div>

                                <div class="profile-v2-field">
                                    <label>Email Address</label>
                                    <input type="email" value="${user.email}" readonly>
                                </div>

                                <div class="profile-v2-field">
                                    <label>Phone Number</label>
                                    <input type="tel" name="phone" value="${user.phone}">
                                </div>

                                <c:if test="${sessionScope.userRole == 'Student'}">
                                    <div class="profile-v2-field">
                                        <label>Date of Birth</label>
                                        <input type="date" name="dob" value="${student.dob}">
                                    </div>

                                    <div class="profile-v2-field">
                                        <label>Gender</label>
                                        <select name="gender">
                                            <option value="">Select Gender</option>
                                            <option value="Male" ${student.gender == 'Male' ? 'selected' : ''}>Male</option>
                                            <option value="Female" ${student.gender == 'Female' ? 'selected' : ''}>Female</option>
                                        </select>
                                    </div>

                                    <div class="profile-v2-field">
                                        <label>Country</label>
                                        <input type="text" name="country" value="${student.country}">
                                    </div>

                                    <div class="profile-v2-field">
                                        <label>State / Province</label>
                                        <input type="text" name="state" value="${student.state}">
                                    </div>

                                    <div class="profile-v2-field">
                                        <label>Emergency Contact</label>
                                        <input type="tel" name="emergencyContact" value="${student.emergencyContact}">
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <c:if test="${sessionScope.userRole == 'Student'}">
                        <div class="sv-card profile-v2-card">
                            <div class="sv-card-head">
                                <h2>Academic Information</h2>
                            </div>
                            <div class="sv-card-body">
                                <div class="profile-v2-form-grid">
                                    <div class="profile-v2-field">
                                        <label>Registration Number</label>
                                        <div class="profile-v2-readonly">${student.regNumber}</div>
                                    </div>

                                    <div class="profile-v2-field">
                                        <label>Qualification</label>
                                        <input type="text" name="qualification" value="${student.qualification}">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${sessionScope.userRole == 'Instructor'}">
                        <div class="sv-card profile-v2-card">
                            <div class="sv-card-head">
                                <h2>Instructor Information</h2>
                            </div>
                            <div class="sv-card-body">
                                <div class="profile-v2-form-grid">
                                    <c:if test="${not empty instructor.specialization}">
                                        <div class="profile-v2-field">
                                            <label>Specialization</label>
                                            <div class="profile-v2-readonly">${instructor.specialization}</div>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty instructor.certification}">
                                        <div class="profile-v2-field">
                                            <label>Certification</label>
                                            <div class="profile-v2-readonly">${instructor.certification}</div>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty instructor.yearsOfExperience}">
                                        <div class="profile-v2-field">
                                            <label>Years of Experience</label>
                                            <div class="profile-v2-readonly">${instructor.yearsOfExperience}</div>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty instructor.hireDate}">
                                        <div class="profile-v2-field">
                                            <label>Hire Date</label>
                                            <div class="profile-v2-readonly">${instructor.hireDate}</div>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <div class="sv-card profile-v2-card">
                        <div class="sv-card-head">
                            <h2>Account Settings</h2>
                        </div>
                        <div class="sv-card-body">
                            <div class="profile-v2-actions">
                                <button type="submit" class="sv-btn primary profile-v2-action-btn">
                                    <i class="fas fa-save"></i>
                                    <span>Save Changes</span>
                                </button>
                                <button type="button" class="sv-btn profile-v2-action-btn" data-open-password-modal>
                                    <i class="fas fa-key"></i>
                                    <span>Change Password</span>
                                </button>
                                <a href="${pageContext.request.contextPath}/dashboard" class="sv-btn profile-v2-action-btn">
                                    <i class="fas fa-arrow-left"></i>
                                    <span>Back to Dashboard</span>
                                </a>
                            </div>
                        </div>
                    </div>
                </form>
            </section>
        </section>
    </main>
</div>

<div class="profile-v2-password-modal" id="passwordModal" aria-hidden="true" role="dialog" aria-modal="true" aria-labelledby="passwordModalTitle">
    <div class="profile-v2-password-dialog">
        <div class="profile-v2-password-header">
            <div>
                <p class="profile-v2-password-kicker">Security Workspace</p>
                <h2 id="passwordModalTitle">Change Password</h2>
                <p>Update your password without leaving the profile screen.</p>
            </div>
            <button type="button" class="profile-v2-password-close" data-close-password-modal aria-label="Close password modal">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/change-password" method="post" id="passwordForm" class="profile-v2-password-form">
            <div class="profile-v2-password-field">
                <label for="currentPassword">Current Password</label>
                <div class="profile-v2-password-input-wrap">
                    <input type="password" id="currentPassword" name="currentPassword" placeholder="Enter your current password" required>
                    <button type="button" class="profile-v2-password-toggle" data-target="currentPassword" aria-label="Toggle current password visibility">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <div class="profile-v2-password-field">
                <label for="newPassword">New Password</label>
                <div class="profile-v2-password-input-wrap">
                    <input type="password" id="newPassword" name="newPassword" placeholder="Create your new password" required>
                    <button type="button" class="profile-v2-password-toggle" data-target="newPassword" aria-label="Toggle new password visibility">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <div class="profile-v2-password-field">
                <label for="confirmPassword">Confirm New Password</label>
                <div class="profile-v2-password-input-wrap">
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter your new password" required>
                    <button type="button" class="profile-v2-password-toggle" data-target="confirmPassword" aria-label="Toggle confirm password visibility">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <div class="profile-v2-password-note">
                Use at least 8 characters, mix letters and numbers, and avoid reusing an old password.
            </div>

            <div class="profile-v2-password-actions">
                <button type="submit" class="sv-btn primary profile-v2-password-submit">
                    <i class="fas fa-lock"></i>
                    <span>Update Password</span>
                </button>
                <button type="button" class="sv-btn profile-v2-password-submit" data-close-password-modal>
                    <i class="fas fa-arrow-left"></i>
                    <span>Close</span>
                </button>
            </div>
        </form>
    </div>
</div>

<div id="svOverlay" class="sv-overlay"></div>

<c:set var="openPasswordModal" value="${param.openPasswordModal == '1' or not empty sessionScope.passwordError}" />

<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script>
    document.getElementById('photoInput')?.addEventListener('change', function() {
        if (this.files && this.files[0]) {
            document.getElementById('photoUploadForm').submit();
        }
    });

    (function () {
        var modal = document.getElementById('passwordModal');
        var overlay = document.getElementById('svOverlay');
        var openButtons = document.querySelectorAll('[data-open-password-modal]');
        var closeButtons = document.querySelectorAll('[data-close-password-modal]');
        var passwordForm = document.getElementById('passwordForm');
        var currentPasswordInput = document.getElementById('currentPassword');
        var passwordToggles = modal ? modal.querySelectorAll('.profile-v2-password-toggle') : [];
        var shouldOpen = '<c:out value="${openPasswordModal}" />' === 'true';

        function openPasswordModal() {
            if (!modal || !overlay) return;
            modal.classList.add('show');
            overlay.classList.add('show');
            modal.setAttribute('aria-hidden', 'false');
            if (currentPasswordInput) {
                setTimeout(function () {
                    currentPasswordInput.focus();
                }, 0);
            }
        }

        function closePasswordModal() {
            if (!modal || !overlay) return;
            modal.classList.remove('show');
            overlay.classList.remove('show');
            modal.setAttribute('aria-hidden', 'true');
        }

        openButtons.forEach(function (button) {
            button.addEventListener('click', openPasswordModal);
        });

        closeButtons.forEach(function (button) {
            button.addEventListener('click', closePasswordModal);
        });

        if (overlay) {
            overlay.addEventListener('click', function () {
                closePasswordModal();
            });
        }

        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                closePasswordModal();
            }
        });

        passwordToggles.forEach(function (toggle) {
            toggle.addEventListener('click', function () {
                var targetId = toggle.getAttribute('data-target');
                var input = document.getElementById(targetId);
                var icon = toggle.querySelector('i');

                if (!input || !icon) return;

                if (input.type === 'password') {
                    input.type = 'text';
                    icon.classList.remove('fa-eye');
                    icon.classList.add('fa-eye-slash');
                } else {
                    input.type = 'password';
                    icon.classList.remove('fa-eye-slash');
                    icon.classList.add('fa-eye');
                }
            });
        });

        if (passwordForm) {
            passwordForm.addEventListener('submit', function (event) {
                var newPassword = document.getElementById('newPassword');
                var confirmPassword = document.getElementById('confirmPassword');

                if (newPassword && confirmPassword && newPassword.value !== confirmPassword.value) {
                    event.preventDefault();
                    window.alert('New password and confirmation password do not match. Please try again.');
                }
            });
        }

        if (shouldOpen) {
            openPasswordModal();
        }
    })();
</script>
</body>
</html>
