package com.psm.elearning.dao;

import com.psm.elearning.model.Admin;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminDAOImpl implements AdminDAO {

    private Admin mapRow(ResultSet rs) throws SQLException {
        Admin a = new Admin();
        a.setUserId(rs.getInt("UserID"));
        a.setPosition(rs.getString("Position"));
        a.setPermissionLevel(rs.getString("PermissionLevel"));
        a.setAssignedDepartment(rs.getString("AssignedDepartment"));
        return a;
    }

    @Override
    public boolean create(Admin admin) {
        String sql = "INSERT INTO Admin (UserID, Position, PermissionLevel, AssignedDepartment) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, admin.getUserId());
            ps.setString(2, admin.getPosition());
            ps.setString(3, admin.getPermissionLevel());
            ps.setString(4, admin.getAssignedDepartment());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Admin create failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public Admin findByUserId(int userId) {
        String sql = "SELECT * FROM Admin WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Admin findByUserId failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Admin> findAll() {
        List<Admin> list = new ArrayList<>();
        String sql = "SELECT * FROM Admin ORDER BY UserID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("Admin findAll failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean update(Admin admin) {
        String sql = "UPDATE Admin SET Position=?, PermissionLevel=?, AssignedDepartment=? WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, admin.getPosition());
            ps.setString(2, admin.getPermissionLevel());
            ps.setString(3, admin.getAssignedDepartment());
            ps.setInt(4, admin.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Admin update failed: " + e.getMessage());
            return false;
        }
    }
}
