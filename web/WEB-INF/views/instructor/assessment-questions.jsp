<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Question Builder - Instructor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    <style>
        .question-card {
            border: 1px solid var(--ins-border);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 16px;
            background: #ffffff;
        }
        .question-text {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--ins-text);
            margin-bottom: 16px;
        }
        .options-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }
        .option-item {
            padding: 10px 14px;
            border: 1px solid var(--ins-border);
            border-radius: 8px;
            background: #f8fafc;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.9rem;
        }
        .option-item.is-correct {
            border-color: #22c55e;
            background: #f0fdf4;
            color: #166534;
            font-weight: 600;
        }
        .question-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 16px;
            border-top: 1px solid var(--ins-border);
        }
    </style>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Question Builder"/>
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
            <span>Question Bank</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">MCQ Question Engine</p>
                <h2>Bank for ${selectedAssessment.title}</h2>
                <p>Construct your assessment by adding multiple-choice questions. Total marks will be calculated automatically based on your inputs below.</p>
            </div>
            <div class="ins-hero-actions">
                <a href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Hub
                </a>
                <a href="${pageContext.request.contextPath}/instructor/assessments?view=editor&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}" class="btn btn-secondary">
                    <i class="fas fa-sliders"></i> Settings
                </a>
            </div>
        </section>

        <!-- Messages -->
        <c:if test="${param.success == 'qcreated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question added to bank.</div></c:if>
        <c:if test="${param.success == 'qdeleted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question removed.</div></c:if>
        <c:if test="${param.error == 'qoptions'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Invalid options. Please provide A/B and a correct choice.</div></c:if>
        <c:if test="${not empty errorMessage}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div></c:if>

        <div style="display: grid; grid-template-columns: 380px 1fr; gap: 32px; align-items: start;">
            <!-- Left Side: Add Question Form -->
            <div class="section-card" style="position: sticky; top: 94px; padding: 24px;">
                <div style="margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid var(--ins-border);">
                    <h3 style="margin: 0; font-size: 1.1rem; color: var(--ins-text);"><i class="fas fa-plus-circle" style="color: var(--ins-primary);"></i> New Question</h3>
                </div>
                
                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="ia-form">
                    <input type="hidden" name="action" value="addQuestion" />
                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}" />
                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}" />
                    <input type="hidden" name="workflowAction" value="questions" />

                    <div style="margin-bottom: 20px;">
                        <label for="createQuestionText" style="display: block; margin-bottom: 8px; font-weight: 700; color: var(--ins-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">Question Prompt <span style="color: #dc2626;">*</span></label>
                        <textarea id="createQuestionText" name="questionText" rows="3" placeholder="Enter the question text..." required style="width: 100%; padding: 12px; font-size: 0.95rem; line-height: 1.5;"></textarea>
                    </div>

                    <div style="display: grid; gap: 14px; margin-bottom: 20px;">
                        <div>
                            <label style="font-size: 0.75rem; font-weight: 700; color: var(--ins-muted); text-transform: uppercase;">Option A <span style="color: #dc2626;">*</span></label>
                            <input name="optionA" type="text" placeholder="First option" required style="width: 100%; padding: 10px;" />
                        </div>
                        <div>
                            <label style="font-size: 0.75rem; font-weight: 700; color: var(--ins-muted); text-transform: uppercase;">Option B <span style="color: #dc2626;">*</span></label>
                            <input name="optionB" type="text" placeholder="Second option" required style="width: 100%; padding: 10px;" />
                        </div>
                        <div>
                            <label style="font-size: 0.75rem; font-weight: 700; color: var(--ins-muted); text-transform: uppercase;">Option C</label>
                            <input name="optionC" type="text" placeholder="Optional" style="width: 100%; padding: 10px;" />
                        </div>
                        <div>
                            <label style="font-size: 0.75rem; font-weight: 700; color: var(--ins-muted); text-transform: uppercase;">Option D</label>
                            <input name="optionD" type="text" placeholder="Optional" style="width: 100%; padding: 10px;" />
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px;">
                        <div>
                            <label for="createCorrectOption" style="font-size: 0.75rem; font-weight: 700; color: var(--ins-muted); text-transform: uppercase;">Answer <span style="color: #dc2626;">*</span></label>
                            <select id="createCorrectOption" name="correctOption" required style="width: 100%; padding: 10px;">
                                <option value="">Choice</option>
                                <option value="A">A</option>
                                <option value="B">B</option>
                                <option value="C">C</option>
                                <option value="D">D</option>
                            </select>
                        </div>
                        <div>
                            <label for="createMarks" style="font-size: 0.75rem; font-weight: 700; color: var(--ins-muted); text-transform: uppercase;">Marks <span style="color: #dc2626;">*</span></label>
                            <input id="createMarks" name="marks" type="number" min="0.5" step="0.5" value="1" required style="width: 100%; padding: 10px;" />
                        </div>
                    </div>

                    <button class="btn btn-primary" type="submit" style="width: 100%; justify-content: center;">
                        <i class="fas fa-save"></i> Add to Bank
                    </button>
                </form>
            </div>

            <!-- Right Side: Questions List -->
            <div>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3 style="font-size: 1.2rem; color: var(--ins-text); margin: 0;">Existing Questions</h3>
                    <div class="ia-filter-group">
                        <span style="font-size: 0.85rem; color: var(--ins-muted); background: #f1f5f9; padding: 4px 12px; border-radius: 999px;">
                            <strong>${fn:length(questions)}</strong> Total Items
                        </span>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty questions}">
                        <div class="ia-empty-state">
                            <div class="ia-empty-icon"><i class="fas fa-layer-group"></i></div>
                            <h3>Empty Bank</h3>
                            <p>No questions have been added to this assessment yet. Use the form on the left to start building.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display: grid; gap: 20px;">
                            <c:forEach var="q" items="${questions}" varStatus="status">
                                <article class="section-card" style="padding: 24px;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px;">
                                        <div style="display: flex; gap: 12px;">
                                            <div style="width: 32px; height: 32px; border-radius: 8px; background: var(--ins-accent-soft); color: var(--ins-primary); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.8rem;">
                                                ${status.index + 1}
                                            </div>
                                            <div style="font-size: 1.05rem; font-weight: 600; color: var(--ins-text); line-height: 1.5; padding-top: 2px;">
                                                ${q.questionText}
                                            </div>
                                        </div>
                                        <div style="display: flex; gap: 8px;">
                                            <span style="font-size: 0.75rem; font-weight: 700; color: var(--ins-muted); background: #f8fafc; border: 1px solid var(--ins-border); padding: 4px 10px; border-radius: 6px;">
                                                ${q.marks} PTS
                                            </span>
                                        </div>
                                    </div>

                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 20px;">
                                        <div class="option-item ${q.correctOption == 'A' ? 'is-correct' : ''}" style="padding: 12px; border: 1px solid var(--ins-border); border-radius: 10px; font-size: 0.9rem; display: flex; align-items: center; gap: 10px; background: ${q.correctOption == 'A' ? 'var(--ins-accent-soft)' : '#fff'}">
                                            <span style="font-weight: 800; opacity: 0.5;">A.</span> ${q.optionA}
                                            <c:if test="${q.correctOption == 'A'}"><i class="fas fa-check-circle" style="margin-left: auto; color: var(--ins-primary);"></i></c:if>
                                        </div>
                                        <div class="option-item ${q.correctOption == 'B' ? 'is-correct' : ''}" style="padding: 12px; border: 1px solid var(--ins-border); border-radius: 10px; font-size: 0.9rem; display: flex; align-items: center; gap: 10px; background: ${q.correctOption == 'B' ? 'var(--ins-accent-soft)' : '#fff'}">
                                            <span style="font-weight: 800; opacity: 0.5;">B.</span> ${q.optionB}
                                            <c:if test="${q.correctOption == 'B'}"><i class="fas fa-check-circle" style="margin-left: auto; color: var(--ins-primary);"></i></c:if>
                                        </div>
                                        <c:if test="${not empty q.optionC}">
                                            <div class="option-item ${q.correctOption == 'C' ? 'is-correct' : ''}" style="padding: 12px; border: 1px solid var(--ins-border); border-radius: 10px; font-size: 0.9rem; display: flex; align-items: center; gap: 10px; background: ${q.correctOption == 'C' ? 'var(--ins-accent-soft)' : '#fff'}">
                                                <span style="font-weight: 800; opacity: 0.5;">C.</span> ${q.optionC}
                                                <c:if test="${q.correctOption == 'C'}"><i class="fas fa-check-circle" style="margin-left: auto; color: var(--ins-primary);"></i></c:if>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty q.optionD}">
                                            <div class="option-item ${q.correctOption == 'D' ? 'is-correct' : ''}" style="padding: 12px; border: 1px solid var(--ins-border); border-radius: 10px; font-size: 0.9rem; display: flex; align-items: center; gap: 10px; background: ${q.correctOption == 'D' ? 'var(--ins-accent-soft)' : '#fff'}">
                                                <span style="font-weight: 800; opacity: 0.5;">D.</span> ${q.optionD}
                                                <c:if test="${q.correctOption == 'D'}"><i class="fas fa-check-circle" style="margin-left: auto; color: var(--ins-primary);"></i></c:if>
                                            </div>
                                        </c:if>
                                    </div>

                                    <div style="display: flex; justify-content: flex-end; padding-top: 16px; border-top: 1px solid var(--ins-border);">
                                        <a href="${pageContext.request.contextPath}/instructor/assessments?action=deleteQuestion&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&questionId=${q.questionId}" 
                                           class="btn btn-secondary btn-sm" style="color: #dc2626; border-color: #fee2e2;"
                                           onclick="return confirm('Are you sure you want to delete this question?');">
                                            <i class="fas fa-trash-can"></i> Remove
                                        </a>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
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
