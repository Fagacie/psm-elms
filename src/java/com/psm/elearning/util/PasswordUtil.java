package com.psm.elearning.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Password Utility for secure password hashing and verification
 * Uses SHA-256 with salt for password hashing
 * 
 * @author PSM E-Learning Team
 * @version 1.0
 */
public class PasswordUtil {
    
    private static final String ALGORITHM = "SHA-256";
    private static final int SALT_LENGTH = 16;
    
    /**
     * Generates a random salt for password hashing
     * 
     * @return Base64 encoded salt string
     */
    public static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }
    
    /**
     * Hashes a password with the given salt using SHA-256
     * 
     * @param password Plain text password
     * @param salt Salt to use for hashing
     * @return Hashed password as hexadecimal string
     */
    public static String hashPassword(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            
            // Add salt to password
            String saltedPassword = password + salt;
            
            // Hash the salted password
            byte[] hashedBytes = md.digest(saltedPassword.getBytes());
            
            // Convert to hexadecimal string
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            
            return sb.toString();
            
        } catch (NoSuchAlgorithmException e) {
            System.err.println("Hashing algorithm not found: " + e.getMessage());
            throw new RuntimeException("Password hashing failed", e);
        }
    }
    
    /**
     * Hashes a password (generates salt automatically)
     * Returns: salt:hashedPassword format
     * 
     * @param password Plain text password
     * @return Salt and hashed password in format "salt:hash"
     */
    public static String hashPassword(String password) {
        String salt = generateSalt();
        String hash = hashPassword(password, salt);
        return salt + ":" + hash;
    }
    
    /**
     * Verifies a password against a stored hash
     * 
     * @param password Plain text password to verify
     * @param storedHash Stored hash in format "salt:hash"
     * @return true if password matches, false otherwise
     */
    public static boolean verifyPassword(String password, String storedHash) {
        try {
            // Split stored hash into salt and hash
            String[] parts = storedHash.split(":");
            if (parts.length != 2) {
                return false;
            }
            
            String salt = parts[0];
            String hash = parts[1];
            
            // Hash the input password with the same salt
            String hashedInput = hashPassword(password, salt);
            
            // Compare hashes
            return hash.equals(hashedInput);
            
        } catch (Exception e) {
            System.err.println("Password verification failed: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Validates password strength
     * Password must be at least 8 characters with uppercase, lowercase, and digit
     * 
     * @param password Password to validate
     * @return true if password meets requirements, false otherwise
     */
    public static boolean isPasswordStrong(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUppercase = false;
        boolean hasLowercase = false;
        boolean hasDigit = false;
        
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUppercase = true;
            if (Character.isLowerCase(c)) hasLowercase = true;
            if (Character.isDigit(c)) hasDigit = true;
        }
        
        return hasUppercase && hasLowercase && hasDigit;
    }
    
    /**
     * Alias for isPasswordStrong - validates password strength
     * Password must be at least 8 characters with uppercase, lowercase, digit, and special character
     * 
     * @param password Password to validate
     * @return true if password meets requirements, false otherwise
     */
    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUppercase = false;
        boolean hasLowercase = false;
        boolean hasDigit = false;
        boolean hasSpecial = false;
        
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUppercase = true;
            else if (Character.isLowerCase(c)) hasLowercase = true;
            else if (Character.isDigit(c)) hasDigit = true;
            else if (!Character.isWhitespace(c)) hasSpecial = true;
        }
        
        return hasUppercase && hasLowercase && hasDigit && hasSpecial;
    }
    
    /**
     * Generates a random temporary password
     * 
     * @return Random password string (12 characters)
     */
    public static String generateTemporaryPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%";
        SecureRandom random = new SecureRandom();
        StringBuilder password = new StringBuilder();
        
        for (int i = 0; i < 12; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return password.toString();
    }
}
