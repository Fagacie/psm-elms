package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.*;
import com.psm.elearning.model.*;
import com.psm.elearning.util.EmailUtil;
import com.psm.elearning.util.PasswordUtil;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

public class AdminInstructorApplicationServlet extends HttpServlet {

    private final InstructorApplicationDAO applicationDAO = new InstructorApplicationDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();
    private final InstructorDAO instructorDAO = new InstructorDAOImpl();
    private final NotificationDAO notificationDAO = new NotificationDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Admin".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String statusFilter = request.getParameter("status");
        Integer selectedApplicationId = parseInteger(request.getParameter("applicationId"));
        List<InstructorApplication> applications = applicationDAO.findAll();
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            applications.removeIf(application -> !statusFilter.equalsIgnoreCase(application.getStatus()));
        }

        Integer reviewedBy = resolveUserId(session);
        if (reviewedBy != null && selectedApplicationId != null) {
            notificationDAO.markReadByRecipientUserIdAndEntity(reviewedBy, Notification.TYPE_INSTRUCTOR_APPLICATION, selectedApplicationId);
        }

        InstructorApplication selectedApplication = selectedApplicationId != null ? applicationDAO.findById(selectedApplicationId) : null;
        if (selectedApplication != null && selectedApplication.getReviewedBy() != null) {
            User reviewer = userDAO.findById(selectedApplication.getReviewedBy());
            if (reviewer != null) {
                request.setAttribute("selectedReviewerName", reviewer.getFullName());
            }
        }

        request.setAttribute("applications", applications);
        request.setAttribute("selectedApplication", selectedApplication);
        request.setAttribute("pendingCount", applicationDAO.countByStatus(InstructorApplication.STATUS_PENDING));
        request.setAttribute("approvedCount", applicationDAO.countByStatus(InstructorApplication.STATUS_APPROVED));
        request.setAttribute("rejectedCount", applicationDAO.countByStatus(InstructorApplication.STATUS_REJECTED));
        request.setAttribute("statusFilter", statusFilter);
        if (reviewedBy != null) {
            request.setAttribute("notificationCount", notificationDAO.countUnreadByRecipientUserId(reviewedBy));
        }
        request.getRequestDispatcher("/WEB-INF/views/admin/instructor-applications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Admin".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String applicationIdRaw = request.getParameter("applicationId");
        if (applicationIdRaw == null || applicationIdRaw.trim().isEmpty()) {
            session.setAttribute("error", "Application record was not provided.");
            response.sendRedirect(request.getContextPath() + "/admin/instructor-applications");
            return;
        }

        int applicationId;
        try {
            applicationId = Integer.parseInt(applicationIdRaw);
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid application identifier.");
            response.sendRedirect(request.getContextPath() + "/admin/instructor-applications");
            return;
        }

        InstructorApplication application = applicationDAO.findById(applicationId);
        if (application == null) {
            session.setAttribute("error", "Instructor application not found.");
            response.sendRedirect(request.getContextPath() + "/admin/instructor-applications");
            return;
        }

        Integer reviewedBy = resolveUserId(session);
        if (reviewedBy == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String adminNotes = trim(request.getParameter("adminNotes"));

        if ("approve".equalsIgnoreCase(action)) {
            approveApplication(application, reviewedBy, adminNotes, session);
        } else if ("reject".equalsIgnoreCase(action)) {
            rejectApplication(application, reviewedBy, adminNotes, session);
        } else {
            session.setAttribute("error", "Unsupported application action.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/instructor-applications?applicationId=" + applicationId);
    }

    private void approveApplication(InstructorApplication application, Integer reviewedBy, String adminNotes, HttpSession session) {
        if (userDAO.findByEmail(application.getEmail()) != null) {
            applicationDAO.updateStatus(application.getApplicationId(), InstructorApplication.STATUS_REJECTED, reviewedBy, "Rejected during review: account already exists.");
            persistApplicantDecisionNotification(application, false, "An account with this email already exists.", null, null);
            try {
                EmailUtil.sendInstructorApplicationDecisionEmail(application.getEmail(), application.getFullName(), false, null, null, "An account with this email already exists.");
            } catch (Exception ignored) {
            }
            session.setAttribute("warning", "This applicant already has an account. The application was rejected instead.");
            return;
        }

        String temporaryPassword = PasswordUtil.generateTemporaryPassword();

        User user = new User();
        user.setFullName(application.getFullName());
        user.setEmail(application.getEmail());
        user.setPhone(application.getPhone());
        user.setPasswordHash(PasswordUtil.hashPassword(temporaryPassword));
        user.setRole("Instructor");
        user.setStatus(User.STATUS_ACTIVE);

        User createdUser = userDAO.create(user);
        if (createdUser == null) {
            session.setAttribute("error", "Failed to create the instructor account.");
            return;
        }

        Instructor instructor = new Instructor();
        instructor.setUserId(createdUser.getUserId());
        instructor.setSpecialization(application.getSpecialization());
        instructor.setYearsOfExperience(application.getYearsOfExperience());
        String bio = application.getCoverMessage();
        if (bio == null || bio.trim().isEmpty()) {
            bio = "Approved via instructor application.";
        }
        if (application.getCvPath() != null) {
            bio = bio + "\nCV: " + application.getCvPath();
        }
        instructor.setBio(bio);
        instructor.setCertification(application.getQualification());
        instructor.setHireDate(LocalDate.now());

        if (!instructorDAO.create(instructor)) {
            userDAO.delete(createdUser.getUserId());
            session.setAttribute("error", "The instructor profile could not be created.");
            return;
        }

        boolean updated = applicationDAO.updateStatus(application.getApplicationId(), InstructorApplication.STATUS_APPROVED, reviewedBy, adminNotes);
        if (!updated) {
            session.setAttribute("warning", "The account was created, but the application status could not be updated.");
        } else {
            session.setAttribute("success", "Instructor application approved and account created.");
        }

        persistApplicantDecisionNotification(application, true, adminNotes, createdUser.getEmail(), temporaryPassword);
        try {
            EmailUtil.sendInstructorApplicationDecisionEmail(createdUser.getEmail(), createdUser.getFullName(), true, createdUser.getEmail(), temporaryPassword, adminNotes);
        } catch (Exception ignored) {
        }
    }

    private void rejectApplication(InstructorApplication application, Integer reviewedBy, String adminNotes, HttpSession session) {
        String finalNotes = adminNotes;
        if (finalNotes == null || finalNotes.isEmpty()) {
            finalNotes = "The instructor application was not approved at this time.";
        }

        boolean updated = applicationDAO.updateStatus(application.getApplicationId(), InstructorApplication.STATUS_REJECTED, reviewedBy, finalNotes);
        if (updated) {
            persistApplicantDecisionNotification(application, false, finalNotes, null, null);
            try {
                EmailUtil.sendInstructorApplicationDecisionEmail(application.getEmail(), application.getFullName(), false, null, null, finalNotes);
            } catch (Exception ignored) {
            }
            session.setAttribute("success", "Instructor application rejected.");
        } else {
            session.setAttribute("error", "Failed to reject the instructor application.");
        }
    }

    private void persistApplicantDecisionNotification(InstructorApplication application, boolean approved, String notes, String loginEmail, String temporaryPassword) {
        Notification notification = new Notification();
        notification.setRecipientEmail(application.getEmail());
        notification.setRecipientName(application.getFullName());
        notification.setTitle(approved ? "Instructor application approved" : "Instructor application update");
        StringBuilder message = new StringBuilder();
        if (approved) {
            message.append("Your instructor application was approved.");
            if (loginEmail != null && temporaryPassword != null) {
                message.append(" Login email: ").append(loginEmail).append(".");
            }
        } else {
            message.append("Your instructor application was reviewed and not approved at this time.");
        }
        if (notes != null && !notes.trim().isEmpty()) {
            message.append(" Notes: ").append(notes.trim());
        }
        notification.setMessage(message.toString());
        notification.setNotificationType(Notification.TYPE_INSTRUCTOR_APPLICATION);
        notification.setRelatedEntityType(Notification.TYPE_INSTRUCTOR_APPLICATION);
        notification.setRelatedEntityId(application.getApplicationId());
        notification.setChannel(Notification.CHANNEL_EMAIL);
        notification.setRead(true);
        notificationDAO.create(notification);
    }

    private static String trim(String value) {
        return value == null ? null : value.trim();
    }

    private Integer parseInteger(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ignored) {
            return null;
        }
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