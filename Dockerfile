FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the built WAR file from target directory into the container
COPY target/maven-web-application.war /app/app.war

# Expose the container's internal port (where the app will run)
EXPOSE 8080

# Set the entry point to run the WAR file
ENTRYPOINT ["java", "-jar", "/app/app.war"]
