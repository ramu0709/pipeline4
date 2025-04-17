# Use Tomcat base image with JDK 17
FROM tomcat:9.0-jdk17-temporal

# Copy the WAR file to Tomcat's webapps directory
COPY target/maven-web-application.war /usr/local/tomcat/webapps/maven-web-application.war

# Expose port 8080 (inside the container)
EXPOSE 8080
