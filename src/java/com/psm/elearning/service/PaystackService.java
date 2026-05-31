package com.psm.elearning.service;

import com.psm.elearning.model.Payment;
import org.json.JSONObject;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Paystack Payment Gateway Service
 * Handles payment initialization and verification with Paystack API
 */
public class PaystackService {

    private static final Logger LOGGER = Logger.getLogger(PaystackService.class.getName());
    
    private String secretKey;
    private String publicKey;
    private String apiUrl;
    private String currency;
    private String callbackUrl;
    private String paymentMode;
    
    public PaystackService() {
        loadConfiguration();
    }

    private String readConfig(Properties props, String key, String envKey, String defaultValue) {
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.trim().isEmpty()) {
            return envValue.trim();
        }
        String propValue = props.getProperty(key, defaultValue);
        return propValue == null ? "" : propValue.trim();
    }

    private boolean isPlaceholderKey(String value) {
        if (value == null) {
            return true;
        }
        String normalized = value.trim().toLowerCase();
        return normalized.isEmpty()
                || normalized.contains("your_secret_key_here")
                || normalized.contains("your_public_key_here")
                || normalized.contains("replace_with")
                || normalized.contains("changeme");
    }
    
    /**
     * Load Paystack configuration from properties file
     */
    private void loadConfiguration() {
        // Set defaults first
        this.secretKey = "sk_test_YOUR_SECRET_KEY_HERE";
        this.publicKey = "pk_test_YOUR_PUBLIC_KEY_HERE";
        this.apiUrl = "https://api.paystack.co";
        this.currency = "NGN";
        this.callbackUrl = "http://localhost:8080/PSME/student/payment-callback";
        this.paymentMode = "LIVE";

        Properties props = new Properties();
        try {
            InputStream input = null;
            // Preferred: load from classpath root (src/conf/paystack.properties -> WEB-INF/classes/paystack.properties)
            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            if (cl != null) {
                input = cl.getResourceAsStream("paystack.properties");
            }
            if (input == null) {
                // Fallback: legacy location kept for backward compatibility
                input = getClass().getClassLoader().getResourceAsStream("com/psm/elearning/config/paystack.properties");
            }
            if (input != null) {
                props.load(input);
                LOGGER.info("Loaded configuration properties from paystack.properties");
            } else {
                LOGGER.warning("paystack.properties not found on classpath. Relying on environment variables.");
            }
        } catch (IOException ex) {
            LOGGER.log(Level.SEVERE, "Error loading paystack.properties from classpath", ex);
        }

        // Environment variables override properties, which override defaults
        this.secretKey = readConfig(props, "paystack.secret.key", "PAYSTACK_SECRET_KEY", this.secretKey);
        this.publicKey = readConfig(props, "paystack.public.key", "PAYSTACK_PUBLIC_KEY", this.publicKey);
        this.apiUrl = readConfig(props, "paystack.api.url", "PAYSTACK_API_URL", this.apiUrl);
        this.currency = readConfig(props, "paystack.currency", "PAYSTACK_CURRENCY", this.currency);
        this.callbackUrl = readConfig(props, "paystack.callback.url", "PAYSTACK_CALLBACK_URL", this.callbackUrl);
        this.paymentMode = readConfig(props, "paystack.mode", "PAYSTACK_MODE", this.paymentMode);

        applyAdminOverrides();
        LOGGER.info("Paystack configuration initialized successfully. Mode=" + this.paymentMode + ", API URL=" + this.apiUrl + ", currency=" + this.currency);
    }

    private void applyAdminOverrides() {
        try {
            String configuredMode = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_MODE, this.paymentMode);
            if ("LIVE".equalsIgnoreCase(configuredMode) || "TEST".equalsIgnoreCase(configuredMode)) {
                this.paymentMode = configuredMode.toUpperCase();
            }

            String configuredCurrency = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_CURRENCY, this.currency);
            if (!configuredCurrency.isEmpty()) {
                this.currency = configuredCurrency;
            }

            String configuredPublicKey = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_PAYSTACK_PUBLIC, "");
            if (!configuredPublicKey.isEmpty() && configuredPublicKey.startsWith("pk_")) {
                this.publicKey = configuredPublicKey;
            }

            String configuredSecretKey = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_PAYSTACK_SECRET, "");
            if (!configuredSecretKey.isEmpty() && configuredSecretKey.startsWith("sk_")) {
                this.secretKey = configuredSecretKey;
            }

            String configuredCallbackUrl = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_CALLBACK_URL, this.callbackUrl);
            if (!configuredCallbackUrl.isEmpty()) {
                this.callbackUrl = configuredCallbackUrl;
            }

            if ("TEST".equals(this.paymentMode)
                    && ((this.publicKey != null && this.publicKey.startsWith("pk_live_"))
                    || (this.secretKey != null && this.secretKey.startsWith("sk_live_")))) {
                LOGGER.warning("Payment mode is TEST but live Paystack keys are configured.");
            }
            if ("LIVE".equals(this.paymentMode)
                    && ((this.publicKey != null && this.publicKey.startsWith("pk_test_"))
                    || (this.secretKey != null && this.secretKey.startsWith("sk_test_")))) {
                LOGGER.warning("Payment mode is LIVE but test Paystack keys are configured.");
            }
        } catch (Exception ignored) {
            // Keep file/env settings if DB settings are unavailable.
        }
    }
    
    /**
     * Initialize a payment transaction with Paystack
     * @param email Student email
     * @param amount Amount in major currency unit (e.g., 5000 for NGN 50.00)
     * @param enrollmentId Enrollment ID for reference
     * @return Payment object with Paystack details (authorization URL, access code, reference)
     */
    public Payment initializeTransaction(String email, Double amount, int enrollmentId) {
        LOGGER.info("Initializing Paystack transaction for enrollmentId=" + enrollmentId + ", amount=" + amount);
        
        if (apiUrl == null || apiUrl.isEmpty()) {
            throw new RuntimeException("Paystack API URL is not configured");
        }
        
        try {
            // Convert amount to kobo (smallest currency unit) - Paystack expects amount in kobo
            int amountInKobo = (int) (amount * 100);
            
            // Create request payload
            JSONObject payload = new JSONObject();
            payload.put("email", email);
            payload.put("amount", amountInKobo);
            payload.put("currency", this.currency);
            payload.put("callback_url", this.callbackUrl);
            payload.put("metadata", new JSONObject()
                .put("enrollment_id", enrollmentId)
                .put("custom_fields", new org.json.JSONArray()
                    .put(new JSONObject()
                        .put("display_name", "Enrollment ID")
                        .put("variable_name", "enrollment_id")
                        .put("value", enrollmentId)
                    )
                )
            );
            
            // Make API call
            URL url = new URL(apiUrl + "/transaction/initialize");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + secretKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setConnectTimeout(30000); // 30 seconds
            conn.setReadTimeout(30000); // 30 seconds
            conn.setDoOutput(true);
            
            // Send request
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = payload.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            // Read response
            int responseCode = conn.getResponseCode();
            LOGGER.info("Paystack initialize responseCode=" + responseCode + " for enrollmentId=" + enrollmentId);
            
            InputStream responseStream = (responseCode == 200) ? conn.getInputStream() : conn.getErrorStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(responseStream, StandardCharsets.UTF_8));
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            
            String jsonResponse = response.toString();
            
            // Parse response
            JSONObject jsonObject = new JSONObject(jsonResponse);
            
            if (jsonObject.getBoolean("status")) {
                JSONObject data = jsonObject.getJSONObject("data");
                
                String authorizationUrl = data.getString("authorization_url");
                String accessCode = data.getString("access_code");
                String reference = data.getString("reference");

                LOGGER.info("Paystack transaction initialized successfully. reference=" + reference);
                
                // Create Payment object with Paystack details
                Payment payment = new Payment(enrollmentId, amount, reference, accessCode, authorizationUrl);
                return payment;
                
            } else {
                String message = jsonObject.getString("message");
                LOGGER.warning("Paystack initialization failed: " + message);
                throw new RuntimeException("Payment initialization failed: " + message);
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing Paystack transaction", e);
            throw new RuntimeException("Payment initialization error: " + e.getMessage());
        }
    }
    
    /**
     * Verify a payment transaction with Paystack
     * @param reference Paystack transaction reference
     * @return JSONObject with payment details if successful, null if failed
     */
    public JSONObject verifyTransaction(String reference) {
        LOGGER.info("Verifying Paystack transaction for reference=" + reference);
        
        try {
            // Make API call
            URL url = new URL(apiUrl + "/transaction/verify/" + reference);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + secretKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setConnectTimeout(30000); // 30 seconds
            conn.setReadTimeout(30000); // 30 seconds
            
            // Read response
            int responseCode = conn.getResponseCode();
            LOGGER.info("Paystack verify responseCode=" + responseCode + " for reference=" + reference);
            
            InputStream responseStream = (responseCode == 200) ? conn.getInputStream() : conn.getErrorStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(responseStream, StandardCharsets.UTF_8));
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            
            String jsonResponse = response.toString();
            
            // Parse response
            JSONObject jsonObject = new JSONObject(jsonResponse);
            
            if (jsonObject.getBoolean("status")) {
                JSONObject data = jsonObject.getJSONObject("data");
                String status = data.getString("status");

                LOGGER.info("Paystack verification status=" + status + " for reference=" + reference);
                
                // Return data object regardless of status; caller will branch on success/failed/abandoned
                if ("success".equals(status)) {
                    LOGGER.info("Paystack payment verified successfully for reference=" + reference);
                } else {
                    LOGGER.warning("Paystack payment completed with non-success status=" + status + " for reference=" + reference);
                }
                return data;
            } else {
                String message = jsonObject.getString("message");
                LOGGER.warning("Paystack verification failed for reference=" + reference + ": " + message);
                return null;
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error verifying Paystack transaction for reference=" + reference, e);
            return null;
        }
    }
    
    /**
     * Initialize a transaction with externally supplied reference (align internal ref & Paystack ref)
     */
    public Payment initializeTransaction(String email, Double amount, int enrollmentId, String reference) {
        return initializeTransaction(email, amount, enrollmentId, reference, null);
    }

    /**
     * Initialize a transaction with externally supplied reference and optional callback URL override.
     */
    public Payment initializeTransaction(String email,
                                         Double amount,
                                         int enrollmentId,
                                         String reference,
                                         String callbackUrlOverride) {
        LOGGER.info("Initializing Paystack transaction (external reference) enrollmentId=" + enrollmentId + ", reference=" + reference);
        try {
            int amountInKobo = (int) (amount * 100);
            JSONObject payload = new JSONObject();
            payload.put("email", email);
            payload.put("amount", amountInKobo);
            payload.put("currency", this.currency);
            String effectiveCallback = (callbackUrlOverride != null && !callbackUrlOverride.trim().isEmpty())
                    ? callbackUrlOverride.trim()
                    : this.callbackUrl;
            if (effectiveCallback != null && !effectiveCallback.isEmpty()) {
                payload.put("callback_url", effectiveCallback);
            }
            payload.put("reference", reference);
            payload.put("metadata", new JSONObject().put("enrollment_id", enrollmentId));
            
            String fullUrl = apiUrl + "/transaction/initialize";
            URL url = new URL(fullUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + secretKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setConnectTimeout(30000); // 30 seconds
            conn.setReadTimeout(30000); // 30 seconds
            conn.setDoOutput(true);
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = payload.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            int responseCode = conn.getResponseCode();
            InputStream responseStream = (responseCode == 200) ? conn.getInputStream() : conn.getErrorStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(responseStream, StandardCharsets.UTF_8));
            StringBuilder response = new StringBuilder();
            String line; while ((line = br.readLine()) != null) { response.append(line.trim()); }
            LOGGER.info("Paystack initialize (external reference) responseCode=" + responseCode + " for reference=" + reference);
            JSONObject jsonObject = new JSONObject(response.toString());
            if (jsonObject.getBoolean("status")) {
                JSONObject data = jsonObject.getJSONObject("data");
                String authorizationUrl = data.getString("authorization_url");
                String accessCode = data.getString("access_code");
                String refReturned = data.getString("reference");
                LOGGER.info("Paystack transaction initialized (external reference) successfully. reference=" + refReturned);
                Payment payment = new Payment(enrollmentId, amount, refReturned, accessCode, authorizationUrl);
                return payment;
            } else {
                throw new RuntimeException("Payment initialization failed: " + jsonObject.optString("message"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing Paystack transaction with external reference=" + reference, e);
            throw new RuntimeException("Payment initialization error: " + e.getMessage());
        }
    }

    /**
     * Get the public key for client-side integration
     */
    public String getPublicKey() {
        return this.publicKey;
    }
    
    /**
     * Get the configured currency
     */
    public String getCurrency() {
        return this.currency;
    }

    public String getPaymentMode() {
        return this.paymentMode;
    }

    public boolean isConfiguredForPayments() {
        return !isPlaceholderKey(secretKey)
                && !isPlaceholderKey(publicKey)
                && secretKey.startsWith("sk_")
                && publicKey.startsWith("pk_");
    }
}
