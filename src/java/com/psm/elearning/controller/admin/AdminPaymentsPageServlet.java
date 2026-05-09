package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Payment;
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
}
