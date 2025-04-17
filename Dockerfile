FROM openjdk:17-jdk-slim
COPY target/maven-web-application.war /app.war
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.war"]
