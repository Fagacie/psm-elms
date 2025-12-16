<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Enrollment Summary</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .card { max-width: 720px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; padding: 20px; }
        .row { display: flex; justify-content: space-between; margin: 8px 0; }
        .actions { margin-top: 20px; display: flex; gap: 12px; }
        .btn { padding: 10px 16px; border: none; border-radius: 4px; cursor: pointer; }
        .btn-primary { background: #1976d2; color: #fff; }
        .btn-secondary { background: #eee; color: #333; }
    </style>
</head>
<body>
<div class="card">
    <h2>Confirm Enrollment</h2>

    <c:if test="${empty course}">
        <p>Course details not available. <a href="${pageContext.request.contextPath}/student/courses">Back to courses</a></p>
    </c:if>

    <c:if test="${not empty course}">
        <div class="row"><strong>Course:</strong> <span>${course.courseName}</span></div>
        <div class="row"><strong>Description:</strong> <span>${course.description}</span></div>
        <div class="row"><strong>Fee:</strong> <span>₦<c:out value="${course.courseFee}"/></span></div>

        <form method="post" action="${pageContext.request.contextPath}/student/enroll">
            <input type="hidden" name="courseId" value="${course.courseId}" />
            <div class="actions">
                <button type="submit" class="btn btn-primary">Proceed to Payment</button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/student/courses">Cancel</a>
            </div>
        </form>
    </c:if>
</div>
</body>
</html>