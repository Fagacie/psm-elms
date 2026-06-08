package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Servlet to list all enrollments (Admin).
 */
public class AdminEnrollmentListServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    private PaymentDAO paymentDAO;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = SessionUtil.resolveRole(session);
        if (!"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        String action = request.getParameter("action");
        if ("revoke".equals(action)) {
            revokeAccess(request, response);
            return;
        }

        try {
            List<Enrollment> enrollments = enrollmentDAO.getAllEnrollments();
            String successCode = request.getParameter("success");
            String errorCode = request.getParameter("error");

            if (enrollments != null && !enrollments.isEmpty()) {
                java.util.List<Integer> enrollmentIds = new java.util.ArrayList<>();
                for (Enrollment e : enrollments) {
                    if (e != null && e.getEnrollmentId() != null) {
                        enrollmentIds.add(e.getEnrollmentId());
                    }
                }
                java.util.List<Payment> payments = paymentDAO.getPaymentsByEnrollmentIds(enrollmentIds);
                java.util.Map<Integer, Payment> paymentMap = new java.util.HashMap<>();
                if (payments != null) {
                    for (Payment p : payments) {
                        if (p != null && p.getEnrollmentId() != null) {
                            paymentMap.putIfAbsent(p.getEnrollmentId(), p);
                        }
                    }
                }
                for (Enrollment e : enrollments) {
                    Payment p = paymentMap.get(e.getEnrollmentId());
                    if (p == null) {
                        e.setPaymentStatus("Pending");
                    } else {
                        e.setPaymentStatus(p.getStatus());
                        e.setPaymentRef(firstNonBlank(p.getPaymentRef(), p.getPaystackReference()));
                    }
                }
            }
            request.setAttribute("enrollments", enrollments);
            request.setAttribute("successMessage", resolveSuccessMessage(successCode));
            request.setAttribute("errorMessage", resolveErrorMessage(errorCode));
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-enrollment-list.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("AdminEnrollmentListServlet: Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("enrollments", java.util.Collections.emptyList());
            request.setAttribute("errorMessage", "Enrollments could not be loaded right now. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-enrollment-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = SessionUtil.resolveRole(session);
        if (!"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        Integer enrollmentId = parseInteger(request.getParameter("enrollmentId"));
        if (enrollmentId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=invalid");
            return;
        }

        Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
        if (enrollment == null) {
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=notfound");
            return;
        }

        String expiryDateValue = request.getParameter("expiryDateOverride");
        LocalDateTime expiryDateOverride = null;
        try {
            if (expiryDateValue != null && !expiryDateValue.trim().isEmpty()) {
                expiryDateOverride = LocalDate.parse(expiryDateValue.trim()).atTime(23, 59, 59);
            }
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=invalidExpiry");
            return;
        }

        try {
            boolean updated = enrollmentDAO.updateExpiryDateOverride(enrollmentId, expiryDateOverride);
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?" + (updated ? "success=expiryUpdated" : "error=exception"));
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=exception");
        }
    }

    private void enrichEnrollmentPayment(Enrollment enrollment) {
        Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
        if (payment == null) {
            enrollment.setPaymentStatus("Pending");
            return;
        }

        enrollment.setPaymentStatus(payment.getStatus());
        enrollment.setPaymentRef(firstNonBlank(payment.getPaymentRef(), payment.getPaystackReference()));
    }

    private String firstNonBlank(String primary, String fallback) {
        if (primary != null && !primary.trim().isEmpty()) {
            return primary.trim();
        }
        if (fallback != null && !fallback.trim().isEmpty()) {
            return fallback.trim();
        }
        return null;
    }

    private String resolveSuccessMessage(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        if ("updated".equalsIgnoreCase(code)) {
            return "Enrollment details were refreshed successfully.";
        }
        if ("expiryUpdated".equalsIgnoreCase(code)) {
            return "Enrollment expiry date was updated successfully.";
        }
        if ("revoked".equalsIgnoreCase(code)) {
            return "Access to the course has been successfully revoked.";
        }
        return null;
    }

    private String resolveErrorMessage(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        if ("invalid".equalsIgnoreCase(code)) {
            return "Choose a valid enrollment record to continue.";
        }
        if ("notfound".equalsIgnoreCase(code)) {
            return "The enrollment record you requested could not be found.";
        }
        if ("exception".equalsIgnoreCase(code)) {
            return "An enrollment error occurred. Please try again.";
        }
        if ("invalidExpiry".equalsIgnoreCase(code)) {
            return "Enter a valid expiry date to continue.";
        }
        return "An enrollment error occurred. Please try again.";
    }

    private Integer parseInteger(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(raw.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private void revokeAccess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Integer enrollmentId = parseInteger(request.getParameter("id"));
            if (enrollmentId == null) {
                response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=invalid");
                return;
            }
            boolean revoked = enrollmentDAO.updateStatus(enrollmentId, Enrollment.STATUS_CANCELLED);
            if (revoked) {
                response.sendRedirect(request.getContextPath() + "/admin/enrollments?success=revoked");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=exception");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/enrollments?error=exception");
        }
    }

}
