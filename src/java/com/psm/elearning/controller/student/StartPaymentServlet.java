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
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
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
    private StudentAccessService studentAccessService;

    @Override
    public void init() {
        LOGGER.info("StartPaymentServlet initialized");
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        paystackService = new PaystackService();
        studentAccessService = new StudentAccessService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LOGGER.info("StartPaymentServlet payment request received");

        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (!studentAccessService.isStudentSession(session) || userId == null) {
            LOGGER.warning("Payment start rejected: missing session");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String userEmail = (String) session.getAttribute("email");
            Integer enrollmentId = parseEnrollmentId(request.getParameter("enrollmentId"));
            if (enrollmentId == null) {
                LOGGER.warning("Payment start failed: invalid enrollmentId parameter");
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
                return;
            }

            // Get enrollment to verify ownership and get course fee
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null) {
                LOGGER.warning("Payment start failed: enrollment not found id=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }

            // Verify ownership
            if (!studentAccessService.belongsToStudent(enrollment, userId)) {
                LOGGER.warning("Payment start rejected: enrollment ownership mismatch id=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }

            if (!paystackService.isConfiguredForPayments()) {
                LOGGER.severe("Payment start blocked: Paystack keys are not configured");
                response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + enrollment.getCourseId() + "&error=paystackconfig");
                return;
            }
            if (userEmail == null || userEmail.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + enrollment.getCourseId() + "&error=noemail");
                return;
            }
            LOGGER.info("Payment start requested for enrollmentId=" + enrollmentId + ", userId=" + userId);

            // Fetch course to get fee
            Course course = courseDAO.findById(enrollment.getCourseId());
            if (course == null) {
                LOGGER.warning("Payment start failed: course not found id=" + enrollment.getCourseId());
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=coursenotfound");
                return;
            }

            // Check if already paid
            Payment existingPayment = paymentDAO.getPaymentByEnrollmentId(enrollmentId);
            if (existingPayment != null && studentAccessService.isPaymentComplete(existingPayment.getStatus())) {
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
                if (existingPayment != null && !studentAccessService.isPaymentComplete(existingPayment.getStatus())) {
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
                    response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + enrollment.getCourseId() + "&error=initstore");
                    return;
                }

                enrollmentDAO.updatePaymentStatus(enrollmentId, "Pending", paystackReference);
                LOGGER.info("Payment record persisted with pending status for enrollmentId=" + enrollmentId);

                // Redirect to Paystack authorization URL
                LOGGER.info("Redirecting to payment authorization endpoint");
                response.sendRedirect(authorizationUrl);

            } else {
                LOGGER.severe("Paystack initialization returned null result");
                response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + enrollment.getCourseId() + "&error=paystack");
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

    private String buildCallbackUrl(HttpServletRequest request) {
        String configured = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_CALLBACK_URL, "");
        if (!configured.isEmpty()) {
            return configured;
        }
        
        String scheme = request.getHeader("X-Forwarded-Proto");
        if (scheme == null || scheme.trim().isEmpty()) {
            scheme = request.getScheme();
        }
        
        String server = request.getHeader("X-Forwarded-Host");
        if (server == null || server.trim().isEmpty()) {
            server = request.getServerName();
        } else {
            if (server.contains(":")) {
                server = server.split(":")[0];
            }
        }
        
        String forwardedPort = request.getHeader("X-Forwarded-Port");
        int port = -1;
        if (forwardedPort != null && !forwardedPort.trim().isEmpty()) {
            try {
                port = Integer.parseInt(forwardedPort.trim());
            } catch (NumberFormatException ignored) {}
        }
        if (port == -1) {
            port = request.getServerPort();
        }
        
        boolean defaultPort = ("http".equalsIgnoreCase(scheme) && (port == 80 || port == 8080))
                || ("https".equalsIgnoreCase(scheme) && (port == 443 || port == 8443));
                
        String host;
        if (request.getHeader("X-Forwarded-Host") != null) {
            host = scheme + "://" + server;
        } else {
            host = defaultPort ? (scheme + "://" + server) : (scheme + "://" + server + ":" + port);
        }
        
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
