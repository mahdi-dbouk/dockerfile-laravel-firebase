FROM php:8.3-apache

# Install dependencies
RUN apt-get update && \
    apt-get install -y --fix-missing \
    libzip-dev \
    zip \
    libgrpc-dev \
    libgrpc++-dev \
    libsodium-dev \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    protobuf-compiler \
    git \
    && rm -rf /var/lib/apt/lists/*

# Enable mod_rewrite
RUN a2enmod rewrite

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql zip sodium

#Compile and install gRPC extension
#RUN git clone https://github.com/grpc/grpc.git && \
#    cd grpc && \
#    git submodule update --init && \
#    make && \
#    make install

# Install gRPC and Protobuf extensions
RUN MAKEFLAGS="-j $(nproc)" pecl install grpc && \
  echo "extension=grpc.so" > /usr/local/etc/php/conf.d/grpc.ini && \
  pecl install protobuf && \
  echo "extension=protobuf.so" > /usr/local/etc/php/conf.d/protobuf.ini

# Verify installation
#RUN php -m | grep -q 'grpc' && \
 #   php -m | grep -q 'protobuf'


# Verify installation
RUN php -m | grep -q 'grpc' && \
php -m | grep -q 'protobuf'

# Add gRPC extension to PHP
#RUN echo "extension=grpc.so" > /usr/local/etc/php/conf.d/grpc.ini

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy the application code
COPY . /var/www/html

# Set the working directory
WORKDIR /var/www/html

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install project dependencies
RUN composer install

#create .env
COPY .env.example .env

#Generate App Key
RUN php artisan key:generate

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
