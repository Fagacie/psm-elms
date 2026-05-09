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

public class AdminPaymentDetailServlet extends HttpServlet {
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
        String idParam = req.getParameter("id");
        Integer id = null;
        try { id = Integer.valueOf(idParam); } catch (Exception ignored) {}
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/payments?error=invalid");
            return;
        }
        Payment payment = paymentDAO.getPaymentById(id);
        if (payment == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/payments?error=notfound");
            return;
        }
        req.setAttribute("payment", payment);
        req.getRequestDispatcher("/WEB-INF/views/admin/payment-detail.jsp").forward(req, resp);
    }
}
