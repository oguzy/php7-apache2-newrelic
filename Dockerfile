FROM alpine:3.5

ENV IGBINARY_VERSION=2.0.1

RUN sed -i -e 's/v3\.5/edge/g' /etc/apk/repositories

# Let's roll
RUN apk update && \
    apk add shadow && \
    apk upgrade && \
    apk add --update tzdata && \
    cp /usr/share/zoneinfo/Europe/Istanbul /etc/localtime && \
    echo "Europe/Istanbul" > /etc/timezone && \
    apk add --update \
        apache2 \
        apache2-utils \
        curl \
        vim \
        file \
        re2c \
        php7-apache2 \
        apache2-http2 \
        php7-sockets \
        php7-imap \
        php7-posix \
        php7-mysqli \
        php7-zlib \
        php7-zip \
        php7-opcache \
        php7-xmlrpc \
        php7-xmlreader \
        php7-sqlite3 \
        php7-soap \
        php7-shmop \
        php7-pdo \
        php7-phar \
        php7-pdo_mysql \
        php7-openssl \
        php7-mcrypt \
        php7-xml \
        php7-ldap \
        php7-json \
        php7-intl \
        php7-iconv \
        php7-gmp \
        php7-gettext \
        php7-gd \
        php7-exif \
        php7-dom \
        php7-dev autoconf gcc g++ clang make cmake \
        php7-ctype \
        php7-common \
        php7-bz2 \
        php7-bcmath \
        php7-apcu \
        php7-sysvmsg \
        php7-sysvshm \
        php7-wddx \
        php7-session \
        php7-mbstring \
        musl \
        libmemcached-libs \
        libmemcached-dev \
        zlib \
        php7  \
        #intl
        icu \
        icu-libs \
        icu-dev \
        php7-intl \
        #
        php7-xdebug && \

        mkdir -p /var/run/apache2 && \
        mkdir -p /var/www/html/public && \
        mkdir -p /var/log/apache2 && \
        usermod -u 500 apache && \
        groupmod -g 500 apache && \
        mkdir -p /root/src/php_module && \

        mkdir -p /pkg && \

        echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

#COPY appdynamics-php-agent-x64-linux-4.2.12.1.tar.bz2 /root/src/php_module/appdynamics-php-agent-x64-linux-4.2.12.1.tar.bz2
COPY php7-memcached-3.0_pre20160808-r0.apk /pkg/php7-memcached-3.0_pre20160808-r0.apk
RUN  apk add --allow-untrusted /pkg/php7-memcached-3.0_pre20160808-r0.apk 

#newrelic part
COPY newrelic-php5-7.1.0.187-linux-musl.tar.gz /root/src
COPY newrelic-install.sh /root/src/newrelic-install.sh
RUN sh /root/src/newrelic-install.sh


WORKDIR /root/src/php_module

RUN /usr/bin/curl -q  https://pecl.php.net/get/timezonedb-2016.10.tgz -o timezonedb-2016.10.tgz -k && \
    tar xvf timezonedb-2016.10.tgz && \
    cd timezonedb-2016.10/ && \
    apk update && \
    /usr/bin/phpize7 && \
    ./configure --with-php-config=php-config7 && \
    /usr/bin/make && \
    /usr/bin/make install && \
    echo "extension=timezonedb.so" > /etc/php7/conf.d/timezoned.ini

COPY php.ini /etc/php7/php.ini
COPY opcache-blacklist.txt /etc/php7/conf.d

# Compile igbinary
RUN set -xe && \
    curl -LO https://github.com/igbinary/igbinary/archive/${IGBINARY_VERSION}.tar.gz  && \
    tar zxf ${IGBINARY_VERSION}.tar.gz && \
    cd igbinary-${IGBINARY_VERSION} && \
    /usr/bin/phpize7 && ./configure --with-php-config=php-config7 && \
    make && make install && \
    echo "extension=igbinary.so" > /etc/php7/conf.d/igbinary.ini && \
    cd .. && rm -rf igbinary-${IGBINARY_VERSION}  ${IGBINARY_VERSION}.tar.gz

COPY extra/*.conf /etc/apache2/extra/
COPY httpd.conf /etc/apache2/httpd.conf

COPY dockerize /usr/local/bin/dockerize

# copy the modules
RUN mkdir -p /etc/apache2/modules && \
    mkdir -p /etc/apache2/conf.modules.d && \
    #echo "zend_extension=xdebug.so" >> /etc/php7/conf.d/xdebug.ini && \
    #echo "xdebug.remote_enable=1" >> /etc/php7/conf.d/xdebug.ini && \
    #echo "xdebug.remote_handler=dbgp xdebug.remote_mode=req" /etc/php7/conf.d/xdebug.ini && \
    #echo "xdebug.remote_host=127.0.0.1 xdebug.remote_port=9000" /etc/php7/conf.d/xdebug.ini && \
    #echo 'xdebug.idekey=idekey' >> /etc/php7/conf.d/xdebug.ini && \
    #echo 'xdebug.remote_connect_back=1' >> /etc/php7/conf.d/xdebug.ini && \
    #echo 'xdebug.remote_autostart=1' >> /etc/php7/conf.d/xdebug.ini && \
    echo 'opcache.enable=0' >> /etc/php7/conf.d/00_opcache.ini

COPY conf.modules.d/00-mpm.conf /etc/apache2/conf.modules.d/

WORKDIR /etc/apache2/modules

RUN ln -s /usr/lib/apache2/* . && \
    rm -rf /var/cache/apk/* && \
    #rm -rf /root/src/php_module && \
    apk del --purge \
        *-dev \
        build-base \
        autoconf \
        libtool \
        gcc \
        g++ \
        clang \
        make \
        cmake \
        php7-dev

COPY httpd-foreground /usr/local/bin/
COPY start_for_docker.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/httpd-foreground
RUN chmod a+x /usr/bin/newrelic-daemon
RUN chmod a+x /usr/local/bin/start_for_docker.sh

WORKDIR /

EXPOSE 80
CMD ["/usr/local/bin/start_for_docker.sh"]
