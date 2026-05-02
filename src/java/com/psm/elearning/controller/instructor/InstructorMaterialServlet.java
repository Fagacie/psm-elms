package com.psm.elearning.controller.instructor;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Material;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

@MultipartConfig(maxFileSize = 52428800) // 50MB
public class InstructorMaterialServlet extends HttpServlet {

    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private static final long MAX_FILE_SIZE = 50L * 1024L * 1024L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null || !isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = request.getParameter("action");
        if (action == null) action = "list";

        if ("delete".equals(action)) {
            deleteMaterial(request, response, userId);
            return;
        }
        if ("restore".equals(action)) {
            restoreMaterial(request, response, userId);
            return;
        }

        loadPage(request, response, userId);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null || !isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = request.getParameter("action");

        if ("update".equals(action)) {
            updateMaterial(request, response, userId);
            return;
        }
        if ("bulkArchive".equals(action)) {
            bulkArchiveMaterials(request, response, userId);
            return;
        }
        if ("bulkRestore".equals(action)) {
            bulkRestoreMaterials(request, response, userId);
            return;
        }
        if ("reorder".equals(action)) {
            reorderMaterial(request, response, userId);
            return;
        }

        createMaterial(request, response, userId);
    }

    private void loadPage(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws ServletException, IOException {

        String courseIdStr = request.getParameter("courseId");
        List<Course> instructorCourses = courseDAO.findByInstructor(userId);
        request.setAttribute("courses", instructorCourses != null ? instructorCourses : new ArrayList<>());

        if (courseIdStr != null && !courseIdStr.trim().isEmpty()) {
            try {
                int courseId = Integer.parseInt(courseIdStr);
                response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "#materials");
                return;
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid course ID.");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/instructor/course-materials.jsp").forward(request, response);
    }

    private void createMaterial(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException, ServletException {

        String courseIdStr = request.getParameter("courseId");
        String title = valueOrEmpty(request.getParameter("title"));
        String description = valueOrEmpty(request.getParameter("description"));
        String materialType = normalizeMaterialType(valueOrEmpty(request.getParameter("materialType")));
        String externalUrl = valueOrEmpty(request.getParameter("externalUrl"));
        Integer displayOrder = parsePositiveInt(request.getParameter("displayOrder"));

        if (courseIdStr.isEmpty() || title.isEmpty() || materialType.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=missing");
            return;
        }

        int courseId;
        try {
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !userId.equals(course.getCreatedBy())) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=permission");
            return;
        }

        String uploadedUrl;
        if (Material.TYPE_LINK.equals(materialType)) {
            if (!isValidHttpUrl(externalUrl)) {
                response.sendRedirect(request.getContextPath() + "/instructor/materials?courseId=" + courseId + "&error=link");
                return;
            }
            uploadedUrl = externalUrl;
        } else {
            Part filePart = request.getPart("materialFile");
            if (filePart == null || filePart.getSize() == 0) {
                response.sendRedirect(request.getContextPath() + "/instructor/materials?courseId=" + courseId + "&error=nofile");
                return;
            }
            if (filePart.getSize() > MAX_FILE_SIZE) {
                response.sendRedirect(request.getContextPath() + "/instructor/materials?courseId=" + courseId + "&error=filesize");
                return;
            }

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String extension = extractExtension(fileName);
            if (!isAllowedExtension(extension) || !isMaterialTypeExtensionCompatible(materialType, extension)) {
                response.sendRedirect(request.getContextPath() + "/instructor/materials?courseId=" + courseId + "&error=filetype");
                return;
            }

            String resourceType = resolveResourceType(extension);
            try (InputStream in = filePart.getInputStream()) {
                uploadedUrl = CloudinaryUtil.uploadFile(in.readAllBytes(), fileName, CloudinaryUtil.getMaterialsFolder(), resourceType);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/instructor/materials?courseId=" + courseId + "&error=upload");
                return;
            }
        }

        if (uploadedUrl == null || uploadedUrl.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?courseId=" + courseId + "&error=upload");
            return;
        }

        Material material = new Material();
        material.setCourseId(courseId);
        material.setTitle(title);
        material.setDescription(description);
        material.setMaterialType(materialType);
        material.setFilePath(uploadedUrl);
        material.setUploadedBy(userId);

        int insertOrder = materialDAO.getMaxDisplayOrder(courseId) + 1;
        material.setDisplayOrder(insertOrder);

        Material created = materialDAO.create(material);
        if (created == null) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=create"));
            return;
        }

        resequenceCourseMaterials(courseId, created.getMaterialId(), displayOrder);

        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "success=created"));
    }

    private void updateMaterial(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException, ServletException {

        String materialIdStr = request.getParameter("materialId");
        String courseIdStr = request.getParameter("courseId");
        if (materialIdStr == null || courseIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        int materialId;
        int courseId;
        try {
            materialId = Integer.parseInt(materialIdStr);
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Material existing = materialDAO.findById(materialId);
        if (course == null || existing == null || !userId.equals(course.getCreatedBy()) || existing.getCourseId() != courseId) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=permission"));
            return;
        }

        existing.setTitle(valueOrEmpty(request.getParameter("title")));
        existing.setDescription(valueOrEmpty(request.getParameter("description")));
        String materialType = normalizeMaterialType(valueOrEmpty(request.getParameter("materialType")));
        if (materialType.isEmpty()) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=missing"));
            return;
        }

        existing.setMaterialType(materialType);

        Integer requestedDisplayOrder = parsePositiveInt(request.getParameter("displayOrder"));
        if (existing.getDisplayOrder() == null) {
            existing.setDisplayOrder(materialDAO.getMaxDisplayOrder(courseId) + 1);
        }

        String externalUrl = valueOrEmpty(request.getParameter("externalUrl"));
        String contentType = request.getContentType();
        boolean isMultipart = contentType != null && contentType.toLowerCase().contains("multipart/");

        if (Material.TYPE_LINK.equals(materialType)) {
            if (!isValidHttpUrl(externalUrl)) {
                response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=link"));
                return;
            }
            existing.setFilePath(externalUrl);
        } else {
            if (isMultipart) {
                Part filePart = request.getPart("materialFile");
                if (filePart != null && filePart.getSize() > 0) {
                    if (filePart.getSize() > MAX_FILE_SIZE) {
                        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=filesize"));
                        return;
                    }
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String extension = extractExtension(fileName);
                    if (!isAllowedExtension(extension) || !isMaterialTypeExtensionCompatible(materialType, extension)) {
                        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=filetype"));
                        return;
                    }
                    try (InputStream in = filePart.getInputStream()) {
                        String uploadedUrl = CloudinaryUtil.uploadFile(in.readAllBytes(), fileName, CloudinaryUtil.getMaterialsFolder(), resolveResourceType(extension));
                        if (uploadedUrl != null && !uploadedUrl.trim().isEmpty()) {
                            existing.setFilePath(uploadedUrl);
                        }
                    } catch (Exception e) {
                        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=upload"));
                        return;
                    }
                }
            }
            String currentExt = extractExtensionFromUrl(existing.getFilePath());
            if (!currentExt.isEmpty() && !isMaterialTypeExtensionCompatible(materialType, currentExt)) {
                response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=filetype"));
                return;
            }
        }

        boolean updated = materialDAO.update(existing);
        if (updated) {
            resequenceCourseMaterials(courseId, existing.getMaterialId(), requestedDisplayOrder);
        }
        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, updated ? "success=updated" : "error=update"));
    }

    private void deleteMaterial(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        String materialIdStr = request.getParameter("id");
        String courseIdStr = request.getParameter("courseId");
        if (materialIdStr == null || courseIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        int materialId;
        int courseId;
        try {
            materialId = Integer.parseInt(materialIdStr);
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Material existing = materialDAO.findById(materialId);
        if (course == null || existing == null || !userId.equals(course.getCreatedBy()) || existing.getCourseId() != courseId) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=permission"));
            return;
        }

        boolean deleted = materialDAO.softDelete(materialId, userId);
        if (deleted) {
            resequenceCourseMaterials(courseId, null, null);
        }
        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, deleted ? "success=deleted" : "error=delete"));
    }

    private void restoreMaterial(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        String materialIdStr = request.getParameter("id");
        String courseIdStr = request.getParameter("courseId");
        if (materialIdStr == null || courseIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        int materialId;
        int courseId;
        try {
            materialId = Integer.parseInt(materialIdStr);
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Material anyMaterial = materialDAO.findAnyById(materialId);
        if (course == null || anyMaterial == null || !userId.equals(course.getCreatedBy()) || anyMaterial.getCourseId() != courseId) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=permission"));
            return;
        }

        boolean restored = materialDAO.restore(materialId);
        if (restored) {
            resequenceCourseMaterials(courseId, materialId, anyMaterial.getDisplayOrder());
        }
        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, restored ? "success=restored" : "error=restore"));
    }

    private void bulkArchiveMaterials(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        String courseIdStr = request.getParameter("courseId");
        String[] materialIds = request.getParameterValues("materialIds");
        if (courseIdStr == null || materialIds == null || materialIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        int courseId;
        try {
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !userId.equals(course.getCreatedBy())) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=permission");
            return;
        }

        boolean changed = false;
        for (String materialIdValue : materialIds) {
            try {
                int materialId = Integer.parseInt(materialIdValue);
                Material existing = materialDAO.findById(materialId);
                if (existing == null || existing.getCourseId() != courseId) {
                    continue;
                }
                changed = materialDAO.softDelete(materialId, userId) || changed;
            } catch (NumberFormatException ignored) {
                // Skip invalid ids and continue with the remaining selection.
            }
        }

        if (changed) {
            resequenceCourseMaterials(courseId, null, null);
        }
        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, changed ? "success=deleted" : "error=delete"));
    }

    private void bulkRestoreMaterials(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        String courseIdStr = request.getParameter("courseId");
        String[] materialIds = request.getParameterValues("materialIds");
        if (courseIdStr == null || materialIds == null || materialIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        int courseId;
        try {
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !userId.equals(course.getCreatedBy())) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=permission");
            return;
        }

        boolean changed = false;
        for (String materialIdValue : materialIds) {
            try {
                int materialId = Integer.parseInt(materialIdValue);
                Material existing = materialDAO.findAnyById(materialId);
                if (existing == null || existing.getCourseId() != courseId) {
                    continue;
                }
                changed = materialDAO.restore(materialId) || changed;
            } catch (NumberFormatException ignored) {
                // Skip invalid ids and continue with the remaining selection.
            }
        }

        if (changed) {
            resequenceCourseMaterials(courseId, null, null);
        }
        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, changed ? "success=restored" : "error=restore"));
    }

    private void reorderMaterial(HttpServletRequest request, HttpServletResponse response, Integer userId)
            throws IOException {

        String courseIdStr = request.getParameter("courseId");
        String materialIdStr = request.getParameter("materialId");
        String direction = valueOrEmpty(request.getParameter("direction"));
        if (courseIdStr == null || materialIdStr == null || direction.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        int courseId;
        int materialId;
        try {
            courseId = Integer.parseInt(courseIdStr);
            materialId = Integer.parseInt(materialIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/instructor/materials?error=invalid");
            return;
        }

        Course course = courseDAO.findById(courseId);
        Material target = materialDAO.findById(materialId);
        if (course == null || target == null || !userId.equals(course.getCreatedBy()) || target.getCourseId() != courseId) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=permission"));
            return;
        }

        List<Material> materials = materialDAO.findByCourse(courseId);
        if (materials == null || materials.isEmpty()) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=update"));
            return;
        }

        int index = -1;
        for (int i = 0; i < materials.size(); i++) {
            Material material = materials.get(i);
            if (material.getMaterialId() != null && material.getMaterialId().equals(materialId)) {
                index = i;
                break;
            }
        }
        if (index < 0) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "error=update"));
            return;
        }

        int swapIndex = "up".equalsIgnoreCase(direction) ? index - 1 : index + 1;
        if (swapIndex < 0 || swapIndex >= materials.size()) {
            response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "success=updated"));
            return;
        }

        Material swap = materials.get(swapIndex);
        Integer targetOrder = target.getDisplayOrder();
        target.setDisplayOrder(swap.getDisplayOrder());
        swap.setDisplayOrder(targetOrder);
        materialDAO.update(target);
        materialDAO.update(swap);
        resequenceCourseMaterials(courseId, null, null);

        response.sendRedirect(workspaceMaterialsRedirect(request, courseId, "success=updated"));
    }

    private boolean isInstructor(HttpSession session) {
        return SessionUtil.resolveUserId(session) != null && "Instructor".equals(SessionUtil.resolveRole(session));
    }

    private String valueOrEmpty(String s) {
        return s == null ? "" : s.trim();
    }

    private Integer parsePositiveInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void resequenceCourseMaterials(int courseId, Integer pinnedMaterialId, Integer desiredOrder) {
        List<Material> materials = materialDAO.findByCourse(courseId);
        if (materials == null || materials.isEmpty()) {
            return;
        }

        Material pinned = null;
        if (pinnedMaterialId != null) {
            for (int i = 0; i < materials.size(); i++) {
                Material candidate = materials.get(i);
                if (candidate.getMaterialId() != null && pinnedMaterialId.equals(candidate.getMaterialId())) {
                    pinned = candidate;
                    materials.remove(i);
                    break;
                }
            }
        }

        if (pinned != null) {
            int fallbackOrder = pinned.getDisplayOrder() != null ? pinned.getDisplayOrder() : (materials.size() + 1);
            int requested = desiredOrder != null ? desiredOrder : fallbackOrder;
            int targetIndex = Math.max(0, Math.min(requested - 1, materials.size()));
            materials.add(targetIndex, pinned);
        }

        int order = 1;
        for (Material material : materials) {
            if (material.getDisplayOrder() == null || material.getDisplayOrder() != order) {
                material.setDisplayOrder(order);
                materialDAO.update(material);
            }
            order++;
        }
    }

    private String extractExtension(String fileName) {
        if (fileName == null) return "";
        int index = fileName.lastIndexOf('.');
        if (index < 0 || index == fileName.length() - 1) return "";
        return fileName.substring(index + 1).toLowerCase();
    }

    private boolean isAllowedExtension(String ext) {
        return "pdf".equals(ext) || "doc".equals(ext) || "docx".equals(ext)
                || "ppt".equals(ext) || "pptx".equals(ext) || "zip".equals(ext)
                || "txt".equals(ext) || "mp4".equals(ext) || "mp3".equals(ext)
                || "webm".equals(ext) || "mov".equals(ext) || "m4v".equals(ext);
    }

    private String normalizeMaterialType(String value) {
        String normalized = valueOrEmpty(value);
        if ("pdf".equalsIgnoreCase(normalized)) return Material.TYPE_PDF;
        if ("video".equalsIgnoreCase(normalized)) return Material.TYPE_VIDEO;
        if ("link".equalsIgnoreCase(normalized)) return Material.TYPE_LINK;
        if ("slides".equalsIgnoreCase(normalized)) return Material.TYPE_SLIDES;
        return normalized;
    }

    private boolean isMaterialTypeExtensionCompatible(String materialType, String ext) {
        if (materialType == null || ext == null) return false;
        String e = ext.toLowerCase();
        if (Material.TYPE_PDF.equals(materialType)) {
            return "pdf".equals(e) || "doc".equals(e) || "docx".equals(e) || "txt".equals(e);
        }
        if (Material.TYPE_SLIDES.equals(materialType)) {
            return "ppt".equals(e) || "pptx".equals(e) || "pdf".equals(e) || "zip".equals(e);
        }
        if (Material.TYPE_VIDEO.equals(materialType)) {
            return "mp4".equals(e) || "mp3".equals(e)
                    || "webm".equals(e) || "mov".equals(e) || "m4v".equals(e);
        }
        return Material.TYPE_LINK.equals(materialType);
    }

    private String extractExtensionFromUrl(String rawUrl) {
        String url = valueOrEmpty(rawUrl);
        int q = url.indexOf('?');
        if (q >= 0) url = url.substring(0, q);
        int dot = url.lastIndexOf('.');
        if (dot < 0 || dot == url.length() - 1) return "";
        return url.substring(dot + 1).toLowerCase();
    }

    private boolean isValidHttpUrl(String rawUrl) {
        try {
            URL url = new URL(valueOrEmpty(rawUrl));
            String protocol = url.getProtocol();
            return "http".equalsIgnoreCase(protocol) || "https".equalsIgnoreCase(protocol);
        } catch (MalformedURLException e) {
            return false;
        }
    }

    private String resolveResourceType(String ext) {
        if ("mp4".equals(ext) || "mp3".equals(ext)
                || "webm".equals(ext) || "mov".equals(ext) || "m4v".equals(ext)) {
            return "video";
        }
        return "raw";
    }

    private String workspaceMaterialsRedirect(HttpServletRequest request, int courseId, String query) {
        StringBuilder builder = new StringBuilder(request.getContextPath())
                .append("/instructor/courses?action=workspace&courseId=")
                .append(courseId);
        if (query != null && !query.trim().isEmpty()) {
            builder.append('&').append(query.trim());
        }
        builder.append("#materials");
        return builder.toString();
    }
}
