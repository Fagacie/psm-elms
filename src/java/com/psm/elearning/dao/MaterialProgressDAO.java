package com.psm.elearning.dao;

import java.util.Set;

public interface MaterialProgressDAO {
    boolean markViewed(int userId, int materialId);
    int countViewedByCourse(int userId, int courseId);
    Set<Integer> findViewedMaterialIdsByCourse(int userId, int courseId);
}
