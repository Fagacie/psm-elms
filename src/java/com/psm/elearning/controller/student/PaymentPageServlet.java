package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

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
    private StudentAccessService studentAccessService;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
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
            if (!studentAccessService.belongsToStudent(enrollment, userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }

            if (studentAccessService.isFreeEnrollment(enrollment)) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&message=freeenrolled");
                return;
            }
            
            Payment latestPayment = paymentDAO.getPaymentByEnrollmentId(enrollmentId);
            if (latestPayment != null) {
                studentAccessService.syncPaymentStatus(enrollment);
                if (studentAccessService.isPaymentComplete(latestPayment.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/student/my-enrollments?message=alreadypaid");
                    return;
                }
            }
            if (enrollment.getPaymentStatus() == null || enrollment.getPaymentStatus().trim().isEmpty()) {
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

}
