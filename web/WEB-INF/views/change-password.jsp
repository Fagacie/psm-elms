<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password | PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/change-password-v2.css">
</head>
<body class="sv-page password-v2-page">
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
            <h1>Change Password</h1>
            <p>Keep your account secure with a fresh password</p>
        </div>
    </div>
    <div class="sv-top-right">
        <div class="password-v2-user">
            <span class="password-v2-user-icon"><i class="fas fa-user-shield"></i></span>
            <div class="password-v2-user-copy">
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

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fas fa-angle-right"></i>
            <a href="${pageContext.request.contextPath}/profile">Profile</a>
            <i class="fas fa-angle-right"></i>
            <span>Change Password</span>
        </div>

        <section class="password-v2-hero" aria-label="Password security overview">
            <div class="password-v2-hero-copy">
                <p class="password-v2-kicker">Security Workspace</p>
                <h2>Protect your account with a stronger password</h2>
                <p>Update your password from a cleaner account security page with clear guidance and quick access back to your profile workspace.</p>
                <div class="password-v2-hero-actions">
                    <a href="${pageContext.request.contextPath}/profile" class="sv-btn primary">Back to Profile</a>
                    <a href="${pageContext.request.contextPath}/dashboard" class="sv-btn">Dashboard</a>
                </div>
            </div>
            <div class="password-v2-hero-scene" id="passwordHeroScene" aria-hidden="true">
                <span class="password-v2-orb password-v2-orb-a" data-depth="20"></span>
                <span class="password-v2-orb password-v2-orb-b" data-depth="26"></span>
                <span class="password-v2-shape password-v2-shape-a" data-depth="16"></span>
                <span class="password-v2-shape password-v2-shape-b" data-depth="12"></span>
                <div class="password-v2-scene-panel password-v2-scene-panel-a">
                    <span>Security</span>
                    <strong>Active</strong>
                </div>
                <div class="password-v2-scene-panel password-v2-scene-panel-b">
                    <span>Reset Flow</span>
                    <strong>Ready</strong>
                </div>
            </div>
        </section>

        <c:if test="${not empty success || not empty sessionScope.passwordSuccess}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <span><c:out value="${not empty success ? success : sessionScope.passwordSuccess}"/></span>
            </div>
            <c:remove var="passwordSuccess" scope="session"/>
        </c:if>

        <c:if test="${not empty error || not empty sessionScope.passwordError}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <span><c:out value="${not empty error ? error : sessionScope.passwordError}"/></span>
            </div>
            <c:remove var="passwordError" scope="session"/>
        </c:if>

        <section class="password-v2-grid">
            <article class="sv-card password-v2-card password-v2-tilt">
                <div class="sv-card-head">
                    <h2>Update Your Password</h2>
                </div>
                <div class="sv-card-body">
                    <form action="${pageContext.request.contextPath}/change-password" method="post" id="passwordForm" class="password-v2-form-grid">
                        <div class="password-v2-field">
                            <label for="currentPassword">Current Password</label>
                            <div class="password-v2-input-wrap">
                                <input type="password" id="currentPassword" name="currentPassword" placeholder="Enter your current password" required>
                                <button type="button" class="password-v2-toggle" data-target="currentPassword" aria-label="Toggle current password visibility">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="password-v2-field">
                            <label for="newPassword">New Password</label>
                            <div class="password-v2-input-wrap">
                                <input type="password" id="newPassword" name="newPassword" placeholder="Create your new password" required>
                                <button type="button" class="password-v2-toggle" data-target="newPassword" aria-label="Toggle new password visibility">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="password-v2-field">
                            <label for="confirmPassword">Confirm New Password</label>
                            <div class="password-v2-input-wrap">
                                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter your new password" required>
                                <button type="button" class="password-v2-toggle" data-target="confirmPassword" aria-label="Toggle confirm password visibility">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="password-v2-actions">
                            <button type="submit" class="sv-btn primary password-v2-btn">
                                <i class="fas fa-lock"></i>
                                <span>Update Password</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/profile" class="sv-btn password-v2-btn">
                                <i class="fas fa-arrow-left"></i>
                                <span>Back to Profile</span>
                            </a>
                        </div>
                    </form>
                </div>
            </article>

            <aside class="sv-card password-v2-card password-v2-tilt">
                <div class="sv-card-head">
                    <h2>Password Guide</h2>
                </div>
                <div class="sv-card-body">
                    <ul class="password-v2-grid-list">
                        <li>
                            <strong>Use at least 8 characters</strong>
                            Longer passwords are easier to defend and harder to guess.
                        </li>
                        <li>
                            <strong>Mix character types</strong>
                            Use uppercase, lowercase, numbers, and symbols together.
                        </li>
                        <li>
                            <strong>Make it unique</strong>
                            Avoid reusing the same password from other platforms.
                        </li>
                        <li>
                            <strong>Keep it private</strong>
                            Never share your account password with anyone else.
                        </li>
                    </ul>

                    <div class="password-v2-note">
                        <strong>Important</strong>
                        Your new password should be different from the current one and easy for you to remember securely.
                    </div>
                </div>
            </aside>
        </section>
    </main>
</div>

<div id="svOverlay" class="sv-overlay"></div>

<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
<script src="${pageContext.request.contextPath}/js/change-password-v2.js"></script>
</body>
</html>
