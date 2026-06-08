package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentRetakeRequest;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentRetakeRequestDAOImpl implements AssessmentRetakeRequestDAO {

    private AssessmentRetakeRequest mapRow(ResultSet rs) throws SQLException {
        AssessmentRetakeRequest r = new AssessmentRetakeRequest();
        r.setRequestId(rs.getInt("RequestID"));
        r.setAssessmentId(rs.getInt("AssessmentID"));
        r.setUserId(rs.getInt("UserID"));
        if (hasColumn(rs, "StudentName")) {
            r.setStudentName(rs.getString("StudentName"));
        }
        if (hasColumn(rs, "StudentEmail")) {
            r.setStudentEmail(rs.getString("StudentEmail"));
        }
        r.setReason(rs.getString("Reason"));
        r.setStatus(rs.getString("Status"));

        Timestamp requested = rs.getTimestamp("RequestedAt");
        r.setRequestedAt(requested != null ? requested.toLocalDateTime() : null);
        Timestamp reviewed = rs.getTimestamp("ReviewedAt");
        r.setReviewedAt(reviewed != null ? reviewed.toLocalDateTime() : null);

        int reviewedBy = rs.getInt("ReviewedBy");
        r.setReviewedBy(rs.wasNull() ? null : reviewedBy);
        return r;
    }

    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData meta = rs.getMetaData();
        for (int i = 1; i <= meta.getColumnCount(); i++) {
            if (columnName.equalsIgnoreCase(meta.getColumnLabel(i))) {
                return true;
            }
        }
        return false;
    }

    @Override
    public AssessmentRetakeRequest create(AssessmentRetakeRequest request) {
        String sql = "INSERT INTO AssessmentRetakeRequest (AssessmentID, UserID, Reason, Status) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, request.getAssessmentId());
            ps.setInt(2, request.getUserId());
            ps.setString(3, request.getReason());
            ps.setString(4, request.getStatus() != null ? request.getStatus() : "Pending");
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) request.setRequestId(keys.getInt(1));
            }
            return request;
        } catch (SQLException e) {
            System.err.println("Retake request create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public AssessmentRetakeRequest findById(int requestId) {
        String sql = "SELECT * FROM AssessmentRetakeRequest WHERE RequestID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Retake request findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<AssessmentRetakeRequest> findByAssessment(int assessmentId) {
        List<AssessmentRetakeRequest> list = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName AS StudentName, u.Email AS StudentEmail " +
                "FROM AssessmentRetakeRequest r " +
                "JOIN User u ON u.UserID=r.UserID " +
                "WHERE r.AssessmentID=? ORDER BY r.RequestedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Retake request findByAssessment failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<AssessmentRetakeRequest> findByAssessmentIds(List<Integer> assessmentIds) {
        List<AssessmentRetakeRequest> list = new ArrayList<>();
        if (assessmentIds == null || assessmentIds.isEmpty()) return list;
        StringBuilder sql = new StringBuilder("SELECT r.*, u.FullName AS StudentName, u.Email AS StudentEmail ")
                .append("FROM AssessmentRetakeRequest r ")
                .append("JOIN User u ON u.UserID=r.UserID ")
                .append("WHERE r.AssessmentID IN (");
        for (int i = 0; i < assessmentIds.size(); i++) {
            sql.append("?");
            if (i < assessmentIds.size() - 1) sql.append(",");
        }
        sql.append(") ORDER BY r.RequestedAt DESC");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < assessmentIds.size(); i++) {
                ps.setInt(i + 1, assessmentIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Retake request findByAssessmentIds failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<AssessmentRetakeRequest> findByAssessmentAndUser(int assessmentId, int userId) {
        List<AssessmentRetakeRequest> list = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName AS StudentName, u.Email AS StudentEmail " +
            "FROM AssessmentRetakeRequest r " +
            "JOIN User u ON u.UserID=r.UserID " +
            "WHERE r.AssessmentID=? AND r.UserID=? ORDER BY r.RequestedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Retake request findByAssessmentAndUser failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<AssessmentRetakeRequest> findByUser(int userId) {
        List<AssessmentRetakeRequest> list = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName AS StudentName, u.Email AS StudentEmail " +
            "FROM AssessmentRetakeRequest r " +
            "JOIN User u ON u.UserID=r.UserID " +
            "WHERE r.UserID=? ORDER BY r.RequestedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Retake request findByUser failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean hasPending(int assessmentId, int userId) {
        String sql = "SELECT 1 FROM AssessmentRetakeRequest WHERE AssessmentID=? AND UserID=? AND Status='Pending' LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Retake request hasPending failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public int countApproved(int assessmentId, int userId) {
        String sql = "SELECT COUNT(*) FROM AssessmentRetakeRequest WHERE AssessmentID=? AND UserID=? AND Status='Approved'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Retake request countApproved failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public boolean updateStatus(int requestId, String status, Integer reviewedBy) {
        String sql = "UPDATE AssessmentRetakeRequest SET Status=?, ReviewedAt=CURRENT_TIMESTAMP, ReviewedBy=? WHERE RequestID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            if (reviewedBy != null) ps.setInt(2, reviewedBy); else ps.setNull(2, Types.INTEGER);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Retake request updateStatus failed: " + e.getMessage());
            return false;
        }
    }
}
