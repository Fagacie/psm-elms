package com.psm.elearning.controller.instructor;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.SessionUtil;
import com.psm.elearning.service.EnrollmentStateSyncService;
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
import java.util.logging.Level;
import java.util.logging.Logger;
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB
public class InstructorCourseServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(InstructorCourseServlet.class.getName());
    
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate instructor session
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Instructor".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listCourses(request, response, session);
                break;
            case "workspace":
                showCourseWorkspace(request, response, session);
                break;
            case "create":
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=forbidden");
                break;
            case "edit":
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=forbidden");
                break;
            case "students":
                redirectToWorkspaceStudents(request, response);
                break;
            case "delete":
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=forbidden");
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
        if (SessionUtil.resolveUserId(session) == null || !"Instructor".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=forbidden");
        } else if ("update".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=forbidden");
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
            Integer userId = resolveUserId(session);
            if (userId == null) {
                request.setAttribute("errorMessage", "Session error: invalid user context.");
                request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-courses.jsp").forward(request, response);
                return;
            }
            List<Course> courses = courseDAO.findByInstructor(userId);

            java.util.Map<Integer, Integer> courseStudentCounts = new java.util.HashMap<>();
            for (Course course : courses) {
                List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByCourse(course.getCourseId());
                courseStudentCounts.put(course.getCourseId(), enrollments != null ? enrollments.size() : 0);
            }
            
            request.setAttribute("courses", courses);
            request.setAttribute("courseStudentCounts", courseStudentCounts);
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-courses.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error listing instructor courses", e);
            request.setAttribute("errorMessage", "Failed to load courses");
            request.getRequestDispatcher("/WEB-INF/views/instructor/instructor-courses.jsp").forward(request, response);
        }
    }

    private void showCourseWorkspace(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            Integer userId = resolveUserId(session);
            if (userId == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Integer courseId = parsePositiveInt(request.getParameter("courseId"));
            if (courseId == null) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
                return;
            }

            Course course = courseDAO.findById(courseId);
            if (course == null || !userId.equals(course.getCreatedBy())) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
                return;
            }

            List<Material> materials = materialDAO.findByCourse(courseId);
            List<Assessment> assessments = assessmentDAO.findByCourse(courseId);
            List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByCourse(courseId);
            if (materials == null) materials = java.util.Collections.emptyList();
            if (assessments == null) assessments = java.util.Collections.emptyList();
            if (enrollments == null) enrollments = java.util.Collections.emptyList();

            int completedStudents = 0;
            int progressSum = 0;
            for (Enrollment enrollment : enrollments) {
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
                if (enrollment.getProgress() != null) {
                    progressSum += Math.max(0, Math.min(100, enrollment.getProgress()));
                }
                if (Enrollment.STATUS_COMPLETED.equalsIgnoreCase(enrollment.getStatus())
                        || Enrollment.COMPLETION_COMPLETED.equalsIgnoreCase(enrollment.getCompletionStatus())) {
                    completedStudents++;
                }
            }

            int totalStudents = enrollments.size();
            int completionRate = totalStudents > 0 ? Math.round((completedStudents * 100f) / totalStudents) : 0;
            int averageProgress = totalStudents > 0 ? Math.round((float) progressSum / totalStudents) : 0;
            int pendingGrading = countPendingGrading(assessments);

            request.setAttribute("selectedCourse", course);
            request.setAttribute("materials", materials);
            request.setAttribute("assessments", assessments);
            request.setAttribute("enrollments", enrollments);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("completedStudents", completedStudents);
            request.setAttribute("completionRate", completionRate);
            request.setAttribute("averageProgress", averageProgress);
            request.setAttribute("pendingGrading", pendingGrading);
            request.setAttribute("publishedMaterials", materials.size());
            request.setAttribute("deletedMaterials", materialDAO.findDeletedByCourse(courseId));
            request.setAttribute("assessmentCount", assessments.size());
            request.getRequestDispatcher("/WEB-INF/views/instructor/course-workspace.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading course workspace", e);
            request.setAttribute("errorMessage", "Failed to load course workspace");
            listCourses(request, response, session);
        }
    }

    private void redirectToWorkspaceStudents(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer courseId = parsePositiveInt(request.getParameter("courseId"));
        if (courseId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "#students");
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
            LOGGER.log(Level.WARNING, "Course banner upload failed", e);
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

    private Integer parsePositiveInt(String value) {
        if (value == null) {
            return null;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException ex) {
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

    private int countPendingGrading(List<Assessment> assessments) {
        if (assessments == null || assessments.isEmpty()) {
            return 0;
        }

        int pendingCount = 0;
        for (Assessment assessment : assessments) {
            List<AssessmentSubmission> submissions = submissionDAO.findByAssessment(assessment.getAssessmentId());
            if (submissions == null || submissions.isEmpty()) {
                continue;
            }
            for (AssessmentSubmission submission : submissions) {
                if (submission == null) {
                    continue;
                }
                if (submission.getScore() == null && (submission.getStatus() == null || !"TimedOut".equalsIgnoreCase(submission.getStatus()))) {
                    pendingCount++;
                }
            }
        }
        return pendingCount;
    }

    private String resolveRole(HttpSession session) {
        if (session == null) return null;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        if (role == null) return null;
        
        String roleStr = role.toString().trim();
        if ("Admin".equalsIgnoreCase(roleStr)) return "Admin";
        if ("Student".equalsIgnoreCase(roleStr)) return "Student";
        if ("Instructor".equalsIgnoreCase(roleStr)) return "Instructor";
        return null;
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
