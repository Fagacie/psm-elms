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
import java.util.List;

/**
 * Servlet to list all enrollments (Admin).
 */
public class AdminEnrollmentListServlet extends HttpServlet {
    
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
            List<Enrollment> enrollments = enrollmentDAO.getAllEnrollments();
            String successCode = request.getParameter("success");
            String errorCode = request.getParameter("error");

            for (Enrollment e : enrollments) {
                enrichEnrollmentPayment(e);
            }
            request.setAttribute("enrollments", enrollments);
            request.setAttribute("successMessage", resolveSuccessMessage(successCode));
            request.setAttribute("errorMessage", resolveErrorMessage(errorCode));
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-enrollment-list.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("AdminEnrollmentListServlet: Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("enrollments", java.util.Collections.emptyList());
            request.setAttribute("errorMessage", "Enrollments could not be loaded right now. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-enrollment-list.jsp").forward(request, response);
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

    private String resolveSuccessMessage(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        if ("updated".equalsIgnoreCase(code)) {
            return "Enrollment details were refreshed successfully.";
        }
        return null;
    }

    private String resolveErrorMessage(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        if ("invalid".equalsIgnoreCase(code)) {
            return "Choose a valid enrollment record to continue.";
        }
        if ("notfound".equalsIgnoreCase(code)) {
            return "The enrollment record you requested could not be found.";
        }
        if ("exception".equalsIgnoreCase(code)) {
            return "An enrollment error occurred. Please try again.";
        }
        return "An enrollment error occurred. Please try again.";
    }

}
