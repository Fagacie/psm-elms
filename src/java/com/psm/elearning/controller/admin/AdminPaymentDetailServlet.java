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

@WebServlet(name = "AdminPaymentDetailServlet", urlPatterns = {"/admin/payment"})
public class AdminPaymentDetailServlet extends HttpServlet {
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Simple admin guard
        Object role = req.getSession(false) != null ? req.getSession(false).getAttribute("userRole") : null;
        if (role == null || !"Admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String idParam = req.getParameter("id");
        Integer id = null;
        try { id = Integer.valueOf(idParam); } catch (Exception ignored) {}
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/payments");
            return;
        }
        Payment payment = paymentDAO.getPaymentById(id);
        if (payment == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/payments?error=notfound");
            return;
        }
        req.setAttribute("payment", payment);
        req.getRequestDispatcher("/admin/payment-detail.jsp").forward(req, resp);
    }
}
