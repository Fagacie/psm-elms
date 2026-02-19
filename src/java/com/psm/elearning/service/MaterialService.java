package com.psm.elearning.service;

import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.exception.ValidationException;
import com.psm.elearning.model.Material;
import com.psm.elearning.util.ValidationUtil;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;

/**
 * Encapsulates material lifecycle logic (validation, sequencing, soft deletes).
 */
public class MaterialService {

    private final MaterialDAO materialDAO;
    private final Validator validator = ValidationUtil.getValidator();

    public MaterialService(MaterialDAO materialDAO) {
        this.materialDAO = Objects.requireNonNull(materialDAO);
    }

    public Material create(Material material, Integer requestedDisplayOrder) {
        Material payload = prepareForPersistence(material, false);
        Material created = materialDAO.create(payload);
        if (created == null) {
            throw new ValidationException("Failed to create material");
        }
        resequenceCourseMaterials(created.getCourseId(), created.getMaterialId(), requestedDisplayOrder);
        return materialDAO.findById(created.getMaterialId());
    }

    public Material update(Material material, Integer requestedDisplayOrder) {
        Material existing = materialDAO.findById(material.getMaterialId());
        if (existing == null) {
            throw new ValidationException("Material not found or has been archived");
        }
        int courseId = existing.getCourseId();
        Material payload = prepareForPersistence(material, true);
        payload.setCourseId(courseId);
        boolean updated = materialDAO.update(payload);
        if (!updated) {
            throw new ValidationException("Material update failed");
        }
        resequenceCourseMaterials(courseId, payload.getMaterialId(), requestedDisplayOrder);
        return materialDAO.findById(payload.getMaterialId());
    }

    public boolean softDelete(int materialId, Integer deletedBy, int courseId) {
        boolean success = materialDAO.softDelete(materialId, deletedBy);
        if (success) {
            resequenceCourseMaterials(courseId, null, null);
        }
        return success;
    }

    public boolean restore(int materialId, int courseId, Integer desiredOrder) {
        boolean success = materialDAO.restore(materialId);
        if (success) {
            resequenceCourseMaterials(courseId, materialId, desiredOrder);
        }
        return success;
    }

    public List<Material> getActiveByCourse(int courseId) {
        return materialDAO.findByCourse(courseId);
    }

    public List<Material> getArchivedByCourse(int courseId) {
        return materialDAO.findDeletedByCourse(courseId);
    }

    private Material prepareForPersistence(Material material, boolean isUpdate) {
        Objects.requireNonNull(material, "material");
        Set<String> errors = new LinkedHashSet<>();

        for (ConstraintViolation<Material> violation : validator.validate(material)) {
            errors.add(violation.getMessage());
        }

        if (material.getCourseId() == null && !isUpdate) {
            errors.add("Course ID is required");
        }

        if (!errors.isEmpty()) {
            throw new ValidationException(errors);
        }

        if (material.getVersionNumber() == null || material.getVersionNumber().trim().isEmpty()) {
            material.setVersionNumber("v1.0");
        }

        Material normalized = new Material();
        normalized.setMaterialId(material.getMaterialId());
        normalized.setCourseId(material.getCourseId());
        normalized.setTitle(material.getTitle());
        normalized.setDescription(Optional.ofNullable(material.getDescription()).map(String::trim).orElse(null));
        normalized.setMaterialType(material.getMaterialType());
        normalized.setFilePath(material.getFilePath());
        normalized.setUploadedBy(material.getUploadedBy());
        normalized.setVersionNumber(material.getVersionNumber());
        normalized.setDisplayOrder(material.getDisplayOrder());

        if (Material.TYPE_LINK.equalsIgnoreCase(normalized.getMaterialType())) {
            validateLink(normalized.getFilePath());
        }

        if (normalized.getDisplayOrder() != null && normalized.getDisplayOrder() < 1) {
            normalized.setDisplayOrder(null);
        }

        if (!isUpdate) {
            int nextOrder = materialDAO.getMaxDisplayOrder(normalized.getCourseId()) + 1;
            normalized.setDisplayOrder(nextOrder);
        }

        return normalized;
    }

    private void validateLink(String value) {
        try {
            URL url = new URL(value);
            String protocol = url.getProtocol();
            if (!"http".equalsIgnoreCase(protocol) && !"https".equalsIgnoreCase(protocol)) {
                throw new ValidationException("Link materials must use http or https");
            }
        } catch (MalformedURLException e) {
            throw new ValidationException("Invalid URL supplied for Link material");
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
            int targetIndex = Math.max(0, Math.min(resolveDesiredOrder(desiredOrder, fallbackOrder) - 1, materials.size()));
            materials.add(targetIndex, pinned);
        }

        int order = 1;
        for (Material m : materials) {
            if (m.getDisplayOrder() == null || m.getDisplayOrder() != order) {
                m.setDisplayOrder(order);
                materialDAO.update(m);
            }
            order++;
        }
    }

    private int resolveDesiredOrder(Integer desiredOrder, int fallback) {
        if (desiredOrder == null || desiredOrder < 1) {
            return fallback;
        }
        return desiredOrder;
    }
}