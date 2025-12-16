package com.psm.elearning.dao;

import com.psm.elearning.model.Material;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MaterialDAOImpl implements MaterialDAO {

    private Material mapRow(ResultSet rs) throws SQLException {
        Material m = new Material();
        m.setMaterialId(rs.getInt("MaterialID"));
        m.setCourseId(rs.getInt("CourseID"));
        m.setTitle(rs.getString("Title"));
        m.setDescription(rs.getString("Description"));
        m.setMaterialType(rs.getString("MaterialType"));
        m.setFilePath(rs.getString("FilePath"));
        m.setUploadedBy(rs.getInt("UploadedBy"));
        Timestamp up = rs.getTimestamp("UploadDate");
        m.setUploadDate(up != null ? up.toLocalDateTime() : null);
        m.setVersionNumber(rs.getString("VersionNumber"));
        return m;
    }

    @Override
    public Material create(Material material) {
        String sql = "INSERT INTO Material (CourseID, Title, Description, MaterialType, FilePath, UploadedBy, VersionNumber) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, material.getCourseId());
            ps.setString(2, material.getTitle());
            ps.setString(3, material.getDescription());
            ps.setString(4, material.getMaterialType());
            ps.setString(5, material.getFilePath());
            ps.setInt(6, material.getUploadedBy());
            ps.setString(7, material.getVersionNumber());
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) material.setMaterialId(rs.getInt(1));
            }
            return findById(material.getMaterialId());
        } catch (SQLException e) {
            System.err.println("Material create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public Material findById(int materialId) {
        String sql = "SELECT * FROM Material WHERE MaterialID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Material findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Material> findByCourse(int courseId) {
        List<Material> list = new ArrayList<>();
        String sql = "SELECT * FROM Material WHERE CourseID=? ORDER BY UploadDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Material findByCourse failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean update(Material material) {
        String sql = "UPDATE Material SET Title=?, Description=?, MaterialType=?, FilePath=?, VersionNumber=? WHERE MaterialID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, material.getTitle());
            ps.setString(2, material.getDescription());
            ps.setString(3, material.getMaterialType());
            ps.setString(4, material.getFilePath());
            ps.setString(5, material.getVersionNumber());
            ps.setInt(6, material.getMaterialId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Material update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean delete(int materialId) {
        String sql = "DELETE FROM Material WHERE MaterialID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Material delete failed: " + e.getMessage());
            return false;
        }
    }
}
