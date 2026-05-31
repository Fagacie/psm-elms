package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.MaterialProgressDAO;
import com.psm.elearning.dao.MaterialProgressDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.Comparator;
import java.util.stream.Collectors;
import java.util.logging.Logger;

public class StudentMaterialServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StudentMaterialServlet.class.getName());

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final MaterialProgressDAO progressDAO = new MaterialProgressDAOImpl();
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final StudentAccessService studentAccessService = new StudentAccessService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        String role = SessionUtil.resolveRole(session);
        if (userId == null || role == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Ensure user is authorized for the current route path
        String servletPath = request.getServletPath();
        if (servletPath.startsWith("/student/") && !"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        if (servletPath.startsWith("/instructor/") && !"Instructor".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        String action = request.getParameter("action");
        if ("preview".equalsIgnoreCase(action)) {
            showMaterialPreview(request, response, userId);
            return;
        }
        if ("view".equalsIgnoreCase(action) || "download".equalsIgnoreCase(action)) {
            boolean markViewed = false;
            serveMaterialFile(request, response, userId, "download".equalsIgnoreCase(action), markViewed);
            return;
        }

        String courseIdStr = request.getParameter("courseId");
        String keyword = normalize(request.getParameter("keyword"));
        String materialType = normalize(request.getParameter("materialType"));
        String sort = normalize(request.getParameter("sort"));
        if (sort.isEmpty()) sort = "sequence";

        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) enrollments = new ArrayList<>();

        List<Enrollment> accessibleEnrollments = filterAccessibleEnrollments(enrollments);
        request.setAttribute("paidEnrollments", accessibleEnrollments);
        request.setAttribute("visibleCourseCount", accessibleEnrollments.size());
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("selectedMaterialType", materialType);
        request.setAttribute("selectedSort", sort);

        if (accessibleEnrollments.isEmpty()) {
            request.getRequestDispatcher("/WEB-INF/views/student/materials.jsp").forward(request, response);
            return;
        }

        Integer selectedCourseId = null;
        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                selectedCourseId = Integer.parseInt(courseIdStr);
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid course selected.");
            }
        }

        if (selectedCourseId != null) {
            final Integer requestedCourseId = selectedCourseId;
            Enrollment selectedEnrollment = accessibleEnrollments.stream()
                    .filter(e -> e.getCourseId() != null && e.getCourseId().equals(requestedCourseId))
                    .findFirst()
                    .orElse(null);

            if (selectedEnrollment == null) {
                request.setAttribute("errorMessage", "You do not have access to this course materials.");
                selectedCourseId = null;
            }
        }

        List<Enrollment> displayEnrollments = new ArrayList<>();
        if (selectedCourseId == null) {
            displayEnrollments.addAll(accessibleEnrollments);
        } else {
            for (Enrollment enrollment : accessibleEnrollments) {
                if (enrollment.getCourseId() != null && enrollment.getCourseId().equals(selectedCourseId)) {
                    displayEnrollments.add(enrollment);
                    break;
                }
            }
        }

        Map<Integer, List<Material>> materialsByCourse = new LinkedHashMap<>();
        Map<Integer, Course> courseById = new LinkedHashMap<>();
        Map<Integer, Set<Integer>> viewedMaterialIdsByCourse = new LinkedHashMap<>();
        int totalMaterials = 0;
        int totalViewedMaterials = 0;

        for (Enrollment enrollment : displayEnrollments) {
            if (enrollment.getCourseId() == null) continue;
            int courseId = enrollment.getCourseId();
            List<Material> materials = materialDAO.findByCourse(courseId);
            if (materials == null) materials = new ArrayList<>();
            int rawCount = materials.size();
            materials = filterMaterials(materials, keyword, materialType);
            materials = sortMaterials(materials, sort);
            LOGGER.info("StudentMaterialServlet: courseId=" + courseId
                    + ", rawMaterials=" + rawCount
                    + ", filteredMaterials=" + materials.size()
                    + ", keyword='" + keyword + "', materialType='" + materialType + "'");
            materialsByCourse.put(courseId, materials);
            totalMaterials += materials.size();
            Set<Integer> viewedIds = progressDAO.findViewedMaterialIdsByCourse(userId, courseId);
            viewedMaterialIdsByCourse.put(courseId, viewedIds);
            int viewedInFilteredSet = 0;
            for (Material material : materials) {
                if (viewedIds.contains(material.getMaterialId())) {
                    viewedInFilteredSet++;
                }
            }
            totalViewedMaterials += viewedInFilteredSet;

            Course course = courseDAO.findById(courseId);
            if (course != null) {
                courseById.put(courseId, course);
            }
        }

        request.setAttribute("selectedCourseId", selectedCourseId);
        request.setAttribute("displayEnrollments", displayEnrollments);
        request.setAttribute("materialsByCourse", materialsByCourse);
        request.setAttribute("courseById", courseById);
        request.setAttribute("visibleCourseCount", displayEnrollments.size());
        request.setAttribute("totalMaterials", totalMaterials);
        request.setAttribute("totalViewedMaterials", totalViewedMaterials);
        request.setAttribute("viewedMaterialIdsByCourse", viewedMaterialIdsByCourse);

        request.getRequestDispatcher("/WEB-INF/views/student/materials.jsp").forward(request, response);
    }

    private void serveMaterialFile(HttpServletRequest request,
                                   HttpServletResponse response,
                                   Integer userId,
                                   boolean download,
                                   boolean markViewed)
            throws IOException {

        String idStr = normalize(request.getParameter("id"));
        if (idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Material ID is required.");
            return;
        }

        int materialId;
        try {
            materialId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid material ID.");
            return;
        }

        Material material = materialDAO.findById(materialId);
        if (material == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Material not found.");
            return;
        }

        HttpSession session = request.getSession(false);
        String role = SessionUtil.resolveRole(session);
        if (!hasCourseAccess(userId, role, material.getCourseId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to access this file.");
            return;
        }

        if (markViewed && "Student".equals(role)) {
            progressDAO.markInProgress(userId, materialId, material.getCourseId());
        }

        if ("Link".equalsIgnoreCase(material.getMaterialType())) {
            String link = normalize(material.getFilePath());
            String lowerLink = link.toLowerCase(Locale.ENGLISH);
            if (link.isEmpty() || (!lowerLink.startsWith("http://") && !lowerLink.startsWith("https://"))) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid material link.");
                return;
            }
            response.sendRedirect(link);
            return;
        }

        if (isExternalHttpUrl(material.getFilePath())) {
            response.sendRedirect(material.getFilePath());
            return;
        }

        URL url;
        try {
            url = new URL(material.getFilePath());
        } catch (MalformedURLException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Material URL is invalid.");
            return;
        }

        URLConnection connection = url.openConnection();
        connection.setConnectTimeout(15000);
        connection.setReadTimeout(30000);
        if (connection instanceof HttpURLConnection) {
            HttpURLConnection httpConnection = (HttpURLConnection) connection;
            httpConnection.setInstanceFollowRedirects(true);
            int status = httpConnection.getResponseCode();
            if (status >= 400) {
                response.sendError(HttpServletResponse.SC_BAD_GATEWAY, "Unable to fetch material from storage.");
                return;
            }
        }

        String contentType = connection.getContentType();
        if (contentType == null || contentType.trim().isEmpty()) {
            contentType = inferContentType(material.getFilePath());
        }
        response.setContentType(contentType);
        response.setHeader("X-Content-Type-Options", "nosniff");

        String fileName = resolveFileName(material);
        String dispositionType = download ? "attachment" : "inline";
        response.setHeader("Content-Disposition", dispositionType + "; filename=\"" + fileName + "\"");

        try (InputStream in = connection.getInputStream();
             ServletOutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();
        } finally {
            if (connection instanceof HttpURLConnection) {
                ((HttpURLConnection) connection).disconnect();
            }
        }
    }

    private void showMaterialPreview(HttpServletRequest request,
                                     HttpServletResponse response,
                                     Integer userId)
            throws IOException, ServletException {

        HttpSession session = request.getSession(false);
        String role = SessionUtil.resolveRole(session);

        Integer materialId = parseInt(request.getParameter("id"));
        if (materialId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid material ID.");
            return;
        }

        Material material = materialDAO.findById(materialId);
        if (material == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Material not found.");
            return;
        }

        if (!hasCourseAccess(userId, role, material.getCourseId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to preview this material.");
            return;
        }

        Enrollment previewEnrollment = null;
        if ("Student".equals(role)) {
            previewEnrollment = resolvePreviewEnrollment(request, userId, material.getCourseId());
            progressDAO.markInProgress(userId, materialId, material.getCourseId());
        }

        String filePath = normalize(material.getFilePath());
        String extension = extractFileExtension(filePath);
        String servletPath = "Instructor".equals(role) ? "/instructor/materials-preview" : "/student/materials";
        String streamUrl = isExternalHttpUrl(filePath)
            ? filePath
            : request.getContextPath() + servletPath + "?action=view&id=" + materialId;
        List<Material> courseMaterials = materialDAO.findByCourse(material.getCourseId());
        if (courseMaterials == null) {
            courseMaterials = new ArrayList<>();
        }
        List<Material> orderedMaterials = sortMaterials(courseMaterials, "sequence");
        
        Map<Integer, String> statusById = "Student".equals(role)
            ? progressDAO.findMaterialStatusByCourse(userId, material.getCourseId())
            : new java.util.HashMap<>();
            
        Material previousMaterial = null;
        Material nextMaterial = null;
        int materialPosition = 0;

        for (int i = 0; i < orderedMaterials.size(); i++) {
            Material candidate = orderedMaterials.get(i);
            if (candidate.getMaterialId() == null || !candidate.getMaterialId().equals(materialId)) {
                continue;
            }
            materialPosition = i + 1;
            if (i > 0) {
                previousMaterial = orderedMaterials.get(i - 1);
            }
            if (i + 1 < orderedMaterials.size()) {
                nextMaterial = orderedMaterials.get(i + 1);
            }
            break;
        }

        boolean isYouTube = Material.TYPE_YOUTUBE.equalsIgnoreCase(material.getMaterialType())
                || filePath.contains("youtube.com")
                || filePath.contains("youtu.be");
        boolean isLink = Material.TYPE_LINK.equalsIgnoreCase(material.getMaterialType()) && !isYouTube;
        boolean isPdf = "pdf".equals(extension);
        boolean isVideo = ("mp4".equals(extension)
                 || "webm".equals(extension)
                 || "mov".equals(extension)
                 || "m4v".equals(extension)
                 || Material.TYPE_VIDEO.equalsIgnoreCase(material.getMaterialType())) && !isYouTube;
        boolean isAudio = "mp3".equals(extension);
        boolean canInlinePreview = isPdf || isVideo || isAudio;
        boolean isExternalPdf = isPdf && isExternalHttpUrl(filePath);
        // Extract YouTube video ID for iframe embedding
        String youtubeVideoId = "";
        if (isYouTube) {
            youtubeVideoId = extractYouTubeVideoId(filePath);
        }
        String completionRule = resolveCompletionRule(material, extension, isPdf, isVideo, isAudio, isLink, isYouTube);
        String materialStatus = "Student".equals(role) ? normalize(statusById.get(materialId)) : "";
        if (materialStatus.isEmpty()) {
            materialStatus = "in_progress";
        }
        String statusLabel = "completed".equalsIgnoreCase(materialStatus)
                ? "Completed"
                : ("in_progress".equalsIgnoreCase(materialStatus) ? "In Progress" : "Ready");
        String statusClass = "completed".equalsIgnoreCase(materialStatus) ? "status-Approved" : "status-Pending";
        
        String backToHubUrl = previewEnrollment != null
                ? request.getContextPath() + "/student/enrollment-details?id=" + previewEnrollment.getEnrollmentId() + "&tab=learning&materialId=" + material.getMaterialId()
                : request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + material.getCourseId() + "#materials";
        String backToHubLabel = "Student".equals(role) ? "Back to Learning Hub" : "Back to Course Workspace";

        request.setAttribute("material", material);
        request.setAttribute("streamUrl", streamUrl);
        request.setAttribute("isLinkMaterial", isLink);
        request.setAttribute("isYouTubeMaterial", isYouTube);
        request.setAttribute("youtubeVideoId", youtubeVideoId);
        request.setAttribute("isPdfMaterial", isPdf);
        request.setAttribute("isExternalPdfMaterial", isExternalPdf);
        request.setAttribute("isVideoMaterial", isVideo);
        request.setAttribute("isAudioMaterial", isAudio);
        request.setAttribute("canInlinePreview", canInlinePreview);
        request.setAttribute("completionRule", completionRule);
        request.setAttribute("materialStatus", materialStatus);
        request.setAttribute("materialStatusLabel", statusLabel);
        request.setAttribute("materialStatusClass", statusClass);
        request.setAttribute("isCompletedMaterial", "completed".equalsIgnoreCase(materialStatus));
        request.setAttribute("previousMaterial", previousMaterial);
        request.setAttribute("nextMaterial", nextMaterial);
        request.setAttribute("materialPosition", materialPosition);
        request.setAttribute("totalMaterialsInCourse", orderedMaterials.size());
        request.setAttribute("backToHubUrl", backToHubUrl);
        request.setAttribute("backToHubLabel", backToHubLabel);
        request.setAttribute("previewEnrollment", previewEnrollment);
        request.setAttribute("completeActionUrl", request.getContextPath() + "/student/mark-material-completed");

        boolean isFragment = "true".equalsIgnoreCase(request.getParameter("fragment"));
        if (isFragment) {
            request.getRequestDispatcher("/WEB-INF/views/student/fragments/material-viewer-fragment.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/views/student/material-viewer.jsp").forward(request, response);
        }
    }

    private List<Material> filterMaterials(List<Material> materials, String keyword, String materialType) {
        return materials.stream()
                .filter(m -> materialType.isEmpty() || materialType.equalsIgnoreCase(normalize(m.getMaterialType())))
                .filter(m -> {
                    if (keyword.isEmpty()) return true;
                    String title = normalize(m.getTitle());
                    String description = normalize(m.getDescription());
                    String type = normalize(m.getMaterialType());
                    return title.toLowerCase(Locale.ENGLISH).contains(keyword.toLowerCase(Locale.ENGLISH))
                            || description.toLowerCase(Locale.ENGLISH).contains(keyword.toLowerCase(Locale.ENGLISH))
                            || type.toLowerCase(Locale.ENGLISH).contains(keyword.toLowerCase(Locale.ENGLISH));
                })
                .collect(Collectors.toList());
    }

    private List<Material> sortMaterials(List<Material> materials, String sort) {
        Comparator<Material> comparator;
        if ("sequence".equalsIgnoreCase(sort)) {
            comparator = Comparator
                    .comparing((Material m) -> m.getDisplayOrder() == null ? Integer.MAX_VALUE : m.getDisplayOrder())
                    .thenComparing(Material::getUploadDate, Comparator.nullsLast(Comparator.reverseOrder()));
        } else if ("oldest".equalsIgnoreCase(sort)) {
            comparator = Comparator.comparing(Material::getUploadDate, Comparator.nullsLast(Comparator.naturalOrder()));
        } else if ("title".equalsIgnoreCase(sort)) {
            comparator = Comparator.comparing(m -> normalize(m.getTitle()).toLowerCase(Locale.ENGLISH));
        } else if ("type".equalsIgnoreCase(sort)) {
            comparator = Comparator.comparing(m -> normalize(m.getMaterialType()).toLowerCase(Locale.ENGLISH));
        } else {
            comparator = Comparator.comparing(Material::getUploadDate, Comparator.nullsLast(Comparator.reverseOrder()));
        }
        return materials.stream().sorted(comparator).collect(Collectors.toList());
    }

    private boolean hasCourseAccess(Integer userId, String role, Integer courseId) {
        if (userId == null || courseId == null) return false;
        if ("Admin".equals(role)) {
            return true;
        }
        if ("Instructor".equals(role)) {
            Course course = courseDAO.findById(courseId);
            return course != null && userId.equals(course.getCreatedBy());
        }
        
        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) return false;

        for (Enrollment enrollment : enrollments) {
            if (hasEnrollmentAccess(enrollment, courseId)) {
                return true;
            }
        }
        return false;
    }

    private String resolveFileName(Material material) {
        String path = normalize(material.getFilePath());
        int qIndex = path.indexOf('?');
        if (qIndex > -1) {
            path = path.substring(0, qIndex);
        }
        int slashIndex = path.lastIndexOf('/');
        String fileName = slashIndex > -1 ? path.substring(slashIndex + 1) : path;
        if (fileName.isEmpty()) {
            fileName = normalize(material.getTitle()).replaceAll("[^a-zA-Z0-9._-]", "_");
        }
        return fileName.isEmpty() ? "material" : fileName;
    }

    private String inferContentType(String filePath) {
        String lower = normalize(filePath).toLowerCase(Locale.ENGLISH);
        if (lower.endsWith(".pdf")) return "application/pdf";
        if (lower.endsWith(".mp4")) return "video/mp4";
        if (lower.endsWith(".webm")) return "video/webm";
        if (lower.endsWith(".mov")) return "video/quicktime";
        if (lower.endsWith(".m4v")) return "video/x-m4v";
        if (lower.endsWith(".mp3")) return "audio/mpeg";
        if (lower.endsWith(".ppt")) return "application/vnd.ms-powerpoint";
        if (lower.endsWith(".pptx")) return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
        if (lower.endsWith(".doc")) return "application/msword";
        if (lower.endsWith(".docx")) return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        if (lower.endsWith(".zip")) return "application/zip";
        if (lower.endsWith(".txt")) return "text/plain";
        return "application/octet-stream";
    }

    private Enrollment resolvePreviewEnrollment(HttpServletRequest request, Integer userId, Integer courseId) {
        Integer enrollmentId = parseInt(request.getParameter("enrollmentId"));
        if (enrollmentId != null) {
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment != null
                    && enrollment.getUserId() != null
                    && enrollment.getUserId().equals(userId)
                    && enrollment.getCourseId() != null
                    && enrollment.getCourseId().equals(courseId)) {
                return enrollment;
            }
        }

        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) {
            return null;
        }
        for (Enrollment enrollment : enrollments) {
            if (hasEnrollmentAccess(enrollment, courseId)) {
                return enrollment;
            }
        }
        return null;
    }

    private String resolveCompletionRule(Material material,
                                         String extension,
                                         boolean isPdf,
                                         boolean isVideo,
                                         boolean isAudio,
                                         boolean isLink,
                                         boolean isYouTube) {
        if (isVideo) { return "video"; }
        if (isAudio) { return "audio"; }
        if (isPdf)   { return "document"; }
        if (isLink)  { return "link"; }
        if (isYouTube) { return "youtube"; }
        if ("ppt".equals(extension) || "pptx".equals(extension) || Material.TYPE_SLIDES.equalsIgnoreCase(material.getMaterialType())) {
            return "slides";
        }
        return "default";
    }

    /** Extracts YouTube video ID from various URL formats. */
    private String extractYouTubeVideoId(String url) {
        if (url == null || url.isEmpty()) return "";
        // youtu.be/ID
        if (url.contains("youtu.be/")) {
            String[] parts = url.split("youtu\\.be/");
            if (parts.length > 1) {
                String id = parts[1].split("[?&]")[0];
                return id.trim();
            }
        }
        // youtube.com/shorts/ID
        if (url.contains("/shorts/")) {
            String[] parts = url.split("/shorts/");
            if (parts.length > 1) {
                String id = parts[1].split("[?&]")[0];
                return id.trim();
            }
        }
        // youtube.com/watch?v=ID
        if (url.contains("v=")) {
            String[] parts = url.split("v=");
            if (parts.length > 1) {
                String id = parts[1].split("[?&]")[0];
                return id.trim();
            }
        }
        // youtube.com/embed/ID
        if (url.contains("/embed/")) {
            String[] parts = url.split("/embed/");
            if (parts.length > 1) {
                String id = parts[1].split("[?&]")[0];
                return id.trim();
            }
        }
        return "";
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private List<Enrollment> filterAccessibleEnrollments(List<Enrollment> enrollments) {
        return enrollments.stream()
                .filter(this::hasEnrollmentAccess)
                .collect(Collectors.toList());
    }

    private boolean hasEnrollmentAccess(Enrollment enrollment) {
        return enrollment != null && hasEnrollmentAccess(enrollment, enrollment.getCourseId());
    }

    private boolean hasEnrollmentAccess(Enrollment enrollment, Integer courseId) {
        if (enrollment == null || courseId == null) {
            return false;
        }
        if (enrollment.getCourseId() == null || !enrollment.getCourseId().equals(courseId)) {
            return false;
        }
        return studentAccessService.hasCourseAccess(enrollment);
    }

    private boolean isFreeEnrollment(Enrollment enrollment) {
        return studentAccessService.isFreeEnrollment(enrollment);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private String extractFileExtension(String path) {
        String cleanPath = normalize(path);
        int queryIndex = cleanPath.indexOf('?');
        if (queryIndex > -1) {
            cleanPath = cleanPath.substring(0, queryIndex);
        }
        int dotIndex = cleanPath.lastIndexOf('.');
        if (dotIndex < 0 || dotIndex == cleanPath.length() - 1) {
            return "";
        }
        return cleanPath.substring(dotIndex + 1).toLowerCase(Locale.ENGLISH);
    }

    private boolean isExternalHttpUrl(String value) {
        String normalized = normalize(value).toLowerCase(Locale.ENGLISH);
        return normalized.startsWith("http://") || normalized.startsWith("https://");
    }

}
