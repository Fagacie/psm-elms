<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Assessments - Instructor</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/materials.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<header class="app-header">
    <div class="header-left">
        <div class="logo-section">
            <i class="fas fa-graduation-cap"></i>
            <span>PSM E-Learning</span>
        </div>
        <h1 class="page-title">Course Assessments</h1>
    </div>
    <div class="header-right">
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="fas fa-home"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/courses" class="nav-item">
            <i class="fas fa-book"></i><span>My Courses</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/materials" class="nav-item">
            <i class="fas fa-folder-open"></i><span>Materials</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/assessments" class="nav-item active">
            <i class="fas fa-clipboard-list"></i><span>Assessments</span>
        </a>
        <a href="${pageContext.request.contextPath}/instructor/certificates" class="nav-item">
            <i class="fas fa-certificate"></i><span>Certificates</span>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="fas fa-user"></i><span>Profile</span>
        </a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <div class="section-card" style="margin-bottom:16px;">
            <form method="get" action="${pageContext.request.contextPath}/instructor/assessments" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <label for="courseId"><strong>Select Course</strong></label>
                <select id="courseId" name="courseId" required>
                    <option value="">-- Select --</option>
                    <c:forEach var="c" items="${courses}">
                        <option value="${c.courseId}" <c:if test="${not empty selectedCourse and selectedCourse.courseId == c.courseId}">selected</c:if>>
                            ${c.courseName}
                        </option>
                    </c:forEach>
                </select>
                <button class="btn btn-primary btn-sm" type="submit"><i class="fas fa-filter"></i> Load Assessments</button>
            </form>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>
        <c:if test="${param.success == 'created'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment created.</div></c:if>
        <c:if test="${param.success == 'updated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment updated.</div></c:if>
        <c:if test="${param.success == 'deleted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment deleted.</div></c:if>
        <c:if test="${param.success == 'qcreated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question added.</div></c:if>
        <c:if test="${param.success == 'qdeleted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question deleted.</div></c:if>
        <c:if test="${param.success == 'rreviewed'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Retake request reviewed.</div></c:if>
        <c:if test="${param.success == 'graded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Submission graded successfully.</div></c:if>
        <c:if test="${param.error == 'qoptions'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Quiz/Exam requires options A/B and correct option.</div></c:if>
        <c:if test="${param.error != null and param.error != 'qoptions'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Action failed. Please retry.</div></c:if>

        <c:if test="${not empty selectedCourse}">
            <div class="section-card" style="margin-bottom:16px;">
                <h3>Create Assessment: ${selectedCourse.courseName}</h3>
                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                    <input type="hidden" name="action" value="createAssessment">
                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                    <div class="upload-form-grid">
                        <div class="field">
                            <label>Title</label>
                            <input type="text" name="title" required>
                        </div>
                        <div class="field">
                            <label>Type</label>
                            <select name="type" required>
                                <option value="">Select type</option>
                                <option value="Assignment">Assignment</option>
                                <option value="Quiz">Quiz</option>
                                <option value="Exam">Exam</option>
                            </select>
                        </div>
                        <div class="field">
                            <label>Duration (minutes)</label>
                            <input type="number" min="1" name="duration" placeholder="Optional">
                        </div>
                        <div class="field">
                            <label>Total Marks</label>
                            <input type="number" min="1" name="totalMarks" placeholder="Optional">
                        </div>
                        <div class="field">
                            <label>Max Attempts</label>
                            <input type="number" min="1" max="10" name="maxAttempts" value="1">
                        </div>
                        <div class="field">
                            <label>Questions Per Page</label>
                            <input type="number" min="1" max="20" name="questionsPerPage" value="2">
                        </div>
                        <div class="field full">
                            <label>Instructions</label>
                            <textarea name="instructions" rows="3" placeholder="Assessment instructions"></textarea>
                        </div>
                    </div>
                    <div style="margin-top:12px;">
                        <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-plus"></i> Create Assessment</button>
                    </div>
                </form>
            </div>

            <div class="section-card" style="margin-bottom:16px;">
                <h3>Assessments</h3>
                <c:choose>
                    <c:when test="${empty assessments}">
                        <p>No assessments created for this course yet.</p>
                    </c:when>
                    <c:otherwise>
                        <table class="data-table" style="width:100%;">
                            <thead>
                            <tr>
                                <th>Title</th>
                                <th>Type</th>
                                <th>Duration</th>
                                <th>Total Marks</th>
                                <th>Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="a" items="${assessments}">
                                <tr>
                                    <td>${a.title}</td>
                                    <td>${a.type}</td>
                                    <td><c:out value="${a.duration}" default="-"/></td>
                                    <td><c:out value="${a.totalMarks}" default="-"/></td>
                                    <td>
                                        <div class="material-actions">
                                            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">
                                                <i class="fas fa-list"></i> Questions
                                            </a>
                                            <details style="display:inline-block;">
                                                <summary class="btn btn-secondary btn-sm" style="display:inline-flex; list-style:none; cursor:pointer;">
                                                    <i class="fas fa-pen"></i> Edit
                                                </summary>
                                                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="margin-top:8px; min-width:280px;">
                                                    <input type="hidden" name="action" value="updateAssessment">
                                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                    <input type="hidden" name="assessmentId" value="${a.assessmentId}">
                                                    <input type="text" name="title" value="${a.title}" required style="width:100%; margin-bottom:6px;">
                                                    <select name="type" required style="width:100%; margin-bottom:6px;">
                                                        <option value="Assignment" ${a.type == 'Assignment' ? 'selected' : ''}>Assignment</option>
                                                        <option value="Quiz" ${a.type == 'Quiz' ? 'selected' : ''}>Quiz</option>
                                                        <option value="Exam" ${a.type == 'Exam' ? 'selected' : ''}>Exam</option>
                                                    </select>
                                                    <input type="number" min="1" name="duration" value="${a.duration}" style="width:100%; margin-bottom:6px;" placeholder="Duration in minutes">
                                                    <input type="number" min="1" name="totalMarks" value="${a.totalMarks}" style="width:100%; margin-bottom:6px;" placeholder="Total marks">
                                                    <input type="number" min="1" max="10" name="maxAttempts" value="${a.maxAttempts}" style="width:100%; margin-bottom:6px;" placeholder="Max attempts">
                                                    <input type="number" min="1" max="20" name="questionsPerPage" value="${a.questionsPerPage}" style="width:100%; margin-bottom:6px;" placeholder="Questions per page">
                                                    <textarea name="instructions" rows="2" style="width:100%;">${a.instructions}</textarea>
                                                    <button type="submit" class="btn btn-primary btn-sm" style="margin-top:6px;">Save</button>
                                                </form>
                                            </details>
                                            <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&id=${a.assessmentId}&courseId=${selectedCourse.courseId}" onclick="return confirm('Delete this assessment and all its questions?');">
                                                <i class="fas fa-trash"></i> Delete
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:if test="${not empty selectedAssessment}">
                <div class="section-card">
                    <h3>Questions: ${selectedAssessment.title}</h3>
                    <p class="text-muted">For quiz/exam, set options and correct option. For assignment, options can be blank.</p>
                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="margin-bottom:12px;">
                        <input type="hidden" name="action" value="addQuestion">
                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                        <div class="upload-form-grid">
                            <div class="field full">
                                <label>Question Text</label>
                                <textarea name="questionText" rows="3" required></textarea>
                            </div>
                            <div class="field"><label>Option A</label><input type="text" name="optionA"></div>
                            <div class="field"><label>Option B</label><input type="text" name="optionB"></div>
                            <div class="field"><label>Option C</label><input type="text" name="optionC"></div>
                            <div class="field"><label>Option D</label><input type="text" name="optionD"></div>
                            <div class="field">
                                <label>Correct Option</label>
                                <select name="correctOption">
                                    <option value="">None</option>
                                    <option value="A">A</option>
                                    <option value="B">B</option>
                                    <option value="C">C</option>
                                    <option value="D">D</option>
                                </select>
                            </div>
                            <div class="field">
                                <label>Marks</label>
                                <input type="number" step="0.01" min="0" name="marks">
                            </div>
                        </div>
                        <div style="margin-top:12px;">
                            <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-plus"></i> Add Question</button>
                        </div>
                    </form>

                    <c:choose>
                        <c:when test="${empty questions}">
                            <p>No questions added yet.</p>
                        </c:when>
                        <c:otherwise>
                            <table class="data-table" style="width:100%;">
                                <thead>
                                <tr>
                                    <th>Question</th>
                                    <th>Correct</th>
                                    <th>Marks</th>
                                    <th>Action</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="q" items="${questions}">
                                    <tr>
                                        <td>${q.questionText}</td>
                                        <td><c:out value="${q.correctOption}" default="-"/></td>
                                        <td><c:out value="${q.marks}" default="-"/></td>
                                        <td>
                                            <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteQuestion&id=${q.questionId}&assessmentId=${selectedAssessment.assessmentId}&courseId=${selectedCourse.courseId}" onclick="return confirm('Delete this question?');">
                                                <i class="fas fa-trash"></i> Delete
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>

                    <div class="archived-materials">
                        <h4>Retake Requests</h4>
                        <c:choose>
                            <c:when test="${empty retakeRequests}">
                                <p class="text-muted">No requests yet.</p>
                            </c:when>
                            <c:otherwise>
                                <table class="data-table" style="width:100%;">
                                    <thead>
                                    <tr>
                                        <th>Student ID</th>
                                        <th>Reason</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="r" items="${retakeRequests}">
                                        <tr>
                                            <td>${r.userId}</td>
                                            <td><c:out value="${r.reason}" default="-"/></td>
                                            <td>${r.status}</td>
                                            <td>
                                                <c:if test="${r.status == 'Pending'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="display:inline;">
                                                        <input type="hidden" name="action" value="reviewRetake">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}">
                                                        <input type="hidden" name="requestId" value="${r.requestId}">
                                                        <input type="hidden" name="decision" value="approve">
                                                        <button class="btn btn-secondary btn-sm" type="submit">Approve</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="display:inline;">
                                                        <input type="hidden" name="action" value="reviewRetake">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}">
                                                        <input type="hidden" name="requestId" value="${r.requestId}">
                                                        <input type="hidden" name="decision" value="reject">
                                                        <button class="btn btn-danger btn-sm" type="submit">Reject</button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="archived-materials">
                        <h4>Student Submissions</h4>
                        <div class="materials-toolbar" style="margin-bottom:10px;">
                            <form method="get" action="${pageContext.request.contextPath}/instructor/assessments" class="materials-filter-form">
                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                <label for="gradeFilter"><strong>Filter</strong></label>
                                <select id="gradeFilter" name="gradeFilter">
                                    <option value="all" ${gradeFilter == 'all' ? 'selected' : ''}>All</option>
                                    <option value="graded" ${gradeFilter == 'graded' ? 'selected' : ''}>Graded</option>
                                    <option value="ungraded" ${gradeFilter == 'ungraded' ? 'selected' : ''}>Ungraded</option>
                                    <option value="timedout" ${gradeFilter == 'timedout' ? 'selected' : ''}>Timed Out</option>
                                </select>
                                <button type="submit" class="btn btn-secondary btn-sm">Apply</button>
                            </form>
                            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=exportSubmissionsCsv&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=${gradeFilter}">
                                <i class="fas fa-file-csv"></i> Export CSV
                            </a>
                        </div>
                        <c:choose>
                            <c:when test="${empty submissions}">
                                <p class="text-muted">No submissions yet.</p>
                            </c:when>
                            <c:otherwise>
                                <table class="data-table" style="width:100%;">
                                    <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Attempt</th>
                                        <th>Status</th>
                                        <th>Answer</th>
                                        <th>Score</th>
                                        <th>Grading</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="s" items="${submissions}">
                                        <tr>
                                            <td>
                                                <div><strong><c:out value="${s.studentName}" default="User ${s.userId}"/></strong></div>
                                                <small class="text-muted"><c:out value="${s.studentEmail}" default="-"/></small>
                                            </td>
                                            <td>${s.attemptNumber}</td>
                                            <td><c:out value="${s.status}" default="Submitted"/></td>
                                            <td><small><c:out value="${s.answersFilePath}" default="-"/></small></td>
                                            <td><c:out value="${s.score}" default="Pending"/></td>
                                            <td>
                                                <details>
                                                    <summary class="btn btn-secondary btn-sm" style="list-style:none; cursor:pointer;">Grade</summary>
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" style="margin-top:8px; min-width:260px;">
                                                        <input type="hidden" name="action" value="gradeSubmission">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}">
                                                        <input type="hidden" name="submissionId" value="${s.submissionId}">
                                                        <input type="number" step="0.01" min="0" name="score" value="${s.score}" style="width:100%; margin-bottom:6px;" placeholder="Score">
                                                        <textarea name="feedback" rows="2" style="width:100%;" placeholder="Feedback">${s.feedback}</textarea>
                                                        <button type="submit" class="btn btn-primary btn-sm" style="margin-top:6px;">Save Grade</button>
                                                    </form>
                                                </details>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
        </c:if>
    </div>
</main>
</body>
</html>
