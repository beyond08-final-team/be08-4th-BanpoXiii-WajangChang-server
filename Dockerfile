# Step 1: Use the official OpenJDK image to build the application
FROM openjdk:17-alpine AS build

# Install dependencies
RUN apk add --no-cache curl unzip

# Install Gradle
RUN curl -sSL https://services.gradle.org/distributions/gradle-7.6-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt && \
    ln -s /opt/gradle-7.6/bin/gradle /usr/bin/gradle && \
    rm gradle.zip

# Set the working directory inside the container
WORKDIR /app

# Copy Gradle configuration files
COPY build.gradle settings.gradle ./

# Copy the source code
COPY src ./src

# Download dependencies and build the application
RUN gradle build --no-daemon
RUN gradle bootJar --no-daemon

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