FROM quay.io/spivegin/livechatcors:latest AS livechatcors
FROM quay.io/spivegin/gobetween:latest AS gobetween
# FROM quay.io/spivegin/caddy_only:caddy2 AS caddy

FROM quay.io/spivegin/php7:7.1.3
ADD files/gobetween/livechat.json /opt/caddy/
ADD files/php/www.conf /etc/php/7.1/fpm/pool.d/
ADD files/bash/entry.sh /opt/bin/entry.sh
WORKDIR /opt/tlm/html
ADD files/Caddy/Caddyfile /opt/caddy/Caddyfile
# ADD files/Caddy/Caddyfile.caddy2 /opt/caddy/Caddyfile
# COPY --from=caddy /opt/bin/caddy  /opt/bin/caddy 
COPY --from=gobetween /opt/bin/gobetween  /opt/bin/gobetween 
COPY --from=livechatcors /opt/bin/livechatcors  /opt/bin/livechatcors 
RUN rm /etc/apt/sources.list.d/php.list &&\
    apt update && apt upgrade -y &&\
    apt install -y nano lsof socat iftop &&\
    apt-get autoremove && apt-get autoclean &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*     

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
    ln -s /opt/bin/gobetween /bin/gobetween &&\
    chmod +x /opt/bin/livechatcors &&\
    ln -s /opt/bin/livechatcors /bin/livechatcors
ADD files/php/index.php /opt/tlm/html/lhc_web/
# Website 9080 caddy management 9081 phpmyadmin 9092 mamage gobetween 2020
EXPOSE 9080 9081 9092 2020

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/bin/entry.sh"]