# ==============================================================================
# PSM E-Learning Platform - Production Dockerfile
# Base: Apache Tomcat 9.0 on JRE 8 (Matches Java 1.8 Compilation Target)
# ==============================================================================
FROM tomcat:9.0-jre8-slim

# Set environment variables for security and configuration
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# 1. Harden Tomcat: Remove default management apps (ROOT, manager, docs, etc.)
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. Deploy Application to Root Context
# By deploying as ROOT.war, the app runs at "/" instead of "/PSME/".
# The codebase is fully compatible with dynamic context paths.
COPY dist/PSME.war /usr/local/tomcat/webapps/ROOT.war

# 3. Create non-root system user for runtime security
RUN groupadd -r tomcat && useradd -r -g tomcat -d /usr/local/tomcat -s /sbin/nologin tomcat

# 4. Set appropriate directories ownership to Tomcat user
RUN chown -R tomcat:tomcat /usr/local/tomcat/webapps /usr/local/tomcat/work /usr/local/tomcat/temp /usr/local/tomcat/logs

# 5. Expose default port
EXPOSE 8080

# 6. Switch execution context to non-privileged user
USER tomcat

# Start Tomcat server
CMD ["catalina.sh", "run"]
