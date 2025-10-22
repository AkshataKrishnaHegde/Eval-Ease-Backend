# Stage 1: build
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom and mvnw first for caching dependencies
COPY pom.xml . 
COPY .mvn/ .mvn
COPY mvnw .
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline

# Copy source code
COPY src ./src

# Build JAR
RUN ./mvnw clean package -DskipTests

# Stage 2: run
FROM openjdk:21-jdk-slim
WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/target/evalease-backend-0.0.1-SNAPSHOT.jar app.jar

# Expose port
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]
