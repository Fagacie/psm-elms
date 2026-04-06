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
 * Servlet to display payment failed page.
 */
public class PaymentFailedServlet extends HttpServlet {

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

        String role = (String) session.getAttribute("role");
        if (role == null) {
            role = (String) session.getAttribute("userRole");
        }
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String retryPaymentUrl = request.getContextPath() + "/student/my-enrollments";
        String detailsUrl = request.getContextPath() + "/student/my-enrollments";
        Integer safeEnrollmentId = null;

        try {
            String enrollmentIdParam = request.getParameter("enrollmentId");
            if (enrollmentIdParam != null && !enrollmentIdParam.trim().isEmpty()) {
                Integer enrollmentId = Integer.parseInt(enrollmentIdParam.trim());
                Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
                if (enrollment != null && enrollment.getUserId() != null && enrollment.getUserId().equals(userId)) {
                    safeEnrollmentId = enrollmentId;
                    retryPaymentUrl = request.getContextPath() + "/student/payment?enrollmentId=" + enrollmentId;
                    detailsUrl = request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId;
                }
            }
        } catch (Exception ignored) {
            safeEnrollmentId = null;
        }

        request.setAttribute("safeEnrollmentId", safeEnrollmentId);
        request.setAttribute("retryPaymentUrl", retryPaymentUrl);
        request.setAttribute("detailsUrl", detailsUrl);
        
        request.getRequestDispatcher("/WEB-INF/views/student/payment-failed.jsp").forward(request, response);
    }
}
