<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="currentPath" value="${requestScope['javax.servlet.forward.request_uri']}"/>
<c:if test="${empty currentPath}">
    <c:set var="currentPath" value="${pageContext.request.requestURI}"/>
</c:if>
<c:set var="resolvedInstructorPage" value="${activeInstructorPage}"/>
<c:if test="${empty resolvedInstructorPage}">
    <c:choose>
        <c:when test="${fn:contains(currentPath, '/instructor/courses')}"><c:set var="resolvedInstructorPage" value="courses"/></c:when>
        <c:when test="${fn:contains(currentPath, '/profile')}"><c:set var="resolvedInstructorPage" value="profile"/></c:when>
        <c:otherwise><c:set var="resolvedInstructorPage" value="dashboard"/></c:otherwise>
    </c:choose>
</c:if>

<aside class="nav_mod_sidebar" id="insSidebar" aria-label="Sidebar navigation">
    <div class="nav_mod_sidebar_shell">
        <nav class="nav_mod_nav" aria-label="Primary navigation">
            <span class="nav_mod_section_label">Management</span>
            
            <a href="${pageContext.request.contextPath}/dashboard" 
               class="nav_mod_link ${resolvedInstructorPage == 'dashboard' ? 'active' : ''}" 
               title="Dashboard">
                <i class="fas fa-table-columns" aria-hidden="true"></i>
                <span class="nav_mod_label">Dashboard</span>
            </a>
            
            <a href="${pageContext.request.contextPath}/instructor/courses" 
               class="nav_mod_link ${resolvedInstructorPage == 'courses' ? 'active' : ''}" 
               title="My Assigned Courses">
                <i class="fas fa-book" aria-hidden="true"></i>
                <span class="nav_mod_label">My Assigned Courses</span>
            </a>
            
            <a href="${pageContext.request.contextPath}/profile" 
               class="nav_mod_link ${resolvedInstructorPage == 'profile' ? 'active' : ''}" 
               title="Profile">
                <i class="fas fa-user-gear" aria-hidden="true"></i>
                <span class="nav_mod_label">Profile</span>
            </a>
            
            <div class="nav_mod_spacer"></div>
            <hr class="nav_mod_divider" />
            
            <a href="${pageContext.request.contextPath}/logout" 
               class="nav_mod_link nav_mod_link_danger" 
               title="Logout">
                <i class="fas fa-right-from-bracket" aria-hidden="true"></i>
                <span class="nav_mod_label">Logout</span>
            </a>
        </nav>
    </div>
</aside>
