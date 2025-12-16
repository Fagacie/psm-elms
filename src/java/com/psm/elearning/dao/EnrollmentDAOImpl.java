package com.psm.elearning.dao;

import com.psm.elearning.model.Enrollment;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementation of EnrollmentDAO using JDBC.
 */
public class EnrollmentDAOImpl implements EnrollmentDAO {
    
    @Override
    public Enrollment createEnrollment(Enrollment enrollment) {
        // Align with current DB schema: Enrollment(UserID, CourseID, EnrollmentDate, Progress, CompletionDate, Status)
        // We insert minimal required fields: UserID, CourseID, Status (use 'Enrolled' as initial state since 'Pending' is not allowed)
        String sql = "INSERT INTO Enrollment (UserID, CourseID, Status, EnrollmentDate) VALUES (?, ?, ?, NOW())";
        
        System.out.println("EnrollmentDAO: Creating enrollment for user " + enrollment.getUserId() + " in course " + enrollment.getCourseId());
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, enrollment.getUserId());
            ps.setInt(2, enrollment.getCourseId());
            // Use provided status (default to Pending) instead of forcing Enrolled
            String initialStatus = enrollment.getStatus() != null ? enrollment.getStatus() : "Pending";
            ps.setString(3, initialStatus);
            
            int affected = ps.executeUpdate();
            
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        enrollment.setEnrollmentId(rs.getInt(1));
                        enrollment.setStatus(initialStatus);
                        // paymentStatus/completionStatus not tracked in current schema
                        enrollment.setEnrollmentDate(LocalDateTime.now());
                        System.out.println("EnrollmentDAO: Enrollment created successfully with ID " + enrollment.getEnrollmentId());
                        return enrollment;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("EnrollmentDAO: Error creating enrollment: " + e.getMessage());
            e.printStackTrace();
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
            System.err.println("EnrollmentDAO: Error checking existing enrollment: " + e.getMessage());
        }
        return false;
    }
    
    @Override
    public boolean updatePaymentStatus(Integer enrollmentId, String paymentStatus, String paymentRef) {
        // Current DB schema does not have PaymentStatus/PaymentRef columns on Enrollment.
        // This becomes a no-op to maintain flow compatibility.
        System.out.println("EnrollmentDAO: Skipping payment status update on Enrollment (not supported in current schema)");
        return true;
    }
    
    @Override
    public boolean updateStatus(Integer enrollmentId, String status) {
        String sql = "UPDATE Enrollment SET Status = ? WHERE EnrollmentID = ?";
        
        System.out.println("EnrollmentDAO: Updating status to " + status + " for enrollment " + enrollmentId);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, enrollmentId);
            
            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (SQLException e) {
            System.err.println("EnrollmentDAO: Error updating status: " + e.getMessage());
        }
        return false;
    }
    
    @Override
    public List<Enrollment> getEnrollmentsByStudent(Integer userId) {
        List<Enrollment> enrollments = new ArrayList<>();
        String sql = "SELECT e.*, c.Title AS CourseTitle, c.Description, c.CourseFee, u.FullName AS InstructorName " +
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
                    enrollment.setInstructorName(rs.getString("InstructorName"));
                    enrollments.add(enrollment);
                }
            }
        } catch (SQLException e) {
            System.err.println("EnrollmentDAO: Error getting enrollments by student: " + e.getMessage());
            e.printStackTrace();
        }
        return enrollments;
    }
    
    @Override
    public Enrollment getEnrollment(Integer enrollmentId) {
        String sql = "SELECT e.*, c.Title AS CourseTitle, c.Description, c.CourseFee, u.FullName AS InstructorName " +
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
                    enrollment.setInstructorName(rs.getString("InstructorName"));
                    return enrollment;
                }
            }
        } catch (SQLException e) {
            System.err.println("EnrollmentDAO: Error getting enrollment: " + e.getMessage());
        }
        return null;
    }
    
    @Override
    public List<Enrollment> getAllEnrollments() {
        List<Enrollment> enrollments = new ArrayList<>();
        String sql = "SELECT e.*, c.Title AS CourseTitle, c.CourseFee, u.FullName AS StudentName, u.Email AS StudentEmail " +
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
                enrollment.setStudentName(rs.getString("StudentName"));
                enrollment.setStudentEmail(rs.getString("StudentEmail"));
                enrollments.add(enrollment);
            }
        } catch (SQLException e) {
            System.err.println("EnrollmentDAO: Error getting all enrollments: " + e.getMessage());
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
        return enrollment;
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
}
