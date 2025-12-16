package com.psm.elearning.init;

import com.psm.elearning.util.SchemaSqlRunner;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * App initializer to apply schema at startup.
 */
public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Try to run schema from classpath (if packaged under WEB-INF/classes/db/schema.sql)
        SchemaSqlRunner.runFromClasspath("db/schema.sql");
        // Also try typical webapp locations
        SchemaSqlRunner.runFromServletContext(sce.getServletContext(),
                "/WEB-INF/classes/db/schema.sql",
                "/WEB-INF/db/schema.sql");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // No-op
    }
}
