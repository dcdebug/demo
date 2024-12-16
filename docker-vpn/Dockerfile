
# Run expressvpn in a container

FROM debian:bullseye-slim

LABEL maintainer="ethanwong.online@gmail.com"

ENV ACTIVATION_CODE Code
ENV LOCATION smart
ARG APP=expressvpn_3.78.0.0-1_amd64.deb
#expressvpn_3.78.0.0-1_amd64.deb
RUN apt-get update && apt-get install -y --no-install-recommends --only-upgrade expressvpn\
    wget curl apt-utils apt-transport-https dirmngr ca-certificates expect iproute2 procps libnm0 gnupg2 privoxy \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q "https://www.expressvpn.works/clients/linux/${APP}" -O /tmp/${APP} \
    && dpkg -i /tmp/${APP} \
    && rm -rf /tmp/*.deb \
    && apt-get purge -y --auto-remove wget\
    && sed -i \
        -e 's/listen-address\s*127.0.0.1:8118/listen-address 0.0.0.0:8118/g' \
        /etc/privoxy/config

COPY entrypoint.sh /tmp/entrypoint.sh
COPY expressvpnActivate.sh /tmp/expressvpnActivate.sh

ENTRYPOINT ["/bin/bash", "/tmp/entrypoint.sh"]
