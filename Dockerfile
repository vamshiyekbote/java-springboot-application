# Stage 1: Build the application
FROM maven:3.8.1-openjdk-11 AS build
COPY . /app
WORKDIR /app
RUN mvn package -DskipTests

# Stage 2: Package the application in a separate container
FROM adoptopenjdk/openjdk11:alpine-jre
COPY --from=build /app/target/*.jar /myapp.jar
ENV DB_USERNAME=""
ENV DB_PASSWORD=""
ENV DB_IP=""
ENTRYPOINT ["java","-jar","/myapp.jar"]

