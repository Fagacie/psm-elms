package com.psm.elearning.dao;

import com.psm.elearning.util.DBConnection;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

public class MaterialProgressDAOImpl implements MaterialProgressDAO {

    /** Cached schema detection — only runs once per JVM, schema never changes at runtime. */
    private static volatile ProgressSchema cachedSchema = null;

    @Override
    public boolean markViewed(int userId, int materialId) {
        try (Connection conn = DBConnection.getConnection()) {
            ProgressSchema schema = resolveSchema(conn);
            String sql;
            if (schema.hasModernTracking()) {
                sql = "INSERT INTO MaterialProgress (UserID, MaterialID, CourseID, Status, ViewedAt, UpdatedAt) " +
                        "SELECT ?, ?, m.CourseID, 'in_progress', NOW(), NOW() FROM Material m WHERE m.MaterialID = ? " +
                        "ON DUPLICATE KEY UPDATE Status = CASE WHEN Status='completed' THEN 'completed' ELSE 'in_progress' END, " +
                        "ViewedAt = NOW(), UpdatedAt = NOW()";
            } else {
                sql = "INSERT INTO MaterialProgress (UserID, MaterialID, ViewedAt) VALUES (?,?,NOW()) " +
                        "ON DUPLICATE KEY UPDATE ViewedAt = NOW()";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, materialId);
                if (schema.hasModernTracking()) {
                    ps.setInt(3, materialId);
                }
                ps.executeUpdate();
                return true;
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress markViewed failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean markInProgress(int userId, int materialId, int courseId) {
        try (Connection conn = DBConnection.getConnection()) {
            ProgressSchema schema = resolveSchema(conn);
            if (!schema.hasModernTracking()) {
                return markViewed(userId, materialId);
            }

            String sql = "INSERT INTO MaterialProgress (UserID, MaterialID, CourseID, Status, ViewedAt, UpdatedAt) VALUES (?,?,?,?,NOW(),NOW()) " +
                    "ON DUPLICATE KEY UPDATE Status = CASE WHEN Status='completed' THEN 'completed' ELSE 'in_progress' END, " +
                    "CourseID = VALUES(CourseID), ViewedAt = NOW(), UpdatedAt = NOW()";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, materialId);
                ps.setInt(3, courseId);
                ps.setString(4, "in_progress");
                ps.executeUpdate();
                return true;
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress markInProgress failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean markCompleted(int userId, int materialId, int courseId) {
        try (Connection conn = DBConnection.getConnection()) {
            ProgressSchema schema = resolveSchema(conn);
            String sql;
            if (schema.hasModernTracking()) {
                sql = "INSERT INTO MaterialProgress (UserID, MaterialID, CourseID, Status, CompletedAt, ViewedAt, UpdatedAt) VALUES (?,?,?,?,NOW(),NOW(),NOW()) " +
                        "ON DUPLICATE KEY UPDATE Status='completed', CourseID=VALUES(CourseID), CompletedAt=NOW(), ViewedAt=NOW(), UpdatedAt=NOW()";
            } else {
                sql = "INSERT INTO MaterialProgress (UserID, MaterialID, ViewedAt) VALUES (?,?,NOW()) " +
                        "ON DUPLICATE KEY UPDATE ViewedAt = NOW()";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, materialId);
                if (schema.hasModernTracking()) {
                    ps.setInt(3, courseId);
                    ps.setString(4, "completed");
                }
                ps.executeUpdate();
                return true;
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress markCompleted failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public int countViewedByCourse(int userId, int courseId) {
        try (Connection conn = DBConnection.getConnection()) {
            ProgressSchema schema = resolveSchema(conn);
            String sql = schema.hasStatus
                    ? "SELECT COUNT(*) FROM MaterialProgress mp " +
                    "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                    "WHERE mp.UserID=? AND m.CourseID=? AND mp.Status='completed' AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)"
                    : "SELECT COUNT(*) FROM MaterialProgress mp " +
                    "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                    "WHERE mp.UserID=? AND m.CourseID=? AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress countViewedByCourse failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public Set<Integer> findViewedMaterialIdsByCourse(int userId, int courseId) {
        Set<Integer> viewedIds = new LinkedHashSet<>();
        try (Connection conn = DBConnection.getConnection()) {
            ProgressSchema schema = resolveSchema(conn);
            String sql = schema.hasStatus
                    ? "SELECT mp.MaterialID FROM MaterialProgress mp " +
                    "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                    "WHERE mp.UserID=? AND m.CourseID=? AND mp.Status='completed' AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)"
                    : "SELECT mp.MaterialID FROM MaterialProgress mp " +
                    "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                    "WHERE mp.UserID=? AND m.CourseID=? AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        viewedIds.add(rs.getInt(1));
                    }
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
        try (Connection conn = DBConnection.getConnection()) {
            ProgressSchema schema = resolveSchema(conn);
            String sql = schema.hasStatus
                    ? "SELECT mp.MaterialID, mp.Status FROM MaterialProgress mp " +
                    "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                    "WHERE mp.UserID=? AND m.CourseID=? AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)"
                    : "SELECT mp.MaterialID FROM MaterialProgress mp " +
                    "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                    "WHERE mp.UserID=? AND m.CourseID=? AND (m.IsDeleted=0 OR m.IsDeleted IS NULL)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int materialId = rs.getInt(1);
                        String status = schema.hasStatus ? rs.getString(2) : "completed";
                        statusByMaterial.put(materialId, status);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress findMaterialStatusByCourse failed: " + e.getMessage());
        }
        return statusByMaterial;
    }

    @Override
    public Map<Integer, Integer> countViewedByCourses(int userId, java.util.List<Integer> courseIds) {
        Map<Integer, Integer> counts = new java.util.HashMap<>();
        if (courseIds == null || courseIds.isEmpty()) {
            return counts;
        }
        StringBuilder sql = new StringBuilder(
            "SELECT m.CourseID, COUNT(*) AS cnt FROM MaterialProgress mp " +
            "JOIN Material m ON mp.MaterialID = m.MaterialID " +
            "WHERE mp.UserID=? AND mp.Status='completed' AND (m.IsDeleted=0 OR m.IsDeleted IS NULL) " +
            "AND m.CourseID IN ("
        );
        for (int i = 0; i < courseIds.size(); i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
        }
        sql.append(") GROUP BY m.CourseID");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, userId);
            for (int i = 0; i < courseIds.size(); i++) {
                ps.setInt(i + 2, courseIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getInt("CourseID"), rs.getInt("cnt"));
                }
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress countViewedByCourses failed: " + e.getMessage());
        }
        return counts;
    }

    @Override
    public Map<Integer, Set<Integer>> findViewedMaterialIdsByCourses(int userId, java.util.List<Integer> courseIds) {
        Map<Integer, Set<Integer>> viewedIdsByCourse = new java.util.HashMap<>();
        if (courseIds == null || courseIds.isEmpty()) {
            return viewedIdsByCourse;
        }
        try (Connection conn = DBConnection.getConnection()) {
            ProgressSchema schema = resolveSchema(conn);
            StringBuilder sql = new StringBuilder(
                schema.hasStatus
                    ? "SELECT m.CourseID, mp.MaterialID FROM MaterialProgress mp " +
                      "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                      "WHERE mp.UserID=? AND mp.Status='completed' AND (m.IsDeleted=0 OR m.IsDeleted IS NULL) AND m.CourseID IN ("
                    : "SELECT m.CourseID, mp.MaterialID FROM MaterialProgress mp " +
                      "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                      "WHERE mp.UserID=? AND (m.IsDeleted=0 OR m.IsDeleted IS NULL) AND m.CourseID IN ("
            );
            for (int i = 0; i < courseIds.size(); i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
            }
            sql.append(")");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                ps.setInt(1, userId);
                for (int i = 0; i < courseIds.size(); i++) {
                    ps.setInt(i + 2, courseIds.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int courseId = rs.getInt(1);
                        int materialId = rs.getInt(2);
                        viewedIdsByCourse.computeIfAbsent(courseId, k -> new java.util.LinkedHashSet<>()).add(materialId);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("MaterialProgress findViewedMaterialIdsByCourses failed: " + e.getMessage());
        }
        return viewedIdsByCourse;
    }

    private ProgressSchema resolveSchema(Connection conn) throws SQLException {
        if (cachedSchema != null) {
            return cachedSchema;
        }
        synchronized (MaterialProgressDAOImpl.class) {
            if (cachedSchema == null) {
                cachedSchema = new ProgressSchema(
                        columnExists(conn, "MaterialProgress", "CourseID"),
                        columnExists(conn, "MaterialProgress", "Status"),
                        columnExists(conn, "MaterialProgress", "CompletedAt"),
                        columnExists(conn, "MaterialProgress", "UpdatedAt")
                );
            }
        }
        return cachedSchema;
    }

    private boolean columnExists(Connection conn, String tableName, String columnName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        String catalog = conn.getCatalog();
        try (ResultSet rs = metaData.getColumns(catalog, null, tableName, columnName)) {
            if (rs.next()) {
                return true;
            }
        }
        try (ResultSet rs = metaData.getColumns(catalog, null, tableName.toLowerCase(), columnName)) {
            return rs.next();
        }
    }

    private static final class ProgressSchema {
        private final boolean hasCourseId;
        private final boolean hasStatus;
        private final boolean hasCompletedAt;
        private final boolean hasUpdatedAt;

        private ProgressSchema(boolean hasCourseId, boolean hasStatus, boolean hasCompletedAt, boolean hasUpdatedAt) {
            this.hasCourseId = hasCourseId;
            this.hasStatus = hasStatus;
            this.hasCompletedAt = hasCompletedAt;
            this.hasUpdatedAt = hasUpdatedAt;
        }

        private boolean hasModernTracking() {
            return hasCourseId && hasStatus && hasCompletedAt && hasUpdatedAt;
        }
    }
}
