package com.psm.elearning.util;

import java.io.OutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * Email Utility for sending emails via Brevo HTTP API (HTTPS/port 443).
 * Uses Brevo's transactional email REST API to bypass all SMTP port
 * restrictions
 * on cloud platforms like Railway.
 *
 * Required environment variables:
 * BREVO_API_KEY — your Brevo v3 API key (starts with "xkeysib-")
 * SMTP_FROM_EMAIL — sender address (defaults to SMTP_USERNAME if not set)
 * SMTP_FROM_NAME — sender display name (optional)
 *
 * @author PSM E-Learning Team
 * @version 2.0
 */
public class EmailUtil {

    private static final String BREVO_API_URL = "https://api.brevo.com/v3/smtp/email";

    private static String BREVO_API_KEY;
    private static String FROM_EMAIL;
    private static String FROM_NAME;

    static {
        loadConfig();
    }

    private static void loadConfig() {
        BREVO_API_KEY = System.getenv("BREVO_API_KEY");
        String fromEmail = System.getenv("SMTP_FROM_EMAIL");
        String smtpUser = System.getenv("SMTP_USERNAME");
        String fromName = System.getenv("SMTP_FROM_NAME");

        FROM_EMAIL = (fromEmail != null && !fromEmail.trim().isEmpty()) ? fromEmail.trim()
                : (smtpUser != null && !smtpUser.trim().isEmpty()) ? smtpUser.trim()
                        : null;
        FROM_NAME = (fromName != null && !fromName.trim().isEmpty()) ? fromName.trim()
                : "PSM E-Learning Platform";

        if (BREVO_API_KEY != null && !BREVO_API_KEY.trim().isEmpty()) {
            System.out.println("[EmailUtil] Mode: Brevo HTTP API. Sender: " + FROM_EMAIL);
        } else {
            System.err.println("[EmailUtil] WARNING: BREVO_API_KEY is missing. Email is DISABLED.");
        }
    }

    /** Escape a string value for safe embedding in a JSON literal. */
    private static String jsonEscape(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    /**
     * Core send method — POSTs to Brevo's transactional email API over HTTPS.
     *
     * @param toEmail  Recipient address
     * @param subject  Email subject
     * @param htmlBody HTML content (use plain text wrapped in &lt;pre&gt; for plain
     *                 text)
     * @param isHtml   true to send as HTML, false for plain text
     * @return true if Brevo accepted the message (2xx response)
     */
    private static boolean sendViaBrevo(String toEmail, String subject, String content, boolean isHtml) {
        loadConfig(); // Always reload to pick up Railway variable changes live

        if (BREVO_API_KEY == null || BREVO_API_KEY.trim().isEmpty()) {
            System.err.println("[EmailUtil] Cannot send email: BREVO_API_KEY env var is missing.");
            return false;
        }
        if (FROM_EMAIL == null || FROM_EMAIL.trim().isEmpty()) {
            System.err.println(
                    "[EmailUtil] Cannot send email: No sender address configured (set SMTP_FROM_EMAIL or SMTP_USERNAME).");
            return false;
        }

        String contentField = isHtml ? "htmlContent" : "textContent";
        String json = "{"
                + "\"sender\":{\"name\":\"" + jsonEscape(FROM_NAME) + "\",\"email\":\"" + jsonEscape(FROM_EMAIL)
                + "\"},"
                + "\"to\":[{\"email\":\"" + jsonEscape(toEmail) + "\"}],"
                + "\"subject\":\"" + jsonEscape(subject) + "\","
                + "\"" + contentField + "\":\"" + jsonEscape(content) + "\""
                + "}";

        try {
            URL url = new URL(BREVO_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("accept", "application/json");
            conn.setRequestProperty("api-key", BREVO_API_KEY.trim());
            conn.setRequestProperty("content-type", "application/json");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(15000);
            conn.setDoOutput(true);

            byte[] payload = json.getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(payload.length);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(payload);
            }

            int status = conn.getResponseCode();
            if (status >= 200 && status < 300) {
                System.out.println("[EmailUtil] Email sent successfully to " + toEmail + " (HTTP " + status + ")");
                return true;
            } else {
                InputStream errStream = conn.getErrorStream();
                String errBody = "";
                if (errStream != null) {
                    errBody = new String(errStream.readAllBytes(), StandardCharsets.UTF_8);
                }
                System.err.println("[EmailUtil] Brevo API error " + status + " sending to " + toEmail + ": " + errBody);
                return false;
            }
        } catch (Exception e) {
            System.err.println("[EmailUtil] Failed to send email to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Sends a plain text email.
     */
    public static boolean sendEmail(String toEmail, String subject, String body) {
        return sendViaBrevo(toEmail, subject, body, false);
    }

    /**
     * Sends an HTML email.
     */
    public static boolean sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        return sendViaBrevo(toEmail, subject, htmlBody, true);
    }

    /**
     * Sends password reset email with temporary password
     * 
     * @param toEmail           Recipient email address
     * @param fullName          User's full name
     * @param temporaryPassword Generated temporary password
     * @return true if email sent successfully
     */
    public static boolean sendPasswordResetEmail(String toEmail, String fullName, String temporaryPassword) {
        String subject = "PSM E-Learning - Password Reset";

        String htmlBody = "<!DOCTYPE html>" +
                "<html><head><style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background-color: #007bff; color: white; padding: 20px; text-align: center; }" +
                ".content { padding: 20px; background-color: #f9f9f9; }" +
                ".password-box { background-color: #fff; padding: 15px; border: 2px solid #007bff; " +
                "font-size: 18px; font-weight: bold; text-align: center; margin: 20px 0; }" +
                ".footer { padding: 20px; text-align: center; font-size: 12px; color: #666; }" +
                "</style></head><body>" +
                "<div class='container'>" +
                "<div class='header'><h2>Password Reset Request</h2></div>" +
                "<div class='content'>" +
                "<p>Dear " + fullName + ",</p>" +
                "<p>You have requested to reset your password. Here is your temporary password:</p>" +
                "<div class='password-box'>" + temporaryPassword + "</div>" +
                "<p><strong>Important:</strong> Please change this password immediately after logging in.</p>" +
                "<p>If you did not request this password reset, please contact our support team immediately.</p>" +
                "</div>" +
                "<div class='footer'>" +
                "<p>&copy; 2025 PSM E-Learning Platform. All rights reserved.</p>" +
                "</div></div></body></html>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Sends registration confirmation email
     * 
     * @param toEmail   Recipient email address
     * @param fullName  User's full name
     * @param regNumber Registration number (for students)
     * @return true if email sent successfully
     */
    public static boolean sendRegistrationEmail(String toEmail, String fullName, String regNumber) {
        String subject = "Welcome to PSM E-Learning Academy! 🎓";

        String htmlBody = "<div style=\"max-width: 600px; margin: 0 auto; font-family: sans-serif; padding: 20px; background-color: #ffffff;\">\n" +
                "  <h1 style=\"color: #0f172a; margin-top: 0; margin-bottom: 8px; font-size: 24px;\">PSM E-Learning Academy</h1>\n" +
                "  <hr style=\"border: none; border-top: 1px solid #e2e8f0; margin-bottom: 24px;\">\n" +
                "  <h2 style=\"color: #0f172a; margin-top: 0; margin-bottom: 16px; font-size: 20px;\">Welcome to the Academy, " + fullName + "!</h2>\n" +
                "  <p style=\"color: #334155; font-size: 16px; line-height: 1.5; margin-bottom: 24px;\">\n" +
                "    Your account has been successfully created. You now have access to our premium learning hub, assignments, and interactive assessments. We are thrilled to have you on board.\n" +
                "  </p>\n" +
                "  <div style=\"background-color: #f8fafc; padding: 15px; border-radius: 6px; margin: 20px 0;\">\n" +
                "    <p style=\"color: #334155; font-size: 16px; margin: 0;\"><strong>Registered Email:</strong> " + toEmail + "</p>\n" +
                "  </div>\n" +
                "  <a href=\"https://psmels.software/login\" style=\"background-color: #0f172a; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: bold; margin: 10px 0;\">\n" +
                "    Log In & Start Learning\n" +
                "  </a>\n" +
                "</div>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Sends course duration expiry reminder email to the student
     * 
     * @param toEmail       Student's email address
     * @param fullName      Student's full name
     * @param courseName    Name of the course
     * @param daysRemaining Number of remaining days (e.g., 2)
     * @return true if email sent successfully
     */
    public static boolean sendCourseDurationReminderEmail(String toEmail, String fullName, String courseName,
            int daysRemaining) {
        String subject = "Course Expiry Reminder: Only " + daysRemaining + " days left in " + courseName + "! ⏳";

        String htmlBody = "<!DOCTYPE html>" +
                "<html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><style>"
                +
                "body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f5f5f5; }"
                +
                ".email-wrapper { max-width: 600px; margin: 20px auto; background: #ffffff; border: 1px solid #e0e0e0; overflow: hidden; }"
                +
                ".header { background: #2563eb; color: white; padding: 40px 20px; text-align: center; }" +
                ".header h1 { margin: 0; font-size: 24px; font-weight: 600; }" +
                ".header p { margin: 10px 0 0 0; opacity: 0.95; font-size: 14px; }" +
                ".content { padding: 40px 30px; }" +
                ".greeting { font-size: 18px; color: #1a1a1a; margin-bottom: 20px; font-weight: 500; }" +
                ".message { color: #4a4a4a; margin-bottom: 30px; font-size: 15px; line-height: 1.7; }" +
                ".warning-card { background: #fffbeb; color: #b45309; padding: 25px; border-left: 4px solid #f59e0b; margin: 25px 0; border-radius: 4px; }"
                +
                ".warning-card h2 { margin: 0 0 10px 0; font-size: 16px; font-weight: 600; color: #92400e; }" +
                ".warning-card p { margin: 0; font-size: 14px; line-height: 1.5; }" +
                ".btn { display: inline-block; background: #2563eb; color: white !important; padding: 14px 32px; text-decoration: none; margin: 25px 0; font-weight: 600; text-align: center; }"
                +
                ".footer { background: #1a1a1a; color: #d0d0d0; padding: 30px; text-align: center; font-size: 13px; border-top: 1px solid #333; }"
                +
                ".footer-links { margin: 15px 0; }" +
                ".footer-links a { color: #60a5fa; text-decoration: none; margin: 0 10px; }" +
                ".footer p { margin: 10px 0; }" +
                "</style></head><body>" +
                "<div class='email-wrapper'>" +
                "<div class='header'>" +
                "<h1>⏳ Course Expiry Reminder</h1>" +
                "<p>Don't miss out on earning your certificate!</p>" +
                "</div>" +
                "<div class='content'>" +
                "<p class='greeting'>Dear <strong>" + fullName + "</strong>,</p>" +
                "<p class='message'>This is a friendly reminder that your enrollment in the course <strong>\""
                + courseName + "\"</strong> is nearing its expiration. Our records show that you have exactly <strong>"
                + daysRemaining + " days</strong> left to access the materials and complete your requirements.</p>" +
                "<div class='warning-card'>" +
                "<h2>⚠️ Action Required</h2>" +
                "<p>To earn your professional certificate, please ensure you complete all required course materials, watch any remaining videos, and successfully pass the course assessments before the access period ends.</p>"
                +
                "</div>" +
                "<div style='text-align: center;'>" +
                "<a class='btn' href='https://localhost:8080/PSME/login'>Go to Learning Hub</a>" +
                "</div>" +
                "<p style='margin-top: 30px; color: #555;'>Keep up the amazing effort! Finishing this course is a fantastic step forward in your career and skill set.</p>"
                +
                "</div>" +
                "<div class='footer'>" +
                "<p><strong>PSM E-Learning Platform</strong></p>" +
                "<p>Empowering Education Through Technology</p>" +
                "<div class='footer-links'>" +
                "<a href='#'>Help Center</a> | " +
                "<a href='#'>Contact Support</a> | " +
                "<a href='#'>Terms of Service</a>" +
                "</div>" +
                "<p style='margin-top: 20px; opacity: 0.8;'>&copy; 2026 PSM E-Learning Platform. All rights reserved.</p>"
                +
                "</div>" +
                "</div></body></html>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Sends enrollment confirmation email
     * 
     * @param toEmail    Recipient email address
     * @param fullName   User's full name
     * @param courseName Course name
     * @return true if email sent successfully
     */
    public static boolean sendEnrollmentEmail(String toEmail, String fullName, String courseName) {
        String subject = "Enrollment Confirmation - " + courseName;

        String htmlBody = "<!DOCTYPE html>" +
                "<html><head><style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background-color: #17a2b8; color: white; padding: 20px; text-align: center; }" +
                ".content { padding: 20px; background-color: #f9f9f9; }" +
                ".footer { padding: 20px; text-align: center; font-size: 12px; color: #666; }" +
                "</style></head><body>" +
                "<div class='container'>" +
                "<div class='header'><h2>Enrollment Confirmed</h2></div>" +
                "<div class='content'>" +
                "<p>Dear " + fullName + ",</p>" +
                "<p>You have successfully enrolled in: <strong>" + courseName + "</strong></p>" +
                "<p>You can now access course materials and start learning.</p>" +
                "<p>Good luck with your studies!</p>" +
                "</div>" +
                "<div class='footer'>" +
                "<p>&copy; 2025 PSM E-Learning Platform. All rights reserved.</p>" +
                "</div></div></body></html>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Sends welcome email to newly created user by admin
     * 
     * @param toEmail   Recipient email address
     * @param fullName  User's full name
     * @param role      User role (Student/Instructor/Admin)
     * @param password  Generated password
     * @param regNumber Registration number (for students only, can be null)
     * @return true if email sent successfully
     */
    public static boolean sendAdminUserCreationEmail(String toEmail, String fullName, String role, String password,
            String regNumber) {
        String subject = "Your PSM E-Learning Account Has Been Created";

        // Plain text version to avoid activation JAR conflicts
        StringBuilder body = new StringBuilder();
        body.append("====================================\n");
        body.append("Welcome to PSM E-Learning Platform!\n");
        body.append("====================================\n\n");
        body.append("Dear ").append(fullName).append(",\n\n");
        body.append("An administrator has created an account for you on PSM E-Learning Platform.\n\n");
        body.append("Account Details:\n");
        body.append("----------------\n");
        body.append("Role: ").append(role).append("\n");

        if (regNumber != null && !regNumber.isEmpty()) {
            body.append("Registration Number: ").append(regNumber).append("\n");
        }

        body.append("Email/Username: ").append(toEmail).append("\n\n");
        body.append("===========================================\n");
        body.append("  YOUR TEMPORARY PASSWORD: ").append(password).append("\n");
        body.append("===========================================\n\n");
        body.append("⚠️ IMPORTANT SECURITY NOTICE:\n");
        body.append("• This is a TEMPORARY password\n");
        body.append("• Please CHANGE IT IMMEDIATELY after your first login\n");
        body.append("• Go to Profile → Change Password after logging in\n");
        body.append("• Do not share this password with anyone\n\n");
        body.append("You can now log in and start using the platform.\n\n");
        body.append("If you have any questions, please contact the administrator.\n\n");
        body.append("Best regards,\n");
        body.append("PSM E-Learning Platform Team\n\n");
        body.append("© 2025 PSM E-Learning Platform. All rights reserved.\n");

        return sendEmail(toEmail, subject, body.toString());
    }

    /**
     * Sends password change confirmation email
     * 
     * @param toEmail  Recipient email address
     * @param fullName User's full name
     * @return true if email sent successfully
     */
    public static boolean sendPasswordChangeConfirmation(String toEmail, String fullName) {
        String subject = "Password Changed Successfully - PSM E-Learning";

        // Plain text version to avoid activation JAR conflicts
        StringBuilder body = new StringBuilder();
        body.append("====================================\n");
        body.append("✓ Password Changed Successfully\n");
        body.append("====================================\n\n");
        body.append("Dear ").append(fullName).append(",\n\n");
        body.append("This is a confirmation that your password has been changed successfully.\n\n");
        body.append("Change Date: ")
                .append(new java.text.SimpleDateFormat("MMMM dd, yyyy 'at' HH:mm").format(new java.util.Date()))
                .append("\n\n");
        body.append("⚠️ DID YOU MAKE THIS CHANGE?\n");
        body.append("If you did not change your password, please contact support immediately\n");
        body.append("as your account may be compromised.\n\n");
        body.append("For security reasons, you may want to:\n");
        body.append("• Log out of all devices\n");
        body.append("• Review your account activity\n");
        body.append("• Update your security questions\n\n");
        body.append("Best regards,\n");
        body.append("PSM E-Learning Platform Team\n\n");
        body.append("© 2025 PSM E-Learning Platform. All rights reserved.\n");

        return sendEmail(toEmail, subject, body.toString());
    }

    /**
     * Sends a course assignment notification to an instructor.
     *
     * @param toEmail      Recipient email address
     * @param fullName     Instructor name
     * @param courseName   Assigned course name
     * @param category     Course category
     * @param level        Course level
     * @param dashboardUrl Link back to the admin course dashboard
     * @return true if email sent successfully
     */
    public static boolean sendCourseAssignmentEmail(String toEmail, String fullName, String courseName, String category,
            String level, String dashboardUrl) {
        String recipientName = fullName != null && !fullName.trim().isEmpty() ? fullName.trim() : "Instructor";
        String title = courseName != null && !courseName.trim().isEmpty() ? courseName.trim() : "Course";
        String subject = "You Have Been Assigned a New Course";

        String htmlBody = "<div style=\"max-width: 600px; margin: 0 auto; font-family: sans-serif; padding: 20px; background-color: #ffffff;\">\n"
                +
                "  <h1 style=\"color: #0f172a; margin-top: 0; margin-bottom: 8px; font-size: 24px;\">PSM E-Learning Academy</h1>\n"
                +
                "  <hr style=\"border: none; border-top: 1px solid #e2e8f0; margin-bottom: 24px;\">\n" +
                "  <h2 style=\"color: #0f172a; margin-top: 0; margin-bottom: 16px; font-size: 20px;\">New Course Assignment</h2>\n"
                +
                "  <p style=\"color: #334155; font-size: 16px; line-height: 1.5; margin-bottom: 24px;\">\n" +
                "    Hello " + recipientName
                + ", the administration team has assigned a new course to your workspace. You can now begin uploading materials, creating assessments, and managing your student roster.\n"
                +
                "  </p>\n" +
                "  <div style=\"background-color: #f8fafc; padding: 15px; border-radius: 6px; margin: 20px 0; border: 1px solid #e2e8f0;\">\n"
                +
                "    <p style=\"color: #334155; font-size: 16px; margin: 0 0 8px 0;\"><strong>Course Name:</strong> "
                + title + "</p>\n" +
                "    <p style=\"color: #334155; font-size: 16px; margin: 0;\"><strong>Role:</strong> Instructor</p>\n" +
                "  </div>\n" +
                "  <a href=\"https://psmels.software/instructor/workspace\" style=\"background-color: #0f172a; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: bold; margin: 10px 0;\">\n"
                +
                "    Go to Course Workspace\n" +
                "  </a>\n" +
                "</div>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Sends password reset email with reset link
     * 
     * @param toEmail    Recipient email
     * @param userName   User's full name
     * @param resetToken Reset token string
     * @param resetLink  Full reset link URL
     * @return true if email sent successfully
     */
    public static boolean sendPasswordResetEmail(String toEmail, String userName, String resetToken, String resetLink) {
        String subject = "Password Reset Request - PSM E-Learning Academy";

        String htmlBody = "<div style=\"max-width: 600px; margin: 0 auto; font-family: sans-serif; background-color: #ffffff; padding: 32px;\">\n" +
                "  <h1 style=\"color: #0f172a; margin-top: 0; margin-bottom: 24px; font-size: 24px;\">PSM E-Learning Academy</h1>\n" +
                "  <p style=\"color: #334155; font-size: 16px; line-height: 1.5; margin-bottom: 24px;\">\n" +
                "    Hello " + userName + ", we received a request to reset your password. If you didn't make this request, you can safely ignore this email.\n" +
                "  </p>\n" +
                "  <a href=\"" + resetLink + "\" style=\"background-color: #0f172a; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: bold; margin: 24px 0;\">\n" +
                "    Reset Password\n" +
                "  </a>\n" +
                "  <p style=\"color: #64748b; font-size: 14px; margin-top: 32px;\">\n" +
                "    This link will expire in 1 hour.\n" +
                "  </p>\n" +
                "</div>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Sends a premium SaaS-style payment receipt email after successful course purchase.
     * 
     * @param toEmail       Recipient email address
     * @param studentName   Student's full name
     * @param courseTitle   Name of the purchased course
     * @param transactionId Payment transaction ID (e.g. Paystack reference)
     * @param date          Date of transaction
     * @param amountPaid    Formatted amount paid (e.g. "₦15,000.00")
     * @return true if email sent successfully via Brevo
     */
    public static boolean sendPaymentReceiptEmail(String toEmail, String studentName, String courseTitle, 
                                                  String transactionId, String date, String amountPaid) {
        String subject = "Payment Receipt - " + courseTitle;

        String htmlBody = 
            "<div style=\"max-width: 600px; margin: 0 auto; font-family: sans-serif; padding: 20px; background-color: #ffffff;\">\n" +
            "  <h1 style=\"color: #0f172a; margin-top: 0; margin-bottom: 8px; font-size: 24px;\">PSM E-Learning Academy</h1>\n" +
            "  <hr style=\"border: none; border-top: 1px solid #e2e8f0; margin-bottom: 24px;\">\n" +
            "  <h2 style=\"color: #0f172a; margin-top: 0; margin-bottom: 16px; font-size: 22px;\">Payment Receipt</h2>\n" +
            "  <p style=\"color: #334155; font-size: 16px; line-height: 1.5; margin-bottom: 24px;\">\n" +
            "    Hello " + studentName + ", thank you for your purchase. Your payment was successful, and you now have full access to your course.\n" +
            "  </p>\n" +
            "  <div style=\"background-color: #f8fafc; padding: 20px; border-radius: 8px; margin: 24px 0; border: 1px solid #e2e8f0;\">\n" +
            "    <table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-size: 16px; color: #334155;\">\n" +
            "      <tr><td style=\"padding-bottom: 12px;\"><strong>Course:</strong></td><td style=\"padding-bottom: 12px;\">" + courseTitle + "</td></tr>\n" +
            "      <tr><td style=\"padding-bottom: 12px;\"><strong>Transaction ID:</strong></td><td style=\"padding-bottom: 12px;\">" + transactionId + "</td></tr>\n" +
            "      <tr><td style=\"padding-bottom: 12px;\"><strong>Date:</strong></td><td style=\"padding-bottom: 12px;\">" + date + "</td></tr>\n" +
            "      <tr><td style=\"padding-top: 12px; border-top: 1px solid #e2e8f0;\"><strong>Total Paid:</strong></td><td style=\"padding-top: 12px; border-top: 1px solid #e2e8f0; font-size: 18px; font-weight: bold; color: #0f172a;\">" + amountPaid + "</td></tr>\n" +
            "    </table>\n" +
            "  </div>\n" +
            "  <div style=\"text-align: center; margin: 32px 0;\">\n" +
            "    <a href=\"https://psmels.software/student/my-courses\" style=\"background-color: #0f172a; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: bold;\">\n" +
            "      Access Your Course\n" +
            "    </a>\n" +
            "  </div>\n" +
            "  <p style=\"color: #94a3b8; font-size: 13px; text-align: center; margin-top: 32px;\">\n" +
            "    If you have any questions about this receipt, please reply to this email.\n" +
            "  </p>\n" +
            "</div>";

        return sendHtmlEmail(toEmail, subject, htmlBody);
    }
}
