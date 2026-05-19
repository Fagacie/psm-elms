package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

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
    private StudentAccessService studentAccessService;

    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        studentAccessService = new StudentAccessService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (!studentAccessService.isStudentSession(session) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String retryPaymentUrl = request.getContextPath() + "/student/my-enrollments";
        String detailsUrl = request.getContextPath() + "/student/my-enrollments";
        Integer safeEnrollmentId = null;

        try {
            String enrollmentIdParam = request.getParameter("enrollmentId");
            if (enrollmentIdParam != null && !enrollmentIdParam.trim().isEmpty()) {
                Integer enrollmentId = parseEnrollmentId(enrollmentIdParam);
                if (enrollmentId == null) {
                    throw new IllegalArgumentException("Invalid enrollmentId");
                }
                Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
                if (studentAccessService.belongsToStudent(enrollment, userId)) {
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

}
