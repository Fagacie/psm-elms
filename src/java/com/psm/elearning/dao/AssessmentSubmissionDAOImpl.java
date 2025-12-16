package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentSubmissionDAOImpl implements AssessmentSubmissionDAO {

    private AssessmentSubmission mapRow(ResultSet rs) throws SQLException {
        AssessmentSubmission s = new AssessmentSubmission();
        s.setSubmissionId(rs.getInt("SubmissionID"));
        s.setAssessmentId(rs.getInt("AssessmentID"));
        s.setUserId(rs.getInt("UserID"));
        s.setAnswersFilePath(rs.getString("AnswersFilePath"));
        double score = rs.getDouble("Score");
        s.setScore(rs.wasNull() ? null : score);
        s.setAttemptNumber(rs.getInt("AttemptNumber"));
        Timestamp sd = rs.getTimestamp("SubmitDate");
        s.setSubmitDate(sd != null ? sd.toLocalDateTime() : null);
        return s;
    }

    @Override
    public AssessmentSubmission submit(AssessmentSubmission submission) {
        String sql = "INSERT INTO AssessmentSubmission (AssessmentID, UserID, AnswersFilePath, Score, AttemptNumber) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, submission.getAssessmentId());
            ps.setInt(2, submission.getUserId());
            ps.setString(3, submission.getAnswersFilePath());
            if (submission.getScore() != null) ps.setDouble(4, submission.getScore()); else ps.setNull(4, Types.DECIMAL);
            ps.setInt(5, submission.getAttemptNumber() != null ? submission.getAttemptNumber() : 1);
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) submission.setSubmissionId(rs.getInt(1));
            }
            return findById(submission.getSubmissionId());
        } catch (SQLException e) {
            System.err.println("AssessmentSubmission submit failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public AssessmentSubmission findById(int submissionId) {
        String sql = "SELECT * FROM AssessmentSubmission WHERE SubmissionID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("AssessmentSubmission findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<AssessmentSubmission> findByAssessment(int assessmentId) {
        List<AssessmentSubmission> list = new ArrayList<>();
        String sql = "SELECT * FROM AssessmentSubmission WHERE AssessmentID=? ORDER BY SubmitDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("AssessmentSubmission findByAssessment failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<AssessmentSubmission> findByUser(int userId) {
        List<AssessmentSubmission> list = new ArrayList<>();
        String sql = "SELECT * FROM AssessmentSubmission WHERE UserID=? ORDER BY SubmitDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("AssessmentSubmission findByUser failed: " + e.getMessage());
        }
        return list;
    }
}
