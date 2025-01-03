#!/bin/bash
apt update && apt install supervisor ufw wget net-tools -y  \
&& cd /usr/local/src/ && wget https://github.com/go-gost/gost/releases/download/v3.0.0-nightly.20241227/gost_3.0.0-nightly.20241227_linux_amd64.tar.gz\
&& tar -zxvf gost_3.0.0-nightly.20241227_linux_amd64.tar.gz && mv ./gost /usr/local/bin/\
&& /usr/local/bin/gost -V \
&& touch /etc/supervisor/conf.d/gost.conf \
&& echo "[program:gost_http_proxy]
command=/usr/local/bin/gost -L http://user:pass@:8080" > /etc/supervisor/conf.d/gost.conf\
&& /etc/init.d/supervisor restart \
&& echo "Waiting for the restart of the process " && sleep 6 && supervisorctl status \
&& ufw allow 8080 \
&& netstat -lnp |grep -i 8080
