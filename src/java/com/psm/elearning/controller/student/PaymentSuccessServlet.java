package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.model.Enrollment;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet to display payment success page.
 */
public class PaymentSuccessServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            Integer enrollmentId = Integer.parseInt(request.getParameter("enrollmentId"));
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            
            request.setAttribute("enrollment", enrollment);
            request.getRequestDispatcher("/WEB-INF/views/student/payment-success.jsp").forward(request, response);
            
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments");
        }
    }
}
