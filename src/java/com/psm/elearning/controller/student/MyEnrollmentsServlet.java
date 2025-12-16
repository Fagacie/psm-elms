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
import java.util.List;

/**
 * Servlet to display student's enrollments.
 */
public class MyEnrollmentsServlet extends HttpServlet {
    
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
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            
            // Get all enrollments for this student
            List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
            // Enrich each enrollment with latest payment status/reference
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
            request.getRequestDispatcher("/WEB-INF/views/student/my-enrollments.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("MyEnrollmentsServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard?error=exception");
        }
    }
}
