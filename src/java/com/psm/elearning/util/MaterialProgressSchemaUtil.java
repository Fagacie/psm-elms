package com.psm.elearning.util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Keeps MaterialProgress compatible with both legacy and current tracking fields.
 */
public final class MaterialProgressSchemaUtil {

    private MaterialProgressSchemaUtil() {
    }

    public static void ensureCompatibility() {
        try (Connection conn = DBConnection.getConnection()) {
            if (!tableExists(conn, "MaterialProgress")) {
                return;
            }

            boolean addedCourseId = addColumnIfMissing(conn, "MaterialProgress", "CourseID", "INT NULL");
            boolean addedStatus = addColumnIfMissing(conn, "MaterialProgress", "Status",
                    "ENUM('in_progress','completed') NOT NULL DEFAULT 'in_progress'");
            addColumnIfMissing(conn, "MaterialProgress", "CompletedAt", "TIMESTAMP NULL DEFAULT NULL");
            addColumnIfMissing(conn, "MaterialProgress", "UpdatedAt",
                    "TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");

            createIndexIfMissing(conn, "MaterialProgress", "idx_material_progress_course", "CourseID");
            createIndexIfMissing(conn, "MaterialProgress", "idx_material_progress_status", "Status");

            if (addedCourseId || columnExists(conn, "MaterialProgress", "CourseID")) {
                backfillCourseId(conn);
            }
            if (addedStatus) {
                upgradeLegacyRows(conn);
            } else {
                normalizeStatusValues(conn);
            }
            backfillCompletedAt(conn);
            backfillUpdatedAt(conn);
        } catch (SQLException e) {
            System.err.println("MaterialProgressSchemaUtil failed: " + e.getMessage());
        }
    }

    private static boolean tableExists(Connection conn, String tableName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        String catalog = conn.getCatalog();
        try (ResultSet rs = metaData.getTables(catalog, null, tableName, new String[]{"TABLE"})) {
            if (rs.next()) {
                return true;
            }
        }
        try (ResultSet rs = metaData.getTables(catalog, null, tableName.toLowerCase(), new String[]{"TABLE"})) {
            return rs.next();
        }
    }

    private static boolean columnExists(Connection conn, String tableName, String columnName) throws SQLException {
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

    private static boolean indexExists(Connection conn, String tableName, String indexName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        String catalog = conn.getCatalog();
        try (ResultSet rs = metaData.getIndexInfo(catalog, null, tableName, false, false)) {
            while (rs.next()) {
                String current = rs.getString("INDEX_NAME");
                if (indexName.equalsIgnoreCase(current)) {
                    return true;
                }
            }
        }
        try (ResultSet rs = metaData.getIndexInfo(catalog, null, tableName.toLowerCase(), false, false)) {
            while (rs.next()) {
                String current = rs.getString("INDEX_NAME");
                if (indexName.equalsIgnoreCase(current)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static boolean addColumnIfMissing(Connection conn,
                                              String tableName,
                                              String columnName,
                                              String definition) throws SQLException {
        if (columnExists(conn, tableName, columnName)) {
            return false;
        }
        try (Statement statement = conn.createStatement()) {
            statement.executeUpdate("ALTER TABLE `" + tableName + "` ADD COLUMN `" + columnName + "` " + definition);
            System.out.println("MaterialProgressSchemaUtil added column " + columnName + ".");
            return true;
        }
    }

    private static void createIndexIfMissing(Connection conn,
                                             String tableName,
                                             String indexName,
                                             String columnName) throws SQLException {
        if (!columnExists(conn, tableName, columnName) || indexExists(conn, tableName, indexName)) {
            return;
        }
        try (Statement statement = conn.createStatement()) {
            statement.executeUpdate("CREATE INDEX `" + indexName + "` ON `" + tableName + "` (`" + columnName + "`)");
            System.out.println("MaterialProgressSchemaUtil added index " + indexName + ".");
        }
    }

    private static void backfillCourseId(Connection conn) throws SQLException {
        if (!columnExists(conn, "MaterialProgress", "CourseID")) {
            return;
        }
        String sql = "UPDATE MaterialProgress mp " +
                "JOIN Material m ON mp.MaterialID = m.MaterialID " +
                "SET mp.CourseID = m.CourseID " +
                "WHERE mp.CourseID IS NULL";
        executeUpdate(conn, sql);
    }

    private static void upgradeLegacyRows(Connection conn) throws SQLException {
        if (!columnExists(conn, "MaterialProgress", "Status")) {
            return;
        }
        String sql = "UPDATE MaterialProgress " +
                "SET Status='completed', " +
                "CompletedAt = COALESCE(CompletedAt, ViewedAt) " +
                "WHERE ViewedAt IS NOT NULL";
        executeUpdate(conn, sql);
    }

    private static void normalizeStatusValues(Connection conn) throws SQLException {
        if (!columnExists(conn, "MaterialProgress", "Status")) {
            return;
        }
        String sql = "UPDATE MaterialProgress " +
                "SET Status='completed' " +
                "WHERE Status IS NULL OR TRIM(Status) = ''";
        executeUpdate(conn, sql);
    }

    private static void backfillCompletedAt(Connection conn) throws SQLException {
        if (!columnExists(conn, "MaterialProgress", "CompletedAt")
                || !columnExists(conn, "MaterialProgress", "Status")) {
            return;
        }
        String sql = "UPDATE MaterialProgress " +
                "SET CompletedAt = COALESCE(CompletedAt, ViewedAt) " +
                "WHERE Status='completed' AND CompletedAt IS NULL";
        executeUpdate(conn, sql);
    }

    private static void backfillUpdatedAt(Connection conn) throws SQLException {
        if (!columnExists(conn, "MaterialProgress", "UpdatedAt")) {
            return;
        }
        String sql = "UPDATE MaterialProgress " +
                "SET UpdatedAt = COALESCE(UpdatedAt, CompletedAt, ViewedAt, CURRENT_TIMESTAMP) " +
                "WHERE UpdatedAt IS NULL";
        executeUpdate(conn, sql);
    }

    private static void executeUpdate(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }
}
