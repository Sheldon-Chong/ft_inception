FROM debian:bullseye

ENV MARIADB_CONFIG_FILE=/etc/mysql/mariadb.conf.d/50-server.cnf

# Install MariaDB server and client in a single layer and clean up
RUN apt update && apt upgrade -y && \
    apt-get install mariadb-server -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



COPY ./tools/init_maria_db.sh   /init_maria_db.sh
COPY ./tools/init_database.sql  /init_database.sql

# Allow script to be executed
RUN chmod +x /init_maria_db.sh


# substitutes "bind-address = 127.0.0.1"
# with        "bind-address = 0.0.0.0"
RUN sed --in-place 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' ${MARIADB_CONFIG_FILE} || \
    echo 'bind-address = 0.0.0.0' >> ${MARIADB_CONFIG_FILE}


ENTRYPOINT [ "/init_maria_db.sh" ]

# Mariadb requires /run/msyqld directory to exists
# So far, can't find documentation about this on official mariadb
# But it is suggested when using this command "mysqld --verbose --help | grep -E 'socket|pid'"
# pid-file and socket show have their paths set to /run/mysqld/mysqld.pid
# NOTE: creation of run/mysqld is done automatically in the mariadb.service file in /lib/systemd/system/mariadb.service
# RUN mkdir --parents /run/mysqld && \
#     chown mysql:mysql /run/mysqld