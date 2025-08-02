#!/bin/bash

cd /var/www/html


cp wp-config-sample.php wp-config.php

sed --in-place "s/database_name_here/${DB_NAME}/"     wp-config.php
sed --in-place "s/username_here/${DB_USER}/"          wp-config.php
sed --in-place "s/password_here/${DB_USER_PASSWORD}/" wp-config.php
sed --in-place "s/localhost/mariadb/"                 wp-config.php

if ! wp core is-installed; then
  wp core install \
    --url="${WP_DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_NAME}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"
fi

wp user create "${WP_USER_NAME}" "${WP_USER_EMAIL}" \
  --user_pass="${WP_USER_PASSWORD}" \
  --role=author

# run PHP in foreground, force it to stay there
exec php-fpm7.4 --nodaemonize
