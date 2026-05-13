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
    <c:url var="courseAssessmentsUrl" value="/instructor/assessments">
        <c:param name="courseId" value="${selectedCourse.courseId}"/>
    </c:url>
    <c:url var="courseStudentsUrl" value="/instructor/courses">
        <c:param name="action" value="students"/>
        <c:param name="courseId" value="${selectedCourse.courseId}"/>
    </c:url>

    <nav class="ws-navbar" aria-label="Course flow navigation">
        <a class="ws-nav-link ${param.action == 'workspace' || empty param.action ? 'active' : ''}" href="${courseWorkspaceUrl}">
            <i class="fas fa-chart-pie"></i> Workspace
        </a>
        <a class="ws-nav-link ${requestScope.currentCourseFlow == 'materials' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/content-organizer?courseId=${selectedCourse.courseId}">
            <i class="fas fa-book-open"></i> Materials
        </a>
        <a class="ws-nav-link ${requestScope.currentCourseFlow == 'assessments' ? 'active' : ''}" href="${courseAssessmentsUrl}">
            <i class="fas fa-tasks"></i> Assessments
        </a>
        <a class="ws-nav-link ${requestScope.currentCourseFlow == 'students' ? 'active' : ''}" href="${courseStudentsUrl}">
            <i class="fas fa-users"></i> Students
        </a>
    </nav>
</c:if>
