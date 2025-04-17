# Use OpenJDK 17 image
FROM openjdk:17-jdk-slim

# Copy the WAR file into the image
COPY target/maven-web-application.war /app.war

# Expose port 8080 for the application
EXPOSE 8080

# Set the entrypoint to run the WAR file with java
ENTRYPOINT ["java", "-jar", "/app.war"]
