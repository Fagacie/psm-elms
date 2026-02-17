package com.psm.elearning.controller;

import com.psm.elearning.dao.*;
import com.psm.elearning.model.*;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;

public class DashboardServlet extends HttpServlet {

    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private UserDAO userDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        userDAO = new UserDAOImpl();
        paymentDAO = new PaymentDAOImpl();
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
        
        String role = (String) session.getAttribute("userRole");

        // Fetch dashboard data for students
        if ("Student".equals(role)) {
            try {
                // Get enrolled courses
                List<Enrollment> enrolledCourses = enrollmentDAO.getEnrollmentsByStudent(user.getUserId());
                request.setAttribute("enrolledCourses", enrolledCourses);
                request.setAttribute("enrolledCoursesCount", enrolledCourses != null ? enrolledCourses.size() : 0);
                
                // TODO: Add logic for pending assignments, upcoming quizzes, and announcements
                // For now, set placeholders
                request.setAttribute("pendingAssignmentsCount", 0);
                request.setAttribute("upcomingQuizzesCount", 0);
                request.setAttribute("overallProgress", 0);
                
            } catch (Exception e) {
                e.printStackTrace();
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
                
                System.out.println("[DEBUG] Admin Dashboard Metrics: " + systemMetrics);
                
            } catch (Exception e) {
                System.err.println("[ERROR] Failed to load admin dashboard metrics: " + e.getMessage());
                e.printStackTrace();
            }
            
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-dashboard.jsp").forward(request, response);
            return;
        }

        // Route instructors to dedicated dashboard view
        if ("Instructor".equals(role)) {
            try {
                Integer userId = user.getUserId();
                System.out.println("[DEBUG] Instructor Dashboard - UserID: " + userId);
                System.out.println("[DEBUG] Instructor Dashboard - User: " + user.getFullName());
                
                // Populate courses created by this instructor
                List courses = courseDAO.findByInstructor(userId);
                System.out.println("[DEBUG] Retrieved " + (courses != null ? courses.size() : 0) + " courses for instructor");
                request.setAttribute("courses", courses);
                
                // Gather instructor statistics
                Integer totalCourses = courses != null ? courses.size() : 0;
                Integer totalStudents = enrollmentDAO.countStudentsByInstructor(userId);
                Integer totalEnrollments = enrollmentDAO.countEnrollmentsByInstructor(userId);
                Integer pendingEnrollments = enrollmentDAO.countPendingEnrollmentsByInstructor(userId);
                Integer activeEnrollments = enrollmentDAO.countActiveEnrollmentsByInstructor(userId);
                
                System.out.println("[DEBUG] Instructor Stats - Courses: " + totalCourses + ", Students: " + totalStudents + 
                                   ", Total Enrollments: " + totalEnrollments + ", Pending: " + pendingEnrollments);
                
                request.setAttribute("totalCourses", totalCourses);
                request.setAttribute("totalStudents", totalStudents);
                request.setAttribute("totalEnrollments", totalEnrollments);
                request.setAttribute("pendingEnrollments", pendingEnrollments);
                request.setAttribute("activeEnrollments", activeEnrollments);
            } catch (Exception e) {
                // Log and continue; view will render empty state
                System.err.println("[ERROR] Failed to load instructor dashboard: " + e.getMessage());
                e.printStackTrace();
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
