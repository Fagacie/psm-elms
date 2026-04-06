package com.psm.elearning.dao;

import com.psm.elearning.model.InstructorApplication;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InstructorApplicationDAOImpl implements InstructorApplicationDAO {

    private InstructorApplication mapRow(ResultSet rs) throws SQLException {
        InstructorApplication application = new InstructorApplication();
        application.setApplicationId(rs.getInt("ApplicationID"));
        application.setFullName(rs.getString("FullName"));
        application.setEmail(rs.getString("Email"));
        application.setPhone(rs.getString("Phone"));
        application.setSpecialization(rs.getString("Specialization"));
        int years = rs.getInt("YearsOfExperience");
        application.setYearsOfExperience(rs.wasNull() ? null : years);
        application.setQualification(rs.getString("Qualification"));
        application.setCoverMessage(rs.getString("CoverMessage"));
        application.setCvPath(rs.getString("CvPath"));
        application.setStatus(rs.getString("Status"));
        int reviewedBy = rs.getInt("ReviewedBy");
        application.setReviewedBy(rs.wasNull() ? null : reviewedBy);
        application.setAdminNotes(rs.getString("AdminNotes"));
        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        Timestamp reviewedAt = rs.getTimestamp("ReviewedAt");
        application.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime() : null);
        application.setReviewedAt(reviewedAt != null ? reviewedAt.toLocalDateTime() : null);
        return application;
    }

    @Override
    public InstructorApplication create(InstructorApplication application) {
        String sql = "INSERT INTO InstructorApplication (FullName, Email, Phone, Specialization, YearsOfExperience, Qualification, CoverMessage, CvPath, Status) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, application.getFullName());
            ps.setString(2, application.getEmail());
            ps.setString(3, application.getPhone());
            ps.setString(4, application.getSpecialization());
            if (application.getYearsOfExperience() != null) {
                ps.setInt(5, application.getYearsOfExperience());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(6, application.getQualification());
            ps.setString(7, application.getCoverMessage());
            ps.setString(8, application.getCvPath());
            ps.setString(9, application.getStatus() != null ? application.getStatus() : InstructorApplication.STATUS_PENDING);
            int affected = ps.executeUpdate();
            if (affected == 0) {
                return null;
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    application.setApplicationId(rs.getInt(1));
                }
            }
            return findById(application.getApplicationId());
        } catch (SQLException e) {
            System.err.println("InstructorApplication create failed: " + e.getMessage()
                    + " | SQLState=" + e.getSQLState()
                    + " | ErrorCode=" + e.getErrorCode());
            return null;
        }
    }

    @Override
    public InstructorApplication findById(int applicationId) {
        String sql = "SELECT * FROM InstructorApplication WHERE ApplicationID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, applicationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("InstructorApplication findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public InstructorApplication findLatestByEmail(String email) {
        String sql = "SELECT * FROM InstructorApplication WHERE Email=? ORDER BY CreatedAt DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("InstructorApplication findLatestByEmail failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<InstructorApplication> findAll() {
        List<InstructorApplication> list = new ArrayList<>();
        String sql = "SELECT * FROM InstructorApplication ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("InstructorApplication findAll failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean updateStatus(int applicationId, String status, Integer reviewedBy, String adminNotes) {
        String sql = "UPDATE InstructorApplication SET Status=?, ReviewedBy=?, ReviewedAt=CURRENT_TIMESTAMP, AdminNotes=? WHERE ApplicationID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            if (reviewedBy != null) {
                ps.setInt(2, reviewedBy);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, adminNotes);
            ps.setInt(4, applicationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("InstructorApplication updateStatus failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM InstructorApplication WHERE Status=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("InstructorApplication countByStatus failed: " + e.getMessage());
        }
        return 0;
    }
}