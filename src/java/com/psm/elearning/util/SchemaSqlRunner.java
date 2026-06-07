package com.psm.elearning.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletContext;

/**
 * Executes a SQL schema file from classpath (e.g., db/schema.sql) at startup.
 * Skips CREATE DATABASE / USE statements and ignores errors for idempotency.
 */
public class SchemaSqlRunner {

    public static boolean runFromClasspath(String resourcePath) {
        if ("db/schema.sql".equals(resourcePath) && isSchemaAlreadyApplied()) {
            System.out.println("SchemaSqlRunner skipped db/schema.sql because core tables already exist");
            return true;
        }
        try (InputStream in = Thread.currentThread().getContextClassLoader().getResourceAsStream(resourcePath)) {
            if (in == null) {
                return false;
            }
            String sql = readAll(in);
            List<String> statements = splitStatements(sql);
            applyStatements(statements);
            System.out.println("SchemaSqlRunner applied schema from classpath: " + resourcePath);
            return true;
        } catch (Exception e) {
            System.err.println("SchemaSqlRunner failed: " + e.getMessage());
            return false;
        }
    }

    /**
     * Attempts to load and run SQL from servlet context paths (e.g., /WEB-INF/db/schema.sql).
     */
    public static boolean runFromServletContext(ServletContext ctx, String... candidatePaths) {
        for (String path : candidatePaths) {
            try (InputStream in = ctx.getResourceAsStream(path)) {
                if (in == null) continue;
                String sql = readAll(in);
                List<String> statements = splitStatements(sql);
                applyStatements(statements);
                System.out.println("SchemaSqlRunner applied schema from: " + path);
                return true; // stop at first successful path
            } catch (Exception e) {
                System.err.println("SchemaSqlRunner path failed (" + path + "): " + e.getMessage());
            }
        }
        return false;
    }

    private static String readAll(InputStream in) throws Exception {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                // strip single-line comments
                if (line.trim().startsWith("--")) continue;
                sb.append(line).append('\n');
            }
        }
        return sb.toString();
    }

    private static List<String> splitStatements(String sql) {
        List<String> list = new ArrayList<>();
        String[] parts = sql.split(";\\s*\n");
        for (String part : parts) {
            String s = part.trim();
            if (s.isEmpty()) continue;
            // skip CREATE DATABASE / USE statements (DB must already exist per DBConnection)
            String upper = s.toUpperCase();
            if (upper.startsWith("CREATE DATABASE") || upper.startsWith("USE ")) continue;
            list.add(s + ";");
        }
        return list;
    }

    private static void applyStatements(List<String> statements) {
        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement()) {
            for (String stmt : statements) {
                try {
                    st.execute(stmt);
                } catch (SQLException e) {
                    // Ignore errors to keep idempotent (e.g., index already exists)
                    System.err.println("SchemaSqlRunner ignoring error: " + e.getMessage());
                }
            }
        } catch (SQLException e) {
            System.err.println("SchemaSqlRunner connection error: " + e.getMessage());
        }
    }

    private static boolean isSchemaAlreadyApplied() {
        try (Connection conn = DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'User' LIMIT 1");
             java.sql.ResultSet rs = ps.executeQuery()) {
            return rs.next();
        } catch (SQLException e) {
            return false;
        }
    }
}
