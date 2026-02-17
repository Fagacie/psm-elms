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
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentRetakeRequest;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Course;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

public class InstructorAssessmentServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentQuestionDAO questionDAO = new AssessmentQuestionDAOImpl();
    private final AssessmentRetakeRequestDAO retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();

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

        Integer userId = (Integer) session.getAttribute("userId");
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
        if (selectedCourseId != null) {
            assessments = assessmentDAO.findByCourse(selectedCourseId);
            if (assessments == null) assessments = new ArrayList<>();
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
        request.setAttribute("selectedAssessment", selectedAssessment);
        request.setAttribute("questions", questions);
        request.setAttribute("retakeRequests", retakeRequests);
        request.setAttribute("submissions", submissions);
        request.setAttribute("gradeFilter", gradeFilter);
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

        if (title.isEmpty() || type.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&error=missing");
            return;
        }

        Assessment assessment = new Assessment();
        assessment.setCourseId(courseId);
        assessment.setTitle(title);
        assessment.setType(type);
        assessment.setDuration(duration);
        assessment.setTotalMarks(totalMarks);
        assessment.setInstructions(instructions);
        assessment.setMaxAttempts(maxAttempts != null && maxAttempts > 0 ? maxAttempts : 1);
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

        if (title.isEmpty() || type.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=missing");
            return;
        }

        assessment.setTitle(title);
        assessment.setType(type);
        assessment.setDuration(duration);
        assessment.setTotalMarks(totalMarks);
        assessment.setInstructions(instructions);
        assessment.setMaxAttempts(maxAttempts != null && maxAttempts > 0 ? maxAttempts : 1);
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

        if ((Assessment.TYPE_QUIZ.equalsIgnoreCase(assessment.getType()) || Assessment.TYPE_EXAM.equalsIgnoreCase(assessment.getType()))
                && (q.getOptionA().isEmpty() || q.getOptionB().isEmpty() || q.getCorrectOption() == null)) {
            response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=qoptions");
            return;
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
        response.sendRedirect(request.getContextPath() + "/instructor/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&gradeFilter=" + gradeFilter + (ok ? "&success=graded" : "&error=grade"));
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

    private boolean isInstructor(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Instructor".equals(role);
    }
}
