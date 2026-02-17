package com.psm.elearning.dao;

import com.psm.elearning.model.Assessment;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentDAOImpl implements AssessmentDAO {

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
        Timestamp cAt = rs.getTimestamp("CreatedAt");
        a.setCreatedAt(cAt != null ? cAt.toLocalDateTime() : null);
        a.setCreatedBy(rs.getInt("CreatedBy"));
        return a;
    }

    @Override
    public Assessment create(Assessment assessment) {
        String sql = "INSERT INTO Assessment (CourseID, Title, Type, Duration, TotalMarks, Instructions, MaxAttempts, QuestionsPerPage, CreatedBy) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, assessment.getCourseId());
            ps.setString(2, assessment.getTitle());
            ps.setString(3, assessment.getType());
            if (assessment.getDuration() != null) ps.setInt(4, assessment.getDuration()); else ps.setNull(4, Types.INTEGER);
            if (assessment.getTotalMarks() != null) ps.setInt(5, assessment.getTotalMarks()); else ps.setNull(5, Types.INTEGER);
            ps.setString(6, assessment.getInstructions());
            ps.setInt(7, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
            ps.setInt(8, assessment.getQuestionsPerPage() != null ? assessment.getQuestionsPerPage() : 2);
            ps.setInt(9, assessment.getCreatedBy());
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) assessment.setAssessmentId(rs.getInt(1));
            }
            return findById(assessment.getAssessmentId());
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
        String sql = "UPDATE Assessment SET Title=?, Type=?, Duration=?, TotalMarks=?, Instructions=?, MaxAttempts=?, QuestionsPerPage=? WHERE AssessmentID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, assessment.getTitle());
            ps.setString(2, assessment.getType());
            if (assessment.getDuration() != null) ps.setInt(3, assessment.getDuration()); else ps.setNull(3, Types.INTEGER);
            if (assessment.getTotalMarks() != null) ps.setInt(4, assessment.getTotalMarks()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, assessment.getInstructions());
            ps.setInt(6, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
            ps.setInt(7, assessment.getQuestionsPerPage() != null ? assessment.getQuestionsPerPage() : 2);
            ps.setInt(8, assessment.getAssessmentId());
            return ps.executeUpdate() > 0;
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
