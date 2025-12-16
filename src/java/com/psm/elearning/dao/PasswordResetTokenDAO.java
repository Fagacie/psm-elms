package com.psm.elearning.dao;

import com.psm.elearning.model.PasswordResetToken;

/**
 * DAO interface for password reset token operations
 */
public interface PasswordResetTokenDAO {
    
    /**
     * Create a new password reset token
     */
    boolean create(PasswordResetToken token);
    
    /**
     * Find token by token string
     */
    PasswordResetToken findByToken(String token);
    
    /**
     * Mark token as used
     */
    boolean markAsUsed(String token);
    
    /**
     * Delete expired tokens (cleanup)
     */
    int deleteExpiredTokens();
    
    /**
     * Invalidate all tokens for a user
     */
    boolean invalidateUserTokens(int userId);
}
