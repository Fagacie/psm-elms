package com.psm.elearning.service;

import com.psm.elearning.dao.AppSettingDAO;
import com.psm.elearning.dao.AppSettingDAOImpl;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Small runtime helper for reading admin-configurable settings with safe defaults.
 */
public final class AppSettingsService {

    public static final String KEY_SECURITY_SESSION_TIMEOUT = "security.sessionTimeoutMinutes";
    public static final String KEY_SECURITY_MIN_PASSWORD_LENGTH = "security.minPasswordLength";
    public static final String KEY_PAYMENT_MODE = "payment.mode";
    public static final String KEY_PAYMENT_CURRENCY = "payment.currency";
    public static final String KEY_PAYMENT_PAYSTACK_PUBLIC = "payment.paystackPublicKey";
    public static final String KEY_PAYMENT_PAYSTACK_SECRET = "payment.paystackSecretKey";
    public static final String KEY_PAYMENT_PAYSTACK_WEBHOOK = "payment.paystackWebhookSecret";
    public static final String KEY_PAYMENT_CALLBACK_URL = "payment.callbackUrl";
    public static final String KEY_ENROLLMENT_AUTO_ACTIVATE = "enrollment.autoActivateOnPayment";
    public static final String KEY_LEARNING_COMPLETION_PERCENT = "learning.completionMaterialPercent";
    public static final String KEY_ASSESSMENT_PASS_MARK = "assessment.defaultPassMark";
    public static final String KEY_ASSESSMENT_MAX_ATTEMPTS = "assessment.defaultMaxAttempts";

    private static final AppSettingDAO APP_SETTING_DAO = new AppSettingDAOImpl();

    private AppSettingsService() {
    }

    public static Map<String, String> getSettings() {
        Map<String, String> merged = defaults();
        try {
            Map<String, String> persisted = APP_SETTING_DAO.findAllAsMap();
            if (persisted != null) {
                for (Map.Entry<String, String> entry : persisted.entrySet()) {
                    if (entry.getValue() != null && !entry.getValue().trim().isEmpty()) {
                        merged.put(entry.getKey(), entry.getValue().trim());
                    }
                }
            }
        } catch (Exception ignored) {
            // Fall back to defaults to keep the app available.
        }
        return merged;
    }

    public static String getString(String key, String fallback) {
        String value = getSettings().get(key);
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    public static int getInt(String key, int fallback, int min, int max) {
        try {
            int value = Integer.parseInt(getString(key, String.valueOf(fallback)));
            if (value < min || value > max) {
                return fallback;
            }
            return value;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    public static boolean getBoolean(String key, boolean fallback) {
        String value = getString(key, fallback ? "true" : "false");
        if ("true".equalsIgnoreCase(value)) {
            return true;
        }
        if ("false".equalsIgnoreCase(value)) {
            return false;
        }
        return fallback;
    }

    private static Map<String, String> defaults() {
        Map<String, String> defaults = new LinkedHashMap<>();
        defaults.put(KEY_SECURITY_SESSION_TIMEOUT, System.getenv("SECURITY_SESSION_TIMEOUT") != null ? System.getenv("SECURITY_SESSION_TIMEOUT") : "30");
        defaults.put(KEY_SECURITY_MIN_PASSWORD_LENGTH, System.getenv("SECURITY_MIN_PASSWORD_LENGTH") != null ? System.getenv("SECURITY_MIN_PASSWORD_LENGTH") : "8");
        defaults.put(KEY_PAYMENT_MODE, System.getenv("PAYMENT_MODE") != null ? System.getenv("PAYMENT_MODE") : "LIVE");
        defaults.put(KEY_PAYMENT_CURRENCY, System.getenv("PAYSTACK_CURRENCY") != null ? System.getenv("PAYSTACK_CURRENCY") : "NGN");
        defaults.put(KEY_PAYMENT_PAYSTACK_PUBLIC, System.getenv("PAYSTACK_PUBLIC_KEY") != null ? System.getenv("PAYSTACK_PUBLIC_KEY") : "");
        defaults.put(KEY_PAYMENT_PAYSTACK_SECRET, System.getenv("PAYSTACK_SECRET_KEY") != null ? System.getenv("PAYSTACK_SECRET_KEY") : "");
        defaults.put(KEY_PAYMENT_PAYSTACK_WEBHOOK, System.getenv("PAYSTACK_WEBHOOK_SECRET") != null ? System.getenv("PAYSTACK_WEBHOOK_SECRET") : "");
        defaults.put(KEY_PAYMENT_CALLBACK_URL, System.getenv("PAYSTACK_CALLBACK_URL") != null ? System.getenv("PAYSTACK_CALLBACK_URL") : "");
        defaults.put(KEY_ENROLLMENT_AUTO_ACTIVATE, "true");
        defaults.put(KEY_LEARNING_COMPLETION_PERCENT, "100");
        defaults.put(KEY_ASSESSMENT_PASS_MARK, "70");
        defaults.put(KEY_ASSESSMENT_MAX_ATTEMPTS, "3");
        return defaults;
    }
}
