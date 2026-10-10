# --- FASE 1: BASE ---
FROM php:8.5.11-fpm-alpine3.24 AS base
WORKDIR /var/www/html
RUN apk add --no-cache libzip-dev postgresql-dev \
    && docker-php-ext-install zip pdo_pgsql pdo_mysql

# --- FASE 2: DESARROLLO (dev) ---
FROM base AS dev
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
CMD ["sh", "-c", "if [ -f composer.json ]; then php-fpm; else echo 'Proyecto no inicializado. Manteniendo contenedor vivo...' && tail -f /dev/null; fi"]

# --- FASE 3: PRODUCCIÓN (prod) ---
FROM base AS prod
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY ./volume/app/src .
RUN chown -R www-data:www-data /var/www/html
RUN composer install --no-dev --optimize-autoloader
CMD ["php-fpm"]