package com.psm.elearning.model;

/**
 * Canonical payment status constants for the PSM E-Learning platform.
 *
 * <p>These are the ONLY valid values stored in the Payment.PaymentStatus column
 * and the Enrollment.PaymentStatus column. All business logic, DAO queries,
 * and report SQL must use these constants — never raw string literals.
 *
 * <h3>Status lifecycle:</h3>
 * <pre>
 *   PENDING  →  PAID      (payment confirmed by Paystack)
 *   PENDING  →  FAILED    (payment declined / verification failed)
 *   PENDING  →  ABANDONED (user closed the payment popup)
 * </pre>
 *
 * <h3>Paystack raw status mapping:</h3>
 * <ul>
 *   <li>Paystack "success"   → our {@link #PAID}</li>
 *   <li>Paystack "failed"    → our {@link #FAILED}</li>
 *   <li>Paystack "abandoned" → our {@link #ABANDONED}</li>
 * </ul>
 */
public final class PaymentStatus {

    /** Payment is awaiting user action or provider confirmation. */
    public static final String PENDING   = "Pending";

    /** Payment was successfully confirmed by Paystack. Grants course access. */
    public static final String PAID      = "Paid";

    /** Payment was declined or verification failed. */
    public static final String FAILED    = "Failed";

    /** User closed the Paystack popup without completing payment. */
    public static final String ABANDONED = "Abandoned";

    /**
     * Returns {@code true} if the given status represents a successful, access-granting payment.
     *
     * <p>This is the single authoritative check — use this instead of scattered
     * {@code "Paid".equals(status)} / {@code "paid".equalsIgnoreCase(status)} comparisons.
     *
     * @param status the raw PaymentStatus string from DB or model
     * @return true if the payment is complete and course access should be granted
     */
    public static boolean isComplete(String status) {
        return PAID.equalsIgnoreCase(status != null ? status.trim() : null);
    }

    /**
     * Returns {@code true} if the status means "the user hasn't paid yet but might still do so".
     * Covers null, empty, or {@link #PENDING} / {@link #ABANDONED} states.
     */
    public static boolean isPending(String status) {
        if (status == null || status.trim().isEmpty()) {
            return true;
        }
        String s = status.trim();
        return PENDING.equalsIgnoreCase(s) || ABANDONED.equalsIgnoreCase(s);
    }

    private PaymentStatus() {
        // utility class — no instances
    }
}
