#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

# Install dependencies
if [ "$APP_ENV" != 'prod' ]; then
    composer install --prefer-dist --no-progress --no-interaction
else
    composer install --no-dev --no-progress --no-interaction
fi

# Run migrations
if ls -A database/migrations/*.php >/dev/null 2>&1; then
    php artisan migrate --force
fi

php artisan storage:link --no-interaction
npm install && npm run build

supervisord -c /etc/supervisord.conf

exec "$@"
