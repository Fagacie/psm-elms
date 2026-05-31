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

    <style>
        .ws-navbar-modern {
            display: flex !important;
            align-items: center;
            gap: 2rem !important;
            border-bottom: 2px solid #e2e8f0 !important;
            background: transparent !important;
            padding: 0 !important;
            margin-bottom: 2rem !important;
        }

        .ws-nav-link-modern {
            font-size: 0.95rem !important;
            color: #64748b !important;
            font-weight: 500 !important;
            padding: 14px 4px 12px 4px !important;
            text-decoration: none !important;
            border-bottom: 2px solid transparent !important;
            display: inline-flex !important;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease !important;
            cursor: pointer;
            margin-bottom: -2px !important;
        }

        .ws-nav-link-modern:hover {
            color: var(--ws-primary, #6366f1) !important;
        }

        .ws-nav-link-modern.active {
            color: var(--ws-primary, #6366f1) !important;
            font-weight: 700 !important;
            border-bottom: 2px solid var(--ws-primary, #6366f1) !important;
        }

        :root[data-theme="dark"] .ws-navbar-modern {
            border-bottom-color: #1f2937 !important;
        }

        :root[data-theme="dark"] .ws-nav-link-modern {
            color: #9ca3af !important;
        }

        :root[data-theme="dark"] .ws-nav-link-modern:hover {
            color: var(--ws-primary, #6366f1) !important;
        }

        :root[data-theme="dark"] .ws-nav-link-modern.active {
            color: var(--ws-primary, #6366f1) !important;
            border-bottom-color: var(--ws-primary, #6366f1) !important;
        }
    </style>

    <nav class="ws-navbar-modern" aria-label="Course flow navigation">
        <a class="ws-nav-link-modern ${param.action == 'workspace' || empty param.action ? 'active' : ''}" href="${courseWorkspaceUrl}">
            <i class="fas fa-chart-pie"></i> Workspace
        </a>
        <a class="ws-nav-link-modern ${requestScope.currentCourseFlow == 'materials' ? 'active' : ''}" href="${pageContext.request.contextPath}/instructor/content-organizer?courseId=${selectedCourse.courseId}">
            <i class="fas fa-book-open"></i> Materials
        </a>
        <a class="ws-nav-link-modern ${requestScope.currentCourseFlow == 'assessments' ? 'active' : ''}" href="${courseAssessmentsUrl}">
            <i class="fas fa-tasks"></i> Assessments
        </a>
        <a class="ws-nav-link-modern ${requestScope.currentCourseFlow == 'students' ? 'active' : ''}" href="${courseStudentsUrl}">
            <i class="fas fa-users"></i> Students
        </a>
    </nav>
</c:if>
