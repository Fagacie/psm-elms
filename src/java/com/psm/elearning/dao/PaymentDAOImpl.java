package com.psm.elearning.dao;

import com.psm.elearning.model.Payment;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Implementation of PaymentDAO using JDBC with Paystack integration.
 */
public class PaymentDAOImpl implements PaymentDAO {

    private static final Logger LOGGER = Logger.getLogger(PaymentDAOImpl.class.getName());
    
    @Override
    public Payment createPayment(Payment payment) {
        String sql = "INSERT INTO Payment (EnrollmentID, Amount, PaymentMethod, PaymentStatus, Reference, PaymentRef, PaystackReference, AccessCode, AuthorizationUrl, PaystackStatus) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        LOGGER.info("Creating payment for enrollmentId=" + payment.getEnrollmentId());
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, payment.getEnrollmentId());
            ps.setDouble(2, payment.getAmount());
            ps.setString(3, payment.getMethod());
            ps.setString(4, payment.getStatus());
            ps.setString(5, payment.getPaystackReference());
            ps.setString(6, payment.getPaymentRef());
            ps.setString(7, payment.getPaystackReference());
            ps.setString(8, payment.getAccessCode());
            ps.setString(9, payment.getAuthorizationUrl());
            ps.setString(10, payment.getPaystackStatus() == null ? "pending" : payment.getPaystackStatus());
            
            int affected = ps.executeUpdate();
            
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        payment.setPaymentId(rs.getInt(1));
                        payment.setPaymentDate(LocalDateTime.now());
                        LOGGER.info("Payment created successfully paymentId=" + payment.getPaymentId());
                        return payment;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating payment", e);
        }
        return null;
    }
    
    @Override
    public boolean updatePaymentStatus(Integer paymentId, String status, String method, String paystackStatus) {
        String sql = "UPDATE Payment SET PaymentStatus = ?, PaymentMethod = ?, PaystackStatus = ?, PaymentDate = CASE WHEN ? = 'Paid' THEN NOW() ELSE PaymentDate END WHERE PaymentID = ?";
        
        LOGGER.info("Updating payment status paymentId=" + paymentId + ", status=" + status + ", paystackStatus=" + paystackStatus);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setString(2, method);
            ps.setString(3, paystackStatus);
            ps.setString(4, status);
            ps.setInt(5, paymentId);
            
            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating payment status for paymentId=" + paymentId, e);
        }
        return false;
    }
    
    @Override
    public Payment getPaymentByEnrollmentId(Integer enrollmentId) {
        String sql = "SELECT * FROM Payment WHERE EnrollmentID = ? ORDER BY PaymentID DESC LIMIT 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, enrollmentId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractPaymentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching payment by enrollmentId=" + enrollmentId, e);
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
            LOGGER.log(Level.SEVERE, "Error fetching payment by paymentId=" + paymentId, e);
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
            LOGGER.log(Level.SEVERE, "Error listing payments", e);
        }
        return list;
    }

    @Override
    public Payment getPaymentByPaystackReference(String paystackReference) {
        String sql = "SELECT * FROM Payment WHERE PaystackReference = ? OR Reference = ? OR PaymentRef = ? ORDER BY PaymentID DESC LIMIT 1";
        
        LOGGER.info("Fetching payment by external reference");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, paystackReference);
            ps.setString(2, paystackReference);
            ps.setString(3, paystackReference);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractPaymentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching payment by external reference", e);
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
        payment.setStatus(normalizePaymentStatus(rs.getString("PaymentStatus")));

        String paystackRef = rs.getString("PaystackReference");
        String reference = rs.getString("Reference");
        String paymentRef = rs.getString("PaymentRef");

        if (paystackRef == null || paystackRef.trim().isEmpty()) {
            paystackRef = (reference != null && !reference.trim().isEmpty()) ? reference : paymentRef;
        }
        if (paymentRef == null || paymentRef.trim().isEmpty()) {
            paymentRef = (reference != null && !reference.trim().isEmpty()) ? reference : paystackRef;
        }

        payment.setPaystackReference(paystackRef);
        payment.setPaymentRef(paymentRef);
        payment.setAccessCode(rs.getString("AccessCode"));
        payment.setAuthorizationUrl(rs.getString("AuthorizationUrl"));
        payment.setPaystackStatus(rs.getString("PaystackStatus"));
        
        Timestamp paymentTs = rs.getTimestamp("PaymentDate");
        if (paymentTs != null) {
            payment.setPaymentDate(paymentTs.toLocalDateTime());
        }
        
        return payment;
    }

    private String normalizePaymentStatus(String status) {
        if (status == null) {
            return "Pending";
        }
        String value = status.trim();
        if (value.equalsIgnoreCase("paid") || value.equalsIgnoreCase("completed") || value.equalsIgnoreCase("success")) {
            return "Paid";
        }
        if (value.equalsIgnoreCase("failed")) {
            return "Failed";
        }
        if (value.equalsIgnoreCase("abandoned")) {
            return "Abandoned";
        }
        if (value.equalsIgnoreCase("pending") || value.equalsIgnoreCase("processing")) {
            return "Pending";
        }
        return value;
    }
}
