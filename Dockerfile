FROM openjdk:22-jdk-bullseye

# Create the application directory
RUN mkdir -p /home/petclinic/

# Copy the JAR file into the container
COPY ./target/spring-petclinic-3.1.0-SNAPSHOT.jar /home/petclinic/

# Set the working directory
WORKDIR /home/petclinic/

# Expose the port the application will run on
EXPOSE 80

# Run the JAR file
ENTRYPOINT [ "java", "-jar", "/home/petclinic/spring-petclinic-3.1.0-SNAPSHOT.jar" ]
