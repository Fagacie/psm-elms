package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.Enrollment;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet to display payment page for an enrollment.
 */
public class PaymentPageServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentPageServlet.class.getName());
    
    private EnrollmentDAO enrollmentDAO;
    private PaymentDAO paymentDAO;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
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
            Integer enrollmentId = parseEnrollmentId(request.getParameter("enrollmentId"));
            if (enrollmentId == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
                return;
            }
            
            // Get enrollment with course details
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            
            if (enrollment == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }
            
            // Verify ownership
            if (!enrollment.getUserId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }

            if (enrollment.getCoursePrice() == null || enrollment.getCoursePrice() <= 0) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&message=freeenrolled");
                return;
            }
            
            // Derive payment status from Payment table (no payment columns on Enrollment table)
            Payment latestPayment = paymentDAO.getPaymentByEnrollmentId(enrollmentId);
            if (latestPayment != null) {
                enrollment.setPaymentStatus(latestPayment.getStatus());
                String latestReference = latestPayment.getPaystackReference();
                if (latestReference == null || latestReference.trim().isEmpty()) {
                    latestReference = latestPayment.getPaymentRef();
                }
                enrollment.setPaymentRef(latestReference);
                // If already paid redirect back
                if (isPaid(latestPayment.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/student/my-enrollments?message=alreadypaid");
                    return;
                }
            } else {
                enrollment.setPaymentStatus("Pending");
            }

            request.setAttribute("paymentError", request.getParameter("error"));
            
            request.setAttribute("enrollment", enrollment);
            request.getRequestDispatcher("/WEB-INF/views/student/payment.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "PaymentPageServlet: Error rendering payment page", e);
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=exception");
        }
    }

    private Integer parseEnrollmentId(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
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
