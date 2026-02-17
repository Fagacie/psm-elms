package com.psm.elearning.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Database Connection Utility
 * Provides a singleton connection manager for MySQL database
 * Reads configuration from db.properties file
 * 
 * @author PSM E-Learning Team
 * @version 1.0
 */
public class DBConnection {
    
    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;
    private static String DB_DRIVER;
    
    // Static block to load database configuration
    static {
        loadDatabaseConfig();
    }
    
    /**
     * Loads database configuration from db.properties file
     */
    private static void loadDatabaseConfig() {
        Properties props = new Properties();
        try (InputStream input = DBConnection.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            
            if (input == null) {
                // Default configuration if properties file not found
                System.err.println("Unable to find db.properties, using defaults");
                DB_DRIVER = "com.mysql.cj.jdbc.Driver";
                DB_URL = "jdbc:mysql://localhost:3306/psm_elearning?useSSL=false&serverTimezone=UTC";
                DB_USER = "root";
                DB_PASSWORD = "";
            } else {
                props.load(input);
                DB_DRIVER = props.getProperty("db.driver");
                DB_URL = props.getProperty("db.url");
                DB_USER = props.getProperty("db.username");
                DB_PASSWORD = props.getProperty("db.password");
            }

            // Allow environment variable overrides (useful for Docker/dev containers)
            String envDriver = System.getenv("DB_DRIVER");
            String envUrl = System.getenv("DB_URL");
            String envUser = System.getenv("DB_USERNAME");
            String envPassword = System.getenv("DB_PASSWORD");

            if (envDriver != null && !envDriver.trim().isEmpty()) {
                DB_DRIVER = envDriver.trim();
            }
            if (envUrl != null && !envUrl.trim().isEmpty()) {
                DB_URL = envUrl.trim();
            }
            if (envUser != null && !envUser.trim().isEmpty()) {
                DB_USER = envUser.trim();
            }
            if (envPassword != null) {
                DB_PASSWORD = envPassword;
            }
            
            // Load MySQL JDBC Driver
            Class.forName(DB_DRIVER);
            System.out.println("Database driver loaded successfully");
            
        } catch (IOException | ClassNotFoundException e) {
            System.err.println("Error loading database configuration: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Gets a database connection
     * 
     * @return Connection object to psm_elearning database
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("Database connection established");
            return conn;
        } catch (SQLException e) {
            System.err.println("Failed to establish database connection: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Tests the database connection
     * 
     * @return true if connection successful, false otherwise
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("Connection test failed: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Closes the given connection safely
     * 
     * @param conn Connection to close
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                System.out.println("Database connection closed");
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
}
