package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.PaystackService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

/**
 * Servlet to process course enrollment (creates Pending enrollment and initializes Paystack transaction).
 */
public class ProcessEnrollmentServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private PaymentDAO paymentDAO;
    private PaystackService paystackService;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        paystackService = new PaystackService();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (role == null) {
            role = (String) session.getAttribute("userRole");
        }
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            String userEmail = (String) session.getAttribute("email");
            Integer courseId = Integer.parseInt(request.getParameter("courseId"));
            
            System.out.println("=== ProcessEnrollmentServlet START ===");
            System.out.println("User ID: " + userId);
            System.out.println("User Email: " + userEmail);
            System.out.println("Course ID: " + courseId);
            System.out.println("Role: " + role);
            
            if (userEmail == null || userEmail.isEmpty()) {
                System.err.println("ERROR: User email is null or empty!");
                request.setAttribute("errorMessage", "Session error: Email not found. Please login again.");
                request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
                return;
            }
            
            // Check if already enrolled
            if (enrollmentDAO.checkExistingEnrollment(userId, courseId)) {
                System.out.println("ProcessEnrollmentServlet: User already enrolled");
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=already");
                return;
            }
            
            // Get course details
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                System.err.println("ERROR: Course not found with ID: " + courseId);
                response.sendRedirect(request.getContextPath() + "/student/courses?error=notfound");
                return;
            }
            
            System.out.println("Course found: " + course.getCourseName());
            System.out.println("Course fee: " + course.getCourseFee());
            
            // Create enrollment with Enrolled status (DB doesn't support Pending in Status enum)
            // Payment status tracked separately in Payment table
            Enrollment enrollment = new Enrollment(userId, courseId, "Enrolled", "Pending");
            enrollment = enrollmentDAO.createEnrollment(enrollment);

            if (enrollment != null) {
                System.out.println("ProcessEnrollmentServlet: Enrollment created with ID " + enrollment.getEnrollmentId());
                // Redirect student to payment page for this enrollment
                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + enrollment.getEnrollmentId());
            } else {
                System.err.println("ProcessEnrollmentServlet: Failed to create enrollment");
                response.sendRedirect(request.getContextPath() + "/student/courses?error=failed");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("ProcessEnrollmentServlet: Invalid course ID");
            response.sendRedirect(request.getContextPath() + "/student/courses?error=invalid");
        } catch (Exception e) {
            System.err.println("ProcessEnrollmentServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/courses?error=exception");
        }
    }
}
