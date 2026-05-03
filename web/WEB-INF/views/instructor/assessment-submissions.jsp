<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submissions & Grading - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    <style>
        .submission-grid {
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 24px;
            align-items: start;
        }
        .grading-panel {
            position: sticky;
            top: 90px;
            border: 1px solid var(--ins-border);
            border-radius: 12px;
            background: #ffffff;
        }
        @media (max-width: 1024px) {
            .submission-grid {
                grid-template-columns: 1fr;
            }
            .grading-panel {
                position: static;
            }
        }
        .file-download-box {
            padding: 14px;
            border: 1px solid var(--ins-border);
            border-radius: 8px;
            background: #f8fafc;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }
        .file-download-box i {
            font-size: 1.5rem;
            color: var(--ins-primary);
        }
    </style>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Submissions & Grading"/>
</jsp:include>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>


<main class="app-main">
    <div class="content-wrapper">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <c:if test="${not empty selectedCourse}">
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/instructor/courses?action=workspace&courseId=${selectedCourse.courseId}">${selectedCourse.courseName}</a>
            </c:if>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}">Assessment Hub</a>
            <span>&gt;</span>
            <span>Submissions</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Submissions & Grading</p>
                <h2>Review: ${selectedAssessment.title}</h2>
                <p>Manage student performance, provide feedback, and finalize grades. MCQ-based assessments can be auto-regraded if necessary.</p>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Hub
                </a>
            </div>
        </section>

        <!-- Messages -->
        <c:if test="${param.success == 'graded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Grade saved for student.</div></c:if>
        <c:if test="${param.success == 'autoregraded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> MCQ auto-graded successfully.</div></c:if>
        <c:if test="${param.error == 'graderange'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Invalid score. Must be between 0 and ${selectedAssessment.totalMarks}.</div></c:if>
        <c:if test="${not empty errorMessage}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div></c:if>

        <div style="display: grid; grid-template-columns: 1fr 400px; gap: 32px; align-items: start;">
            <!-- Left Side: Roster -->
            <div class="section-card" style="padding: 0; overflow: hidden;">
                <div style="padding: 24px; border-bottom: 1px solid var(--ins-border); display: flex; justify-content: space-between; align-items: center;">
                    <h3 style="margin: 0; font-size: 1.1rem; color: var(--ins-text);">Student Roster</h3>
                    <span style="font-size: 0.85rem; color: var(--ins-muted); background: #f1f5f9; padding: 4px 12px; border-radius: 999px;">
                        <strong>${fn:length(assessmentRosterRows)}</strong> Enrolled
                    </span>
                </div>
                
                <c:choose>
                    <c:when test="${empty assessmentRosterRows}">
                        <div class="ia-empty-state" style="padding: 60px 24px;">
                            <div class="ia-empty-icon"><i class="fas fa-users-slash"></i></div>
                            <h3>No Students</h3>
                            <p>There are currently no students enrolled in this course.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="dashboard-table" style="margin: 0; border: none;">
                                <thead>
                                    <tr>
                                        <th style="padding-left: 24px;">Student Details</th>
                                        <th>Status</th>
                                        <th>Attempt</th>
                                        <th>Score</th>
                                        <th style="text-align: right; padding-right: 24px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="row" items="${assessmentRosterRows}">
                                        <tr style="background: ${not empty selectedSubmission and row.latestSubmission.submissionId == selectedSubmission.submissionId ? 'var(--ins-accent-soft)' : 'transparent'};">
                                            <td style="padding-left: 24px;">
                                                <div style="display: flex; flex-direction: column; gap: 2px;">
                                                    <strong style="color: var(--ins-text);">${row.studentName}</strong>
                                                    <span style="font-size: 0.8rem; color: var(--ins-muted);">${row.studentEmail}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="status-badge status-${fn:toLowerCase(fn:replace(row.studentStatusLabel, ' ', '-'))}" style="font-size: 0.75rem;">
                                                    ${row.studentStatusLabel}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty row.latestSubmission}">
                                                        <span style="font-size: 0.9rem; font-weight: 600; color: var(--ins-text);">#${row.latestSubmission.attemptNumber}</span>
                                                    </c:when>
                                                    <c:otherwise><span style="color: var(--ins-muted);">--</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty row.latestSubmission and row.latestSubmission.score != null}">
                                                        <strong style="color: var(--ins-primary);">${row.latestSubmission.score}</strong> <span style="font-size: 0.8rem; color: var(--ins-muted);">/ ${selectedAssessment.totalMarks}</span>
                                                    </c:when>
                                                    <c:otherwise><span style="color: var(--ins-muted);">--</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: right; padding-right: 24px;">
                                                <c:choose>
                                                    <c:when test="${not empty row.latestSubmission}">
                                                        <a href="${pageContext.request.contextPath}/instructor/assessments?view=submissions&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&submissionId=${row.latestSubmission.submissionId}" class="btn btn-secondary btn-sm" style="font-size: 0.75rem; padding: 6px 12px;">
                                                            Review Work
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="font-size: 0.75rem; color: var(--ins-muted); font-style: italic;">No work</span>
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

            <!-- Right Side: Grading Panel -->
            <div class="section-card" style="position: sticky; top: 94px; padding: 0; overflow: hidden; border-color: var(--ins-primary);">
                <div style="padding: 20px 24px; background: var(--ins-primary); color: #fff;">
                    <h3 style="margin: 0; font-size: 1.1rem; color: #fff;"><i class="fas fa-pen-nib"></i> Grading Panel</h3>
                </div>
                
                <div style="padding: 24px;">
                    <c:choose>
                        <c:when test="${empty selectedSubmission}">
                            <div class="ia-empty-state" style="padding: 40px 0; border: none;">
                                <div class="ia-empty-icon"><i class="fas fa-mouse-pointer"></i></div>
                                <p style="font-size: 0.9rem; color: var(--ins-muted);">Select a student from the list to begin grading their work.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid var(--ins-border);">
                                <span style="font-size: 0.7rem; color: var(--ins-muted); text-transform: uppercase; font-weight: 800; letter-spacing: 0.05em; display: block; margin-bottom: 6px;">Evaluation For</span>
                                <h4 style="margin: 0; font-size: 1.2rem; color: var(--ins-text);">Submission #${selectedSubmission.submissionId}</h4>
                                <div style="font-size: 0.85rem; color: var(--ins-muted); margin-top: 6px; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-calendar-day"></i> <fmt:formatDate value="${selectedSubmission.submitDate}" pattern="MMM dd, HH:mm" />
                                </div>
                            </div>

                            <c:if test="${not empty selectedSubmission.answersFilePath}">
                                <div style="margin-bottom: 24px; padding: 16px; background: #f8fafc; border: 1px solid var(--ins-border); border-radius: 12px; display: flex; align-items: center; gap: 14px;">
                                    <div style="width: 40px; height: 40px; border-radius: 10px; background: #fff; display: flex; align-items: center; justify-content: center; color: var(--ins-primary); box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                                        <i class="fas fa-file-pdf" style="font-size: 1.2rem;"></i>
                                    </div>
                                    <div style="flex: 1;">
                                        <strong style="display: block; font-size: 0.85rem; color: var(--ins-text);">Submission File</strong>
                                        <a href="${pageContext.request.contextPath}/uploads/${selectedSubmission.answersFilePath}" target="_blank" style="font-size: 0.8rem; color: var(--ins-primary); font-weight: 600; text-decoration: none;">Download Asset <i class="fas fa-download" style="font-size: 0.7rem;"></i></a>
                                    </div>
                                </div>
                            </c:if>

                            <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form">
                                <input type="hidden" name="action" value="gradeSubmission" />
                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                                <input type="hidden" name="submissionId" value="${selectedSubmission.submissionId}" />
                                <input type="hidden" name="workflowAction" value="submissions" />

                                <div style="margin-bottom: 20px;">
                                    <label for="score" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Final Score <span style="color: #dc2626;">*</span></label>
                                    <div style="position: relative;">
                                        <input id="score" name="score" type="number" min="0" max="${selectedAssessment.totalMarks}" step="0.5" value="${selectedSubmission.score}" style="width: 100%; border: 1px solid var(--ins-border); border-radius: 10px; padding: 14px; font-size: 1.2rem; font-weight: 800; color: var(--ins-primary);" required />
                                        <span style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); font-weight: 700; color: var(--ins-muted); pointer-events: none;">/ ${selectedAssessment.totalMarks}</span>
                                    </div>
                                </div>

                                <div style="margin-bottom: 24px;">
                                    <label for="feedback" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Feedback for Student</label>
                                    <textarea id="feedback" name="feedback" rows="5" style="width: 100%; border: 1px solid var(--ins-border); border-radius: 10px; padding: 12px; font-size: 0.9rem; line-height: 1.5;" placeholder="What did they do well? What can be improved?">${selectedSubmission.feedback}</textarea>
                                </div>

                                <button class="btn btn-primary" type="submit" style="width: 100%; justify-content: center; padding: 14px;">
                                    <i class="fas fa-check-double"></i> Save Final Grade
                                </button>
                                
                                <c:if test="${selectedAssessment.type == 'Quiz' or selectedAssessment.type == 'Exam'}">
                                    <div style="margin-top: 16px; padding-top: 16px; border-top: 1px dashed var(--ins-border);">
                                        <button type="submit" formaction="${pageContext.request.contextPath}/instructor/assessments?action=autoRegradeSubmission&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&submissionId=${selectedSubmission.submissionId}" class="btn btn-secondary" style="width: 100%; justify-content: center;" onclick="return confirm('Recalculate score based on current MCQ bank answers?');">
                                            <i class="fas fa-wand-sparkles"></i> Auto-Regrade MCQ
                                        </button>
                                    </div>
                                </c:if>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</main>



<script>
    document.addEventListener("DOMContentLoaded", () => {
        const toggleBtn = document.getElementById("instructorMenuToggle");
        if (toggleBtn) {
            toggleBtn.addEventListener("click", () => {
                document.body.classList.toggle("ins-shell-collapsed");
            });
        }
    });
</script>
</body>
</html>
