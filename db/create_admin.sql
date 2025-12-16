-- Create Admin User
-- Password will be: admin123 (hash generated with salt)
-- Remember to change password after first login!

USE psm_elearning;

-- Insert admin user
INSERT INTO User (FullName, Email, Phone, PasswordHash, Role, Status) 
VALUES (
    'System Administrator',
    'admin@psm.edu',
    '1234567890',
    'salt_placeholder:hash_placeholder',  -- Will be replaced below
    'Admin',
    'Active'
);

SET @adminUserId = LAST_INSERT_ID();

-- Insert admin details
INSERT INTO Admin (UserID, Position, PermissionLevel, AssignedDepartment)
VALUES (
    @adminUserId,
    'System Administrator',
    'SuperAdmin',
    'IT Department'
);

-- Display created admin
SELECT 
    u.UserID,
    u.FullName,
    u.Email,
    u.Role,
    a.Position,
    a.PermissionLevel
FROM User u
JOIN Admin a ON u.UserID = a.UserID
WHERE u.UserID = @adminUserId;
