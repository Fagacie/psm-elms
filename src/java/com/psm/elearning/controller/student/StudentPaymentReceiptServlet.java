package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class StudentPaymentReceiptServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final StudentAccessService studentAccessService = new StudentAccessService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (!studentAccessService.isStudentSession(session) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Payment payment = null;
        Integer paymentId = parseInt(request.getParameter("paymentId"));
        Integer enrollmentId = parseInt(request.getParameter("enrollmentId"));

        if (paymentId != null) {
            payment = paymentDAO.getPaymentById(paymentId);
        }
        if (payment == null && enrollmentId != null) {
            payment = paymentDAO.getPaymentByEnrollmentId(enrollmentId);
        }
        if (payment == null) {
            response.sendRedirect(request.getContextPath() + "/student/payments?error=notfound");
            return;
        }

        Enrollment enrollment = enrollmentDAO.getEnrollment(payment.getEnrollmentId());
        if (!studentAccessService.belongsToStudent(enrollment, userId)) {
            response.sendRedirect(request.getContextPath() + "/student/payments?error=unauthorized");
            return;
        }

        studentAccessService.syncPaymentStatus(enrollment);

        response.sendRedirect(request.getContextPath() + "/student/payments?receiptPaymentId=" + payment.getPaymentId());
    }

    private Integer parseInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

}