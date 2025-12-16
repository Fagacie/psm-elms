package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * Model for password reset tokens with automatic expiration validation.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class PasswordResetToken {
    @NotNull(message = "Token ID cannot be null")
    private Integer tokenId;
    
    @NotNull(message = "User ID is required")
    private Integer userId;
    
    @NotBlank(message = "Token is required")
    @Size(max = 255, message = "Token must not exceed 255 characters")
    private String token;
    
    private LocalDateTime createdAt;
    
    @NotNull(message = "Token expiration time is required")
    private LocalDateTime expiresAt;
    
    private boolean used;

    // Constructor for creating new token
    public PasswordResetToken(Integer userId, String token, LocalDateTime expiresAt) {
        this.userId = userId;
        this.token = token;
        this.createdAt = LocalDateTime.now();
        this.expiresAt = expiresAt;
        this.used = false;
    }
    
    // Default constructor
    public PasswordResetToken() {}

    // Getters and Setters
    public Integer getTokenId() { return tokenId; }
    public void setTokenId(Integer tokenId) { this.tokenId = tokenId; }
    
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    
    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }

    // Helper methods
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }

    public boolean isValid() {
        return !used && !isExpired();
    }
}






