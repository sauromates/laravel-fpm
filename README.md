# Laravel FPM

A customized Docker image to run Laravel apps behind a reverse proxy.

# Disclaimer

Package is not part of official Laravel environment.

# About

This Docker image is a fork of official [Laravel Sail](https://github.com/laravel/sail) image with some additional features inspired by approach used in [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker) package.

Instead of using local PHP web server, it provides a PHP-FPM entrypoint along with Laravel specific tasks: application key generation, installing dependencies and running migrations on container start.

Latest version also includes a Supervisor configuration with two `artisan queue:work` processes to run jobs in background.

# Usage

Image is designed to be used in Laravel 9+ applications. Installation of Laravel Sail itself is not required. On the other hand, a web server (local or container) is required to act as a reverse proxy for PHP-FPM container. An example [`docker-compose` file](https://github.com/sauromates/laravel-fpm/blob/main/docker-compose.example.yml) can be found in this repository, featuring Caddy as reverse proxy.

Image can be pulled from Docker Hub

```
docker pull sauromates/laravel-fpm:latest
```

Or included in `docker-compose.yml`

```
version: '3'
services:
    php:
        image: sauromates/laravel-fpm
        ...
```

**Please note:**

Image is relying internally on the fact that application source code is mounted in `/var/www/html` folder inside container. In order to override this you should create your own Dockerfile based on this image along with Supervisor configuration.

# Deploy

The deploy is quite simple once you have configured a web server container. In most use cases you can simply clone your application on the server and run single `docker-compose up -d` command. In default environment, not even a build process is needed.

# Examples

## Usage with Caddy

Only 2 things are needed to deploy production-ready containerized Laravel app with Caddy: `public` folder binding and Caddyfile. Example of Caddy container configuration can be found in [`docker-compose` file](https://github.com/sauromates/laravel-fpm/blob/main/docker-compose.example.yml) under the `caddy` service. Example of Caddyfile is provided below.

```
{$SERVER_NAME}

log

route {
    root * /var/www/html/public

    php_fastcgi php:9000
    encode zstd gzip
    file_server
}
```

In this example `{$SERVER_NAME}` should be configured in your application's `.env` file (in most cases, it can be the same as `APP_URL` variable).

Also, `php_fastcgi` directive should contain the name of your application Docker service name and default FPM port, which is 9000.
