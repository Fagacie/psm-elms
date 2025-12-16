package com.psm.elearning.dao;

import com.psm.elearning.model.Instructor;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class InstructorDAOImpl implements InstructorDAO {

    private Instructor mapRow(ResultSet rs) throws SQLException {
        Instructor i = new Instructor();
        i.setUserId(rs.getInt("UserID"));
        i.setSpecialization(rs.getString("Specialization"));
        int yrs = rs.getInt("YearsOfExperience");
        i.setYearsOfExperience(rs.wasNull() ? null : yrs);
        i.setBio(rs.getString("Bio"));
        i.setCertification(rs.getString("Certification"));
        Date hd = rs.getDate("HireDate");
        i.setHireDate(hd != null ? hd.toLocalDate() : null);
        return i;
    }

    @Override
    public boolean create(Instructor instructor) {
        String sql = "INSERT INTO Instructor (UserID, Specialization, YearsOfExperience, Bio, Certification, HireDate) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, instructor.getUserId());
            ps.setString(2, instructor.getSpecialization());
            if (instructor.getYearsOfExperience() != null) ps.setInt(3, instructor.getYearsOfExperience()); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, instructor.getBio());
            ps.setString(5, instructor.getCertification());
            if (instructor.getHireDate() != null) ps.setDate(6, Date.valueOf(instructor.getHireDate())); else ps.setNull(6, Types.DATE);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Instructor create failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public Instructor findByUserId(int userId) {
        String sql = "SELECT * FROM Instructor WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Instructor findByUserId failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Instructor> findAll() {
        List<Instructor> list = new ArrayList<>();
        String sql = "SELECT * FROM Instructor ORDER BY UserID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("Instructor findAll failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean update(Instructor instructor) {
        String sql = "UPDATE Instructor SET Specialization=?, YearsOfExperience=?, Bio=?, Certification=?, HireDate=? WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, instructor.getSpecialization());
            if (instructor.getYearsOfExperience() != null) ps.setInt(2, instructor.getYearsOfExperience()); else ps.setNull(2, Types.INTEGER);
            ps.setString(3, instructor.getBio());
            ps.setString(4, instructor.getCertification());
            if (instructor.getHireDate() != null) ps.setDate(5, Date.valueOf(instructor.getHireDate())); else ps.setNull(5, Types.DATE);
            ps.setInt(6, instructor.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Instructor update failed: " + e.getMessage());
            return false;
        }
    }
}
