# ==============================================================================
# PSM E-Learning Platform - Production Dockerfile (Multi-stage Build)
# Stage 1: Build & Compile (using eclipse-temurin:17-jdk)
# Stage 2: Hardened Runtime (using tomcat:9.0-jdk17-temurin)
# ==============================================================================

# --- Stage 1: Builder ---
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /app

# Copy dependency libraries and sources
COPY lib ./lib
COPY src ./src
COPY web ./web
COPY db ./db

# Prepare build directory structure
RUN mkdir -p build/web/WEB-INF/classes build/web/WEB-INF/lib build/web/WEB-INF/classes/db \
    && cp -R web/. build/web/ \
    && cp -R lib/. build/web/WEB-INF/lib/ \
    && cp db/schema.sql build/web/WEB-INF/classes/db/schema.sql \
    && cp db/migration_db_cleanup.sql build/web/WEB-INF/classes/db/migration_db_cleanup.sql 2>/dev/null || true \
    && cp db/migration_performance_indexes.sql build/web/WEB-INF/classes/db/migration_performance_indexes.sql 2>/dev/null || true \
    && cp src/conf/*.properties build/web/WEB-INF/classes/ 2>/dev/null || true \
    && cp src/conf/logback.xml build/web/WEB-INF/classes/ 2>/dev/null || true \
    && find src/java -name '*.java' > sources.txt \
    && javac --release 17 -encoding UTF-8 -cp "lib/*:build/web/WEB-INF/classes" -d build/web/WEB-INF/classes @sources.txt \
    && jar --create --file /app/PSME.war -C build/web .

# --- Stage 2: Hardened Runner ---
FROM tomcat:9.0-jdk17-temurin

# Set environment variables for security and configuration
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# 1. Harden Tomcat: Remove default management apps (ROOT, manager, docs, etc.)
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. Deploy Application to Root Context
COPY --from=builder /app/PSME.war /usr/local/tomcat/webapps/ROOT.war

# 3. Create non-root system user for runtime security
RUN groupadd -r tomcat && useradd -r -g tomcat -d /usr/local/tomcat -s /sbin/nologin tomcat

# 4. Set appropriate directories ownership to Tomcat user
RUN chown -R tomcat:tomcat /usr/local/tomcat/webapps /usr/local/tomcat/work /usr/local/tomcat/temp /usr/local/tomcat/logs /usr/local/tomcat/conf

# 5. Expose default port
EXPOSE 8080

# 6. Switch execution context to non-privileged user
USER tomcat

# Start Tomcat server
CMD ["catalina.sh", "run"]
