#!/usr/bin/bash

##service tor start
##service privoxy start
##/etc/init.d/shadowsocks-libev start
cp /etc/resolv.conf /tmp/resolv.conf
su -c 'umount /etc/resolv.conf'
cp /tmp/resolv.conf /etc/resolv.conf
sed -i 's/DAEMON_ARGS=.*/DAEMON_ARGS=""/' /etc/init.d/expressvpn
service expressvpn restart
/etc/init.d/shadowsocks-libev restart
/usr/bin/expect /tmp/expressvpnActivate.sh
expressvpn connect $SERVER
exec "$@"
