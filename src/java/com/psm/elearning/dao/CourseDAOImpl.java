package com.psm.elearning.dao;

import com.psm.elearning.model.Course;
import com.psm.elearning.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseDAOImpl implements CourseDAO {

    private Course mapRow(ResultSet rs) throws SQLException {
        Course c = new Course();
        c.setCourseId(rs.getInt("CourseID"));
        c.setCourseName(rs.getString("Title")); // Database column is Title
        c.setDescription(rs.getString("Description"));
        c.setCategory(rs.getString("Category"));
        int duration = rs.getInt("Duration");
        c.setDuration(rs.wasNull() ? null : duration);
        c.setCourseFee(rs.getBigDecimal("CourseFee"));
        c.setLevel(rs.getString("Level"));
        int createdBy = rs.getInt("InstructorID"); // Database column is InstructorID
        c.setCreatedBy(rs.wasNull() ? null : createdBy);
        int approvedBy = rs.getInt("ApprovedBy");
        c.setApprovedBy(rs.wasNull() ? null : approvedBy);
        Timestamp cAt = rs.getTimestamp("CreatedAt");
        Timestamp uAt = rs.getTimestamp("UpdatedAt");
        c.setCreatedAt(cAt != null ? cAt.toLocalDateTime() : null);
        c.setUpdatedAt(uAt != null ? uAt.toLocalDateTime() : null);
        c.setStatus(rs.getString("Status"));
        c.setCourseBanner(rs.getString("CourseBanner"));
        return c;
    }

    @Override
    public Course create(Course course) {
        String sql = "INSERT INTO Course (Title, Description, Category, Duration, CourseFee, Level, InstructorID, Status, CourseBanner) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, course.getCourseName());
            ps.setString(2, course.getDescription());
            ps.setString(3, course.getCategory());
            if (course.getDuration() != null) ps.setInt(4, course.getDuration()); else ps.setNull(4, Types.INTEGER);
            ps.setBigDecimal(5, course.getCourseFee() != null ? course.getCourseFee() : BigDecimal.ZERO);
            ps.setString(6, course.getLevel());
            if (course.getCreatedBy() != null) ps.setInt(7, course.getCreatedBy()); else ps.setNull(7, Types.INTEGER);
            ps.setString(8, course.getStatus() != null ? course.getStatus() : Course.STATUS_PENDING);
            ps.setString(9, course.getCourseBanner());
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) course.setCourseId(rs.getInt(1));
            }
            return findById(course.getCourseId());
        } catch (SQLException e) {
            System.err.println("Course create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public boolean update(Course course) {
        String sql = "UPDATE Course SET Title=?, Description=?, Category=?, Duration=?, CourseFee=?, Level=?, ApprovedBy=?, Status=?, CourseBanner=? WHERE CourseID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, course.getCourseName());
            ps.setString(2, course.getDescription());
            ps.setString(3, course.getCategory());
            if (course.getDuration() != null) ps.setInt(4, course.getDuration()); else ps.setNull(4, Types.INTEGER);
            ps.setBigDecimal(5, course.getCourseFee());
            ps.setString(6, course.getLevel());
            if (course.getApprovedBy() != null) ps.setInt(7, course.getApprovedBy()); else ps.setNull(7, Types.INTEGER);
            ps.setString(8, course.getStatus());
            ps.setString(9, course.getCourseBanner());
            ps.setInt(10, course.getCourseId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Course update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public Course findById(int courseId) {
        String sql = "SELECT * FROM Course WHERE CourseID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Course findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Course> findAll() {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT * FROM Course ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("Course findAll failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<Course> findByStatus(String status) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT * FROM Course WHERE Status=? ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Course findByStatus failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean approve(int courseId, int approvedBy) {
        String sql = "UPDATE Course SET Status=?, ApprovedBy=? WHERE CourseID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Course.STATUS_APPROVED);
            ps.setInt(2, approvedBy);
            ps.setInt(3, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Course approve failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean reject(int courseId) {
        String sql = "UPDATE Course SET Status=? WHERE CourseID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Course.STATUS_ARCHIVED);
            ps.setInt(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Course reject failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean updateStatus(int courseId, String status) {
        String sql = "UPDATE Course SET Status=? WHERE CourseID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Course status update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean delete(int courseId) {
        String sql = "DELETE FROM Course WHERE CourseID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Course delete failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public List<Course> findByInstructor(int instructorId) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT * FROM Course WHERE InstructorID=? ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, instructorId);
            System.out.println("[DEBUG] Querying courses for InstructorID: " + instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
            System.out.println("[DEBUG] Found " + list.size() + " courses for instructor " + instructorId);
        } catch (SQLException e) {
            System.err.println("Course findByInstructor failed: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Course> searchCourses(String keyword) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT * FROM Course WHERE Status='Approved' AND (Title LIKE ? OR Description LIKE ? OR Category LIKE ?) ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Course search failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<Course> filterCourses(String category, String level, Double minFee, Double maxFee) {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Course WHERE Status='Approved'");
        
        if (category != null && !category.isEmpty()) {
            sql.append(" AND Category=?");
        }
        if (level != null && !level.isEmpty()) {
            sql.append(" AND Level=?");
        }
        if (minFee != null) {
            sql.append(" AND CourseFee >= ?");
        }
        if (maxFee != null) {
            sql.append(" AND CourseFee <= ?");
        }
        sql.append(" ORDER BY CreatedAt DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (category != null && !category.isEmpty()) {
                ps.setString(paramIndex++, category);
            }
            if (level != null && !level.isEmpty()) {
                ps.setString(paramIndex++, level);
            }
            if (minFee != null) {
                ps.setDouble(paramIndex++, minFee);
            }
            if (maxFee != null) {
                ps.setDouble(paramIndex++, maxFee);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Course filter failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Course WHERE Status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("countByStatus failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public List<Course> findFeaturedCourses(int limit) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT * FROM Course WHERE Status = 'Approved' ORDER BY CreatedAt DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("findFeaturedCourses failed: " + e.getMessage());
        }
        return list;
    }
}
