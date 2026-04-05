package com.psm.elearning.dao;

import java.util.List;
import java.util.Map;

public interface ReportDAO {
    Map<String, Object> getAdminSummary(String startDate, String endDate);
    List<Map<String, Object>> getTopCoursesByEnrollment(int limit, String startDate, String endDate);
    List<Map<String, Object>> getRevenueByCourse(int limit, String startDate, String endDate);
    List<Map<String, Object>> getRecentExports(int limit);

    Map<String, Object> getInstructorSummary(int instructorId);
    List<Map<String, Object>> getInstructorCoursePerformance(int instructorId, int limit);

    Map<String, Object> getStudentSummary(int studentId);
    List<Map<String, Object>> getStudentCourseProgress(int studentId, int limit);

    boolean saveGeneratedReport(Integer userId, String role, String reportType, String filtersJson, String exportFormat, String filePath);
    boolean logReportAccess(Integer userId, String role, String reportType, String filtersJson, String accessStatus, String ipAddress);
}
