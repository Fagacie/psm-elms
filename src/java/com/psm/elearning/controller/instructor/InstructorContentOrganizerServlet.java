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

        Integer userId = (Integer) session.getAttribute("userId");
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
            AssessmentPlacementUtil.Placement placement = AssessmentPlacementUtil.parsePlacement(assessment.getInstructions());
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

        request.setAttribute("course", course);
        request.setAttribute("materials", materials);
        request.setAttribute("assessmentsAfterMaterial", assessmentsAfterMaterial);
        request.setAttribute("finalAssessments", finalAssessments);
        request.getRequestDispatcher("/WEB-INF/views/instructor/content-organizer.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isInstructor(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
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

        response.sendRedirect(request.getContextPath() + "/instructor/content-organizer?courseId=" + courseId);
    }

    private void reorderMaterials(HttpServletRequest request, HttpServletResponse response, Integer courseId)
            throws IOException {

        String[] materialIds = request.getParameterValues("materialIds[]");
        if (materialIds == null || materialIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/instructor/content-organizer?courseId=" + courseId + "&error=invalid");
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

        response.sendRedirect(request.getContextPath() + "/instructor/content-organizer?courseId=" + courseId + "&success=reordered");
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
                        // Strip existing placement
                        String cleanInstructions = AssessmentPlacementUtil.stripPlacement(assessment.getInstructions());
                        
                        // Apply new placement
                        String newInstructions;
                        if ("final".equals(materialIdStr)) {
                            newInstructions = AssessmentPlacementUtil.applyPlacement(cleanInstructions, "final");
                        } else {
                            newInstructions = AssessmentPlacementUtil.applyPlacement(cleanInstructions, "material:" + materialIdStr);
                        }
                        
                        assessment.setInstructions(newInstructions);
                        assessmentDAO.update(assessment);
                    }
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/instructor/content-organizer?courseId=" + courseId + "&success=reordered");
    }

    private boolean isInstructor(HttpSession session) {
        return session != null && "Instructor".equals(session.getAttribute("userRole"));
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
}
