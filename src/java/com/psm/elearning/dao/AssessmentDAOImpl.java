package com.psm.elearning.dao;

import com.psm.elearning.model.Assessment;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssessmentDAOImpl implements AssessmentDAO {

    private volatile Boolean placementColumnsAvailable;
    private volatile Boolean gradingModeColumnAvailable;
    private volatile Boolean submissionModeColumnAvailable;
    private volatile Boolean archiveColumnsAvailable;
    private volatile Boolean statusColumnAvailable;

    private boolean supportsPlacementColumns(Connection conn) {
        if (placementColumnsAvailable != null) {
            return placementColumnsAvailable;
        }
        synchronized (this) {
            if (placementColumnsAvailable != null) {
                return placementColumnsAvailable;
            }
            String sql = "SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS "
                    + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Assessment' "
                    + "AND COLUMN_NAME IN ('PlacementType','PlacementMaterialID')";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    placementColumnsAvailable = rs.getInt("cnt") == 2;
                } else {
                    placementColumnsAvailable = false;
                }
            } catch (SQLException e) {
                placementColumnsAvailable = false;
            }
            return placementColumnsAvailable;
        }
    }

    private static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int count = metaData.getColumnCount();
        for (int i = 1; i <= count; i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) return true;
        }
        return false;
    }

    private boolean supportsGradingModeColumn(Connection conn) {
        if (gradingModeColumnAvailable != null) {
            return gradingModeColumnAvailable;
        }
        synchronized (this) {
            if (gradingModeColumnAvailable != null) {
                return gradingModeColumnAvailable;
            }
            String sql = "SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS "
                    + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Assessment' "
                    + "AND COLUMN_NAME = 'GradingMode'";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    gradingModeColumnAvailable = rs.getInt("cnt") == 1;
                } else {
                    gradingModeColumnAvailable = false;
                }
            } catch (SQLException e) {
                gradingModeColumnAvailable = false;
            }
            return gradingModeColumnAvailable;
        }
    }

    private boolean supportsSubmissionModeColumn(Connection conn) {
        if (submissionModeColumnAvailable != null) {
            return submissionModeColumnAvailable;
        }
        synchronized (this) {
            if (submissionModeColumnAvailable != null) {
                return submissionModeColumnAvailable;
            }
            String sql = "SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS "
                    + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Assessment' "
                    + "AND COLUMN_NAME = 'SubmissionMode'";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    submissionModeColumnAvailable = rs.getInt("cnt") == 1;
                } else {
                    submissionModeColumnAvailable = false;
                }
            } catch (SQLException e) {
                submissionModeColumnAvailable = false;
            }
            return submissionModeColumnAvailable;
        }
    }

    private boolean supportsArchiveColumns(Connection conn) {
        if (archiveColumnsAvailable != null) {
            return archiveColumnsAvailable;
        }
        synchronized (this) {
            if (archiveColumnsAvailable != null) {
                return archiveColumnsAvailable;
            }
            String sql = "SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS "
                    + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Assessment' "
                    + "AND COLUMN_NAME IN ('IsDeleted','DeletedAt','DeletedBy')";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    archiveColumnsAvailable = rs.getInt("cnt") >= 2;
                } else {
                    archiveColumnsAvailable = false;
                }
            } catch (SQLException e) {
                archiveColumnsAvailable = false;
            }
            return archiveColumnsAvailable;
        }
    }

    private boolean supportsStatusColumn(Connection conn) {
        if (statusColumnAvailable != null) {
            return statusColumnAvailable;
        }
        synchronized (this) {
            if (statusColumnAvailable != null) {
                return statusColumnAvailable;
            }
            String sql = "SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS "
                    + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Assessment' "
                    + "AND COLUMN_NAME = 'Status'";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    statusColumnAvailable = rs.getInt("cnt") == 1;
                } else {
                    statusColumnAvailable = false;
                }
            } catch (SQLException e) {
                statusColumnAvailable = false;
            }
            if (!statusColumnAvailable) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("ALTER TABLE Assessment ADD COLUMN Status VARCHAR(50) DEFAULT 'Draft'");
                    statusColumnAvailable = true;
                } catch (SQLException e) {
                    System.err.println("Failed to auto-add Status column: " + e.getMessage());
                }
            }
            return statusColumnAvailable;
        }
    }

    private Assessment mapRow(ResultSet rs) throws SQLException {
        Assessment a = new Assessment();
        a.setAssessmentId(rs.getInt("AssessmentID"));
        a.setCourseId(rs.getInt("CourseID"));
        a.setTitle(rs.getString("Title"));
        a.setType(rs.getString("Type"));
        if (hasColumn(rs, "GradingMode")) {
            a.setGradingMode(rs.getString("GradingMode"));
        }
        if (hasColumn(rs, "SubmissionMode")) {
            a.setSubmissionMode(rs.getString("SubmissionMode"));
        }
        int duration = rs.getInt("Duration");
        a.setDuration(rs.wasNull() ? null : duration);
        int total = rs.getInt("TotalMarks");
        a.setTotalMarks(rs.wasNull() ? null : total);
        String rawInstructions = rs.getString("Instructions");
        a.setInstructions(com.psm.elearning.util.AssessmentPlacementUtil.stripPlacement(rawInstructions));
        if (hasColumn(rs, "Status")) {
            a.setStatus(rs.getString("Status"));
        } else {
            a.setStatus("Draft"); // Default
        }
        int maxAttempts = rs.getInt("MaxAttempts");
        a.setMaxAttempts(rs.wasNull() ? null : maxAttempts);
        if (hasColumn(rs, "PlacementType")) {
            a.setPlacementType(rs.getString("PlacementType"));
        }
        if (hasColumn(rs, "PlacementMaterialID")) {
            int placementMaterialId = rs.getInt("PlacementMaterialID");
            a.setPlacementMaterialId(rs.wasNull() ? null : placementMaterialId);
        }
        if (a.getPlacementType() == null || a.getPlacementType().trim().isEmpty()) {
            com.psm.elearning.util.AssessmentPlacementUtil.Placement placement = com.psm.elearning.util.AssessmentPlacementUtil.parsePlacement(rawInstructions);
            a.setPlacementType(placement.type);
            a.setPlacementMaterialId(placement.materialId);
        }
        Timestamp cAt = rs.getTimestamp("CreatedAt");
        a.setCreatedAt(cAt != null ? cAt.toLocalDateTime() : null);
        a.setCreatedBy(rs.getInt("CreatedBy"));
        return a;
    }

    @Override
    public Assessment create(Assessment assessment) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean supportsPlacement = supportsPlacementColumns(conn);
            boolean supportsGradingMode = supportsGradingModeColumn(conn);
            boolean supportsSubmissionMode = supportsSubmissionModeColumn(conn);
            boolean supportsStatus = supportsStatusColumn(conn);
            
            StringBuilder columns = new StringBuilder("CourseID, Title, Type, Duration, TotalMarks, Instructions, MaxAttempts, CreatedBy");
            StringBuilder placeholders = new StringBuilder("?,?,?,?,?,?,?,?");
            
            if (supportsGradingMode) {
                columns.append(", GradingMode");
                placeholders.append(", ?");
            }
            if (supportsSubmissionMode) {
                columns.append(", SubmissionMode");
                placeholders.append(", ?");
            }
            if (supportsPlacement) {
                columns.append(", PlacementType, PlacementMaterialID");
                placeholders.append(", ?, ?");
            }
            if (supportsStatus) {
                columns.append(", Status");
                placeholders.append(", ?");
            }
            
            String sql = "INSERT INTO Assessment (" + columns + ") VALUES (" + placeholders + ")";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            int i = 1;
            ps.setInt(i++, assessment.getCourseId());
            ps.setString(i++, assessment.getTitle());
            ps.setString(i++, assessment.getType());
            if (assessment.getDuration() != null) ps.setInt(i++, assessment.getDuration()); else ps.setNull(i++, Types.INTEGER);
            if (assessment.getTotalMarks() != null) ps.setInt(i++, assessment.getTotalMarks()); else ps.setNull(i++, Types.INTEGER);
            String instructionsText = assessment.getInstructions();
            if (!supportsPlacement) {
                instructionsText = com.psm.elearning.util.AssessmentPlacementUtil.applyPlacement(
                    instructionsText,
                    com.psm.elearning.util.AssessmentPlacementUtil.toPlacementKey(
                        new com.psm.elearning.util.AssessmentPlacementUtil.Placement(assessment.getPlacementType(), assessment.getPlacementMaterialId())
                    )
                );
            }
            ps.setString(i++, instructionsText);
            ps.setInt(i++, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
            ps.setInt(i++, assessment.getCreatedBy());
            if (supportsGradingMode) {
                ps.setString(i++, assessment.getGradingMode() != null ? assessment.getGradingMode() : "auto");
            }
            if (supportsSubmissionMode) {
                ps.setString(i++, assessment.getSubmissionMode() != null ? assessment.getSubmissionMode() : "both");
            }
            if (supportsPlacement) {
                ps.setString(i++, assessment.getPlacementType());
                if (assessment.getPlacementMaterialId() != null) {
                    ps.setInt(i++, assessment.getPlacementMaterialId());
                } else {
                    ps.setNull(i++, Types.INTEGER);
                }
            }
            if (supportsStatus) {
                ps.setString(i++, assessment.getStatus() != null ? assessment.getStatus() : "Draft");
            }
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) assessment.setAssessmentId(rs.getInt(1));
            }
            return findById(assessment.getAssessmentId());
            }
        } catch (SQLException e) {
            System.err.println("Assessment create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public Assessment findById(int assessmentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     supportsArchiveColumns(conn)
                             ? "SELECT * FROM Assessment WHERE AssessmentID=? AND (IsDeleted IS NULL OR IsDeleted=0)"
                             : "SELECT * FROM Assessment WHERE AssessmentID=?")) {
            ps.setInt(1, assessmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Assessment findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public Assessment findAnyById(int assessmentId) {
        String sql = "SELECT * FROM Assessment WHERE AssessmentID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Assessment findAnyById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Assessment> findByCourse(int courseId) {
        List<Assessment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     supportsArchiveColumns(conn)
                             ? "SELECT * FROM Assessment WHERE CourseID=? AND (IsDeleted IS NULL OR IsDeleted=0) ORDER BY CreatedAt DESC"
                             : "SELECT * FROM Assessment WHERE CourseID=? ORDER BY CreatedAt DESC")) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Assessment findByCourse failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<Assessment> findByCourseIds(List<Integer> courseIds) {
        List<Assessment> list = new ArrayList<>();
        if (courseIds == null || courseIds.isEmpty()) {
            return list;
        }
        try (Connection conn = DBConnection.getConnection()) {
            boolean supportsArchive = supportsArchiveColumns(conn);
            StringBuilder sql = new StringBuilder("SELECT * FROM Assessment WHERE CourseID IN (");
            for (int i = 0; i < courseIds.size(); i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
            }
            sql.append(")");
            if (supportsArchive) {
                sql.append(" AND (IsDeleted IS NULL OR IsDeleted=0)");
            }
            sql.append(" ORDER BY CreatedAt DESC");
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < courseIds.size(); i++) {
                    ps.setInt(i + 1, courseIds.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Assessment findByCourseIds failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<Assessment> findDeletedByCourse(int courseId) {
        List<Assessment> list = new ArrayList<>();
        if (!supportsArchiveColumnsSafe()) {
            return list;
        }
        String sql = "SELECT * FROM Assessment WHERE CourseID=? AND IsDeleted=1 ORDER BY DeletedAt DESC, CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Assessment findDeletedByCourse failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean update(Assessment assessment) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean supportsPlacement = supportsPlacementColumns(conn);
            boolean supportsGradingMode = supportsGradingModeColumn(conn);
            boolean supportsSubmissionMode = supportsSubmissionModeColumn(conn);
            boolean supportsStatus = supportsStatusColumn(conn);
            
            StringBuilder sql = new StringBuilder("UPDATE Assessment SET Title=?, Type=?, Duration=?, TotalMarks=?, Instructions=?, MaxAttempts=?");
            
            if (supportsGradingMode) {
                sql.append(", GradingMode=?");
            }
            if (supportsSubmissionMode) {
                sql.append(", SubmissionMode=?");
            }
            if (supportsPlacement) {
                sql.append(", PlacementType=?, PlacementMaterialID=?");
            }
            if (supportsStatus) {
                sql.append(", Status=?");
            }
            
            sql.append(" WHERE AssessmentID=?");
            
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            ps.setString(i++, assessment.getTitle());
            ps.setString(i++, assessment.getType());
            if (assessment.getDuration() != null) ps.setInt(i++, assessment.getDuration()); else ps.setNull(i++, Types.INTEGER);
            if (assessment.getTotalMarks() != null) ps.setInt(i++, assessment.getTotalMarks()); else ps.setNull(i++, Types.INTEGER);
            String instructionsText = assessment.getInstructions();
            if (!supportsPlacement) {
                instructionsText = com.psm.elearning.util.AssessmentPlacementUtil.applyPlacement(
                    instructionsText,
                    com.psm.elearning.util.AssessmentPlacementUtil.toPlacementKey(
                        new com.psm.elearning.util.AssessmentPlacementUtil.Placement(assessment.getPlacementType(), assessment.getPlacementMaterialId())
                    )
                );
            }
            ps.setString(i++, instructionsText);
            ps.setInt(i++, assessment.getMaxAttempts() != null ? assessment.getMaxAttempts() : 1);
            if (supportsGradingMode) {
                ps.setString(i++, assessment.getGradingMode() != null ? assessment.getGradingMode() : "auto");
            }
            if (supportsSubmissionMode) {
                ps.setString(i++, assessment.getSubmissionMode() != null ? assessment.getSubmissionMode() : "both");
            }
            if (supportsPlacement) {
                ps.setString(i++, assessment.getPlacementType());
                if (assessment.getPlacementMaterialId() != null) {
                    ps.setInt(i++, assessment.getPlacementMaterialId());
                } else {
                    ps.setNull(i++, Types.INTEGER);
                }
            }
            if (supportsStatus) {
                ps.setString(i++, assessment.getStatus() != null ? assessment.getStatus() : "Draft");
            }
            ps.setInt(i++, assessment.getAssessmentId());
            return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Assessment update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean delete(int assessmentId) {
        String sql = "DELETE FROM Assessment WHERE AssessmentID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assessmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Assessment delete failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean archive(int assessmentId, Integer archivedBy) {
        try (Connection conn = DBConnection.getConnection()) {
            if (!supportsArchiveColumns(conn)) {
                return delete(assessmentId);
            }
            String sql = "UPDATE Assessment SET IsDeleted=1, DeletedAt=CURRENT_TIMESTAMP, DeletedBy=? WHERE AssessmentID=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (archivedBy != null) {
                    ps.setInt(1, archivedBy);
                } else {
                    ps.setNull(1, Types.INTEGER);
                }
                ps.setInt(2, assessmentId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Assessment archive failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean restore(int assessmentId) {
        try (Connection conn = DBConnection.getConnection()) {
            if (!supportsArchiveColumns(conn)) {
                return false;
            }
            String sql = "UPDATE Assessment SET IsDeleted=0, DeletedAt=NULL, DeletedBy=NULL WHERE AssessmentID=? AND IsDeleted=1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, assessmentId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Assessment restore failed: " + e.getMessage());
            return false;
        }
    }

    private boolean supportsArchiveColumnsSafe() {
        try (Connection conn = DBConnection.getConnection()) {
            return supportsArchiveColumns(conn);
        } catch (SQLException e) {
            return false;
        }
    }
}
