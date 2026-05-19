package com.psm.elearning.controller.student;

import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StudentPaymentHistoryServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StudentPaymentHistoryServlet.class.getName());

    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
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

        try {
            List<Payment> allPayments = paymentDAO.getPaymentsByStudentId(userId);
            if (allPayments == null) {
                allPayments = new ArrayList<>();
            }

            String statusFilter = normalizeStatus(request.getParameter("status"));
            List<Payment> payments = new ArrayList<>();
            double totalPaidAmount = 0.0;
            int paidCount = 0;
            int pendingCount = 0;
            int failedCount = 0;

            for (Payment payment : allPayments) {
                if (statusFilter == null || statusFilter.equalsIgnoreCase(payment.getStatus())) {
                    payments.add(payment);
                }

                if (studentAccessService.isPaymentComplete(payment.getStatus())) {
                    paidCount++;
                    if (payment.getAmount() != null) {
                        totalPaidAmount += payment.getAmount();
                    }
                } else if ("Failed".equalsIgnoreCase(payment.getStatus()) || "Abandoned".equalsIgnoreCase(payment.getStatus())) {
                    failedCount++;
                } else {
                    pendingCount++;
                }
            }

            request.setAttribute("payments", payments);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("allPaymentCount", allPayments.size());
            request.setAttribute("paidCount", paidCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("failedCount", failedCount);
            request.setAttribute("totalPaidAmount", totalPaidAmount);
            request.getRequestDispatcher("/WEB-INF/views/student/payments.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "StudentPaymentHistoryServlet failed to load payments", e);
            response.sendRedirect(request.getContextPath() + "/dashboard?error=exception");
        }
    }

    private String normalizeStatus(String rawStatus) {
        if (rawStatus == null) {
            return null;
        }
        String value = rawStatus.trim();
        if (value.isEmpty() || "all".equalsIgnoreCase(value)) {
            return null;
        }
        if ("paid".equalsIgnoreCase(value) || "success".equalsIgnoreCase(value)) {
            return "Paid";
        }
        if ("pending".equalsIgnoreCase(value) || "processing".equalsIgnoreCase(value)) {
            return "Pending";
        }
        if ("failed".equalsIgnoreCase(value)) {
            return "Failed";
        }
        if ("abandoned".equalsIgnoreCase(value)) {
            return "Abandoned";
        }
        return value.substring(0, 1).toUpperCase(Locale.ENGLISH) + value.substring(1).toLowerCase(Locale.ENGLISH);
    }
}