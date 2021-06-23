# Build image
FROM quay.io/spivegin/gitonly:latest AS git

FROM quay.io/spivegin/golang:v1.15.2 AS builder
WORKDIR /opt/src/src/sc.tpnfc.us/Misc/livechatcors
ADD . /opt/src/src/sc.tpnfc.us/Misc/livechatcors

RUN ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa && git config --global user.name "quadtone" && git config --global user.email "quadtone@txtsme.com"
COPY --from=git /root/.ssh /root/.ssh
RUN ssh-keyscan -H github.com > ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitea.com >> ~/.ssh/know_hosts

ENV deploy=c1f18aefcb3d1074d5166520dbf4ac8d2e85bf41 \
    GO111MODULE=on \
    GOPROXY=direct \
    GOSUMDB=off \
    GOPRIVATE=sc.tpnfc.us
    # GIT_TRACE_PACKET=1 \
    # GIT_TRACE=1 \
    # GIT_CURL_VERBOSE=1

RUN git config --global url.git@github.com:.insteadOf https://github.com/ &&\
    git config --global url.git@gitlab.com:.insteadOf https://gitlab.com/ &&\
    git config --global url.git@gitea.com:.insteadOf https://gitea.com/ &&\
    git config --global url."https://${deploy}@sc.tpnfc.us/".insteadOf "https://sc.tpnfc.us/"

RUN git clone https://sc.tpnfc.us/Misc/livechatcors.git &&\
    cd livechatcors &&\
    go build -o /opt/livechatcors livechatcors/main.go

# FROM quay.io/spivegin/caddy_only:caddy2 AS caddy
FROM quay.io/spivegin/gobetween:latest AS gobetween

FROM quay.io/spivegin/php7:7.1.3
ADD files/Caddy/Caddyfile /opt/caddy/
ADD files/gobetween/livechat.json /opt/caddy/
ADD files/php/www.conf /etc/php/7.1/fpm/pool.d/
ADD files/bash/entry.sh /opt/bin/entry.sh
WORKDIR /opt/tlm/html
# COPY --from=caddy /opt/bin/caddy  /opt/bin/caddy 
COPY --from=gobetween /opt/bin/gobetween  /opt/bin/gobetween 
COPY --from=builder /opt/livechatcors  /opt/bin/livechatcors 
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