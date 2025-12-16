package com.psm.elearning.dao;

import com.psm.elearning.model.Student;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class StudentDAOImpl implements StudentDAO {

    private Student mapRow(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setUserId(rs.getInt("UserID"));
        s.setRegNumber(rs.getString("RegNumber"));
        s.setQualification(rs.getString("Qualification"));
        s.setCountry(rs.getString("Country"));
        s.setState(rs.getString("State"));
        s.setPassportPath(rs.getString("PassportPath"));
        Date dob = rs.getDate("DOB");
        s.setDob(dob != null ? dob.toLocalDate() : null);
        s.setGender(rs.getString("Gender"));
        s.setEmergencyContact(rs.getString("EmergencyContact"));
        Timestamp reg = rs.getTimestamp("RegistrationDate");
        s.setRegistrationDate(reg != null ? reg.toLocalDateTime() : null);
        return s;
    }

    @Override
    public boolean create(Student student) {
        String sql = "INSERT INTO Student (UserID, RegNumber, Qualification, Country, State, PassportPath, DOB, Gender, EmergencyContact) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, student.getUserId());
            ps.setString(2, student.getRegNumber());
            ps.setString(3, student.getQualification());
            ps.setString(4, student.getCountry());
            ps.setString(5, student.getState());
            ps.setString(6, student.getPassportPath());
            if (student.getDob() != null) ps.setDate(7, Date.valueOf(student.getDob())); else ps.setNull(7, Types.DATE);
            ps.setString(8, student.getGender());
            ps.setString(9, student.getEmergencyContact());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Student create failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public Student findByUserId(int userId) {
        String sql = "SELECT * FROM Student WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("findByUserId failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public Student findByRegNumber(String regNumber) {
        String sql = "SELECT * FROM Student WHERE RegNumber=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, regNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("findByRegNumber failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Student> findAll() {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM Student ORDER BY RegistrationDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("findAll students failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean updateProfile(Student student) {
        String sql = "UPDATE Student SET Qualification=?, Country=?, State=?, PassportPath=?, DOB=?, Gender=?, EmergencyContact=? WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, student.getQualification());
            ps.setString(2, student.getCountry());
            ps.setString(3, student.getState());
            ps.setString(4, student.getPassportPath());
            if (student.getDob() != null) ps.setDate(5, Date.valueOf(student.getDob())); else ps.setNull(5, Types.DATE);
            ps.setString(6, student.getGender());
            ps.setString(7, student.getEmergencyContact());
            ps.setInt(8, student.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Student updateProfile failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public String getNextRegNumber() {
        String prefix = "PSM"; // Fixed prefix
        int minimumStart = 1783; // User indicated existing highest is 1782
        int currentMax = 0;
        String sql = "SELECT MAX(CAST(SUBSTRING(RegNumber, 4) AS UNSIGNED)) AS maxnum FROM Student WHERE RegNumber LIKE 'PSM%'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                currentMax = rs.getInt("maxnum");
            }
        } catch (SQLException e) {
            System.err.println("getNextRegNumber query failed: " + e.getMessage());
        }
        int next = currentMax < (minimumStart - 1) ? minimumStart : currentMax + 1;
        return prefix + next;
    }
}
