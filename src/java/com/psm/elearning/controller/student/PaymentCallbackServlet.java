package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.PaymentStatus;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.service.PaystackService;
import com.psm.elearning.util.DBConnection;
import org.json.JSONObject;
import org.json.JSONArray;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.model.Course;
import com.psm.elearning.util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * Servlet to handle Paystack payment callback (verifies payment and updates enrollment).
 */
public class PaymentCallbackServlet extends HttpServlet {

    private static final Pattern PAYMENT_REFERENCE_PATTERN =
            Pattern.compile("^[A-Za-z0-9][A-Za-z0-9_\\-.:]{7,119}$");
    private static final Logger LOGGER = Logger.getLogger(PaymentCallbackServlet.class.getName());
    
    private EnrollmentDAO enrollmentDAO;
    private PaymentDAO paymentDAO;
    private PaystackService paystackService;
    private UserDAO userDAO;
    private CourseDAO courseDAO;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        paystackService = new PaystackService();
        userDAO = new UserDAOImpl();
        courseDAO = new CourseDAOImpl();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String reference = request.getParameter("reference");
            if (reference != null) {
                reference = reference.trim();
            }
            
            if (reference == null || reference.isEmpty()) {
                LOGGER.warning("Payment callback rejected: missing payment reference");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=noreference");
                return;
            }

            if (!isValidReference(reference)) {
                LOGGER.warning("Payment callback rejected: invalid payment reference format");
                response.sendRedirect(request.getContextPath() + "/student/payment-failed?error=badreference");
                return;
            }

            LOGGER.info("Verifying payment callback for reference=" + maskReference(reference));
            
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
            
            // Verify payment with Paystack
            JSONObject verificationResult = paystackService.verifyTransaction(reference);

            if (verificationResult != null) {
                String paystackStatus = normalizeProviderStatus(verificationResult.optString("status", "failed"));
                String paymentMethod = normalizePaymentMethod(verificationResult.optString("channel", "paystack"));
                if (!isMetadataEnrollmentMatch(verificationResult, payment.getEnrollmentId())) {
                    LOGGER.warning("Payment callback metadata mismatch or missing for reference=" + maskReference(reference) + ". Proceeding because reference and amount match.");
                }
                int verifiedAmountKobo = verificationResult.optInt("amount", -1);
                if (verifiedAmountKobo > -1) {
                    long expectedAmountKobo = toAmountKobo(payment.getAmount());
                    if (expectedAmountKobo != verifiedAmountKobo) {
                        LOGGER.warning("Payment callback amount mismatch reference=" + maskReference(reference) +
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String webhookSecret = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_PAYSTACK_WEBHOOK, "");
        if (webhookSecret == null || webhookSecret.trim().isEmpty()) {
            LOGGER.warning("Paystack webhook rejected: webhook secret not configured");
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("Webhook secret not configured");
            return;
        }

        String signatureHeader = request.getHeader("X-Paystack-Signature");
        if (signatureHeader == null || signatureHeader.trim().isEmpty()) {
            LOGGER.warning("Paystack webhook rejected: missing signature header");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Missing signature");
            return;
        }

        StringBuilder rawBodyBuilder = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            rawBodyBuilder.append(line);
        }
        String rawBody = rawBodyBuilder.toString();

        if (!isValidWebhookSignature(rawBody, signatureHeader, webhookSecret)) {
            LOGGER.warning("Paystack webhook rejected: invalid signature");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Invalid signature");
            return;
        }

        try {
            JSONObject payload = new JSONObject(rawBody);
            String event = payload.optString("event", "").trim();
            JSONObject data = payload.optJSONObject("data");
            if (data == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Missing event data");
                return;
            }

            String reference = data.optString("reference", "").trim();
            if (reference.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Missing payment reference");
                return;
            }

            if (!isValidReference(reference)) {
                LOGGER.warning("Paystack webhook rejected: invalid payment reference format");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid payment reference");
                return;
            }

            Payment payment = paymentDAO.getPaymentByPaystackReference(reference);
            if (payment == null) {
                LOGGER.warning("Paystack webhook: payment not found for reference=" + reference);
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Payment not found");
                return;
            }

            if (isPaid(payment.getStatus())) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;
            }

            Enrollment enrollment = enrollmentDAO.getEnrollment(payment.getEnrollmentId());
            if (enrollment == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Enrollment not found");
                return;
            }

            String providerStatus = normalizeProviderStatus(data.optString("status", "failed"));
            String paymentMethod = normalizePaymentMethod(data.optString("channel", "paystack"));
            if (!isMetadataEnrollmentMatch(data, payment.getEnrollmentId())) {
                LOGGER.warning("Paystack webhook metadata mismatch or missing for reference=" + maskReference(reference) + ". Proceeding because reference and amount match.");
            }
            int verifiedAmountKobo = data.optInt("amount", -1);

            if (verifiedAmountKobo > -1) {
                long expectedAmountKobo = toAmountKobo(payment.getAmount());
                if (expectedAmountKobo != verifiedAmountKobo) {
                    LOGGER.warning("Paystack webhook amount mismatch reference=" + maskReference(reference) +
                            " expectedKobo=" + expectedAmountKobo + " verifiedKobo=" + verifiedAmountKobo);
                    paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", paymentMethod, "amount_mismatch");
                    enrollmentDAO.updatePaymentStatus(payment.getEnrollmentId(), "Failed", reference);
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("OK");
                    return;
                }
            }

            if ("charge.success".equalsIgnoreCase(event) || "success".equals(providerStatus)) {
                boolean updated = markPaymentSuccessful(payment, enrollment, paymentMethod, providerStatus);
                response.setStatus(updated ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(updated ? "OK" : "Update failed");
                return;
            }

            if ("failed".equals(providerStatus)) {
                paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Failed", paymentMethod, providerStatus);
                enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Failed", reference);
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;
            }

            if ("abandoned".equals(providerStatus)) {
                paymentDAO.updatePaymentStatus(payment.getPaymentId(), "Abandoned", paymentMethod, providerStatus);
                enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Pending", reference);
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;
            }

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Ignored");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Paystack webhook processing error", ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Webhook error");
        }
    }

    private boolean markPaymentSuccessful(Payment payment,
                                          Enrollment enrollment,
                                          String paymentMethod,
                                          String providerStatus) {
        String nextEnrollmentStatus = AppSettingsService.getBoolean(AppSettingsService.KEY_ENROLLMENT_AUTO_ACTIVATE, true)
                ? "Enrolled"
                : (enrollment.getStatus() == null || enrollment.getStatus().trim().isEmpty() ? "Pending" : enrollment.getStatus());
        boolean updated = applySuccessfulStateTransaction(
            payment.getPaymentId(),
            enrollment.getEnrollmentId(),
            payment.getPaystackReference(),
            paymentMethod,
            providerStatus,
            nextEnrollmentStatus
        );

        if (updated) {
            try {
                User student = userDAO.getUser(enrollment.getStudentId());
                Course course = courseDAO.getCourse(enrollment.getCourseId());
                String dateStr = new java.text.SimpleDateFormat("MMMM dd, yyyy").format(new java.util.Date());
                String formattedAmount = String.format("₦%,.2f", payment.getAmount());
                new Thread(() -> {
                    EmailUtil.sendPaymentReceiptEmail(
                        student.getEmail(),
                        student.getFullName(),
                        course.getCourseName(),
                        payment.getPaystackReference(),
                        dateStr,
                        formattedAmount
                    );
                }).start();
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to send payment receipt email", e);
            }
        }
        return updated;
    }

    private boolean ensureEnrollmentPaidState(Payment payment, String reference) {
        String nextEnrollmentStatus = AppSettingsService.getBoolean(AppSettingsService.KEY_ENROLLMENT_AUTO_ACTIVATE, true)
                ? "Enrolled"
                : "Pending";
        return applySuccessfulStateTransaction(
            payment.getPaymentId(),
            payment.getEnrollmentId(),
            reference,
            payment.getMethod(),
            payment.getPaystackStatus(),
            nextEnrollmentStatus
        );
    }

    private boolean isPaid(String status) {
        return PaymentStatus.isComplete(status);
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

    private boolean isValidWebhookSignature(String rawBody, String providedSignature, String secret) {
        try {
            Mac sha512 = Mac.getInstance("HmacSHA512");
            sha512.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] digest = sha512.doFinal(rawBody.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(String.format("%02x", b));
            }
            byte[] expected = hex.toString().toLowerCase(Locale.ENGLISH).getBytes(StandardCharsets.UTF_8);
            byte[] actual = providedSignature.trim().toLowerCase(Locale.ENGLISH).getBytes(StandardCharsets.UTF_8);
            return MessageDigest.isEqual(expected, actual);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Webhook signature validation failed", e);
            return false;
        }
    }

    private boolean isValidReference(String reference) {
        if (reference == null) {
            return false;
        }
        String normalized = reference.trim();
        if (normalized.contains("\n") || normalized.contains("\r")) {
            return false;
        }
        return PAYMENT_REFERENCE_PATTERN.matcher(normalized).matches();
    }

    private long toAmountKobo(Double amount) {
        if (amount == null) {
            return 0L;
        }
        return Math.round(amount * 100d);
    }

    private boolean isMetadataEnrollmentMatch(JSONObject providerData, Integer expectedEnrollmentId) {
        Integer metadataEnrollmentId = extractEnrollmentIdFromMetadata(providerData);
        if (metadataEnrollmentId == null) {
            LOGGER.warning("Metadata enrollment_id is missing or unparseable. Proceeding since reference and amount match.");
            return true;
        }
        return metadataEnrollmentId.equals(expectedEnrollmentId);
    }

    private Integer extractEnrollmentIdFromMetadata(JSONObject providerData) {
        if (providerData == null) {
            return null;
        }
        Object metadataObj = providerData.opt("metadata");
        if (metadataObj == null) {
            return null;
        }
        
        JSONObject metadata = null;
        if (metadataObj instanceof JSONObject) {
            metadata = (JSONObject) metadataObj;
        } else if (metadataObj instanceof String) {
            String metadataStr = ((String) metadataObj).trim();
            if (!metadataStr.isEmpty() && !metadataStr.equalsIgnoreCase("null")) {
                try {
                    metadata = new JSONObject(metadataStr);
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Failed to parse metadata string as JSON: " + metadataStr, e);
                }
            }
        }
        
        if (metadata == null) {
            return null;
        }

        Integer fromPrimary = parseIntegerSafe(metadata.opt("enrollment_id"));
        if (fromPrimary != null) {
            return fromPrimary;
        }

        JSONArray customFields = metadata.optJSONArray("custom_fields");
        if (customFields == null) {
            return null;
        }

        for (int i = 0; i < customFields.length(); i++) {
            JSONObject field = customFields.optJSONObject(i);
            if (field == null) {
                continue;
            }
            String variableName = field.optString("variable_name", "").trim();
            if (!"enrollment_id".equalsIgnoreCase(variableName)) {
                continue;
            }
            Integer parsed = parseIntegerSafe(field.opt("value"));
            if (parsed != null) {
                return parsed;
            }
        }

        return null;
    }

    private Integer parseIntegerSafe(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(String.valueOf(value).trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private boolean applySuccessfulStateTransaction(Integer paymentId,
                                                    Integer enrollmentId,
                                                    String reference,
                                                    String paymentMethod,
                                                    String paystackStatus,
                                                    String enrollmentStatus) {
        String updatePaymentSql = "UPDATE Payment SET PaymentStatus=?, PaymentMethod=?, PaystackStatus=?, PaymentRef=?, PaystackReference=? WHERE PaymentID=?";
        String updateEnrollmentSql = "UPDATE Enrollment SET Status=?, PaymentStatus=?, PaymentRef=? WHERE EnrollmentID=?";

        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);
            try (PreparedStatement updatePayment = connection.prepareStatement(updatePaymentSql);
                 PreparedStatement updateEnrollment = connection.prepareStatement(updateEnrollmentSql)) {

                updatePayment.setString(1, "Paid");
                updatePayment.setString(2, normalizePaymentMethod(paymentMethod));
                updatePayment.setString(3, normalizeProviderStatus(paystackStatus));
                updatePayment.setString(4, reference);
                updatePayment.setString(5, reference);
                updatePayment.setInt(6, paymentId);
                int paymentRows = updatePayment.executeUpdate();

                updateEnrollment.setString(1, enrollmentStatus);
                updateEnrollment.setString(2, "Paid");
                updateEnrollment.setString(3, reference);
                updateEnrollment.setInt(4, enrollmentId);
                int enrollmentRows = updateEnrollment.executeUpdate();

                // Accept 0 or 1 rows affected (MySQL returns 0 if columns already have the target values)
                if (paymentRows < 0 || paymentRows > 1 || enrollmentRows < 0 || enrollmentRows > 1) {
                    connection.rollback();
                    LOGGER.warning("Payment success transaction rollback due to unexpected row counts: paymentRows=" + paymentRows + ", enrollmentRows=" + enrollmentRows + " for reference=" + maskReference(reference));
                    return false;
                }

                connection.commit();
                return true;
            } catch (SQLException sqlException) {
                connection.rollback();
                LOGGER.log(Level.SEVERE, "Payment success transaction failed for reference=" + maskReference(reference), sqlException);
                return false;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to open transaction for payment success update", e);
            return false;
        }
    }

    private String maskReference(String reference) {
        if (reference == null || reference.trim().isEmpty()) {
            return "-";
        }
        String normalized = reference.trim();
        if (normalized.length() <= 8) {
            return "****";
        }
        return normalized.substring(0, 4) + "..." + normalized.substring(normalized.length() - 4);
    }
}
