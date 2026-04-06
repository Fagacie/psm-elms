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

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Shows enrollment summary before payment begins.
 */
public class EnrollmentSummaryServlet extends HttpServlet {

    private CourseDAO courseDAO;
    private EnrollmentDAO enrollmentDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() {
        System.out.println("EnrollmentSummaryServlet.init: initializing");
        courseDAO = new CourseDAOImpl();
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("EnrollmentSummaryServlet.doGet: start");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("EnrollmentSummaryServlet: no session or userId; redirecting to /login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null) {
            role = (String) session.getAttribute("userRole");
        }
        if (!"Student".equals(role)) {
            System.out.println("EnrollmentSummaryServlet: role=" + role + " redirecting to /dashboard");
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            String courseIdParam = request.getParameter("courseId");
            System.out.println("EnrollmentSummaryServlet: userId=" + userId + ", courseIdParam=" + courseIdParam);
            Integer courseId = Integer.parseInt(courseIdParam);
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                System.out.println("EnrollmentSummaryServlet: course not found id=" + courseId);
                response.sendRedirect(request.getContextPath() + "/student/courses?error=notfound");
                return;
            }
            Enrollment latestEnrollment = enrollmentDAO.findLatestEnrollmentByUserAndCourse(userId, courseId);
            if (latestEnrollment != null) {
                Payment payment = paymentDAO.getPaymentByEnrollmentId(latestEnrollment.getEnrollmentId());
                String paymentStatus = payment != null ? payment.getStatus() : latestEnrollment.getPaymentStatus();
                if (isPaid(paymentStatus)) {
                    response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=already");
                } else {
                    response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + latestEnrollment.getEnrollmentId());
                }
                return;
            }
            System.out.println("EnrollmentSummaryServlet: forwarding to enrollment-summary.jsp");
            request.setAttribute("course", course);
            request.getRequestDispatcher("/WEB-INF/views/student/enrollment-summary.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            System.err.println("EnrollmentSummaryServlet: invalid courseId: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/courses?error=invalid");
        } catch (Exception e) {
            System.err.println("EnrollmentSummaryServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/courses?error=exception");
        }
    }

    private boolean isPaid(String status) {
        if (status == null) {
            return false;
        }
        String normalized = status.trim();
        return "Paid".equalsIgnoreCase(normalized)
                || "Completed".equalsIgnoreCase(normalized)
                || "Success".equalsIgnoreCase(normalized);
    }
}
