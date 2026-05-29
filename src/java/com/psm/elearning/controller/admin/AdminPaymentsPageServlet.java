package com.psm.elearning.controller.admin;

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

public class AdminPaymentsPageServlet extends HttpServlet {
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
    private final com.psm.elearning.dao.EnrollmentDAO enrollmentDAO = new com.psm.elearning.dao.EnrollmentDAOImpl();
    private final com.psm.elearning.service.PaystackService paystackService = new com.psm.elearning.service.PaystackService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        String role = SessionUtil.resolveRole(session);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!"Admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            verifyPayment(req, resp);
            return;
        }

        String status = normalizeStatusFilter(req.getParameter("status"));
        int page = parseInt(req.getParameter("page"), 1);
        int pageSize = parseInt(req.getParameter("pageSize"), 20);

        List<Payment> payments = paymentDAO.listPayments(status, page, pageSize);
        req.setAttribute("payments", payments);
        req.setAttribute("status", status);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("successMessage", resolveSuccessMessage(req.getParameter("success")));
        req.setAttribute("errorMessage", resolveErrorMessage(req.getParameter("error")));
        req.getRequestDispatcher("/WEB-INF/views/admin/payments.jsp").forward(req, resp);
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private String normalizeStatusFilter(String rawStatus) {
        if (rawStatus == null) {
            return null;
        }

        String value = rawStatus.trim();
        if (value.isEmpty()) {
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
        return value;
    }

    private String resolveSuccessMessage(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        if ("updated".equalsIgnoreCase(code)) {
            return "Payment record updated successfully.";
        }
        return null;
    }

    private String resolveErrorMessage(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        if ("invalid".equalsIgnoreCase(code)) {
            return "Choose a valid payment record to continue.";
        }
        if ("notfound".equalsIgnoreCase(code)) {
            return "The payment record you requested could not be found.";
        }
        if ("exception".equalsIgnoreCase(code)) {
            return "Payments could not be loaded right now. Please try again.";
        }
        return "An admin payment error occurred. Please try again.";
    }

    private void verifyPayment(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        org.json.JSONObject result = new org.json.JSONObject();
        try {
            String idParam = req.getParameter("id");
            Integer id = null;
            try { id = Integer.valueOf(idParam); } catch (Exception ignored) {}
            if (id == null) {
                result.put("success", false);
                result.put("message", "Invalid payment ID.");
                resp.getWriter().write(result.toString());
                return;
            }

            Payment payment = paymentDAO.getPaymentById(id);
            if (payment == null) {
                result.put("success", false);
                result.put("message", "Payment record not found.");
                resp.getWriter().write(result.toString());
                return;
            }

            String ref = payment.getPaystackReference();
            if (ref == null || ref.trim().isEmpty()) {
                ref = payment.getPaymentRef();
            }

            if (ref == null || ref.trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "No Paystack transaction reference associated with this record.");
                resp.getWriter().write(result.toString());
                return;
            }

            org.json.JSONObject verifyData = paystackService.verifyTransaction(ref);
            if (verifyData == null) {
                result.put("success", false);
                result.put("message", "Gateway verification failed to reach Paystack or ref was invalid.");
                resp.getWriter().write(result.toString());
                return;
            }

            String gatewayStatus = verifyData.optString("status", "failed");
            String method = verifyData.optString("channel", "N/A");
            
            String localStatus = "Pending";
            if ("success".equals(gatewayStatus)) {
                localStatus = "Paid";
            } else if ("failed".equals(gatewayStatus)) {
                localStatus = "Failed";
            } else if ("abandoned".equals(gatewayStatus)) {
                localStatus = "Abandoned";
            }

            boolean updated = paymentDAO.updatePaymentStatus(payment.getPaymentId(), localStatus, method, gatewayStatus);
            if (updated) {
                // Sync enrollment status
                Enrollment enrollment = enrollmentDAO.getEnrollment(payment.getEnrollmentId());
                if (enrollment != null) {
                    new com.psm.elearning.service.EnrollmentStateSyncService().syncEnrollmentState(enrollment);
                }
                result.put("success", true);
                result.put("status", localStatus);
                result.put("gatewayStatus", gatewayStatus);
                result.put("method", method);
                result.put("message", "Transaction verified successfully with status: " + localStatus);
            } else {
                result.put("success", false);
                result.put("message", "Failed to update verified payment status in database.");
            }
            resp.getWriter().write(result.toString());
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "System error during verification: " + e.getMessage());
            resp.getWriter().write(result.toString());
        }
    }
}
