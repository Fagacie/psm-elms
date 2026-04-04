<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="studentProfilePicture" value="${not empty sessionScope.student.passportPath ? sessionScope.student.passportPath : null}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessments - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-v2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-assessments-v2.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="sv-page">
<header class="sv-topbar">
    <div class="sv-top-left">
        <button class="sv-menu-btn" id="svMenuBtn" type="button" aria-label="Toggle navigation"><i class="fas fa-bars"></i></button>
        <a href="${pageContext.request.contextPath}/dashboard" class="sv-brand"><span class="sv-brand-main">PSM</span><span class="sv-brand-sub">E-Learning</span></a>
        <div class="sv-page-title"><h1>Assessments</h1><p>Attempt flow, grading, and retakes</p></div>
    </div>
    <div class="sv-top-right"><a href="${pageContext.request.contextPath}/profile" class="sv-profile-link"><c:choose><c:when test="${not empty studentProfilePicture}"><c:choose><c:when test="${fn:startsWith(studentProfilePicture, 'http')}"><img src="${studentProfilePicture}" alt="Profile" class="sv-avatar-img"></c:when><c:otherwise><img src="${pageContext.request.contextPath}${studentProfilePicture}" alt="Profile" class="sv-avatar-img"></c:otherwise></c:choose></c:when><c:otherwise><i class="fas fa-user"></i></c:otherwise></c:choose><span>${sessionScope.userName}</span></a><a href="${pageContext.request.contextPath}/logout" class="sv-logout"><i class="fas fa-right-from-bracket"></i> Logout</a></div>
</header>

<div class="sv-layout">
    <aside class="sv-sidebar" id="svSidebar">
        <nav class="sv-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="sv-nav-link"><i class="fas fa-house"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-nav-link"><i class="fas fa-book-open"></i><span>My Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/courses" class="sv-nav-link"><i class="fas fa-compass"></i><span>Browse Courses</span></a>
            <a href="${pageContext.request.contextPath}/student/certificates" class="sv-nav-link"><i class="fas fa-certificate"></i><span>Certificates</span></a>
            <a href="${pageContext.request.contextPath}/profile" class="sv-nav-link"><i class="fas fa-user-gear"></i><span>Profile</span></a>
        </nav>
    </aside>

    <main class="sv-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
            <span>/</span>
            <span>Assessments</span>
        </div>

        <section class="sv-metrics ass-metrics">
            <article class="sv-metric"><h3>${not empty paidEnrollments ? paidEnrollments.size() : 0}</h3><p>Paid Courses</p></article>
            <article class="sv-metric"><h3>${not empty assessments ? assessments.size() : 0}</h3><p>Assessments Loaded</p></article>
            <article class="sv-metric"><h3>${selectedEnrollmentSync != null ? selectedEnrollmentSync.passedAssessments : (not empty submissionHistory ? submissionHistory.size() : 0)}</h3><p>Passed Assessments</p></article>
            <article class="sv-metric"><h3>${modeAttempt ? 'Live' : 'Ready'}</h3><p>Attempt Status</p></article>
        </section>

        <c:if test="${not fromHub}">
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <strong>Tip:</strong> You can take assessments inside your course Learning Hub.
                <a href="${pageContext.request.contextPath}/student/my-enrollments" class="sv-link-inline">Open Learning Hub</a>.
            </div>
        </c:if>

        <div class="ass-alert-stack" role="status" aria-live="polite">
            <c:if test="${not empty errorMessage}"><div class="alert alert-error">${errorMessage}</div></c:if>
            <c:if test="${param.success == 'submitted'}"><div class="alert alert-success">Assessment submitted.</div></c:if>
            <c:if test="${param.success == 'retakerequested'}"><div class="alert alert-success">Retake request sent to instructor.</div></c:if>
            <c:if test="${param.error == 'attempts'}"><div class="alert alert-error">Attempt limit reached for this assessment.</div></c:if>
            <c:if test="${param.error == 'timeout'}"><div class="alert alert-error">Time is up. Your attempt was submitted automatically.</div></c:if>
            <c:if test="${param.error == 'retakepending'}"><div class="alert alert-error">You already have a pending retake request.</div></c:if>
            <c:if test="${param.error == 'retakereason'}"><div class="alert alert-error">Please add a reason before requesting another attempt.</div></c:if>
            <c:if test="${param.error == 'assignmentfile'}"><div class="alert alert-error">Assignment requires a file upload.</div></c:if>
            <c:if test="${param.error == 'submitfailed'}"><div class="alert alert-error">We could not save your attempt. Please retry submission.</div></c:if>
            <c:if test="${param.error == 'permission'}"><div class="alert alert-error">You do not have access to that assessment.</div></c:if>
        </div>

        <c:if test="${selectedEnrollmentSync != null}">
            <section class="sv-card sv-gap-top-12 ass-list-card">
                <div class="sv-card-head">
                    <div class="ass-summary-copy">
                        <h3>Assessment Impact on Certificate</h3>
                        <p>See how your assessment results affect certificate readiness for the selected course.</p>
                    </div>
                    <span class="status-badge ${selectedEnrollmentSync.eligibleForCertificate ? 'status-Approved' : 'status-Pending'}">
                        ${selectedEnrollmentSync.eligibleForCertificate ? 'Certificate Ready' : 'Still In Progress'}
                    </span>
                </div>
                <div class="sv-card-body">
                    <div class="sv-metrics">
                        <article class="sv-metric"><h3>${selectedEnrollmentSync.passedAssessments}/${selectedEnrollmentSync.totalAssessments}</h3><p>Required Assessments Passed</p></article>
                        <article class="sv-metric"><h3>${selectedEnrollmentSync.progressPercent}%</h3><p>Course Progress</p></article>
                        <article class="sv-metric"><h3>${selectedEnrollmentSync.paid ? 'Paid' : 'Pending'}</h3><p>Payment State</p></article>
                    </div>
                    <div class="alert ${selectedEnrollmentSync.eligibleForCertificate ? 'alert-success' : 'alert-info'} sv-gap-top-12">
                        <c:choose>
                            <c:when test="${selectedEnrollmentSync.eligibleForCertificate}">
                                This course already satisfies the current certificate rules. You can return to the Learning Hub or certificate area any time.
                            </c:when>
                            <c:when test="${selectedEnrollmentSync.totalAssessments > selectedEnrollmentSync.passedAssessments}">
                                Passing the remaining assessment items here will immediately improve certificate readiness for this course.
                            </c:when>
                            <c:otherwise>
                                Your assessment progress is recorded, but certificate generation may still depend on course progress or payment completion.
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${selectedEnrollment != null}">
                        <div class="attempt-toolbar sv-gap-top-10">
                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${selectedEnrollment.enrollmentId}&tab=learning">Open Learning Hub</a>
                            <a class="sv-btn" href="${pageContext.request.contextPath}/student/certificates">Open Certificates</a>
                        </div>
                    </c:if>
                </div>
            </section>
        </c:if>

        <c:choose>
            <c:when test="${empty paidEnrollments}">
                <section class="sv-card">
                    <div class="sv-card-body">
                        <div class="empty-state-box">
                            <i class="fas fa-lock"></i>
                            <p>You do not have any paid enrollments yet. Complete payment to access assessments.</p>
                        </div>
                    </div>
                </section>
            </c:when>
            <c:otherwise>
                <c:if test="${not modeAttempt and not fromHub}">
                    <section class="sv-card ass-course-selector">
                        <div class="sv-card-body">
                            <p class="ass-selector-note">Choose a paid course to load its assessment workspace.</p>
                            <form method="get" action="${pageContext.request.contextPath}/student/assessments" class="sv-flow-form-inline">
                                <label for="courseId"><strong>Select Paid Course</strong></label>
                                <select id="courseId" name="courseId" required>
                                    <c:forEach var="e" items="${paidEnrollments}">
                                        <option value="${e.courseId}" <c:if test="${selectedCourseId == e.courseId}">selected</c:if>>${e.courseName}</option>
                                    </c:forEach>
                                </select>
                                <button class="sv-btn primary" type="submit">Load</button>
                            </form>
                        </div>
                    </section>

                    <section class="sv-card ass-list-card">
                        <div class="sv-card-head">
                            <div class="ass-summary-copy">
                                <h3>Assessments: ${selectedCourse.courseName}</h3>
                                <p>Start, continue, or review assessment attempts for this course from one clear list.</p>
                            </div>
                            <span class="assessment-type-badge assessment-type-Quiz">Assessment List</span>
                        </div>
                        <div class="sv-card-body">
                            <c:choose>
                                <c:when test="${empty assessments}">
                                    <div class="empty-state-box"><p>No assessments published for this course yet.</p></div>
                                </c:when>
                                <c:otherwise>
                                    <div class="sv-table-wrap">
                                    <table class="assessment-table">
                                        <thead>
                                        <tr>
                                            <th scope="col">Title</th>
                                            <th scope="col">Type</th>
                                            <th scope="col">Duration</th>
                                            <th scope="col">Attempts</th>
                                            <th scope="col">Latest Score</th>
                                            <th scope="col">Action</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="a" items="${assessments}">
                                            <c:set var="rowUsedAttempts" value="${usedAttemptsByAssessment[a.assessmentId]}"/>
                                            <c:set var="rowAllowedAttempts" value="${allowedAttemptsByAssessment[a.assessmentId]}"/>
                                            <c:set var="rowActiveAttempt" value="${activeAttemptByAssessment[a.assessmentId]}"/>
                                            <c:set var="rowPendingRetake" value="${hasPendingRetakeByAssessment[a.assessmentId]}"/>
                                            <tr>
                                                <td>${a.title}</td>
                                                <td><span class="assessment-type-badge assessment-type-${a.type}">${a.type}</span></td>
                                                <td><c:out value="${a.duration}" default="30"/> min</td>
                                                <td>
                                                    ${rowUsedAttempts}/${rowAllowedAttempts}
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty latestSubmissionByAssessment[a.assessmentId] and not empty latestSubmissionByAssessment[a.assessmentId].score}">${latestSubmissionByAssessment[a.assessmentId].score}</c:when>
                                                        <c:otherwise>-</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${fromHub}">
                                                            <a class="sv-btn" aria-label="View assessment ${a.title}" href="${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${a.assessmentId}&fromHub=1&enrollmentId=${fromHubEnrollmentId}">View</a>
                                                            <c:choose>
                                                                <c:when test="${rowActiveAttempt}">
                                                                    <a class="sv-btn primary" aria-label="Continue assessment ${a.title}" href="${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${a.assessmentId}&mode=attempt&page=1&fromHub=1&enrollmentId=${fromHubEnrollmentId}">Continue</a>
                                                                </c:when>
                                                                <c:when test="${rowUsedAttempts < rowAllowedAttempts}">
                                                                    <a class="sv-btn primary" aria-label="Start assessment ${a.title}" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${selectedCourseId}&assessmentId=${a.assessmentId}&fromHub=1&enrollmentId=${fromHubEnrollmentId}">Start</a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="sv-btn disabled" aria-disabled="true">${rowPendingRetake ? 'Retake Pending' : 'No Attempts'}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a class="sv-btn" aria-label="View assessment ${a.title}" href="${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${a.assessmentId}">View</a>
                                                            <c:choose>
                                                                <c:when test="${rowActiveAttempt}">
                                                                    <a class="sv-btn primary" aria-label="Continue assessment ${a.title}" href="${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${a.assessmentId}&mode=attempt&page=1">Continue</a>
                                                                </c:when>
                                                                <c:when test="${rowUsedAttempts < rowAllowedAttempts}">
                                                                    <a class="sv-btn primary" aria-label="Start assessment ${a.title}" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${selectedCourseId}&assessmentId=${a.assessmentId}">Start</a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="sv-btn disabled" aria-disabled="true">${rowPendingRetake ? 'Retake Pending' : 'No Attempts'}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>
                </c:if>

                <c:if test="${not empty selectedAssessment}">
                    <section class="sv-card ass-detail-card">
                        <div class="sv-card-body">
                            <div class="attempt-header">
                                <div>
                                    <h3>${modeAttempt ? 'Attempt In Progress' : 'Assessment Details'}: ${selectedAssessment.title}</h3>
                                    <div class="attempt-meta">
                                        <span><strong>Type:</strong> ${selectedAssessment.type}</span>
                                        <span><strong>Duration:</strong> <c:out value="${selectedAssessment.duration}" default="30"/> minutes</span>
                                        <span><strong>Attempts:</strong> ${usedAttempts}/${allowedAttempts}</span>
                                    </div>
                                </div>
                                <c:if test="${modeAttempt}">
                                    <div class="timer-bar"><i class="fas fa-hourglass-half"></i><span>Time Left: <span id="timer" aria-live="polite">--:--</span></span><span>| Page ${currentPage} of ${totalPages}</span></div>
                                </c:if>
                            </div>

                            <c:if test="${fromHub}">
                                <div class="attempt-toolbar">
                                    <a class="sv-btn" href="${pageContext.request.contextPath}/student/enrollment-details?id=${fromHubEnrollmentId}&tab=learning">Back to Learning Hub</a>
                                </div>
                            </c:if>

                            <c:if test="${not empty selectedAssessment.instructions}"><div class="alert alert-info">${selectedAssessment.instructions}</div></c:if>

                            <c:if test="${modeAttempt}">
                                <form method="post" action="${pageContext.request.contextPath}/student/assessments" id="attemptForm" enctype="multipart/form-data">
                                    <input type="hidden" name="courseId" value="${selectedCourseId}">
                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                    <input type="hidden" name="page" value="${currentPage}">
                                    <c:if test="${fromHub}">
                                        <input type="hidden" name="fromHub" value="1">
                                        <input type="hidden" name="enrollmentId" value="${fromHubEnrollmentId}">
                                    </c:if>

                                    <div class="attempt-toolbar">
                                        <c:if test="${currentPage > 1}"><button type="submit" class="sv-btn" name="action" value="savePage" onclick="document.getElementById('navField').value='prev';">Previous</button></c:if>
                                        <c:if test="${currentPage < totalPages}"><button type="submit" class="sv-btn" name="action" value="savePage" onclick="document.getElementById('navField').value='next';">Save and Next</button></c:if>
                                    </div>

                                    <c:forEach var="q" items="${pagedQuestions}" varStatus="loop">
                                        <div class="question-card">
                                            <div class="question-title">Q${(currentPage - 1) * questionsPerPageActual + loop.index + 1}. ${q.questionText}</div>
                                            <c:choose>
                                                <c:when test="${not empty fn:trim(q.optionA) or not empty fn:trim(q.optionB) or not empty fn:trim(q.optionC) or not empty fn:trim(q.optionD)}">
                                                    <div class="question-options">
                                                        <c:if test="${not empty fn:trim(q.optionA)}"><label class="question-option"><input type="radio" name="q_${q.questionId}" value="A" ${currentAnswers[q.questionId] == 'A' ? 'checked' : ''}> A. ${q.optionA}</label></c:if>
                                                        <c:if test="${not empty fn:trim(q.optionB)}"><label class="question-option"><input type="radio" name="q_${q.questionId}" value="B" ${currentAnswers[q.questionId] == 'B' ? 'checked' : ''}> B. ${q.optionB}</label></c:if>
                                                        <c:if test="${not empty fn:trim(q.optionC)}"><label class="question-option"><input type="radio" name="q_${q.questionId}" value="C" ${currentAnswers[q.questionId] == 'C' ? 'checked' : ''}> C. ${q.optionC}</label></c:if>
                                                        <c:if test="${not empty fn:trim(q.optionD)}"><label class="question-option"><input type="radio" name="q_${q.questionId}" value="D" ${currentAnswers[q.questionId] == 'D' ? 'checked' : ''}> D. ${q.optionD}</label></c:if>
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
                                            <label for="answerFile" class="sv-visually-hidden">Upload assignment file</label>
                                            <input id="answerFile" type="file" name="answerFile" accept=".pdf,.doc,.docx,.txt,.rtf,.odt,.zip,.png,.jpg,.jpeg" required>
                                            <p class="sv-course-line sv-gap-top-6">Upload your assignment document. This is required.</p>
                                        </div>
                                    </c:if>

                                    <div class="attempt-toolbar">
                                        <c:if test="${currentPage > 1}"><button type="submit" class="sv-btn" name="action" value="savePage" onclick="document.getElementById('navField').value='prev';">Previous</button></c:if>
                                        <c:if test="${currentPage < totalPages}"><button type="submit" class="sv-btn" name="action" value="savePage" onclick="document.getElementById('navField').value='next';">Next</button></c:if>
                                        <button type="submit" class="sv-btn primary" name="action" value="submit">Submit Attempt</button>
                                    </div>
                                    <input type="hidden" id="navField" name="nav" value="next">
                                </form>
                            </c:if>

                            <c:if test="${not modeAttempt}">
                                <div class="attempt-toolbar">
                                    <c:choose>
                                        <c:when test="${assessmentHasActiveAttempt}">
                                            <c:choose>
                                                <c:when test="${fromHub}">
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${selectedAssessment.assessmentId}&mode=attempt&page=1&fromHub=1&enrollmentId=${fromHubEnrollmentId}">Continue Attempt</a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${selectedAssessment.assessmentId}&mode=attempt&page=1">Continue Attempt</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:when test="${assessmentCanStart}">
                                            <c:choose>
                                                <c:when test="${fromHub}">
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${selectedCourseId}&assessmentId=${selectedAssessment.assessmentId}&fromHub=1&enrollmentId=${fromHubEnrollmentId}">Start Attempt</a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="sv-btn primary" href="${pageContext.request.contextPath}/student/assessments?action=start&courseId=${selectedCourseId}&assessmentId=${selectedAssessment.assessmentId}">Start Attempt</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="sv-btn disabled" aria-disabled="true">No Attempts Remaining</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${canRequestRetake}">
                                    <form method="post" action="${pageContext.request.contextPath}/student/assessments" class="sv-gap-top-10">
                                        <input type="hidden" name="action" value="requestRetake">
                                        <input type="hidden" name="courseId" value="${selectedCourseId}">
                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                        <c:if test="${fromHub}">
                                            <input type="hidden" name="fromHub" value="1">
                                            <input type="hidden" name="enrollmentId" value="${fromHubEnrollmentId}">
                                        </c:if>
                                        <textarea name="reason" rows="3" placeholder="Reason for extra attempt (required)"></textarea>
                                        <button type="submit" class="sv-btn sv-gap-top-8">Request Another Attempt</button>
                                    </form>
                                </c:if>
                                <c:if test="${hasPendingRetake}"><div class="alert alert-info sv-gap-top-10">Your retake request is pending instructor review.</div></c:if>
                            </c:if>

                            <c:if test="${not empty submissionHistory}">
                                <div class="sv-card sv-gap-top-12">
                                    <div class="sv-card-head"><h3>Your Submission History</h3></div>
                                    <div class="sv-card-body">
                                        <div class="sv-table-wrap">
                                        <table class="history-table">
                                            <thead><tr><th scope="col">Attempt</th><th scope="col">Status</th><th scope="col">Score</th><th scope="col">Feedback</th><th scope="col">Submitted</th></tr></thead>
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
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </section>
                </c:if>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<div class="sv-overlay" id="svOverlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>

<c:if test="${modeAttempt}">
<script>
(function() {
    var remaining = ${remainingSeconds};
    var timerEl = document.getElementById('timer');
    var attemptUrl = '${pageContext.request.contextPath}/student/assessments?courseId=${selectedCourseId}&assessmentId=${selectedAssessment.assessmentId}&mode=attempt&page=${currentPage}${fromHub ? '&fromHub=1&enrollmentId=' : ''}${fromHub ? fromHubEnrollmentId : ''}';

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

