package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet to view enrollment details (Admin).
 */
public class AdminEnrollmentDetailsServlet extends HttpServlet {
    
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
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = SessionUtil.resolveRole(session);
        if (!"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer enrollmentId = Integer.parseInt(request.getParameter("id"));
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            
            if (enrollment == null) {
                response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=notfound");
                return;
            }

            enrichEnrollmentPayment(enrollment);
            
            request.setAttribute("enrollment", enrollment);
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-enrollment-details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=invalid");
        } catch (Exception e) {
            System.err.println("AdminEnrollmentDetailsServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=exception");
        }
    }

    private void enrichEnrollmentPayment(Enrollment enrollment) {
        Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
        if (payment == null) {
            enrollment.setPaymentStatus("Pending");
            return;
        }

        enrollment.setPaymentStatus(payment.getStatus());
        enrollment.setPaymentRef(firstNonBlank(payment.getPaymentRef(), payment.getPaystackReference()));
    }

    private String firstNonBlank(String primary, String fallback) {
        if (primary != null && !primary.trim().isEmpty()) {
            return primary.trim();
        }
        if (fallback != null && !fallback.trim().isEmpty()) {
            return fallback.trim();
        }
        return null;
    }

}
