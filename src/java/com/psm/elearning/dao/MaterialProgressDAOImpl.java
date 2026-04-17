package com.psm.elearning.dao;

import com.psm.elearning.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

public class MaterialProgressDAOImpl implements MaterialProgressDAO {

    @Override
    public boolean markViewed(int userId, int materialId) {
        String sql = "INSERT INTO MaterialProgress (UserID, MaterialID, CourseID, Status, ViewedAt, UpdatedAt) " +
                "SELECT ?, ?, m.CourseID, 'in_progress', NOW(), NOW() FROM Material m WHERE m.MaterialID = ? " +
                "ON DUPLICATE KEY UPDATE Status = CASE WHEN Status='completed' THEN 'completed' ELSE 'in_progress' END, UpdatedAt = NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, materialId);
            ps.setInt(3, materialId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("MaterialProgress markViewed failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean markInProgress(int userId, int materialId, int courseId) {
        String sql = "INSERT INTO MaterialProgress (UserID, MaterialID, CourseID, Status, ViewedAt, UpdatedAt) VALUES (?,?,?,?,NOW(),NOW()) " +
                "ON DUPLICATE KEY UPDATE Status = CASE WHEN Status='completed' THEN 'completed' ELSE 'in_progress' END, " +
                "CourseID = VALUES(CourseID), UpdatedAt = NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, materialId);
            ps.setInt(3, courseId);
            ps.setString(4, "in_progress");
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("MaterialProgress markInProgress failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean markCompleted(int userId, int materialId, int courseId) {
        String sql = "INSERT INTO MaterialProgress (UserID, MaterialID, CourseID, Status, CompletedAt, ViewedAt, UpdatedAt) VALUES (?,?,?,?,NOW(),NOW(),NOW()) " +
                "ON DUPLICATE KEY UPDATE Status='completed', CourseID=VALUES(CourseID), CompletedAt=NOW(), UpdatedAt=NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, materialId);
            ps.setInt(3, courseId);
            ps.setString(4, "completed");
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("MaterialProgress markCompleted failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public int countViewedByCourse(int userId, int courseId) {
        String sql = "SELECT COUNT(*) FROM MaterialProgress mp " +
                "JOIN Material m ON mp.MaterialID = m.MaterialID " +
            "WHERE mp.UserID=? AND m.CourseID=? AND mp.Status='completed' AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress countViewedByCourse failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public Set<Integer> findViewedMaterialIdsByCourse(int userId, int courseId) {
        Set<Integer> viewedIds = new LinkedHashSet<>();
        String sql = "SELECT mp.MaterialID FROM MaterialProgress mp " +
                "JOIN Material m ON mp.MaterialID = m.MaterialID " +
            "WHERE mp.UserID=? AND m.CourseID=? AND mp.Status='completed' AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    viewedIds.add(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress findViewedMaterialIdsByCourse failed: " + e.getMessage());
        }
        return viewedIds;
    }

    @Override
    public Map<Integer, String> findMaterialStatusByCourse(int userId, int courseId) {
        Map<Integer, String> statusByMaterial = new LinkedHashMap<>();
        String sql = "SELECT mp.MaterialID, mp.Status FROM MaterialProgress mp " +
                "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                "WHERE mp.UserID=? AND m.CourseID=? AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    statusByMaterial.put(rs.getInt(1), rs.getString(2));
                }
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress findMaterialStatusByCourse failed: " + e.getMessage());
        }
        return statusByMaterial;
    }
}
