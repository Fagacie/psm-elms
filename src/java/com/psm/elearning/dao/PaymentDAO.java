package com.psm.elearning.dao;

import com.psm.elearning.model.Payment;

/**
 * DAO interface for Payment operations with Paystack integration.
 */
public interface PaymentDAO {
    
    /**
     * Create a new payment record with Paystack details.
     * @param payment Payment object with enrollmentId, amount, and Paystack fields
     * @return Created Payment with generated ID, or null if failed
     */
    Payment createPayment(Payment payment);
    
    /**
     * Update payment status and Paystack details after verification.
     * @param paymentId Payment ID
     * @param status New status (Pending, Paid, Failed, Abandoned)
     * @param method Payment method/channel from Paystack
     * @param paystackStatus Paystack transaction status
     * @return true if updated successfully, false otherwise
     */
    boolean updatePaymentStatus(Integer paymentId, String status, String method, String paystackStatus);
    
    
    // Admin helpers
    Payment getPaymentById(Integer paymentId);
    java.util.List<Payment> listPayments(String status, int page, int pageSize);
    /**
     * Get payment by enrollment ID.
     * @param enrollmentId Enrollment ID
     * @return Payment object or null if not found
     */
    Payment getPaymentByEnrollmentId(Integer enrollmentId);
    
    /**
     * Get payment by Paystack reference.
     * @param paystackReference Paystack transaction reference
     * @return Payment object or null if not found
     */
    Payment getPaymentByPaystackReference(String paystackReference);
}
