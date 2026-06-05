package com.psm.elearning.controller.instructor;

import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.AssessmentQuestionDAO;
import com.psm.elearning.dao.AssessmentQuestionDAOImpl;
import com.psm.elearning.dao.AssessmentRetakeRequestDAO;
import com.psm.elearning.dao.AssessmentRetakeRequestDAOImpl;
import com.psm.elearning.dao.AssessmentGradeAuditDAO;
import com.psm.elearning.dao.AssessmentGradeAuditDAOImpl;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAOImpl;
import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentGradeAudit;
import com.psm.elearning.model.AssessmentRetakeRequest;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.service.AssessmentAnalyticsService;
import com.psm.elearning.util.AssessmentPlacementUtil;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.nio.file.Paths;

@MultipartConfig(maxFileSize = 52428800)
public class InstructorAssessmentServlet extends HttpServlet {

    private static final String VIEW_DASHBOARD = "dashboard";
    private static final String VIEW_EDITOR = "editor";
    private static final String VIEW_QUESTIONS = "questions";
    private static final String VIEW_SUBMISSIONS = "submissions";
    private static final String VIEW_GRADE = "grade";
    private static final String VIEW_ANALYTICS = "analytics";
    private static final String VIEW_ARCHIVE = "archive";

    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentQuestionDAO questionDAO = new AssessmentQuestionDAOImpl();
    private final AssessmentRetakeRequestDAO retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
    private final AssessmentGradeAuditDAO gradeAuditDAO = new AssessmentGradeAuditDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();
    private final AssessmentAnalyticsService analyticsService = new AssessmentAnalyticsService(assessmentDAO, submissionDAO, questionDAO, enrollmentDAO);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = SessionUtil.resolveUserId(session);
        
        resolveRouteContext(request);
        
        String action = normalize(request.getParameter("action"));

        if ("exportSubmissionsCsv".equals(action)) {
            exportSubmissionsCsv(request, response, userId);
            return;
        }
        if ("deleteAssessment".equals(action) || "archiveAssessment".equals(action)) {
            archiveAssessment(request, response, userId);
            return;
        }
        if ("restoreAssessment".equals(action)) {
            restoreAssessment(request, response, userId);
            return;
        }
        if ("deleteQuestion".equals(action)) {
            deleteQuestion(request, response, userId);
            return;
        }

        loadPage(request, response, userId);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        resolveRouteContext(request);
        
        String action = normalize(request.getParameter("action"));

        if ("createAssessment".equals(action)) {
            createAssessment(request, response, userId);
            return;
        }
        if ("updateAssessment".equals(action)) {
            updateAssessment(request, response, userId);
            return;
        }
        if ("publishAssessment".equals(action)) {
            publishAssessment(request, response, userId);
            return;
        }
        if ("addQuestion".equals(action)) {
            addQuestion(request, response, userId);
            return;
        }
        if ("updateQuestion".equals(action)) {
            updateQuestion(request, response, userId);
            return;
        }
        if ("moveQuestion".equals(action)) {
            moveQuestion(request, response, userId);
            return;
        }
        if ("reviewRetake".equals(action)) {
            reviewRetakeRequest(request, response, userId);
            return;
        }
        if ("gradeSubmission".equals(action)) {
            gradeSubmission(request, response, userId);
            return;
        }
        if ("autoRegradeSubmission".equals(action)) {
            autoRegradeSubmission(request, response, userId);
            return;
        }
        if ("autoRegradeAllObjective".equals(action)) {
            autoRegradeAllObjective(request, response, userId);
            return;
        }
        if ("bulkRestoreAssessments".equals(action)) {
            bulkRestoreAssessments(request, response, userId);
            return;
        }

        loadPage(request, response, userId);
    }

    private void loadPage(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws ServletException, IOException {

        Integer selectedCourseId = parseInt(request.getParameter("courseId"));
        if (selectedCourseId == null && request.getAttribute("pathCourseId") != null) {
            selectedCourseId = parseInt((String) request.getAttribute("pathCourseId"));
        }
        Integer selectedAssessmentId = parseInt(request.getParameter("assessmentId"));
        if (selectedAssessmentId == null && request.getAttribute("pathAssessmentId") != null) {
            selectedAssessmentId = parseInt((String) request.getAttribute("pathAssessmentId"));
        }
        Integer selectedSubmissionId = parseInt(request.getParameter("submissionId"));
        
        String viewParam = request.getParameter("view");
        if (viewParam == null && request.getAttribute("pathView") != null) {
            viewParam = (String) request.getAttribute("pathView");
        }
        String activeView = normalizeView(viewParam);

        if (selectedCourseId == null) {
            String err = request.getParameter("error");
            String succ = request.getParameter("success");
            String query = "";
            if (err != null) query = "?error=" + err;
            else if (succ != null) query = "?success=" + succ;
            response.sendRedirect(request.getContextPath() + "/instructor/courses" + query);
            return;
        }

        if (VIEW_DASHBOARD.equals(activeView) || VIEW_ARCHIVE.equals(activeView)) {
            String err = request.getParameter("error");
            String succ = request.getParameter("success");
            String query = "";
            if (err != null) query = "&error=" + err;
            else if (succ != null) query = "&success=" + succ;
            response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + selectedCourseId + query + "#assessments");
            return;
        }
        
        String gradeFilter = normalize(request.getParameter("gradeFilter"));
        if (gradeFilter.isEmpty()) gradeFilter = "all";

        List<Course> courses = courseDAO.findByInstructor(userId);
        if (courses == null) courses = new ArrayList<>();
        request.setAttribute("courses", courses);

        Course selectedCourse = null;
        if (selectedCourseId != null) {
            selectedCourse = courseDAO.findById(selectedCourseId);
            if (selectedCourse == null || !userId.equals(selectedCourse.getCreatedBy())) {
                request.setAttribute("errorMessage", "You are not allowed to manage this course workspace.");
                selectedCourse = null;
                selectedCourseId = null;
                selectedAssessmentId = null;
            }
        }

        List<Assessment> assessments = new ArrayList<>();
        List<Assessment> archivedAssessments = new ArrayList<>();
        List<Material> materials = new ArrayList<>();
        List<Enrollment> courseEnrollments = new ArrayList<>();
        Map<Integer, Integer> submissionCountByAssessmentId = new LinkedHashMap<>();
        Map<Integer, Integer> questionCountByAssessmentId = new LinkedHashMap<>();
        Map<Integer, Integer> gradedCountByAssessmentId = new LinkedHashMap<>();
        Map<Integer, Integer> pendingCountByAssessmentId = new LinkedHashMap<>();
        Map<Integer, Double> averageScoreByAssessmentId = new LinkedHashMap<>();
        Map<Integer, String> statusByAssessmentId = new LinkedHashMap<>();
        int draftAssessmentCount = 0;
        int activeAssessmentCount = 0;
        int closedAssessmentCount = 0;
        int pendingGradingAssessmentCount = 0;

        if (selectedCourseId != null) {
            assessments = assessmentDAO.findByCourse(selectedCourseId);
            if (assessments == null) assessments = new ArrayList<>();
            archivedAssessments = assessmentDAO.findDeletedByCourse(selectedCourseId);
            if (archivedAssessments == null) archivedAssessments = new ArrayList<>();
            materials = materialDAO.findByCourse(selectedCourseId);
            if (materials == null) materials = new ArrayList<>();
            courseEnrollments = enrollmentDAO.getEnrollmentsByCourse(selectedCourseId);
            if (courseEnrollments == null) courseEnrollments = new ArrayList<>();

            AssessmentAnalyticsService.CourseAssessmentMetrics metrics = analyticsService.calculateMetricsForCourseAssessments(assessments);
            submissionCountByAssessmentId = metrics.submissionCountByAssessmentId;
            questionCountByAssessmentId = metrics.questionCountByAssessmentId;
            gradedCountByAssessmentId = metrics.gradedCountByAssessmentId;
            pendingCountByAssessmentId = metrics.pendingCountByAssessmentId;
            averageScoreByAssessmentId = metrics.averageScoreByAssessmentId;
            statusByAssessmentId = metrics.statusByAssessmentId;
            draftAssessmentCount = metrics.draftAssessmentCount;
            activeAssessmentCount = metrics.activeAssessmentCount;
            closedAssessmentCount = metrics.closedAssessmentCount;
            pendingGradingAssessmentCount = metrics.pendingGradingAssessmentCount;
            hydrateAssignmentAttachments(assessments);
            hydrateAssignmentAttachments(archivedAssessments);

            Map<Integer, Integer> pendingRetakesCountByAssessmentId = new java.util.HashMap<>();
            for (Assessment assessment : assessments) {
                List<AssessmentRetakeRequest> reqs = retakeRequestDAO.findByAssessment(assessment.getAssessmentId());
                int pCount = 0;
                if (reqs != null) {
                    for (AssessmentRetakeRequest r : reqs) {
                        if ("Pending".equalsIgnoreCase(r.getStatus())) {
                            pCount++;
                        }
                    }
                }
                pendingRetakesCountByAssessmentId.put(assessment.getAssessmentId(), pCount);
            }
            request.setAttribute("pendingRetakesCountByAssessmentId", pendingRetakesCountByAssessmentId);
        }

        Map<Integer, String> placementTypeByAssessmentId = new LinkedHashMap<>();
        Map<Integer, Integer> placementMaterialByAssessmentId = new LinkedHashMap<>();
        for (Assessment assessment : assessments) {
            AssessmentPlacementUtil.Placement placement = resolvePlacement(assessment);
            assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(assessment.getInstructions()));
            placementTypeByAssessmentId.put(assessment.getAssessmentId(), placement.type);
            placementMaterialByAssessmentId.put(assessment.getAssessmentId(), placement.materialId);
        }

        Assessment selectedAssessment = null;
        List<AssessmentQuestion> questions = new ArrayList<>();
        List<AssessmentRetakeRequest> retakeRequests = new ArrayList<>();
        List<AssessmentSubmission> submissions = new ArrayList<>();
        List<AssessmentSubmission> submissionsUnfiltered = new ArrayList<>();
        AssessmentSubmission selectedSubmission = null;
        List<AssessmentGradeAudit> selectedSubmissionAudits = new ArrayList<>();
        Map<Integer, String> submissionWorkflowStatus = new LinkedHashMap<>();
        List<Map<String, Object>> assessmentRosterRows = new ArrayList<>();
        Map<String, Object> analytics = new LinkedHashMap<>();
        if (selectedAssessmentId != null || (selectedCourseId != null && !assessments.isEmpty()
                && (VIEW_SUBMISSIONS.equals(activeView) || VIEW_GRADE.equals(activeView)
                || "pending-grading".equals(activeView) || VIEW_ANALYTICS.equals(activeView)
                || VIEW_QUESTIONS.equals(activeView)))) {
            
            if (selectedAssessmentId == null) {
                selectedAssessment = assessments.get(0);
                selectedAssessmentId = selectedAssessment.getAssessmentId();
            } else {
                selectedAssessment = assessmentDAO.findById(selectedAssessmentId);
            }
            
            if (selectedAssessment == null || selectedCourseId == null || !selectedAssessment.getCourseId().equals(selectedCourseId)) {
                request.setAttribute("errorMessage", "Invalid assessment selected.");
                selectedAssessment = null;
            } else {
                AssessmentPlacementUtil.Placement placement = resolvePlacement(selectedAssessment);
                selectedAssessment.setInstructions(AssessmentPlacementUtil.stripPlacement(selectedAssessment.getInstructions()));
                placementTypeByAssessmentId.putIfAbsent(selectedAssessment.getAssessmentId(), placement.type);
                placementMaterialByAssessmentId.putIfAbsent(selectedAssessment.getAssessmentId(), placement.materialId);
                
                questions = questionDAO.findByAssessment(selectedAssessmentId);
                if (questions == null) questions = new ArrayList<>();
                hydrateAssignmentAttachment(selectedAssessment, questions);
                retakeRequests = retakeRequestDAO.findByAssessment(selectedAssessmentId);
                if (retakeRequests == null) retakeRequests = new ArrayList<>();
                submissionsUnfiltered = submissionDAO.findByAssessment(selectedAssessmentId);
                if (submissionsUnfiltered == null) submissionsUnfiltered = new ArrayList<>();
                submissions = filterSubmissions(submissionsUnfiltered, gradeFilter);

                AssessmentAnalyticsService.AssessmentDetailedAnalytics detailedAnalytics = analyticsService.calculateDetailedAnalytics(selectedAssessment, submissionsUnfiltered, courseEnrollments);
                
                submissionWorkflowStatus = detailedAnalytics.submissionWorkflowStatus;
                assessmentRosterRows = detailedAnalytics.rosterRows;
                
                analytics.put("totalSubmissions", detailedAnalytics.totalSubmissions);
                analytics.put("gradedSubmissions", detailedAnalytics.gradedSubmissions);
                analytics.put("pendingSubmissions", detailedAnalytics.pendingSubmissions);
                analytics.put("averageScore", detailedAnalytics.averageScore);
                analytics.put("topScore", detailedAnalytics.topScore);
                analytics.put("lowScore", detailedAnalytics.lowScore);
                analytics.put("completionRate", detailedAnalytics.completionRate);

                if (!submissions.isEmpty()) {
                    if (selectedSubmissionId == null) {
                        selectedSubmissionId = submissions.get(0).getSubmissionId();
                    }
                    for (AssessmentSubmission submission : submissions) {
                        if (submission != null && submission.getSubmissionId() != null && submission.getSubmissionId().equals(selectedSubmissionId)) {
                            selectedSubmission = submission;
                            break;
                        }
                    }
                    if (selectedSubmission == null && selectedSubmissionId != null) {
                        selectedSubmission = submissionDAO.findById(selectedSubmissionId);
                    }
                    if (selectedSubmission != null && selectedSubmission.getSubmissionId() != null) {
                        selectedSubmissionAudits = gradeAuditDAO.findBySubmission(selectedSubmission.getSubmissionId());
                        if (selectedSubmissionAudits == null) {
                            selectedSubmissionAudits = new ArrayList<>();
                        }
                    }
                }
            }
        }

        if ((VIEW_QUESTIONS.equals(activeView) || VIEW_SUBMISSIONS.equals(activeView)
            || VIEW_GRADE.equals(activeView) || "pending-grading".equals(activeView) || VIEW_ANALYTICS.equals(activeView))
                && selectedAssessment == null) {
            activeView = VIEW_DASHBOARD;
        }

        if (!VIEW_DASHBOARD.equals(activeView) && !VIEW_EDITOR.equals(activeView) && !VIEW_QUESTIONS.equals(activeView)
                && !VIEW_SUBMISSIONS.equals(activeView) && !VIEW_GRADE.equals(activeView) && !VIEW_ANALYTICS.equals(activeView)) {
            activeView = VIEW_DASHBOARD;
        }

        if (selectedCourseId == null) {
            selectedAssessment = null;
            questions = new ArrayList<>();
            retakeRequests = new ArrayList<>();
            submissions = new ArrayList<>();
            submissionsUnfiltered = new ArrayList<>();
            selectedSubmission = null;
            selectedSubmissionAudits = new ArrayList<>();
            assessmentRosterRows = new ArrayList<>();
            analytics = new LinkedHashMap<>();
            activeView = VIEW_DASHBOARD;
        }

        request.setAttribute("selectedCourse", selectedCourse);
        request.setAttribute("activeView", activeView);
        request.setAttribute("assessments", assessments);
        request.setAttribute("archivedAssessments", archivedAssessments);
        request.setAttribute("materials", materials);
        request.setAttribute("submissionCountByAssessmentId", submissionCountByAssessmentId);
        request.setAttribute("questionCountByAssessmentId", questionCountByAssessmentId);
        request.setAttribute("gradedCountByAssessmentId", gradedCountByAssessmentId);
        request.setAttribute("pendingCountByAssessmentId", pendingCountByAssessmentId);
        request.setAttribute("averageScoreByAssessmentId", averageScoreByAssessmentId);
        request.setAttribute("statusByAssessmentId", statusByAssessmentId);
        request.setAttribute("selectedAssessment", selectedAssessment);
        request.setAttribute("questions", questions);
        request.setAttribute("retakeRequests", retakeRequests);
        request.setAttribute("submissions", submissions);
        request.setAttribute("submissionWorkflowStatus", submissionWorkflowStatus);
        request.setAttribute("courseEnrollments", courseEnrollments);
        request.setAttribute("assessmentRosterRows", assessmentRosterRows);
        request.setAttribute("assessmentAnalytics", analytics);
        request.setAttribute("selectedSubmission", selectedSubmission);
        request.setAttribute("selectedSubmissionAudits", selectedSubmissionAudits);
        request.setAttribute("selectedSubmissionId", selectedSubmissionId);
        request.setAttribute("gradeFilter", gradeFilter);
        request.setAttribute("assessmentPlacementTypeMap", placementTypeByAssessmentId);
        request.setAttribute("assessmentPlacementMaterialIdMap", placementMaterialByAssessmentId);
        request.setAttribute("draftAssessmentCount", draftAssessmentCount);
        request.setAttribute("activeAssessmentCount", activeAssessmentCount);
        request.setAttribute("closedAssessmentCount", closedAssessmentCount);
        request.setAttribute("pendingGradingAssessmentCount", pendingGradingAssessmentCount);
        String jspFile = "/WEB-INF/views/instructor/course-assessments.jsp";
        if (VIEW_EDITOR.equals(activeView)) {
            jspFile = "/WEB-INF/views/instructor/assessment-builder.jsp";
        } else if (VIEW_QUESTIONS.equals(activeView)) {
            jspFile = "/WEB-INF/views/instructor/assessment-questions.jsp";
        } else if (VIEW_SUBMISSIONS.equals(activeView) || VIEW_GRADE.equals(activeView)) {
            jspFile = "/WEB-INF/views/instructor/assessment-submissions.jsp";
        } else if (VIEW_ARCHIVE.equals(activeView)) {
            jspFile = "/WEB-INF/views/instructor/course-assessments.jsp"; // Archive is usually handled in the same hub JSP
        }
        
        request.getRequestDispatcher(jspFile).forward(request, response);
    }

    private void resolveRouteContext(HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isEmpty() || "/".equals(pathInfo)) {
            return;
        }
        
        // Example: /1/assessments/2/grade
        // parts = ["", "1", "assessments", "2", "grade"]
        String[] parts = pathInfo.split("/");
        
        if (parts.length >= 2) {
            String courseIdStr = parts[1];
            try {
                Integer.parseInt(courseIdStr);
                // Simulate parameters if not already present
                if (request.getParameter("courseId") == null) {
                    request.setAttribute("pathCourseId", courseIdStr);
                }
            } catch (NumberFormatException e) {
                // Not a course ID
            }
        }
        
        if (parts.length >= 4 && "assessments".equals(parts[2])) {
            String assessmentIdStr = parts[3];
            try {
                Integer.parseInt(assessmentIdStr);
                if (request.getParameter("assessmentId") == null) {
                    request.setAttribute("pathAssessmentId", assessmentIdStr);
                }
            } catch (NumberFormatException e) {
                // Not an assessment ID, maybe it's "create" or "archive"
                if ("create".equals(assessmentIdStr)) {
                    request.setAttribute("pathView", VIEW_EDITOR);
                } else if ("archive".equals(assessmentIdStr)) {
                    request.setAttribute("pathView", VIEW_ARCHIVE);
                }
            }
        }
        
        if (parts.length >= 5 && "assessments".equals(parts[2])) {
            String viewStr = parts[4];
            if (request.getParameter("view") == null) {
                request.setAttribute("pathView", viewStr);
            }
            if ("grade".equals(viewStr)) {
                request.setAttribute("pathView", VIEW_SUBMISSIONS);
            }
        }
    }

    private void createAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        if (courseId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !userId.equals(course.getCreatedBy())) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
            return;
        }

        String title = normalize(request.getParameter("title"));
        String type = normalize(request.getParameter("type"));
        String gradingMode = normalizeGradingMode(type);
        String submissionMode = normalizeSubmissionMode(type, normalize(request.getParameter("submissionMode")));
        Integer duration = parseInt(request.getParameter("duration"));
        Integer totalMarks = parseInt(request.getParameter("totalMarks"));
        Integer maxAttempts = parseInt(request.getParameter("maxAttempts"));
        String instructions = normalize(request.getParameter("instructions"));
        String placement = normalize(request.getParameter("placement"));

        if (title.isEmpty() || type.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=editor&courseId=" + courseId + "&error=missing");
            return;
        }

        if (!isSupportedAssessmentType(type)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=editor&courseId=" + courseId + "&error=type");
            return;
        }

        Assessment assessment = new Assessment();
        assessment.setCourseId(courseId);
        assessment.setTitle(title);
        assessment.setType(type);
        assessment.setGradingMode(gradingMode);
        assessment.setSubmissionMode(submissionMode);
        assessment.setDuration(duration);
        assessment.setTotalMarks(totalMarks);
        AssessmentPlacementUtil.Placement parsedPlacement = AssessmentPlacementUtil.parsePlacement(AssessmentPlacementUtil.applyPlacement("", placement));
        if (!isValidPlacementForCourse(courseId, parsedPlacement)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=editor&courseId=" + courseId + "&error=placement");
            return;
        }
        assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(instructions));
        assessment.setPlacementType(parsedPlacement.type);
        assessment.setPlacementMaterialId(parsedPlacement.materialId);
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        assessment.setMaxAttempts(maxAttempts != null && maxAttempts > 0 ? maxAttempts : defaultMaxAttempts);
        assessment.setCreatedBy(userId);

        Assessment created = assessmentDAO.create(assessment);
        if (created == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=editor&courseId=" + courseId + "&error=create");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + created.getAssessmentId() + "&success=created");
    }

    private void updateAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findAnyById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
            return;
        }

        String title = normalize(request.getParameter("title"));
        String type = normalize(request.getParameter("type"));
        String gradingMode = normalizeGradingMode(type);
        String submissionMode = normalizeSubmissionMode(type, normalize(request.getParameter("submissionMode")));
        Integer duration = parseInt(request.getParameter("duration"));
        Integer totalMarks = parseInt(request.getParameter("totalMarks"));
        Integer maxAttempts = parseInt(request.getParameter("maxAttempts"));
        String instructions = normalize(request.getParameter("instructions"));
        String placement = normalize(request.getParameter("placement"));
        String workflowAction = normalize(request.getParameter("workflowAction"));

        if (title.isEmpty() || type.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=editor&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=missing");
            return;
        }

        if (!isSupportedAssessmentType(type)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=editor&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=type");
            return;
        }

        assessment.setTitle(title);
        assessment.setType(type);
        assessment.setGradingMode(gradingMode);
        assessment.setSubmissionMode(submissionMode);
        assessment.setDuration(duration);
        assessment.setTotalMarks(totalMarks);
        AssessmentPlacementUtil.Placement parsedPlacement = AssessmentPlacementUtil.parsePlacement(AssessmentPlacementUtil.applyPlacement("", placement));
        if (!isValidPlacementForCourse(courseId, parsedPlacement)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=editor&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=placement");
            return;
        }
        assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(instructions));
        assessment.setPlacementType(parsedPlacement.type);
        assessment.setPlacementMaterialId(parsedPlacement.materialId);
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        assessment.setMaxAttempts(maxAttempts != null && maxAttempts > 0 ? maxAttempts : defaultMaxAttempts);

        boolean updated = assessmentDAO.update(assessment);
        String redirectView = "questions";
        if ("details".equalsIgnoreCase(workflowAction)) {
            redirectView = "editor";
        }
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=" + redirectView + "&courseId=" + courseId + "&assessmentId=" + assessmentId + (updated ? "&success=updated" : "&error=update"));
    }

    private void publishAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
            return;
        }

        List<AssessmentQuestion> questions = questionDAO.findByAssessment(assessmentId);
        if (questions == null || questions.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=publish_no_questions");
            return;
        }

        assessment.setStatus(Assessment.STATUS_PUBLISHED);
        assessmentDAO.update(assessment);

        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "&success=published#assessments");
    }

    private void archiveAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("id"));
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
            return;
        }

        boolean archived = assessmentDAO.archive(assessmentId, userId);
        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + (archived ? "&success=archived" : "&error=delete") + "#assessments");
    }

    private void restoreAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("id"));
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findAnyById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
            return;
        }

        boolean restored = assessmentDAO.restore(assessmentId);
        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + (restored ? "&success=restored" : "&error=restore") + "#assessments");
    }

    private void bulkRestoreAssessments(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        String[] ids = request.getParameterValues("assessmentIds");
        if (courseId == null || ids == null || ids.length == 0) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !userId.equals(course.getCreatedBy())) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        int restoredCount = 0;
        for (String s : ids) {
            try {
                Integer aid = Integer.parseInt(s);
                Assessment a = assessmentDAO.findAnyById(aid);
                if (a == null || !a.getCourseId().equals(courseId)) continue;
                boolean ok = assessmentDAO.restore(aid);
                if (ok) restoredCount++;
            } catch (NumberFormatException ignore) {
            }
        }

        sendWorkspaceRedirect(request, response, courseId, restoredCount > 0 ? "success" : "error", restoredCount > 0 ? "restored" : "restore");
    }

    private void addQuestion(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException, ServletException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        if (courseId == null || assessmentId == null) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        String questionText = normalize(request.getParameter("questionText"));
        String assignmentAttachmentUrl = null;
        String assignmentAttachmentName = null;

        AssessmentQuestion q = new AssessmentQuestion();
        q.setAssessmentId(assessmentId);
        q.setQuestionText(questionText);
        q.setOptionA(normalize(request.getParameter("optionA")));
        q.setOptionB(normalize(request.getParameter("optionB")));
        q.setOptionC(normalize(request.getParameter("optionC")));
        q.setOptionD(normalize(request.getParameter("optionD")));
        String correctOption = normalize(request.getParameter("correctOption"));
        q.setCorrectOption(correctOption.isEmpty() ? null : correctOption);
        q.setMarks(parseDouble(request.getParameter("marks")));

        String normalizedType = normalize(assessment.getType());
        if (Assessment.TYPE_QUIZ.equalsIgnoreCase(normalizedType) || Assessment.TYPE_EXAM.equalsIgnoreCase(normalizedType)) {
            if (questionText.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qmissing");
                return;
            }
            if (q.getOptionA().isEmpty() || q.getOptionB().isEmpty() || q.getCorrectOption() == null || !isValidCorrectOption(q.getCorrectOption())) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qoptions");
                return;
            }
        } else if (Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(normalizedType)) {
            Part attachmentPart = request.getPart("assignmentAttachment");
            if (attachmentPart != null && attachmentPart.getSize() > 0) {
                String fileName = Paths.get(attachmentPart.getSubmittedFileName()).getFileName().toString();
                if (!fileName.toLowerCase().endsWith(".pdf")) {
                    response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentfiletype");
                    return;
                }
                try (InputStream in = attachmentPart.getInputStream()) {
                    assignmentAttachmentUrl = CloudinaryUtil.uploadFile(in.readAllBytes(), fileName, CloudinaryUtil.getAssessmentAttachmentsFolder(), "raw");
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentupload");
                    return;
                }
                assignmentAttachmentName = fileName;
            }

            if (questionText.isEmpty() && (assignmentAttachmentUrl == null || assignmentAttachmentUrl.isEmpty())) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentmissing");
                return;
            }
            if (!q.getOptionA().isEmpty() || !q.getOptionB().isEmpty() || !q.getOptionC().isEmpty() || !q.getOptionD().isEmpty() || q.getCorrectOption() != null) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentschema");
                return;
            }
            if (questionText.isEmpty()) {
                q.setQuestionText(assignmentAttachmentName != null ? assignmentAttachmentName : "Assignment attachment");
            }
            q.setAttachmentUrl(assignmentAttachmentUrl);
            q.setAttachmentName(assignmentAttachmentName);
        } else {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=type");
            return;
        }

        AssessmentQuestion created = questionDAO.addQuestion(q);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + (created != null ? "&success=qcreated" : "&error=qcreate"));
    }

    private void updateQuestion(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException, ServletException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer questionId = parseInt(request.getParameter("questionId"));
        if (courseId == null || assessmentId == null || questionId == null) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentQuestion existing = questionDAO.findById(questionId);
        if (course == null || assessment == null || existing == null || !userId.equals(course.getCreatedBy())
                || !assessment.getCourseId().equals(courseId) || !existing.getAssessmentId().equals(assessmentId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        String questionText = normalize(request.getParameter("questionText"));
        if (questionText.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qmissing");
            return;
        }

        existing.setQuestionText(questionText);
        existing.setOptionA(normalize(request.getParameter("optionA")));
        existing.setOptionB(normalize(request.getParameter("optionB")));
        existing.setOptionC(normalize(request.getParameter("optionC")));
        existing.setOptionD(normalize(request.getParameter("optionD")));
        String correctOption = normalize(request.getParameter("correctOption"));
        existing.setCorrectOption(correctOption.isEmpty() ? null : correctOption);
        existing.setMarks(parseDouble(request.getParameter("marks")));
        String existingAttachmentUrl = existing.getAttachmentUrl();
        String existingAttachmentName = existing.getAttachmentName();
        String deleteAttachment = request.getParameter("deleteAttachment");
        if ("true".equalsIgnoreCase(deleteAttachment)) {
            existingAttachmentUrl = null;
            existingAttachmentName = null;
        }

        String normalizedType = normalize(assessment.getType());
        if (Assessment.TYPE_QUIZ.equalsIgnoreCase(normalizedType) || Assessment.TYPE_EXAM.equalsIgnoreCase(normalizedType)) {
            if (questionText.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qmissing");
                return;
            }
            if (existing.getOptionA().isEmpty() || existing.getOptionB().isEmpty() || existing.getCorrectOption() == null || !isValidCorrectOption(existing.getCorrectOption())) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qoptions");
                return;
            }
        } else if (Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(normalizedType)) {
            Part attachmentPart = request.getPart("assignmentAttachment");
            if (attachmentPart != null && attachmentPart.getSize() > 0) {
                String fileName = Paths.get(attachmentPart.getSubmittedFileName()).getFileName().toString();
                if (!fileName.toLowerCase().endsWith(".pdf")) {
                    response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentfiletype");
                    return;
                }
                try (InputStream in = attachmentPart.getInputStream()) {
                    existingAttachmentUrl = CloudinaryUtil.uploadFile(in.readAllBytes(), fileName, CloudinaryUtil.getAssessmentAttachmentsFolder(), "raw");
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentupload");
                    return;
                }
                existingAttachmentName = fileName;
            }
            if (questionText.isEmpty() && (existingAttachmentUrl == null || existingAttachmentUrl.isEmpty())) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentmissing");
                return;
            }
            existing.setOptionA("");
            existing.setOptionB("");
            existing.setOptionC("");
            existing.setOptionD("");
            existing.setCorrectOption(null);
            if (questionText.isEmpty()) {
                existing.setQuestionText(existingAttachmentName != null ? existingAttachmentName : "Assignment attachment");
            }
            existing.setAttachmentUrl(existingAttachmentUrl);
            existing.setAttachmentName(existingAttachmentName);
        } else {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=type");
            return;
        }

        boolean updated = questionDAO.updateQuestion(existing);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + (updated ? "&success=qupdated" : "&error=qupdate"));
    }

    private void moveQuestion(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer questionId = parseInt(request.getParameter("questionId"));
        String direction = normalize(request.getParameter("direction"));
        if (courseId == null || assessmentId == null || questionId == null || direction.isEmpty()) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentQuestion current = questionDAO.findById(questionId);
        if (course == null || assessment == null || current == null || !userId.equals(course.getCreatedBy())
                || !assessment.getCourseId().equals(courseId) || !current.getAssessmentId().equals(assessmentId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        List<AssessmentQuestion> questions = questionDAO.findByAssessment(assessmentId);
        if (questions == null || questions.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qmove");
            return;
        }

        int currentIndex = -1;
        for (int i = 0; i < questions.size(); i++) {
            AssessmentQuestion q = questions.get(i);
            if (q != null && questionId.equals(q.getQuestionId())) {
                currentIndex = i;
                break;
            }
        }
        if (currentIndex < 0) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qmove");
            return;
        }

        int targetIndex = currentIndex;
        if ("up".equalsIgnoreCase(direction)) {
            targetIndex = currentIndex - 1;
        } else if ("down".equalsIgnoreCase(direction)) {
            targetIndex = currentIndex + 1;
        }

        if (targetIndex < 0 || targetIndex >= questions.size()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qmove");
            return;
        }

        AssessmentQuestion target = questions.get(targetIndex);
        boolean moved = target != null && questionDAO.swapQuestionContent(current.getQuestionId(), target.getQuestionId());
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + (moved ? "&success=qmoved" : "&error=qmove"));
    }

    private void deleteQuestion(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer questionId = parseInt(request.getParameter("id"));
        if (questionId == null) {
            questionId = parseInt(request.getParameter("questionId"));
        }
        if (courseId == null || assessmentId == null || questionId == null) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentQuestion question = questionDAO.findById(questionId);
        if (course == null || assessment == null || question == null || !userId.equals(course.getCreatedBy())
                || !assessment.getCourseId().equals(courseId) || !question.getAssessmentId().equals(assessmentId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        boolean deleted = questionDAO.delete(questionId);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=questions&courseId=" + courseId + "&assessmentId=" + assessmentId + (deleted ? "&success=qdeleted" : "&error=qdelete"));
    }

    private void reviewRetakeRequest(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {
        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer requestId = parseInt(request.getParameter("requestId"));
        String decision = normalize(request.getParameter("decision"));
        String gradeFilter = normalize(request.getParameter("gradeFilter"));
        if (gradeFilter.isEmpty()) gradeFilter = "all";
        if (courseId == null || assessmentId == null || requestId == null || decision.isEmpty()) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        if (!"approve".equalsIgnoreCase(decision) && !"reject".equalsIgnoreCase(decision)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=submissions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + "&error=invalid");
            return;
        }

        AssessmentRetakeRequest targetRequest = retakeRequestDAO.findById(requestId);
        if (targetRequest == null || targetRequest.getAssessmentId() == null || !targetRequest.getAssessmentId().equals(assessmentId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=submissions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + "&error=permission");
            return;
        }

        if (!"Pending".equalsIgnoreCase(targetRequest.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=submissions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + "&error=retakestatus");
            return;
        }

        String nextStatus = "reject".equalsIgnoreCase(decision) ? "Rejected" : "Approved";
        boolean ok = retakeRequestDAO.updateStatus(requestId, nextStatus, userId);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=submissions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + (ok ? "&success=rreviewed" : "&error=rreview"));
    }

    private void gradeSubmission(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {
        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer submissionId = parseInt(request.getParameter("submissionId"));
        Double score = parseDouble(request.getParameter("score"));
        String feedback = normalize(request.getParameter("feedback"));
        String gradeFilter = normalize(request.getParameter("gradeFilter"));
        if (gradeFilter.isEmpty()) gradeFilter = "all";
        if (courseId == null || assessmentId == null || submissionId == null) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentSubmission submission = submissionDAO.findById(submissionId);
        if (course == null || assessment == null || submission == null || !userId.equals(course.getCreatedBy())
                || !assessment.getCourseId().equals(courseId) || !submission.getAssessmentId().equals(assessmentId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        if (score != null) {
            if (score < 0d) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=grade&courseId=" + courseId + "&assessmentId=" + assessmentId + "&submissionId=" + submissionId + "&gradeFilter=" + gradeFilter + "&error=graderange");
                return;
            }
            if (assessment.getTotalMarks() != null && score > assessment.getTotalMarks()) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=grade&courseId=" + courseId + "&assessmentId=" + assessmentId + "&submissionId=" + submissionId + "&gradeFilter=" + gradeFilter + "&error=graderange");
                return;
            }
        }

        AssessmentSubmission beforeGrade = submissionDAO.findById(submissionId);
        boolean ok = submissionDAO.gradeSubmission(submissionId, score, feedback);
        if (ok && submission.getUserId() != null) {
            com.psm.elearning.model.Enrollment enrollment = findEnrollmentForCourse(submission.getUserId(), courseId);
            if (enrollment != null) {
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
            }
        }
        if (ok) {
            recordGradeAudit(beforeGrade, submission, assessmentId, userId, score, feedback, "ManualGrade", "Instructor manually updated the submission.");
        }
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=grade&courseId=" + courseId + "&assessmentId=" + assessmentId + "&submissionId=" + submissionId + "&gradeFilter=" + gradeFilter + (ok ? "&success=graded" : "&error=grade"));
    }

    private void autoRegradeSubmission(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {
        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer submissionId = parseInt(request.getParameter("submissionId"));
        String gradeFilter = normalize(request.getParameter("gradeFilter"));
        if (gradeFilter.isEmpty()) gradeFilter = "all";

        if (courseId == null || assessmentId == null || submissionId == null) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentSubmission submission = submissionDAO.findById(submissionId);
        if (course == null || assessment == null || submission == null || !userId.equals(course.getCreatedBy())
                || !assessment.getCourseId().equals(courseId) || !submission.getAssessmentId().equals(assessmentId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        boolean objectiveType = isObjectiveAssessmentType(assessment.getType());
        String answersSummary = normalize(submission.getAnswersFilePath());
        if (!objectiveType || answersSummary.isEmpty() || answersSummary.startsWith("http")) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=submissions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + "&error=regradeunsupported");
            return;
        }

        List<AssessmentQuestion> questions = questionDAO.findByAssessment(assessmentId);
        if (questions == null) {
            questions = new ArrayList<>();
        }
        Double recalculatedScore = calculateAutoScoreFromSummary(answersSummary, questions, assessment);
        AssessmentSubmission beforeGrade = submissionDAO.findById(submissionId);
        boolean ok = submissionDAO.gradeSubmission(submissionId, recalculatedScore, submission.getFeedback());

        if (ok && submission.getUserId() != null) {
            com.psm.elearning.model.Enrollment enrollment = findEnrollmentForCourse(submission.getUserId(), courseId);
            if (enrollment != null) {
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
            }
        }
        if (ok) {
            recordGradeAudit(beforeGrade, submission, assessmentId, userId, recalculatedScore, submission.getFeedback(), "AutoRegrade", "Instructor triggered auto regrade for one submission.");
        }
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=grade&courseId=" + courseId + "&assessmentId=" + assessmentId + "&submissionId=" + submissionId + "&gradeFilter=" + gradeFilter + (ok ? "&success=autoregraded" : "&error=regrade"));
    }

    private void autoRegradeAllObjective(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {
        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        String gradeFilter = normalize(request.getParameter("gradeFilter"));
        if (gradeFilter.isEmpty()) gradeFilter = "all";

        if (courseId == null || assessmentId == null) {
            sendWorkspaceRedirect(request, response, courseId, "error", "invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            sendWorkspaceRedirect(request, response, courseId, "error", "permission");
            return;
        }

        boolean objectiveType = isObjectiveAssessmentType(assessment.getType());
        if (!objectiveType) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=submissions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + "&error=regradeunsupported");
            return;
        }

        List<AssessmentQuestion> questions = questionDAO.findByAssessment(assessmentId);
        if (questions == null) {
            questions = new ArrayList<>();
        }

        List<AssessmentSubmission> submissions = submissionDAO.findByAssessment(assessmentId);
        if (submissions == null) {
            submissions = new ArrayList<>();
        }
        submissions = filterSubmissions(submissions, gradeFilter);

        int regradedCount = 0;
        Set<Integer> affectedUsers = new HashSet<>();
        for (AssessmentSubmission submission : submissions) {
            if (submission == null || submission.getSubmissionId() == null) {
                continue;
            }
            String answersSummary = normalize(submission.getAnswersFilePath());
            if (answersSummary.isEmpty() || answersSummary.startsWith("http")) {
                continue;
            }
            Double recalculatedScore = calculateAutoScoreFromSummary(answersSummary, questions, assessment);
            AssessmentSubmission beforeGrade = submissionDAO.findById(submission.getSubmissionId());
            boolean ok = submissionDAO.gradeSubmission(submission.getSubmissionId(), recalculatedScore, submission.getFeedback());
            if (ok) {
                regradedCount++;
                recordGradeAudit(beforeGrade, submission, assessmentId, userId, recalculatedScore, submission.getFeedback(), "BulkAutoRegrade", "Bulk auto regrade executed from instructor panel.");
                if (submission.getUserId() != null) {
                    affectedUsers.add(submission.getUserId());
                }
            }
        }

        for (Integer affectedUserId : affectedUsers) {
            com.psm.elearning.model.Enrollment enrollment = findEnrollmentForCourse(affectedUserId, courseId);
            if (enrollment != null) {
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
            }
        }

        response.sendRedirect(request.getContextPath() + "/instructor/assessments?view=submissions&courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + "&success=autoregradedall&regradedCount=" + regradedCount);
    }

    private void recordGradeAudit(AssessmentSubmission beforeGrade, AssessmentSubmission afterGrade, Integer assessmentId, Integer userId, Double newScore, String newFeedback,
                                  String actionType, String note) {
        if (afterGrade == null || afterGrade.getSubmissionId() == null) {
            return;
        }
        AssessmentGradeAudit audit = new AssessmentGradeAudit();
        audit.setSubmissionId(afterGrade.getSubmissionId());
        audit.setAssessmentId(assessmentId != null ? assessmentId : afterGrade.getAssessmentId());
        audit.setActionType(actionType);
        audit.setOldScore(beforeGrade != null ? beforeGrade.getScore() : null);
        audit.setNewScore(newScore);
        audit.setOldFeedback(beforeGrade != null ? beforeGrade.getFeedback() : null);
        audit.setNewFeedback(newFeedback);
        audit.setGradedBy(userId);
        audit.setNote(note);
        gradeAuditDAO.record(audit);
    }

        private double round2(double value) {
        return Math.round(value * 100.0) / 100.0;
    }

    private Double calculateAutoScoreFromSummary(String answersSummary, List<AssessmentQuestion> questions, Assessment assessment) {
        Map<Integer, String> answersByQuestionId = new LinkedHashMap<>();
        if (answersSummary != null) {
            String[] items = answersSummary.split(";");
            for (String item : items) {
                String part = normalize(item);
                if (part.isEmpty() || !part.startsWith("Q") || !part.contains(":")) {
                    continue;
                }
                int sep = part.indexOf(':');
                String idPart = part.substring(1, sep).trim();
                String answerPart = normalize(part.substring(sep + 1));
                Integer qid = parseInt(idPart);
                if (qid != null && !answerPart.isEmpty()) {
                    answersByQuestionId.put(qid, answerPart);
                }
            }
        }

        double earned = 0.0;
        double totalPossible = 0.0;
        for (AssessmentQuestion q : questions) {
            if (q == null) {
                continue;
            }
            Double markValue = q.getMarks();
            double marks = markValue != null ? markValue.doubleValue() : 1.0;
            totalPossible += marks;

            String correct = normalize(q.getCorrectOption());
            if (correct.isEmpty()) {
                continue;
            }
            String given = answersByQuestionId.get(q.getQuestionId());
            if (given != null && correct.equalsIgnoreCase(given)) {
                earned += marks;
            }
        }

        if (totalPossible > 0) {
            double achievedRatio = earned / totalPossible;
            Integer totalMarksValue = assessment.getTotalMarks();
            double scoreScale = (totalMarksValue != null && totalMarksValue > 0) ? totalMarksValue : totalPossible;
            return round2(achievedRatio * scoreScale);
        }
        return 0.0;
    }

    private com.psm.elearning.model.Enrollment findEnrollmentForCourse(Integer userId, Integer courseId) {
        if (userId == null || courseId == null) {
            return null;
        }
        com.psm.elearning.dao.EnrollmentDAO enrollmentDAO = new com.psm.elearning.dao.EnrollmentDAOImpl();
        List<com.psm.elearning.model.Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) {
            return null;
        }
        for (com.psm.elearning.model.Enrollment enrollment : enrollments) {
            if (enrollment != null && courseId.equals(enrollment.getCourseId())) {
                return enrollment;
            }
        }
        return null;
    }

    private void exportSubmissionsCsv(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {
        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        String gradeFilter = normalize(request.getParameter("gradeFilter"));
        if (gradeFilter.isEmpty()) gradeFilter = "all";
        if (courseId == null || assessmentId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing courseId/assessmentId");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not allowed");
            return;
        }

        List<AssessmentSubmission> submissions = submissionDAO.findByAssessment(assessmentId);
        if (submissions == null) submissions = new ArrayList<>();
        submissions = filterSubmissions(submissions, gradeFilter);

        String fileName = "assessment_" + assessmentId + "_submissions.csv";
        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (PrintWriter writer = response.getWriter()) {
            writer.println("SubmissionID,StudentName,StudentEmail,Attempt,Status,Score,Feedback,SubmittedAt");
            for (AssessmentSubmission s : submissions) {
                writer.println(csv(s.getSubmissionId())
                        + "," + csv(s.getStudentName())
                        + "," + csv(s.getStudentEmail())
                        + "," + csv(s.getAttemptNumber())
                        + "," + csv(s.getStatus())
                        + "," + csv(s.getScore())
                        + "," + csv(s.getFeedback())
                        + "," + csv(s.getSubmitDate()));
            }
        }
    }

    private List<AssessmentSubmission> filterSubmissions(List<AssessmentSubmission> submissions, String gradeFilter) {
        List<AssessmentSubmission> filtered = new ArrayList<>();
        for (AssessmentSubmission s : submissions) {
            boolean include;
            switch (gradeFilter) {
                case "graded":
                    include = s.getScore() != null;
                    break;
                case "ungraded":
                    include = s.getScore() == null;
                    break;
                case "timedout":
                    include = "TimedOut".equalsIgnoreCase(s.getStatus());
                    break;
                default:
                    include = true;
            }
            if (include) filtered.add(s);
        }
        return filtered;
    }

    private String csv(Object value) {
        String s = value == null ? "" : String.valueOf(value);
        s = s.replace("\"", "\"\"");
        return "\"" + s + "\"";
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Double parseDouble(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private LocalDateTime parseDateTime(String value) {
        String normalized = normalize(value);
        if (normalized.isEmpty()) {
            return null;
        }
        try {
            return LocalDateTime.parse(normalized, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
        } catch (Exception e) {
            return null;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeView(String view) {
        String normalized = normalize(view).toLowerCase();
        List<String> supportedViews = Arrays.asList(
                VIEW_DASHBOARD,
                VIEW_EDITOR,
                VIEW_QUESTIONS,
                VIEW_SUBMISSIONS,
                VIEW_GRADE,
                "pending-grading",
                VIEW_ANALYTICS,
                VIEW_ARCHIVE
        );
        return supportedViews.contains(normalized) ? normalized : VIEW_DASHBOARD;
    }

    private boolean isSupportedAssessmentType(String type) {
        return Assessment.TYPE_QUIZ.equalsIgnoreCase(type)
            || Assessment.TYPE_EXAM.equalsIgnoreCase(type)
            || Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(type);
    }

    private String normalizeGradingMode(String assessmentType) {
        if (Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(assessmentType)) {
            return "manual";
        }
        return "auto";
    }

    private String normalizeSubmissionMode(String assessmentType, String inputMode) {
        if (!Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(assessmentType)) {
            return "both";
        }
        if ("file".equalsIgnoreCase(inputMode)) {
            return "file";
        }
        if ("text".equalsIgnoreCase(inputMode)) {
            return "text";
        }
        return "both";
    }

    private boolean isValidCorrectOption(String option) {
        return "A".equalsIgnoreCase(option)
                || "B".equalsIgnoreCase(option)
                || "C".equalsIgnoreCase(option)
                || "D".equalsIgnoreCase(option);
    }

    private String resolveAssessmentWorkflowStatus(Assessment assessment, int questionCount, int submissionsCount, int pendingCount) {
        if (assessment == null) {
            return Assessment.STATUS_DRAFT;
        }
        String status = assessment.getStatus();
        if (status != null && !status.isEmpty()) {
            return status;
        }
        return Assessment.STATUS_DRAFT;
    }

    private String resolveSubmissionWorkflowStatus(AssessmentSubmission submission, Assessment assessment) {
        if (submission == null) {
            return "Pending Review";
        }
        if ("TimedOut".equalsIgnoreCase(submission.getStatus())) {
            return "Late";
        }
        boolean objective = assessment != null && isObjectiveAssessmentType(assessment.getType());
        if (submission.getScore() == null) {
            return objective ? "Pending Review" : "Pending Review";
        }
        if (objective) {
            return "Auto Graded";
        }
        return "Graded";
    }

    private AssessmentPlacementUtil.Placement resolvePlacement(Assessment assessment) {
        String type = normalize(assessment.getPlacementType());
        if (!type.isEmpty()) {
            Integer materialId = assessment.getPlacementMaterialId();
            if ("afterMaterial".equals(type) && materialId == null) {
                type = "final";
            }
            return new AssessmentPlacementUtil.Placement(type, materialId);
        }
        return AssessmentPlacementUtil.parsePlacement(assessment.getInstructions());
    }

    private boolean isValidPlacementForCourse(Integer courseId, AssessmentPlacementUtil.Placement placement) {
        if (placement == null) {
            return false;
        }
        if (!"afterMaterial".equals(placement.type)) {
            return true;
        }
        if (placement.materialId == null) {
            return false;
        }
        Material material = materialDAO.findById(placement.materialId);
        return material != null && courseId != null && courseId.equals(material.getCourseId());
    }

    private void hydrateAssignmentAttachments(List<Assessment> assessments) {
        if (assessments == null) {
            return;
        }
        for (Assessment assessment : assessments) {
            hydrateAssignmentAttachment(assessment, null);
        }
    }

    private void hydrateAssignmentAttachment(Assessment assessment, List<AssessmentQuestion> knownQuestions) {
        if (assessment == null || assessment.getAssessmentId() == null
                || !Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(assessment.getType())) {
            return;
        }
        List<AssessmentQuestion> questions = knownQuestions;
        if (questions == null) {
            questions = questionDAO.findByAssessment(assessment.getAssessmentId());
        }
        if (questions == null) {
            return;
        }
        for (AssessmentQuestion question : questions) {
            if (question != null && question.getAttachmentUrl() != null && !question.getAttachmentUrl().trim().isEmpty()) {
                assessment.setAttachmentUrl(question.getAttachmentUrl());
                assessment.setAttachmentName(question.getAttachmentName());
                return;
            }
        }
    }

    private boolean isInstructor(HttpSession session) {
        return SessionUtil.resolveUserId(session) != null && "Instructor".equals(SessionUtil.resolveRole(session));
    }

    private boolean isObjectiveAssessmentType(String type) {
        return Assessment.TYPE_QUIZ.equalsIgnoreCase(type)
            || Assessment.TYPE_EXAM.equalsIgnoreCase(type);
    }

    private void sendWorkspaceRedirect(HttpServletRequest request, HttpServletResponse response, Integer courseId, String paramName, String paramValue) throws IOException {
        if (courseId != null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "&" + paramName + "=" + paramValue + "#assessments");
        } else {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?" + paramName + "=" + paramValue);
        }
    }
}

