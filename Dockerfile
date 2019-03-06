FROM quay.io/spivegin/php7

ADD files/Caddy/Caddyfile /opt/caddy/
WORKDIR /opt/tlm/html

RUN git clone https://github.com/LiveHelperChat/livehelperchat.git .

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/bin/entry.sh"]