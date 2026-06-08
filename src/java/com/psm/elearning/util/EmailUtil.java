package com.psm.elearning.util;

import java.util.Properties;
import java.io.InputStream;
import java.io.IOException;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

/**
 * Email Utility for sending emails using JavaMail API
 * Supports password reset, registration confirmation, and notifications
 * 
 * @author PSM E-Learning Team
 * @version 1.0
 */
public class EmailUtil {

    private static String SMTP_HOST;
    private static String SMTP_PORT;
    private static String SMTP_USERNAME;
    private static String SMTP_PASSWORD;
    private static String FROM_EMAIL;
    private static String FROM_NAME;
    private static boolean MAIL_DEBUG = false;

    // Static block to load email configuration
    static {
        loadEmailConfig();
    }

    /**
     * Loads email configuration from environment variables
     */
    private static void loadEmailConfig() {
        SMTP_HOST = System.getenv("SMTP_HOST");
        SMTP_PORT = System.getenv("SMTP_PORT");
        SMTP_USERNAME = System.getenv("SMTP_USERNAME");
        SMTP_PASSWORD = System.getenv("SMTP_PASSWORD");
        
        String fromEmailEnv = System.getenv("SMTP_FROM_EMAIL");
        FROM_EMAIL = (fromEmailEnv != null && !fromEmailEnv.isEmpty()) ? fromEmailEnv : SMTP_USERNAME;
        
        String fromNameEnv = System.getenv("SMTP_FROM_NAME");
        FROM_NAME = (fromNameEnv != null && !fromNameEnv.isEmpty()) ? fromNameEnv : "PSM E-Learning Platform";
        
        String debugEnv = System.getenv("SMTP_DEBUG");
        MAIL_DEBUG = "true".equalsIgnoreCase(debugEnv);

        if (SMTP_HOST == null || SMTP_HOST.trim().isEmpty() || SMTP_USERNAME == null || SMTP_USERNAME.trim().isEmpty()) {
            System.err.println("SEVERE WARNING: Email functionality is disabled. Required environment variables (SMTP_HOST, SMTP_USERNAME) are missing.");
        }
    }

    private static String resolveFromAddress() {
        return (FROM_EMAIL != null && !FROM_EMAIL.trim().isEmpty()) ? FROM_EMAIL : SMTP_USERNAME;
    }

    private static String resolveFromName() {
        return (FROM_NAME != null && !FROM_NAME.trim().isEmpty()) ? FROM_NAME : "PSM E-Learning Platform";
    }

    private static Session createSession() {
        if (SMTP_HOST == null || SMTP_HOST.trim().isEmpty() || SMTP_USERNAME == null || SMTP_USERNAME.trim().isEmpty()) {
            return null; // Return null early if credentials are not configured
        }

        Properties props = new Properties();
        
        String host = SMTP_HOST;
        String port = (SMTP_PORT != null && !SMTP_PORT.trim().isEmpty()) ? SMTP_PORT : "587";
        String username = SMTP_USERNAME;
        String password = SMTP_PASSWORD != null ? SMTP_PASSWORD : "";
        
        String startTls = System.getenv("SMTP_STARTTLS");
        if (startTls == null || startTls.isEmpty()) startTls = "true";

        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.connectiontimeout", "10000"); // 10 seconds
        props.put("mail.smtp.timeout", "10000"); // 10 seconds
        
        // Disable STARTTLS if we are using port 465 (pure SSL)
        if ("465".equals(port)) {
            props.put("mail.smtp.starttls.enable", "false");
            props.put("mail.smtp.starttls.required", "false");
            props.put("mail.smtp.socketFactory.port", port);
            props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
            props.put("mail.smtp.ssl.enable", "true");
        } else {
            props.put("mail.smtp.starttls.enable", startTls);
            props.put("mail.smtp.starttls.required", startTls);
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            props.put("mail.smtp.ssl.trust", host);
        }
        
        final String authUser = username;
        final String authPass = password;
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(authUser, authPass);
            }
        });
        if (MAIL_DEBUG) {
            session.setDebug(true);
        }
        return session;
    }

    /**
     * Sends a plain text email
     * 
     * @param toEmail Recipient email address
     * @param subject Email subject
     * @param body    Email body
     * @return true if email sent successfully, false otherwise
     */
    public static boolean sendEmail(String toEmail, String subject, String body) {
        try {
            Session session = createSession();
            if (session == null) {
                System.err.println("ERROR: Could not send email to " + toEmail + ". SMTP credentials are not fully configured in environment variables.");
                return false;
            }

            Message message = new MimeMessage(session);
            String fromAddress = resolveFromAddress();
            message.setFrom(
                    new InternetAddress(fromAddress, resolveFromName()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(body);

            Transport.send(message);
            return true;

        } catch (MessagingException e) {
            System.err.println("Failed to send email to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (java.io.UnsupportedEncodingException e) {
            System.err.println("Email encoding error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("Unexpected error sending email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Sends an HTML email
     * 
     * @param toEmail  Recipient email address
     * @param subject  Email subject
     * @param htmlBody HTML email body
     * @return true if email sent successfully, false otherwise
     */
    public static boolean sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        try {
            Session session = createSession();
            if (session == null) {
                System.err.println("ERROR: Could not send HTML email to " + toEmail + ". SMTP credentials are not fully configured in environment variables.");
                return false;
            }

            Message message = new MimeMessage(session);
            String fromAddress = resolveFromAddress();
            message.setFrom(
                    new InternetAddress(fromAddress, resolveFromName()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("HTML Email sent successfully to: " + toEmail);
            return true;

        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            System.err.println("Failed to send HTML email: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("Unexpected error sending HTML email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
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
        String subject = "Welcome to PSM E-Learning Platform! 🎓";

        String htmlBody = "<!DOCTYPE html>" +
                "<html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><style>"
                +
                "body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f5f5f5; }"
                +
                ".email-wrapper { max-width: 600px; margin: 20px auto; background: #ffffff; border: 1px solid #e0e0e0; overflow: hidden; }"
                +
                ".header { background: #1e3a8a; color: white; padding: 40px 20px; text-align: center; }" +
                ".header h1 { margin: 0; font-size: 28px; font-weight: 600; }" +
                ".header p { margin: 10px 0 0 0; opacity: 0.95; font-size: 14px; }" +
                ".content { padding: 40px 30px; }" +
                ".greeting { font-size: 18px; color: #1a1a1a; margin-bottom: 20px; font-weight: 500; }" +
                ".message { color: #4a4a4a; margin-bottom: 30px; font-size: 15px; line-height: 1.7; }" +
                ".info-card { background: #1e3a8a; color: white; padding: 30px; border: 1px solid #1e40af; margin: 30px 0; text-align: center; }"
                +
                ".info-card h2 { margin: 0 0 15px 0; font-size: 14px; opacity: 0.95; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }"
                +
                ".reg-number { font-size: 36px; font-weight: 700; letter-spacing: 3px; margin: 15px 0; font-family: 'Courier New', monospace; }"
                +
                ".info-row { margin: 15px 0; font-size: 15px; }" +
                ".login-instructions { background: #ffffff; padding: 25px; border: 1px solid #e0e0e0; margin: 25px 0; }"
                +
                ".login-instructions h3 { margin: 0 0 20px 0; color: #1a1a1a; font-size: 16px; font-weight: 600; }" +
                ".login-instructions ol { margin: 0; padding-left: 20px; color: #4a4a4a; line-height: 1.8; }" +
                ".login-instructions li { margin: 10px 0; }" +
                ".login-instructions strong { color: #1e3a8a; }" +
                ".btn { display: inline-block; background: #1e3a8a; color: white; padding: 14px 32px; text-decoration: none; border: 1px solid #1e40af; margin: 25px 0; font-weight: 600; transition: background 0.2s; }"
                +
                ".btn:hover { background: #1e40af; }" +
                ".features { margin: 30px 0; border: 1px solid #e0e0e0; }" +
                ".feature-item { padding: 15px 20px; border-bottom: 1px solid #e0e0e0; color: #4a4a4a; background: #fafafa; }"
                +
                ".feature-item:last-child { border-bottom: none; }" +
                ".feature-icon { color: #1e3a8a; margin-right: 10px; font-weight: 600; }" +
                ".footer { background: #1a1a1a; color: #d0d0d0; padding: 30px; text-align: center; font-size: 13px; border-top: 1px solid #333; }"
                +
                ".footer-links { margin: 15px 0; }" +
                ".footer-links a { color: #60a5fa; text-decoration: none; margin: 0 10px; }" +
                ".footer p { margin: 10px 0; }" +
                "</style></head><body>" +
                "<div class='email-wrapper'>" +
                "<div class='header'>" +
                "<h1>🎓 Welcome to PSM E-Learning!</h1>" +
                "<p>Your Journey to Excellence Begins Here</p>" +
                "</div>" +
                "<div class='content'>" +
                "<p class='greeting'>Dear <strong>" + fullName + "</strong>,</p>" +
                "<p class='message'>Congratulations! Your registration with PSM E-Learning Platform has been completed successfully. We're excited to have you join our community of learners.</p>"
                +
                "<div class='info-card'>" +
                "<h2>Your Registration Number</h2>" +
                "<div class='reg-number'>" + regNumber + "</div>" +
                "<div class='info-row'>📧 <strong>" + toEmail + "</strong></div>" +
                "</div>" +
                "<div class='login-instructions'>" +
                "<h3>🔐 How to Login</h3>" +
                "<ol>" +
                "<li>Visit the PSM E-Learning login page</li>" +
                "<li>Select <strong>\"Student\"</strong> as your role</li>" +
                "<li>Enter your Registration Number: <strong>" + regNumber + "</strong></li>" +
                "<li>Enter the password you created during registration</li>" +
                "<li>Click \"Login\" to access your dashboard</li>" +
                "</ol>" +
                "</div>" +
                "<div class='features'>" +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Access to comprehensive course materials</div>"
                +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Interactive learning modules</div>" +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Track your progress and achievements</div>"
                +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Connect with instructors and peers</div>"
                +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Access 24/7 learning resources</div>" +
                "</div>" +
                "<p style='margin-top: 30px; color: #555;'>If you have any questions or need assistance, our support team is here to help.</p>"
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
                "<p style='margin-top: 20px; opacity: 0.8;'>&copy; 2025 PSM E-Learning Platform. All rights reserved.</p>"
                +
                "</div>" +
                "</div></body></html>";

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

        StringBuilder body = new StringBuilder();
        body.append("Hello ").append(recipientName).append(",\n\n");
        body.append("You have been assigned to teach:\n\n");
        body.append(title).append("\n\n");
        body.append("Please log in to upload materials, create assessments, and manage students.\n\n");
        body.append("Regards,\nPSM E-Learning");

        return sendEmail(toEmail, subject, body.toString());
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
        String subject = "Password Reset Request - PSM E-Learning";

        StringBuilder body = new StringBuilder();
        body.append("Dear ").append(userName).append(",\n\n");
        body.append("We received a request to reset your password for your PSM E-Learning account.\n\n");
        body.append("To reset your password, click the link below:\n");
        body.append(resetLink).append("\n\n");
        body.append("Or copy and paste this link into your browser:\n");
        body.append(resetLink).append("\n\n");
        body.append("⏰ IMPORTANT: This link will expire in 1 hour for security reasons.\n\n");
        body.append("⚠️ DIDN'T REQUEST THIS?\n");
        body.append("If you didn't request a password reset, please ignore this email.\n");
        body.append("Your password will remain unchanged and your account is safe.\n\n");
        body.append("Security Tips:\n");
        body.append("• Never share your password with anyone\n");
        body.append("• Use a strong, unique password\n");
        body.append("• Don't use the same password on multiple sites\n\n");
        body.append("Best regards,\n");
        body.append("PSM E-Learning Platform Team\n\n");
        body.append("© 2025 PSM E-Learning Platform. All rights reserved.\n");

        return sendEmail(toEmail, subject, body.toString());
    }
}
