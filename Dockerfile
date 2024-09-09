# Step 1: Use the official Gradle image to build the application
FROM gradle:7.4.2-jdk17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy Gradle wrapper and configuration files
COPY gradle/ ./gradle
COPY build.gradle settings.gradle gradlew ./

# Download dependencies
RUN ./gradlew build --no-daemon || return 0

# Copy the source code
COPY src ./src

# Build the application
RUN ./gradlew bootJar --no-daemon

# Step 2: Use the official OpenJDK 17 image to run the application
FROM openjdk:17-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose port 30021
EXPOSE 30021

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]