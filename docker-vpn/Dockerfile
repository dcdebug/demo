
# Run expressvpn in a container

FROM debian:bullseye-slim

LABEL maintainer="ethanwong.online@gmail.com"

ENV ACTIVATION_CODE Code
ENV LOCATION smart
ARG APP=expressvpn_3.78.0.0-1_amd64.deb

#expressvpn_3.78.0.0-1_amd64.deb
#RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf\
#   && echo "nameserver 8.8.4.4" >> /etc/resolv.conf
#RUN echo ""
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl apt-utils apt-transport-https dirmngr ca-certificates expect iproute2 procps libnm0 gnupg2 \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q "https://www.expressvpn.works/clients/linux/${APP}" -O /tmp/${APP} \
    && dpkg -i /tmp/${APP} \
 ##   && rm -rf /tmp/*.deb \
    && apt update && apt install -y --only-upgrade expressvpn && apt install -y nload htop vim net-tools shadowsocks-libev && mkdir -p /etc/shadowsocks-libev \
    ## && apt-get purge -y --auto-remove wget\
#    && sed -i \
#        -e 's/listen-address\s*127.0.0.1:8118/listen-address 0.0.0.0:8118/g' \
#        /etc/privoxy/config
RUN echo '{ \
"server":["::1", "0.0.0.0"], \
"mode":"tcp_and_udp", \
"server_port":8118, \
"local_port":1080, \
"password":"iserver123", \
"timeout":86400, \
"method":"chacha20-ietf-poly1305" \
}' > /etc/shadowsocks-libev/config.json

COPY entrypoint.sh /tmp/entrypoint.sh
COPY expressvpnActivate.sh /tmp/expressvpnActivate.sh

ENTRYPOINT ["/bin/bash", "/tmp/entrypoint.sh"]
