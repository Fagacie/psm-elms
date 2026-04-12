<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="currentPath" value="${pageContext.request.requestURI}"/>
<c:set var="resolvedActivePage" value="${activePage}"/>
<c:if test="${empty resolvedActivePage}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/student/my-enrollments') or fn:contains(currentPath, '/student/enrollment-details') or fn:contains(currentPath, '/student/materials')}">
            <c:set var="resolvedActivePage" value="my-courses"/>
        </c:when>
        <c:when test="${fn:contains(currentPath, '/student/assessments')}">
            <c:set var="resolvedActivePage" value="assessments"/>
        </c:when>
        <c:when test="${fn:contains(currentPath, '/student/courses') or fn:contains(currentPath, '/student/enrollment-summary') or fn:contains(currentPath, '/student/payment')}">
            <c:set var="resolvedActivePage" value="browse-courses"/>
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

<aside class="sv-sidebar" id="svSidebar">
    <nav class="sv-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link ${resolvedActivePage == 'dashboard' ? 'active' : ''}"><i class="fas fa-house"></i><span>Dashboard</span></a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link ${resolvedActivePage == 'my-courses' ? 'active' : ''}"><i class="fas fa-book-open"></i><span>My Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link ${resolvedActivePage == 'browse-courses' ? 'active' : ''}"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="sv-nav-link ${resolvedActivePage == 'assessments' ? 'active' : ''}"><i class="fas fa-clipboard-check"></i><span>Assessments</span></a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link ${resolvedActivePage == 'certificates' ? 'active' : ''}"><i class="fas fa-certificate"></i><span>Certificates</span></a>
        <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link ${resolvedActivePage == 'profile' ? 'active' : ''}"><i class="fas fa-user-gear"></i><span>Profile</span></a>
    </nav>

</aside>