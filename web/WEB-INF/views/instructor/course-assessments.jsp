<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Course Assessments - Instructor</title>
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessment-flow.css">
                <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp" />
            </head>

            <body class="instructor-ui">
                <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
                    <jsp:param name="pageTitle" value="Course Assessments" />
                </jsp:include>

                <c:set var="activeInstructorPage" value="assessments" />
                <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp" />


                <main class="app-main">
                    <div class="content-wrapper">
                        <jsp:include page="/WEB-INF/views/instructor/fragments/assessment-breadcrumb.jsp">
                            <jsp:param name="currentLabel" value="Course Assessments" />
                        </jsp:include>

                        <c:set var="currentCourseFlow" value="assessments" />
                        <jsp:include page="/WEB-INF/views/instructor/fragments/course-flow-nav.jsp" />

                        <section class="ins-page-head">
                            <div>
                                <p class="ins-page-kicker">Course Assessments</p>
                                <h2>${not empty selectedCourse ? selectedCourse.courseName : 'Manage Course
                                    Assessments'}</h2>
                            </div>
                            <div class="ins-hero-actions">
                                <c:if test="${not empty selectedCourse}">
                                    <a href="${pageContext.request.contextPath}/instructor/assessments?view=archive&courseId=${selectedCourse.courseId}"
                                        class="btn btn-secondary">
                                        <i class="fas fa-box-archive"></i> Archive
                                    </a>
                                    <a href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}"
                                        class="btn btn-primary">
                                        <i class="fas fa-plus-circle"></i> Add Assessment
                                    </a>
                                </c:if>
                            </div>
                        </section>

                        <!-- Search & Filter Bar -->
                        <div class="ia-filter-bar">
                            <form method="get" action="${pageContext.request.contextPath}/instructor/assessments"
                                class="ia-filter-group" id="courseFilterForm">
                                <label for="courseId"><i class="fas fa-book"></i> Active Course:</label>
                                <select id="courseId" name="courseId" onchange="this.form.submit()" required>
                                    <option value="">-- Select Course Workspace --</option>
                                    <c:forEach var="c" items="${courses}">
                                        <option value="${c.courseId}" <c:if
                                            test="${not empty selectedCourse and selectedCourse.courseId == c.courseId}">
                                            selected</c:if>>
                                            ${c.courseName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </form>
                            <div class="ia-filter-group" style="justify-content: flex-end;">
                                <span style="font-size: 0.85rem; color: var(--ins-muted);">
                                    <strong>${not empty assessments ? fn:length(assessments) : 0}</strong> Assessments
                                    Found
                                </span>
                            </div>
                        </div>

                        <!-- Messages -->
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}
                            </div>
                        </c:if>
                        <c:if test="${param.success == 'created'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment created
                                successfully!</div>
                        </c:if>
                        <c:if test="${param.success == 'draftsaved'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment draft saved.
                                You can publish it anytime.</div>
                        </c:if>
                        <c:if test="${param.success == 'finished'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment setup
                                completed successfully.</div>
                        </c:if>
                        <c:if test="${param.success == 'published'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment published
                                successfully.</div>
                        </c:if>
                        <c:if test="${param.success == 'deleted'}">
                            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment deleted
                                successfully.</div>
                        </c:if>

                        <c:choose>
                            <c:when test="${empty selectedCourse}">
                                <div class="ia-empty-state">
                                    <div class="ia-empty-icon"><i class="fas fa-arrow-up"></i></div>
                                    <h3>Get Started</h3>
                                </div>
                            </c:when>
                            <c:when test="${activeView == 'archive'}">
                                <div class="ia-archive-header">
                                    <h3>Archived Assessments</h3>
                                    <c:if test="${not empty archivedAssessments}">
                                        <form method="post"
                                            action="${pageContext.request.contextPath}/instructor/assessments"
                                            style="display:inline;">
                                            <input type="hidden" name="action" value="bulkRestoreAssessments">
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                            <c:forEach var="aa" items="${archivedAssessments}">
                                                <input type="hidden" name="assessmentIds" value="${aa.assessmentId}">
                                            </c:forEach>
                                            <button type="submit" class="btn btn-secondary btn-sm"
                                                onclick="return confirm('Restore all archived assessments?');">
                                                <i class="fas fa-trash-arrow-up"></i> Restore All
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                                <c:choose>
                                    <c:when test="${empty archivedAssessments}">
                                        <div class="ia-empty-state">
                                            <div class="ia-empty-icon"><i class="fas fa-box-open"></i></div>
                                            <h3>Archive is Empty</h3>
                                            <p>No archived assessments found for this course.</p>
                                            <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}"
                                                class="btn btn-primary">
                                                <i class="fas fa-arrow-left"></i> Back to Assessments
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="ia-assessment-grid">
                                            <c:forEach var="a" items="${archivedAssessments}">
                                                <article class="ia-assessment-card type-${fn:toLowerCase(a.type)}">
                                                    <div class="ia-card-header">
                                                        <div class="ia-card-title-area">
                                                            <h3>${a.title}</h3>
                                                            <div class="ia-card-subtitle">Archived</div>
                                                        </div>
                                                    </div>
                                                    <div class="ia-card-footer">
                                                        <form method="get"
                                                            action="${pageContext.request.contextPath}/instructor/assessments">
                                                            <input type="hidden" name="action"
                                                                value="restoreAssessment">
                                                            <input type="hidden" name="courseId"
                                                                value="${selectedCourse.courseId}">
                                                            <input type="hidden" name="id" value="${a.assessmentId}">
                                                            <button type="submit" class="btn btn-primary btn-sm">
                                                                <i class="fas fa-trash-arrow-up"></i> Restore
                                                            </button>
                                                        </form>
                                                    </div>
                                                </article>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:when test="${empty assessments}">
                                <div class="ia-empty-state">
                                    <div class="ia-empty-icon"><i class="fas fa-clipboard-list"></i></div>
                                    <h3>No Assessments Yet</h3>
                                    <a href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}"
                                        class="btn btn-primary">
                                        <i class="fas fa-plus"></i> Build First Assessment
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="ia-assessment-grid">
                                    <c:forEach var="a" items="${assessments}">
                                        <article class="ia-assessment-card type-${fn:toLowerCase(a.type)}">
                                            <div
                                                class="ia-status-tag status-${fn:toLowerCase(statusByAssessmentId[a.assessmentId])}">
                                                ${statusByAssessmentId[a.assessmentId]}
                                            </div>

                                            <div class="ia-card-type-icon">
                                                <c:choose>
                                                    <c:when test="${a.type == 'Quiz'}"><i class="fas fa-bolt"></i>
                                                    </c:when>
                                                    <c:when test="${a.type == 'Exam'}"><i
                                                            class="fas fa-graduation-cap"></i></c:when>
                                                    <c:otherwise><i class="fas fa-file-pen"></i></c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="ia-card-header">
                                                <div class="ia-card-title-area">
                                                    <h3>${a.title}</h3>
                                                    <div class="ia-card-subtitle">${a.type} &bull; Course Requirement
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="ia-card-stats">
                                                <div class="ia-stat-item">
                                                    <span
                                                        class="ia-stat-value">${submissionCountByAssessmentId[a.assessmentId]}</span>
                                                    <span class="ia-stat-label">Submissions</span>
                                                </div>
                                                <div class="ia-stat-item">
                                                    <span
                                                        class="ia-stat-value">${questionCountByAssessmentId[a.assessmentId]
                                                        != null ? questionCountByAssessmentId[a.assessmentId] :
                                                        0}</span>
                                                    <span class="ia-stat-label">Questions</span>
                                                </div>
                                                <div class="ia-stat-item">
                                                    <span class="ia-stat-value">${a.totalMarks != null ? a.totalMarks :
                                                        'N/A'}</span>
                                                    <span class="ia-stat-label">Total Marks</span>
                                                </div>
                                            </div>

                                            <div class="ia-card-footer">
                                                <a href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}"
                                                    class="btn btn-secondary btn-sm" title="Edit Assessment Details">
                                                    <i class="fas fa-pen-to-square"></i> Modify
                                                </a>

                                                <c:if test="${a.type == 'Quiz' or a.type == 'Exam'}">
                                                    <a href="${pageContext.request.contextPath}/instructor/assessments?view=questions&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}"
                                                        class="btn btn-secondary btn-sm" title="Manage Questions">
                                                        <i class="fas fa-list-check"></i> Bank
                                                    </a>
                                                </c:if>

                                                <a href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}"
                                                    class="btn btn-primary btn-sm">
                                                    <i
                                                        class="fas ${a.type == 'Assignment' ? 'fa-pen-to-square' : 'fa-chart-column'}"></i>
                                                    <c:choose>
                                                        <c:when test="${a.type == 'Assignment'}">Grade Submissions
                                                        </c:when>
                                                        <c:otherwise>Results</c:otherwise>
                                                    </c:choose>
                                                </a>

                                                <a href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&courseId=${selectedCourse.courseId}&id=${a.assessmentId}"
                                                    class="btn btn-danger btn-sm"
                                                    onclick="return confirm('Archive this assessment? You can restore it from archive later.');"
                                                    title="Archive Assessment">
                                                    <i class="fas fa-box-archive"></i> Archive
                                                </a>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </main>



            </body>

            </html>