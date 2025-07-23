FROM debian:bullseye

RUN apt update && apt upgrade -y && \
    apt-get install -y curl php php-fpm php-mysql php-cli unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download WordPress
RUN mkdir -p /srv/www && \
    # download latest wordpress version, and extract contents
    curl https://wordpress.org/latest.tar.gz | tar zx -C /srv/www --strip-components=1 && \
    
    # - www-data is a standard user and group to be used by web servers like Nginx.
    # - files/processes in www-data have limited permissions for security, preventing web applications from having root access.
    chown -R www-data:www-data /srv/www

# -- Download WordPress CLI --
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# -- Download less --
# less is a command-line pager program.
# lets you view/scroll-through text output one screen at a time, making it easier to read outputs.
# WP-CLI uses less to display paged output by default.
RUN apt-get update && apt-get install -y less

WORKDIR /srv/www

COPY init_wordpress.sh /init_wordpress.sh 

RUN chmod +x /init_wordpress.sh
USER www-data

# Start PHP's built-in server on port 8000
ENTRYPOINT [ "/init_wordpress.sh" ]