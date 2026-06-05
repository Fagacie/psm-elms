package com.psm.elearning.controller.instructor;

import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Material;
import com.psm.elearning.util.AssessmentPlacementUtil;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class InstructorContentOrganizerServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Integer courseId = parseInt(request.getParameter("courseId"));

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
        if (materials == null) materials = new ArrayList<>();
        if (assessments == null) assessments = new ArrayList<>();

        materials.sort((a, b) -> {
            Integer ao = a.getDisplayOrder() != null ? a.getDisplayOrder() : Integer.MAX_VALUE;
            Integer bo = b.getDisplayOrder() != null ? b.getDisplayOrder() : Integer.MAX_VALUE;
            int cmp = ao.compareTo(bo);
            if (cmp != 0) return cmp;
            if (a.getUploadDate() == null && b.getUploadDate() == null) return 0;
            if (a.getUploadDate() == null) return 1;
            if (b.getUploadDate() == null) return -1;
            return a.getUploadDate().compareTo(b.getUploadDate());
        });

        Set<Integer> materialIds = new HashSet<>();
        for (Material material : materials) {
            materialIds.add(material.getMaterialId());
        }

        Map<Integer, List<Assessment>> assessmentsAfterMaterial = new LinkedHashMap<>();
        List<Assessment> finalAssessments = new ArrayList<>();

        for (Assessment assessment : assessments) {
            AssessmentPlacementUtil.Placement placement = resolvePlacement(assessment);
            assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(assessment.getInstructions()));
            if ("afterMaterial".equals(placement.type)
                    && placement.materialId != null
                    && materialIds.contains(placement.materialId)) {
                assessmentsAfterMaterial
                        .computeIfAbsent(placement.materialId, key -> new ArrayList<>())
                        .add(assessment);
            } else {
                finalAssessments.add(assessment);
            }
        }

        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "#materials");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = SessionUtil.resolveUserId(session);
        String action = normalize(request.getParameter("action"));
        Integer courseId = parseInt(request.getParameter("courseId"));

        if (courseId == null) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !userId.equals(course.getCreatedBy())) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?error=permission");
            return;
        }

        if ("reorderMaterials".equals(action)) {
            reorderMaterials(request, response, courseId);
            return;
        } else if ("saveContentOrder".equals(action)) {
            saveContentOrder(request, response, courseId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "#materials");
    }

    private void reorderMaterials(HttpServletRequest request, HttpServletResponse response, Integer courseId)
            throws IOException {

        String[] materialIds = request.getParameterValues("materialIds[]");
        if (materialIds == null || materialIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "&error=invalid#materials");
            return;
        }

        for (int i = 0; i < materialIds.length; i++) {
            Integer materialId = parseInt(materialIds[i]);
            if (materialId != null) {
                Material material = materialDAO.findById(materialId);
                if (material != null && material.getCourseId().equals(courseId)) {
                    material.setDisplayOrder(i + 1);
                    materialDAO.update(material);
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "&success=reordered#materials");
    }

    private void saveContentOrder(HttpServletRequest request, HttpServletResponse response, Integer courseId)
            throws IOException {

        // Update material order
        String[] materialIds = request.getParameterValues("materialIds[]");
        if (materialIds != null) {
            for (int i = 0; i < materialIds.length; i++) {
                Integer materialId = parseInt(materialIds[i]);
                if (materialId != null) {
                    Material material = materialDAO.findById(materialId);
                    if (material != null && material.getCourseId().equals(courseId)) {
                        material.setDisplayOrder(i + 1);
                        materialDAO.update(material);
                    }
                }
            }
        }

        // Update assessment placements
        String[] assessmentIds = request.getParameterValues("assessmentIds[]");
        String[] assessmentMaterials = request.getParameterValues("assessmentMaterials[]");
        
        if (assessmentIds != null && assessmentMaterials != null && assessmentIds.length == assessmentMaterials.length) {
            for (int i = 0; i < assessmentIds.length; i++) {
                Integer assessmentId = parseInt(assessmentIds[i]);
                String materialIdStr = assessmentMaterials[i];
                
                if (assessmentId != null) {
                    Assessment assessment = assessmentDAO.findById(assessmentId);
                    if (assessment != null && assessment.getCourseId().equals(courseId)) {
                        String cleanInstructions = AssessmentPlacementUtil.stripPlacement(assessment.getInstructions());
                        AssessmentPlacementUtil.Placement placement;
                        if ("final".equals(materialIdStr)) {
                            placement = new AssessmentPlacementUtil.Placement("final", null);
                        } else {
                            Integer materialId = parseInt(materialIdStr);
                            if (materialId != null) {
                                Material targetMaterial = materialDAO.findById(materialId);
                                if (targetMaterial != null && courseId.equals(targetMaterial.getCourseId())) {
                                    placement = new AssessmentPlacementUtil.Placement("afterMaterial", materialId);
                                } else {
                                    placement = new AssessmentPlacementUtil.Placement("final", null);
                                }
                            } else {
                                placement = new AssessmentPlacementUtil.Placement("final", null);
                            }
                        }

                        assessment.setInstructions(cleanInstructions);
                        assessment.setPlacementType(placement.type);
                        assessment.setPlacementMaterialId(placement.materialId);
                        assessmentDAO.update(assessment);
                    }
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/instructor/courses?action=workspace&courseId=" + courseId + "&success=reordered#materials");
    }

    private boolean isInstructor(HttpSession session) {
        return SessionUtil.resolveUserId(session) != null && "Instructor".equals(SessionUtil.resolveRole(session));
    }

    private Integer parseInt(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private AssessmentPlacementUtil.Placement resolvePlacement(Assessment assessment) {
        String type = normalize(assessment.getPlacementType());
        if (!type.isEmpty()) {
            Integer materialId = assessment.getPlacementMaterialId();
            if ("afterMaterial".equals(type) && materialId == null) {
                type = "final";
            }
            return new AssessmentPlacementUtil.Placement(type, materialId);
        }
        return AssessmentPlacementUtil.parsePlacement(assessment.getInstructions());
    }
}
