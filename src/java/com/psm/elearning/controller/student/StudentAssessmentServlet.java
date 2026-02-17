package com.psm.elearning.controller.student;

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
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentRetakeRequest;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class StudentAssessmentServlet extends HttpServlet {

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentQuestionDAO questionDAO = new AssessmentQuestionDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();
    private final AssessmentRetakeRequestDAO retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();

    private static class AttemptState {
        int courseId;
        int assessmentId;
        int attemptNumber;
        long startedAtMillis;
        long deadlineMillis;
        int questionsPerPage;
        Map<Integer, String> answers = new HashMap<>();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        Integer selectedCourseId = parseInt(request.getParameter("courseId"));
        Integer selectedAssessmentId = parseInt(request.getParameter("assessmentId"));
        String action = normalize(request.getParameter("action"));
        int page = parseIntOrDefault(request.getParameter("page"), 1);

        List<Enrollment> paidEnrollments = getPaidEnrollments(userId);
        request.setAttribute("paidEnrollments", paidEnrollments);
        if (paidEnrollments.isEmpty()) {
            request.getRequestDispatcher("/WEB-INF/views/student/assessments.jsp").forward(request, response);
            return;
        }

        if (selectedCourseId == null) {
            selectedCourseId = paidEnrollments.get(0).getCourseId();
        }

        final Integer requestedCourseId = selectedCourseId;
        Enrollment selectedEnrollment = paidEnrollments.stream()
                .filter(e -> e.getCourseId() != null && e.getCourseId().equals(requestedCourseId))
                .findFirst()
                .orElse(null);
        if (selectedEnrollment == null) {
            request.setAttribute("errorMessage", "You do not have paid access to this course.");
            selectedCourseId = paidEnrollments.get(0).getCourseId();
        }

        Course selectedCourse = courseDAO.findById(selectedCourseId);
        List<Assessment> assessments = assessmentDAO.findByCourse(selectedCourseId);
        if (assessments == null) assessments = new ArrayList<>();

        Map<Integer, AssessmentSubmission> latestSubmissionByAssessment = new LinkedHashMap<>();
        for (Assessment assessment : assessments) {
            List<AssessmentSubmission> attempts = submissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), userId);
            if (attempts != null && !attempts.isEmpty()) {
                latestSubmissionByAssessment.put(assessment.getAssessmentId(), attempts.get(0));
            }
        }

        if ("start".equalsIgnoreCase(action) && selectedAssessmentId != null) {
            Assessment assessment = assessmentDAO.findById(selectedAssessmentId);
            if (assessment == null || !selectedCourseId.equals(assessment.getCourseId())) {
                response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&error=invalid");
                return;
            }
            if (!hasPaidAccess(userId, selectedCourseId)) {
                response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&error=permission");
                return;
            }

            int usedAttempts = countUsedAttempts(userId, selectedAssessmentId);
            int allowedAttempts = getAllowedAttempts(userId, assessment);
            if (usedAttempts >= allowedAttempts) {
                response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&assessmentId=" + selectedAssessmentId + "&error=attempts");
                return;
            }

            AttemptState state = new AttemptState();
            state.courseId = selectedCourseId;
            state.assessmentId = selectedAssessmentId;
            state.attemptNumber = usedAttempts + 1;
            state.startedAtMillis = System.currentTimeMillis();
            int durationMinutes = assessment.getDuration() != null && assessment.getDuration() > 0 ? assessment.getDuration() : 30;
            state.deadlineMillis = state.startedAtMillis + (durationMinutes * 60L * 1000L);
            state.questionsPerPage = assessment.getQuestionsPerPage() != null && assessment.getQuestionsPerPage() > 0 ? assessment.getQuestionsPerPage() : 2;
            session.setAttribute(attemptSessionKey(selectedAssessmentId), state);

            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&assessmentId=" + selectedAssessmentId + "&page=1&mode=attempt");
            return;
        }

        Assessment selectedAssessment = null;
        List<AssessmentQuestion> questions = new ArrayList<>();
        List<AssessmentSubmission> submissionHistory = new ArrayList<>();
        AttemptState activeState = null;
        List<AssessmentQuestion> pagedQuestions = new ArrayList<>();
        int totalPages = 1;
        long remainingSeconds = 0;
        boolean modeAttempt = false;

        if (selectedAssessmentId != null) {
            selectedAssessment = assessmentDAO.findById(selectedAssessmentId);
            if (selectedAssessment == null || !selectedCourseId.equals(selectedAssessment.getCourseId())) {
                request.setAttribute("errorMessage", "Invalid assessment selected.");
                selectedAssessment = null;
            } else {
                questions = questionDAO.findByAssessment(selectedAssessmentId);
                if (questions == null) questions = new ArrayList<>();
                submissionHistory = submissionDAO.findByAssessmentAndUser(selectedAssessmentId, userId);
                if (submissionHistory == null) submissionHistory = new ArrayList<>();

                int usedAttempts = countUsedAttempts(userId, selectedAssessmentId);
                int allowedAttempts = getAllowedAttempts(userId, selectedAssessment);
                boolean hasPendingRetake = retakeRequestDAO.hasPending(selectedAssessmentId, userId);
                request.setAttribute("usedAttempts", usedAttempts);
                request.setAttribute("allowedAttempts", allowedAttempts);
                request.setAttribute("canRequestRetake", usedAttempts >= allowedAttempts && !hasPendingRetake);
                request.setAttribute("hasPendingRetake", hasPendingRetake);

                activeState = (AttemptState) session.getAttribute(attemptSessionKey(selectedAssessmentId));
                if (activeState != null && activeState.assessmentId == selectedAssessmentId && activeState.courseId == selectedCourseId) {
                    if (System.currentTimeMillis() >= activeState.deadlineMillis) {
                        autoSubmitTimedOut(activeState, questions, userId, session);
                        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&assessmentId=" + selectedAssessmentId + "&error=timeout");
                        return;
                    }

                    modeAttempt = "attempt".equalsIgnoreCase(normalize(request.getParameter("mode")));
                    int qpp = activeState.questionsPerPage > 0 ? activeState.questionsPerPage : 2;
                    totalPages = Math.max(1, (int) Math.ceil((double) Math.max(questions.size(), 1) / qpp));
                    page = Math.min(Math.max(page, 1), totalPages);
                    int from = (page - 1) * qpp;
                    int to = Math.min(from + qpp, questions.size());
                    if (from < to) {
                        pagedQuestions = questions.subList(from, to);
                    }
                    remainingSeconds = Math.max(0, (activeState.deadlineMillis - System.currentTimeMillis()) / 1000L);
                    request.setAttribute("questionsPerPageActual", qpp);
                }
            }
        }

        request.setAttribute("selectedCourse", selectedCourse);
        request.setAttribute("selectedCourseId", selectedCourseId);
        request.setAttribute("assessments", assessments);
        request.setAttribute("latestSubmissionByAssessment", latestSubmissionByAssessment);
        request.setAttribute("selectedAssessment", selectedAssessment);
        request.setAttribute("questions", questions);
        request.setAttribute("submissionHistory", submissionHistory);
        request.setAttribute("modeAttempt", modeAttempt);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pagedQuestions", pagedQuestions);
        request.setAttribute("remainingSeconds", remainingSeconds);
        if (activeState != null) {
            request.setAttribute("currentAnswers", activeState.answers);
        }
        request.getRequestDispatcher("/WEB-INF/views/student/assessments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String action = normalize(request.getParameter("action"));
        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));

        if ("requestRetake".equalsIgnoreCase(action)) {
            handleRetakeRequest(request, response, userId, courseId, assessmentId);
            return;
        }

        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?error=invalid");
            return;
        }

        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (assessment == null || !courseId.equals(assessment.getCourseId()) || !hasPaidAccess(userId, courseId)) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&error=permission");
            return;
        }

        List<AssessmentQuestion> questions = questionDAO.findByAssessment(assessmentId);
        if (questions == null) questions = new ArrayList<>();

        AttemptState state = (AttemptState) session.getAttribute(attemptSessionKey(assessmentId));
        if (state == null) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=noattempt");
            return;
        }

        int page = parseIntOrDefault(request.getParameter("page"), 1);
        savePageAnswers(request, state, questions, page);

        if (System.currentTimeMillis() >= state.deadlineMillis) {
            autoSubmitTimedOut(state, questions, userId, session);
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=timeout");
            return;
        }

        if ("savePage".equalsIgnoreCase(action)) {
            String nav = normalize(request.getParameter("nav"));
            int qpp = state.questionsPerPage > 0 ? state.questionsPerPage : 2;
            int totalPages = Math.max(1, (int) Math.ceil((double) Math.max(questions.size(), 1) / qpp));
            if ("prev".equalsIgnoreCase(nav)) {
                page = Math.max(1, page - 1);
            } else {
                page = Math.min(totalPages, page + 1);
            }
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&page=" + page + "&mode=attempt");
            return;
        }

        if ("submit".equalsIgnoreCase(action)) {
            submitAttempt(state, assessment, questions, userId, session, "Submitted");
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&success=submitted");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId);
    }

    private void handleRetakeRequest(HttpServletRequest request, HttpServletResponse response, Integer userId, Integer courseId, Integer assessmentId)
            throws IOException {
        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?error=invalid");
            return;
        }

        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (assessment == null || !courseId.equals(assessment.getCourseId()) || !hasPaidAccess(userId, courseId)) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=permission");
            return;
        }

        int usedAttempts = countUsedAttempts(userId, assessmentId);
        int allowedAttempts = getAllowedAttempts(userId, assessment);
        if (usedAttempts < allowedAttempts) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=retakenotneeded");
            return;
        }

        if (retakeRequestDAO.hasPending(assessmentId, userId)) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=retakepending");
            return;
        }

        AssessmentRetakeRequest retake = new AssessmentRetakeRequest();
        retake.setAssessmentId(assessmentId);
        retake.setUserId(userId);
        retake.setReason(normalize(request.getParameter("reason")));
        retake.setStatus("Pending");

        AssessmentRetakeRequest created = retakeRequestDAO.create(retake);
        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + (created != null ? "&success=retakerequested" : "&error=retakefailed"));
    }

    private void savePageAnswers(HttpServletRequest request, AttemptState state, List<AssessmentQuestion> questions, int page) {
        int qpp = state.questionsPerPage > 0 ? state.questionsPerPage : 2;
        int from = Math.max(0, (page - 1) * qpp);
        int to = Math.min(from + qpp, questions.size());
        for (int i = from; i < to; i++) {
            AssessmentQuestion q = questions.get(i);
            String answer = null;
            boolean hasOptions = !normalize(q.getOptionA()).isEmpty() || !normalize(q.getOptionB()).isEmpty() || !normalize(q.getOptionC()).isEmpty() || !normalize(q.getOptionD()).isEmpty();
            if (hasOptions) {
                answer = normalize(request.getParameter("q_" + q.getQuestionId()));
            } else {
                answer = normalize(request.getParameter("qa_" + q.getQuestionId()));
            }
            if (answer != null) {
                if (answer.isEmpty()) {
                    state.answers.remove(q.getQuestionId());
                } else {
                    state.answers.put(q.getQuestionId(), answer);
                }
            }
        }
    }

    private void autoSubmitTimedOut(AttemptState state, List<AssessmentQuestion> questions, Integer userId, HttpSession session) {
        submitAttempt(state, assessmentDAO.findById(state.assessmentId), questions, userId, session, "TimedOut");
    }

    private void submitAttempt(AttemptState state, Assessment assessment, List<AssessmentQuestion> questions,
                               Integer userId, HttpSession session, String status) {
        if (assessment == null) return;

        double earned = 0.0;
        double totalObjectiveMarks = 0.0;
        StringBuilder summary = new StringBuilder();

        for (AssessmentQuestion q : questions) {
            String ans = state.answers.get(q.getQuestionId());
            if (ans != null && !ans.isEmpty()) {
                summary.append("Q").append(q.getQuestionId()).append(":")
                        .append(ans.replace(";", ","))
                        .append(";");
            }

            boolean hasCorrect = q.getCorrectOption() != null && !q.getCorrectOption().trim().isEmpty();
            if (hasCorrect) {
                double marks = q.getMarks() != null ? q.getMarks() : 1.0;
                totalObjectiveMarks += marks;
                if (ans != null && q.getCorrectOption().equalsIgnoreCase(ans)) {
                    earned += marks;
                }
            }
        }

        Double score = null;
        if ((Assessment.TYPE_QUIZ.equalsIgnoreCase(assessment.getType()) || Assessment.TYPE_EXAM.equalsIgnoreCase(assessment.getType()))
                && totalObjectiveMarks > 0.0) {
            score = earned;
        }

        String answersSummary = summary.toString();
        if (answersSummary.length() > 255) {
            answersSummary = answersSummary.substring(0, 255);
        }

        AssessmentSubmission submission = new AssessmentSubmission();
        submission.setAssessmentId(state.assessmentId);
        submission.setUserId(userId);
        submission.setAttemptNumber(state.attemptNumber);
        submission.setScore(score);
        submission.setStatus(status);
        submission.setStartedAt(LocalDateTime.now().minusSeconds(Math.max(0, (System.currentTimeMillis() - state.startedAtMillis) / 1000L)));
        submission.setEndedAt(LocalDateTime.now());
        submission.setAnswersFilePath(answersSummary.isEmpty() ? null : answersSummary);
        submissionDAO.submit(submission);

        session.removeAttribute(attemptSessionKey(state.assessmentId));
    }

    private int countUsedAttempts(Integer userId, Integer assessmentId) {
        List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessmentId, userId);
        return submissions == null ? 0 : submissions.size();
    }

    private int getAllowedAttempts(Integer userId, Assessment assessment) {
        int base = assessment.getMaxAttempts() != null && assessment.getMaxAttempts() > 0 ? assessment.getMaxAttempts() : 1;
        int approvedExtra = retakeRequestDAO.countApproved(assessment.getAssessmentId(), userId);
        return base + approvedExtra;
    }

    private String attemptSessionKey(int assessmentId) {
        return "assessmentAttempt_" + assessmentId;
    }

    private List<Enrollment> getPaidEnrollments(Integer userId) {
        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) return new ArrayList<>();

        return enrollments.stream()
                .filter(e -> e.getEnrollmentId() != null)
                .filter(e -> {
                    Payment payment = paymentDAO.getPaymentByEnrollmentId(e.getEnrollmentId());
                    return payment != null && "Paid".equalsIgnoreCase(payment.getStatus());
                })
                .collect(Collectors.toList());
    }

    private boolean hasPaidAccess(Integer userId, Integer courseId) {
        List<Enrollment> paid = getPaidEnrollments(userId);
        return paid.stream().anyMatch(e -> e.getCourseId() != null && e.getCourseId().equals(courseId));
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        Integer parsed = parseInt(value);
        return parsed != null ? parsed : defaultValue;
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isStudent(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Student".equals(role);
    }
}
