package com.psm.elearning.dao;

import com.psm.elearning.model.Material;
import java.util.List;

public interface MaterialDAO {
    Material create(Material material);
    Material findById(int materialId);
    List<Material> findByCourse(int courseId);
    boolean update(Material material);
    boolean delete(int materialId);
}
