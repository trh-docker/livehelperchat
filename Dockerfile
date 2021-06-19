FROM quay.io/spivegin/php7:7.1.3

ADD files/Caddy/Caddyfile /opt/caddy/
ADD files/php/ /etc/php/7.1/fpm/pool.d/
ADD files/bash/entry.sh /opt/bin/entry.sh
WORKDIR /opt/tlm/html

RUN git clone https://github.com/LiveHelperChat/livehelperchat.git . &&\
    git clone https://github.com/LiveHelperChat/livehelperchat-extensions.git extension &&\
    rm -rf extension/.git &&\
    git clone https://github.com/LiveHelperChat/telegram.git lhctelegram &&\
    rm -rf lhctelegram/.git && mv lhctelegram extension/ &&\
    cp lhc_web/extension/* extension && rm -rf lhc_web/extension && mv extension lhc_web/ &&\
    chown -R www-data:www-data . &&\
    chmod +x /opt/bin/entry.sh

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/bin/entry.sh"]