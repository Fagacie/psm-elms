package com.psm.elearning.controller;

import com.psm.elearning.dao.*;
import com.psm.elearning.model.*;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DashboardServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DashboardServlet.class.getName());

    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private UserDAO userDAO;
    private PaymentDAO paymentDAO;
    private CertificateDAO certificateDAO;
    private InstructorApplicationDAO applicationDAO;
    private NotificationDAO notificationDAO;
    private EnrollmentStateSyncService enrollmentStateSyncService;

    @Override
    public void init() throws ServletException {
        super.init();
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        userDAO = new UserDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        certificateDAO = new CertificateDAOImpl();
        applicationDAO = new InstructorApplicationDAOImpl();
        notificationDAO = new NotificationDAOImpl();
        enrollmentStateSyncService = new EnrollmentStateSyncService();
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
                        enrollmentStateSyncService.syncEnrollmentState(enrollment);
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
                
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Student dashboard data load failed", e);
                // Continue to render page even if data fetch fails
            }
        }
        // Route admins to admin dashboard
        if ("Admin".equals(role)) {
            try {
                // Fetch all system metrics for the admin dashboard
                Map<String, Object> systemMetrics = new HashMap<>();
                
                // Get all users
                List<User> allUsers = userDAO.findAll();
                systemMetrics.put("totalUsers", allUsers != null ? allUsers.size() : 0);
                
                // Count users by role
                int studentsCount = 0;
                int instructorsCount = 0;
                int adminsCount = 0;
                if (allUsers != null) {
                    for (User u : allUsers) {
                        if ("Student".equals(u.getRole())) studentsCount++;
                        else if ("Instructor".equals(u.getRole())) instructorsCount++;
                        else if ("Admin".equals(u.getRole())) adminsCount++;
                    }
                }
                systemMetrics.put("studentsCount", studentsCount);
                systemMetrics.put("instructorsCount", instructorsCount);
                systemMetrics.put("adminsCount", adminsCount);
                systemMetrics.put("pendingApplications", applicationDAO.countByStatus(InstructorApplication.STATUS_PENDING));
                request.setAttribute("notificationCount", notificationDAO.countUnreadByRecipientUserId(user.getUserId()));
                
                // Get all courses and count by status
                List<Course> allCourses = courseDAO.findAll();
                systemMetrics.put("activeCourses", allCourses != null ? allCourses.size() : 0);
                
                int approvedCourses = 0;
                int pendingCourses = 0;
                int archivedCourses = 0;
                if (allCourses != null) {
                    for (Course c : allCourses) {
                        if ("Approved".equals(c.getStatus())) approvedCourses++;
                        else if ("Pending".equals(c.getStatus())) pendingCourses++;
                        else if ("Archived".equals(c.getStatus())) archivedCourses++;
                    }
                }
                systemMetrics.put("approvedCourses", approvedCourses);
                systemMetrics.put("pendingCourses", pendingCourses);
                systemMetrics.put("archivedCourses", archivedCourses);
                
                // Get all enrollments and count by payment status
                List<Enrollment> allEnrollments = enrollmentDAO.getAllEnrollments();
                systemMetrics.put("totalEnrollments", allEnrollments != null ? allEnrollments.size() : 0);
                
                int paidEnrollments = 0;
                int pendingEnrollments = 0;
                int cancelledEnrollments = 0;
                double totalRevenue = 0;
                if (allEnrollments != null) {
                    for (Enrollment e : allEnrollments) {
                        String paymentStatus = e.getPaymentStatus();
                        if (paymentStatus != null) {
                        if (paymentStatus.equalsIgnoreCase("paid") || paymentStatus.equalsIgnoreCase("success")) {
                                paidEnrollments++;
                                if (e.getCoursePrice() != null) {
                                    totalRevenue += e.getCoursePrice();
                                }
                            } else if (paymentStatus.equalsIgnoreCase("pending")) {
                                pendingEnrollments++;
                            } else if (paymentStatus.equalsIgnoreCase("failed") || paymentStatus.equalsIgnoreCase("cancelled")) {
                                cancelledEnrollments++;
                            }
                        }
                    }
                }
                systemMetrics.put("paidEnrollments", paidEnrollments);
                systemMetrics.put("pendingEnrollments", pendingEnrollments);
                systemMetrics.put("cancelledEnrollments", cancelledEnrollments);
                systemMetrics.put("totalRevenue", totalRevenue);
                
                request.setAttribute("systemMetrics", systemMetrics);
                request.setAttribute("adminName", user.getFullName());

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
                List courses = courseDAO.findByInstructor(userId);
                request.setAttribute("courses", courses);
                
                // Gather instructor statistics
                Integer totalCourses = courses != null ? courses.size() : 0;
                Integer totalStudents = enrollmentDAO.countStudentsByInstructor(userId);
                Integer totalEnrollments = enrollmentDAO.countEnrollmentsByInstructor(userId);
                Integer pendingEnrollments = enrollmentDAO.countPendingEnrollmentsByInstructor(userId);
                Integer activeEnrollments = enrollmentDAO.countActiveEnrollmentsByInstructor(userId);

                request.setAttribute("totalCourses", totalCourses);
                request.setAttribute("totalStudents", totalStudents);
                request.setAttribute("totalEnrollments", totalEnrollments);
                request.setAttribute("pendingEnrollments", pendingEnrollments);
                request.setAttribute("activeEnrollments", activeEnrollments);
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
}
