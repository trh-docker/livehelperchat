FROM quay.io/spivegin/php7

ADD files/Caddy/Caddyfile /opt/caddy/
ADD files/php/ /etc/php/7.0/fpm/pool.d/

WORKDIR /opt/tlm/html

RUN git clone https://github.com/LiveHelperChat/livehelperchat.git . &&\
    chown -R www-data:www-data .

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/bin/entry.sh"]