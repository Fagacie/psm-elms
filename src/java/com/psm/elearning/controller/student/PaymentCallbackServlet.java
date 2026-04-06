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
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet to handle Paystack payment callback (verifies payment and updates enrollment).
 */
public class PaymentCallbackServlet extends HttpServlet {

    private static final double AMOUNT_TOLERANCE = 0.01d;
    private static final Logger LOGGER = Logger.getLogger(PaymentCallbackServlet.class.getName());
    
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
        if (role == null) {
            role = (String) session.getAttribute("userRole");
        }
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            String reference = request.getParameter("reference");
            
            if (reference == null || reference.isEmpty()) {
                LOGGER.warning("Payment callback rejected: missing payment reference");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=noreference");
                return;
            }

            LOGGER.info("Verifying payment callback for reference=" + reference);
            
            // Get payment record by Paystack reference
            Payment payment = paymentDAO.getPaymentByPaystackReference(reference);
            
            if (payment == null) {
                LOGGER.warning("Payment callback failed: payment record not found for reference=" + reference);
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=notfound");
                return;
            }

            String failedBaseUrl = request.getContextPath() + "/student/payment-failed?enrollmentId=" + payment.getEnrollmentId();

            if (isPaid(payment.getStatus())) {
                boolean stateAligned = ensureEnrollmentPaidState(payment, reference);
                if (stateAligned) {
                    response.sendRedirect(request.getContextPath() + "/student/payment-success?enrollmentId=" + payment.getEnrollmentId());
                } else {
                    response.sendRedirect(failedBaseUrl + "&error=state");
                }
                return;
            }
            
            // Get enrollment
            Enrollment enrollment = enrollmentDAO.getEnrollment(payment.getEnrollmentId());
            
            if (enrollment == null) {
                LOGGER.warning("Payment callback failed: enrollment not found for paymentId=" + payment.getPaymentId());
                response.sendRedirect(failedBaseUrl + "&error=notfound");
                return;
            }
            
            // Verify ownership
            if (!enrollment.getUserId().equals(userId)) {
                LOGGER.warning("Payment callback blocked: unauthorized access for enrollmentId=" + enrollment.getEnrollmentId());
                response.sendRedirect(failedBaseUrl + "&error=unauthorized");
                return;
            }
            
            // Verify payment with Paystack
            JSONObject verificationResult = paystackService.verifyTransaction(reference);

            if (verificationResult != null) {
                String paystackStatus = normalizeProviderStatus(verificationResult.optString("status", "failed"));
                String paymentMethod = normalizePaymentMethod(verificationResult.optString("channel", "paystack"));
                int verifiedAmountKobo = verificationResult.optInt("amount", -1);
                if (verifiedAmountKobo > -1) {
                    double expectedAmountKobo = payment.getAmount() != null ? payment.getAmount() * 100d : 0d;
                    if (Math.abs(expectedAmountKobo - verifiedAmountKobo) > AMOUNT_TOLERANCE) {
                        LOGGER.warning("Payment callback amount mismatch reference=" + reference +
                                " expectedKobo=" + expectedAmountKobo + " verifiedKobo=" + verifiedAmountKobo);
                        paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", paymentMethod, "amount_mismatch");
                        enrollmentDAO.updatePaymentStatus(payment.getEnrollmentId(), "Failed", reference);
                        response.sendRedirect(failedBaseUrl + "&error=amountmismatch");
                        return;
                    }
                }

                LOGGER.info("Payment verification status reference=" + reference + " status=" + paystackStatus);

                switch (paystackStatus) {
                    case "success": {
                        boolean stateUpdated = markPaymentSuccessful(payment, enrollment, paymentMethod, paystackStatus);
                        if (stateUpdated) {
                            response.sendRedirect(request.getContextPath() + "/student/payment-success?enrollmentId=" + enrollment.getEnrollmentId());
                        } else {
                            response.sendRedirect(failedBaseUrl + "&error=update");
                        }
                        break;
                    }
                    case "failed": {
                        if (!isPaid(payment.getStatus())) {
                            paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", paymentMethod, paystackStatus);
                            enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Failed", reference);
                        }
                        response.sendRedirect(failedBaseUrl + "&error=failed");
                        break;
                    }
                    case "abandoned": {
                        if (!isPaid(payment.getStatus())) {
                            paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Abandoned", paymentMethod, paystackStatus);
                            enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Pending", reference);
                        }
                        response.sendRedirect(failedBaseUrl + "&error=abandoned");
                        break;
                    }
                    default: {
                        if (!isPaid(payment.getStatus())) {
                            paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", paymentMethod, paystackStatus);
                            enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Failed", reference);
                        }
                        response.sendRedirect(failedBaseUrl + "&error=unknownstatus");
                    }
                }
            } else {
                LOGGER.warning("Payment verification returned null for reference=" + reference + " (network or API error)");
                paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", "paystack", "failed");
                enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Failed", reference);
                response.sendRedirect(failedBaseUrl + "&error=verification");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Payment callback processing error", e);
            response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=exception");
        }
    }

    private boolean markPaymentSuccessful(Payment payment,
                                          Enrollment enrollment,
                                          String paymentMethod,
                                          String providerStatus) {
        boolean paymentUpdated = paymentDAO.updatePaymentStatus(
                payment.getPaymentId(), "Paid", paymentMethod, providerStatus);
        boolean enrollmentStatusUpdated = enrollmentDAO.updateStatus(
                enrollment.getEnrollmentId(), "Enrolled");
        boolean enrollmentPaymentUpdated = enrollmentDAO.updatePaymentStatus(
                enrollment.getEnrollmentId(), "Paid", payment.getPaystackReference());
        return paymentUpdated && enrollmentStatusUpdated && enrollmentPaymentUpdated;
    }

    private boolean ensureEnrollmentPaidState(Payment payment, String reference) {
        boolean enrollmentStatusUpdated = enrollmentDAO.updateStatus(payment.getEnrollmentId(), "Enrolled");
        boolean enrollmentPaymentUpdated = enrollmentDAO.updatePaymentStatus(payment.getEnrollmentId(), "Paid", reference);
        return enrollmentStatusUpdated && enrollmentPaymentUpdated;
    }

    private boolean isPaid(String status) {
        if (status == null) {
            return false;
        }
        String normalized = status.trim().toLowerCase(Locale.ENGLISH);
        return "paid".equals(normalized) || "completed".equals(normalized) || "success".equals(normalized);
    }

    private String normalizeProviderStatus(String status) {
        if (status == null) {
            return "failed";
        }
        String normalized = status.trim().toLowerCase(Locale.ENGLISH);
        if ("success".equals(normalized) || "failed".equals(normalized) || "abandoned".equals(normalized)) {
            return normalized;
        }
        return "failed";
    }

    private String normalizePaymentMethod(String method) {
        if (method == null || method.trim().isEmpty()) {
            return "paystack";
        }
        return method.trim().toLowerCase(Locale.ENGLISH);
    }
}
