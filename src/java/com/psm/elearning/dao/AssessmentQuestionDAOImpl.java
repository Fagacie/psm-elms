package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentQuestionDAOImpl implements AssessmentQuestionDAO {

    private volatile Boolean attachmentColumnsAvailable;

    private boolean supportsAttachmentColumns(Connection conn) {
        if (attachmentColumnsAvailable != null) {
            return attachmentColumnsAvailable;
        }
        synchronized (this) {
            if (attachmentColumnsAvailable != null) {
                return attachmentColumnsAvailable;
            }
            try {
                ensureAttachmentColumn(conn, "AttachmentUrl", "VARCHAR(500) NULL");
                ensureAttachmentColumn(conn, "AttachmentName", "VARCHAR(255) NULL");
                attachmentColumnsAvailable = hasAttachmentColumn(conn, "AttachmentUrl")
                        && hasAttachmentColumn(conn, "AttachmentName");
            } catch (SQLException e) {
                System.err.println("AssessmentQuestion attachment columns unavailable: " + e.getMessage());
                attachmentColumnsAvailable = false;
            }
            return attachmentColumnsAvailable;
        }
    }

    private void ensureAttachmentColumn(Connection conn, String columnName, String definition) throws SQLException {
        if (hasAttachmentColumn(conn, columnName)) {
            return;
        }
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("ALTER TABLE AssessmentQuestion ADD COLUMN " + columnName + " " + definition);
        }
    }

    private boolean hasAttachmentColumn(Connection conn, String columnName) throws SQLException {
        String sql = "SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS "
                + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'AssessmentQuestion' "
                + "AND COLUMN_NAME = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt("cnt") > 0;
            }
        }
    }

    private static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int count = metaData.getColumnCount();
        for (int i = 1; i <= count; i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) {
                return true;
            }
        }
        return false;
    }

    private AssessmentQuestion mapRow(ResultSet rs) throws SQLException {
        AssessmentQuestion q = new AssessmentQuestion();
        q.setQuestionId(rs.getInt("QuestionID"));
        q.setAssessmentId(rs.getInt("AssessmentID"));
        q.setQuestionText(rs.getString("QuestionText"));
        q.setOptionA(rs.getString("OptionA"));
        q.setOptionB(rs.getString("OptionB"));
        q.setOptionC(rs.getString("OptionC"));
        q.setOptionD(rs.getString("OptionD"));
        q.setCorrectOption(rs.getString("CorrectOption"));
        if (hasColumn(rs, "AttachmentUrl")) {
            q.setAttachmentUrl(rs.getString("AttachmentUrl"));
        }
        if (hasColumn(rs, "AttachmentName")) {
            q.setAttachmentName(rs.getString("AttachmentName"));
        }
        double marks = rs.getDouble("Marks");
        q.setMarks(rs.wasNull() ? null : marks);
        return q;
    }

    @Override
    public AssessmentQuestion addQuestion(AssessmentQuestion question) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     supportsAttachmentColumns(conn)
                             ? "INSERT INTO AssessmentQuestion (AssessmentID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption, Marks, AttachmentUrl, AttachmentName) VALUES (?,?,?,?,?,?,?,?,?,?)"
                             : "INSERT INTO AssessmentQuestion (AssessmentID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption, Marks) VALUES (?,?,?,?,?,?,?,?)",
                     Statement.RETURN_GENERATED_KEYS)) {
            boolean includeAttachment = supportsAttachmentColumns(conn);
            ps.setInt(1, question.getAssessmentId());
            ps.setString(2, question.getQuestionText());
            ps.setString(3, question.getOptionA());
            ps.setString(4, question.getOptionB());
            ps.setString(5, question.getOptionC());
            ps.setString(6, question.getOptionD());
            ps.setString(7, question.getCorrectOption());
            if (question.getMarks() != null) ps.setDouble(8, question.getMarks()); else ps.setNull(8, Types.DECIMAL);
            if (includeAttachment) {
                ps.setString(9, question.getAttachmentUrl());
                ps.setString(10, question.getAttachmentName());
            }
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) question.setQuestionId(rs.getInt(1));
            }
            return findById(question.getQuestionId());
        } catch (SQLException e) {
            System.err.println("AssessmentQuestion add failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public AssessmentQuestion findById(int questionId) {
        String sql = "SELECT * FROM AssessmentQuestion WHERE QuestionID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("AssessmentQuestion findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<AssessmentQuestion> findByAssessment(int assessmentId) {
        List<AssessmentQuestion> list = new ArrayList<>();
        String sql = "SELECT * FROM AssessmentQuestion WHERE AssessmentID=? ORDER BY QuestionID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("AssessmentQuestion findByAssessment failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean updateQuestion(AssessmentQuestion question) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     supportsAttachmentColumns(conn)
                             ? "UPDATE AssessmentQuestion SET QuestionText=?, OptionA=?, OptionB=?, OptionC=?, OptionD=?, CorrectOption=?, Marks=?, AttachmentUrl=?, AttachmentName=? WHERE QuestionID=?"
                             : "UPDATE AssessmentQuestion SET QuestionText=?, OptionA=?, OptionB=?, OptionC=?, OptionD=?, CorrectOption=?, Marks=? WHERE QuestionID=?")) {
            boolean includeAttachment = supportsAttachmentColumns(conn);
            ps.setString(1, question.getQuestionText());
            ps.setString(2, question.getOptionA());
            ps.setString(3, question.getOptionB());
            ps.setString(4, question.getOptionC());
            ps.setString(5, question.getOptionD());
            ps.setString(6, question.getCorrectOption());
            if (question.getMarks() != null) {
                ps.setDouble(7, question.getMarks());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }
            if (includeAttachment) {
                ps.setString(8, question.getAttachmentUrl());
                ps.setString(9, question.getAttachmentName());
                ps.setInt(10, question.getQuestionId());
            } else {
                ps.setInt(8, question.getQuestionId());
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("AssessmentQuestion update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean swapQuestionContent(int firstQuestionId, int secondQuestionId) {
        AssessmentQuestion first = findById(firstQuestionId);
        AssessmentQuestion second = findById(secondQuestionId);
        if (first == null || second == null) {
            return false;
        }

        try (Connection conn = DBConnection.getConnection()) {
            boolean includeAttachment = supportsAttachmentColumns(conn);
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(
                includeAttachment
                            ? "UPDATE AssessmentQuestion SET QuestionText=?, OptionA=?, OptionB=?, OptionC=?, OptionD=?, CorrectOption=?, Marks=?, AttachmentUrl=?, AttachmentName=? WHERE QuestionID=?"
                            : "UPDATE AssessmentQuestion SET QuestionText=?, OptionA=?, OptionB=?, OptionC=?, OptionD=?, CorrectOption=?, Marks=? WHERE QuestionID=?")) {
            bindQuestionContent(ps, second, firstQuestionId, includeAttachment);
                ps.executeUpdate();

            bindQuestionContent(ps, first, secondQuestionId, includeAttachment);
                ps.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("AssessmentQuestion swap failed: " + e.getMessage());
            return false;
        }
    }

    private void bindQuestionContent(PreparedStatement ps, AssessmentQuestion source, int targetQuestionId, boolean includeAttachment) throws SQLException {
        ps.setString(1, source.getQuestionText());
        ps.setString(2, source.getOptionA());
        ps.setString(3, source.getOptionB());
        ps.setString(4, source.getOptionC());
        ps.setString(5, source.getOptionD());
        ps.setString(6, source.getCorrectOption());
        if (source.getMarks() != null) {
            ps.setDouble(7, source.getMarks());
        } else {
            ps.setNull(7, Types.DECIMAL);
        }
        if (includeAttachment) {
            ps.setString(8, source.getAttachmentUrl());
            ps.setString(9, source.getAttachmentName());
            ps.setInt(10, targetQuestionId);
        } else {
            ps.setInt(8, targetQuestionId);
        }
    }

    @Override
    public boolean delete(int questionId) {
        String sql = "DELETE FROM AssessmentQuestion WHERE QuestionID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("AssessmentQuestion delete failed: " + e.getMessage());
            return false;
        }
    }
}
