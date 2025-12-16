<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Servlet Mappings</title>
</head>
<body>
    <h1>Test Servlet Mappings</h1>
    <p>Context Path: <%= request.getContextPath() %></p>
    <p>Session User Role: <%= session.getAttribute("userRole") %></p>
    <p>Session User ID: <%= session.getAttribute("userId") %></p>
    
    <h3>Try these links:</h3>
    <ul>
        <li><a href="<%= request.getContextPath() %>/admin/users">Admin Users</a></li>
        <li><a href="<%= request.getContextPath() %>/admin/courses">Admin Courses</a></li>
        <li><a href="<%= request.getContextPath() %>/instructor/courses">Instructor Courses</a></li>
        <li><a href="<%= request.getContextPath() %>/student/courses">Student Courses</a></li>
    </ul>
</body>
</html>
