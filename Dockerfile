FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
# Dockerfile builds an image that runs a Spring Boot application inside a Docker container using OpenJDK 8 on Alpine Linux, with the application accessible on port 8080. It also creates a new user and group for running the application inside the container.

# Specifies the base image to use, which is the OpenJDK 8 runtime environment on Alpine Linux.
# Creates a new user group called "pipeline" and a new user called "k8s-pipeline" that is a member of that group.
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
USER k8s-pipeline

# Specifies the command that will be executed when a container based on this image is started. In this case, it will run the command java -jar /home/k8s-pipeline/app.jar, which starts the Spring Boot application contained in the app.jar file.
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]
