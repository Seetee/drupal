# We use latest Ubuntu LTR as base image
FROM ubuntu:latest 

# This is me...
LABEL maintainer="docker@frantzen.se"

# Make sure we are up to date
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y autoremove

# Tell apt-get that we won't be there to answer questions
ENV DEBIAN_FRONTEND noninteractive

# Install what we need
RUN apt-get -y install apt-utils acl apache2 php7.1 php-mbstring php-mysql php-curl php-gd php-intl php-xml git curl unzip

# Configure apache2 and allow the Drupal .htaccess to override default URLs
RUN a2enmod ssl && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2dismod -f autoindex && \
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All'/ /etc/apache2/apache2.conf && \
    service apache2 restart

# Install Composer
RUN cd /usr/local/src && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install drush Launcher
RUN cd /tmp && \
    curl -OL https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar && \ 
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush

# Remove example files from drupal directory
RUN rm -rf /var/www/html/*

# Install drush and drupal
RUN composer create-project drupal-composer/drupal-project:8.x-dev /var/www/html --stability dev --no-interaction && \
    cd /var/www/html && \
    composer require drush/drush && \
    composer require drupal/devel:~1.0
#    composer require alchemy/zippy && \

# The ports that are exposed
EXPOSE 80/tcp
