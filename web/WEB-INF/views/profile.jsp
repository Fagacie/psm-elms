<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile | PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile-v2.css">
</head>
<body class="sv-page">
<nav class="sv-topbar">
    <div class="sv-top-left">
        <button id="svMenuBtn" class="sv-menu-btn" type="button" aria-label="Open menu">
            <i class="fas fa-bars"></i>
        </button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand">
            <span class="sv-brand-main">PSM</span>
            <span class="sv-brand-sub">E-Learning</span>
        </a>
        <div class="sv-page-title">
            <h1>Profile</h1>
            <p>Manage your account details and personal information</p>
        </div>
    </div>
    <div class="sv-top-right">
        <div class="profile-v2-user">
            <span class="profile-v2-user-icon"><i class="fas fa-user-circle"></i></span>
            <div class="profile-v2-user-copy">
                <strong>${sessionScope.userName}</strong>
                <span>${sessionScope.userRole}</span>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="sv-logout">
            <i class="fas fa-sign-out-alt"></i>
            <span>Logout</span>
        </a>
    </div>
</nav>

<div class="sv-layout">
    <aside id="svSidebar" class="sv-sidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link">
                <i class="fas fa-home"></i>
                <span>Dashboard</span>
            </a>
            <c:choose>
                <c:when test="${sessionScope.userRole == 'Instructor'}">
                    <a href="${pageContext.request.contextPath}/instructor/courses" class="sv-nav-link">
                        <i class="fas fa-book"></i>
                        <span>Courses</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/materials" class="sv-nav-link">
                        <i class="fas fa-folder-open"></i>
                        <span>Materials</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/assessments" class="sv-nav-link">
                        <i class="fas fa-clipboard-check"></i>
                        <span>Assessments</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/instructor/certificates" class="sv-nav-link">
                        <i class="fas fa-certificate"></i>
                        <span>Certificates</span>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link">
                        <i class="fas fa-book"></i>
                        <span>Browse Courses</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link">
                        <i class="fas fa-graduation-cap"></i>
                        <span>My Courses</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link">
                        <i class="fas fa-certificate"></i>
                        <span>Certificates</span>
                    </a>
                </c:otherwise>
            </c:choose>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link active">
                <i class="fas fa-user"></i>
                <span>Profile</span>
            </a>
        </nav>
    </aside>

    <main class="sv-main profile-page">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fas fa-angle-right"></i>
            <span>Profile</span>
        </div>

        <section class="profile-v2-hero" id="profileHero" aria-label="Profile overview highlights">
            <div class="profile-v2-hero-copy">
                <p class="profile-v2-kicker">Identity Workspace</p>
                <h2>Professional Account Control</h2>
                <p>Manage personal details, profile media, and account security through an interactive dashboard-grade profile experience.</p>
            </div>
            <div class="profile-v2-hero-scene" id="profileHeroScene" aria-hidden="true">
                <span class="profile-v2-orb profile-v2-orb-a" data-depth="20"></span>
                <span class="profile-v2-orb profile-v2-orb-b" data-depth="26"></span>
                <span class="profile-v2-shape profile-v2-shape-a" data-depth="16"></span>
                <span class="profile-v2-shape profile-v2-shape-b" data-depth="12"></span>
            </div>
        </section>

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
            <aside class="sv-card profile-v2-side profile-v2-animated profile-v2-tilt">
                <div class="sv-card-head">
                    <h2>Account Overview</h2>
                </div>
                <div class="sv-card-body">
                    <div class="profile-v2-photo profile-v2-tilt">
                        <c:choose>
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

                    <c:if test="${sessionScope.userRole == 'Student'}">
                        <form action="${pageContext.request.contextPath}/profile-picture" method="post" enctype="multipart/form-data" id="photoUploadForm" class="profile-v2-photo-form">
                            <input type="file" name="passportPhoto" id="photoInput" accept="image/jpeg,image/png,image/gif" required>
                            <label for="photoInput" class="sv-btn profile-v2-upload-btn">
                                <i class="fas fa-camera"></i>
                                <span>Upload Photo</span>
                            </label>
                        </form>
                    </c:if>

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

            <section class="profile-v2-main profile-v2-animated profile-v2-delay">
                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <div class="sv-card profile-v2-card profile-v2-tilt">
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
                        <div class="sv-card profile-v2-card profile-v2-tilt">
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
                        <div class="sv-card profile-v2-card profile-v2-tilt">
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

                    <div class="sv-card profile-v2-card profile-v2-tilt">
                        <div class="sv-card-head">
                            <h2>Account Settings</h2>
                        </div>
                        <div class="sv-card-body">
                            <div class="profile-v2-actions">
                                <button type="submit" class="sv-btn primary profile-v2-action-btn">
                                    <i class="fas fa-save"></i>
                                    <span>Save Changes</span>
                                </button>
                                <a href="${pageContext.request.contextPath}/change-password" class="sv-btn profile-v2-action-btn">
                                    <i class="fas fa-key"></i>
                                    <span>Change Password</span>
                                </a>
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

<div id="svOverlay" class="sv-overlay"></div>

<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/profile-v2.js"></script>
<script>
    document.getElementById('photoInput')?.addEventListener('change', function() {
        if (this.files && this.files[0]) {
            document.getElementById('photoUploadForm').submit();
        }
    });
</script>
</body>
</html>
