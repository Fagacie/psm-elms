FROM eclipse-temurin:17-jdk AS builder

WORKDIR /app

COPY lib ./lib
COPY src ./src
COPY web ./web
COPY db ./db

RUN mkdir -p build/web/WEB-INF/classes build/web/WEB-INF/lib build/web/WEB-INF/classes/db \
    && cp -R web/. build/web/ \
    && cp -R lib/. build/web/WEB-INF/lib/ \
    && cp db/schema.sql build/web/WEB-INF/classes/db/schema.sql \
    && cp src/conf/*.properties build/web/WEB-INF/classes/ 2>/dev/null || true \
    && cp src/conf/logback.xml build/web/WEB-INF/classes/ 2>/dev/null || true \
    && find src/java -name '*.java' > sources.txt \
    && javac --release 17 -encoding UTF-8 -cp "lib/*:build/web/WEB-INF/classes" -d build/web/WEB-INF/classes @sources.txt \
    && jar --create --file /app/PSME.war -C build/web .

FROM tomcat:9.0-jdk17-temurin

COPY --from=builder /app/PSME.war /usr/local/tomcat/webapps/PSME.war
