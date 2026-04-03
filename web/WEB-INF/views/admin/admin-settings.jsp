<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Settings - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Settings"/>
    <jsp:param name="pageSubtitle" value="Review platform configuration and operational defaults"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Settings</span>
            </div>

            <div class="admin-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">System Settings</p>
                    <h2>Admin configuration workspace is ready</h2>
                    <p>This screen is now wired and reachable. You can extend it with email, payment, and policy controls as needed.</p>
                </div>
                <div class="admin-hero-scene" aria-hidden="true">
                    <div class="admin-scene-panel">
                        <span>Route</span>
                        <strong>/admin/settings</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2>Status</h2>
            </div>
            <div class="panel-stack">
                <div class="status-item">
                    <div class="status-item-copy">
                        <strong>Settings Page</strong>
                        <span>Online and rendering with the admin shell.</span>
                    </div>
                </div>
            </div>
        </section>
    </div>
</main>
</body>
</html>
