package com.psm.elearning.util;

public class GenerateAdminPassword {
    public static void main(String[] args) {
        String password = args.length > 0 ? args[0] : "admin123";
        String hashed = PasswordUtil.hashPassword(password);
        System.out.println("Password: " + password);
        System.out.println("Hashed: " + hashed);
        System.out.println("\nSQL to create admin:");
        System.out.println("INSERT INTO User (FullName, Email, Phone, PasswordHash, Role, Status)");
        System.out.println("VALUES ('System Administrator', 'admin@psm.edu', '1234567890', '" + hashed + "', 'Admin', 'Active');");
        System.out.println("\nSET @adminUserId = LAST_INSERT_ID();");
        System.out.println("\nINSERT INTO Admin (UserID, Position, PermissionLevel, AssignedDepartment)");
        System.out.println("VALUES (@adminUserId, 'System Administrator', 'SuperAdmin', 'IT Department');");
    }
}
