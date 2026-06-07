package com.psm.elearning.controller;

import com.psm.elearning.dao.*;
import com.psm.elearning.model.*;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.psm.elearning.util.DBConnection;

public class DashboardServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DashboardServlet.class.getName());

    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private UserDAO userDAO;
    private PaymentDAO paymentDAO;
    private CertificateDAO certificateDAO;
    private NotificationDAO notificationDAO;
    private MaterialDAO materialDAO;
    private AssessmentDAO assessmentDAO;
    private AssessmentSubmissionDAO assessmentSubmissionDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        userDAO = new UserDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        certificateDAO = new CertificateDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        materialDAO = new MaterialDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
        assessmentSubmissionDAO = new AssessmentSubmissionDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("user", user);
        
        // Pass student data if available
        Student student = (Student) session.getAttribute("student");
        if (student != null) {
            request.setAttribute("student", student);
        }
        
        String role = SessionUtil.resolveRole(session);

        // Fetch dashboard data for students
        if ("Student".equals(role)) {
            try {
                List<Enrollment> enrolledCourses = enrollmentDAO.getEnrollmentsByStudent(user.getUserId());
                request.setAttribute("enrolledCourses", enrolledCourses);

                int enrolledCoursesCount = enrolledCourses != null ? enrolledCourses.size() : 0;
                int activeCoursesCount = 0;
                int completedCoursesCount = 0;
                int paidEnrollmentsCount = 0;
                int progressSum = 0;
                int progressEntries = 0;

                if (enrolledCourses != null) {
                    for (Enrollment enrollment : enrolledCourses) {
                        String completion = enrollment.getCompletionStatus();
                        String status = enrollment.getStatus();
                        String payment = enrollment.getPaymentStatus();

                        if ("Completed".equalsIgnoreCase(completion) || "Completed".equalsIgnoreCase(status)) {
                            completedCoursesCount++;
                        } else {
                            activeCoursesCount++;
                        }

                        if ("Paid".equalsIgnoreCase(payment)) {
                            paidEnrollmentsCount++;
                        }

                        if (enrollment.getProgress() != null) {
                            int clamped = Math.max(0, Math.min(100, enrollment.getProgress()));
                            progressSum += clamped;
                            progressEntries++;
                        }
                    }
                }

                int overallProgress = progressEntries > 0 ? Math.round((float) progressSum / progressEntries) : 0;
                int certificatesCount = 0;
                try {
                    List<Certificate> issued = certificateDAO.findByUser(user.getUserId());
                    certificatesCount = issued != null ? issued.size() : 0;
                } catch (Exception ignored) {
                    // Keep dashboard available even if certificate read fails.
                }

                request.setAttribute("enrolledCoursesCount", enrolledCoursesCount);
                request.setAttribute("activeCoursesCount", activeCoursesCount);
                request.setAttribute("completedCoursesCount", completedCoursesCount);
                request.setAttribute("paidEnrollmentsCount", paidEnrollmentsCount);
                request.setAttribute("certificatesCount", certificatesCount);
                request.setAttribute("overallProgress", overallProgress);
                request.setAttribute("dashboardDate", LocalDate.now());
                
                // Fetch dynamic study activity data for the chart
                List<Map<String, Object>> activityData = getStudentActivityStats(user.getUserId());
                request.setAttribute("activityData", activityData);

                // Notification bell
                try {
                    int unreadCount = notificationDAO.countUnreadByRecipientUserId(user.getUserId());
                    request.setAttribute("unreadNotificationCount", unreadCount);
                } catch (Exception ignored) { }
                
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Student dashboard data load failed", e);
                // Continue to render page even if data fetch fails
            }
        }
        // Route admins to admin dashboard
        if ("Admin".equals(role)) {
            try {
                Map<String, Object> systemMetrics = new HashMap<>();

                int studentsCount = userDAO.countByRoleAllStatuses("Student");
                int instructorsCount = userDAO.countByRoleAllStatuses("Instructor");
                int adminsCount = userDAO.countByRoleAllStatuses("Admin");
                systemMetrics.put("totalUsers", userDAO.countAll());
                systemMetrics.put("studentsCount", studentsCount);
                systemMetrics.put("instructorsCount", instructorsCount);
                systemMetrics.put("adminsCount", adminsCount);
                request.setAttribute("notificationCount", notificationDAO.countUnreadByRecipientUserId(user.getUserId()));

                int approvedCourses = courseDAO.countByStatus("Approved");
                int pendingCourses = courseDAO.countByStatus("Pending");
                int archivedCourses = courseDAO.countByStatus("Archived");
                systemMetrics.put("activeCourses", approvedCourses + pendingCourses + archivedCourses);
                systemMetrics.put("approvedCourses", approvedCourses);
                systemMetrics.put("pendingCourses", pendingCourses);
                systemMetrics.put("archivedCourses", archivedCourses);

                EnrollmentDAO.EnrollmentPaymentSummary paymentSummary = enrollmentDAO.getEnrollmentPaymentSummary();
                systemMetrics.put("totalEnrollments", paymentSummary.getTotalEnrollments());
                systemMetrics.put("paidEnrollments", paymentSummary.getPaidEnrollments());
                systemMetrics.put("pendingEnrollments", paymentSummary.getPendingEnrollments());
                systemMetrics.put("cancelledEnrollments", paymentSummary.getCancelledEnrollments());
                systemMetrics.put("totalRevenue", paymentSummary.getTotalRevenue());

                LocalDate today = LocalDate.now();
                LocalDate chartStart = today.minusDays(6);
                List<EnrollmentDAO.DailyEnrollmentMetric> dailyMetrics =
                        enrollmentDAO.getDailyEnrollmentMetrics(chartStart, today);
                Map<LocalDate, Integer> registrationsByDate =
                        userDAO.countRegistrationsByDate(chartStart, today);

                List<Map<String, Object>> performanceStats = new ArrayList<>();
                List<Map<String, Object>> platformGrowth = new ArrayList<>();
                for (EnrollmentDAO.DailyEnrollmentMetric metric : dailyMetrics) {
                    LocalDate date = metric.getDate();
                    String dayLabel = date.getDayOfWeek().getDisplayName(
                            java.time.format.TextStyle.SHORT, java.util.Locale.US);

                    Map<String, Object> dayStat = new HashMap<>();
                    dayStat.put("day", dayLabel);
                    dayStat.put("dateLabel", date.toString());
                    dayStat.put("revenue", metric.getRevenue());
                    dayStat.put("enrollments", metric.getEnrollmentCount());
                    performanceStats.add(dayStat);

                    Map<String, Object> dayGrowth = new HashMap<>();
                    dayGrowth.put("date", date.toString());
                    dayGrowth.put("newUsers", registrationsByDate.getOrDefault(date, 0));
                    dayGrowth.put("platformRevenue", metric.getRevenue());
                    platformGrowth.add(dayGrowth);
                }
                request.setAttribute("performanceStats", performanceStats);
                request.setAttribute("platformGrowth", platformGrowth);

                request.setAttribute("systemMetrics", systemMetrics);
                request.setAttribute("adminName", user.getFullName());
                request.setAttribute("recentEnrollments", enrollmentDAO.getRecentEnrollments(5));

            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to load admin dashboard metrics", e);
            }
            
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-dashboard.jsp").forward(request, response);
            return;
        }

        // Route instructors to dedicated dashboard view
        if ("Instructor".equals(role)) {
            try {
                Integer userId = user.getUserId();
                
                // Populate courses created by this instructor
                List<Course> courses = courseDAO.findByInstructor(userId);
                if (courses == null) {
                    courses = new ArrayList<>();
                }
                request.setAttribute("courses", courses);
                request.setAttribute("instructorName", user.getFullName());
                
                // Gather instructor statistics
                Integer totalCourses = courses.size();
                Integer totalStudents = enrollmentDAO.countStudentsByInstructor(userId);
                Integer totalEnrollments = enrollmentDAO.countEnrollmentsByInstructor(userId);
                Integer pendingEnrollments = enrollmentDAO.countPendingEnrollmentsByInstructor(userId);
                Integer activeEnrollments = enrollmentDAO.countActiveEnrollmentsByInstructor(userId);
                int activeCourses = 0;
                int publishedMaterialsCount = 0;
                int pendingGradingCount = 0;
                int missingMaterialsCourseCount = 0;
                int dueSoonAssessmentCount = 0;
                int activeLearnersCount = 0;
                int progressSum = 0;
                int progressCount = 0;

                // Dynamic metric variables for KPI and Donuts
                double instructorRevenue = 0.0;
                int newEnrollments30Days = 0;
                double scoreSum = 0.0;
                int scoreCount = 0;
                int passedSubmissions = 0;
                int failedSubmissions = 0;
                int completedEnrollmentsCount = 0;
                int inProgressEnrollmentsCount = 0;
                int droppedEnrollmentsCount = 0;

                Map<Integer, Integer> courseEnrollmentCountById = new LinkedHashMap<>();
                Map<Integer, Integer> courseMaterialCountById = new LinkedHashMap<>();
                Map<Integer, Integer> courseAssessmentCountById = new LinkedHashMap<>();
                Map<Integer, Integer> pendingSubmissionsByCourseId = new LinkedHashMap<>();
                Map<Integer, String> courseStatusById = new LinkedHashMap<>();

                List<Enrollment> instructorEnrollments = enrollmentDAO.getEnrollmentsByInstructor(userId);
                if (instructorEnrollments == null) {
                    instructorEnrollments = new ArrayList<>();
                }
                Map<Integer, List<Enrollment>> enrollmentsByCourseId = new HashMap<>();
                for (Enrollment enrollment : instructorEnrollments) {
                    if (enrollment == null || enrollment.getCourseId() == null) {
                        continue;
                    }
                    enrollmentsByCourseId
                            .computeIfAbsent(enrollment.getCourseId(), ignored -> new ArrayList<>())
                            .add(enrollment);
                }

                LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);

                for (Course course : courses) {
                    if (course == null || course.getCourseId() == null) {
                        continue;
                    }

                    Integer courseId = course.getCourseId();
                    courseStatusById.put(courseId, course.getStatus());
                    if (Course.STATUS_APPROVED.equalsIgnoreCase(course.getStatus())) {
                        activeCourses++;
                    }

                    List<Enrollment> courseEnrollments = enrollmentsByCourseId.getOrDefault(courseId, new ArrayList<>());
                    courseEnrollmentCountById.put(courseId, courseEnrollments.size());
                    for (Enrollment enrollment : courseEnrollments) {
                        String enrollmentStatus = enrollment.getStatus();
                        if (Enrollment.STATUS_ENROLLED.equalsIgnoreCase(enrollmentStatus)
                                || Enrollment.STATUS_ACTIVE.equalsIgnoreCase(enrollmentStatus)) {
                            activeLearnersCount++;
                        }
                        if (enrollment.getProgress() != null) {
                            int clamped = Math.max(0, Math.min(100, enrollment.getProgress()));
                            progressSum += clamped;
                            progressCount++;
                        }

                        String payStatus = enrollment.getPaymentStatus();
                        if (payStatus != null && (payStatus.equalsIgnoreCase("paid") || payStatus.equalsIgnoreCase("success"))) {
                            if (enrollment.getCoursePrice() != null) {
                                instructorRevenue += enrollment.getCoursePrice();
                            }
                        }
                        if (enrollment.getEnrollmentDate() != null && enrollment.getEnrollmentDate().isAfter(thirtyDaysAgo)) {
                            newEnrollments30Days++;
                        }

                        String compStatus = enrollment.getCompletionStatus();
                        String status = enrollment.getStatus();
                        if ("Completed".equalsIgnoreCase(compStatus)) {
                            completedEnrollmentsCount++;
                        } else if ("Cancelled".equalsIgnoreCase(status)) {
                            droppedEnrollmentsCount++;
                        } else {
                            inProgressEnrollmentsCount++;
                        }
                    }

                    List<Material> courseMaterials = materialDAO.findByCourse(courseId);
                    if (courseMaterials == null) {
                        courseMaterials = new ArrayList<>();
                    }
                    courseMaterialCountById.put(courseId, courseMaterials.size());
                    publishedMaterialsCount += courseMaterials.size();
                    if (courseMaterials.isEmpty()) {
                        missingMaterialsCourseCount++;
                    }

                    List<Assessment> courseAssessments = assessmentDAO.findByCourse(courseId);
                    if (courseAssessments == null) {
                        courseAssessments = new ArrayList<>();
                    }
                    courseAssessmentCountById.put(courseId, courseAssessments.size());

                    int coursePendingSubmissions = 0;
                    for (Assessment assessment : courseAssessments) {
                        if (assessment == null || assessment.getAssessmentId() == null) {
                            continue;
                        }

                        List<AssessmentSubmission> submissions =
                                assessmentSubmissionDAO.findByAssessment(assessment.getAssessmentId());
                        if (submissions == null) {
                            submissions = new ArrayList<>();
                        }
                        coursePendingSubmissions += countPendingGradingFromSubmissions(submissions);

                        double maxMarks = (assessment.getTotalMarks() != null && assessment.getTotalMarks() > 0)
                                ? assessment.getTotalMarks() : 100.0;
                        for (AssessmentSubmission sub : submissions) {
                            if (sub == null) {
                                continue;
                            }
                            if ("Graded".equalsIgnoreCase(sub.getStatus()) && sub.getScore() != null) {
                                double pct = (sub.getScore() / maxMarks) * 100.0;
                                scoreSum += pct;
                                scoreCount++;

                                if (pct >= 50.0) {
                                    passedSubmissions++;
                                } else {
                                    failedSubmissions++;
                                }
                            }
                        }
                    }
                    pendingSubmissionsByCourseId.put(courseId, coursePendingSubmissions);
                    pendingGradingCount += coursePendingSubmissions;
                }

                int averageProgress = progressCount > 0 ? Math.round((float) progressSum / progressCount) : 0;
                int averageAssessmentScore = scoreCount > 0 ? Math.round((float) scoreSum / scoreCount) : 0;

                List<Map<String, Object>> monthlyTrends = new ArrayList<>();
                LocalDate today = LocalDate.now();
                for (int i = 5; i >= 0; i--) {
                    LocalDate targetMonth = today.minusMonths(i);
                    String monthLabel = targetMonth.getMonth().getDisplayName(
                            java.time.format.TextStyle.SHORT, java.util.Locale.US);
                    int year = targetMonth.getYear();
                    String label = monthLabel + " " + year;

                    double monthRevenue = 0.0;
                    int monthEnrollments = 0;

                    for (Enrollment enrollment : instructorEnrollments) {
                        if (enrollment == null || enrollment.getEnrollmentDate() == null) {
                            continue;
                        }
                        LocalDateTime enrollDateTime = enrollment.getEnrollmentDate();
                        if (enrollDateTime.getYear() == year
                                && enrollDateTime.getMonthValue() == targetMonth.getMonthValue()) {
                            monthEnrollments++;
                            String payStatus = enrollment.getPaymentStatus();
                            if (payStatus != null
                                    && (payStatus.equalsIgnoreCase("paid") || payStatus.equalsIgnoreCase("success"))
                                    && enrollment.getCoursePrice() != null) {
                                monthRevenue += enrollment.getCoursePrice();
                            }
                        }
                    }

                    Map<String, Object> trendVal = new HashMap<>();
                    trendVal.put("date", label);
                    trendVal.put("enrollments", monthEnrollments);
                    trendVal.put("revenue", monthRevenue);
                    monthlyTrends.add(trendVal);
                }

                request.setAttribute("totalCourses", totalCourses);
                request.setAttribute("totalStudents", totalStudents);
                request.setAttribute("totalEnrollments", totalEnrollments);
                request.setAttribute("pendingEnrollments", pendingEnrollments);
                request.setAttribute("activeEnrollments", activeEnrollments);
                request.setAttribute("activeCourses", activeCourses);
                request.setAttribute("publishedMaterialsCount", publishedMaterialsCount);
                request.setAttribute("pendingGradingCount", pendingGradingCount);
                request.setAttribute("missingMaterialsCourseCount", missingMaterialsCourseCount);
                request.setAttribute("dueSoonAssessmentCount", dueSoonAssessmentCount);
                request.setAttribute("activeLearnersCount", activeLearnersCount);
                request.setAttribute("averageProgress", averageProgress);
                request.setAttribute("courseEnrollmentCountById", courseEnrollmentCountById);
                request.setAttribute("courseMaterialCountById", courseMaterialCountById);
                request.setAttribute("courseAssessmentCountById", courseAssessmentCountById);
                request.setAttribute("pendingSubmissionsByCourseId", pendingSubmissionsByCourseId);
                request.setAttribute("courseStatusById", courseStatusById);

                // Add the new metrics
                request.setAttribute("totalRevenue", instructorRevenue);
                request.setAttribute("newEnrollments30Days", newEnrollments30Days);
                request.setAttribute("averageAssessmentScore", averageAssessmentScore);
                request.setAttribute("completedEnrollmentsCount", completedEnrollmentsCount);
                request.setAttribute("inProgressEnrollmentsCount", inProgressEnrollmentsCount);
                request.setAttribute("droppedEnrollmentsCount", droppedEnrollmentsCount);
                request.setAttribute("passedSubmissions", passedSubmissions);
                request.setAttribute("failedSubmissions", failedSubmissions);
                request.setAttribute("monthlyTrends", monthlyTrends);

                // Notification bell for instructor
                try {
                    int unreadCount = notificationDAO.countUnreadByRecipientUserId(userId);
                    request.setAttribute("unreadNotificationCount", unreadCount);
                } catch (Exception ignored) { }
            } catch (Exception e) {
                // Log and continue; view will render empty state
                LOGGER.log(Level.WARNING, "Failed to load instructor dashboard", e);
            }
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-dashboard.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private int countPendingGradingFromSubmissions(List<AssessmentSubmission> submissions) {
        if (submissions == null || submissions.isEmpty()) {
            return 0;
        }

        int pendingCount = 0;
        for (AssessmentSubmission submission : submissions) {
            if (submission == null) {
                continue;
            }
            if (submission.getScore() == null
                    && (submission.getStatus() == null || !"TimedOut".equalsIgnoreCase(submission.getStatus()))) {
                pendingCount++;
            }
        }
        return pendingCount;
    }

    private List<Map<String, Object>> getStudentActivityStats(int userId) {
        List<Map<String, Object>> activityStats = new ArrayList<>();
        LocalDate today = LocalDate.now();
        
        // Initialize map for the last 7 days with 0 minutes (Mon-Sun in chronological order)
        Map<LocalDate, Integer> dailyMinutes = new LinkedHashMap<>();
        for (int i = 6; i >= 0; i--) {
            dailyMinutes.put(today.minusDays(i), 0);
        }
        
        String materialSql = "SELECT DATE(ViewedAt) as view_date, COUNT(*) as count " +
                             "FROM MaterialProgress " +
                             "WHERE UserID = ? AND ViewedAt >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                             "GROUP BY DATE(ViewedAt)";
                             
        String assessmentSql = "SELECT DATE(SubmitDate) as submit_date, StartedAt, EndedAt " +
                               "FROM AssessmentSubmission " +
                               "WHERE UserID = ? AND SubmitDate >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)";
                               
        try (Connection conn = DBConnection.getConnection()) {
            // Fetch material progress activity (15 mins per viewed material)
            try (PreparedStatement ps = conn.prepareStatement(materialSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        java.sql.Date sqlDate = rs.getDate("view_date");
                        if (sqlDate != null) {
                            LocalDate date = sqlDate.toLocalDate();
                            int count = rs.getInt("count");
                            dailyMinutes.put(date, dailyMinutes.getOrDefault(date, 0) + (count * 15));
                        }
                    }
                }
            }
            
            // Fetch assessment submission activity
            try (PreparedStatement ps = conn.prepareStatement(assessmentSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        java.sql.Date sqlDate = rs.getDate("submit_date");
                        if (sqlDate != null) {
                            LocalDate date = sqlDate.toLocalDate();
                            java.sql.Timestamp started = rs.getTimestamp("StartedAt");
                            java.sql.Timestamp ended = rs.getTimestamp("EndedAt");
                            
                            int duration = 30; // default 30 minutes
                            if (started != null && ended != null) {
                                long diffMs = ended.getTime() - started.getTime();
                                int diffMins = (int) (diffMs / (1000 * 60));
                                if (diffMins > 0) {
                                    duration = Math.min(diffMins, 180); // clamp to max 3 hours
                                }
                            }
                            dailyMinutes.put(date, dailyMinutes.getOrDefault(date, 0) + duration);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to fetch student activity stats", e);
        }
        
        // Convert to the required map list format for Recharts
        for (Map.Entry<LocalDate, Integer> entry : dailyMinutes.entrySet()) {
            LocalDate date = entry.getKey();
            String dayLabel = date.getDayOfWeek().getDisplayName(java.time.format.TextStyle.SHORT, java.util.Locale.US);
            
            Map<String, Object> dayStat = new HashMap<>();
            dayStat.put("day", dayLabel);
            dayStat.put("dateLabel", date.toString());
            dayStat.put("Minutes", entry.getValue());
            activityStats.add(dayStat);
        }
        
        return activityStats;
    }
}

