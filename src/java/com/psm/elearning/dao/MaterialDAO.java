package com.psm.elearning.dao;

import com.psm.elearning.model.Material;
import java.util.List;

public interface MaterialDAO {
    Material create(Material material);
    Material findById(int materialId);
    Material findAnyById(int materialId);
    List<Material> findByCourse(int courseId);
    List<Material> findByCourseIds(List<Integer> courseIds);
    List<Material> findDeletedByCourse(int courseId);
    boolean update(Material material);
    boolean delete(int materialId);
    boolean softDelete(int materialId, Integer deletedBy);
    boolean restore(int materialId);
    int getMaxDisplayOrder(int courseId);
    boolean shiftDisplayOrderFrom(int courseId, int fromOrder, Integer excludeMaterialId);
}
