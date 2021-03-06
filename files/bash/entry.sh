#!/usr/bin/dumb-init /bin/sh
# gobetween from-file <path> [flags]
/usr/sbin/php-fpm7.1 --nodaemonize --fpm-config /etc/php/7.1/fpm/php-fpm.conf &
# caddy run -config /opt/caddy/Caddyfile &
caddy -conf /opt/caddy/Caddyfile &
# livechatcors server &
# socat -d tcp4-connect:127.0.0.1:9000 unix-connect:/run/php/php7.1-fpm.sock &
gobetween from-file /opt/caddy/livechat.json -f json