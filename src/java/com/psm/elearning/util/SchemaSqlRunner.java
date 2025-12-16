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

    public static void runFromClasspath(String resourcePath) {
        try (InputStream in = Thread.currentThread().getContextClassLoader().getResourceAsStream(resourcePath)) {
            if (in == null) {
                System.err.println("SchemaSqlRunner: Resource not found: " + resourcePath);
                return;
            }
            String sql = readAll(in);
            List<String> statements = splitStatements(sql);
            applyStatements(statements);
        } catch (Exception e) {
            System.err.println("SchemaSqlRunner failed: " + e.getMessage());
        }
    }

    /**
     * Attempts to load and run SQL from servlet context paths (e.g., /WEB-INF/db/schema.sql).
     */
    public static void runFromServletContext(ServletContext ctx, String... candidatePaths) {
        for (String path : candidatePaths) {
            try (InputStream in = ctx.getResourceAsStream(path)) {
                if (in == null) continue;
                String sql = readAll(in);
                List<String> statements = splitStatements(sql);
                applyStatements(statements);
                System.out.println("SchemaSqlRunner applied schema from: " + path);
                return; // stop at first successful path
            } catch (Exception e) {
                System.err.println("SchemaSqlRunner path failed (" + path + "): " + e.getMessage());
            }
        }
        System.err.println("SchemaSqlRunner: No schema.sql found in servlet context paths.");
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
}
