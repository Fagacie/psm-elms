package com.psm.elearning.dao;

public interface MaterialProgressDAO {
    boolean markViewed(int userId, int materialId);
    int countViewedByCourse(int userId, int courseId);
}
