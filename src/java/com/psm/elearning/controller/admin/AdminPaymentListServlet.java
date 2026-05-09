package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Payment;
import com.psm.elearning.util.SessionUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class AdminPaymentListServlet extends HttpServlet {
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = SessionUtil.resolveUserId(req.getSession(false));
        String role = SessionUtil.resolveRole(req.getSession(false));
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!"Admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        String queryString = req.getQueryString();
        resp.sendRedirect(req.getContextPath() + "/admin/payments" + (queryString == null || queryString.isEmpty() ? "" : "?" + queryString));
    }
}
