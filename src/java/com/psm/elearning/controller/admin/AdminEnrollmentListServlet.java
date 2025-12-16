package com.psm.elearning.controller.admin;

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
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (!"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            List<Enrollment> enrollments = enrollmentDAO.getAllEnrollments();
            // Enrich with payment data
            for (Enrollment e : enrollments) {
                Payment p = paymentDAO.getPaymentByEnrollmentId(e.getEnrollmentId());
                if (p != null) {
                    e.setPaymentStatus(p.getStatus());
                    e.setPaymentRef(p.getPaystackReference());
                } else {
                    e.setPaymentStatus("Pending");
                }
            }
            request.setAttribute("enrollments", enrollments);
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-enrollment-list.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("AdminEnrollmentListServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard?error=exception");
        }
    }
}
