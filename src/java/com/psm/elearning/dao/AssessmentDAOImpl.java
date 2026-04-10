package com.psm.elearning.dao;

import com.psm.elearning.model.Assessment;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentDAOImpl implements AssessmentDAO {

    private volatile Boolean placementColumnsAvailable;

    private boolean supportsPlacementColumns(Connection conn) {
        if (placementColumnsAvailable != null) {
            return placementColumnsAvailable;
        }
        synchronized (this) {
            if (placementColumnsAvailable != null) {
                return placementColumnsAvailable;
            }
            String sql = "SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS "
                    + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Assessment' "
                    + "AND COLUMN_NAME IN ('PlacementType','PlacementMaterialID')";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    placementColumnsAvailable = rs.getInt("cnt") == 2;
                } else {
                    placementColumnsAvailable = false;
                }
            } catch (SQLException e) {
                placementColumnsAvailable = false;
            }
            return placementColumnsAvailable;
        }
    }

    private static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int count = metaData.getColumnCount();
        for (int i = 1; i <= count; i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) return true;
        }
        return false;
    }

    private Assessment mapRow(ResultSet rs) throws SQLException {
        Assessment a = new Assessment();
        a.setAssessmentId(rs.getInt("AssessmentID"));
        a.setCourseId(rs.getInt("CourseID"));
        a.setTitle(rs.getString("Title"));
        a.setType(rs.getString("Type"));
        int duration = rs.getInt("Duration");
        a.setDuration(rs.wasNull() ? null : duration);
        int total = rs.getInt("TotalMarks");
        a.setTotalMarks(rs.wasNull() ? null : total);
        a.setInstructions(rs.getString("Instructions"));
        int maxAttempts = rs.getInt("MaxAttempts");
        a.setMaxAttempts(rs.wasNull() ? null : maxAttempts);
        int questionsPerPage = rs.getInt("QuestionsPerPage");
        a.setQuestionsPerPage(rs.wasNull() ? null : questionsPerPage);
        if (hasColumn(rs, "PlacementType")) {
            a.setPlacementType(rs.getString("PlacementType"));
        }
        if (hasColumn(rs, "PlacementMaterialID")) {
            int placementMaterialId = rs.getInt("PlacementMaterialID");
            a.setPlacementMaterialId(rs.wasNull() ? null : placementMaterialId);
        }
        Timestamp cAt = rs.getTimestamp("CreatedAt");
        a.setCreatedAt(cAt != null ? cAt.toLocalDateTime() : null);
        a.setCreatedBy(rs.getInt("CreatedBy"));
        return a;
    }

    @Override
    public Assessment create(Assessment assessment) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean supportsPlacement = supportsPlacementColumns(conn);
            String sql = supportsPlacement
                    ? "INSERT INTO Assessment (CourseID, Title, Type, Duration, TotalMarks, Instructions, PlacementType, PlacementMaterialID, MaxAttempts, QuestionsPerPage, CreatedBy) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
                    : "INSERT INTO Assessment (CourseID, Title, Type, Duration, TotalMarks, Instructions, MaxAttempts, QuestionsPerPage, CreatedBy) VALUES (?,?,?,?,?,?,?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, assessment.getCourseId());
            ps.setString(2, assessment.getTitle());
            ps.setString(3, assessment.getType());
            if (assessment.getDuration() != null) ps.setInt(4, assessment.getDuration()); else ps.setNull(4, Types.INTEGER);
            if (assessment.getTotalMarks() != null) ps.setInt(5, assessment.getTotalMarks()); else ps.setNull(5, Types.INTEGER);
            ps.setString(6, assessment.getInstructions());
            if (supportsPlacement) {
                ps.setString(7, assessment.getPlacementType());
                if (assessment.getPlacementMaterialId() != null) {
                    ps.setInt(8, assessment.getPlacementMaterialId());
                } else {
                    ps.setNull(8, Types.INTEGER);
                }
                ps.setInt(9, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
                ps.setInt(10, assessment.getQuestionsPerPage() != null ? assessment.getQuestionsPerPage() : 2);
                ps.setInt(11, assessment.getCreatedBy());
            } else {
                ps.setInt(7, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
                ps.setInt(8, assessment.getQuestionsPerPage() != null ? assessment.getQuestionsPerPage() : 2);
                ps.setInt(9, assessment.getCreatedBy());
            }
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) assessment.setAssessmentId(rs.getInt(1));
            }
            return findById(assessment.getAssessmentId());
            }
        } catch (SQLException e) {
            System.err.println("Assessment create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public Assessment findById(int assessmentId) {
        String sql = "SELECT * FROM Assessment WHERE AssessmentID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Assessment findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Assessment> findByCourse(int courseId) {
        List<Assessment> list = new ArrayList<>();
        String sql = "SELECT * FROM Assessment WHERE CourseID=? ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Assessment findByCourse failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean update(Assessment assessment) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean supportsPlacement = supportsPlacementColumns(conn);
            String sql = supportsPlacement
                    ? "UPDATE Assessment SET Title=?, Type=?, Duration=?, TotalMarks=?, Instructions=?, PlacementType=?, PlacementMaterialID=?, MaxAttempts=?, QuestionsPerPage=? WHERE AssessmentID=?"
                    : "UPDATE Assessment SET Title=?, Type=?, Duration=?, TotalMarks=?, Instructions=?, MaxAttempts=?, QuestionsPerPage=? WHERE AssessmentID=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, assessment.getTitle());
            ps.setString(2, assessment.getType());
            if (assessment.getDuration() != null) ps.setInt(3, assessment.getDuration()); else ps.setNull(3, Types.INTEGER);
            if (assessment.getTotalMarks() != null) ps.setInt(4, assessment.getTotalMarks()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, assessment.getInstructions());
            if (supportsPlacement) {
                ps.setString(6, assessment.getPlacementType());
                if (assessment.getPlacementMaterialId() != null) {
                    ps.setInt(7, assessment.getPlacementMaterialId());
                } else {
                    ps.setNull(7, Types.INTEGER);
                }
                ps.setInt(8, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
                ps.setInt(9, assessment.getQuestionsPerPage() != null ? assessment.getQuestionsPerPage() : 2);
                ps.setInt(10, assessment.getAssessmentId());
            } else {
                ps.setInt(6, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
                ps.setInt(7, assessment.getQuestionsPerPage() != null ? assessment.getQuestionsPerPage() : 2);
                ps.setInt(8, assessment.getAssessmentId());
            }
            return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Assessment update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean delete(int assessmentId) {
        String sql = "DELETE FROM Assessment WHERE AssessmentID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Assessment delete failed: " + e.getMessage());
            return false;
        }
    }
}
