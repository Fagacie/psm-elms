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
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.util.AssessmentPlacementUtil;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Locale;
import java.util.stream.Collectors;

@MultipartConfig(maxFileSize = 50 * 1024 * 1024, maxRequestSize = 60 * 1024 * 1024)
public class StudentAssessmentServlet extends HttpServlet {

    private static final long MAX_ASSIGNMENT_UPLOAD_BYTES = 25L * 1024L * 1024L;
    private static final Set<String> ALLOWED_ASSIGNMENT_EXTENSIONS = new HashSet<>();

    static {
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("pdf");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("doc");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("docx");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("txt");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("rtf");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("odt");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("zip");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("png");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("jpg");
        ALLOWED_ASSIGNMENT_EXTENSIONS.add("jpeg");
    }

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentQuestionDAO questionDAO = new AssessmentQuestionDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();
    private final AssessmentRetakeRequestDAO retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();

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

        Integer userId = resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Integer selectedCourseId = parseInt(request.getParameter("courseId"));
        Integer selectedAssessmentId = parseInt(request.getParameter("assessmentId"));
        String action = normalize(request.getParameter("action"));
        boolean fromHub = "1".equals(normalize(request.getParameter("fromHub")));
        Integer fromHubEnrollmentId = parseInt(request.getParameter("enrollmentId"));
        int page = parseIntOrDefault(request.getParameter("page"), 1);

        List<Enrollment> paidEnrollments = getPaidEnrollments(userId);
        request.setAttribute("paidEnrollments", paidEnrollments);
        if (paidEnrollments.isEmpty()) {
            request.getRequestDispatcher("/WEB-INF/views/student/assessments.jsp").forward(request, response);
            return;
        }

        Map<Integer, List<AssessmentSubmission>> submissionsByAssessment = getSubmissionsByAssessment(userId);

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
            final Integer fallbackCourseId = selectedCourseId;
            selectedEnrollment = paidEnrollments.stream()
                    .filter(e -> e.getCourseId() != null && e.getCourseId().equals(fallbackCourseId))
                    .findFirst()
                    .orElse(null);
        }

        if (fromHub && (fromHubEnrollmentId == null
                || selectedEnrollment == null
                || selectedEnrollment.getEnrollmentId() == null
                || !fromHubEnrollmentId.equals(selectedEnrollment.getEnrollmentId()))) {
            fromHub = false;
            fromHubEnrollmentId = null;
        }

        EnrollmentStateSyncService.SyncResult selectedEnrollmentSync = selectedEnrollment != null
                ? enrollmentStateSyncService.syncEnrollmentState(selectedEnrollment)
                : null;

        Course selectedCourse = courseDAO.findById(selectedCourseId);
        List<Assessment> assessments = assessmentDAO.findByCourse(selectedCourseId);
        if (assessments == null) assessments = new ArrayList<>();
        for (Assessment assessment : assessments) {
            assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(assessment.getInstructions()));
        }

        Map<Integer, AssessmentSubmission> latestSubmissionByAssessment = new LinkedHashMap<>();
        Map<Integer, Integer> usedAttemptsByAssessment = new LinkedHashMap<>();
        Map<Integer, Integer> allowedAttemptsByAssessment = new LinkedHashMap<>();
        Map<Integer, Boolean> hasPendingRetakeByAssessment = new LinkedHashMap<>();
        Map<Integer, Boolean> activeAttemptByAssessment = new LinkedHashMap<>();
        for (Assessment assessment : assessments) {
            List<AssessmentSubmission> attempts = submissionsByAssessment.getOrDefault(assessment.getAssessmentId(), new ArrayList<>());
            int usedAttempts = attempts != null ? attempts.size() : 0;
            int allowedAttempts = getAllowedAttempts(userId, assessment);
            boolean hasPendingRetake = retakeRequestDAO.hasPending(assessment.getAssessmentId(), userId);
            AttemptState attemptState = getLiveAttemptState(session, assessment.getAssessmentId(), assessment.getCourseId(), userId);

            usedAttemptsByAssessment.put(assessment.getAssessmentId(), usedAttempts);
            allowedAttemptsByAssessment.put(assessment.getAssessmentId(), allowedAttempts);
            hasPendingRetakeByAssessment.put(assessment.getAssessmentId(), hasPendingRetake);
            activeAttemptByAssessment.put(assessment.getAssessmentId(), attemptState != null);

            if (attempts != null && !attempts.isEmpty()) {
                latestSubmissionByAssessment.put(assessment.getAssessmentId(), attempts.get(0));
            }
        }

        if ("start".equalsIgnoreCase(action) && selectedAssessmentId != null) {
            Assessment assessment = assessmentDAO.findById(selectedAssessmentId);
            if (assessment == null || !selectedCourseId.equals(assessment.getCourseId())) {
                response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&error=invalid" + buildHubQuerySuffix(fromHub, fromHubEnrollmentId));
                return;
            }
            if (!hasPaidAccess(userId, selectedCourseId)) {
                response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&error=permission" + buildHubQuerySuffix(fromHub, fromHubEnrollmentId));
                return;
            }

            int usedAttempts = countUsedAttempts(userId, selectedAssessmentId);
            int allowedAttempts = getAllowedAttempts(userId, assessment);
            if (usedAttempts >= allowedAttempts) {
                response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&assessmentId=" + selectedAssessmentId + "&error=attempts" + buildHubQuerySuffix(fromHub, fromHubEnrollmentId));
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

            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&assessmentId=" + selectedAssessmentId + "&page=1&mode=attempt" + buildHubQuerySuffix(fromHub, fromHubEnrollmentId));
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
                selectedAssessment.setInstructions(AssessmentPlacementUtil.stripPlacement(selectedAssessment.getInstructions()));
                questions = questionDAO.findByAssessment(selectedAssessmentId);
                if (questions == null) questions = new ArrayList<>();
                submissionHistory = submissionsByAssessment.getOrDefault(selectedAssessmentId, new ArrayList<>());

                int usedAttempts = usedAttemptsByAssessment.getOrDefault(selectedAssessmentId, 0);
                int allowedAttempts = getAllowedAttempts(userId, selectedAssessment);
                boolean hasPendingRetake = retakeRequestDAO.hasPending(selectedAssessmentId, userId);
                request.setAttribute("usedAttempts", usedAttempts);
                request.setAttribute("allowedAttempts", allowedAttempts);
                request.setAttribute("canRequestRetake", usedAttempts >= allowedAttempts && !hasPendingRetake);
                request.setAttribute("hasPendingRetake", hasPendingRetake);
                request.setAttribute("assessmentHasActiveAttempt", activeAttemptByAssessment.getOrDefault(selectedAssessmentId, false));
                request.setAttribute("assessmentCanStart", usedAttempts < allowedAttempts);

                activeState = getLiveAttemptState(session, selectedAssessmentId, selectedCourseId, userId);
                if (activeState != null && activeState.assessmentId == selectedAssessmentId && activeState.courseId == selectedCourseId) {
                    if (System.currentTimeMillis() >= activeState.deadlineMillis) {
                        boolean timedOutSubmitted = autoSubmitTimedOut(activeState, questions, userId, session);
                        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + selectedCourseId + "&assessmentId=" + selectedAssessmentId + (timedOutSubmitted ? "&error=timeout" : "&error=submitfailed") + buildHubQuerySuffix(fromHub, fromHubEnrollmentId));
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
        request.setAttribute("selectedEnrollment", selectedEnrollment);
        request.setAttribute("selectedEnrollmentSync", selectedEnrollmentSync);
        request.setAttribute("assessments", assessments);
        request.setAttribute("latestSubmissionByAssessment", latestSubmissionByAssessment);
        request.setAttribute("usedAttemptsByAssessment", usedAttemptsByAssessment);
        request.setAttribute("allowedAttemptsByAssessment", allowedAttemptsByAssessment);
        request.setAttribute("hasPendingRetakeByAssessment", hasPendingRetakeByAssessment);
        request.setAttribute("activeAttemptByAssessment", activeAttemptByAssessment);
        request.setAttribute("selectedAssessment", selectedAssessment);
        request.setAttribute("questions", questions);
        request.setAttribute("submissionHistory", submissionHistory);
        request.setAttribute("modeAttempt", modeAttempt);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pagedQuestions", pagedQuestions);
        request.setAttribute("remainingSeconds", remainingSeconds);
        request.setAttribute("fromHub", fromHub);
        request.setAttribute("fromHubEnrollmentId", fromHubEnrollmentId);
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

        Integer userId = resolveUserId(session);
        if (userId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        String action = normalize(request.getParameter("action"));
        Integer courseId = parseInt(request.getParameter("courseId"));
        Integer assessmentId = parseInt(request.getParameter("assessmentId"));

        if ("requestRetake".equalsIgnoreCase(action)) {
            handleRetakeRequest(request, response, userId, courseId, assessmentId);
            return;
        }

        boolean fromHub = isFromHub(request);
        Integer enrollmentId = sanitizeHubEnrollmentId(userId, courseId, parseInt(request.getParameter("enrollmentId")), fromHub);

        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?error=invalid" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (assessment == null || !courseId.equals(assessment.getCourseId()) || !hasPaidAccess(userId, courseId)) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&error=permission" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        List<AssessmentQuestion> questions = questionDAO.findByAssessment(assessmentId);
        if (questions == null) questions = new ArrayList<>();

        AttemptState state = (AttemptState) session.getAttribute(attemptSessionKey(assessmentId));
        if (state == null || state.assessmentId != assessmentId || state.courseId != courseId) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=noattempt" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        int page = parseIntOrDefault(request.getParameter("page"), 1);
        savePageAnswers(request, state, questions, page);

        if (System.currentTimeMillis() >= state.deadlineMillis) {
            boolean timedOutSubmitted = autoSubmitTimedOut(state, questions, userId, session);
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + (timedOutSubmitted ? "&error=timeout" : "&error=submitfailed") + buildHubQuerySuffix(fromHub, enrollmentId));
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
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&page=" + page + "&mode=attempt" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        if ("submit".equalsIgnoreCase(action)) {
            String uploadedAnswerUrl = null;
            String assignmentTextSummary = null;
            boolean isAssignment = Assessment.TYPE_ASSIGNMENT.equalsIgnoreCase(assessment.getType());
            String submissionMode = normalize(assessment.getSubmissionMode());
            boolean requiresFile = isAssignment && ("file".equalsIgnoreCase(submissionMode) || "both".equalsIgnoreCase(submissionMode));
            boolean requiresText = isAssignment && ("text".equalsIgnoreCase(submissionMode) || "both".equalsIgnoreCase(submissionMode));
            if (isAssignment) {
                try {
                    if (requiresFile) {
                        Part answerFile = request.getPart("answerFile");
                        if (answerFile != null && answerFile.getSize() > 0) {
                            String fileName = extractFileName(answerFile);
                            if (fileName != null && !fileName.trim().isEmpty()) {
                                if (!isAllowedAssignmentFileName(fileName) || answerFile.getSize() > MAX_ASSIGNMENT_UPLOAD_BYTES) {
                                    response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentfiletype" + buildHubQuerySuffix(fromHub, enrollmentId));
                                    return;
                                }
                                try (InputStream in = answerFile.getInputStream()) {
                                    uploadedAnswerUrl = CloudinaryUtil.uploadFile(
                                            in.readAllBytes(),
                                            fileName,
                                            CloudinaryUtil.getAssessmentAnswersFolder(),
                                            "raw"
                                    );
                                }
                            }
                        }
                        if (answerFile == null || answerFile.getSize() == 0) {
                            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentfile" + buildHubQuerySuffix(fromHub, enrollmentId));
                            return;
                        }
                    }

                    if (requiresText) {
                        StringBuilder textSummary = new StringBuilder();
                        for (AssessmentQuestion question : questions) {
                            if (question == null) {
                                continue;
                            }
                            String answer = normalize(request.getParameter("qa_" + question.getQuestionId()));
                            if (!answer.isEmpty()) {
                                if (textSummary.length() > 0) {
                                    textSummary.append(';');
                                }
                                textSummary.append('Q').append(question.getQuestionId()).append(':').append(answer.replace(";", ","));
                            }
                        }
                        assignmentTextSummary = textSummary.toString();
                        if (assignmentTextSummary.isEmpty()) {
                            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmenttext" + buildHubQuerySuffix(fromHub, enrollmentId));
                            return;
                        }
                    }

                    if (!requiresFile && !requiresText) {
                        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmenttext" + buildHubQuerySuffix(fromHub, enrollmentId));
                        return;
                    }
                } catch (Exception ignored) {
                    response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=assignmentfile" + buildHubQuerySuffix(fromHub, enrollmentId));
                    return;
                }
            }

            boolean submitted = submitAttempt(state, assessment, questions, userId, session, "Submitted", uploadedAnswerUrl, assignmentTextSummary);
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + (submitted ? "&success=submitted" : "&error=submitfailed") + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId);
    }

    private void handleRetakeRequest(HttpServletRequest request, HttpServletResponse response, Integer userId, Integer courseId, Integer assessmentId)
            throws IOException {
        boolean fromHub = isFromHub(request);
        Integer enrollmentId = sanitizeHubEnrollmentId(userId, courseId, parseInt(request.getParameter("enrollmentId")), fromHub);

        if (courseId == null || assessmentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?error=invalid" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        Assessment assessment = assessmentDAO.findById(assessmentId);
        if (assessment == null || !courseId.equals(assessment.getCourseId()) || !hasPaidAccess(userId, courseId)) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=permission" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        int usedAttempts = countUsedAttempts(userId, assessmentId);
        int allowedAttempts = getAllowedAttempts(userId, assessment);
        if (usedAttempts < allowedAttempts) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=retakenotneeded" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        if (retakeRequestDAO.hasPending(assessmentId, userId)) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=retakepending" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }

        AssessmentRetakeRequest retake = new AssessmentRetakeRequest();
        retake.setAssessmentId(assessmentId);
        retake.setUserId(userId);
        String reason = normalize(request.getParameter("reason"));
        if (reason.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + "&error=retakereason" + buildHubQuerySuffix(fromHub, enrollmentId));
            return;
        }
        retake.setReason(reason);
        retake.setStatus("Pending");

        AssessmentRetakeRequest created = retakeRequestDAO.create(retake);
        response.sendRedirect(request.getContextPath() + "/student/assessments?courseId=" + courseId + "&assessmentId=" + assessmentId + (created != null ? "&success=retakerequested" : "&error=retakefailed") + buildHubQuerySuffix(fromHub, enrollmentId));
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

    private boolean autoSubmitTimedOut(AttemptState state, List<AssessmentQuestion> questions, Integer userId, HttpSession session) {
        return submitAttempt(state, assessmentDAO.findById(state.assessmentId), questions, userId, session, "TimedOut", null, null);
    }

    private boolean submitAttempt(AttemptState state, Assessment assessment, List<AssessmentQuestion> questions,
                               Integer userId, HttpSession session, String status, String uploadedAnswerUrl, String assignmentTextSummary) {
        if (assessment == null) return false;

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

        String gradingMode = normalize(assessment.getGradingMode());
        boolean objectiveType = Assessment.TYPE_QUIZ.equalsIgnoreCase(assessment.getType())
            || Assessment.TYPE_EXAM.equalsIgnoreCase(assessment.getType());
        boolean shouldAutoGrade = objectiveType && !"manual".equalsIgnoreCase(gradingMode);

        Double score = null;
        if (shouldAutoGrade && totalObjectiveMarks > 0.0) {
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
        if (uploadedAnswerUrl != null && !uploadedAnswerUrl.trim().isEmpty()) {
            submission.setAnswersFilePath(uploadedAnswerUrl);
        } else {
            String finalSummary = assignmentTextSummary != null ? assignmentTextSummary : answersSummary;
            submission.setAnswersFilePath(finalSummary.isEmpty() ? null : finalSummary);
        }
        AssessmentSubmission createdSubmission = submissionDAO.submit(submission);
        if (createdSubmission == null) {
            return false;
        }
        syncEnrollmentProgress(userId, state.courseId);

        session.removeAttribute(attemptSessionKey(state.assessmentId));
        return true;
    }

    private void syncEnrollmentProgress(Integer userId, Integer courseId) {
        if (userId == null || courseId == null) {
            return;
        }

        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) {
            return;
        }

        for (Enrollment enrollment : enrollments) {
            if (enrollment != null && enrollment.getCourseId() != null && enrollment.getCourseId().equals(courseId)) {
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
                return;
            }
        }
    }

    private boolean isFromHub(HttpServletRequest request) {
        return "1".equals(normalize(request.getParameter("fromHub")));
    }

    private String buildHubQuerySuffix(boolean fromHub, Integer enrollmentId) {
        if (!fromHub || enrollmentId == null) {
            return "";
        }
        return "&fromHub=1&enrollmentId=" + enrollmentId;
    }

    private int countUsedAttempts(Integer userId, Integer assessmentId) {
        List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessmentId, userId);
        return submissions == null ? 0 : submissions.size();
    }

    private Map<Integer, List<AssessmentSubmission>> getSubmissionsByAssessment(Integer userId) {
        List<AssessmentSubmission> submissions = submissionDAO.findByUser(userId);
        Map<Integer, List<AssessmentSubmission>> submissionsByAssessment = new LinkedHashMap<>();
        if (submissions == null) {
            return submissionsByAssessment;
        }

        for (AssessmentSubmission submission : submissions) {
            if (submission == null || submission.getAssessmentId() == null) {
                continue;
            }
            submissionsByAssessment
                    .computeIfAbsent(submission.getAssessmentId(), key -> new ArrayList<>())
                    .add(submission);
        }
        return submissionsByAssessment;
    }

    private int getAllowedAttempts(Integer userId, Assessment assessment) {
        int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
        int base = assessment.getMaxAttempts() != null && assessment.getMaxAttempts() > 0 ? assessment.getMaxAttempts() : defaultMaxAttempts;
        int approvedExtra = retakeRequestDAO.countApproved(assessment.getAssessmentId(), userId);
        return base + approvedExtra;
    }

    private String attemptSessionKey(int assessmentId) {
        return "assessmentAttempt_" + assessmentId;
    }

    private AttemptState getLiveAttemptState(HttpSession session, int assessmentId, Integer courseId, Integer userId) {
        if (session == null) {
            return null;
        }

        Object raw = session.getAttribute(attemptSessionKey(assessmentId));
        if (!(raw instanceof AttemptState)) {
            if (raw != null) {
                session.removeAttribute(attemptSessionKey(assessmentId));
            }
            return null;
        }

        AttemptState state = (AttemptState) raw;
        if (state.assessmentId != assessmentId || courseId == null || state.courseId != courseId) {
            session.removeAttribute(attemptSessionKey(assessmentId));
            return null;
        }

        if (System.currentTimeMillis() >= state.deadlineMillis) {
            List<AssessmentQuestion> timedOutQuestions = questionDAO.findByAssessment(assessmentId);
            if (timedOutQuestions == null) {
                timedOutQuestions = new ArrayList<>();
            }
            autoSubmitTimedOut(state, timedOutQuestions, userId, session);
            return null;
        }

        return state;
    }

    private List<Enrollment> getPaidEnrollments(Integer userId) {
        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) return new ArrayList<>();

        return enrollments.stream()
                .filter(e -> e.getEnrollmentId() != null)
                .filter(e -> {
                    if (e.getCoursePrice() != null && e.getCoursePrice() <= 0) {
                        return true;
                    }
                    Payment payment = paymentDAO.getPaymentByEnrollmentId(e.getEnrollmentId());
                    return payment != null && isPaymentComplete(payment.getStatus());
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

    private int parseIntOrDefault(String value, int defaultValue) {
        Integer parsed = parseInt(value);
        return parsed != null ? parsed : defaultValue;
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isPaymentComplete(String paymentStatus) {
        if (paymentStatus == null) return false;
        String normalized = paymentStatus.trim();
        return "Paid".equalsIgnoreCase(normalized)
                || "Completed".equalsIgnoreCase(normalized)
                || "Success".equalsIgnoreCase(normalized);
    }

    private Integer sanitizeHubEnrollmentId(Integer userId, Integer courseId, Integer enrollmentId, boolean fromHub) {
        if (!fromHub || userId == null || courseId == null || enrollmentId == null) {
            return null;
        }

        List<Enrollment> paidEnrollments = getPaidEnrollments(userId);
        for (Enrollment enrollment : paidEnrollments) {
            if (enrollment.getEnrollmentId() == null || enrollment.getCourseId() == null) continue;
            if (enrollmentId.equals(enrollment.getEnrollmentId()) && courseId.equals(enrollment.getCourseId())) {
                return enrollmentId;
            }
        }
        return null;
    }

    private String extractFileName(Part part) {
        if (part == null || part.getSubmittedFileName() == null) {
            return null;
        }
        String submitted = part.getSubmittedFileName().trim();
        if (submitted.isEmpty()) {
            return null;
        }
        int slash = Math.max(submitted.lastIndexOf('/'), submitted.lastIndexOf('\\'));
        return slash >= 0 ? submitted.substring(slash + 1) : submitted;
    }

    private boolean isAllowedAssignmentFileName(String fileName) {
        if (fileName == null) {
            return false;
        }
        int idx = fileName.lastIndexOf('.');
        if (idx < 0 || idx == fileName.length() - 1) {
            return false;
        }
        String ext = fileName.substring(idx + 1).toLowerCase(Locale.ROOT);
        return ALLOWED_ASSIGNMENT_EXTENSIONS.contains(ext);
    }

    private boolean isStudent(HttpSession session) {
        return SessionUtil.resolveUserId(session) != null && "Student".equals(SessionUtil.resolveRole(session));
    }
}
