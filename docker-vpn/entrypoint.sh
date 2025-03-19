#!/usr/bin/bash

##service tor start
##service privoxy start
##/etc/init.d/shadowsocks-libev start
cp /etc/resolv.conf /tmp/resolv.conf
su -c 'umount /etc/resolv.conf'
cp /tmp/resolv.conf /etc/resolv.conf
sed -i 's/DAEMON_ARGS=.*/DAEMON_ARGS=""/' /etc/init.d/expressvpn


cat <<EOF > /etc/shadowsocks-libev/config.json
{
    "server":["::1", "0.0.0.0"],
    "mode":"tcp_and_udp",
    "server_port":8118,
    "local_port":1080,
    "password":"iserver123",
    "timeout":86400,
    "method":"chacha20-ietf-poly1305"
}
EOF

echo "配置文件已写入 /etc/shadowsocks-libev/config.json"
service expressvpn restart
/etc/init.d/shadowsocks-libev restart
/usr/bin/expect /tmp/expressvpnActivate.sh
expressvpn connect $SERVER
exec "$@"
