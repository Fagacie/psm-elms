package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.AppSettingDAO;
import com.psm.elearning.dao.AppSettingDAOImpl;
import com.psm.elearning.model.AppSettingAuditEntry;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.mail.Authenticator;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

public class AdminSettingsServlet extends HttpServlet {

    private final AppSettingDAO appSettingDAO = new AppSettingDAOImpl();

    private static final String KEY_PLATFORM_NAME = "platform.name";
    private static final String KEY_PLATFORM_SUPPORT_EMAIL = "platform.supportEmail";
    private static final String KEY_PLATFORM_TIMEZONE = "platform.timezone";
    private static final String KEY_SECURITY_SESSION_TIMEOUT = "security.sessionTimeoutMinutes";
    private static final String KEY_SECURITY_MIN_PASSWORD_LENGTH = "security.minPasswordLength";
    private static final String KEY_PAYMENT_MODE = "payment.mode";
    private static final String KEY_PAYMENT_CURRENCY = "payment.currency";
    private static final String KEY_PAYMENT_PAYSTACK_PUBLIC = "payment.paystackPublicKey";
    private static final String KEY_PAYMENT_PAYSTACK_SECRET = "payment.paystackSecretKey";
    private static final String KEY_PAYMENT_PAYSTACK_WEBHOOK = "payment.paystackWebhookSecret";
    private static final String KEY_PAYMENT_CALLBACK_URL = "payment.callbackUrl";
    private static final String KEY_SMTP_HOST = "email.smtp.host";
    private static final String KEY_SMTP_PORT = "email.smtp.port";
    private static final String KEY_SMTP_USERNAME = "email.smtp.username";
    private static final String KEY_SMTP_PASSWORD = "email.smtp.password";
    private static final String KEY_SMTP_FROM_EMAIL = "email.from.email";
    private static final String KEY_SMTP_FROM_NAME = "email.from.name";
    private static final String KEY_SMTP_STARTTLS = "email.smtp.starttls";
    private static final String KEY_ENROLLMENT_AUTO_ACTIVATE = "enrollment.autoActivateOnPayment";
    private static final String KEY_LEARNING_COMPLETION_PERCENT = "learning.completionMaterialPercent";
    private static final String KEY_ASSESSMENT_PASS_MARK = "assessment.defaultPassMark";
    private static final String KEY_ASSESSMENT_MAX_ATTEMPTS = "assessment.defaultMaxAttempts";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = ensureAdminSession(request);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Map<String, String> settings = mergeWithDefaults(appSettingDAO.findAllAsMap());
        String status = normalize(request.getParameter("status"));
        String successMessage = "saved".equalsIgnoreCase(status) ? "Settings were saved successfully." : null;
        renderPage(request, response, settings, successMessage, null, null);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = ensureAdminSession(request);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Map<String, String> existing = mergeWithDefaults(appSettingDAO.findAllAsMap());
        Map<String, String> input = buildInput(request, existing);
        String action = normalize(request.getParameter("action")).toLowerCase();

        String validationError = validate(input);
        if (validationError != null) {
            renderPage(request, response, mergeWithDefaults(input), null, validationError, null);
            return;
        }

        if ("testsmtp".equals(action)) {
            String smtpError = validateSmtp(input);
            if (smtpError != null) {
                renderPage(request, response, mergeWithDefaults(input), null, smtpError, null);
                return;
            }

            String smtpResult = testSmtpConnection(input)
                    ? "SMTP connection test passed. The server accepted your credentials."
                    : "SMTP connection test failed. Check host/port/credentials and try again.";
            if (smtpResult.startsWith("SMTP connection test passed")) {
                renderPage(request, response, mergeWithDefaults(input), smtpResult, null, null);
            } else {
                renderPage(request, response, mergeWithDefaults(input), null, smtpResult, null);
            }
            return;
        }

        Integer userId = resolveUserId(session);
        if (userId == null) {
            renderPage(request, response, mergeWithDefaults(input), null, "Session error: invalid user context.", null);
            return;
        }
        boolean saved = appSettingDAO.upsertAll(input, userId);
        if (!saved) {
            renderPage(request, response, mergeWithDefaults(input), null, "Unable to save settings right now. Please try again.", null);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/settings?status=saved");
    }

    private void renderPage(HttpServletRequest request,
                            HttpServletResponse response,
                            Map<String, String> settings,
                            String successMessage,
                            String errorMessage,
                            String infoMessage) throws ServletException, IOException {
        List<AppSettingAuditEntry> audits = appSettingDAO.findRecentAudits(20);
        request.setAttribute("settings", settings);
        request.setAttribute("audits", audits);
        request.setAttribute("hasPaystackSecret", !normalize(settings.get(KEY_PAYMENT_PAYSTACK_SECRET)).isEmpty());
        request.setAttribute("hasWebhookSecret", !normalize(settings.get(KEY_PAYMENT_PAYSTACK_WEBHOOK)).isEmpty());
        request.setAttribute("hasSmtpPassword", !normalize(settings.get(KEY_SMTP_PASSWORD)).isEmpty());
        if (successMessage != null) {
            request.setAttribute("successMessage", successMessage);
        }
        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
        }
        if (infoMessage != null) {
            request.setAttribute("infoMessage", infoMessage);
        }
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-settings.jsp").forward(request, response);
    }

    private Map<String, String> buildInput(HttpServletRequest request, Map<String, String> existing) {
        Map<String, String> input = new LinkedHashMap<>();
        input.put(KEY_PLATFORM_NAME, normalize(request.getParameter("platformName")));
        input.put(KEY_PLATFORM_SUPPORT_EMAIL, normalize(request.getParameter("supportEmail")));
        input.put(KEY_PLATFORM_TIMEZONE, normalize(request.getParameter("timezone")));
        input.put(KEY_SECURITY_SESSION_TIMEOUT, normalize(request.getParameter("sessionTimeoutMinutes")));
        input.put(KEY_SECURITY_MIN_PASSWORD_LENGTH, normalize(request.getParameter("minPasswordLength")));
        input.put(KEY_PAYMENT_MODE, normalize(request.getParameter("paymentMode")).toUpperCase());
        input.put(KEY_PAYMENT_CURRENCY, normalize(request.getParameter("paymentCurrency")).toUpperCase());
        input.put(KEY_PAYMENT_PAYSTACK_PUBLIC, normalize(request.getParameter("paystackPublicKey")));
        input.put(KEY_PAYMENT_PAYSTACK_SECRET, preserveSecretIfBlank(request.getParameter("paystackSecretKey"), existing.get(KEY_PAYMENT_PAYSTACK_SECRET)));
        input.put(KEY_PAYMENT_PAYSTACK_WEBHOOK, preserveSecretIfBlank(request.getParameter("paystackWebhookSecret"), existing.get(KEY_PAYMENT_PAYSTACK_WEBHOOK)));
        input.put(KEY_PAYMENT_CALLBACK_URL, normalize(request.getParameter("paymentCallbackUrl")));
        input.put(KEY_SMTP_HOST, normalize(request.getParameter("smtpHost")));
        input.put(KEY_SMTP_PORT, normalize(request.getParameter("smtpPort")));
        input.put(KEY_SMTP_USERNAME, normalize(request.getParameter("smtpUsername")));
        input.put(KEY_SMTP_PASSWORD, preserveSecretIfBlank(request.getParameter("smtpPassword"), existing.get(KEY_SMTP_PASSWORD)));
        input.put(KEY_SMTP_FROM_EMAIL, normalize(request.getParameter("smtpFromEmail")));
        input.put(KEY_SMTP_FROM_NAME, normalize(request.getParameter("smtpFromName")));
        input.put(KEY_SMTP_STARTTLS, "true".equalsIgnoreCase(normalize(request.getParameter("smtpStartTls"))) ? "true" : "false");
        input.put(KEY_ENROLLMENT_AUTO_ACTIVATE, "true".equalsIgnoreCase(normalize(request.getParameter("autoActivateEnrollment"))) ? "true" : "false");
        input.put(KEY_LEARNING_COMPLETION_PERCENT, normalize(request.getParameter("completionMaterialPercent")));
        input.put(KEY_ASSESSMENT_PASS_MARK, normalize(request.getParameter("defaultPassMark")));
        input.put(KEY_ASSESSMENT_MAX_ATTEMPTS, normalize(request.getParameter("defaultMaxAttempts")));
        return input;
    }

    private String preserveSecretIfBlank(String submitted, String existing) {
        String normalized = normalize(submitted);
        if (!normalized.isEmpty()) {
            return normalized;
        }
        return normalize(existing);
    }

    private HttpSession ensureAdminSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || !"Admin".equals(session.getAttribute("userRole"))) {
            return null;
        }
        return session;
    }

    private Map<String, String> defaults() {
        Map<String, String> defaults = new LinkedHashMap<>();
        defaults.put(KEY_PLATFORM_NAME, "PSM E-Learning Platform");
        defaults.put(KEY_PLATFORM_SUPPORT_EMAIL, "support@psm-elearning.com");
        defaults.put(KEY_PLATFORM_TIMEZONE, "Africa/Lagos");
        defaults.put(KEY_SECURITY_SESSION_TIMEOUT, "30");
        defaults.put(KEY_SECURITY_MIN_PASSWORD_LENGTH, "8");
        defaults.put(KEY_PAYMENT_MODE, "LIVE");
        defaults.put(KEY_PAYMENT_CURRENCY, "NGN");
        defaults.put(KEY_PAYMENT_PAYSTACK_PUBLIC, "");
        defaults.put(KEY_PAYMENT_PAYSTACK_SECRET, "");
        defaults.put(KEY_PAYMENT_PAYSTACK_WEBHOOK, "");
        defaults.put(KEY_PAYMENT_CALLBACK_URL, "");
        defaults.put(KEY_SMTP_HOST, "");
        defaults.put(KEY_SMTP_PORT, "587");
        defaults.put(KEY_SMTP_USERNAME, "");
        defaults.put(KEY_SMTP_PASSWORD, "");
        defaults.put(KEY_SMTP_FROM_EMAIL, "");
        defaults.put(KEY_SMTP_FROM_NAME, "PSM E-Learning Platform");
        defaults.put(KEY_SMTP_STARTTLS, "true");
        defaults.put(KEY_ENROLLMENT_AUTO_ACTIVATE, "true");
        defaults.put(KEY_LEARNING_COMPLETION_PERCENT, "100");
        defaults.put(KEY_ASSESSMENT_PASS_MARK, "70");
        defaults.put(KEY_ASSESSMENT_MAX_ATTEMPTS, "3");
        return defaults;
    }

    private Map<String, String> mergeWithDefaults(Map<String, String> values) {
        Map<String, String> merged = defaults();
        if (values == null) {
            return merged;
        }
        for (Map.Entry<String, String> entry : values.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().trim().isEmpty()) {
                merged.put(entry.getKey(), entry.getValue().trim());
            }
        }
        return merged;
    }

    private String validate(Map<String, String> input) {
        if (input.get(KEY_PLATFORM_NAME).isEmpty()) {
            return "Platform name is required.";
        }
        if (input.get(KEY_PLATFORM_SUPPORT_EMAIL).isEmpty() || !input.get(KEY_PLATFORM_SUPPORT_EMAIL).contains("@")) {
            return "Please provide a valid support email address.";
        }
        if (input.get(KEY_PLATFORM_TIMEZONE).isEmpty()) {
            return "Timezone is required.";
        }
        if (!"LIVE".equals(input.get(KEY_PAYMENT_MODE)) && !"TEST".equals(input.get(KEY_PAYMENT_MODE))) {
            return "Payment mode must be LIVE or TEST.";
        }

        if ("LIVE".equals(input.get(KEY_PAYMENT_MODE)) && input.get(KEY_PAYMENT_PAYSTACK_WEBHOOK).isEmpty()) {
            return "Paystack webhook secret is required in LIVE payment mode.";
        }

        if (input.get(KEY_PAYMENT_CURRENCY).isEmpty()) {
            return "Payment currency is required.";
        }
        String callbackUrl = input.get(KEY_PAYMENT_CALLBACK_URL);
        if (!callbackUrl.isEmpty() && !(callbackUrl.startsWith("http://") || callbackUrl.startsWith("https://"))) {
            return "Payment callback URL must start with http:// or https://.";
        }

        String paystackPublic = input.get(KEY_PAYMENT_PAYSTACK_PUBLIC);
        if (!paystackPublic.isEmpty() && !paystackPublic.startsWith("pk_")) {
            return "Paystack public key must start with pk_.";
        }
        String paystackSecret = input.get(KEY_PAYMENT_PAYSTACK_SECRET);
        if (!paystackSecret.isEmpty() && !paystackSecret.startsWith("sk_")) {
            return "Paystack secret key must start with sk_.";
        }

        Integer sessionTimeout = parseInteger(input.get(KEY_SECURITY_SESSION_TIMEOUT));
        if (sessionTimeout == null || sessionTimeout < 5 || sessionTimeout > 480) {
            return "Session timeout must be between 5 and 480 minutes.";
        }

        Integer minPasswordLength = parseInteger(input.get(KEY_SECURITY_MIN_PASSWORD_LENGTH));
        if (minPasswordLength == null || minPasswordLength < 6 || minPasswordLength > 64) {
            return "Minimum password length must be between 6 and 64.";
        }

        Integer completionPercent = parseInteger(input.get(KEY_LEARNING_COMPLETION_PERCENT));
        if (completionPercent == null || completionPercent < 1 || completionPercent > 100) {
            return "Material completion threshold must be between 1 and 100.";
        }

        Integer passMark = parseInteger(input.get(KEY_ASSESSMENT_PASS_MARK));
        if (passMark == null || passMark < 1 || passMark > 100) {
            return "Default pass mark must be between 1 and 100.";
        }

        Integer attempts = parseInteger(input.get(KEY_ASSESSMENT_MAX_ATTEMPTS));
        if (attempts == null || attempts < 1 || attempts > 10) {
            return "Default max attempts must be between 1 and 10.";
        }

        String smtpValidation = validateSmtp(input);
        if (smtpValidation != null) {
            return smtpValidation;
        }

        return null;
    }

    private String validateSmtp(Map<String, String> input) {
        String smtpHost = input.get(KEY_SMTP_HOST);
        String smtpPort = input.get(KEY_SMTP_PORT);
        String smtpUsername = input.get(KEY_SMTP_USERNAME);
        String smtpPassword = input.get(KEY_SMTP_PASSWORD);
        String fromEmail = input.get(KEY_SMTP_FROM_EMAIL);

        boolean smtpConfigured = !smtpHost.isEmpty() || !smtpPort.isEmpty() || !smtpUsername.isEmpty() || !smtpPassword.isEmpty();
        if (!smtpConfigured) {
            return null;
        }

        if (smtpHost.isEmpty()) {
            return "SMTP host is required when email settings are configured.";
        }
        Integer port = parseInteger(smtpPort);
        if (port == null || port < 1 || port > 65535) {
            return "SMTP port must be between 1 and 65535.";
        }
        if (smtpUsername.isEmpty()) {
            return "SMTP username is required when email settings are configured.";
        }
        if (smtpPassword.isEmpty()) {
            return "SMTP password is required when email settings are configured.";
        }
        if (fromEmail.isEmpty() || !fromEmail.contains("@")) {
            return "A valid SMTP from-email is required when email settings are configured.";
        }

        return null;
    }

    private boolean testSmtpConnection(Map<String, String> input) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", input.get(KEY_SMTP_HOST));
            props.put("mail.smtp.port", input.get(KEY_SMTP_PORT));
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", input.get(KEY_SMTP_STARTTLS));
            props.put("mail.smtp.starttls.required", input.get(KEY_SMTP_STARTTLS));
            props.put("mail.smtp.connectiontimeout", "8000");
            props.put("mail.smtp.timeout", "8000");

            final String username = input.get(KEY_SMTP_USERNAME);
            final String password = input.get(KEY_SMTP_PASSWORD);
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });

            Transport transport = session.getTransport("smtp");
            try {
                transport.connect();
            } finally {
                transport.close();
            }
            return true;
        } catch (MessagingException e) {
            return false;
        }
    }

    private Integer parseInteger(String value) {
        try {
            return Integer.parseInt(normalize(value));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private Integer resolveUserId(HttpSession session) {
        if (session == null) return null;
        Object userId = session.getAttribute("userId");
        if (userId == null) return null;
        
        if (userId instanceof Integer) {
            int id = (Integer) userId;
            return id > 0 ? id : null;
        }
        
        if (userId instanceof String) {
            try {
                int id = Integer.parseInt((String) userId);
                return id > 0 ? id : null;
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
}
