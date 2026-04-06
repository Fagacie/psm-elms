package com.psm.elearning.controller;

import com.psm.elearning.dao.AdminDAO;
import com.psm.elearning.dao.AdminDAOImpl;
import com.psm.elearning.dao.InstructorApplicationDAO;
import com.psm.elearning.dao.InstructorApplicationDAOImpl;
import com.psm.elearning.dao.NotificationDAO;
import com.psm.elearning.dao.NotificationDAOImpl;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.model.Admin;
import com.psm.elearning.model.InstructorApplication;
import com.psm.elearning.model.Notification;
import com.psm.elearning.model.User;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.List;

@MultipartConfig(maxFileSize = 10485760, maxRequestSize = 12582912)
public class InstructorApplicationServlet extends HttpServlet {

    private final InstructorApplicationDAO applicationDAO = new InstructorApplicationDAOImpl();
    private final AdminDAO adminDAO = new AdminDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();
    private final NotificationDAO notificationDAO = new NotificationDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/landing#apply");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String specialization = trim(request.getParameter("specialization"));
        String qualification = trim(request.getParameter("qualification"));
        String coverMessage = trim(request.getParameter("coverMessage"));
        String yearsOfExperienceRaw = trim(request.getParameter("yearsOfExperience"));

        if (isBlank(fullName) || isBlank(email) || isBlank(phone) || isBlank(specialization) || isBlank(qualification)) {
            request.getSession().setAttribute("error", "Please complete all required instructor application fields.");
            response.sendRedirect(request.getContextPath() + "/landing#apply");
            return;
        }

        if (userDAO.findByEmail(email) != null) {
            request.getSession().setAttribute("error", "That email already belongs to an existing account.");
            response.sendRedirect(request.getContextPath() + "/landing#apply");
            return;
        }

        InstructorApplication existingApplication = applicationDAO.findLatestByEmail(email);
        if (existingApplication != null && !InstructorApplication.STATUS_REJECTED.equals(existingApplication.getStatus())) {
            request.getSession().setAttribute("error", "There is already an active instructor application for that email.");
            response.sendRedirect(request.getContextPath() + "/landing#apply");
            return;
        }

        Integer yearsOfExperience = null;
        if (!isBlank(yearsOfExperienceRaw)) {
            try {
                yearsOfExperience = Integer.parseInt(yearsOfExperienceRaw);
            } catch (NumberFormatException ignored) {
                request.getSession().setAttribute("error", "Years of experience must be a number.");
                response.sendRedirect(request.getContextPath() + "/landing#apply");
                return;
            }
        }

        String cvPath;
        try {
            Part cvPart = request.getPart("cvFile");
            if (cvPart == null || cvPart.getSize() <= 0) {
                request.getSession().setAttribute("error", "Please upload your CV or supporting document.");
                response.sendRedirect(request.getContextPath() + "/landing#apply");
                return;
            }

            String submittedName = cvPart.getSubmittedFileName();
            String fileName = submittedName != null ? Paths.get(submittedName).getFileName().toString() : "instructor-cv";
            byte[] fileBytes;
            try (InputStream inputStream = cvPart.getInputStream()) {
                fileBytes = inputStream.readAllBytes();
            }
            cvPath = CloudinaryUtil.uploadFile(fileBytes, fileName, CloudinaryUtil.getInstructorApplicationsFolder(), "raw");
            if (cvPath == null) {
                request.getSession().setAttribute("error", "The CV upload failed. Please try again.");
                response.sendRedirect(request.getContextPath() + "/landing#apply");
                return;
            }
        } catch (Exception uploadEx) {
            request.getSession().setAttribute("error", "Unable to process the uploaded CV.");
            response.sendRedirect(request.getContextPath() + "/landing#apply");
            return;
        }

        InstructorApplication application = new InstructorApplication();
        application.setFullName(fullName);
        application.setEmail(email);
        application.setPhone(phone);
        application.setSpecialization(specialization);
        application.setYearsOfExperience(yearsOfExperience);
        application.setQualification(qualification);
        application.setCoverMessage(coverMessage);
        application.setCvPath(cvPath);
        application.setStatus(InstructorApplication.STATUS_PENDING);

        InstructorApplication created = applicationDAO.create(application);
        if (created == null) {
            request.getSession().setAttribute("error", "We could not save your application. Please try again.");
            response.sendRedirect(request.getContextPath() + "/landing#apply");
            return;
        }

        persistNotifications(created);
        notifyAdmins(created);
        try {
            EmailUtil.sendInstructorApplicationReceivedEmail(created.getEmail(), created.getFullName());
        } catch (Exception ignored) {
        }

        request.getSession().setAttribute("success", "Your instructor application has been submitted. The admin team will review it and contact you by email.");
        response.sendRedirect(request.getContextPath() + "/landing?application=submitted#apply");
    }

    private void persistNotifications(InstructorApplication application) {
        try {
            List<Admin> admins = adminDAO.findAll();
            for (Admin admin : admins) {
                User adminUser = userDAO.findById(admin.getUserId());
                if (adminUser == null) {
                    continue;
                }

                Notification notification = new Notification();
                notification.setRecipientUserId(adminUser.getUserId());
                notification.setRecipientEmail(adminUser.getEmail());
                notification.setRecipientName(adminUser.getFullName());
                notification.setTitle("New instructor application");
                notification.setMessage(application.getFullName() + " submitted an instructor application for " + application.getSpecialization() + ".");
                notification.setNotificationType(Notification.TYPE_INSTRUCTOR_APPLICATION);
                notification.setRelatedEntityType(Notification.TYPE_INSTRUCTOR_APPLICATION);
                notification.setRelatedEntityId(application.getApplicationId());
                notification.setChannel(Notification.CHANNEL_IN_APP);
                notification.setRead(false);
                notificationDAO.create(notification);
            }

            Notification applicantNotification = new Notification();
            applicantNotification.setRecipientEmail(application.getEmail());
            applicantNotification.setRecipientName(application.getFullName());
            applicantNotification.setTitle("Instructor application received");
            applicantNotification.setMessage("Your instructor application has been submitted and is waiting for review.");
            applicantNotification.setNotificationType(Notification.TYPE_INSTRUCTOR_APPLICATION);
            applicantNotification.setRelatedEntityType(Notification.TYPE_INSTRUCTOR_APPLICATION);
            applicantNotification.setRelatedEntityId(application.getApplicationId());
            applicantNotification.setChannel(Notification.CHANNEL_EMAIL);
            applicantNotification.setRead(true);
            notificationDAO.create(applicantNotification);
        } catch (Exception ignored) {
        }
    }

    private void notifyAdmins(InstructorApplication application) {
        try {
            List<Admin> admins = adminDAO.findAll();
            for (Admin admin : admins) {
                User adminUser = userDAO.findById(admin.getUserId());
                if (adminUser == null || adminUser.getEmail() == null) {
                    continue;
                }

                String subject = "New Instructor Application - " + application.getFullName();
                StringBuilder body = new StringBuilder();
                body.append("<html><body style='font-family:Arial,sans-serif;line-height:1.6;color:#0f172a;'>");
                body.append("<div style='max-width:640px;margin:0 auto;padding:24px;border:1px solid #e2e8f0;border-radius:16px;background:#fff;'>");
                body.append("<h2 style='margin-top:0;'>New Instructor Application</h2>");
                body.append("<p>A new instructor application was submitted from the public landing page.</p>");
                body.append("<table style='width:100%;border-collapse:collapse;'>");
                body.append("<tr><td style='padding:8px 0;color:#64748b;'>Name</td><td style='padding:8px 0;'><strong>").append(application.getFullName()).append("</strong></td></tr>");
                body.append("<tr><td style='padding:8px 0;color:#64748b;'>Email</td><td style='padding:8px 0;'>").append(application.getEmail()).append("</td></tr>");
                body.append("<tr><td style='padding:8px 0;color:#64748b;'>Phone</td><td style='padding:8px 0;'>").append(application.getPhone()).append("</td></tr>");
                body.append("<tr><td style='padding:8px 0;color:#64748b;'>Specialization</td><td style='padding:8px 0;'>").append(application.getSpecialization()).append("</td></tr>");
                body.append("<tr><td style='padding:8px 0;color:#64748b;'>Years of Experience</td><td style='padding:8px 0;'>").append(application.getYearsOfExperience() != null ? application.getYearsOfExperience() : "-").append("</td></tr>");
                body.append("<tr><td style='padding:8px 0;color:#64748b;'>Qualification</td><td style='padding:8px 0;'>").append(application.getQualification()).append("</td></tr>");
                body.append("<tr><td style='padding:8px 0;color:#64748b;'>CV</td><td style='padding:8px 0;'><a href='").append(application.getCvPath()).append("'>View uploaded CV</a></td></tr>");
                body.append("</table>");
                body.append("<p style='margin-top:20px;'>Review it in the admin applications workspace.</p>");
                body.append("</div></body></html>");
                EmailUtil.sendHtmlEmail(adminUser.getEmail(), subject, body.toString());
            }
        } catch (Exception ignored) {
        }
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private static String trim(String value) {
        return value == null ? null : value.trim();
    }
}