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
     * Loads email configuration from email.properties file
     */
    private static void loadEmailConfig() {
        Properties props = new Properties();
        InputStream input = null;
        
        try {
            // Try loading from classpath
            input = EmailUtil.class.getClassLoader().getResourceAsStream("email.properties");
            
            if (input == null) {
                System.err.println("========================================");
                System.err.println("CRITICAL: email.properties NOT FOUND in classpath!");
                System.err.println("Expected location: WEB-INF/classes/email.properties");
                System.err.println("Using INVALID default configuration - emails WILL FAIL");
                System.err.println("========================================");
                
                // Default configuration (WILL NOT WORK)
                SMTP_HOST = "smtp.gmail.com";
                SMTP_PORT = "587";
                SMTP_USERNAME = "INVALID@example.com";
                SMTP_PASSWORD = "INVALID_PASSWORD";
                FROM_EMAIL = "INVALID@example.com";
                FROM_NAME = "PSM E-Learning Platform";
                return;
            }
            
            props.load(input);
            SMTP_HOST = props.getProperty("smtp.host", "smtp.gmail.com");
            SMTP_PORT = props.getProperty("smtp.port", "587");
            SMTP_USERNAME = props.getProperty("smtp.username");
            SMTP_PASSWORD = props.getProperty("smtp.password");
            FROM_EMAIL = props.getProperty("from.email", SMTP_USERNAME);
            FROM_NAME = props.getProperty("from.name", "PSM E-Learning Platform");
            MAIL_DEBUG = Boolean.parseBoolean(props.getProperty("mail.debug", "false"));
            
        } catch (IOException e) {
            System.err.println("========================================");
            System.err.println("ERROR loading email configuration: " + e.getMessage());
            e.printStackTrace();
            System.err.println("========================================");
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    // Ignore close errors
                }
            }
        }
    }
    
    /**
     * Creates a mail session with SMTP authentication
     * 
     * @return Configured Session object
     */
    private static Session createSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        // Some providers require explicit TLS trust or protocol settings
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        // Enable debugging easily when diagnosing issues
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
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
     * @param body Email body
     * @return true if email sent successfully, false otherwise
     */
    public static boolean sendEmail(String toEmail, String subject, String body) {
        try {
            Session session = createSession();
            
            Message message = new MimeMessage(session);
            String fromAddress = (FROM_EMAIL != null && !FROM_EMAIL.trim().isEmpty()) ? FROM_EMAIL : SMTP_USERNAME;
            message.setFrom(new InternetAddress(fromAddress, FROM_NAME != null ? FROM_NAME : "PSM E-Learning Platform"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(body);
            
            Transport.send(message);
            return true;
            
        } catch (MessagingException e) {
            System.err.println("Failed to send email to " + toEmail + ": " + e.getMessage());
            return false;
        } catch (java.io.UnsupportedEncodingException e) {
            System.err.println("Email encoding error: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Sends an HTML email
     * 
     * @param toEmail Recipient email address
     * @param subject Email subject
     * @param htmlBody HTML email body
     * @return true if email sent successfully, false otherwise
     */
    public static boolean sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        try {
            Session session = createSession();
            
            Message message = new MimeMessage(session);
            String fromAddress = (FROM_EMAIL != null && !FROM_EMAIL.trim().isEmpty()) ? FROM_EMAIL : SMTP_USERNAME;
            message.setFrom(new InternetAddress(fromAddress, FROM_NAME != null ? FROM_NAME : "PSM E-Learning Platform"));
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
        }
    }
    
    /**
     * Sends password reset email with temporary password
     * 
     * @param toEmail Recipient email address
     * @param fullName User's full name
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
     * @param toEmail Recipient email address
     * @param fullName User's full name
     * @param regNumber Registration number (for students)
     * @return true if email sent successfully
     */
    public static boolean sendRegistrationEmail(String toEmail, String fullName, String regNumber) {
        String subject = "Welcome to PSM E-Learning Platform! 🎓";
        
        String htmlBody = "<!DOCTYPE html>" +
                "<html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><style>" +
                "body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f4f4f4; }" +
                ".email-wrapper { max-width: 600px; margin: 20px auto; background: #ffffff; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }" +
                ".header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 20px; text-align: center; }" +
                ".header h1 { margin: 0; font-size: 28px; font-weight: 600; }" +
                ".header p { margin: 10px 0 0 0; opacity: 0.9; }" +
                ".content { padding: 40px 30px; }" +
                ".greeting { font-size: 18px; color: #333; margin-bottom: 20px; }" +
                ".message { color: #555; margin-bottom: 30px; font-size: 15px; }" +
                ".info-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 25px; border-radius: 8px; margin: 30px 0; text-align: center; }" +
                ".info-card h2 { margin: 0 0 15px 0; font-size: 16px; opacity: 0.9; font-weight: 400; }" +
                ".reg-number { font-size: 32px; font-weight: bold; letter-spacing: 2px; margin: 10px 0; }" +
                ".info-row { margin: 10px 0; }" +
                ".login-instructions { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea; }" +
                ".login-instructions h3 { margin: 0 0 15px 0; color: #333; font-size: 16px; }" +
                ".login-instructions ol { margin: 0; padding-left: 20px; color: #555; }" +
                ".login-instructions li { margin: 8px 0; }" +
                ".btn { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: 600; }" +
                ".features { margin: 30px 0; }" +
                ".feature-item { padding: 12px 0; border-bottom: 1px solid #eee; color: #555; }" +
                ".feature-item:last-child { border-bottom: none; }" +
                ".feature-icon { color: #667eea; margin-right: 8px; }" +
                ".footer { background: #2c3e50; color: #ecf0f1; padding: 30px; text-align: center; font-size: 13px; }" +
                ".footer-links { margin: 15px 0; }" +
                ".footer-links a { color: #3498db; text-decoration: none; margin: 0 10px; }" +
                ".social-links { margin: 20px 0; }" +
                ".social-links a { display: inline-block; margin: 0 8px; color: #ecf0f1; text-decoration: none; }" +
                "</style></head><body>" +
                "<div class='email-wrapper'>" +
                "<div class='header'>" +
                "<h1>🎓 Welcome to PSM E-Learning!</h1>" +
                "<p>Your Journey to Excellence Begins Here</p>" +
                "</div>" +
                "<div class='content'>" +
                "<p class='greeting'>Dear <strong>" + fullName + "</strong>,</p>" +
                "<p class='message'>Congratulations! Your registration with PSM E-Learning Platform has been completed successfully. We're excited to have you join our community of learners.</p>" +
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
                "<div class='feature-item'><span class='feature-icon'>✓</span> Access to comprehensive course materials</div>" +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Interactive learning modules</div>" +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Track your progress and achievements</div>" +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Connect with instructors and peers</div>" +
                "<div class='feature-item'><span class='feature-icon'>✓</span> Access 24/7 learning resources</div>" +
                "</div>" +
                "<p style='margin-top: 30px; color: #555;'>If you have any questions or need assistance, our support team is here to help.</p>" +
                "</div>" +
                "<div class='footer'>" +
                "<p><strong>PSM E-Learning Platform</strong></p>" +
                "<p>Empowering Education Through Technology</p>" +
                "<div class='footer-links'>" +
                "<a href='#'>Help Center</a> | " +
                "<a href='#'>Contact Support</a> | " +
                "<a href='#'>Terms of Service</a>" +
                "</div>" +
                "<p style='margin-top: 20px; opacity: 0.8;'>&copy; 2025 PSM E-Learning Platform. All rights reserved.</p>" +
                "</div>" +
                "</div></body></html>";
        
        return sendHtmlEmail(toEmail, subject, htmlBody);
    }
    
    /**
     * Sends enrollment confirmation email
     * 
     * @param toEmail Recipient email address
     * @param fullName User's full name
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
     * @param toEmail Recipient email address
     * @param fullName User's full name
     * @param role User role (Student/Instructor/Admin)
     * @param password Generated password
     * @param regNumber Registration number (for students only, can be null)
     * @return true if email sent successfully
     */
    public static boolean sendAdminUserCreationEmail(String toEmail, String fullName, String role, String password, String regNumber) {
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
     * @param toEmail Recipient email address
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
        body.append("Change Date: ").append(new java.text.SimpleDateFormat("MMMM dd, yyyy 'at' HH:mm").format(new java.util.Date())).append("\n\n");
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
     * Sends password reset email with reset link
     * 
     * @param toEmail Recipient email
     * @param userName User's full name
     * @param resetToken Reset token string
     * @param resetLink Full reset link URL
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

