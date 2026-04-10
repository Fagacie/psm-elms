package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.service.PaystackService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet to initialize a Paystack payment transaction.
 * Creates a Payment record and redirects to Paystack's authorization URL.
 */
public class StartPaymentServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StartPaymentServlet.class.getName());

    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private PaymentDAO paymentDAO;
    private PaystackService paystackService;

    @Override
    public void init() {
        LOGGER.info("StartPaymentServlet initialized");
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        paystackService = new PaystackService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LOGGER.info("StartPaymentServlet payment request received");

        HttpSession session = request.getSession(false);
        Integer userId = resolveUserId(session);
        if (session == null || userId == null) {
            LOGGER.warning("Payment start rejected: missing session");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = resolveRole(session);
        if (!"Student".equals(role)) {
            LOGGER.warning("Payment start rejected: unauthorized role");
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        try {
            String userEmail = (String) session.getAttribute("email");
            if (!paystackService.isConfiguredForPayments()) {
                LOGGER.severe("Payment start blocked: Paystack keys are not configured");
                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + request.getParameter("enrollmentId") + "&error=paystackconfig");
                return;
            }
            if (userEmail == null || userEmail.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + request.getParameter("enrollmentId") + "&error=noemail");
                return;
            }
            Integer enrollmentId = parseEnrollmentId(request.getParameter("enrollmentId"));
            if (enrollmentId == null) {
                LOGGER.warning("Payment start failed: invalid enrollmentId parameter");
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
                return;
            }
            LOGGER.info("Payment start requested for enrollmentId=" + enrollmentId + ", userId=" + userId);

            // Get enrollment to verify ownership and get course fee
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null) {
                LOGGER.warning("Payment start failed: enrollment not found id=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }

            // Verify ownership
            if (!enrollment.getUserId().equals(userId)) {
                LOGGER.warning("Payment start rejected: enrollment ownership mismatch id=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }

            // Fetch course to get fee
            Course course = courseDAO.findById(enrollment.getCourseId());
            if (course == null) {
                LOGGER.warning("Payment start failed: course not found id=" + enrollment.getCourseId());
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=coursenotfound");
                return;
            }

            // Check if already paid
            Payment existingPayment = paymentDAO.getPaymentByEnrollmentId(enrollmentId);
            if (existingPayment != null && isPaid(existingPayment.getStatus())) {
                LOGGER.info("Payment start skipped: enrollment already paid id=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?message=alreadypaid");
                return;
            }

            BigDecimal amount = course.getCourseFee();
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&message=freeenrolled");
                return;
            }
            LOGGER.info("Payment init amount=" + amount + ", email=" + maskEmail(userEmail));

            // Generate external reference
            String externalReference = "PSME_" + enrollmentId + "_" + UUID.randomUUID().toString();
            LOGGER.info("Generated payment reference=" + maskReference(externalReference));

            // Initialize Paystack transaction with external reference
            String callbackUrl = buildCallbackUrl(request);
            Payment initResult = paystackService.initializeTransaction(
                    userEmail,
                    amount.doubleValue(),
                    enrollmentId,
                    externalReference,
                    callbackUrl
            );

            if (initResult != null) {
                LOGGER.info("Paystack initialization successful for enrollmentId=" + enrollmentId);

                String authorizationUrl = initResult.getAuthorizationUrl();
                String accessCode = initResult.getAccessCode();
                String paystackReference = initResult.getPaystackReference();
                if (paystackReference == null || paystackReference.trim().isEmpty()) {
                    paystackReference = externalReference;
                }
                LOGGER.info("Gateway reference=" + maskReference(paystackReference));

                boolean paymentStored;
                if (existingPayment != null && !isPaid(existingPayment.getStatus())) {
                    paymentStored = paymentDAO.refreshPaymentInitialization(
                            existingPayment.getPaymentId(),
                            amount.doubleValue(),
                            "Paystack",
                            paystackReference,
                            accessCode,
                            authorizationUrl,
                            "pending"
                    );
                } else {
                    Payment payment = new Payment();
                    payment.setEnrollmentId(enrollmentId);
                    payment.setAmount(amount.doubleValue());
                    payment.setStatus("Pending");
                    payment.setMethod("Paystack");
                    payment.setPaymentRef(paystackReference);
                    payment.setPaystackReference(paystackReference);
                    payment.setAccessCode(accessCode);
                    payment.setAuthorizationUrl(authorizationUrl);
                    payment.setPaystackStatus("pending");
                    payment.setPaymentDate(LocalDateTime.now());
                    paymentStored = paymentDAO.createPayment(payment) != null;
                }
                if (!paymentStored) {
                    LOGGER.severe("Failed to persist payment record for enrollmentId=" + enrollmentId);
                    response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + enrollmentId + "&error=initstore");
                    return;
                }

                enrollmentDAO.updatePaymentStatus(enrollmentId, "Pending", paystackReference);
                LOGGER.info("Payment record persisted with pending status for enrollmentId=" + enrollmentId);

                // Redirect to Paystack authorization URL
                LOGGER.info("Redirecting to payment authorization endpoint");
                response.sendRedirect(authorizationUrl);

            } else {
                LOGGER.severe("Paystack initialization returned null result");
                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + enrollmentId + "&error=paystack");
            }

        } catch (NumberFormatException e) {
            LOGGER.warning("Payment start failed: invalid enrollmentId parameter");
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected payment start error", e);
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=exception");
        }
    }

    private Integer parseEnrollmentId(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Integer resolveUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object raw = session.getAttribute("userId");
        if (raw instanceof Integer) {
            Integer parsed = (Integer) raw;
            return parsed > 0 ? parsed : null;
        }
        if (raw instanceof String) {
            try {
                int parsed = Integer.parseInt(((String) raw).trim());
                return parsed > 0 ? parsed : null;
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private String resolveRole(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object role = session.getAttribute("role");
        if (!(role instanceof String) || ((String) role).trim().isEmpty()) {
            role = session.getAttribute("userRole");
        }
        if (!(role instanceof String)) {
            return null;
        }
        String normalized = ((String) role).trim();
        if ("Student".equalsIgnoreCase(normalized)) {
            return "Student";
        }
        if ("Admin".equalsIgnoreCase(normalized)) {
            return "Admin";
        }
        if ("Instructor".equalsIgnoreCase(normalized)) {
            return "Instructor";
        }
        return null;
    }

    private boolean isPaid(String status) {
        if (status == null) {
            return false;
        }
        String normalized = status.trim().toLowerCase(Locale.ENGLISH);
        return "paid".equals(normalized) || "completed".equals(normalized) || "success".equals(normalized);
    }

    private String buildCallbackUrl(HttpServletRequest request) {
        String configured = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_CALLBACK_URL, "");
        if (!configured.isEmpty()) {
            return configured;
        }
        String scheme = request.getScheme();
        String server = request.getServerName();
        int port = request.getServerPort();
        boolean defaultPort = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443);
        String host = defaultPort ? (scheme + "://" + server) : (scheme + "://" + server + ":" + port);
        return host + request.getContextPath() + "/student/payment-callback";
    }

    private String maskReference(String reference) {
        if (reference == null || reference.isEmpty()) {
            return "-";
        }
        if (reference.length() <= 8) {
            return "****";
        }
        return reference.substring(0, 4) + "..." + reference.substring(reference.length() - 4);
    }

    private String maskEmail(String email) {
        if (email == null || email.isEmpty() || !email.contains("@")) {
            return "-";
        }
        String[] parts = email.split("@", 2);
        String name = parts[0];
        String domain = parts[1];
        if (name.length() <= 2) {
            return "**@" + domain;
        }
        return name.substring(0, 2) + "***@" + domain;
    }
}
