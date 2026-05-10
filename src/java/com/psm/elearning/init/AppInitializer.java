package com.psm.elearning.init;

import com.psm.elearning.util.MaterialProgressSchemaUtil;
import com.psm.elearning.util.SchemaSqlRunner;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * App initializer to apply schema at startup.
 */
public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        boolean schemaApplied = SchemaSqlRunner.runFromClasspath("db/schema.sql");
        if (!schemaApplied) {
            schemaApplied = SchemaSqlRunner.runFromServletContext(sce.getServletContext(),
                    "/WEB-INF/classes/db/schema.sql",
                    "/WEB-INF/db/schema.sql");
        }
        MaterialProgressSchemaUtil.ensureCompatibility();
        // Run DB cleanup migration (idempotent — uses IF EXISTS / INSERT IGNORE)
        boolean cleanupApplied = SchemaSqlRunner.runFromClasspath("db/migration_db_cleanup.sql");
        if (!cleanupApplied) {
            SchemaSqlRunner.runFromServletContext(sce.getServletContext(),
                    "/WEB-INF/classes/db/migration_db_cleanup.sql",
                    "/WEB-INF/db/migration_db_cleanup.sql");
        }
        if (!schemaApplied) {
            System.out.println("AppInitializer: schema runner skipped because no packaged schema.sql was found.");
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        com.psm.elearning.util.DBConnection.shutdown();
    }
}
