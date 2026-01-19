package com.psm.elearning.dao;

import com.psm.elearning.model.Course;
import java.util.List;

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
    List<Course> findFeaturedCourses(int limit);
}
