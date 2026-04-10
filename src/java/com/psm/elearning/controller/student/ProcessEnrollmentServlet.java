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
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Servlet to process course enrollment and route the student to payment (or auto-complete free enrollments).
 */
public class ProcessEnrollmentServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private PaymentDAO paymentDAO;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        paymentDAO = new PaymentDAOImpl();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer userId = resolveUserId(session);
        if (session == null || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = resolveRole(session);
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            String userEmail = (String) session.getAttribute("email");
            Integer courseId = parseCourseId(request.getParameter("courseId"));
            if (courseId == null) {
                response.sendRedirect(request.getContextPath() + "/student/courses?error=invalid");
                return;
            }

            if (userEmail == null || userEmail.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/login?error=session");
                return;
            }
            
            Enrollment existingEnrollment = enrollmentDAO.findLatestEnrollmentByUserAndCourse(userId, courseId);
            if (existingEnrollment != null) {
                Payment existingPayment = paymentDAO.getPaymentByEnrollmentId(existingEnrollment.getEnrollmentId());
                String paymentStatus = existingPayment != null ? existingPayment.getStatus() : existingEnrollment.getPaymentStatus();
                if (isPaidStatus(paymentStatus)) {
                    response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=already");
                } else {
                    response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + existingEnrollment.getEnrollmentId());
                }
                return;
            }
            
            // Get course details
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/student/courses?error=notfound");
                return;
            }
            
            // Create enrollment first; payment gating is resolved below.
            Enrollment enrollment = new Enrollment(userId, courseId, "Enrolled", "Pending");
            enrollment = enrollmentDAO.createEnrollment(enrollment);

            if (enrollment != null) {
                boolean freeCourse = isFreeCourse(course.getCourseFee());
                if (freeCourse) {
                    String freeReference = "FREE-" + enrollment.getEnrollmentId() + "-" + UUID.randomUUID().toString().substring(0, 8);
                    enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Paid", freeReference);
                    enrollmentDAO.updateStatus(enrollment.getEnrollmentId(), "Enrolled");

                    Payment freePayment = new Payment();
                    freePayment.setEnrollmentId(enrollment.getEnrollmentId());
                    freePayment.setAmount(0.0);
                    freePayment.setMethod("Free");
                    freePayment.setStatus("Paid");
                    freePayment.setPaymentRef(freeReference);
                    freePayment.setPaystackReference(freeReference);
                    freePayment.setPaystackStatus("success");
                    paymentDAO.createPayment(freePayment);

                    response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&message=freeenrolled");
                    return;
                }

                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + enrollment.getEnrollmentId());
            } else {
                response.sendRedirect(request.getContextPath() + "/student/courses?error=failed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/courses?error=invalid");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/student/courses?error=exception");
        }
    }

    private Integer resolveUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object raw = session.getAttribute("userId");
        if (raw instanceof Integer) {
            Integer parsed = (Integer) raw;
            return parsed > 0 ? parsed : null;
        }
        if (raw instanceof String) {
            try {
                int parsed = Integer.parseInt(((String) raw).trim());
                return parsed > 0 ? parsed : null;
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private String resolveRole(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object role = session.getAttribute("role");
        if (!(role instanceof String) || ((String) role).trim().isEmpty()) {
            role = session.getAttribute("userRole");
        }
        if (!(role instanceof String)) {
            return null;
        }
        String normalized = ((String) role).trim();
        if ("Student".equalsIgnoreCase(normalized)) {
            return "Student";
        }
        if ("Admin".equalsIgnoreCase(normalized)) {
            return "Admin";
        }
        if ("Instructor".equalsIgnoreCase(normalized)) {
            return "Instructor";
        }
        return null;
    }

    private Integer parseCourseId(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private boolean isFreeCourse(BigDecimal fee) {
        return fee == null || fee.compareTo(BigDecimal.ZERO) <= 0;
    }

    private boolean isPaidStatus(String status) {
        if (status == null) {
            return false;
        }
        String normalized = status.trim();
        return "Paid".equalsIgnoreCase(normalized)
                || "Completed".equalsIgnoreCase(normalized)
                || "Success".equalsIgnoreCase(normalized);
    }
}
