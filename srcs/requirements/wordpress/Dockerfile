FROM debian:bullseye

RUN apt update && apt upgrade -y && \
    apt-get install -y \
        curl \
        php \
        php-fpm \
        php-mysql \
        php-cli unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV WORDPRESS_ROOT=/var/www/html

# -- Download WordPress CLI --
# so that we can use it from bash, and automate the creation of users
RUN curl  --remote-name https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv    wp-cli.phar /usr/local/bin/wp

# -- Download less --
# less is a command-line pager program.
# lets you view/scroll-through text output one screen at a time, making it easier to read outputs.
# WP-CLI uses less to display paged output by default.
RUN apt-get update && apt-get install -y less

RUN mkdir -p ${WORDPRESS_ROOT} && \
    curl https://wordpress.org/latest.tar.gz | \ 
    tar zx -C ${WORDPRESS_ROOT} --strip-components=1 && \
    chown --recursive www-data:www-data ${WORDPRESS_ROOT}

WORKDIR ${WORDPRESS_ROOT}

RUN mkdir -p /var/log && chown --recursive www-data:www-data /var/log
RUN mkdir -p /run/php && chown --recursive www-data:www-data /run/php

COPY ./tools/init_wordpress.sh /init_wordpress.sh 
RUN chmod +x /init_wordpress.sh


RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf

USER www-data

# Start PHP's built-in server on port 8000
ENTRYPOINT [ "/init_wordpress.sh" ]



# RUN sed -i "s/^pm\.max_children\s*=.*/pm.max_children = 30/" /etc/php/7.4/fpm/pool.d/www.conf
# RUN sed -i "s/^pm\.start_servers\s*=.*/pm.start_servers = 8/" /etc/php/7.4/fpm/pool.d/www.conf
# RUN sed -i "s/^pm\.min_spare_servers\s*=.*/pm.min_spare_servers = 4/" /etc/php/7.4/fpm/pool.d/www.conf
# RUN sed -i "s/^pm\.max_spare_servers\s*=.*/pm.max_spare_servers = 12/" /etc/php/7.4/fpm/pool.d/www.conf



# # Download WordPress
# RUN mkdir -p /srv/www && \
#     # download latest wordpress version, and extract contents
#     curl https://wordpress.org/latest.tar.gz | \
#     tar zx -C /srv/www --strip-components=1 && \
    
#     # - www-data is a standard user and group to be used by web servers like Nginx.
#     # - files/processes in www-data have limited permissions for security, preventing web applications from having root access.
#     chown --recursive www-data:www-data /srv/www