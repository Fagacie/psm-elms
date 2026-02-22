package com.psm.elearning.dao;

import com.psm.elearning.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class MaterialProgressDAOImpl implements MaterialProgressDAO {

    @Override
    public boolean markViewed(int userId, int materialId) {
        String sql = "INSERT IGNORE INTO MaterialProgress (UserID, MaterialID) VALUES (?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, materialId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("MaterialProgress markViewed failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public int countViewedByCourse(int userId, int courseId) {
        String sql = "SELECT COUNT(*) FROM MaterialProgress mp " +
                "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                "WHERE mp.UserID=? AND m.CourseID=? AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)";
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
}
