FROM quay.io/spivegin/php7

ADD files/Caddy/Caddyfile /opt/caddy/
ADD files/php/ /etc/php/7.0/fpm/pool.d/
ADD files/bash/composer.sh /opt/

WORKDIR /opt/tlm/html

RUN git clone https://github.com/LiveHelperChat/livehelperchat.git . &&\
    git clone https://github.com/LiveHelperChat/livehelperchat-extensions.git extension &&\
    rm -rf extension/.git &&\
    git clone https://github.com/LiveHelperChat/telegram.git lhctelegram &&\
    rm -rf lhctelegram/.git && mv lhctelegram extension/ &&\
    cp lhc_web/extension/* extension && rm -rf lhc_web/extension && mv extension lhc_web/ &&\
    chown -R www-data:www-data .
RUN chmod +x /opt/composer.sh && /opt/composer.sh &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/bin/entry.sh"]