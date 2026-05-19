package com.psm.elearning.dao;

import com.psm.elearning.model.Enrollment;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Implementation of EnrollmentDAO using JDBC.
 */
public class EnrollmentDAOImpl implements EnrollmentDAO {

    private static final Logger LOGGER = Logger.getLogger(EnrollmentDAOImpl.class.getName());

    @Override
    public Enrollment createEnrollment(Enrollment enrollment) {
        String sql = "INSERT INTO Enrollment (UserID, CourseID, Status, EnrollmentDate) VALUES (?, ?, ?, NOW())";

        LOGGER.info("Creating enrollment userId=" + enrollment.getUserId() + ", courseId=" + enrollment.getCourseId());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, enrollment.getUserId());
            ps.setInt(2, enrollment.getCourseId());
            String initialStatus = enrollment.getStatus() != null ? enrollment.getStatus() : "Pending";
            ps.setString(3, initialStatus);

            int affected = ps.executeUpdate();

            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        enrollment.setEnrollmentId(rs.getInt(1));
                        enrollment.setStatus(initialStatus);
                        enrollment.setEnrollmentDate(LocalDateTime.now());
                        LOGGER.info("Enrollment created successfully enrollmentId=" + enrollment.getEnrollmentId());
                        return enrollment;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating enrollment", e);
        }
        return null;
    }

    @Override
    public boolean checkExistingEnrollment(Integer userId, Integer courseId) {
        String sql = "SELECT COUNT(*) FROM Enrollment WHERE UserID = ? AND CourseID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking existing enrollment userId=" + userId + ", courseId=" + courseId, e);
        }
        return false;
    }

    @Override
    public Enrollment findLatestEnrollmentByUserAndCourse(Integer userId, Integer courseId) {
        String sql = "SELECT EnrollmentID FROM Enrollment WHERE UserID = ? AND CourseID = ? ORDER BY EnrollmentDate DESC, EnrollmentID DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int enrollmentId = rs.getInt("EnrollmentID");
                    return getEnrollment(enrollmentId);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding latest enrollment userId=" + userId + ", courseId=" + courseId, e);
        }
        return null;
    }

    @Override
    public boolean updatePaymentStatus(Integer enrollmentId, String paymentStatus, String paymentRef) {
        String sql = "UPDATE Enrollment SET PaymentStatus = ?, PaymentRef = ? WHERE EnrollmentID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, paymentStatus);
            if (paymentRef == null || paymentRef.trim().isEmpty()) {
                ps.setNull(2, Types.VARCHAR);
            } else {
                ps.setString(2, paymentRef.trim());
            }
            ps.setInt(3, enrollmentId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating enrollment payment status enrollmentId=" + enrollmentId, e);
        }
        return false;
    }

    @Override
    public boolean updateStatus(Integer enrollmentId, String status) {
        String sql = "UPDATE Enrollment SET Status = ? WHERE EnrollmentID = ?";

        LOGGER.info("Updating enrollment status enrollmentId=" + enrollmentId + ", status=" + status);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, enrollmentId);

            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating enrollment status enrollmentId=" + enrollmentId, e);
        }
        return false;
    }

    @Override
    public boolean updateLearningProgress(Integer enrollmentId, Integer progress, String completionStatus, String status) {
        String sql = "UPDATE Enrollment SET Progress = ?, CompletionStatus = ?, Status = ? WHERE EnrollmentID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int safeProgress = progress == null ? 0 : Math.max(0, Math.min(100, progress));
            String safeCompletion = completionStatus == null || completionStatus.trim().isEmpty() ? "Not Started" : completionStatus.trim();
            String safeStatus = status == null || status.trim().isEmpty() ? "Enrolled" : status.trim();

            ps.setInt(1, safeProgress);
            ps.setString(2, safeCompletion);
            ps.setString(3, safeStatus);
            ps.setInt(4, enrollmentId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating learning progress enrollmentId=" + enrollmentId, e);
        }
        return false;
    }

    @Override
    public List<Enrollment> getEnrollmentsByStudent(Integer userId) {
        List<Enrollment> enrollments = new ArrayList<>();
        String sql = "SELECT e.*, c.Title AS CourseTitle, c.Description, c.CourseFee, c.CourseBanner, c.Duration AS CourseDuration, c.Level AS CourseLevel, c.Category AS CourseCategory, u.FullName AS InstructorName " +
                "FROM Enrollment e " +
                "JOIN Course c ON e.CourseID = c.CourseID " +
                "LEFT JOIN User u ON c.InstructorID = u.UserID " +
                "WHERE e.UserID = ? " +
                "ORDER BY e.EnrollmentDate DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Enrollment enrollment = mapResultSet(rs);
                    enrollment.setCourseName(rs.getString("CourseTitle"));
                    enrollment.setCourseDescription(rs.getString("Description"));
                    enrollment.setCoursePrice(rs.getDouble("CourseFee"));
                    enrollment.setCourseBanner(rs.getString("CourseBanner"));
                    int durationVal = rs.getInt("CourseDuration");
                    if (!rs.wasNull()) {
                        enrollment.setCourseDuration(durationVal);
                    }
                    enrollment.setInstructorName(rs.getString("InstructorName"));
                    enrollment.setLevel(rs.getString("CourseLevel"));
                    enrollment.setCategory(rs.getString("CourseCategory"));
                    enrollments.add(enrollment);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting enrollments by student userId=" + userId, e);
        }
        return enrollments;
    }

    @Override
    public Enrollment getEnrollment(Integer enrollmentId) {
        String sql = "SELECT e.*, c.Title AS CourseTitle, c.Description, c.CourseFee, c.CourseBanner, c.Duration AS CourseDuration, c.Level AS CourseLevel, c.Category AS CourseCategory, u.FullName AS InstructorName " +
                "FROM Enrollment e " +
                "JOIN Course c ON e.CourseID = c.CourseID " +
                "LEFT JOIN User u ON c.InstructorID = u.UserID " +
                "WHERE e.EnrollmentID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, enrollmentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Enrollment enrollment = mapResultSet(rs);
                    enrollment.setCourseName(rs.getString("CourseTitle"));
                    enrollment.setCourseDescription(rs.getString("Description"));
                    enrollment.setCoursePrice(rs.getDouble("CourseFee"));
                    enrollment.setCourseBanner(rs.getString("CourseBanner"));
                    int durationVal = rs.getInt("CourseDuration");
                    if (!rs.wasNull()) {
                        enrollment.setCourseDuration(durationVal);
                    }
                    enrollment.setInstructorName(rs.getString("InstructorName"));
                    enrollment.setLevel(rs.getString("CourseLevel"));
                    enrollment.setCategory(rs.getString("CourseCategory"));
                    return enrollment;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting enrollment enrollmentId=" + enrollmentId, e);
        }
        return null;
    }

    @Override
    public List<Enrollment> getAllEnrollments() {
        List<Enrollment> enrollments = new ArrayList<>();
        String sql = "SELECT e.*, c.Title AS CourseTitle, c.CourseFee, c.Duration AS CourseDuration, u.FullName AS StudentName, u.Email AS StudentEmail " +
                "FROM Enrollment e " +
                "JOIN Course c ON e.CourseID = c.CourseID " +
                "JOIN User u ON e.UserID = u.UserID " +
                "ORDER BY e.EnrollmentDate DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Enrollment enrollment = mapResultSet(rs);
                enrollment.setCourseName(rs.getString("CourseTitle"));
                enrollment.setCoursePrice(rs.getDouble("CourseFee"));
                int durationVal = rs.getInt("CourseDuration");
                if (!rs.wasNull()) {
                    enrollment.setCourseDuration(durationVal);
                }
                enrollment.setStudentName(rs.getString("StudentName"));
                enrollment.setStudentEmail(rs.getString("StudentEmail"));
                enrollments.add(enrollment);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all enrollments", e);
        }
        return enrollments;
    }

    /**
     * Map ResultSet to Enrollment object.
     */
    private Enrollment mapResultSet(ResultSet rs) throws SQLException {
        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(rs.getInt("EnrollmentID"));
        enrollment.setUserId(rs.getInt("UserID"));
        enrollment.setCourseId(rs.getInt("CourseID"));
        if (hasColumn(rs, "Status")) {
            enrollment.setStatus(rs.getString("Status"));
        }
        if (hasColumn(rs, "PaymentStatus")) {
            enrollment.setPaymentStatus(rs.getString("PaymentStatus"));
        }
        if (hasColumn(rs, "PaymentRef")) {
            enrollment.setPaymentRef(rs.getString("PaymentRef"));
        }
        Timestamp enrollmentTs = null;
        if (hasColumn(rs, "EnrollmentDate")) {
            enrollmentTs = rs.getTimestamp("EnrollmentDate");
        }
        if (enrollmentTs != null) {
            enrollment.setEnrollmentDate(enrollmentTs.toLocalDateTime());
        }
        Timestamp expiryOverrideTs = null;
        if (hasColumn(rs, "ExpiryDateOverride")) {
            expiryOverrideTs = rs.getTimestamp("ExpiryDateOverride");
        }
        if (expiryOverrideTs != null) {
            enrollment.setExpiryDateOverride(expiryOverrideTs.toLocalDateTime());
        }
        Timestamp updatedTs = null;
        if (hasColumn(rs, "UpdatedDate")) {
            updatedTs = rs.getTimestamp("UpdatedDate");
        }
        if (updatedTs != null) {
            enrollment.setUpdatedDate(updatedTs.toLocalDateTime());
        }
        if (hasColumn(rs, "CompletionStatus")) {
            enrollment.setCompletionStatus(rs.getString("CompletionStatus"));
        }
        if (hasColumn(rs, "Progress")) {
            int progress = rs.getInt("Progress");
            if (!rs.wasNull()) {
                enrollment.setProgress(progress);
            }
        }
        if (hasColumn(rs, "ReminderSent")) {
            enrollment.setReminderSent(rs.getBoolean("ReminderSent"));
        }
        return enrollment;
    }

    @Override
    public List<Enrollment> getEnrollmentsByCourse(Integer courseId) {
        List<Enrollment> enrollments = new ArrayList<>();
        String sql = "SELECT e.*, u.FullName AS StudentName, u.Email AS StudentEmail " +
                "FROM Enrollment e " +
                "JOIN User u ON e.UserID = u.UserID " +
                "WHERE e.CourseID = ? " +
                "ORDER BY e.EnrollmentDate DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, courseId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Enrollment enrollment = mapResultSet(rs);
                    enrollment.setStudentName(rs.getString("StudentName"));
                    enrollment.setStudentEmail(rs.getString("StudentEmail"));
                    enrollments.add(enrollment);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting enrollments by course courseId=" + courseId, e);
        }
        return enrollments;
    }

    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            ResultSetMetaData md = rs.getMetaData();
            int columns = md.getColumnCount();
            for (int i = 1; i <= columns; i++) {
                String label = md.getColumnLabel(i);
                String name = md.getColumnName(i);
                if (columnName.equalsIgnoreCase(label) || columnName.equalsIgnoreCase(name)) {
                    return true;
                }
            }
        } catch (SQLException ignored) {}
        return false;
    }

    @Override
    public Integer countStudentsByInstructor(Integer instructorId) {
        String sql = "SELECT COUNT(DISTINCT e.UserID) AS student_count " +
                     "FROM Enrollment e " +
                     "INNER JOIN Course c ON e.CourseID = c.CourseID " +
                     "WHERE c.InstructorID = ? AND e.Status != 'Cancelled'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("student_count");
                    LOGGER.fine("countStudentsByInstructor instructorId=" + instructorId + ", count=" + count);
                    return count;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting students by instructor instructorId=" + instructorId, e);
        }
        return 0;
    }

    @Override
    public Integer countEnrollmentsByInstructor(Integer instructorId) {
        String sql = "SELECT COUNT(*) AS enrollment_count " +
                     "FROM Enrollment e " +
                     "INNER JOIN Course c ON e.CourseID = c.CourseID " +
                     "WHERE c.InstructorID = ? AND e.Status != 'Cancelled'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("enrollment_count");
                    LOGGER.fine("countEnrollmentsByInstructor instructorId=" + instructorId + ", count=" + count);
                    return count;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting enrollments by instructor instructorId=" + instructorId, e);
        }
        return 0;
    }

    @Override
    public Integer countPendingEnrollmentsByInstructor(Integer instructorId) {
        String sql = "SELECT COUNT(*) AS pending_count " +
                     "FROM Enrollment e " +
                     "INNER JOIN Course c ON e.CourseID = c.CourseID " +
                     "WHERE c.InstructorID = ? AND e.Status = 'Pending'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("pending_count");
                    LOGGER.fine("countPendingEnrollmentsByInstructor instructorId=" + instructorId + ", count=" + count);
                    return count;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting pending enrollments by instructor instructorId=" + instructorId, e);
        }
        return 0;
    }

    @Override
    public Integer countActiveEnrollmentsByInstructor(Integer instructorId) {
        String sql = "SELECT COUNT(*) AS active_count " +
                     "FROM Enrollment e " +
                     "INNER JOIN Course c ON e.CourseID = c.CourseID " +
                     "WHERE c.InstructorID = ? AND e.Status = 'Active'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("active_count");
                    LOGGER.fine("countActiveEnrollmentsByInstructor instructorId=" + instructorId + ", count=" + count);
                    return count;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting active enrollments by instructor instructorId=" + instructorId, e);
        }
        return 0;
    }

    @Override
    public boolean updateReminderSent(Integer enrollmentId, boolean reminderSent) {
        String sql = "UPDATE Enrollment SET ReminderSent = ? WHERE EnrollmentID = ?";
        LOGGER.info("Updating enrollment reminderSent enrollmentId=" + enrollmentId + ", reminderSent=" + reminderSent);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reminderSent ? 1 : 0);
            ps.setInt(2, enrollmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating reminderSent for enrollmentId=" + enrollmentId, e);
        }
        return false;
    }

    @Override
    public boolean updateExpiryDateOverride(Integer enrollmentId, LocalDateTime expiryDateOverride) {
        ensureExpiryOverrideColumn();
        String sql = "UPDATE Enrollment SET ExpiryDateOverride = ? WHERE EnrollmentID = ?";
        LOGGER.info("Updating enrollment expiry override enrollmentId=" + enrollmentId + ", expiryDateOverride=" + expiryDateOverride);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (expiryDateOverride == null) {
                ps.setNull(1, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(1, Timestamp.valueOf(expiryDateOverride));
            }
            ps.setInt(2, enrollmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating expiry override for enrollmentId=" + enrollmentId, e);
        }
        return false;
    }

    private void ensureExpiryOverrideColumn() {
        try (Connection conn = DBConnection.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            try (ResultSet rs = metaData.getColumns(conn.getCatalog(), null, "Enrollment", "ExpiryDateOverride")) {
                if (rs.next()) {
                    return;
                }
            }

            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("ALTER TABLE Enrollment ADD COLUMN ExpiryDateOverride DATETIME NULL");
                LOGGER.info("Added ExpiryDateOverride column to Enrollment table.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Unable to ensure ExpiryDateOverride column exists", e);
        }
    }
}
