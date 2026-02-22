<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessments - Student</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/materials.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<nav class="top-navbar">
    <div class="top-navbar-inner">
        <div class="top-navbar-left">
            <a href="${pageContext.request.contextPath}/dashboard" class="navbar-logo">
                <span class="logo-text">PSM</span><span class="logo-subtext">E-Learning</span>
            </a>
            <h1 class="page-title-nav">Assessments</h1>
        </div>
        <div class="top-navbar-right">
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </div>
</nav>

<aside class="app-sidebar">
    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item"><i class="fas fa-home"></i><span>Dashboard</span></a>
        <a href="${pageContext.request.contextPath}/student/courses" class="nav-item"><i class="fas fa-book"></i><span>Browse Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/my-enrollments" class="nav-item"><i class="fas fa-graduation-cap"></i><span>My Courses</span></a>
        <a href="${pageContext.request.contextPath}/student/assessments" class="nav-item active"><i class="fas fa-clipboard-list"></i><span>Assessments</span></a>
        <a href="${pageContext.request.contextPath}/student/certificates" class="nav-item"><i class="fas fa-certificate"></i><span>Certificates</span></a>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item"><i class="fas fa-user"></i><span>Profile</span></a>
    </nav>
</aside>

<main class="app-main">
    <div class="content-wrapper">
        <c:if test="${not fromHub}">
        <div class="alert alert-info" style="border-left: 4px solid #1a73e8; background: #e8f0fe; border: 1px solid #d2e3fc; padding: 16px; margin-bottom: 24px;">
            <i class="fas fa-info-circle" style="color: #1a73e8;"></i>
            <strong>Tip:</strong> You can now take assessments inside your course
            <a href="${pageContext.request.contextPath}/student/my-enrollments" style="color: #1a73e8; text-decoration: underline;">Learning Hub</a>
            alongside materials.
        </div>
        </c:if>
        <c:if test="${not empty errorMessage}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div></c:if>
        <c:if test="${param.success == 'submitted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment submitted.</div></c:if>
        <c:if test="${param.success == 'retakerequested'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Retake request sent to instructor.</div></c:if>
        <c:if test="${param.error == 'attempts'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Attempt limit reached for this assessment.</div></c:if>
        <c:if test="${param.error == 'timeout'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Time is up. Your attempt was submitted automatically.</div></c:if>
        <c:if test="${param.error == 'retakepending'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> You already have a pending retake request.</div></c:if>
        <c:if test="${param.error == 'assignmentfile'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Assignment requires a file upload.</div></c:if>
        <c:if test="${param.error != null and param.error != 'attempts' and param.error != 'timeout' and param.error != 'retakepending' and param.error != 'assignmentfile'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Action failed.</div></c:if>

        <c:choose>
            <c:when test="${empty paidEnrollments}">
                <div class="section-card"><p>You do not have any paid enrollments yet. Complete payment to access assessments.</p></div>
            </c:when>
            <c:otherwise>
                <c:if test="${not modeAttempt and not fromHub}">
                <div class="section-card" style="margin-bottom:16px;">
                    <form method="get" action="${pageContext.request.contextPath}/student/assessments" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                        <label for="courseId"><strong>Select Paid Course</strong></label>
                        <select id="courseId" name="courseId" required>
                            <c:forEach var="e" items="${paidEnrollments}">
                                <option value="${e.courseId}" <c:if test="${selectedCourseId == e.courseId}">selected</c:if>>${e.courseName}</option>
                            </c:forEach>
                        </select>
                        <button class="btn btn-primary btn-sm" type="submit"><i class="fas fa-filter"></i> Load</button>
                    </form>
                </div>

                <c:if test="${not fromHub}">
                <div class="section-card" style="margin-bottom:16px;">
                    <div class="assessments-hero">
                        <div>
                            <h3>Assessments: ${selectedCourse.courseName}</h3>
                            <p>View and attempt quizzes, exams, and assignments for this course.</p>
                        </div>
                        <span class="assessment-type-badge assessment-type-Quiz">Assessments</span>
                    </div>
                    <c:choose>
                        <c:when test="${empty assessments}">
                            <p>No assessments published for this course yet.</p>
                        </c:when>
                        <c:otherwise>
                            <table class="assessment-table">
                                <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Type</th>
                                    <th>Duration</th>
                                    <th>Attempts</th>
                                    <th>Latest Score</th>
                                    <th>Action</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="a" items="${assessments}">
                                    <tr>
                                        <td>${a.title}</td>
                                        <td>
                                            <span class="assessment-type-badge assessment-type-${a.type}">${a.type}</span>
                                        </td>
                                        <td><c:out value="${a.duration}" default="30"/> min</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${selectedAssessment != null and selectedAssessment.assessmentId == a.assessmentId}">
                                                    ${usedAttempts}/${allowedAttempts}
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty latestSubmissionByAssessment[a.assessmentId] and not empty latestSubmissionByAssessment[a.assessmentId].score}">
                                                    ${latestSubmissionByAssessment[a.assessmentId].score}
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${a.assessmentId}">
                                                <i class="fas fa-eye"></i> View
                                            </a>
                                            <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${selectedCourseId}&assessmentId=${a.assessmentId}">
                                                <i class="fas fa-play"></i> Start
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
                </c:if>
                </c:if>

                <c:if test="${not empty selectedAssessment}">
                    <div class="section-card">
                        <div class="attempt-header">
                            <div>
                                <h3 style="margin:0;">${modeAttempt ? 'Attempt In Progress' : 'Assessment Details'}: ${selectedAssessment.title}</h3>
                                <div class="attempt-meta">
                                    <span><strong>Type:</strong> ${selectedAssessment.type}</span>
                                    <span><strong>Duration:</strong> <c:out value="${selectedAssessment.duration}" default="30"/> minutes</span>
                                    <span><strong>Attempts:</strong> ${usedAttempts}/${allowedAttempts}</span>
                                </div>
                            </div>
                            <c:if test="${modeAttempt}">
                                <div class="timer-bar">
                                    <i class="fas fa-hourglass-half"></i>
                                    <span>Time Left: <span id="timer">--:--</span></span>
                                    <span>| Page ${currentPage} of ${totalPages}</span>
                                </div>
                            </c:if>
                        </div>
                        <c:if test="${fromHub}">
                            <div class="attempt-toolbar" style="justify-content:flex-start;">
                                <a class="btn btn-secondary btn-sm" href="${pageContext.request.contextPath}/student/enrollment-details?id=${fromHubEnrollmentId}&tab=learning">
                                    <i class="fas fa-arrow-left"></i> Back to Learning Hub
                                </a>
                            </div>
                        </c:if>
                        <c:if test="${not empty selectedAssessment.instructions}">
                            <div class="alert alert-info">${selectedAssessment.instructions}</div>
                        </c:if>

                        <c:if test="${modeAttempt}">
                            <div class="attempt-panel">
                            <form method="post" action="${pageContext.request.contextPath}/student/assessments" id="attemptForm" enctype="multipart/form-data">
                                <input type="hidden" name="courseId" value="${selectedCourseId}">
                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                <input type="hidden" name="page" value="${currentPage}">

                                <div class="attempt-toolbar" style="justify-content:flex-start; margin-bottom:12px;">
                                    <c:if test="${currentPage > 1}">
                                        <button type="submit" class="btn btn-secondary" name="action" value="savePage" onclick="document.getElementById('navField').value='prev';">Previous</button>
                                    </c:if>
                                    <c:if test="${currentPage < totalPages}">
                                        <button type="submit" class="btn btn-secondary" name="action" value="savePage" onclick="document.getElementById('navField').value='next';">Save &amp; Next</button>
                                    </c:if>
                                </div>

                                <c:forEach var="q" items="${pagedQuestions}" varStatus="loop">
                                    <div class="question-card">
                                        <div class="question-title">Q${(currentPage - 1) * questionsPerPageActual + loop.index + 1}. ${q.questionText}</div>
                                        <c:choose>
                                            <c:when test="${not empty fn:trim(q.optionA) or not empty fn:trim(q.optionB) or not empty fn:trim(q.optionC) or not empty fn:trim(q.optionD)}">
                                                <div class="question-options">
                                                    <c:if test="${not empty fn:trim(q.optionA)}">
                                                        <label class="question-option"><input type="radio" name="q_${q.questionId}" value="A" ${currentAnswers[q.questionId] == 'A' ? 'checked' : ''}> A. ${q.optionA}</label>
                                                    </c:if>
                                                    <c:if test="${not empty fn:trim(q.optionB)}">
                                                        <label class="question-option"><input type="radio" name="q_${q.questionId}" value="B" ${currentAnswers[q.questionId] == 'B' ? 'checked' : ''}> B. ${q.optionB}</label>
                                                    </c:if>
                                                    <c:if test="${not empty fn:trim(q.optionC)}">
                                                        <label class="question-option"><input type="radio" name="q_${q.questionId}" value="C" ${currentAnswers[q.questionId] == 'C' ? 'checked' : ''}> C. ${q.optionC}</label>
                                                    </c:if>
                                                    <c:if test="${not empty fn:trim(q.optionD)}">
                                                        <label class="question-option"><input type="radio" name="q_${q.questionId}" value="D" ${currentAnswers[q.questionId] == 'D' ? 'checked' : ''}> D. ${q.optionD}</label>
                                                    </c:if>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <textarea name="qa_${q.questionId}" rows="4" class="question-textarea" placeholder="Write your answer">${currentAnswers[q.questionId]}</textarea>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:forEach>

                                <c:if test="${selectedAssessment.type == 'Assignment'}">
                                    <div class="upload-panel">
                                        <p><strong>Required file upload</strong></p>
                                        <input type="file" name="answerFile" accept=".pdf,.doc,.docx,.txt,.rtf,.odt,.zip,.png,.jpg,.jpeg" required>
                                        <p class="text-muted" style="margin-top:6px;">Upload your assignment document. This is required.</p>
                                    </div>
                                </c:if>

                                <div class="attempt-toolbar">
                                    <c:if test="${currentPage > 1}">
                                        <button type="submit" class="btn btn-secondary" name="action" value="savePage" onclick="document.getElementById('navField').value='prev';">Previous</button>
                                    </c:if>
                                    <c:if test="${currentPage < totalPages}">
                                        <button type="submit" class="btn btn-secondary" name="action" value="savePage" onclick="document.getElementById('navField').value='next';">Next</button>
                                    </c:if>
                                    <button type="submit" class="btn btn-primary" name="action" value="submit">Submit Attempt</button>
                                </div>
                                <input type="hidden" id="navField" name="nav" value="next">
                            </form>
                            </div>
                        </c:if>

                        <c:if test="${not modeAttempt}">
                            <div class="attempt-toolbar">
                                <a class="btn btn-primary" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${selectedCourseId}&assessmentId=${selectedAssessment.assessmentId}">
                                    <i class="fas fa-play"></i> Start Attempt
                                </a>
                            </div>
                            <c:if test="${canRequestRetake}">
                                <form method="post" action="${pageContext.request.contextPath}/student/assessments" style="margin-top:12px;">
                                    <input type="hidden" name="action" value="requestRetake">
                                    <input type="hidden" name="courseId" value="${selectedCourseId}">
                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                    <textarea name="reason" rows="3" style="width:100%;" placeholder="Reason for extra attempt (required)"></textarea>
                                    <button type="submit" class="btn btn-secondary" style="margin-top:8px;">Request Another Attempt</button>
                                </form>
                            </c:if>
                            <c:if test="${hasPendingRetake}">
                                <div class="alert alert-info" style="margin-top:12px;">Your retake request is pending instructor review.</div>
                            </c:if>
                        </c:if>

                        <c:if test="${not empty submissionHistory}">
                            <div class="archived-materials">
                                <h4>Your Submission History</h4>
                                <table class="history-table">
                                    <thead><tr><th>Attempt</th><th>Status</th><th>Score</th><th>Feedback</th><th>Submitted</th></tr></thead>
                                    <tbody>
                                    <c:forEach var="s" items="${submissionHistory}">
                                        <tr>
                                            <td>${s.attemptNumber}</td>
                                            <td><c:out value="${s.status}" default="Submitted"/></td>
                                            <td><c:out value="${s.score}" default="Pending"/></td>
                                            <td><c:out value="${s.feedback}" default="-"/></td>
                                            <td><c:out value="${s.submitDate}" default="-"/></td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<c:if test="${modeAttempt}">
<script>
(function() {
    var remaining = ${remainingSeconds};
    var timerEl = document.getElementById('timer');
    var attemptUrl = '${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${selectedAssessment.assessmentId}&mode=attempt&page=${currentPage}';

    function format(sec) {
        var m = Math.floor(sec / 60);
        var s = sec % 60;
        return String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
    }

    function tick() {
        if (!timerEl) return;
        timerEl.textContent = format(Math.max(0, remaining));
        if (remaining <= 0) {
            window.location.href = attemptUrl;
            return;
        }
        remaining -= 1;
        setTimeout(tick, 1000);
    }

    tick();
})();
</script>
</c:if>
</body>
</html>
