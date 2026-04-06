package com.psm.elearning.controller.instructor;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.util.CloudinaryUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.List;
import java.util.Locale;
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB
public class InstructorCourseServlet extends HttpServlet {
    
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate instructor session
        HttpSession session = request.getSession(false);
        if (session == null || !"Instructor".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listCourses(request, response, session);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "students":
                viewCourseStudents(request, response, session);
                break;
            case "delete":
                deleteCourse(request, response, session);
                break;
            default:
                listCourses(request, response, session);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate instructor session
        HttpSession session = request.getSession(false);
        if (session == null || !"Instructor".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            createCourse(request, response, session);
        } else if ("update".equals(action)) {
            updateCourse(request, response, session);
        } else {
            listCourses(request, response, session);
        }
    }

    /**
     * List all courses created by the logged-in instructor
     */
    private void listCourses(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            List<Course> courses = courseDAO.findByInstructor(userId);
            
            request.setAttribute("courses", courses);
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-courses.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Error listing instructor courses: " + e.getMessage());
            request.setAttribute("errorMessage", "Failed to load courses");
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-courses.jsp").forward(request, response);
        }
    }

    /**
     * Show course creation form
     */
    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("mode", "create");
        request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
    }

    /**
     * Show course edit form with pre-populated data
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int courseId = Integer.parseInt(request.getParameter("id"));
            Course course = courseDAO.findById(courseId);
            
            if (course == null) {
                request.setAttribute("errorMessage", "Course not found");
                listCourses(request, response, request.getSession(false));
                return;
            }
            
            request.setAttribute("course", course);
            request.setAttribute("mode", "edit");
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid course ID");
            listCourses(request, response, request.getSession(false));
        }
    }

    /**
     * Create a new course
     */
    private void createCourse(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            // Get form parameters
            String courseName = request.getParameter("courseName");
            String description = request.getParameter("description");
            String category = request.getParameter("category");
            String durationStr = request.getParameter("duration");
            String durationUnit = request.getParameter("durationUnit");
            String feeStr = request.getParameter("courseFee");
            String level = request.getParameter("level");
            String courseBannerUrl = uploadCourseBannerIfProvided(request);
            if (courseBannerUrl == null && isBannerProvided(request)) {
                request.setAttribute("errorMessage", "Course banner upload failed. Use JPG, PNG, WEBP up to 5MB.");
                request.setAttribute("mode", "create");
                request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
                return;
            }
            
            // Validate required fields
            if (courseName == null || courseName.trim().isEmpty() || 
                feeStr == null || feeStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Course name and fee are required");
                request.setAttribute("mode", "create");
                request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
                return;
            }
            
            // Create course object
            Course course = new Course();
            course.setCourseName(courseName.trim());
            course.setDescription(description != null ? description.trim() : "");
            course.setCategory(category != null ? category.trim() : "");
            
            // Parse duration (stored internally as days)
            if (durationStr != null && !durationStr.trim().isEmpty()) {
                int durationValue = Integer.parseInt(durationStr);
                course.setDuration(toDays(durationValue, durationUnit));
            }
            
            // Parse fee
            course.setCourseFee(new BigDecimal(feeStr));
            course.setLevel(level != null ? level : Course.LEVEL_BEGINNER);
            course.setCreatedBy((Integer) session.getAttribute("userId"));
            course.setStatus(Course.STATUS_PENDING);
            course.setCourseBanner(courseBannerUrl);
            
            // Save course
            Course created = courseDAO.create(course);
            
            if (created != null) {
                request.setAttribute("successMessage", "Course created successfully. Pending admin approval.");
                response.sendRedirect(request.getContextPath() + "/instructor/courses?success=created");
            } else {
                request.setAttribute("errorMessage", "Failed to create course");
                request.setAttribute("mode", "create");
                request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format for duration or fee");
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Error creating course: " + e.getMessage());
            request.setAttribute("errorMessage", "An error occurred while creating the course");
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
        }
    }

    /**
     * Update an existing course
     */
    private void updateCourse(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            Course existingCourse = courseDAO.findById(courseId);
            
            if (existingCourse == null) {
                request.setAttribute("errorMessage", "Course not found");
                listCourses(request, response, session);
                return;
            }
            
            // Verify ownership
            Integer userId = (Integer) session.getAttribute("userId");
            if (!existingCourse.getCreatedBy().equals(userId)) {
                request.setAttribute("errorMessage", "You don't have permission to edit this course");
                listCourses(request, response, session);
                return;
            }
            
            // Get form parameters
            String courseName = request.getParameter("courseName");
            String description = request.getParameter("description");
            String category = request.getParameter("category");
            String durationStr = request.getParameter("duration");
            String durationUnit = request.getParameter("durationUnit");
            String feeStr = request.getParameter("courseFee");
            String level = request.getParameter("level");
            String courseBannerUrl = uploadCourseBannerIfProvided(request);
            if (courseBannerUrl == null && isBannerProvided(request)) {
                request.setAttribute("errorMessage", "Course banner upload failed. Use JPG, PNG, WEBP up to 5MB.");
                request.setAttribute("course", existingCourse);
                request.setAttribute("mode", "edit");
                request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
                return;
            }
            
            // Validate required fields
            if (courseName == null || courseName.trim().isEmpty() || 
                feeStr == null || feeStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Course name and fee are required");
                request.setAttribute("course", existingCourse);
                request.setAttribute("mode", "edit");
                request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
                return;
            }
            
            // Update course object
            existingCourse.setCourseName(courseName.trim());
            existingCourse.setDescription(description != null ? description.trim() : "");
            existingCourse.setCategory(category != null ? category.trim() : "");
            
            // Parse duration (stored internally as days)
            if (durationStr != null && !durationStr.trim().isEmpty()) {
                int durationValue = Integer.parseInt(durationStr);
                existingCourse.setDuration(toDays(durationValue, durationUnit));
            }
            
            // Parse fee
            existingCourse.setCourseFee(new BigDecimal(feeStr));
            existingCourse.setLevel(level != null ? level : Course.LEVEL_BEGINNER);
            if (courseBannerUrl != null && !courseBannerUrl.trim().isEmpty()) {
                existingCourse.setCourseBanner(courseBannerUrl);
            }
            
            // If course was approved, set back to pending after edit
            if (Course.STATUS_APPROVED.equals(existingCourse.getStatus())) {
                existingCourse.setStatus(Course.STATUS_PENDING);
                existingCourse.setApprovedBy(null);
            }

            // Update course
            boolean updated = courseDAO.update(existingCourse);
            
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?success=updated");
            } else {
                request.setAttribute("errorMessage", "Failed to update course");
                request.setAttribute("course", existingCourse);
                request.setAttribute("mode", "edit");
                request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-course-form.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format");
            listCourses(request, response, session);
        } catch (Exception e) {
            System.err.println("Error updating course: " + e.getMessage());
            request.setAttribute("errorMessage", "An error occurred while updating the course");
            listCourses(request, response, session);
        }
    }

    /**
     * Delete a course
     */
    private void deleteCourse(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            int courseId = Integer.parseInt(request.getParameter("id"));
            Course course = courseDAO.findById(courseId);
            
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=notfound");
                return;
            }
            
            // Verify ownership
            Integer userId = (Integer) session.getAttribute("userId");
            if (!course.getCreatedBy().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
                return;
            }
            
            boolean deleted = courseDAO.delete(courseId);
            
            if (deleted) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=deletefailed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=invalid");
        } catch (Exception e) {
            System.err.println("Error deleting course: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=exception");
        }
    }

    /**
     * View students enrolled in a specific course
     */
    private void viewCourseStudents(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            String courseIdStr = request.getParameter("courseId");
            
            if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
                return;
            }
            
            int courseId = Integer.parseInt(courseIdStr);
            Course course = courseDAO.findById(courseId);
            
            // Verify this course belongs to the instructor
            if (course == null || !course.getCreatedBy().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
                return;
            }
            
            // Get all enrollments for this course
            List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByCourse(courseId);
            
            request.setAttribute("course", course);
            request.setAttribute("enrollments", enrollments);
            request.setAttribute("studentCount", enrollments != null ? enrollments.size() : 0);
            request.getRequestDispatcher("/WEB-INF/views/instructor/course-students.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=invalid");
        } catch (Exception e) {
            System.err.println("Error viewing course students: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=exception");
        }
    }

    private boolean isBannerProvided(HttpServletRequest request) {
        try {
            String contentType = request.getContentType();
            if (contentType == null || !contentType.toLowerCase().contains("multipart/")) {
                return false;
            }
            Part part = request.getPart("courseBanner");
            return part != null && part.getSize() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    private String uploadCourseBannerIfProvided(HttpServletRequest request) {
        try {
            String contentType = request.getContentType();
            if (contentType == null || !contentType.toLowerCase().contains("multipart/")) {
                return null;
            }

            Part bannerPart = request.getPart("courseBanner");
            if (bannerPart == null || bannerPart.getSize() == 0) {
                return null;
            }

            String fileName = Paths.get(bannerPart.getSubmittedFileName()).getFileName().toString();
            String ext = extractExtension(fileName);
            if (!isAllowedBannerExtension(ext)) {
                return null;
            }

            try (InputStream in = bannerPart.getInputStream()) {
                return CloudinaryUtil.uploadFile(
                        in.readAllBytes(),
                        fileName,
                        CloudinaryUtil.getCourseBannersFolder(),
                        "image"
                );
            }
        } catch (Exception e) {
            System.err.println("Course banner upload failed: " + e.getMessage());
            return null;
        }
    }

    private String extractExtension(String fileName) {
        if (fileName == null) return "";
        int index = fileName.lastIndexOf('.');
        if (index < 0 || index == fileName.length() - 1) return "";
        return fileName.substring(index + 1).toLowerCase();
    }

    private boolean isAllowedBannerExtension(String ext) {
        return "jpg".equals(ext) || "jpeg".equals(ext) || "png".equals(ext) || "webp".equals(ext);
    }

    private int toDays(int durationValue, String durationUnit) {
        if (durationValue < 1) {
            throw new NumberFormatException("Duration must be at least 1");
        }

        String normalizedUnit = durationUnit == null ? "days" : durationUnit.trim().toLowerCase(Locale.ENGLISH);
        switch (normalizedUnit) {
            case "weeks":
                return durationValue * 7;
            case "months":
                return durationValue * 30;
            case "days":
            default:
                return durationValue;
        }
    }
}
