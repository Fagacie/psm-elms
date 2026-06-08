package com.psm.elearning.dao;

import com.psm.elearning.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportDAOImpl implements ReportDAO {

    @Override
    public Map<String, Object> getAdminSummary(String startDate, String endDate) {
        String sql = "SELECT " +
                "(SELECT COUNT(*) FROM User) AS totalUsers, " +
                "(SELECT COUNT(*) FROM User WHERE Role='Student') AS totalStudents, " +
                "(SELECT COUNT(*) FROM User WHERE Role='Instructor') AS totalInstructors, " +
                "(SELECT COUNT(*) FROM Course) AS totalCourses, " +
                "(SELECT COUNT(*) FROM Enrollment) AS totalEnrollments, " +
                "(SELECT COUNT(*) FROM Enrollment WHERE CompletionStatus='Completed' OR Status='Completed') AS completedEnrollments, " +
                "(SELECT COUNT(*) FROM Certificate WHERE Status='Active') AS activeCertificates, " +
                "(SELECT COALESCE(SUM(Amount), 0) FROM Payment WHERE PaymentStatus = 'Paid') AS totalRevenue";

        Map<String, Object> row = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                row.put("totalUsers", rs.getInt("totalUsers"));
                row.put("totalStudents", rs.getInt("totalStudents"));
                row.put("totalInstructors", rs.getInt("totalInstructors"));
                row.put("totalCourses", rs.getInt("totalCourses"));
                row.put("totalEnrollments", rs.getInt("totalEnrollments"));
                row.put("completedEnrollments", rs.getInt("completedEnrollments"));
                row.put("activeCertificates", rs.getInt("activeCertificates"));
                row.put("totalRevenue", rs.getDouble("totalRevenue"));

                if (isDateRangeProvided(startDate, endDate)) {
                    row.put("filteredEnrollments", countByDateRange(conn,
                            "SELECT COUNT(*) FROM Enrollment WHERE DATE(EnrollmentDate) BETWEEN ? AND ?",
                            startDate, endDate));
                    row.put("filteredCompletedEnrollments", countByDateRange(conn,
                            "SELECT COUNT(*) FROM Enrollment WHERE (CompletionStatus='Completed' OR Status='Completed') AND DATE(EnrollmentDate) BETWEEN ? AND ?",
                            startDate, endDate));
                    row.put("filteredRevenue", sumByDateRange(conn,
                            "SELECT COALESCE(SUM(Amount), 0) FROM Payment WHERE PaymentStatus = 'Paid' AND DATE(COALESCE(PaymentDate, CreatedAt)) BETWEEN ? AND ?",
                            startDate, endDate));
                    row.put("newUsersInRange", countByDateRange(conn,
                            "SELECT COUNT(*) FROM User WHERE DATE(CreatedAt) BETWEEN ? AND ?",
                            startDate, endDate));
                } else {
                    row.put("filteredEnrollments", rs.getInt("totalEnrollments"));
                    row.put("filteredCompletedEnrollments", rs.getInt("completedEnrollments"));
                    row.put("filteredRevenue", rs.getDouble("totalRevenue"));
                    row.put("newUsersInRange", 0);
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getAdminSummary failed: " + e.getMessage());
        }
        return row;
    }

    @Override
    public List<Map<String, Object>> getTopCoursesByEnrollment(int limit, String startDate, String endDate) {
        StringBuilder sql = new StringBuilder("SELECT c.CourseID, c.Title, " +
                "COUNT(e.EnrollmentID) AS enrollments, " +
                "SUM(CASE WHEN e.CompletionStatus='Completed' OR e.Status='Completed' THEN 1 ELSE 0 END) AS completions, " +
                "ROUND(AVG(COALESCE(e.Progress, 0)), 0) AS avgProgress " +
                "FROM Course c " +
                "LEFT JOIN Enrollment e ON e.CourseID = c.CourseID");

        if (isDateRangeProvided(startDate, endDate)) {
            sql.append(" AND DATE(e.EnrollmentDate) BETWEEN ? AND ?");
        }
        sql.append(" GROUP BY c.CourseID, c.Title ORDER BY enrollments DESC, c.Title ASC LIMIT ?");

        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;
            if (isDateRangeProvided(startDate, endDate)) {
                ps.setString(index++, startDate);
                ps.setString(index++, endDate);
            }
            ps.setInt(index, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("courseId", rs.getInt("CourseID"));
                    row.put("title", rs.getString("Title"));
                    row.put("enrollments", rs.getInt("enrollments"));
                    row.put("completions", rs.getInt("completions"));
                    row.put("avgProgress", rs.getInt("avgProgress"));
                    int enrollments = rs.getInt("enrollments");
                    int completions = rs.getInt("completions");
                    int completionRate = enrollments > 0 ? Math.round((float) completions * 100f / (float) enrollments) : 0;
                    row.put("completionRate", completionRate);
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getTopCoursesByEnrollment failed: " + e.getMessage());
        }
        return rows;
    }

    @Override
    public List<Map<String, Object>> getRevenueByCourse(int limit, String startDate, String endDate) {
        StringBuilder sql = new StringBuilder("SELECT c.CourseID, c.Title, " +
                "COUNT(DISTINCT e.EnrollmentID) AS enrollments, " +
                "COALESCE(SUM(CASE WHEN p.PaymentStatus = 'Paid' THEN p.Amount ELSE 0 END), 0) AS revenue " +
                "FROM Course c " +
                "LEFT JOIN Enrollment e ON e.CourseID = c.CourseID " +
                "LEFT JOIN Payment p ON p.EnrollmentID = e.EnrollmentID");

        if (isDateRangeProvided(startDate, endDate)) {
            sql.append(" AND DATE(COALESCE(p.PaymentDate, p.CreatedAt)) BETWEEN ? AND ?");
        }
        sql.append(" GROUP BY c.CourseID, c.Title ORDER BY revenue DESC, c.Title ASC LIMIT ?");

        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;
            if (isDateRangeProvided(startDate, endDate)) {
                ps.setString(index++, startDate);
                ps.setString(index++, endDate);
            }
            ps.setInt(index, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("courseId", rs.getInt("CourseID"));
                    row.put("title", rs.getString("Title"));
                    row.put("enrollments", rs.getInt("enrollments"));
                    row.put("revenue", rs.getDouble("revenue"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getRevenueByCourse failed: " + e.getMessage());
        }
        return rows;
    }

    @Override
    public List<Map<String, Object>> getRecentExports(int limit) {
        String sql = "SELECT ExportID, ReportType, ExportFormat, FiltersJson, CreatedAt " +
                "FROM ReportExport ORDER BY CreatedAt DESC LIMIT ?";
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("exportId", rs.getInt("ExportID"));
                    row.put("reportType", rs.getString("ReportType"));
                    row.put("exportFormat", rs.getString("ExportFormat"));
                    row.put("filtersJson", rs.getString("FiltersJson"));
                    row.put("createdAt", rs.getTimestamp("CreatedAt"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getRecentExports failed: " + e.getMessage());
        }
        return rows;
    }

    @Override
    public List<Map<String, Object>> getUserRoleBreakdown() {
        return loadBreakdown("SELECT Role AS label, COUNT(*) AS count FROM User GROUP BY Role ORDER BY FIELD(Role, 'Admin', 'Instructor', 'Student')");
    }

    @Override
    public List<Map<String, Object>> getUserStatusBreakdown() {
        return loadBreakdown("SELECT Status AS label, COUNT(*) AS count FROM User GROUP BY Status ORDER BY FIELD(Status, 'Active', 'Pending', 'Suspended')");
    }

    @Override
    public List<Map<String, Object>> getCourseStatusBreakdown() {
        return loadBreakdown("SELECT Status AS label, COUNT(*) AS count FROM Course GROUP BY Status ORDER BY FIELD(Status, 'Approved', 'Pending', 'Archived')");
    }

    @Override
    public List<Map<String, Object>> getEnrollmentStatusBreakdown() {
        return loadBreakdown("SELECT Status AS label, COUNT(*) AS count FROM Enrollment GROUP BY Status ORDER BY FIELD(Status, 'Active', 'Enrolled', 'Completed', 'Pending', 'Cancelled')");
    }

    @Override
    public List<Map<String, Object>> getPaymentStatusBreakdown() {
        return loadBreakdown("SELECT PaymentStatus AS label, COUNT(*) AS count FROM Payment GROUP BY PaymentStatus ORDER BY FIELD(PaymentStatus, 'Paid', 'Pending', 'Failed', 'Abandoned')");
    }

    @Override
    public List<Map<String, Object>> getCertificateStatusBreakdown() {
        return loadBreakdown("SELECT Status AS label, COUNT(*) AS count FROM Certificate GROUP BY Status ORDER BY FIELD(Status, 'Active', 'Revoked')");
    }

    @Override
    public Map<String, Object> getAssessmentSummary() {
        String sql = "SELECT " +
                "(SELECT COUNT(*) FROM Assessment) AS totalAssessments, " +
                "(SELECT COUNT(*) FROM Assessment WHERE IsDeleted = 0) AS activeAssessments, " +
                "(SELECT COUNT(*) FROM Assessment WHERE IsDeleted = 1) AS deletedAssessments, " +
                "(SELECT COUNT(*) FROM AssessmentQuestion) AS totalQuestions, " +
                "(SELECT COUNT(*) FROM AssessmentSubmission) AS totalSubmissions, " +
                "(SELECT COUNT(*) FROM AssessmentSubmission WHERE Status = 'Graded') AS gradedSubmissions, " +
                "(SELECT COUNT(*) FROM AssessmentSubmission WHERE Status IN ('Submitted', 'TimedOut', 'AutoSubmitted')) AS pendingSubmissions, " +
                "(SELECT COUNT(*) FROM AssessmentRetakeRequest WHERE Status = 'Pending') AS pendingRetakeRequests";

        Map<String, Object> row = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                row.put("totalAssessments", rs.getInt("totalAssessments"));
                row.put("activeAssessments", rs.getInt("activeAssessments"));
                row.put("deletedAssessments", rs.getInt("deletedAssessments"));
                row.put("totalQuestions", rs.getInt("totalQuestions"));
                row.put("totalSubmissions", rs.getInt("totalSubmissions"));
                row.put("gradedSubmissions", rs.getInt("gradedSubmissions"));
                row.put("pendingSubmissions", rs.getInt("pendingSubmissions"));
                row.put("pendingRetakeRequests", rs.getInt("pendingRetakeRequests"));
            }
        } catch (SQLException e) {
            System.err.println("Report getAssessmentSummary failed: " + e.getMessage());
        }
        return row;
    }

    @Override
    public List<Map<String, Object>> getAssessmentGradingModeBreakdown() {
        return loadBreakdown("SELECT GradingMode AS label, COUNT(*) AS count FROM Assessment GROUP BY GradingMode ORDER BY FIELD(GradingMode, 'auto', 'manual')");
    }

    @Override
    public List<Map<String, Object>> getAssessmentSubmissionModeBreakdown() {
        return loadBreakdown("SELECT SubmissionMode AS label, COUNT(*) AS count FROM Assessment GROUP BY SubmissionMode ORDER BY FIELD(SubmissionMode, 'both', 'file', 'text')");
    }

    @Override
    public List<Map<String, Object>> getReportAccessStatusBreakdown() {
        return loadBreakdown("SELECT AccessStatus AS label, COUNT(*) AS count FROM ReportAccessLog GROUP BY AccessStatus ORDER BY FIELD(AccessStatus, 'Success', 'Failed', 'Denied')");
    }

    @Override
    public Map<String, Object> getInstructorSummary(int instructorId) {
        String sql = "SELECT " +
                "COUNT(DISTINCT c.CourseID) AS totalCourses, " +
                "COUNT(e.EnrollmentID) AS totalEnrollments, " +
                "SUM(CASE WHEN e.CompletionStatus='Completed' OR e.Status='Completed' THEN 1 ELSE 0 END) AS completedEnrollments, " +
                "ROUND(AVG(COALESCE(e.Progress, 0)), 0) AS avgProgress, " +
                "COALESCE(SUM(CASE WHEN p.PaymentStatus = 'Paid' THEN p.Amount ELSE 0 END), 0) AS totalRevenue " +
                "FROM Course c " +
                "LEFT JOIN Enrollment e ON e.CourseID = c.CourseID " +
                "LEFT JOIN Payment p ON p.EnrollmentID = e.EnrollmentID " +
                "WHERE c.InstructorID = ?";

        Map<String, Object> row = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    row.put("totalCourses", rs.getInt("totalCourses"));
                    row.put("totalEnrollments", rs.getInt("totalEnrollments"));
                    row.put("completedEnrollments", rs.getInt("completedEnrollments"));
                    row.put("avgProgress", rs.getInt("avgProgress"));
                    row.put("totalRevenue", rs.getDouble("totalRevenue"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getInstructorSummary failed: " + e.getMessage());
        }
        return row;
    }

    @Override
    public List<Map<String, Object>> getInstructorCoursePerformance(int instructorId, int limit) {
        String sql = "SELECT c.CourseID, c.Title, " +
                "COUNT(e.EnrollmentID) AS enrollments, " +
                "SUM(CASE WHEN e.CompletionStatus='Completed' OR e.Status='Completed' THEN 1 ELSE 0 END) AS completions, " +
                "ROUND(AVG(COALESCE(e.Progress, 0)), 0) AS avgProgress " +
                "FROM Course c " +
                "LEFT JOIN Enrollment e ON e.CourseID = c.CourseID " +
                "WHERE c.InstructorID = ? " +
                "GROUP BY c.CourseID, c.Title " +
                "ORDER BY enrollments DESC, c.Title ASC " +
                "LIMIT ?";

        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, instructorId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("courseId", rs.getInt("CourseID"));
                    row.put("title", rs.getString("Title"));
                    row.put("enrollments", rs.getInt("enrollments"));
                    row.put("completions", rs.getInt("completions"));
                    row.put("avgProgress", rs.getInt("avgProgress"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getInstructorCoursePerformance failed: " + e.getMessage());
        }
        return rows;
    }

    @Override
    public Map<String, Object> getStudentSummary(int studentId) {
        String sql = "SELECT " +
                "COUNT(e.EnrollmentID) AS totalEnrollments, " +
                "SUM(CASE WHEN e.Status='Active' OR e.CompletionStatus='In Progress' THEN 1 ELSE 0 END) AS activeEnrollments, " +
                "SUM(CASE WHEN e.CompletionStatus='Completed' OR e.Status='Completed' THEN 1 ELSE 0 END) AS completedEnrollments, " +
                "ROUND(AVG(COALESCE(e.Progress, 0)), 0) AS avgProgress, " +
                "SUM(CASE WHEN e.PaymentStatus='Paid' THEN 1 ELSE 0 END) AS paidEnrollments, " +
                "(SELECT COUNT(*) FROM Certificate c JOIN Enrollment ce ON ce.EnrollmentID = c.EnrollmentID WHERE ce.UserID = ? AND c.Status='Active') AS certificates " +
                "FROM Enrollment e WHERE e.UserID = ?";

        Map<String, Object> row = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    row.put("totalEnrollments", rs.getInt("totalEnrollments"));
                    row.put("activeEnrollments", rs.getInt("activeEnrollments"));
                    row.put("completedEnrollments", rs.getInt("completedEnrollments"));
                    row.put("avgProgress", rs.getInt("avgProgress"));
                    row.put("paidEnrollments", rs.getInt("paidEnrollments"));
                    row.put("certificates", rs.getInt("certificates"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getStudentSummary failed: " + e.getMessage());
        }
        return row;
    }

    @Override
    public List<Map<String, Object>> getStudentCourseProgress(int studentId, int limit) {
        String sql = "SELECT e.EnrollmentID, c.Title, c.Level, e.Status, e.CompletionStatus, COALESCE(e.Progress,0) AS Progress, e.PaymentStatus " +
                "FROM Enrollment e JOIN Course c ON c.CourseID = e.CourseID " +
                "WHERE e.UserID = ? ORDER BY e.EnrollmentDate DESC LIMIT ?";

        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("enrollmentId", rs.getInt("EnrollmentID"));
                    row.put("title", rs.getString("Title"));
                    row.put("level", rs.getString("Level"));
                    row.put("status", rs.getString("Status"));
                    row.put("completionStatus", rs.getString("CompletionStatus"));
                    row.put("progress", rs.getInt("Progress"));
                    row.put("paymentStatus", rs.getString("PaymentStatus"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("Report getStudentCourseProgress failed: " + e.getMessage());
        }
        return rows;
    }

    @Override
    public boolean saveGeneratedReport(Integer userId, String role, String reportType, String filtersJson, String exportFormat, String filePath) {
        String sql = "INSERT INTO ReportExport (UserID, RoleName, ReportType, FiltersJson, ExportFormat, FilePath) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, role);
            ps.setString(3, reportType);
            ps.setString(4, filtersJson);
            ps.setString(5, exportFormat);
            ps.setString(6, filePath);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Report saveGeneratedReport failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean logReportAccess(Integer userId, String role, String reportType, String filtersJson, String accessStatus, String ipAddress) {
        String sql = "INSERT INTO ReportAccessLog (UserID, RoleName, ReportType, FiltersJson, AccessStatus, IPAddress) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, role);
            ps.setString(3, reportType);
            ps.setString(4, filtersJson);
            ps.setString(5, accessStatus);
            ps.setString(6, ipAddress);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Report logReportAccess failed: " + e.getMessage());
            return false;
        }
    }

    private boolean isDateRangeProvided(String startDate, String endDate) {
        return startDate != null && endDate != null && !startDate.trim().isEmpty() && !endDate.trim().isEmpty();
    }

    private List<Map<String, Object>> loadBreakdown(String sql) {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("label", rs.getString("label"));
                row.put("count", rs.getInt("count"));
                rows.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Report breakdown query failed: " + e.getMessage());
        }
        return rows;
    }

    private int countByDateRange(Connection conn, String sql, String startDate, String endDate) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private double sumByDateRange(Connection conn, String sql, String startDate, String endDate) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        }
        return 0;
    }
}
