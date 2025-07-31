FROM debian:bullseye

# Install MariaDB server and client in a single layer and clean up
RUN apt update && apt upgrade -y && \
    apt-get install mariadb-server -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld
COPY init_maria_db.sh /init_maria_db.sh
COPY init_database.sql /init_database.sql

# set permisiosn
RUN chmod +x /init_maria_db.sh

# RUN echo -e "\nslow_query_log = 1\nslow_query_log_file = /var/log/mysql/slow.log\nlong_query_time = 1" >> /etc/mysql/mariadb.conf.d/50-server.cnf
# RUN mkdir -p /var/log/mysql && chown mysql:mysql /var/log/mysql

# filepath: /home/vboxuser/Desktop/coreProgram/ft_inception/srcs/requirements/mariadb/Dockerfile
RUN sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf || \
    echo 'bind-address = 0.0.0.0' >> /etc/mysql/mariadb.conf.d/50-server.cnf


ENTRYPOINT [ "/init_maria_db.sh" ]