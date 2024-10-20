# Start with Alpine Linux
FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    mariadb \
    mariadb-client

# Environment variables for MariaDB
ENV MYSQL_ROOT_PASSWORD=root_password
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=password
ENV MYSQL_DATABASE=user_database

# Initialize MariaDB and create user and database
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    /usr/bin/mysqld --user=mysql --bootstrap <<EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Configure MariaDB to allow connetions from IP
RUN sed -i 's/^skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i 's/^#bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf

# Expose ports
EXPOSE 3306

# Expose folders
VOLUME /var/lib/mysql

# Start MariaDB and Apache
CMD /usr/bin/mysqld_safe --datadir=/var/lib/mysql