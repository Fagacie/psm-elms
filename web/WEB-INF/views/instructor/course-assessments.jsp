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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-assessments.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="instructor-ui">
<jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
    <jsp:param name="pageTitle" value="Course Assessments"/>
    <jsp:param name="pageSubtitle" value="Create, grade, and review assessment workflows"/>
</jsp:include>

<c:set var="activeInstructorPage" value="assessments"/>
<jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/instructor/dashboard">Dashboard</a>
            <span>&gt;</span>
            <a href="${pageContext.request.contextPath}/instructor/courses">Courses</a>
            <span>&gt;</span>
            <span>Assessments</span>
        </nav>

        <section class="ins-page-head">
            <div>
                <p class="ins-page-kicker">Assessment Workspace</p>
                <h2>Design, review, and grade assessments with clearer structure</h2>
                <p>This page now aligns with the instructor workspace so assessment creation, question handling, grading, and retake decisions feel connected instead of scattered.</p>
            </div>
            <div class="ins-hero-actions">
                <c:if test="${not empty selectedCourse}">
                    <button type="button" class="btn btn-primary" onclick="openCreateAssessmentModal()">
                        <i class="fas fa-plus-circle"></i> New Assessment
                    </button>
                </c:if>
                <a href="${pageContext.request.contextPath}/instructor/materials" class="btn btn-secondary">
                    <i class="fas fa-folder-open"></i> Open Materials
                </a>
            </div>
        </section>

        <c:set var="defaultTab" value="${not empty selectedAssessment ? 'details' : (param.view == 'create' ? 'create' : 'list')}" />
        <div class="section-card course-filter-card">
            <form method="get" action="${pageContext.request.contextPath}/instructor/assessments" class="course-filter-form">
                <label for="courseId"><strong>Select Course:</strong></label>
                <select id="courseId" name="courseId" required>
                    <option value="">-- Select Course --</option>
                    <c:forEach var="c" items="${courses}">
                        <option value="${c.courseId}" <c:if test="${not empty selectedCourse and selectedCourse.courseId == c.courseId}">selected</c:if>>
                            ${c.courseName}
                        </option>
                    </c:forEach>
                </select>
                <button class="btn btn-primary btn-sm" type="submit"><i class="fas fa-filter"></i> Load Assessments</button>
            </form>
        </div>

        <!-- Messages -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>
        <c:if test="${param.success == 'created'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment created successfully.</div></c:if>
        <c:if test="${param.success == 'updated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment updated successfully.</div></c:if>
        <c:if test="${param.success == 'deleted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Assessment deleted successfully.</div></c:if>
        <c:if test="${param.success == 'qcreated'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question added successfully.</div></c:if>
        <c:if test="${param.success == 'qdeleted'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Question deleted successfully.</div></c:if>
        <c:if test="${param.success == 'rreviewed'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Retake request reviewed successfully.</div></c:if>
        <c:if test="${param.success == 'graded'}"><div class="alert alert-success"><i class="fas fa-check-circle"></i> Submission graded successfully.</div></c:if>
        <c:if test="${param.error == 'qoptions'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Quiz requires options A/B and a correct option.</div></c:if>
        <c:if test="${param.error == 'type'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Assessment type is invalid. Choose Quiz, Exam, or Assignment.</div></c:if>
        <c:if test="${param.error == 'placement'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Selected placement material is invalid for this course.</div></c:if>
        <c:if test="${param.error == 'assignmentschema'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Assignment questions must be descriptive only (no options/correct option).</div></c:if>
        <c:if test="${param.error == 'examschema'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Exam questions with options must include A/B and a valid correct option; descriptive exam questions should not set a correct option.</div></c:if>
        <c:if test="${param.error != null and param.error != 'qoptions' and param.error != 'type' and param.error != 'placement' and param.error != 'assignmentschema' and param.error != 'examschema'}"><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Action failed. Please retry.</div></c:if>

        <c:if test="${not empty selectedCourse}">
            <section class="ins-hero-card assessments-hero">
                <div class="ins-hero-grid">
                    <div>
                        <h3>${selectedCourse.courseName}</h3>
                        <p>Use this workspace to place the right assessment at the right point in the course, distinguish quizzes from assignments and exams, and keep grading decisions visible.</p>
                    </div>
                    <div class="ins-hero-metrics">
                        <div class="ins-metric">
                            <strong>${assessments.size()}</strong>
                            <span>Assessments in course</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${not empty selectedAssessment ? questions.size() : 0}</strong>
                            <span>Questions in focus</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${not empty selectedAssessment ? submissions.size() : 0}</strong>
                            <span>Submission records</span>
                        </div>
                        <div class="ins-metric">
                            <strong>${not empty selectedAssessment ? retakeRequests.size() : 0}</strong>
                            <span>Retake requests</span>
                        </div>
                    </div>
                </div>
            </section>

            <div class="tabs">
                <button type="button" class="tab-btn ${defaultTab == 'create' ? 'active' : ''}" data-tab-target="create-tab">
                    <i class="fas fa-plus-circle"></i> Create Assessment
                </button>
                <button type="button" class="tab-btn ${defaultTab == 'list' ? 'active' : ''}" data-tab-target="list-tab">
                    <i class="fas fa-list"></i> Manage Assessments (${assessments.size()})
                </button>
                <c:if test="${not empty selectedAssessment}">
                    <button type="button" class="tab-btn ${defaultTab == 'details' ? 'active' : ''}" data-tab-target="details-tab">
                        <i class="fas fa-clipboard-check"></i> Assessment Details
                    </button>
                </c:if>
            </div>

            <!-- Create Assessment Tab -->
            <div id="create-tab" class="tab-content ${defaultTab == 'create' ? 'active' : ''}">
                <div class="assessment-form-section">
                    <h3><i class="fas fa-plus-circle"></i> Create New Assessment for: ${selectedCourse.courseName}</h3>
                    <p class="section-caption">Assessment setup now opens in a focused modal to keep this workspace cleaner.</p>
                    <button type="button" class="btn btn-primary" onclick="openCreateAssessmentModal()">
                        <i class="fas fa-plus"></i> Open Create Assessment Modal
                    </button>
                </div>
            </div>

            <!-- Manage Assessments Tab -->
            <div id="list-tab" class="tab-content ${defaultTab == 'list' ? 'active' : ''}">
                <div class="assessments-list-section">
                    <h3><i class="fas fa-list"></i> Assessments for: ${selectedCourse.courseName}</h3>
                    <c:choose>
                        <c:when test="${empty assessments}">
                            <div class="empty-state-box">
                                <i class="fas fa-clipboard-list"></i>
                                <p>No assessments created for this course yet.</p>
                                <button type="button" class="btn btn-primary" onclick="openCreateAssessmentModal()">
                                    <i class="fas fa-plus"></i> Create First Assessment
                                </button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="assessments-grid">
                            <c:forEach var="a" items="${assessments}">
                                <div class="assessment-card" aria-label="Assessment ${a.title}">
                                    <div class="assessment-card-header">
                                        <h4 class="assessment-title">${a.title}</h4>
                                        <span class="assessment-type-badge type-${a.type}">${a.type}</span>
                                    </div>
                                    <div class="assessment-meta-grid">
                                        <div class="meta-item">
                                            <i class="fas fa-clock"></i>
                                            <span>${a.duration != null ? a.duration : 'Unlimited'} mins</span>
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-star"></i>
                                            <span>${a.totalMarks != null ? a.totalMarks : 'N/A'} marks</span>
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-redo"></i>
                                            <span>${a.maxAttempts} ${a.maxAttempts == 1 ? 'attempt' : 'attempts'}</span>
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-question-circle"></i>
                                            <span>Questions: Manage in details</span>
                                        </div>
                                    </div>
                                    <div class="assessment-actions">
                                        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}&assessmentId=${a.assessmentId}">
                                            <i class="fas fa-clipboard-check"></i> Manage / View Results
                                        </a>
                                        <button class="btn btn-secondary btn-sm" onclick="toggleEditAssessment(${a.assessmentId})">
                                            <i class="fas fa-pen"></i> Edit
                                        </button>
                                        <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteAssessment&id=${a.assessmentId}&courseId=${selectedCourse.courseId}" onclick="return confirm('Delete this assessment and all its questions? This cannot be undone.');">
                                            <i class="fas fa-trash"></i>
                                        </a>
                                    </div>
                                    
                                    <!-- Edit Form -->
                                    <div id="edit-assessment-${a.assessmentId}" class="edit-dropdown-content" hidden>
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                            <input type="hidden" name="action" value="updateAssessment">
                                            <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                            <input type="hidden" name="assessmentId" value="${a.assessmentId}">
                                            <c:set var="placementType" value="${assessmentPlacementTypeMap[a.assessmentId]}"/>
                                            <c:set var="placementMaterialId" value="${assessmentPlacementMaterialIdMap[a.assessmentId]}"/>
                                            <div class="upload-form-grid">
                                                <div class="field">
                                                    <label>Title</label>
                                                    <input type="text" name="title" value="${a.title}" required>
                                                </div>
                                                <div class="field">
                                                    <label>Type</label>
                                                    <select name="type" required>
                                                        <option value="Assignment" ${a.type == 'Assignment' ? 'selected' : ''}>Assignment</option>
                                                        <option value="Quiz" ${a.type == 'Quiz' ? 'selected' : ''}>Quiz</option>
                                                        <option value="Exam" ${a.type == 'Exam' ? 'selected' : ''}>Exam</option>
                                                    </select>
                                                </div>
                                                <div class="field">
                                                    <label>Duration (mins)</label>
                                                    <input type="number" min="1" name="duration" value="${a.duration}">
                                                </div>
                                                <div class="field">
                                                    <label>Total Marks</label>
                                                    <input type="number" min="1" name="totalMarks" value="${a.totalMarks}">
                                                </div>
                                                <div class="field">
                                                    <label>Max Attempts</label>
                                                    <input type="number" min="1" max="10" name="maxAttempts" value="${a.maxAttempts}" required>
                                                </div>
                                                <div class="field">
                                                    <label>Questions Per Page</label>
                                                    <input type="number" min="1" max="20" name="questionsPerPage" value="${a.questionsPerPage}" required>
                                                </div>
                                                <div class="field full">
                                                    <label>Placement</label>
                                                    <select name="placement">
                                                        <option value="final" ${placementType != 'afterMaterial' ? 'selected' : ''}>After all materials (final)</option>
                                                        <c:forEach var="m" items="${materials}">
                                                            <option value="material:${m.materialId}" ${placementType == 'afterMaterial' && placementMaterialId == m.materialId ? 'selected' : ''}>
                                                                After: ${m.title}
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="field full">
                                                    <label>Instructions</label>
                                                    <textarea name="instructions" rows="2">${a.instructions}</textarea>
                                                </div>
                                            </div>
                                            <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-save"></i> Save Changes</button>
                                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleEditAssessment(${a.assessmentId})">Cancel</button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Assessment Details Tab -->
            <c:if test="${not empty selectedAssessment}">
                <div id="details-tab" class="tab-content ${defaultTab == 'details' ? 'active' : ''}">
                    <div class="assessment-details-header">
                        <div>
                            <h2 class="assessment-details-title"><i class="fas fa-clipboard-check"></i> ${selectedAssessment.title}</h2>
                            <div class="assessment-details-meta">
                                <span class="assessment-type-badge type-${selectedAssessment.type}">${selectedAssessment.type}</span>
                                <span><i class="fas fa-clock"></i> ${selectedAssessment.duration != null ? selectedAssessment.duration : 'Unlimited'} mins</span>
                                <span><i class="fas fa-star"></i> ${selectedAssessment.totalMarks != null ? selectedAssessment.totalMarks : 'N/A'} marks</span>
                                <span><i class="fas fa-redo"></i> ${selectedAssessment.maxAttempts} attempt${selectedAssessment.maxAttempts > 1 ? 's' : ''}</span>
                            </div>
                        </div>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/instructor/assessments?courseId=${selectedCourse.courseId}">
                            <i class="fas fa-arrow-left"></i> Back to List
                        </a>
                    </div>

                    <!-- Sub-tabs for Questions vs Submissions -->
                    <div class="sub-tabs">
                        <button type="button" class="sub-tab-btn active" data-subtab-target="questions-section">
                            <i class="fas fa-question-circle"></i> Questions (${questions.size()})
                        </button>
                        <button type="button" class="sub-tab-btn" data-subtab-target="submissions-section">
                            <i class="fas fa-users"></i> Student Submissions (${submissions.size()})
                        </button>
                        <button type="button" class="sub-tab-btn" data-subtab-target="retake-section">
                            <i class="fas fa-redo"></i> Retake Requests (${retakeRequests.size()})
                        </button>
                    </div>

                    <!-- Questions Section -->
                    <div id="questions-section" class="sub-tab-content active">
                        <div class="questions-section">
                            <h3><i class="fas fa-plus-circle"></i> Add Question</h3>
                            <p class="form-subtitle" id="question-note">
                                <strong>Note:</strong>
                                <c:choose>
                                    <c:when test="${selectedAssessment.type == 'Assignment'}">
                                        Assignment questions are descriptive. No options required. Students will upload a file.
                                    </c:when>
                                    <c:otherwise>
                                        Quiz/Exam questions require options A & B and a correct option.
                                    </c:otherwise>
                                </c:choose>
                            </p>
                            <div class="add-question-form">
                                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                    <input type="hidden" name="action" value="addQuestion">
                                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                    <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                    <div class="upload-form-grid">
                                        <div class="field full">
                                            <label>Question Text *</label>
                                            <textarea name="questionText" rows="3" required placeholder="Enter your question here..."></textarea>
                                        </div>
                                        <div class="option-fields">
                                            <div class="field"><label>Option A</label><input type="text" name="optionA" placeholder="Option A"></div>
                                            <div class="field"><label>Option B</label><input type="text" name="optionB" placeholder="Option B"></div>
                                            <div class="field"><label>Option C</label><input type="text" name="optionC" placeholder="Option C"></div>
                                            <div class="field"><label>Option D</label><input type="text" name="optionD" placeholder="Option D"></div>
                                        </div>
                                        <div class="field correct-field">
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
                                            <input type="number" step="0.01" min="0" name="marks" placeholder="0.00">
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary"><i class="fas fa-plus"></i> Add Question</button>
                                </form>
                            </div>

                            <h3 class="questions-list-title"><i class="fas fa-list"></i> Questions List (${questions.size()})</h3>
                            <c:choose>
                                <c:when test="${empty questions}">
                                    <div class="empty-state-box">
                                        <i class="fas fa-question-circle"></i>
                                        <p>No questions added yet. Add questions above to complete this assessment.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="questions-list">
                                    <c:forEach var="q" items="${questions}" varStatus="status">
                                        <div class="question-item">
                                            <div class="question-number">Q${status.index + 1}</div>
                                            <div class="question-content">
                                                <div class="question-item-text">${q.questionText}</div>
                                                <div class="question-item-details">
                                                    <span><i class="fas fa-check-circle"></i> Correct: <strong><c:out value="${q.correctOption}" default="N/A"/></strong></span>
                                                    <span><i class="fas fa-star"></i> Marks: <strong><c:out value="${q.marks}" default="N/A"/></strong></span>
                                                </div>
                                                <c:if test="${not empty q.optionA or not empty q.optionB or not empty q.optionC or not empty q.optionD}">
                                                    <div class="question-options">
                                                        <c:if test="${not empty q.optionA}">
                                                            <div class="question-option ${q.correctOption == 'A' ? 'correct' : ''}">
                                                                <span class="option-label">A</span> ${q.optionA}
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty q.optionB}">
                                                            <div class="question-option ${q.correctOption == 'B' ? 'correct' : ''}">
                                                                <span class="option-label">B</span> ${q.optionB}
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty q.optionC}">
                                                            <div class="question-option ${q.correctOption == 'C' ? 'correct' : ''}">
                                                                <span class="option-label">C</span> ${q.optionC}
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty q.optionD}">
                                                            <div class="question-option ${q.correctOption == 'D' ? 'correct' : ''}">
                                                                <span class="option-label">D</span> ${q.optionD}
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </c:if>
                                            </div>
                                            <div class="question-actions">
                                                <a class="btn btn-danger btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=deleteQuestion&id=${q.questionId}&assessmentId=${selectedAssessment.assessmentId}&courseId=${selectedCourse.courseId}" onclick="return confirm('Delete this question?');">
                                                    <i class="fas fa-trash"></i> Delete
                                                </a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Submissions Section -->
                    <div id="submissions-section" class="sub-tab-content">
                        <div class="submissions-section">
                            <div class="section-header">
                                <div>
                                    <h3><i class="fas fa-users"></i> Student Submissions</h3>
                                    <p class="section-caption">Filter, grade, and export submissions from one concise panel.</p>
                                </div>
                                <div class="submissions-toolbar">
                                    <form method="get" action="${pageContext.request.contextPath}/instructor/assessments" class="submissions-filter-form">
                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                        <label for="gradeFilter"><strong>Filter:</strong></label>
                                        <select id="gradeFilter" name="gradeFilter">
                                            <option value="all" ${gradeFilter == 'all' ? 'selected' : ''}>All Submissions</option>
                                            <option value="graded" ${gradeFilter == 'graded' ? 'selected' : ''}>Graded Only</option>
                                            <option value="ungraded" ${gradeFilter == 'ungraded' ? 'selected' : ''}>Pending Grading</option>
                                            <option value="timedout" ${gradeFilter == 'timedout' ? 'selected' : ''}>Timed Out</option>
                                        </select>
                                        <button type="submit" class="btn btn-secondary btn-sm"><i class="fas fa-filter"></i> Apply</button>
                                    </form>
                                    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/instructor/assessments?action=exportSubmissionsCsv&courseId=${selectedCourse.courseId}&assessmentId=${selectedAssessment.assessmentId}&gradeFilter=${gradeFilter}">
                                        <i class="fas fa-file-csv"></i> Export CSV
                                    </a>
                                </div>
                            </div>

                            <c:choose>
                                <c:when test="${empty submissions}">
                                    <div class="empty-state-box">
                                        <i class="fas fa-inbox"></i>
                                        <p>No submissions yet. Students haven't taken this assessment.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="submissions-stats">
                                        <div class="stat-card">
                                            <div class="stat-number">${submissions.size()}</div>
                                            <div class="stat-label">Total Submissions</div>
                                        </div>
                                        <div class="stat-card">
                                            <div class="stat-number" id="graded-count">-</div>
                                            <div class="stat-label">Graded</div>
                                        </div>
                                        <div class="stat-card">
                                            <div class="stat-number" id="ungraded-count">-</div>
                                            <div class="stat-label">Pending</div>
                                        </div>
                                        <div class="stat-card">
                                            <div class="stat-number" id="avg-score">-</div>
                                            <div class="stat-label">Average Score</div>
                                        </div>
                                    </div>

                                    <table class="data-table">
                                        <thead>
                                        <tr>
                                            <th>Student</th>
                                            <th>Attempt</th>
                                            <th>Status</th>
                                            <th>Submitted At</th>
                                            <th>Score</th>
                                            <th>Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="s" items="${submissions}">
                                            <tr class="submission-row ${empty s.score ? 'ungraded' : 'graded'}">
                                                <td>
                                                    <div class="student-info">
                                                        <div class="student-name"><i class="fas fa-user-circle"></i> <strong><c:out value="${s.studentName}" default="User ${s.userId}"/></strong></div>
                                                        <div class="student-email"><c:out value="${s.studentEmail}" default="-"/></div>
                                                    </div>
                                                </td>
                                                <td><span class="badge">${s.attemptNumber}</span></td>
                                                <td>
                                                    <span class="status-badge status-${s.status}">
                                                        <c:choose>
                                                            <c:when test="${s.status == 'TimedOut'}">⏱️ Timed Out</c:when>
                                                            <c:when test="${s.status == 'AutoSubmitted'}">🤖 Auto-Submitted</c:when>
                                                            <c:otherwise>✓ Submitted</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td><small>${s.submitDate != null ? s.submitDate : 'N/A'}</small></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${empty s.score}">
                                                            <span class="score-pending">Pending</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="score-value">${s.score} / ${selectedAssessment.totalMarks != null ? selectedAssessment.totalMarks : '?'}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <details class="grade-dropdown">
                                                        <summary class="btn btn-primary btn-sm">
                                                            <i class="fas fa-edit"></i> Grade
                                                        </summary>
                                                        <div class="grade-form-container">
                                                            <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                                                                <input type="hidden" name="action" value="gradeSubmission">
                                                                <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                                <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                                <input type="hidden" name="gradeFilter" value="${gradeFilter}">
                                                                <input type="hidden" name="submissionId" value="${s.submissionId}">
                                                                
                                                                <div class="form-group">
                                                                    <label>Score *</label>
                                                                    <input type="number" step="0.1" min="0" max="${selectedAssessment.totalMarks}" name="score" value="${s.score}" placeholder="Enter score" required>
                                                                </div>
                                                                
                                                                <div class="form-group">
                                                                    <label>Feedback</label>
                                                                    <textarea name="feedback" rows="3" placeholder="Provide feedback to the student...">${s.feedback}</textarea>
                                                                </div>
                                                                
                                                                <c:if test="${not empty s.answersFilePath}">
                                                                    <div class="form-group">
                                                                        <label>Submission File:</label>
                                                                        <c:choose>
                                                                            <c:when test="${fn:startsWith(s.answersFilePath, 'http')}">
                                                                                <a href="${s.answersFilePath}" target="_blank" class="file-link">
                                                                                    <i class="fas fa-file-download"></i> View/Download Answer
                                                                                </a>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="file-link"><i class="fas fa-file-alt"></i> Text/summary answer submitted</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                </c:if>
                                                                
                                                                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Grade</button>
                                                            </form>
                                                        </div>
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

                    <!-- Retake Requests Section -->
                    <div id="retake-section" class="sub-tab-content">
                        <div class="retake-requests-section">
                            <h3><i class="fas fa-redo"></i> Retake Requests</h3>
                            <c:choose>
                                <c:when test="${empty retakeRequests}">
                                    <div class="empty-state-box">
                                        <i class="fas fa-check-circle"></i>
                                        <p>No retake requests. All clear!</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="retake-requests-list">
                                    <c:forEach var="r" items="${retakeRequests}">
                                        <div class="retake-request-item status-${r.status}">
                                            <div class="retake-request-content">
                                                <div class="retake-request-student">
                                                    <i class="fas fa-user"></i> <strong>Student ID: ${r.userId}</strong>
                                                </div>
                                                <div class="retake-request-reason">
                                                    <strong>Reason:</strong> <c:out value="${r.reason}" default="No reason provided"/>
                                                </div>
                                                <div class="retake-request-status">
                                                    <strong>Status:</strong> 
                                                    <span class="status-badge status-${r.status}">${r.status}</span>
                                                </div>
                                            </div>
                                            <c:if test="${r.status == 'Pending'}">
                                                <div class="retake-request-actions">
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="inline-form">
                                                        <input type="hidden" name="action" value="reviewRetake">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}">
                                                        <input type="hidden" name="requestId" value="${r.requestId}">
                                                        <input type="hidden" name="decision" value="approve">
                                                        <button class="btn btn-primary btn-sm" type="submit">
                                                            <i class="fas fa-check"></i> Approve
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/assessments" class="inline-form inline-form-gap">
                                                        <input type="hidden" name="action" value="reviewRetake">
                                                        <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                                                        <input type="hidden" name="assessmentId" value="${selectedAssessment.assessmentId}">
                                                        <input type="hidden" name="gradeFilter" value="${gradeFilter}">
                                                        <input type="hidden" name="requestId" value="${r.requestId}">
                                                        <input type="hidden" name="decision" value="reject">
                                                        <button class="btn btn-danger btn-sm" type="submit">
                                                            <i class="fas fa-times"></i> Reject
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:if>
        </c:if>
    </div>
</main>

<c:if test="${not empty selectedCourse}">
    <div id="createAssessmentModal" class="assessment-modal" aria-hidden="true">
        <div class="assessment-modal-dialog" role="dialog" aria-modal="true" aria-labelledby="createAssessmentModalTitle">
            <div class="assessment-modal-header">
                <h3 id="createAssessmentModalTitle"><i class="fas fa-plus-circle"></i> Create Assessment</h3>
                <button type="button" class="assessment-modal-close" aria-label="Close" onclick="closeCreateAssessmentModal()">&times;</button>
            </div>
            <div class="assessment-modal-body">
                <p class="section-caption">Course: <strong>${selectedCourse.courseName}</strong></p>
                <form method="post" action="${pageContext.request.contextPath}/instructor/assessments">
                    <input type="hidden" name="action" value="createAssessment">
                    <input type="hidden" name="courseId" value="${selectedCourse.courseId}">
                    <div class="upload-form-grid">
                        <div class="field">
                            <label>Title *</label>
                            <input type="text" name="title" placeholder="e.g., Final Exam, Week 1 Quiz" required>
                        </div>
                        <div class="field">
                            <label>Type *</label>
                            <select name="type" required>
                                <option value="">-- Select Type --</option>
                                <option value="Assignment">Assignment (Student uploads answer)</option>
                                <option value="Quiz">Quiz (MCQ - auto-graded)</option>
                                <option value="Exam">Exam (MCQ - auto-graded)</option>
                            </select>
                        </div>
                        <div class="field">
                            <label>Duration (minutes)</label>
                            <input type="number" min="1" name="duration" placeholder="e.g., 60">
                            <small class="helper-text">Leave blank for no time limit</small>
                        </div>
                        <div class="field">
                            <label>Total Marks</label>
                            <input type="number" min="1" name="totalMarks" placeholder="e.g., 100">
                            <small class="helper-text">Sum of all question marks</small>
                        </div>
                        <div class="field">
                            <label>Max Attempts *</label>
                            <input type="number" min="1" max="10" name="maxAttempts" value="1" required>
                            <small class="helper-text">Number of times students can attempt</small>
                        </div>
                        <div class="field">
                            <label>Questions Per Page *</label>
                            <input type="number" min="1" max="20" name="questionsPerPage" value="2" required>
                            <small class="helper-text">For pagination during assessment</small>
                        </div>
                        <div class="field full">
                            <label>Placement in Course Flow</label>
                            <select name="placement">
                                <option value="final">After all materials (Final Assessment)</option>
                                <c:forEach var="m" items="${materials}">
                                    <option value="material:${m.materialId}">After: ${m.title}</option>
                                </c:forEach>
                            </select>
                            <small class="helper-text">Choose where this assessment appears in the learning sequence</small>
                        </div>
                        <div class="field full">
                            <label>Instructions</label>
                            <textarea name="instructions" rows="3" placeholder="Enter instructions for students taking this assessment..."></textarea>
                        </div>
                    </div>
                    <div class="assessment-modal-footer">
                        <button type="button" class="btn btn-secondary" onclick="closeCreateAssessmentModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-plus"></i> Create Assessment</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:if>

<script>
    function openCreateAssessmentModal() {
        const modal = document.getElementById('createAssessmentModal');
        if (!modal) return;
        modal.classList.add('open');
        modal.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
    }

    function closeCreateAssessmentModal() {
        const modal = document.getElementById('createAssessmentModal');
        if (!modal) return;
        modal.classList.remove('open');
        modal.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = '';
    }

    // Tab navigation
    function showTab(tabId, trigger) {
        document.querySelectorAll('.tab-content').forEach(tab => {
            tab.style.display = 'none';
            tab.classList.remove('active');
        });
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        const selectedTab = document.getElementById(tabId);
        if (selectedTab) {
            selectedTab.style.display = 'block';
            selectedTab.classList.add('active');
        }
        if (trigger) {
            trigger.classList.add('active');
        }
    }

    // Sub-tab navigation
    function showSubTab(subTabId, trigger) {
        document.querySelectorAll('.sub-tab-content').forEach(tab => {
            tab.style.display = 'none';
            tab.classList.remove('active');
        });
        document.querySelectorAll('.sub-tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        const selectedSubTab = document.getElementById(subTabId);
        if (selectedSubTab) {
            selectedSubTab.style.display = 'block';
            selectedSubTab.classList.add('active');
        }
        if (trigger) {
            trigger.classList.add('active');
        }
    }
    
    // Toggle assessment edit form
    function toggleEditAssessment(assessmentId) {
        const editForm = document.getElementById('edit-assessment-' + assessmentId);
        if (editForm) {
            if (editForm.hasAttribute('hidden')) {
                editForm.removeAttribute('hidden');
            } else {
                editForm.setAttribute('hidden', 'hidden');
            }
        }
    }
    
    // Calculate submission statistics
    document.addEventListener('DOMContentLoaded', function() {
        function syncQuestionForm() {
            var type = '${selectedAssessment.type}';
            var optionFields = document.querySelector('.option-fields');
            var correctField = document.querySelector('.correct-field');
            var note = document.getElementById('question-note');
            var isAssignment = type === 'Assignment';
            if (optionFields) optionFields.style.display = isAssignment ? 'none' : 'contents';
            if (correctField) correctField.style.display = isAssignment ? 'none' : 'block';
            if (note) {
                note.innerHTML = '<strong>Note:</strong> ' + (isAssignment
                    ? 'Assignment questions are descriptive. No options required. Students will upload a file.'
                    : 'Quiz/Exam questions require options A & B and a correct option.');
            }
        }
        syncQuestionForm();

        // Wire tab buttons reliably (fixes non-responsive buttons in some layouts)
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const target = btn.getAttribute('data-tab-target');
                if (target) showTab(target, btn);
            });
        });
        document.querySelectorAll('.sub-tab-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const target = btn.getAttribute('data-subtab-target');
                if (target) showSubTab(target, btn);
            });
        });

        // Ensure default active tabs are visible on load
        const activeTabBtn = document.querySelector('.tab-btn.active');
        const activeTabId = activeTabBtn ? activeTabBtn.getAttribute('data-tab-target') : null;
        if (activeTabId) showTab(activeTabId, activeTabBtn);
        const activeSubTabBtn = document.querySelector('.sub-tab-btn.active');
        const activeSubTabId = activeSubTabBtn ? activeSubTabBtn.getAttribute('data-subtab-target') : null;
        if (activeSubTabId) showSubTab(activeSubTabId, activeSubTabBtn);

        const submissionsTable = document.querySelector('#submissions-section .data-table tbody');
        if (submissionsTable) {
            const rows = submissionsTable.querySelectorAll('tr');
            let gradedCount = 0;
            let ungradedCount = 0;
            let totalScore = 0;
            let scoreCount = 0;
            
            rows.forEach(row => {
                if (row.classList.contains('graded')) {
                    gradedCount++;
                    const scoreCell = row.querySelector('.score-value');
                    if (scoreCell) {
                        const scoreText = scoreCell.textContent.trim();
                        const score = parseFloat(scoreText.split('/')[0]);
                        if (!isNaN(score)) {
                            totalScore += score;
                            scoreCount++;
                        }
                    }
                } else if (row.classList.contains('ungraded')) {
                    ungradedCount++;
                }
            });
            
            document.getElementById('graded-count').textContent = gradedCount;
            document.getElementById('ungraded-count').textContent = ungradedCount;
            
            if (scoreCount > 0) {
                const avg = (totalScore / scoreCount).toFixed(1);
                document.getElementById('avg-score').textContent = avg;
            } else {
                document.getElementById('avg-score').textContent = 'N/A';
            }
        }

        const createAssessmentModal = document.getElementById('createAssessmentModal');
        if (createAssessmentModal) {
            createAssessmentModal.addEventListener('click', function(event) {
                if (event.target === createAssessmentModal) {
                    closeCreateAssessmentModal();
                }
            });
        }

        window.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeCreateAssessmentModal();
            }
        });
    });
</script>
</body>
</html>

