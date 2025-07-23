#!/bin/bash

cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sed -i "s/username_here/${DB_USER}/" wp-config.php
sed -i "s/password_here/${DB_USER_PASSWORD}/" wp-config.php
sed -i "s/localhost/mariadb/" wp-config.php

if ! wp core is-installed; then
  wp core install \
    --url="${WP_DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_NAME}" \
    --admin_password="${WP_USER_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"
fi

php -S 0.0.0.0:8000 -t /srv/www

