package com.psm.elearning.controller;

import com.psm.elearning.util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public class MailTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String to = request.getParameter("to");
        try (PrintWriter out = response.getWriter()) {
            out.println("<html><head><title>Mail Test</title></head><body>");
            out.println("<h3>Send Test Email</h3>");
            out.println("<form method='get'>");
            out.println("<input type='email' name='to' placeholder='recipient@example.com' value='" + (to != null ? to : "") + "' required /> ");
            out.println("<button type='submit'>Send</button>");
            out.println("</form>");

            if (to != null && !to.trim().isEmpty()) {
                boolean ok = EmailUtil.sendEmail(to.trim(), "PSM E-Learning Mail Test", "This is a test email from PSM E-Learning.");
                out.println("<p>Result: " + (ok ? "<span style='color:green'>SENT</span>" : "<span style='color:red'>FAILED</span>") + "</p>");
                out.println("<p>Check Tomcat console/logs for debug output.</p>");
            }
            out.println("</body></html>");
        }
    }
}
