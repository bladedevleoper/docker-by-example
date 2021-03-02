#go off to docker hub and get me php 8 with apache
FROM php:8.0-apache

RUN docker-php-ext-install pdo pdo_mysql

ARG uid
#1000
RUN useradd -G www-data,root -u $uid -d /home/testuser testuser
RUN mkdir -p /home/testuser/.composer && \
    chown -R testuser:testuser /home/testuser

RUN apt-get update --fix-missing -q
RUN echo 'now going install node js'
RUN apt-get install -y nodejs
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#environment variables for apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite

#I want to copy all this directory and place it into /var/www/html
COPY . /var/www/html/

RUN echo 'storage permissions are going be updated'
#grant access to storage in project
RUN chmod -R 775 /var/www/html/storage
RUN echo 'Permissions updated'

#Run Composer install and composer dump-autoload
RUN echo 'chwon -R www-data:www-data /var/www/html' \
&& composer install \
&& composer dump-autoload -o


RUN echo 'setup complete'






