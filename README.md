# Plantilla Docker - Laravel (Backend)

Plantilla Docker para Laravel configurada exclusivamente como **Monolito Backend** (API / Headless, Colas, Scheduler, DB y Redis). Sin dependencias de compilación frontend.

## Servicios incluidos

- **app**: PHP 8.5-FPM con extensiones backend (`pdo_pgsql`, `pdo_mysql`, `redis`, `pcntl`, `bcmath`, `intl`, `zip`, `opcache`).
- **caddy**: Servidor web que expone el puerto HTTP, sirve estáticos desde `/public` y traduce FastCGI hacia `app:9000`.
- **queue**: Worker de colas en segundo plano (`php artisan queue:work --tries=3 --timeout=90`).
- **scheduler**: Tareas programadas / cron en segundo plano (`php artisan schedule:work`).

## Requisitos previos

Crear la red externa de Docker definida en `.env` (si aún no existe), donde residen tus contenedores de Base de Datos y Redis:

```bash
docker network create template-network
```

## Uso en desarrollo

1. Iniciar los contenedores:

   ```bash
   docker compose up -d
   ```

2. Inicializar un nuevo proyecto de Laravel en `./volume/app/src/`:

   ```bash
   docker compose exec app composer create-project laravel/laravel .
   ```

3. Ajustar permisos de escritura:

   ```bash
   docker compose exec app chown -R www-data:www-data storage bootstrap/cache
   ```

4. Generar clave de aplicación (si no se generó):
   ```bash
   docker compose exec app php artisan key:generate
   ```

## Uso en producción

Construir y levantar en modo producción:

```bash
docker compose -f docker-compose.prod.yml up -d --build
```
