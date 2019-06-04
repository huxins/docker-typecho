FROM alpine:3.9.4

ARG plugins=http.cache,http.expires,http.git,http.minify,http.realip

# 国内源
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk --update add --no-cache \
    tzdata \
    ca-certificates \
    curl \
    tar \
    xz \
    openssl \
    php7 \
    php7-fpm \
    php7-mbstring \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_sqlite \
    php7-sqlite3 \
    php7-mysqli \
    php7-pgsql \
    php7-exif \
    php7-tokenizer \
    php7-fileinfo \
    php7-xml \
    php7-phar \
    php7-openssl \
    php7-json \
    php7-curl \
    php7-ctype \
    php7-session \
    php7-gd \
    php7-zip \
    php7-zlib \
    php7-iconv \
  && rm -rf /var/cache/apk/* \
  && rm -rf /usr/share/gtk-doc

RUN rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" >  /etc/timezone \
        && apk del --no-cache tzdata \
        && rm -rf /var/cache/apk/* \
        && rm -rf /root/.cache \
        && rm -rf /tmp/*

RUN curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" \
      "https://getcomposer.org/installer" \
    | php -- --install-dir=/usr/bin --filename=composer

RUN echo "clear_env = no" >> /etc/php7/php-fpm.conf

RUN curl --silent --show-error --fail --location \
    --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
    "https://caddyserver.com/download/linux/amd64?plugins=${plugins}&license=personal&telemetry=off" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
 && chmod 0755 /usr/bin/caddy \
 && addgroup -S caddy \
 && adduser -D -S -s /sbin/nologin -G caddy caddy \
 && setcap cap_net_bind_service=+ep `readlink -f /usr/bin/caddy` \
 && /usr/bin/caddy -version

EXPOSE 80 443 2015
WORKDIR /srv

COPY files/Caddyfile /etc/Caddyfile
COPY files/index.php /srv/index.php

RUN chown -R caddy:caddy /srv /var/log

USER caddy

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile"]