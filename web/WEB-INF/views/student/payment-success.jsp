<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enrollment-flow-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Payment Success</h1><p>Enrollment completed</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/profile" class="sv-profile-link"><i class="fas fa-user"></i><span>${sessionScope.userName}</span></a><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout ef-layout-flat">
    <main class="sv-main ef-main-centered">
        <div class="ef-stepper">
            <div class="ef-step">1. Enrollment Summary</div>
            <div class="ef-step">2. Payment</div>
            <div class="ef-step active">3. Access Learning Hub</div>
        </div>

        <section class="ef-result">
            <div class="ef-result-top">
                <div class="ef-icon success"><i class="fas fa-check"></i></div>
                <div>
                    <h2>Payment Successful</h2>
                    <p>You are now enrolled and can start learning immediately.</p>
                </div>
            </div>

            <div class="ef-grid ef-grid-tight">
                <div class="ef-meta"><span>Course</span><strong>${enrollment.courseName}</strong></div>
                <div class="ef-meta"><span>Enrollment ID</span><strong>#${enrollment.enrollmentId}</strong></div>
                <div class="ef-meta"><span>Reference</span><strong><c:out value="${enrollment.paymentRef}" default="-"/></strong></div>
                <div class="ef-meta"><span>Amount Paid</span><strong><fmt:formatNumber value="${enrollment.coursePrice}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong></div>
                <div class="ef-meta"><span>Status</span><strong>Enrolled</strong></div>
            </div>

            <div class="ef-note">
                <h4>Next Steps</h4>
                <ul>
                    <li>Open your Learning Hub and start materials.</li>
                    <li>Take course assessments in sequence.</li>
                    <li>Complete course requirements to qualify for certificate.</li>
                </ul>
            </div>

            <div class="ef-actions">
                <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${enrollment.enrollmentId}&tab=learning" class="sv-btn primary">Start Learning</a>
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-btn">My Courses</a>
            </div>
        </section>
    </main>
</div>
</body>
</html>


