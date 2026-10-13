# --- FASE 1: BASE ---
FROM php:8.5.11-fpm-alpine3.24 AS base
WORKDIR /var/www/html

# Dependencias del sistema y extensiones de PHP para Laravel Backend
RUN apk add --no-cache \
    git \
    unzip \
    curl \
    libzip-dev \
    postgresql-dev \
    icu-dev \
    linux-headers \
    $PHPIZE_DEPS \
    && docker-php-ext-install -j$(nproc) \
    zip \
    pdo_pgsql \
    pdo_mysql \
    bcmath \
    pcntl \
    intl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del $PHPIZE_DEPS \
    && rm -rf /tmp/pear

# --- FASE 2: DESARROLLO (dev) ---
FROM base AS dev
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
CMD ["sh", "-c", "if [ -f composer.json ]; then php-fpm; else echo 'Proyecto no inicializado. Manteniendo contenedor vivo...' && tail -f /dev/null; fi"]

# --- FASE 3: PRODUCCIÓN (prod) ---
FROM base AS prod
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY ./volume/app/src .
RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader --no-interaction; fi
RUN if [ -d storage ]; then chown -R www-data:www-data storage bootstrap/cache; fi
CMD ["php-fpm"]