package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentQuestionDAOImpl implements AssessmentQuestionDAO {

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
        double marks = rs.getDouble("Marks");
        q.setMarks(rs.wasNull() ? null : marks);
        return q;
    }

    @Override
    public AssessmentQuestion addQuestion(AssessmentQuestion question) {
        String sql = "INSERT INTO AssessmentQuestion (AssessmentID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption, Marks) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, question.getAssessmentId());
            ps.setString(2, question.getQuestionText());
            ps.setString(3, question.getOptionA());
            ps.setString(4, question.getOptionB());
            ps.setString(5, question.getOptionC());
            ps.setString(6, question.getOptionD());
            ps.setString(7, question.getCorrectOption());
            if (question.getMarks() != null) ps.setDouble(8, question.getMarks()); else ps.setNull(8, Types.DECIMAL);
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
