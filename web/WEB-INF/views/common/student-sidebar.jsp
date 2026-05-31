<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="currentAction" value="${param.action}"/>
<c:set var="currentMode" value="${param.mode}"/>
<c:set var="resolvedActivePage" value="${activePage}"/>
<c:set var="resolvedNavContext" value="${navContext}"/>
<c:set var="resolvedNavContextPage" value="${navContextPage}"/>

<c:if test="${empty resolvedActivePage}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/student/my-enrollments') or fn:contains(currentPath, '/student/enrollment-details') or (fn:contains(currentPath, '/student/materials') and currentAction == 'preview')}">
            <c:set var="resolvedActivePage" value="my-courses"/>
        </c:when>
        <c:when test="${fn:contains(currentPath, '/student/courses')}">
            <c:set var="resolvedActivePage" value="browse-courses"/>
        </c:when>
                <c:when test="${fn:contains(currentPath, '/student/payments')}">
                    <c:set var="resolvedActivePage" value="payments"/>
                </c:when>
        <c:when test="${fn:contains(currentPath, '/student/certificates') or fn:contains(currentPath, '/student/certificate')}">
            <c:set var="resolvedActivePage" value="certificates"/>
        </c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}">
            <c:set var="resolvedActivePage" value="profile"/>
        </c:when>
        <c:otherwise>
            <c:set var="resolvedActivePage" value="dashboard"/>
        </c:otherwise>
    </c:choose>
</c:if>

<c:if test="${empty resolvedNavContext}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/student/enrollment-details') or (fn:contains(currentPath, '/student/materials') and currentAction == 'preview' and not empty param.enrollmentId)}">
            <c:set var="resolvedNavContext" value="course"/>
        </c:when>
        <c:when test="${fn:contains(currentPath, '/student/assessments') and (not empty param.assessmentId or currentMode == 'attempt')}">
            <c:set var="resolvedNavContext" value="assessment"/>
        </c:when>
        <c:otherwise>
            <c:set var="resolvedNavContext" value="default"/>
        </c:otherwise>
    </c:choose>
</c:if>

<c:if test="${empty resolvedNavContextPage}">
    <c:choose>
        <c:when test="${resolvedNavContext == 'course'}">
            <c:choose>
                <c:when test="${fn:contains(currentPath, '/student/materials') and currentAction == 'preview'}">
                    <c:set var="resolvedNavContextPage" value="materials"/>
                </c:when>
                <c:when test="${param.tab == 'overview'}">
                    <c:set var="resolvedNavContextPage" value="overview"/>
                </c:when>
                <c:when test="${param.tab == 'materials'}">
                    <c:set var="resolvedNavContextPage" value="materials"/>
                </c:when>
                <c:when test="${param.tab == 'assessments'}">
                    <c:set var="resolvedNavContextPage" value="assessments"/>
                </c:when>
                <c:when test="${param.tab == 'performance'}">
                    <c:set var="resolvedNavContextPage" value="performance"/>
                </c:when>
                <c:otherwise>
                    <c:set var="resolvedNavContextPage" value="progress"/>
                </c:otherwise>
            </c:choose>
        </c:when>
        <c:when test="${resolvedNavContext == 'assessment'}">
            <c:set var="resolvedNavContextPage" value="${currentMode == 'attempt' ? 'questions' : 'submit'}"/>
        </c:when>
    </c:choose>
</c:if>

<c:set var="resolvedCourseEnrollmentId" value="${not empty navCourseEnrollmentId ? navCourseEnrollmentId : (not empty enrollment ? enrollment.enrollmentId : (not empty previewEnrollment ? previewEnrollment.enrollmentId : param.enrollmentId))}"/>
<c:set var="resolvedCourseTitle" value="${not empty navCourseTitle ? navCourseTitle : (not empty enrollment.courseName ? enrollment.courseName : (not empty previewEnrollment.courseName ? previewEnrollment.courseName : 'Course Workspace'))}"/>
<c:set var="resolvedAssessmentTitle" value="${not empty navAssessmentTitle ? navAssessmentTitle : (not empty selectedAssessment.title ? selectedAssessment.title : 'Assessment Workspace')}"/>
<c:choose>
    <c:when test="${not empty navAssessmentExitUrl}">
        <c:set var="assessmentExitUrl" value="${navAssessmentExitUrl}"/>
    </c:when>
    <c:when test="${not empty param.enrollmentId}">
        <c:set var="assessmentExitUrl" value="${pageContext.request.contextPath}/student/enrollment-details?id=${param.enrollmentId}&tab=assessments"/>
    </c:when>
    <c:when test="${not empty param.courseId}">
        <c:set var="assessmentExitUrl" value="${pageContext.request.contextPath}/student/my-enrollments"/>
    </c:when>
    <c:otherwise>
        <c:set var="assessmentExitUrl" value="${pageContext.request.contextPath}/student/my-enrollments"/>
    </c:otherwise>
</c:choose>

<aside class="nav_mod_sidebar" id="svSidebar" aria-label="Sidebar navigation">
    <div class="nav_mod_sidebar_shell">
        <nav class="nav_mod_nav" aria-label="Primary navigation">
            <c:choose>
                <c:when test="${resolvedNavContext == 'course' and not empty resolvedCourseEnrollmentId}">
                    <div class="nav_mod_nav_group" aria-label="Course section tabs">
                        <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${resolvedCourseEnrollmentId}&tab=overview"
                           class="nav_mod_link ${resolvedNavContextPage == 'overview' ? 'active' : ''}"
                           title="Course Overview">
                            <i class="fas fa-table-columns" aria-hidden="true"></i>
                            <span class="nav_mod_label">Overview</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/student/enrollment-details?id=${resolvedCourseEnrollmentId}&tab=performance"
                           class="nav_mod_link ${resolvedNavContextPage == 'performance' ? 'active' : ''}"
                           title="Performance">
                            <i class="fas fa-chart-column" aria-hidden="true"></i>
                            <span class="nav_mod_label">Performance</span>
                        </a>
                    </div>
                    <a href="${pageContext.request.contextPath}/dashboard"
                       class="nav_mod_link"
                       title="Back to Dashboard">
                        <i class="fas fa-arrow-left" aria-hidden="true"></i>
                        <span class="nav_mod_label">Back to Dashboard</span>
                    </a>
                </c:when>

                <c:when test="${resolvedNavContext == 'assessment'}">
                    <a href="#assQuestionPanel"
                       class="nav_mod_link ${resolvedNavContextPage == 'questions' ? 'active' : ''}"
                       title="Questions">
                        <i class="fas fa-list-check" aria-hidden="true"></i>
                        <span class="nav_mod_label">Questions</span>
                    </a>
                    <a href="#assTimerPanel"
                       class="nav_mod_link ${resolvedNavContextPage == 'timer' ? 'active' : ''}"
                       title="Timer">
                        <i class="fas fa-stopwatch" aria-hidden="true"></i>
                        <span class="nav_mod_label">Timer</span>
                    </a>
                    <a href="#assessmentPrimaryAction"
                       class="nav_mod_link ${resolvedNavContextPage == 'submit' ? 'active' : ''}"
                       title="Submit">
                        <i class="fas fa-paper-plane" aria-hidden="true"></i>
                        <span class="nav_mod_label">Submit</span>
                    </a>
                    <a href="${assessmentExitUrl}"
                       class="nav_mod_link"
                       title="Exit">
                        <i class="fas fa-xmark" aria-hidden="true"></i>
                        <span class="nav_mod_label">Exit</span>
                    </a>
                </c:when>

                <c:otherwise>
                    <%-- Learning Section --%>
                    <span class="nav_mod_section_label">Learning</span>
                    <a href="${pageContext.request.contextPath}/dashboard"
                       class="nav_mod_link ${resolvedActivePage == 'dashboard' ? 'active' : ''}"
                       title="Dashboard">
                        <i class="fas fa-table-columns" aria-hidden="true"></i>
                        <span class="nav_mod_label">Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/my-enrollments"
                       class="nav_mod_link ${resolvedActivePage == 'my-courses' ? 'active' : ''}"
                       title="My Courses">
                        <i class="fas fa-book-open-reader" aria-hidden="true"></i>
                        <span class="nav_mod_label">My Courses</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/courses"
                       class="nav_mod_link ${resolvedActivePage == 'browse-courses' ? 'active' : ''}"
                       title="Browse Courses">
                        <i class="fas fa-compass" aria-hidden="true"></i>
                        <span class="nav_mod_label">Browse Courses</span>
                    </a>

                    <%-- Resources Section --%>
                    <div class="nav_mod_divider" aria-hidden="true"></div>
                    <span class="nav_mod_section_label">Resources</span>
                    <a href="${pageContext.request.contextPath}/student/payments"
                       class="nav_mod_link ${resolvedActivePage == 'payments' ? 'active' : ''}"
                       title="Payments">
                        <i class="fas fa-receipt" aria-hidden="true"></i>
                        <span class="nav_mod_label">Payments</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/certificates"
                       class="nav_mod_link ${resolvedActivePage == 'certificates' ? 'active' : ''}"
                       title="Certificates">
                        <i class="fas fa-certificate" aria-hidden="true"></i>
                        <span class="nav_mod_label">Certificates</span>
                    </a>

                    <%-- Account Section --%>
                    <div class="nav_mod_divider" aria-hidden="true"></div>
                    <span class="nav_mod_section_label">Account</span>
                    <a href="${pageContext.request.contextPath}/profile"
                       class="nav_mod_link ${resolvedActivePage == 'profile' ? 'active' : ''}"
                       title="Profile">
                        <i class="fas fa-user-gear" aria-hidden="true"></i>
                        <span class="nav_mod_label">Profile</span>
                    </a>
                    <div class="nav_mod_spacer" aria-hidden="true"></div>
                    <a href="${pageContext.request.contextPath}/logout"
                       class="nav_mod_link nav_mod_link_danger"
                       title="Logout">
                        <i class="fas fa-right-from-bracket" aria-hidden="true"></i>
                        <span class="nav_mod_label">Logout</span>
                    </a>
                </c:otherwise>
            </c:choose>
        </nav>
    </div>
</aside>
