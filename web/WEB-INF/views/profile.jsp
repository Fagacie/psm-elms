<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - PSM E-Learning</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
            text-align: center;
        }
        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .profile-picture {
            text-align: center;
            margin-bottom: 30px;
        }
        .profile-picture img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #007bff;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: bold;
        }
        input[type="text"],
        input[type="email"],
        input[type="tel"],
        input[type="date"],
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        input:focus, select:focus {
            outline: none;
            border-color: #007bff;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .btn-primary {
            background: #007bff;
            color: white;
        }
        .btn-primary:hover {
            background: #0056b3;
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .btn-secondary:hover {
            background: #545b62;
        }
        .form-actions {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 30px;
        }
        .picture-upload {
            margin-top: 10px;
        }
        .picture-upload input[type="file"] {
            margin-bottom: 10px;
        }
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #007bff;
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="${pageContext.request.contextPath}/dashboard" class="back-link">← Back to Dashboard</a>
        
        <h1>My Profile</h1>
        
        <c:if test="${not empty sessionScope.profileSuccess}">
            <div class="alert alert-success">${sessionScope.profileSuccess}</div>
            <c:remove var="profileSuccess" scope="session"/>
        </c:if>
        
        <c:if test="${not empty sessionScope.profileError}">
            <div class="alert alert-error">${sessionScope.profileError}</div>
            <c:remove var="profileError" scope="session"/>
        </c:if>
        
        <!-- Profile Picture Section -->
        <div class="profile-picture">
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
                    <img src="${pageContext.request.contextPath}/assets/default-avatar.png" alt="Default Avatar">
                </c:otherwise>
            </c:choose>
            
            <c:if test="${sessionScope.userRole == 'Student'}">
                <div class="picture-upload">
                    <form action="${pageContext.request.contextPath}/profile-picture" method="post" enctype="multipart/form-data">
                        <input type="file" name="passportPhoto" accept="image/jpeg,image/png,image/gif" required>
                        <button type="submit" class="btn btn-secondary">Upload Picture</button>
                    </form>
                </div>
            </c:if>
        </div>
        
        <!-- Profile Form -->
        <form action="${pageContext.request.contextPath}/profile" method="post">
            <div class="form-group">
                <label for="fullName">Full Name *</label>
                <input type="text" id="fullName" name="fullName" value="${user.fullName}" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email (Read-only)</label>
                <input type="email" id="email" value="${user.email}" readonly style="background: #f0f0f0;">
            </div>
            
            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="tel" id="phone" name="phone" value="${user.phone}">
            </div>
            
            <c:if test="${sessionScope.userRole == 'Student'}">
                <div class="form-group">
                    <label for="regNumber">Registration Number (Read-only)</label>
                    <input type="text" id="regNumber" value="${student.regNumber}" readonly style="background: #f0f0f0;">
                </div>
                
                <div class="form-group">
                    <label for="qualification">Qualification</label>
                    <input type="text" id="qualification" name="qualification" value="${student.qualification}">
                </div>
                
                <div class="form-group">
                    <label for="country">Country</label>
                    <input type="text" id="country" name="country" value="${student.country}">
                </div>
                
                <div class="form-group">
                    <label for="state">State</label>
                    <input type="text" id="state" name="state" value="${student.state}">
                </div>
                
                <div class="form-group">
                    <label for="dob">Date of Birth</label>
                    <input type="date" id="dob" name="dob" value="${student.dob}">
                </div>
                
                <div class="form-group">
                    <label for="gender">Gender</label>
                    <select id="gender" name="gender">
                        <option value="">Select Gender</option>
                        <option value="Male" ${student.gender == 'Male' ? 'selected' : ''}>Male</option>
                        <option value="Female" ${student.gender == 'Female' ? 'selected' : ''}>Female</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="emergencyContact">Emergency Contact</label>
                    <input type="tel" id="emergencyContact" name="emergencyContact" value="${student.emergencyContact}">
                </div>
            </c:if>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Save Changes</button>
                <a href="${pageContext.request.contextPath}/change-password" class="btn btn-secondary">Change Password</a>
            </div>
        </form>
    </div>
</body>
</html>
