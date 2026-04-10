package com.psm.elearning.controller.instructor;

import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.AssessmentQuestionDAO;
import com.psm.elearning.dao.AssessmentQuestionDAOImpl;
import com.psm.elearning.dao.AssessmentRetakeRequestDAO;
import com.psm.elearning.dao.AssessmentRetakeRequestDAOImpl;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAOImpl;
import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentRetakeRequest;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Material;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.util.AssessmentPlacementUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class InstructorAssessmentServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentQuestionDAO questionDAO = new AssessmentQuestionDAOImpl();
    private final AssessmentRetakeRequestDAO retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String action = normalize(request.getParameter("action"));

        if ("exportSubmissionsCsv".equals(action)) {
            exportSubmissionsCsv(request, response, userId);
            return;
        }
        if ("deleteAssessment".equals(action)) {
            deleteAssessment(request, response, userId);
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

        Integer userId = resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = normalize(request.getParameter("action"));

        if ("createAssessment".equals(action)) {
            createAssessment(request, response, userId);
            return;
        }
        if ("updateAssessment".equals(action)) {
            updateAssessment(request, response, userId);
            return;
        }
        if ("addQuestion".equals(action)) {
            addQuestion(request, response, userId);
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

        loadPage(request, response, userId);
    }

    private void loadPage(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws ServletException, IOException {

        Integer selectedCourseId = parseInt(request.getParameter("courseId"));
        Integer selectedAssessmentId = parseInt(request.getParameter("assessmentId"));
        String gradeFilter = normalize(request.getParameter("gradeFilter"));
        if (gradeFilter.isEmpty()) gradeFilter = "all";

        List<Course> courses = courseDAO.findByInstructor(userId);
        if (courses == null) courses = new ArrayList<>();
        request.setAttribute("courses", courses);

        Course selectedCourse = null;
        if (selectedCourseId != null) {
            selectedCourse = courseDAO.findById(selectedCourseId);
            if (selectedCourse == null || !userId.equals(selectedCourse.getCreatedBy())) {
                request.setAttribute("errorMessage", "You are not allowed to manage this course assessments.");
                selectedCourse = null;
                selectedCourseId = null;
                selectedAssessmentId = null;
            }
        }

        List<Assessment> assessments = new ArrayList<>();
        List<Material> materials = new ArrayList<>();
        if (selectedCourseId != null) {
            assessments = assessmentDAO.findByCourse(selectedCourseId);
            if (assessments == null) assessments = new ArrayList<>();
            materials = materialDAO.findByCourse(selectedCourseId);
            if (materials == null) materials = new ArrayList<>();
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
        if (selectedAssessmentId != null) {
            selectedAssessment = assessmentDAO.findById(selectedAssessmentId);
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
                retakeRequests = retakeRequestDAO.findByAssessment(selectedAssessmentId);
                if (retakeRequests == null) retakeRequests = new ArrayList<>();
                submissions = submissionDAO.findByAssessment(selectedAssessmentId);
                if (submissions == null) submissions = new ArrayList<>();
                submissions = filterSubmissions(submissions, gradeFilter);
            }
        }

        request.setAttribute("selectedCourse", selectedCourse);
        request.setAttribute("assessments", assessments);
        request.setAttribute("materials", materials);
        request.setAttribute("selectedAssessment", selectedAssessment);
        request.setAttribute("questions", questions);
        request.setAttribute("retakeRequests", retakeRequests);
        request.setAttribute("submissions", submissions);
        request.setAttribute("gradeFilter", gradeFilter);
        request.setAttribute("assessmentPlacementTypeMap", placementTypeByAssessmentId);
        request.setAttribute("assessmentPlacementMaterialIdMap", placementMaterialByAssessmentId);
        request.getRequestDispatcher("/WEB-INF/views/instructor/course-assessments.jsp").forward(request, response);
    }

    private void createAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        if (courseId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !userId.equals(course.getCreatedBy())) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=permission");
            return;
        }

        String title = normalize(request.getParameter("title"));
        String type = normalize(request.getParameter("type"));
        Integer duration = parseInt(request.getParameter("duration"));
        Integer totalMarks = parseInt(request.getParameter("totalMarks"));
        Integer maxAttempts = parseInt(request.getParameter("maxAttempts"));
        Integer questionsPerPage = parseInt(request.getParameter("questionsPerPage"));
        String instructions = normalize(request.getParameter("instructions"));
        String placement = normalize(request.getParameter("placement"));

        if (title.isEmpty() || type.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&error=missing");
            return;
        }

        if (!isSupportedAssessmentType(type)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&error=type");
            return;
        }

        Assessment assessment = new Assessment();
        assessment.setCourseId(courseId);
        assessment.setTitle(title);
        assessment.setType(type);
        assessment.setDuration(duration);
        assessment.setTotalMarks(totalMarks);
        AssessmentPlacementUtil.Placement parsedPlacement = AssessmentPlacementUtil.parsePlacement(AssessmentPlacementUtil.applyPlacement("", placement));
        if (!isValidPlacementForCourse(courseId, parsedPlacement)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&error=placement");
            return;
        }
        assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(instructions));
        assessment.setPlacementType(parsedPlacement.type);
        assessment.setPlacementMaterialId(parsedPlacement.materialId);
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        assessment.setMaxAttempts(maxAttempts != null && maxAttempts > 0 ? maxAttempts : defaultMaxAttempts);
        assessment.setQuestionsPerPage(questionsPerPage != null && questionsPerPage > 0 ? questionsPerPage : 2);
        assessment.setCreatedBy(userId);

        Assessment created = assessmentDAO.create(assessment);
        if (created == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&error=create");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + created.getAssessmentId() + "&success=created");
    }

    private void updateAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=permission");
            return;
        }

        String title = normalize(request.getParameter("title"));
        String type = normalize(request.getParameter("type"));
        Integer duration = parseInt(request.getParameter("duration"));
        Integer totalMarks = parseInt(request.getParameter("totalMarks"));
        Integer maxAttempts = parseInt(request.getParameter("maxAttempts"));
        Integer questionsPerPage = parseInt(request.getParameter("questionsPerPage"));
        String instructions = normalize(request.getParameter("instructions"));
        String placement = normalize(request.getParameter("placement"));

        if (title.isEmpty() || type.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=missing");
            return;
        }

        if (!isSupportedAssessmentType(type)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=type");
            return;
        }

        assessment.setTitle(title);
        assessment.setType(type);
        assessment.setDuration(duration);
        assessment.setTotalMarks(totalMarks);
        AssessmentPlacementUtil.Placement parsedPlacement = AssessmentPlacementUtil.parsePlacement(AssessmentPlacementUtil.applyPlacement("", placement));
        if (!isValidPlacementForCourse(courseId, parsedPlacement)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=placement");
            return;
        }
        assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(instructions));
        assessment.setPlacementType(parsedPlacement.type);
        assessment.setPlacementMaterialId(parsedPlacement.materialId);
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        assessment.setMaxAttempts(maxAttempts != null && maxAttempts > 0 ? maxAttempts : defaultMaxAttempts);
        assessment.setQuestionsPerPage(questionsPerPage != null && questionsPerPage > 0 ? questionsPerPage : 2);

        boolean updated = assessmentDAO.update(assessment);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + (updated ? "&success=updated" : "&error=update"));
    }

    private void deleteAssessment(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("id"));
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=permission");
            return;
        }

        boolean deleted = assessmentDAO.delete(assessmentId);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + (deleted ? "&success=deleted" : "&error=delete"));
    }

    private void addQuestion(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=permission");
            return;
        }

        String questionText = normalize(request.getParameter("questionText"));
        if (questionText.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qmissing");
            return;
        }

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
        if (Assessment.TYPE_QUIZ.equalsIgnoreCase(normalizedType)) {
            if (q.getOptionA().isEmpty() || q.getOptionB().isEmpty() || q.getCorrectOption() == null || !isValidCorrectOption(q.getCorrectOption())) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qoptions");
                return;
            }
        } else if (Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(normalizedType)) {
            if (!q.getOptionA().isEmpty() || !q.getOptionB().isEmpty() || !q.getOptionC().isEmpty() || !q.getOptionD().isEmpty() || q.getCorrectOption() != null) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentschema");
                return;
            }
        } else if (Assessment.TYPE_EXAM.equalsIgnoreCase(normalizedType)) {
            boolean hasAnyOptions = !q.getOptionA().isEmpty() || !q.getOptionB().isEmpty() || !q.getOptionC().isEmpty() || !q.getOptionD().isEmpty();
            if (hasAnyOptions) {
                if (q.getOptionA().isEmpty() || q.getOptionB().isEmpty() || q.getCorrectOption() == null || !isValidCorrectOption(q.getCorrectOption())) {
                    response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=examschema");
                    return;
                }
            } else if (q.getCorrectOption() != null) {
                response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=examschema");
                return;
            }
        }

        AssessmentQuestion created = questionDAO.addQuestion(q);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + (created != null ? "&success=qcreated" : "&error=qcreate"));
    }

    private void deleteQuestion(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));
        Integer questionId = parseInt(request.getParameter("id"));
        if (courseId == null || assessmentId == null || questionId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentQuestion question = questionDAO.findById(questionId);
        if (course == null || assessment == null || question == null || !userId.equals(course.getCreatedBy())
                || !assessment.getCourseId().equals(courseId) || !question.getAssessmentId().equals(assessmentId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=permission");
            return;
        }

        boolean deleted = questionDAO.delete(questionId);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + (deleted ? "&success=qdeleted" : "&error=qdelete"));
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
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (course == null || assessment == null || !userId.equals(course.getCreatedBy()) || !assessment.getCourseId().equals(courseId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=permission");
            return;
        }

        String nextStatus = "reject".equalsIgnoreCase(decision) ? "Rejected" : "Approved";
        boolean ok = retakeRequestDAO.updateStatus(requestId, nextStatus, userId);
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + (ok ? "&success=rreviewed" : "&error=rreview"));
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
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Assessment assessment = assessmentDAO.findById(assessmentId);
        AssessmentSubmission submission = submissionDAO.findById(submissionId);
        if (course == null || assessment == null || submission == null || !userId.equals(course.getCreatedBy())
                || !assessment.getCourseId().equals(courseId) || !submission.getAssessmentId().equals(assessmentId)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?error=permission");
            return;
        }

        boolean ok = submissionDAO.gradeSubmission(submissionId, score, feedback);
        if (ok && submission.getUserId() != null) {
            com.psm.elearning.model.Enrollment enrollment = findEnrollmentForCourse(submission.getUserId(), courseId);
            if (enrollment != null) {
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
            }
        }
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + (ok ? "&success=graded" : "&error=grade"));
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

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private Integer resolveUserId(HttpSession session) {
        if (session == null) return null;
        Object userId = session.getAttribute("userId");
        if (userId == null) return null;
        
        if (userId instanceof Integer) {
            int id = (Integer) userId;
            return id > 0 ? id : null;
        }
        
        if (userId instanceof String) {
            try {
                int id = Integer.parseInt((String) userId);
                return id > 0 ? id : null;
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }

    private boolean isSupportedAssessmentType(String type) {
        return Assessment.TYPE_QUIZ.equalsIgnoreCase(type)
                || Assessment.TYPE_EXAM.equalsIgnoreCase(type)
                || Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(type);
    }

    private boolean isValidCorrectOption(String option) {
        return "A".equalsIgnoreCase(option)
                || "B".equalsIgnoreCase(option)
                || "C".equalsIgnoreCase(option)
                || "D".equalsIgnoreCase(option);
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

    private boolean isInstructor(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Instructor".equals(role);
    }
}
