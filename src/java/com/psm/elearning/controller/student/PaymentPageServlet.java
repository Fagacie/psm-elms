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

/**
 * Servlet to display payment page for an enrollment.
 */
public class PaymentPageServlet extends HttpServlet {
    
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
            Integer enrollmentId = Integer.parseInt(request.getParameter("enrollmentId"));
            
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

            if (enrollment.getCoursePrice() != null && enrollment.getCoursePrice() <= 0) {
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
            System.err.println("PaymentPageServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=exception");
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
