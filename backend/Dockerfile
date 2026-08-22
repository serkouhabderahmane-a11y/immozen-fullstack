FROM php:8.2-apache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

ENV DEBIAN_FRONTEND=noninteractive
RUN install-php-extensions gd exif intl bcmath pdo_mysql opcache zip

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public \
    COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_ALLOW_SUPERUSER=1

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf \
    && a2enmod rewrite headers

WORKDIR /var/www/html

COPY . .

RUN mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/app/public storage/logs bootstrap/cache database \
    && touch database/database.sqlite

RUN php -d memory_limit=-1 /usr/bin/composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-progress

COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080

ENTRYPOINT ["start.sh"]
