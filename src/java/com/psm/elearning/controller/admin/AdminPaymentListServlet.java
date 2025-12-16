package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Payment;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminPaymentListServlet", urlPatterns = {"/admin/payments"})
public class AdminPaymentListServlet extends HttpServlet {
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Simple admin guard
        Object role = req.getSession(false) != null ? req.getSession(false).getAttribute("userRole") : null;
        if (role == null || !"Admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String status = req.getParameter("status");
        int page = parseInt(req.getParameter("page"), 1);
        int pageSize = parseInt(req.getParameter("pageSize"), 20);

        List<Payment> payments = paymentDAO.listPayments(status, page, pageSize);
        req.setAttribute("payments", payments);
        req.setAttribute("status", status);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", pageSize);
        req.getRequestDispatcher("/admin/payments.jsp").forward(req, resp);
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
