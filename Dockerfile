FROM ubuntu:22.04

LABEL maintainer="vs.girenko@mail.ru"

ARG NODE_VERSION=18
ARG POSTGRES_VERSION=14
ARG PHP_VERSION=8.2

WORKDIR /var/www/html

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 dnsutils && \
    curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /usr/share/keyrings/ppa_ondrej_php.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list && \
    apt-get update && \
    apt-get install -y \
        php$PHP_VERSION-fpm \
        php$PHP_VERSION-dev \
        php$PHP_VERSION-pgsql \
        php$PHP_VERSION-sqlite3 \
        php$PHP_VERSION-gd \
        php$PHP_VERSION-curl \
        php$PHP_VERSION-imap \
        php$PHP_VERSION-mysql \
        php$PHP_VERSION-mbstring \
        php$PHP_VERSION-xml \
        php$PHP_VERSION-zip \
        php$PHP_VERSION-bcmath \
        php$PHP_VERSION-soap \
        php$PHP_VERSION-intl \
        php$PHP_VERSION-readline \
        php$PHP_VERSION-ldap \
        php$PHP_VERSION-msgpack \
        php$PHP_VERSION-igbinary \
        php$PHP_VERSION-redis \
        php$PHP_VERSION-swoole \
        php$PHP_VERSION-memcached \
        php$PHP_VERSION-pcov \
        php$PHP_VERSION-xdebug && \
    curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarn.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/pgdg.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y yarn && \
    apt-get install -y mysql-client && \
    apt-get install -y postgresql-client-$POSTGRES_VERSION && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php$PHP_VERSION

COPY laravel-entrypoint.sh /usr/local/bin/laravel-entrypoint
COPY zz-docker.conf /etc/php/$PHP_VERSION/fpm/pool.d/zz-docker.conf
COPY supervisord.conf /etc/supervisord.conf

RUN chmod +x /usr/local/bin/laravel-entrypoint

STOPSIGNAL SIGQUIT

EXPOSE 9000

ENTRYPOINT ["laravel-entrypoint"]
ENV FPM_EXECUTABLE=/usr/sbin/php-fpm${PHP_VERSION}
CMD ${FPM_EXECUTABLE} -F -R
