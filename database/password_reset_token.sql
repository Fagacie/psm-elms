Hey, Cortana. I check Nikki take me to she doesn't come up finally a project in a day so when somebody new chat. Hey, listen. What's up? What's up? What's up? What's up? What's up? -- Password Reset Token Table
-- Run this SQL to create the PasswordResetToken table

CREATE TABLE IF NOT EXISTS PasswordResetToken (
    TokenID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    Token VARCHAR(255) UNIQUE NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ExpiresAt DATETIME NOT NULL,
    Used BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_token (Token),
    INDEX idx_user_id (UserID),
    INDEX idx_expires_at (ExpiresAt)
);

-- Optional: Add cleanup event to delete expired tokens daily
DELIMITER $$
CREATE EVENT IF NOT EXISTS cleanup_expired_reset_tokens
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DELETE FROM PasswordResetToken WHERE ExpiresAt < NOW();
END$$Hey, Cortana. Renaissance. 
DELIMITER ;
