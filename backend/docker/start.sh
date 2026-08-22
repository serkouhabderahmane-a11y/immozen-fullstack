#!/bin/bash
set -e

PORT="${PORT:-8080}"
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf

cd /var/www/html

if [ ! -f .env ]; then
  cp .env.example .env
  sed -i 's/^APP_ENV=.*/APP_ENV=production/' .env
  php artisan key:generate --force >/dev/null 2>&1 || true
fi

mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/app/public storage/logs bootstrap/cache database
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then touch database/database.sqlite; fi
chown -R www-data:www-data storage bootstrap/cache database

if [ ! -f storage/.migrated ]; then
  php artisan migrate --force
  if [ -d database/seeders ] && [ -f database/seeders/DatabaseSeeder.php ]; then
    php artisan db:seed --force || true
  fi
  touch storage/.migrated
fi

php artisan storage:link >/dev/null 2>&1 || true
php artisan config:cache
php artisan route:cache >/dev/null 2>&1 || true
php artisan view:cache

exec apache2-foreground
