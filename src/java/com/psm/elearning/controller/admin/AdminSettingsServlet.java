package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.AppSettingDAO;
import com.psm.elearning.dao.AppSettingDAOImpl;
import com.psm.elearning.model.AppSettingAuditEntry;
import com.psm.elearning.util.SessionUtil;

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
import org.json.JSONObject;
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
    private static final String KEY_YOUTUBE_API_KEY = "platform.youtubeApiKey";
    private static final String KEY_MAX_FILE_UPLOAD_MB = "platform.maxFileUploadMB";
    private static final String KEY_CERTIFICATE_ENABLED = "platform.certificateEnabled";
    private static final String KEY_PAYMENT_PAYSTACK_ENABLED = "payment.paystack.enabled";
    private static final String KEY_PAYMENT_MONIEPOINT_ENABLED = "payment.moniepoint.enabled";
    private static final String KEY_PAYMENT_MONIEPOINT_CLIENT_ID = "payment.moniepointClientId";
    private static final String KEY_PAYMENT_MONIEPOINT_SECRET = "payment.moniepointSecretKey";
    private static final String KEY_CLOUDINARY_CLOUD_NAME = "cloudinary.cloudName";
    private static final String KEY_CLOUDINARY_API_KEY = "cloudinary.apiKey";
    private static final String KEY_CLOUDINARY_API_SECRET = "cloudinary.apiSecret";
    private static final String KEY_CLOUDINARY_FOLDER_PASSPORTS = "cloudinary.folderPassports";
    private static final String KEY_CLOUDINARY_FOLDER_MATERIALS = "cloudinary.folderMaterials";
    private static final String KEY_CLOUDINARY_FOLDER_CERTIFICATES = "cloudinary.folderCertificates";
    private static final String KEY_CLOUDINARY_FOLDER_COURSE_BANNERS = "cloudinary.folderCourseBanners";
    private static final String KEY_PLATFORM_DEFAULT_INSTRUCTOR_COMMISSION = "platform.defaultInstructorCommission";
    private static final String KEY_PLATFORM_AUTO_APPROVE_COURSES = "platform.autoApproveCourses";


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
        boolean isJson = request.getContentType() != null && request.getContentType().contains("application/json");

        if (session == null) {
            if (isJson) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\":false,\"message\":\"Session expired. Please log in again.\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return;
        }

        JSONObject json = null;
        if (isJson) {
            StringBuilder sb = new StringBuilder();
            String line;
            try (java.io.BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            } catch (Exception e) {
                // ignore
            }
            try {
                json = new JSONObject(sb.toString());
            } catch (Exception e) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid JSON payload.\"}");
                return;
            }
        }

        Map<String, String> existing = mergeWithDefaults(appSettingDAO.findAllAsMap());
        Map<String, String> input = buildInput(request, json, existing);
        String action = getVal(request, json, "action", "action").toLowerCase();

        String validationError = validate(input);
        if (validationError != null) {
            if (isJson) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JSONObject respObj = new JSONObject();
                respObj.put("success", false);
                respObj.put("message", validationError);
                response.getWriter().write(respObj.toString());
            } else {
                renderPage(request, response, mergeWithDefaults(input), null, validationError, null);
            }
            return;
        }

        if ("testsmtp".equals(action)) {
            String smtpError = validateSmtp(input);
            if (smtpError != null) {
                if (isJson) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    JSONObject respObj = new JSONObject();
                    respObj.put("success", false);
                    respObj.put("message", smtpError);
                    response.getWriter().write(respObj.toString());
                } else {
                    renderPage(request, response, mergeWithDefaults(input), null, smtpError, null);
                }
                return;
            }

            boolean success = testSmtpConnection(input);
            String smtpResult = success
                    ? "SMTP connection test passed. The server accepted your credentials."
                    : "SMTP connection test failed. Check host/port/credentials and try again.";
            
            if (isJson) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                if (!success) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                }
                JSONObject respObj = new JSONObject();
                respObj.put("success", success);
                respObj.put("message", smtpResult);
                response.getWriter().write(respObj.toString());
            } else {
                if (success) {
                    renderPage(request, response, mergeWithDefaults(input), smtpResult, null, null);
                } else {
                    renderPage(request, response, mergeWithDefaults(input), null, smtpResult, null);
                }
            }
            return;
        }

        Integer userId = resolveUserId(session);
        if (userId == null) {
            if (isJson) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\":false,\"message\":\"Session error: invalid user context.\"}");
            } else {
                renderPage(request, response, mergeWithDefaults(input), null, "Session error: invalid user context.", null);
            }
            return;
        }

        boolean saved = appSettingDAO.upsertAll(input, userId);
        if (saved) {
            com.psm.elearning.service.AppSettingsService.clearCache();
        }
        if (!saved) {
            if (isJson) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"message\":\"Unable to save settings right now. Please try again.\"}");
            } else {
                renderPage(request, response, mergeWithDefaults(input), null, "Unable to save settings right now. Please try again.", null);
            }
            return;
        }

        if (isJson) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":true,\"message\":\"Settings were saved successfully.\"}");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/settings?status=saved");
        }
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
        request.setAttribute("hasCloudinarySecret", !normalize(settings.get(KEY_CLOUDINARY_API_SECRET)).isEmpty());
        request.setAttribute("hasMoniepointSecret", !normalize(settings.get(KEY_PAYMENT_MONIEPOINT_SECRET)).isEmpty());
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

    private String getVal(HttpServletRequest request, JSONObject json, String jsonKey, String paramName) {
        if (json != null && json.has(jsonKey)) {
            Object val = json.get(jsonKey);
            if (val == null) {
                return "";
            }
            if (val instanceof Boolean) {
                return String.valueOf(val);
            }
            return val.toString().trim();
        }
        return normalize(request.getParameter(paramName));
    }

    private Map<String, String> buildInput(HttpServletRequest request, JSONObject json, Map<String, String> existing) {
        Map<String, String> input = new LinkedHashMap<>();
        input.put(KEY_PLATFORM_NAME, getVal(request, json, "platformName", "platformName"));
        input.put(KEY_PLATFORM_SUPPORT_EMAIL, getVal(request, json, "supportEmail", "supportEmail"));
        input.put(KEY_PLATFORM_TIMEZONE, getVal(request, json, "timezone", "timezone"));
        input.put(KEY_SECURITY_SESSION_TIMEOUT, getVal(request, json, "sessionTimeoutMinutes", "sessionTimeoutMinutes"));
        input.put(KEY_SECURITY_MIN_PASSWORD_LENGTH, getVal(request, json, "minPasswordLength", "minPasswordLength"));
        input.put(KEY_PAYMENT_MODE, getVal(request, json, "paymentMode", "paymentMode").toUpperCase());
        input.put(KEY_PAYMENT_CURRENCY, getVal(request, json, "paymentCurrency", "paymentCurrency").toUpperCase());
        input.put(KEY_PAYMENT_PAYSTACK_PUBLIC, getVal(request, json, "paystackPublicKey", "paystackPublicKey"));
        input.put(KEY_PAYMENT_PAYSTACK_SECRET, preserveSecretIfBlank(getVal(request, json, "paystackSecretKey", "paystackSecretKey"), existing.get(KEY_PAYMENT_PAYSTACK_SECRET)));
        input.put(KEY_PAYMENT_PAYSTACK_WEBHOOK, preserveSecretIfBlank(getVal(request, json, "paystackWebhookSecret", "paystackWebhookSecret"), existing.get(KEY_PAYMENT_PAYSTACK_WEBHOOK)));
        input.put(KEY_PAYMENT_CALLBACK_URL, getVal(request, json, "paymentCallbackUrl", "paymentCallbackUrl"));
        input.put(KEY_SMTP_HOST, getVal(request, json, "smtpHost", "smtpHost"));
        input.put(KEY_SMTP_PORT, getVal(request, json, "smtpPort", "smtpPort"));
        input.put(KEY_SMTP_USERNAME, getVal(request, json, "smtpUsername", "smtpUsername"));
        input.put(KEY_SMTP_PASSWORD, preserveSecretIfBlank(getVal(request, json, "smtpPassword", "smtpPassword"), existing.get(KEY_SMTP_PASSWORD)));
        input.put(KEY_SMTP_FROM_EMAIL, getVal(request, json, "smtpFromEmail", "smtpFromEmail"));
        input.put(KEY_SMTP_FROM_NAME, getVal(request, json, "smtpFromName", "smtpFromName"));
        input.put(KEY_SMTP_STARTTLS, "true".equalsIgnoreCase(getVal(request, json, "smtpStartTls", "smtpStartTls")) ? "true" : "false");
        input.put(KEY_ENROLLMENT_AUTO_ACTIVATE, "true".equalsIgnoreCase(getVal(request, json, "autoActivateEnrollment", "autoActivateEnrollment")) ? "true" : "false");
        input.put(KEY_LEARNING_COMPLETION_PERCENT, getVal(request, json, "completionMaterialPercent", "completionMaterialPercent"));
        input.put(KEY_ASSESSMENT_PASS_MARK, getVal(request, json, "defaultPassMark", "defaultPassMark"));
        input.put(KEY_ASSESSMENT_MAX_ATTEMPTS, getVal(request, json, "defaultMaxAttempts", "defaultMaxAttempts"));
        input.put(KEY_YOUTUBE_API_KEY, getVal(request, json, "youtubeApiKey", "youtubeApiKey"));
        input.put(KEY_MAX_FILE_UPLOAD_MB, getVal(request, json, "maxFileUploadMB", "maxFileUploadMB"));
        input.put(KEY_CERTIFICATE_ENABLED, "true".equalsIgnoreCase(getVal(request, json, "certificateEnabled", "certificateEnabled")) ? "true" : "false");
        
        input.put(KEY_PAYMENT_PAYSTACK_ENABLED, "true".equalsIgnoreCase(getVal(request, json, "paystackEnabled", "paystackEnabled")) ? "true" : "false");
        input.put(KEY_PAYMENT_MONIEPOINT_ENABLED, "true".equalsIgnoreCase(getVal(request, json, "moniepointEnabled", "moniepointEnabled")) ? "true" : "false");
        input.put(KEY_PAYMENT_MONIEPOINT_CLIENT_ID, getVal(request, json, "moniepointClientId", "moniepointClientId"));
        input.put(KEY_PAYMENT_MONIEPOINT_SECRET, preserveSecretIfBlank(getVal(request, json, "moniepointSecretKey", "moniepointSecretKey"), existing.get(KEY_PAYMENT_MONIEPOINT_SECRET)));
        
        input.put(KEY_CLOUDINARY_CLOUD_NAME, getVal(request, json, "cloudinaryCloudName", "cloudinaryCloudName"));
        input.put(KEY_CLOUDINARY_API_KEY, getVal(request, json, "cloudinaryApiKey", "cloudinaryApiKey"));
        input.put(KEY_CLOUDINARY_API_SECRET, preserveSecretIfBlank(getVal(request, json, "cloudinaryApiSecret", "cloudinaryApiSecret"), existing.get(KEY_CLOUDINARY_API_SECRET)));
        input.put(KEY_CLOUDINARY_FOLDER_PASSPORTS, getVal(request, json, "cloudinaryFolderPassports", "cloudinaryFolderPassports"));
        input.put(KEY_CLOUDINARY_FOLDER_MATERIALS, getVal(request, json, "cloudinaryFolderMaterials", "cloudinaryFolderMaterials"));
        input.put(KEY_CLOUDINARY_FOLDER_CERTIFICATES, getVal(request, json, "cloudinaryFolderCertificates", "cloudinaryFolderCertificates"));
        input.put(KEY_CLOUDINARY_FOLDER_COURSE_BANNERS, getVal(request, json, "cloudinaryFolderCourseBanners", "cloudinaryFolderCourseBanners"));
        
        input.put(KEY_PLATFORM_DEFAULT_INSTRUCTOR_COMMISSION, getVal(request, json, "defaultInstructorCommission", "defaultInstructorCommission"));
        input.put(KEY_PLATFORM_AUTO_APPROVE_COURSES, "true".equalsIgnoreCase(getVal(request, json, "autoApproveCourses", "autoApproveCourses")) ? "true" : "false");
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
        if (SessionUtil.resolveUserId(session) == null || !"Admin".equals(SessionUtil.resolveRole(session))) {
            return null;
        }
        return session;
    }

    private Map<String, String> defaults() {
        Map<String, String> defaults = new LinkedHashMap<>();
        defaults.put(KEY_PLATFORM_NAME, System.getenv("PLATFORM_NAME") != null ? System.getenv("PLATFORM_NAME") : "PSM E-Learning Platform");
        defaults.put(KEY_PLATFORM_SUPPORT_EMAIL, System.getenv("PLATFORM_SUPPORT_EMAIL") != null ? System.getenv("PLATFORM_SUPPORT_EMAIL") : "support@psm-elearning.com");
        defaults.put(KEY_PLATFORM_TIMEZONE, System.getenv("PLATFORM_TIMEZONE") != null ? System.getenv("PLATFORM_TIMEZONE") : "Africa/Lagos");
        defaults.put(KEY_SECURITY_SESSION_TIMEOUT, System.getenv("SECURITY_SESSION_TIMEOUT") != null ? System.getenv("SECURITY_SESSION_TIMEOUT") : "30");
        defaults.put(KEY_SECURITY_MIN_PASSWORD_LENGTH, System.getenv("SECURITY_MIN_PASSWORD_LENGTH") != null ? System.getenv("SECURITY_MIN_PASSWORD_LENGTH") : "8");
        defaults.put(KEY_PAYMENT_MODE, System.getenv("PAYMENT_MODE") != null ? System.getenv("PAYMENT_MODE") : "LIVE");
        defaults.put(KEY_PAYMENT_CURRENCY, System.getenv("PAYSTACK_CURRENCY") != null ? System.getenv("PAYSTACK_CURRENCY") : "NGN");
        defaults.put(KEY_PAYMENT_PAYSTACK_PUBLIC, System.getenv("PAYSTACK_PUBLIC_KEY") != null ? System.getenv("PAYSTACK_PUBLIC_KEY") : "");
        defaults.put(KEY_PAYMENT_PAYSTACK_SECRET, System.getenv("PAYSTACK_SECRET_KEY") != null ? System.getenv("PAYSTACK_SECRET_KEY") : "");
        defaults.put(KEY_PAYMENT_PAYSTACK_WEBHOOK, System.getenv("PAYSTACK_WEBHOOK_SECRET") != null ? System.getenv("PAYSTACK_WEBHOOK_SECRET") : "");
        defaults.put(KEY_PAYMENT_CALLBACK_URL, System.getenv("PAYSTACK_CALLBACK_URL") != null ? System.getenv("PAYSTACK_CALLBACK_URL") : "");
        defaults.put(KEY_SMTP_HOST, System.getenv("SMTP_HOST") != null ? System.getenv("SMTP_HOST") : "");
        defaults.put(KEY_SMTP_PORT, System.getenv("SMTP_PORT") != null ? System.getenv("SMTP_PORT") : "587");
        defaults.put(KEY_SMTP_USERNAME, System.getenv("SMTP_USERNAME") != null ? System.getenv("SMTP_USERNAME") : "");
        defaults.put(KEY_SMTP_PASSWORD, System.getenv("SMTP_PASSWORD") != null ? System.getenv("SMTP_PASSWORD") : "");
        defaults.put(KEY_SMTP_FROM_EMAIL, System.getenv("SMTP_FROM_EMAIL") != null ? System.getenv("SMTP_FROM_EMAIL") : "");
        defaults.put(KEY_SMTP_FROM_NAME, System.getenv("SMTP_FROM_NAME") != null ? System.getenv("SMTP_FROM_NAME") : "PSM E-Learning Platform");
        defaults.put(KEY_SMTP_STARTTLS, System.getenv("SMTP_STARTTLS") != null ? System.getenv("SMTP_STARTTLS") : "true");
        defaults.put(KEY_ENROLLMENT_AUTO_ACTIVATE, "true");
        defaults.put(KEY_LEARNING_COMPLETION_PERCENT, "100");
        defaults.put(KEY_ASSESSMENT_PASS_MARK, "70");
        defaults.put(KEY_ASSESSMENT_MAX_ATTEMPTS, "3");
        defaults.put(KEY_YOUTUBE_API_KEY, System.getenv("YOUTUBE_API_KEY") != null ? System.getenv("YOUTUBE_API_KEY") : "");
        defaults.put(KEY_MAX_FILE_UPLOAD_MB, "50");
        defaults.put(KEY_CERTIFICATE_ENABLED, "true");
        defaults.put(KEY_PAYMENT_PAYSTACK_ENABLED, "true");
        defaults.put(KEY_PAYMENT_MONIEPOINT_ENABLED, "false");
        defaults.put(KEY_PAYMENT_MONIEPOINT_CLIENT_ID, System.getenv("MONIEPOINT_CLIENT_ID") != null ? System.getenv("MONIEPOINT_CLIENT_ID") : "");
        defaults.put(KEY_PAYMENT_MONIEPOINT_SECRET, System.getenv("MONIEPOINT_SECRET_KEY") != null ? System.getenv("MONIEPOINT_SECRET_KEY") : "");
        defaults.put(KEY_CLOUDINARY_CLOUD_NAME, System.getenv("CLOUDINARY_CLOUD_NAME") != null ? System.getenv("CLOUDINARY_CLOUD_NAME") : "");
        defaults.put(KEY_CLOUDINARY_API_KEY, System.getenv("CLOUDINARY_API_KEY") != null ? System.getenv("CLOUDINARY_API_KEY") : "");
        defaults.put(KEY_CLOUDINARY_API_SECRET, System.getenv("CLOUDINARY_API_SECRET") != null ? System.getenv("CLOUDINARY_API_SECRET") : "");
        defaults.put(KEY_CLOUDINARY_FOLDER_PASSPORTS, System.getenv("CLOUDINARY_FOLDER_PASSPORTS") != null ? System.getenv("CLOUDINARY_FOLDER_PASSPORTS") : "psm/passports");
        defaults.put(KEY_CLOUDINARY_FOLDER_MATERIALS, System.getenv("CLOUDINARY_FOLDER_MATERIALS") != null ? System.getenv("CLOUDINARY_FOLDER_MATERIALS") : "psm/materials");
        defaults.put(KEY_CLOUDINARY_FOLDER_CERTIFICATES, System.getenv("CLOUDINARY_FOLDER_CERTIFICATES") != null ? System.getenv("CLOUDINARY_FOLDER_CERTIFICATES") : "psm/certificates");
        defaults.put(KEY_CLOUDINARY_FOLDER_COURSE_BANNERS, System.getenv("CLOUDINARY_FOLDER_COURSE_BANNERS") != null ? System.getenv("CLOUDINARY_FOLDER_COURSE_BANNERS") : "psm/course-banners");
        defaults.put(KEY_PLATFORM_DEFAULT_INSTRUCTOR_COMMISSION, System.getenv("DEFAULT_INSTRUCTOR_COMMISSION") != null ? System.getenv("DEFAULT_INSTRUCTOR_COMMISSION") : "20");
        defaults.put(KEY_PLATFORM_AUTO_APPROVE_COURSES, "false");
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

        String cloudNameVal = input.get(KEY_CLOUDINARY_CLOUD_NAME);
        String apiKeyVal = input.get(KEY_CLOUDINARY_API_KEY);
        String apiSecretVal = input.get(KEY_CLOUDINARY_API_SECRET);
        boolean anyCloudinary = !cloudNameVal.isEmpty() || !apiKeyVal.isEmpty() || !apiSecretVal.isEmpty();
        if (anyCloudinary) {
            if (cloudNameVal.isEmpty()) {
                return "Cloudinary Cloud Name is required when configuring Cloudinary.";
            }
            if (apiKeyVal.isEmpty()) {
                return "Cloudinary API Key is required when configuring Cloudinary.";
            }
            if (apiSecretVal.isEmpty()) {
                return "Cloudinary API Secret is required when configuring Cloudinary.";
            }
        }


        Integer commission = parseInteger(input.get(KEY_PLATFORM_DEFAULT_INSTRUCTOR_COMMISSION));
        if (commission == null || commission < 0 || commission > 100) {
            return "Default instructor commission must be a valid percentage between 0 and 100.";
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
            String port = input.get(KEY_SMTP_PORT);
            props.put("mail.smtp.port", port);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", input.get(KEY_SMTP_STARTTLS));
            props.put("mail.smtp.starttls.required", input.get(KEY_SMTP_STARTTLS));
            props.put("mail.smtp.connectiontimeout", "8000");
            props.put("mail.smtp.timeout", "8000");

            if ("465".equals(port)) {
                props.put("mail.smtp.socketFactory.port", port);
                props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
                props.put("mail.smtp.ssl.enable", "true");
            }

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
