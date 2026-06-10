<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:if test="${not empty selectedCourse}">
    <c:url var="courseWorkspaceUrl" value="/instructor/courses">
        <c:param name="action" value="workspace"/>
        <c:param name="courseId" value="${selectedCourse.courseId}"/>
    </c:url>
    <c:url var="courseMaterialsUrl" value="/instructor/materials">
        <c:param name="courseId" value="${selectedCourse.courseId}"/>
    </c:url>
    <c:url var="courseAssessmentsUrl" value="/instructor/courses">
        <c:param name="action" value="workspace"/>
        <c:param name="courseId" value="${selectedCourse.courseId}"/>
    </c:url>
    <c:url var="courseStudentsUrl" value="/instructor/courses">
        <c:param name="action" value="students"/>
        <c:param name="courseId" value="${selectedCourse.courseId}"/>
    </c:url>

    <c:set var="resolvedCourseFlow" value="${requestScope.currentCourseFlow}"/>
    <c:if test="${empty resolvedCourseFlow}">
        <c:set var="resolvedCourseFlow" value="${param.action == 'students' ? 'students' : 'workspace'}"/>
    </c:if>

    <nav class="ins-flow-nav" aria-label="Course flow navigation">
        <a class="ins-flow-link ${resolvedCourseFlow == 'workspace' ? 'active' : ''}" href="${courseWorkspaceUrl}">
            <i class="fas fa-chart-pie"></i> Overview
        </a>
        <a class="ins-flow-link ${resolvedCourseFlow == 'materials' ? 'active' : ''}" href="${courseWorkspaceUrl}#materials">
            <i class="fas fa-book-open"></i> Materials
        </a>
        <a class="ins-flow-link ${resolvedCourseFlow == 'assessments' ? 'active' : ''}" href="${courseAssessmentsUrl}#assessments">
            <i class="fas fa-tasks"></i> Assessments
        </a>
        <a class="ins-flow-link ${resolvedCourseFlow == 'students' ? 'active' : ''}" href="${courseStudentsUrl}">
            <i class="fas fa-users"></i> Students
        </a>
    </nav>
</c:if>
