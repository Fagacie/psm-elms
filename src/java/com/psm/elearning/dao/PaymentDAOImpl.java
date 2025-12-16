package com.psm.elearning.dao;

import com.psm.elearning.model.Payment;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;

/**
 * Implementation of PaymentDAO using JDBC with Paystack integration.
 */
public class PaymentDAOImpl implements PaymentDAO {
    
    @Override
    public Payment createPayment(Payment payment) {
        // Payment table schema: PaymentID, EnrollmentID, Amount, PaymentDate, PaymentStatus, PaymentMethod, Reference, VerifiedBy
            String sql = "INSERT INTO Payment (EnrollmentID, Amount, PaymentMethod, PaymentStatus, Reference) " +
                    "VALUES (?, ?, ?, ?, ?)";
        
        System.out.println("PaymentDAO: Creating payment for enrollment " + payment.getEnrollmentId());
        System.out.println("PaymentDAO: Paystack Reference: " + payment.getPaystackReference());
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, payment.getEnrollmentId());
            ps.setDouble(2, payment.getAmount());
                ps.setString(3, payment.getMethod()); // PaymentMethod
                ps.setString(4, payment.getStatus()); // PaymentStatus
                ps.setString(5, payment.getPaystackReference()); // Reference
            
            int affected = ps.executeUpdate();
            
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        payment.setPaymentId(rs.getInt(1));
                        payment.setPaymentDate(LocalDateTime.now());
                        System.out.println("PaymentDAO: Payment created successfully with ID " + payment.getPaymentId());
                        return payment;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("PaymentDAO: Error creating payment: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    @Override
    public boolean updatePaymentStatus(Integer paymentId, String status, String method, String paystackStatus) {
        // Update PaymentStatus and PaymentMethod in Payment table
            String sql = "UPDATE Payment SET PaymentStatus = ?, PaymentMethod = ? WHERE PaymentID = ?";
        
        System.out.println("PaymentDAO: Updating payment " + paymentId);
        System.out.println("PaymentDAO: Status: " + status + ", Method: " + method + ", Paystack Status: " + paystackStatus);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setString(2, method);
            ps.setInt(3, paymentId);
            
            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (SQLException e) {
            System.err.println("PaymentDAO: Error updating payment status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public Payment getPaymentByEnrollmentId(Integer enrollmentId) {
        String sql = "SELECT * FROM Payment WHERE EnrollmentID = ? ORDER BY PaymentDate DESC LIMIT 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, enrollmentId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractPaymentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("PaymentDAO: Error fetching payment: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    @Override
    public Payment getPaymentById(Integer paymentId) {
        String sql = "SELECT * FROM Payment WHERE PaymentID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractPaymentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("PaymentDAO: Error fetching payment by id: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public java.util.List<Payment> listPayments(String status, int page, int pageSize) {
        java.util.List<Payment> list = new java.util.ArrayList<>();
        String base = "SELECT p.*, c.Title AS CourseTitle, u.Email AS StudentEmail FROM Payment p " +
                "JOIN Enrollment e ON e.EnrollmentID = p.EnrollmentID " +
                "JOIN User u ON u.UserID = e.UserID " +
                "JOIN Course c ON c.CourseID = e.CourseID";
        String where = (status != null && !status.isEmpty()) ? " WHERE p.PaymentStatus = ?" : "";
        String order = " ORDER BY p.PaymentDate DESC";
        String limit = " LIMIT ? OFFSET ?";
        String sql = base + where + order + limit;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            if (!where.isEmpty()) {
                ps.setString(i++, status);
            }
            ps.setInt(i++, pageSize);
            ps.setInt(i, Math.max(0, (page - 1) * pageSize));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payment p = extractPaymentFromResultSet(rs);
                    try {
                        p.setCourseName(rs.getString("CourseTitle"));
                        p.setStudentName(rs.getString("StudentEmail"));
                    } catch (SQLException ignored) {}
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            System.err.println("PaymentDAO: Error listing payments: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Payment getPaymentByPaystackReference(String paystackReference) {
        // Paystack reference is stored in Reference column
        String sql = "SELECT * FROM Payment WHERE Reference = ?";
        
        System.out.println("PaymentDAO: Fetching payment by Paystack reference: " + paystackReference);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, paystackReference);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractPaymentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("PaymentDAO: Error fetching payment by reference: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Helper method to extract Payment object from ResultSet
     */
    private Payment extractPaymentFromResultSet(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentId(rs.getInt("PaymentID"));
        payment.setEnrollmentId(rs.getInt("EnrollmentID"));
        payment.setAmount(rs.getDouble("Amount"));
        // Map DB columns to model fields
        payment.setMethod(rs.getString("PaymentMethod"));
        payment.setStatus(rs.getString("PaymentStatus"));
        // Reference column stores the Paystack reference
        String ref = rs.getString("Reference");
        payment.setPaymentRef(ref);
        payment.setPaystackReference(ref);
        
        Timestamp paymentTs = rs.getTimestamp("PaymentDate");
        if (paymentTs != null) {
            payment.setPaymentDate(paymentTs.toLocalDateTime());
        }
        
        return payment;
    }
}
