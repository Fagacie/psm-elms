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
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Shows enrollment summary before payment begins.
 */
public class EnrollmentSummaryServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(EnrollmentSummaryServlet.class.getName());

    private CourseDAO courseDAO;
    private EnrollmentDAO enrollmentDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() {
        courseDAO = new CourseDAOImpl();
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!"Student".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        try {
            String courseIdParam = request.getParameter("courseId");
            Integer courseId = Integer.parseInt(courseIdParam);
            Course course = courseDAO.findById(courseId);
            if (course == null) {
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
            request.setAttribute("course", course);
            request.getRequestDispatcher("/WEB-INF/views/student/enrollment-summary.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "EnrollmentSummaryServlet invalid courseId", e);
            response.sendRedirect(request.getContextPath() + "/student/courses?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "EnrollmentSummaryServlet failed", e);
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
