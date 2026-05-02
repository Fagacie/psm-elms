package com.psm.elearning.dao;

import com.psm.elearning.model.Material;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MaterialDAOImpl implements MaterialDAO {

    private static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int columns = metaData.getColumnCount();
        for (int i = 1; i <= columns; i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) return true;
        }
        return false;
    }

    private boolean hasDisplayOrderColumn(Connection conn) {
        try {
            String catalog = conn.getCatalog();
            try (ResultSet rs = conn.getMetaData().getColumns(catalog, null, "Material", "DisplayOrder")) {
                if (rs.next()) return true;
            }
            try (ResultSet rs = conn.getMetaData().getColumns(catalog, null, "material", "DisplayOrder")) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    private Material mapRow(ResultSet rs) throws SQLException {
        Material m = new Material();
        m.setMaterialId(rs.getInt("MaterialID"));
        m.setCourseId(rs.getInt("CourseID"));
        m.setTitle(rs.getString("Title"));
        m.setDescription(rs.getString("Description"));
        m.setMaterialType(rs.getString("MaterialType"));
        m.setFilePath(rs.getString("FilePath"));
        int uploader = rs.getInt("UploadedBy");
        m.setUploadedBy(rs.wasNull() ? null : uploader);
        Timestamp up = rs.getTimestamp("UploadDate");
        m.setUploadDate(up != null ? up.toLocalDateTime() : null);
        if (hasColumn(rs, "DisplayOrder")) {
            int order = rs.getInt("DisplayOrder");
            m.setDisplayOrder(rs.wasNull() ? null : order);
        }
        if (hasColumn(rs, "IsDeleted")) {
            m.setDeleted(rs.getBoolean("IsDeleted"));
        }
        if (hasColumn(rs, "DeletedAt")) {
            Timestamp deletedAt = rs.getTimestamp("DeletedAt");
            m.setDeletedAt(deletedAt != null ? deletedAt.toLocalDateTime() : null);
        }
        if (hasColumn(rs, "DeletedBy")) {
            int deletedBy = rs.getInt("DeletedBy");
            m.setDeletedBy(rs.wasNull() ? null : deletedBy);
        }
        return m;
    }

    @Override
    public Material create(Material material) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasDisplayOrder = hasDisplayOrderColumn(conn);
            String sql = hasDisplayOrder
                    ? "INSERT INTO Material (CourseID, Title, Description, MaterialType, FilePath, UploadedBy, DisplayOrder) VALUES (?,?,?,?,?,?,?)"
                    : "INSERT INTO Material (CourseID, Title, Description, MaterialType, FilePath, UploadedBy) VALUES (?,?,?,?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, material.getCourseId());
                ps.setString(2, material.getTitle());
                ps.setString(3, material.getDescription());
                ps.setString(4, material.getMaterialType());
                ps.setString(5, material.getFilePath());
                if (material.getUploadedBy() != null) ps.setInt(6, material.getUploadedBy()); else ps.setNull(6, Types.INTEGER);
                if (hasDisplayOrder) {
                    if (material.getDisplayOrder() != null) ps.setInt(7, material.getDisplayOrder()); else ps.setNull(7, Types.INTEGER);
                }
                int affected = ps.executeUpdate();
                if (affected == 0) return null;
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) material.setMaterialId(rs.getInt(1));
                }
                return findById(material.getMaterialId());
            }
        } catch (SQLException e) {
            System.err.println("Material create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public Material findById(int materialId) {
        String sql = "SELECT * FROM Material WHERE MaterialID=? AND (IsDeleted=0 OR IsDeleted IS NULL)";
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
    public Material findAnyById(int materialId) {
        String sql = "SELECT * FROM Material WHERE MaterialID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Material findAnyById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Material> findByCourse(int courseId) {
        List<Material> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasDisplayOrder = hasDisplayOrderColumn(conn);
            String sql = hasDisplayOrder
                    ? "SELECT * FROM Material WHERE CourseID=? AND (IsDeleted=0 OR IsDeleted IS NULL) " +
                    "ORDER BY CASE WHEN DisplayOrder IS NULL THEN 1 ELSE 0 END, DisplayOrder ASC, UploadDate DESC, MaterialID DESC"
                    : "SELECT * FROM Material WHERE CourseID=? AND (IsDeleted=0 OR IsDeleted IS NULL) ORDER BY UploadDate DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Material findByCourse failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<Material> findDeletedByCourse(int courseId) {
        List<Material> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasDisplayOrder = hasDisplayOrderColumn(conn);
            String sql = hasDisplayOrder
                    ? "SELECT * FROM Material WHERE CourseID=? AND IsDeleted=1 " +
                    "ORDER BY CASE WHEN DisplayOrder IS NULL THEN 1 ELSE 0 END, DisplayOrder ASC, DeletedAt DESC, UploadDate DESC"
                    : "SELECT * FROM Material WHERE CourseID=? AND IsDeleted=1 ORDER BY DeletedAt DESC, UploadDate DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Material findDeletedByCourse failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean update(Material material) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasDisplayOrder = hasDisplayOrderColumn(conn);
            String sql = hasDisplayOrder
                    ? "UPDATE Material SET Title=?, Description=?, MaterialType=?, FilePath=?, DisplayOrder=? " +
                    "WHERE MaterialID=? AND (IsDeleted=0 OR IsDeleted IS NULL)"
                    : "UPDATE Material SET Title=?, Description=?, MaterialType=?, FilePath=? " +
                    "WHERE MaterialID=? AND (IsDeleted=0 OR IsDeleted IS NULL)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, material.getTitle());
                ps.setString(2, material.getDescription());
                ps.setString(3, material.getMaterialType());
                ps.setString(4, material.getFilePath());
                if (hasDisplayOrder) {
                    if (material.getDisplayOrder() != null) ps.setInt(5, material.getDisplayOrder()); else ps.setNull(5, Types.INTEGER);
                    ps.setInt(6, material.getMaterialId());
                } else {
                    ps.setInt(5, material.getMaterialId());
                }
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Material update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean delete(int materialId) {
        return softDelete(materialId, null);
    }

    @Override
    public boolean softDelete(int materialId, Integer deletedBy) {
        String sql = "UPDATE Material SET IsDeleted=1, DeletedAt=CURRENT_TIMESTAMP, DeletedBy=? WHERE MaterialID=? AND (IsDeleted=0 OR IsDeleted IS NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (deletedBy != null) {
                ps.setInt(1, deletedBy);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setInt(2, materialId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Material softDelete failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean restore(int materialId) {
        String sql = "UPDATE Material SET IsDeleted=0, DeletedAt=NULL, DeletedBy=NULL WHERE MaterialID=? AND IsDeleted=1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, materialId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Material restore failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public int getMaxDisplayOrder(int courseId) {
        try (Connection conn = DBConnection.getConnection()) {
            if (!hasDisplayOrderColumn(conn)) {
                return findByCourse(courseId).size();
            }
            String sql = "SELECT COALESCE(MAX(DisplayOrder),0) FROM Material WHERE CourseID=? AND (IsDeleted=0 OR IsDeleted IS NULL)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Material getMaxDisplayOrder failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public boolean shiftDisplayOrderFrom(int courseId, int fromOrder, Integer excludeMaterialId) {
        try (Connection conn = DBConnection.getConnection()) {
            if (!hasDisplayOrderColumn(conn)) return false;

            String sql = "UPDATE Material SET DisplayOrder = DisplayOrder + 1 " +
                    "WHERE CourseID=? AND (IsDeleted=0 OR IsDeleted IS NULL) AND DisplayOrder IS NOT NULL AND DisplayOrder>=?" +
                    (excludeMaterialId != null ? " AND MaterialID<>?" : "");

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, courseId);
                ps.setInt(2, fromOrder);
                if (excludeMaterialId != null) ps.setInt(3, excludeMaterialId);
                ps.executeUpdate();
                return true;
            }
        } catch (SQLException e) {
            System.err.println("Material shiftDisplayOrderFrom failed: " + e.getMessage());
            return false;
        }
    }
}
