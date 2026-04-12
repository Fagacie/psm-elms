package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentGradeAudit;
import com.psm.elearning.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AssessmentGradeAuditDAOImpl implements AssessmentGradeAuditDAO {

    private AssessmentGradeAudit mapRow(ResultSet rs) throws SQLException {
        AssessmentGradeAudit audit = new AssessmentGradeAudit();
        audit.setAuditId(rs.getInt("AuditID"));
        audit.setSubmissionId(rs.getInt("SubmissionID"));
        audit.setAssessmentId(rs.getInt("AssessmentID"));
        audit.setActionType(rs.getString("ActionType"));
        double oldScore = rs.getDouble("OldScore");
        audit.setOldScore(rs.wasNull() ? null : oldScore);
        double newScore = rs.getDouble("NewScore");
        audit.setNewScore(rs.wasNull() ? null : newScore);
        audit.setOldFeedback(rs.getString("OldFeedback"));
        audit.setNewFeedback(rs.getString("NewFeedback"));
        int gradedBy = rs.getInt("GradedBy");
        audit.setGradedBy(rs.wasNull() ? null : gradedBy);
        audit.setGradedByName(rs.getString("GradedByName"));
        audit.setGradedByEmail(rs.getString("GradedByEmail"));
        Timestamp ts = rs.getTimestamp("GradedAt");
        audit.setGradedAt(ts != null ? ts.toLocalDateTime() : null);
        audit.setNote(rs.getString("Note"));
        return audit;
    }

    @Override
    public boolean record(AssessmentGradeAudit audit) {
        String sql = "INSERT INTO AssessmentGradeAudit (SubmissionID, AssessmentID, ActionType, OldScore, NewScore, OldFeedback, NewFeedback, GradedBy, GradedAt, Note) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, audit.getSubmissionId());
            ps.setInt(2, audit.getAssessmentId());
            ps.setString(3, audit.getActionType());
            if (audit.getOldScore() != null) ps.setDouble(4, audit.getOldScore()); else ps.setNull(4, java.sql.Types.DECIMAL);
            if (audit.getNewScore() != null) ps.setDouble(5, audit.getNewScore()); else ps.setNull(5, java.sql.Types.DECIMAL);
            ps.setString(6, audit.getOldFeedback());
            ps.setString(7, audit.getNewFeedback());
            if (audit.getGradedBy() != null) ps.setInt(8, audit.getGradedBy()); else ps.setNull(8, java.sql.Types.INTEGER);
            if (audit.getGradedAt() != null) ps.setTimestamp(9, Timestamp.valueOf(audit.getGradedAt())); else ps.setTimestamp(9, Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setString(10, audit.getNote());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("AssessmentGradeAudit record failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public List<AssessmentGradeAudit> findBySubmission(int submissionId) {
        List<AssessmentGradeAudit> list = new ArrayList<>();
        String sql = "SELECT a.*, u.FullName AS GradedByName, u.Email AS GradedByEmail " +
                "FROM AssessmentGradeAudit a LEFT JOIN User u ON u.UserID = a.GradedBy " +
                "WHERE a.SubmissionID=? ORDER BY a.GradedAt DESC, a.AuditID DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("AssessmentGradeAudit findBySubmission failed: " + e.getMessage());
        }
        return list;
    }
}
