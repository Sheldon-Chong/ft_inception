FROM debian:bullseye

# Update package list and install nginx
RUN apt update && \
    apt upgrade -y && \
    apt install -y nginx

# Create necessary directories
RUN mkdir -p /var/www/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/html/index.html
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# NOT COPIED CORRECTLY, maybe must run in makefile
COPY ./tools/dhparam.pem /dhparam.pem
COPY ./tools/private.key /private.key
COPY ./tools/self_signed_certificate.pem /self_signed_certificate.pem

EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"] 





