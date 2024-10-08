FROM php:8.3.12-cli-bookworm

ARG OCTANE_SERVER
ENV OCTANE_SERVER=$OCTANE_SERVER

WORKDIR /var/www/presentation

RUN apt-get update &&\
    apt-get install -y \
    git \
    zip \
    unzip \
    supervisor \
    libbrotli-dev

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" &&\
    echo "max_input_vars=32" >> $PHP_INI_DIR/php.ini &&\
    echo "post_max_size=32K" >> $PHP_INI_DIR/php.ini &&\
    echo "memory_limit=64M" >> $PHP_INI_DIR/php.ini &&\
    echo "file_uploads=Off" >> $PHP_INI_DIR/php.ini &&\
    echo "opcache.enable = 1" >> $PHP_INI_DIR/php.ini &&\
    echo "opcache.enable_cli = 1" >> $PHP_INI_DIR/php.ini &&\
    echo "opcache.validate_timestamps = 0" >> $PHP_INI_DIR/php.ini &&\
    echo "opcache.memory_consumption = 128" >> $PHP_INI_DIR/php.ini

RUN docker-php-ext-install sockets pdo_mysql pcntl opcache

RUN pecl install swoole &&\
    docker-php-ext-enable swoole

RUN curl -sSk https://getcomposer.org/installer | php -- --version=2.8.1  &&\
    mv composer.phar /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN php artisan optimize

CMD ["supervisord", "-c", "/var/www/presentation/supervisord.conf"]
