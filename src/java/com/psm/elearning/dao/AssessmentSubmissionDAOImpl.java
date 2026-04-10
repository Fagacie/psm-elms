package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentSubmissionDAOImpl implements AssessmentSubmissionDAO {

    private static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int count = metaData.getColumnCount();
        for (int i = 1; i <= count; i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) return true;
        }
        return false;
    }

    private AssessmentSubmission mapRow(ResultSet rs) throws SQLException {
        AssessmentSubmission s = new AssessmentSubmission();
        s.setSubmissionId(rs.getInt("SubmissionID"));
        s.setAssessmentId(rs.getInt("AssessmentID"));
        s.setUserId(rs.getInt("UserID"));
        s.setAnswersFilePath(rs.getString("AnswersFilePath"));
        double score = rs.getDouble("Score");
        s.setScore(rs.wasNull() ? null : score);
        if (hasColumn(rs, "Feedback")) {
            s.setFeedback(rs.getString("Feedback"));
        }
        s.setAttemptNumber(rs.getInt("AttemptNumber"));
        if (hasColumn(rs, "Status")) {
            s.setStatus(rs.getString("Status"));
        }
        if (hasColumn(rs, "StartedAt")) {
            Timestamp started = rs.getTimestamp("StartedAt");
            s.setStartedAt(started != null ? started.toLocalDateTime() : null);
        }
        if (hasColumn(rs, "EndedAt")) {
            Timestamp ended = rs.getTimestamp("EndedAt");
            s.setEndedAt(ended != null ? ended.toLocalDateTime() : null);
        }
        Timestamp sd = rs.getTimestamp("SubmitDate");
        s.setSubmitDate(sd != null ? sd.toLocalDateTime() : null);
        if (hasColumn(rs, "StudentName")) {
            s.setStudentName(rs.getString("StudentName"));
        }
        if (hasColumn(rs, "StudentEmail")) {
            s.setStudentEmail(rs.getString("StudentEmail"));
        }
        return s;
    }

    @Override
    public AssessmentSubmission submit(AssessmentSubmission submission) {
        String sql = "INSERT INTO AssessmentSubmission (AssessmentID, UserID, AnswersFilePath, Score, Feedback, AttemptNumber, Status, StartedAt, EndedAt) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, submission.getAssessmentId());
            ps.setInt(2, submission.getUserId());
            ps.setString(3, submission.getAnswersFilePath());
            if (submission.getScore() != null) ps.setDouble(4, submission.getScore()); else ps.setNull(4, Types.DECIMAL);
            ps.setString(5, submission.getFeedback());
            ps.setInt(6, submission.getAttemptNumber() != null ? submission.getAttemptNumber() : 1);
            ps.setString(7, submission.getStatus() != null ? submission.getStatus() : "Submitted");
            if (submission.getStartedAt() != null) ps.setTimestamp(8, Timestamp.valueOf(submission.getStartedAt())); else ps.setNull(8, Types.TIMESTAMP);
            if (submission.getEndedAt() != null) ps.setTimestamp(9, Timestamp.valueOf(submission.getEndedAt())); else ps.setNull(9, Types.TIMESTAMP);
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
        String sql = "SELECT s.*, u.FullName AS StudentName, u.Email AS StudentEmail " +
                "FROM AssessmentSubmission s JOIN User u ON u.UserID=s.UserID " +
                "WHERE s.AssessmentID=? ORDER BY s.SubmitDate DESC";
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
    public List<AssessmentSubmission> findByAssessmentAndUser(int assessmentId, int userId) {
        List<AssessmentSubmission> list = new ArrayList<>();
        String sql = "SELECT * FROM AssessmentSubmission WHERE AssessmentID=? AND UserID=? ORDER BY SubmitDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("AssessmentSubmission findByAssessmentAndUser failed: " + e.getMessage());
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

    @Override
    public boolean gradeSubmission(int submissionId, Double score, String feedback) {
        String sql = "UPDATE AssessmentSubmission SET Score=?, Feedback=?, Status=? WHERE SubmissionID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (score != null) ps.setDouble(1, score); else ps.setNull(1, Types.DECIMAL);
            ps.setString(2, feedback);
            ps.setString(3, score != null ? "Graded" : "Submitted");
            ps.setInt(4, submissionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("AssessmentSubmission grade failed: " + e.getMessage());
            return false;
        }
    }
}
