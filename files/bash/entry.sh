#!/usr/bin/dumb-init /bin/sh
# gobetween from-file <path> [flags]
/usr/sbin/php-fpm7.1 --nodaemonize --fpm-config /etc/php/7.1/fpm/php-fpm.conf &
caddy run -config /opt/caddy/Caddyfile &
gobetween from-file /opt/caddy/livechat.json -f json