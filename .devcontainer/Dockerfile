# Use the base MySQL image
FROM mysql:8.4

# Copy custom configuration files into the image
COPY ./conf.d /etc/mysql/conf.d

# Set environment variables
ENV MYSQL_ROOT_PASSWORD=yourpassword
ENV MYSQL_USER=petclinic
ENV MYSQL_PASSWORD=petclinic
ENV MYSQL_DATABASE=petclinic
