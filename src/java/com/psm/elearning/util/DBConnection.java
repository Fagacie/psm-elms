package com.psm.elearning.util;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.Properties;

/**
 * Database Connection Utility
 * Provides a HikariCP connection pool for MySQL database access.
 * Reads configuration from db.properties file.
 *
 * @author PSM E-Learning Team
 * @version 2.0
 */
public class DBConnection {

    private static HikariDataSource dataSource;

    static {
        loadDatabaseConfig();
    }

    private static void loadDatabaseConfig() {
        Properties props = new Properties();
        try (InputStream input = DBConnection.class.getClassLoader()
                .getResourceAsStream("db.properties")) {

            if (input == null) {
                System.err.println("Unable to find db.properties, using defaults");
                props.setProperty("db.driver", "com.mysql.cj.jdbc.Driver");
                props.setProperty("db.url",
                        "jdbc:mysql://localhost:3306/psm_elearning?useSSL=false&serverTimezone=UTC");
                props.setProperty("db.username", "root");
                props.setProperty("db.password", "");
            } else {
                props.load(input);
            }

            applyEnvironmentOverrides(props);
            initializePool(props);

        } catch (IOException e) {
            System.err.println("Error loading database configuration: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void applyEnvironmentOverrides(Properties props) {
        String envDriver = System.getenv("DB_DRIVER");
        String envUrl = System.getenv("DB_URL");
        String envUser = System.getenv("DB_USERNAME");
        String envPassword = System.getenv("DB_PASSWORD");

        if (envDriver != null && !envDriver.trim().isEmpty()) {
            props.setProperty("db.driver", envDriver.trim());
        }
        if (envUrl != null && !envUrl.trim().isEmpty()) {
            props.setProperty("db.url", envUrl.trim());
        }
        if (envUser != null && !envUser.trim().isEmpty()) {
            props.setProperty("db.username", envUser.trim());
        }
        if (envPassword != null) {
            props.setProperty("db.password", envPassword);
        }
    }

    private static void initializePool(Properties props) {
        HikariConfig config = new HikariConfig();
        config.setDriverClassName(props.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
        config.setJdbcUrl(props.getProperty("db.url"));
        config.setUsername(props.getProperty("db.username"));
        config.setPassword(props.getProperty("db.password", ""));

        config.setMaximumPoolSize(getIntProperty(props, "db.pool.maxActive", 20));
        config.setMinimumIdle(getIntProperty(props, "db.pool.minIdle", 5));
        config.setConnectionTimeout(getLongProperty(props, "db.pool.connectionTimeout", 30_000L));
        config.setIdleTimeout(getLongProperty(props, "db.pool.idleTimeout", 600_000L));
        config.setMaxLifetime(getLongProperty(props, "db.pool.maxLifetime", 1_800_000L));
        config.setPoolName("PSME-HikariPool");

        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        config.addDataSourceProperty("useServerPrepStmts", "true");

        dataSource = new HikariDataSource(config);
        System.out.println("HikariCP connection pool initialized (max="
                + config.getMaximumPoolSize() + ", minIdle=" + config.getMinimumIdle() + ")");
    }

    private static int getIntProperty(Properties props, String key, int defaultValue) {
        String value = props.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            System.err.println("Invalid integer for " + key + ", using default " + defaultValue);
            return defaultValue;
        }
    }

    private static long getLongProperty(Properties props, String key, long defaultValue) {
        String value = props.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            System.err.println("Invalid long for " + key + ", using default " + defaultValue);
            return defaultValue;
        }
    }

    /**
     * Gets a connection from the pool.
     * Call close() (or use try-with-resources) to return it to the pool.
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("Database connection pool is not initialized");
        }
        return dataSource.getConnection();
    }

    /**
     * Tests the database connection.
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
     * Returns a connection to the pool.
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }

    /**
     * Cleans up JDBC resources during webapp shutdown.
     */
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("HikariCP connection pool shut down");
        }
        shutdownMysqlCleanupThread();
        deregisterJdbcDrivers();
    }

    private static void shutdownMysqlCleanupThread() {
        try {
            AbandonedConnectionCleanupThread.checkedShutdown();
            System.out.println("MySQL abandoned connection cleanup thread stopped");
        } catch (Throwable t) {
            System.err.println("Unable to stop MySQL cleanup thread cleanly: " + t.getMessage());
        }
    }

    private static void deregisterJdbcDrivers() {
        ClassLoader appClassLoader = DBConnection.class.getClassLoader();
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            if (driver.getClass().getClassLoader() != appClassLoader) {
                continue;
            }
            try {
                DriverManager.deregisterDriver(driver);
                System.out.println("Deregistered JDBC driver: " + driver.getClass().getName());
            } catch (SQLException e) {
                System.err.println("Failed to deregister JDBC driver " + driver.getClass().getName()
                        + ": " + e.getMessage());
            }
        }
    }
}
