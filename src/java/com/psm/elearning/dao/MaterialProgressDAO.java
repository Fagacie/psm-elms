package com.psm.elearning.dao;

import java.util.Map;
import java.util.Set;

public interface MaterialProgressDAO {
    boolean markViewed(int userId, int materialId);
    boolean markInProgress(int userId, int materialId, int courseId);
    boolean markCompleted(int userId, int materialId, int courseId);
    int countViewedByCourse(int userId, int courseId);
    Set<Integer> findViewedMaterialIdsByCourse(int userId, int courseId);
    Map<Integer, String> findMaterialStatusByCourse(int userId, int courseId);
}
