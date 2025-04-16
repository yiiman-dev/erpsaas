FROM php:8.3-fpm

WORKDIR /var/www/html

RUN apt-get update -y  \
    && apt-get install -y \
    git \
    zip \
    unzip \
    curl \
    jq \
    sed \
    cron \
    libpng-dev \
    libzip-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libicu-dev \
    openssl \
    nginx \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd  \
    intl  \
    pdo  \
    pgsql \
    pdo_pgsql  \
    zip  \
    bcmath  \
    mbstring  \
    xml \
    exif \
    pcntl \
    sockets \
    xml \
    dom

COPY --from=mlocati/php-extension-installer:2.5.0 /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    amqp \
    json \
    tokenizer \
    zlib 
 #   swoole 
#    grpc

COPY --from=composer:2.7.9 /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./

RUN composer install --no-autoloader

COPY --chown=root:root . ./

RUN composer dump-autoload --optimize

RUN chmod -R 777 ./storage

EXPOSE 5050

COPY config/nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["sh", "-c", "exec ./entrypoint.sh"]
