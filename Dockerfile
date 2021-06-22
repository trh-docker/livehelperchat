FROM quay.io/spivegin/caddy_only:caddy2 AS caddy
FROM quay.io/spivegin/gobetween:latest AS gobetween

FROM quay.io/spivegin/php7:7.1.3
ADD files/Caddy/Caddyfile /opt/caddy/
ADD files/gobetween/livechat.json /opt/caddy/
ADD files/php/ /etc/php/7.1/fpm/pool.d/
ADD files/bash/entry.sh /opt/bin/entry.sh
WORKDIR /opt/tlm/html
COPY --from=caddy /opt/bin/caddy  /opt/bin/caddy 
COPY --from=gobetween /opt/bin/gobetween  /opt/bin/gobetween 

RUN git clone https://github.com/LiveHelperChat/livehelperchat.git . &&\
    git clone https://github.com/LiveHelperChat/livehelperchat-extensions.git extension &&\
    rm -rf extension/.git &&\
    git clone https://github.com/LiveHelperChat/telegram.git lhctelegram &&\
    rm -rf lhctelegram/.git && mv lhctelegram extension/ &&\
    cp lhc_web/extension/* extension && rm -rf lhc_web/extension && mv extension lhc_web/ &&\
    chown -R www-data:www-data . &&\
    chmod +x /opt/bin/entry.sh &&\
    chmod +x /opt/bin/caddy &&\
    chmod +x /opt/bin/gobetween &&\
    ln -s /opt/bin/gobetween /bin/gobetween
# Website 9080 caddy management 9081 mamage gobetween 2020
EXPOSE 9080 9081 2020

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/bin/entry.sh"]