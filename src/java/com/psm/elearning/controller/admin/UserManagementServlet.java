package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.*;
import com.psm.elearning.model.*;
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
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserManagementServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserManagementServlet.class.getName());
    
    private final UserDAO userDAO = new UserDAOImpl();
    private final StudentDAO studentDAO = new StudentDAOImpl();
    private final InstructorDAO instructorDAO = new InstructorDAOImpl();
    private final AdminDAO adminDAO = new AdminDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Admin".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listUsers(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteUser(request, response);
                break;
            case "toggle-status":
                toggleStatus(request, response);
                break;
            default:
                listUsers(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Admin".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            createUser(request, response);
        } else if ("edit".equals(action)) {
            updateUser(request, response);
        } else {
            listUsers(request, response);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<User> users = userDAO.findAll();
        if (users == null) {
            users = new java.util.ArrayList<>();
        }

        java.util.Map<Integer, Student> studentDetailsMap = new java.util.HashMap<>();
        java.util.Map<Integer, Instructor> instructorDetailsMap = new java.util.HashMap<>();
        java.util.Map<Integer, String> studentEnrollmentsMap = new java.util.HashMap<>();
        java.util.Map<Integer, String> instructorCoursesMap = new java.util.HashMap<>();
        java.util.Map<Integer, Integer> instructorMaterialsCountMap = new java.util.HashMap<>();
        java.util.Map<Integer, Integer> instructorAssessmentsCountMap = new java.util.HashMap<>();

        // Load metrics for each user role dynamically
        CourseDAO courseDAO = new CourseDAOImpl();
        MaterialDAO materialDAO = new MaterialDAOImpl();
        AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
        EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();

        for (User u : users) {
            int uid = u.getUserId();
            if ("Student".equals(u.getRole())) {
                Student s = studentDAO.findByUserId(uid);
                if (s != null) {
                    studentDetailsMap.put(uid, s);
                }
                List<Enrollment> enrs = enrollmentDAO.getEnrollmentsByStudent(uid);
                if (enrs != null && !enrs.isEmpty()) {
                    java.util.StringJoiner sj = new java.util.StringJoiner("; ");
                    for (Enrollment e : enrs) {
                        sj.add(e.getCourseName() + " (" + e.getCompletionStatus() + ", " + e.getProgress() + "%)");
                    }
                    studentEnrollmentsMap.put(uid, sj.toString());
                } else {
                    studentEnrollmentsMap.put(uid, "None");
                }
            } else if ("Instructor".equals(u.getRole())) {
                Instructor ins = instructorDAO.findByUserId(uid);
                if (ins != null) {
                    instructorDetailsMap.put(uid, ins);
                }
                List<Course> courses = courseDAO.findByInstructor(uid);
                int matCount = 0;
                int assCount = 0;
                if (courses != null && !courses.isEmpty()) {
                    java.util.StringJoiner sj = new java.util.StringJoiner(", ");
                    for (Course c : courses) {
                        sj.add(c.getCourseName());
                        List<Material> mats = materialDAO.findByCourse(c.getCourseId());
                        if (mats != null) {
                            matCount += mats.size();
                        }
                        List<Assessment> asses = assessmentDAO.findByCourse(c.getCourseId());
                        if (asses != null) {
                            assCount += asses.size();
                        }
                    }
                    instructorCoursesMap.put(uid, sj.toString());
                } else {
                    instructorCoursesMap.put(uid, "None");
                }
                instructorMaterialsCountMap.put(uid, matCount);
                instructorAssessmentsCountMap.put(uid, assCount);
            }
        }

        request.setAttribute("users", users);
        request.setAttribute("studentDetailsMap", studentDetailsMap);
        request.setAttribute("instructorDetailsMap", instructorDetailsMap);
        request.setAttribute("studentEnrollmentsMap", studentEnrollmentsMap);
        request.setAttribute("instructorCoursesMap", instructorCoursesMap);
        request.setAttribute("instructorMaterialsCountMap", instructorMaterialsCountMap);
        request.setAttribute("instructorAssessmentsCountMap", instructorAssessmentsCountMap);
        
        request.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        User user = userDAO.findById(userId);
        
        if (user == null) {
            request.getSession().setAttribute("error", "User not found");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        request.setAttribute("user", user);
        request.setAttribute("editMode", true);
        
        // Load role-specific data
        switch (user.getRole()) {
            case "Student":
                request.setAttribute("student", studentDAO.findByUserId(userId));
                break;
            case "Instructor":
                request.setAttribute("instructor", instructorDAO.findByUserId(userId));
                break;
            case "Admin":
                request.setAttribute("admin", adminDAO.findByUserId(userId));
                break;
        }
        
        request.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(request, response);
    }

    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LOGGER.fine("Entering createUser method");
        
        try {
            // Get common fields
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String password = request.getParameter("password");
            String role = request.getParameter("role");

            LOGGER.log(Level.FINE, "Form data received for role: {0}", role);
            
            // Validate
            if (fullName == null || fullName.trim().isEmpty() || 
                email == null || email.trim().isEmpty() || 
                password == null || password.trim().isEmpty() || 
                role == null || role.trim().isEmpty()) {
                request.getSession().setAttribute("error", "All required fields must be filled");
                response.sendRedirect(request.getContextPath() + "/admin/users?action=create");
                return;
            }
            
            // Check if email exists
            if (userDAO.findByEmail(email) != null) {
                request.getSession().setAttribute("error", "Email already exists");
                response.sendRedirect(request.getContextPath() + "/admin/users?action=create");
                return;
            }
            
            // Store plain password for email (before hashing)
            String plainPassword = password.trim();
            
            // Create user
            User user = new User();
            user.setFullName(fullName.trim());
            user.setEmail(email.trim());
            user.setPhone(phone != null ? phone.trim() : null);
            user.setPasswordHash(PasswordUtil.hashPassword(plainPassword));
            user.setRole(role);
            user.setStatus("Active");
            
            User createdUser = userDAO.create(user);

            LOGGER.log(Level.INFO, "User creation result: {0}", createdUser != null ? "SUCCESS" : "FAILED");
            
            if (createdUser == null) {
                request.getSession().setAttribute("error", "Failed to create user");
                response.sendRedirect(request.getContextPath() + "/admin/users?action=create");
                return;
            }

            LOGGER.log(Level.INFO, "Created UserID: {0}", createdUser.getUserId());
            
            // Create role-specific record and store regNumber for email
            boolean roleCreated = false;
            String regNumber = null;
            
            switch (role) {
                case "Student":
                    Student student = new Student();
                    student.setUserId(createdUser.getUserId());
                    regNumber = studentDAO.getNextRegNumber();
                    student.setRegNumber(regNumber);
                    student.setQualification(request.getParameter("qualification"));
                    student.setCountry(request.getParameter("country"));
                    student.setState(request.getParameter("state"));
                    String dobStr = request.getParameter("dob");
                    if (dobStr != null && !dobStr.isEmpty()) {
                        student.setDob(LocalDate.parse(dobStr));
                    }
                    student.setGender(request.getParameter("gender"));
                    student.setEmergencyContact(request.getParameter("emergencyContact"));
                    roleCreated = studentDAO.create(student);
                    break;
                    
                case "Instructor":
                    Instructor instructor = new Instructor();
                    instructor.setUserId(createdUser.getUserId());
                    instructor.setSpecialization(request.getParameter("specialization"));
                    instructor.setCertification(request.getParameter("certification"));
                    String yearsExpStr = request.getParameter("yearsOfExperience");
                    if (yearsExpStr != null && !yearsExpStr.isEmpty()) {
                        instructor.setYearsOfExperience(Integer.parseInt(yearsExpStr));
                    }
                    instructor.setBio(request.getParameter("bio"));
                    String hireDateStr = request.getParameter("hireDate");
                    if (hireDateStr != null && !hireDateStr.isEmpty()) {
                        instructor.setHireDate(LocalDate.parse(hireDateStr));
                    }
                    roleCreated = instructorDAO.create(instructor);
                    break;
                    
                case "Admin":
                    Admin admin = new Admin();
                    admin.setUserId(createdUser.getUserId());
                    admin.setPosition(request.getParameter("position"));
                    admin.setPermissionLevel(request.getParameter("permissionLevel"));
                    admin.setAssignedDepartment(request.getParameter("assignedDepartment"));
                    roleCreated = adminDAO.create(admin);
                    break;
            }
            
            if (roleCreated) {
                // Send welcome email with credentials
                try {
                    com.psm.elearning.util.EmailUtil.sendAdminUserCreationEmail(
                        createdUser.getEmail(),
                        createdUser.getFullName(),
                        role,
                        plainPassword,
                        regNumber
                    );
                } catch (Exception emailEx) {
                    LOGGER.log(Level.WARNING, "Failed to send user creation email", emailEx);
                }
                
                request.getSession().setAttribute("success", "User created successfully. Check console for email status.");
            } else {
                request.getSession().setAttribute("warning", "User created but role data failed");
            }
            
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error creating user: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            User user = userDAO.findById(userId);
            
            if (user == null) {
                request.getSession().setAttribute("error", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
            
            // Update common fields
            user.setFullName(request.getParameter("fullName").trim());
            user.setPhone(request.getParameter("phone"));
            
            // Update password if provided
            String newPassword = request.getParameter("password");
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                user.setPasswordHash(PasswordUtil.hashPassword(newPassword.trim()));
            }
            
            if (!userDAO.update(user)) {
                request.getSession().setAttribute("error", "Failed to update user");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
            
            // Update role-specific data
            boolean roleUpdated = false;
            switch (user.getRole()) {
                case "Student":
                    Student student = studentDAO.findByUserId(userId);
                    if (student != null) {
                        student.setQualification(request.getParameter("qualification"));
                        student.setCountry(request.getParameter("country"));
                        student.setState(request.getParameter("state"));
                        String dobStr = request.getParameter("dob");
                        if (dobStr != null && !dobStr.isEmpty()) {
                            student.setDob(LocalDate.parse(dobStr));
                        }
                        student.setGender(request.getParameter("gender"));
                        student.setEmergencyContact(request.getParameter("emergencyContact"));
                        roleUpdated = studentDAO.updateProfile(student);
                    }
                    break;
                    
                case "Instructor":
                    Instructor instructor = instructorDAO.findByUserId(userId);
                    if (instructor != null) {
                        instructor.setSpecialization(request.getParameter("specialization"));
                        instructor.setCertification(request.getParameter("certification"));
                        String yearsExpStr = request.getParameter("yearsOfExperience");
                        if (yearsExpStr != null && !yearsExpStr.isEmpty()) {
                            instructor.setYearsOfExperience(Integer.parseInt(yearsExpStr));
                        }
                        instructor.setBio(request.getParameter("bio"));
                        String hireDateStr = request.getParameter("hireDate");
                        if (hireDateStr != null && !hireDateStr.isEmpty()) {
                            instructor.setHireDate(LocalDate.parse(hireDateStr));
                        }
                        roleUpdated = instructorDAO.update(instructor);
                    }
                    break;
                    
                case "Admin":
                    Admin admin = adminDAO.findByUserId(userId);
                    if (admin != null) {
                        admin.setPosition(request.getParameter("position"));
                        admin.setPermissionLevel(request.getParameter("permissionLevel"));
                        admin.setAssignedDepartment(request.getParameter("assignedDepartment"));
                        roleUpdated = adminDAO.update(admin);
                    }
                    break;
            }
            
            if (roleUpdated) {
                request.getSession().setAttribute("success", "User updated successfully");
            } else {
                request.getSession().setAttribute("warning", "User updated but role data may have failed");
            }
            
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error updating user: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String userIdParam = request.getParameter("userId");
        
        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            request.getSession().setAttribute("error", "User ID is required");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }
        
        int userId = Integer.parseInt(userIdParam);
        
        // Get current logged-in user
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        
        // Prevent admin from deleting themselves
        if (currentUser != null && currentUser.getUserId() == userId) {
            request.getSession().setAttribute("error", "You cannot delete your own account");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }
        
        if (userDAO.delete(userId)) {
            request.getSession().setAttribute("success", "User deleted successfully");
        } else {
            request.getSession().setAttribute("error", "Failed to delete user");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void toggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        User user = userDAO.findById(userId);
        
        if (user != null) {
            String newStatus = "Active".equals(user.getStatus()) ? "Suspended" : "Active";
            
            if (userDAO.updateStatus(userId, newStatus)) {
                request.getSession().setAttribute("success", "User status updated to " + newStatus);
            } else {
                request.getSession().setAttribute("error", "Failed to update user status");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
