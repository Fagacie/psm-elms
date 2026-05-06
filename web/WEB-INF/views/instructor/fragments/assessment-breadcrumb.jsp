<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="breadcrumb" aria-label="Breadcrumb">
    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
    <span>&gt;</span>
    <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
    <c:if test="${not empty selectedCourse}">
        <span>&gt;</span>
        <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}">${selectedCourse.courseName}</a>
        <span>&gt;</span>
        <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}#assessments">Course Workspace</a>
    </c:if>
    <span>&gt;</span>
    <span><c:out value="${param.currentLabel}"/></span>
</nav>