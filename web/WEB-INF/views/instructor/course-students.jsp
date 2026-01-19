<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Students - ${course.courseName}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Reset and Base */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
        }
        
        body {
            background: #f5f7fa;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            color: #1e293b;
            line-height: 1.6;
        }
        
        /* Top Navigation */
        .top-navbar {
            background: #1e293b;
            border-bottom: 1px solid #334155;
            padding: 0;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        .nav-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 60px;
        }
        
        .nav-left .logo {
            font-size: 20px;
            font-weight: 700;
            color: white;
        }
        
        .nav-right {
            display: flex;
            gap: 25px;
            align-items: center;
        }
        
        .nav-link {
            color: #cbd5e1;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: color 0.2s;
        }
        
        .nav-link:hover {
            color: white;
        }
        
        /* Main Content */
        .main-content {
            padding: 30px;
            max-width: 1400px;
            margin: 0 auto;
        }
        
        /* Page Header */
        .page-header {
            margin-bottom: 30px;
        }
        
        /* Breadcrumb */
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #64748b;
        }
        
        .breadcrumb a {
            color: #3b82f6;
            text-decoration: none;
            transition: color 0.2s;
        }
        
        .breadcrumb a:hover {
            color: #2563eb;
            text-decoration: underline;
        }
        
        .breadcrumb-separator {
            color: #cbd5e1;
        }
        
        /* Back Button */
        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: white;
            border: 1px solid #e2e8f0;
            color: #475569;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s;
            margin-bottom: 20px;
            cursor: pointer;
        }
        
        .back-button:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: #1e293b;
        }
        
        .back-button i {
            font-size: 14px;
        }
        
        /* Page Title Section */
        .page-title-section {
            background: white;
            border: 1px solid #e2e8f0;
            padding: 25px 30px;
            margin-bottom: 25px;
        }
        
        .page-title-section h1 {
            margin: 0 0 15px 0;
            font-size: 24px;
            font-weight: 600;
            color: #1e293b;
        }
        
        /* Course Info Grid */
        .course-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .info-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-icon {
            width: 36px;
            height: 36px;
            border: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8fafc;
            color: #3b82f6;
            flex-shrink: 0;
        }
        
        .info-icon i {
            font-size: 16px;
        }
        
        .info-content {
            flex: 1;
            min-width: 0;
        }
        
        .info-label {
            font-size: 12px;
            color: #64748b;
            margin-bottom: 2px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-value {
            font-size: 15px;
            font-weight: 600;
            color: #1e293b;
        }
        
        /* Students Section */
        .students-section {
            background: white;
            border: 1px solid #e2e8f0;
        }
        
        .section-header {
            padding: 20px 30px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #1e293b;
            margin: 0;
        }
        
        .student-count-badge {
            padding: 6px 14px;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            color: #1e40af;
            font-size: 13px;
            font-weight: 600;
        }
        
        /* Table */
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }
        
        thead {
            background: #f8fafc;
        }
        
        thead tr {
            background: #f8fafc;
        }
        
        th {
            padding: 14px 30px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            color: #475569;
            border-bottom: 1px solid #e2e8f0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: #f8fafc;
        }
        
        td {
            padding: 16px 30px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
            font-size: 14px;
            vertical-align: middle;
        }
        
        tbody tr {
            transition: background 0.15s;
            background: white;
        }
        
        tbody tr:hover {
            background: #f8fafc;
        }
        
        tbody tr:last-child td {
            border-bottom: none;
        }
        
        .student-index {
            color: #94a3b8;
            font-weight: 500;
        }
        
        .student-name {
            font-weight: 600;
            color: #1e293b;
        }
        
        .student-email {
            color: #64748b;
        }
        
        /* Status Badges */
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border: 1px solid;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        
        .status-pending {
            background: #fef3c7;
            border-color: #fde047;
            color: #854d0e;
        }
        
        .status-active {
            background: #dcfce7;
            border-color: #86efac;
            color: #166534;
        }
        
        .status-completed {
            background: #dbeafe;
            border-color: #93c5fd;
            color: #1e40af;
        }
        
        .status-cancelled {
            background: #fee2e2;
            border-color: #fca5a5;
            color: #991b1b;
        }
        
        /* Empty State */
        .empty-state {
            padding: 80px 30px;
            text-align: center;
        }
        
        .empty-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            border: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8fafc;
        }
        
        .empty-icon i {
            font-size: 36px;
            color: #cbd5e1;
        }
        
        .empty-title {
            font-size: 18px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 8px;
        }
        
        .empty-description {
            font-size: 14px;
            color: #94a3b8;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .main-content {
                padding: 20px 15px;
            }
            
            .nav-container {
                padding: 0 20px;
            }
            
            .page-title-section {
                padding: 20px;
            }
            
            .page-title-section h1 {
                font-size: 20px;
            }
            
            .course-info-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .section-header {
                padding: 15px 20px;
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            th, td {
                padding: 12px 20px;
                font-size: 13px;
            }
            
            .back-button {
                padding: 8px 16px;
                font-size: 13px;
            }
        }
    </style>
</head>
<body>
    <!-- Top Navigation -->
    <nav class="top-navbar">
        <div class="nav-container">
            <div class="nav-left">
                <div class="logo">PSM E-Learning</div>
            </div>
            <div class="nav-right">
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-link">Dashboard</a>
                <a href="${pageContext.request.contextPath}/logout" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <!-- Page Content -->
    <div class="main-content">
        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/courses">
                <i class="fas fa-book"></i> Courses
            </a>
            <span class="breadcrumb-separator">/</span>
            <span>${course.courseName}</span>
            <span class="breadcrumb-separator">/</span>
            <span>Students</span>
        </div>

        <!-- Back Button -->
        <a href="${pageContext.request.contextPath}/instructor/courses" class="back-button">
            <i class="fas fa-arrow-left"></i>
            Back to Courses
        </a>

        <!-- Page Title Section -->
        <div class="page-title-section">
            <h1>${course.courseName}</h1>
            
            <div class="course-info-grid">
                <div class="info-item">
                    <div class="info-icon">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Category</div>
                        <div class="info-value">${course.category}</div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon">
                        <i class="fas fa-signal"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Level</div>
                        <div class="info-value">${course.level}</div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Duration</div>
                        <div class="info-value">${course.duration} hours</div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Total Enrolled</div>
                        <div class="info-value">${studentCount} students</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Students Table -->
        <div class="students-section">
            <div class="section-header">
                <h2 class="section-title">Enrolled Students</h2>
                <div class="student-count-badge">${studentCount} Students</div>
            </div>

            <c:choose>
                <c:when test="${not empty enrollments && enrollments.size() > 0}">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 60px;">#</th>
                                    <th style="width: 30%;">Student Name</th>
                                    <th style="width: 30%;">Email Address</th>
                                    <th style="width: 20%;">Enrollment Date</th>
                                    <th style="width: 15%;">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="enrollment" items="${enrollments}" varStatus="status">
                                    <tr>
                                        <td class="student-index">${status.count}</td>
                                        <td class="student-name">${enrollment.studentName}</td>
                                        <td class="student-email">${enrollment.studentEmail}</td>
                                        <td>
                                            <c:if test="${not empty enrollment.enrollmentDate}">
                                                ${enrollment.enrollmentDate}
                                            </c:if>
                                            <c:if test="${empty enrollment.enrollmentDate}">
                                                <span style="color: #94a3b8;">—</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${enrollment.status == 'Pending'}">
                                                    <span class="status-badge status-pending">Pending</span>
                                                </c:when>
                                                <c:when test="${enrollment.status == 'Active'}">
                                                    <span class="status-badge status-active">Active</span>
                                                </c:when>
                                                <c:when test="${enrollment.status == 'Completed'}">
                                                    <span class="status-badge status-completed">Completed</span>
                                                </c:when>
                                                <c:when test="${enrollment.status == 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">Cancelled</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-pending">${enrollment.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-icon">
                            <i class="fas fa-user-slash"></i>
                        </div>
                        <div class="empty-title">No Students Enrolled Yet</div>
                        <div class="empty-description">
                            Students who enroll in this course will appear here.
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
