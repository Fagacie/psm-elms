package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.PaystackService;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet to handle Paystack payment callback (verifies payment and updates enrollment).
 */
public class PaymentCallbackServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    private PaymentDAO paymentDAO;
    private PaystackService paystackService;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        paystackService = new PaystackService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            String reference = request.getParameter("reference");
            
            if (reference == null || reference.isEmpty()) {
                System.err.println("PaymentCallbackServlet: No reference provided");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=noreference");
                return;
            }
            
            System.out.println("PaymentCallbackServlet: Verifying payment with reference: " + reference);
            
            // Get payment record by Paystack reference
            Payment payment = paymentDAO.getPaymentByPaystackReference(reference);
            
            if (payment == null) {
                System.err.println("PaymentCallbackServlet: Payment record not found");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=notfound");
                return;
            }
            
            // Get enrollment
            Enrollment enrollment = enrollmentDAO.getEnrollment(payment.getEnrollmentId());
            
            if (enrollment == null) {
                System.err.println("PaymentCallbackServlet: Enrollment not found");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=notfound");
                return;
            }
            
            // Verify ownership
            if (!enrollment.getUserId().equals(userId)) {
                System.err.println("PaymentCallbackServlet: Unauthorized access attempt");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=unauthorized");
                return;
            }
            
            // Verify payment with Paystack
            JSONObject verificationResult = paystackService.verifyTransaction(reference);

            if (verificationResult != null) {
                String paystackStatus = verificationResult.optString("status", "failed");
                String paymentMethod = verificationResult.optString("channel", "paystack");

                System.out.println("PaymentCallbackServlet: Verification status: " + paystackStatus);

                switch (paystackStatus) {
                    case "success": {
                        // Align with DB enum value
                        boolean paymentUpdated = paymentDAO.updatePaymentStatus(
                            payment.getPaymentId(), "Success", paymentMethod, paystackStatus);
                        boolean enrollmentStatusUpdated = enrollmentDAO.updateStatus(
                            enrollment.getEnrollmentId(), "Enrolled");
                        // Also update enrollment payment status
                        boolean enrollmentPaymentUpdated = enrollmentDAO.updatePaymentStatus(
                            enrollment.getEnrollmentId(), "Paid", payment.getPaystackReference());
                        if (paymentUpdated && enrollmentStatusUpdated && enrollmentPaymentUpdated) {
                            response.sendRedirect(request.getContextPath() + "/student/payment-success?enrollmentId=" + enrollment.getEnrollmentId());
                        } else {
                            response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=update");
                        }
                        break;
                    }
                    case "failed": {
                        paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", paymentMethod, paystackStatus);
                        // Keep enrollment pending
                        response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=failed");
                        break;
                    }
                    case "abandoned": {
                        paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Abandoned", paymentMethod, paystackStatus);
                        response.sendRedirect(request.getContextPath() + "/student/payment-incomplete?enrollmentId=" + enrollment.getEnrollmentId());
                        break;
                    }
                    default: {
                        paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", paymentMethod, paystackStatus);
                        response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=unknownstatus");
                    }
                }
            } else {
                System.err.println("PaymentCallbackServlet: Verification returned null (network or API error)");
                paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", "paystack", "failed");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=verification");
            }
            
        } catch (Exception e) {
            System.err.println("PaymentCallbackServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=exception");
        }
    }
}
