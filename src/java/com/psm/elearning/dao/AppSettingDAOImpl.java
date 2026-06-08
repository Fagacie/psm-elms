package com.psm.elearning.dao;

import com.psm.elearning.model.AppSettingAuditEntry;
import com.psm.elearning.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class AppSettingDAOImpl implements AppSettingDAO {

    private static boolean tablesEnsured = false;

    public AppSettingDAOImpl() {
        if (!tablesEnsured) {
            ensureTableExists();
            ensureAuditTableExists();
            tablesEnsured = true;
        }
    }

    private void ensureTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS AppSetting ("
                + "SettingKey VARCHAR(120) PRIMARY KEY,"
                + "SettingValue TEXT NULL,"
                + "UpdatedBy INT NULL,"
                + "CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                + "UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
                + "CONSTRAINT fk_app_setting_updated_by FOREIGN KEY (UpdatedBy) REFERENCES User(UserID) ON DELETE SET NULL ON UPDATE CASCADE"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Failed to ensure AppSetting table exists: " + e.getMessage());
        }
    }

    private void ensureAuditTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS AppSettingAudit ("
                + "AuditID INT AUTO_INCREMENT PRIMARY KEY,"
                + "SettingKey VARCHAR(120) NOT NULL,"
                + "OldValue TEXT NULL,"
                + "NewValue TEXT NULL,"
                + "ChangedBy INT NULL,"
                + "ChangedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                + "INDEX idx_app_setting_audit_changed_at (ChangedAt),"
                + "INDEX idx_app_setting_audit_key (SettingKey),"
                + "CONSTRAINT fk_app_setting_audit_changed_by FOREIGN KEY (ChangedBy) REFERENCES User(UserID) ON DELETE SET NULL ON UPDATE CASCADE"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Failed to ensure AppSettingAudit table exists: " + e.getMessage());
        }
    }

    @Override
    public Map<String, String> findAllAsMap() {
        Map<String, String> result = new LinkedHashMap<>();
        String sql = "SELECT SettingKey, SettingValue FROM AppSetting ORDER BY SettingKey";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.put(rs.getString("SettingKey"), rs.getString("SettingValue"));
            }
        } catch (SQLException e) {
            System.err.println("Failed to fetch app settings: " + e.getMessage());
        }

        return result;
    }

    @Override
    public boolean upsertAll(Map<String, String> settings, Integer updatedBy) {
        if (settings == null || settings.isEmpty()) {
            return true;
        }

        String upsertSql = "INSERT INTO AppSetting (SettingKey, SettingValue, UpdatedBy) VALUES (?,?,?) "
                + "ON DUPLICATE KEY UPDATE SettingValue=VALUES(SettingValue), UpdatedBy=VALUES(UpdatedBy), UpdatedAt=CURRENT_TIMESTAMP";
        String selectSql = "SELECT SettingValue FROM AppSetting WHERE SettingKey=?";
        String auditSql = "INSERT INTO AppSettingAudit (SettingKey, OldValue, NewValue, ChangedBy) VALUES (?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement upsertPs = conn.prepareStatement(upsertSql);
             PreparedStatement selectPs = conn.prepareStatement(selectSql);
             PreparedStatement auditPs = conn.prepareStatement(auditSql)) {
            conn.setAutoCommit(false);
            try {
                for (Map.Entry<String, String> entry : settings.entrySet()) {
                    String key = entry.getKey();
                    String newValue = entry.getValue();
                    String oldValue = findCurrentValue(conn, selectPs, key);

                    upsertPs.setString(1, key);
                    upsertPs.setString(2, newValue);
                    if (updatedBy == null) {
                        upsertPs.setNull(3, java.sql.Types.INTEGER);
                    } else {
                        upsertPs.setInt(3, updatedBy);
                    }

                    upsertPs.addBatch();

                    if (hasValueChanged(oldValue, newValue)) {
                        auditPs.setString(1, key);
                        auditPs.setString(2, maskIfSecret(key, oldValue));
                        auditPs.setString(3, maskIfSecret(key, newValue));
                        if (updatedBy == null) {
                            auditPs.setNull(4, java.sql.Types.INTEGER);
                        } else {
                            auditPs.setInt(4, updatedBy);
                        }
                        auditPs.addBatch();
                    }
                }

                upsertPs.executeBatch();
                auditPs.executeBatch();
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                System.err.println("Failed to save app settings batch: " + ex.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Failed to save app settings: " + e.getMessage());
            return false;
        }
    }

    @Override
    public List<AppSettingAuditEntry> findRecentAudits(int limit) {
        List<AppSettingAuditEntry> result = new ArrayList<>();
        String sql = "SELECT AuditID, SettingKey, OldValue, NewValue, ChangedBy, ChangedAt "
                + "FROM AppSettingAudit ORDER BY ChangedAt DESC, AuditID DESC LIMIT ?";

        int safeLimit = limit <= 0 ? 10 : Math.min(limit, 100);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeLimit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AppSettingAuditEntry row = new AppSettingAuditEntry();
                    row.setAuditId(rs.getInt("AuditID"));
                    row.setSettingKey(rs.getString("SettingKey"));
                    row.setOldValue(rs.getString("OldValue"));
                    row.setNewValue(rs.getString("NewValue"));
                    int changedBy = rs.getInt("ChangedBy");
                    row.setChangedBy(rs.wasNull() ? null : changedBy);
                    row.setChangedAt(rs.getTimestamp("ChangedAt"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("Failed to fetch app setting audits: " + e.getMessage());
        }

        return result;
    }

    private String findCurrentValue(Connection conn, PreparedStatement ps, String key) throws SQLException {
        ps.setString(1, key);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getString("SettingValue");
            }
            return null;
        }
    }

    private boolean hasValueChanged(String oldValue, String newValue) {
        if (oldValue == null && newValue == null) {
            return false;
        }
        if (oldValue == null || newValue == null) {
            return true;
        }
        return !oldValue.equals(newValue);
    }

    private boolean isSecretKey(String key) {
        if (key == null) {
            return false;
        }
        String normalized = key.toLowerCase(Locale.ENGLISH);
        return normalized.contains("password")
                || normalized.contains("secret")
                || normalized.contains("token")
                || normalized.contains("apikey")
                || normalized.contains("api.key")
                || normalized.contains("webhook");
    }

    private String maskIfSecret(String key, String value) {
        if (!isSecretKey(key)) {
            return value;
        }
        if (value == null || value.trim().isEmpty()) {
            return "";
        }
        return "[REDACTED]";
    }
}
