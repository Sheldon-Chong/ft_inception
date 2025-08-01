#!/bin/bash
service mariadb start

# Source the .env file to load environment variables
eval "cat <<EOF >db1.sql
$(cat init_database.sql)
EOF"


mysql < db1.sql

# Shuts down the MariaDB server using the mysqladmin tool.
# shutting down the MariaDB server requires sufficient permissions, hence we shut down as root user
mysqladmin -u root -p${ROOT_PASSWORD} shutdown

# this will execute mysqsld as PID 1, by replacing the current shell
# without exec, it will not be PID 1
# use "ps -p 1" to verify that mysqld is process1
exec mysqld