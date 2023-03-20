#!/bin/sh
set -e

# Install dependencies
if [ "$APP_ENV" = 'prod' ]; then
    composer install --no-dev --no-progress --no-interaction
    php artisan key:generate
else
    composer install --prefer-dist --no-progress --no-interaction
fi

# Run migrations
if ls -A database/migrations/*.php >/dev/null 2>&1; then
    php artisan migrate --force
fi

# Build and link frontend resources
php artisan storage:link --no-interaction
npm install && npm run build

# Run queue workers via Supervisor
supervisord -c /etc/supervisord.conf

exec "$@"
