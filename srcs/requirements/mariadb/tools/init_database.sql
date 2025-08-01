-- create database
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

-- create user
/*
In MySQL/MariaDB, users are defined as 'username'@'hostname'. The hostname part specifies where the user can connect from:
	'user'@'localhost' - Can only connect from the same machine
	'user'@'192.168.1.100' - Can only connect from that specific IP
	'user'@'%.example.com' - Can connect from any subdomain of example.com
	'user'@'%' - Can connect from any host/IP address
*/
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

-- set user permisions
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
FLUSH PRIVILEGES;