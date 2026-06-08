package com.psm.elearning.dao;

import com.psm.elearning.model.Course;
import java.util.List;
import java.util.Map;

public interface CourseDAO {
    Course create(Course course);
    boolean update(Course course);
    boolean delete(int courseId);
    Course findById(int courseId);
    List<Course> findAll();
    List<Course> findByStatus(String status);
    List<Course> findByInstructor(int instructorId);
    boolean approve(int courseId, int approvedBy);
    boolean reject(int courseId);
    List<Course> searchCourses(String keyword);
    List<Course> filterCourses(String category, String level, Double minFee, Double maxFee);
    int countByStatus(String status);
    /**
     * Returns course counts grouped by status in a single DB round-trip.
     * Keys are the Status values found in the Course table (e.g., "Approved", "Pending", "Archived").
     * Missing statuses will not appear in the returned map (check with getOrDefault).
     */
    Map<String, Integer> getCourseCountsByStatus();
    List<Course> findFeaturedCourses(int limit);
    boolean updateStatus(int courseId, String status);
    boolean assignInstructor(int courseId, int instructorId);
    List<Course> findByCourseIds(List<Integer> courseIds);
}
