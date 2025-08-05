#!/bin/bash
isHaveAdded=`grep -c 'sh /root/report_system.sh>/dev/null' /etc/crontabs/root`
if [ $isHaveAdded == 0 ]; then
	echo "start install crontab task..."
 	`echo "*/1 * * * * sh /root/report_system.sh>/dev/null" >> /etc/crontabs/root`
	haveInstalledCron=`grep -c 'sh /root/report_system.sh>/dev/null' /etc/crontabs/root`
	if [ $haveInstalledCron == 1 ]; then
		echo "installed crontab task successfully."
	fi
fi
## ssl證書有問題。
SERVER_DOMAIN='https://apis.iservernetwork.cn'

## 檢查網絡狀態
function minitorNetwork(){
    ##检测外网情况
    ret=`curl --connect-timeout 3 -o /dev/null -I -skL -w "%{http_code}:%{time_starttransfer}" www.google.com`
    code=`echo -n $ret |awk -F ':' '{print $1}'`
    ## use_time=`echo -n $ret |awk -F ':' '{print $2}'`
    if [ "$code" == "200" ];then
            google_status="true"
    else
            google_status="false"
    fi
    isPwOpen=`uci get passwall.@global[0].enabled`
    if [ "$isPwOpen" == "1" ];then
       proxy_name="passwall"
       nodestring=`uci get passwall.@global[0].tcp_node`
       nodename=`uci get passwall.$nodestring.remarks`
       type=`uci get passwall.$nodestring.type`
       type=${type:0:2}
       protocol=`uci get passwall.$nodestring.protocol`
       protocol=${protocol:0:2}
       address=`uci get passwall.$nodestring.address |cut -d "." -f 1`
       echo "proxyInfo[proxy_name]=$proxy_name&proxyInfo[isOpen]=$isPwOpen&proxyInfo[google_status]=$google_status&proxyInfo[nodename]=$nodename&proxyInfo[type]=$type&proxyInfo[protocol]=$protocol&proxyInfo[address]=$address"
       return ;
    fi
    isSrOpen=`uci get shadowsocksr.@global[0].global_server`
    if [ $isSrOpen != nil ];then
        isOpen="true"
        proxy_name="shadowsocksr"
        nodestring=`uci get shadowsocksr.@global[0].global_server`
        nodename=`uci get shadowsocksr.$nodestring.alias`
        type=`uci get shadowsocksr.$nodestring.type`
        type=${type:0:2}
        protocol=`uci get shadowsocksr.$nodestring.v2ray_protocol`
        protocol=${protocol:0:2}
        address=`uci get shadowsocksr.$nodestring.server|cut -d "." -f 1`
        echo "proxyInfo[proxy_name]=$proxy_name&proxyInfo[isOpen]=$isSrOpen&proxyInfo[google_status]=$google_status&proxyInfo[nodename]=$nodename&proxyInfo[type]=$type&proxyInfo[protocol]=$protocol&proxyInfo[address]=$address"
        return ;
    fi
    ## not open proxy
    echo "proxyInfo[proxy_name]=none&proxyInfo[google_status]=$google_status"
    return ;
}
## check which proxy software is running
function checkProxySoftware(){
  passwall=`uci get passwall.@global[0].enabled`
  shadowsocksr=`uci get shadowsocksr.@global[0].global_server`
  openclash=`uci get openclash.config.enable`
  if [ $passwall == 1 ]; then
    echo "PW"
  elif [ $shadowsocksr != nil ]; then
    echo "SSR"
  elif [ $openclash == 1 ]; then
    echo "OC"
  else
    echo "None"
  fi
}
## get proxy information
function proxyInformation(){
  ## {proxyname:'passwall',enabled:'status',google_status:'true',node_name:'usa',remark:'mark',type"VM/VL",}
  ##passwall,openclash,shadowsocksr
  proxy_name=$1
  if [ $proxy_name == "passwall" ]; then
    isOpen=`uci get passwall.@global[0].enabled`
    ret=`curl --connect-timeout 3 -o /dev/null -I -skL -w "%{http_code}:%{time_starttransfer}" www.google.com`
    code=`echo -n $ret |awk -F ':' '{print $1}'`
    ## use_time=`echo -n $ret |awk -F ':' '{print $2}'`
    if [ "$code" == "200" ];then
      google_status="true"
    else
      google_status="false"
    fi
    if [ "$isOpen" == "1" ];then
       nodestring=`uci get passwall.@global[0].tcp_node`
       nodename=`uci get passwall.$nodestring.remarks`
       type=`uci get passwall.$nodestring.type`
       type=${type:0:2}
       protocol=`uci get passwall.$nodestring.protocol`
       protocol=${protocol:0:2}
       address=`uci get passwall.$nodestring.address |cut -d "." -f 1`
       echo "proxyInfo[proxy_name]=$proxy_name&proxyInfo[isOpen]=$isOpen&proxyInfo[google_status]=$google_status&proxyInfo[nodename]=$nodename&proxyInfo[type]=$type&proxyInfo[protocol]=$protocol&proxyInfo[address]=$address"
    else
       echo "proxyInfo[proxy_name]=$proxy_name&proxyInfo[isOpen]=$isOpen&proxyInfo[google_status]=$google_status"
    fi
  elif  [ $proxy_name == "shadowsocksr" ]; then
    isOpen=`uci get shadowsocksr.@global[0].global_server`
    if [ $isOpen != nil ];then
        isOpen="true"
        nodestring=`uci get shadowsocksr.@global[0].global_server`
        nodename=`uci get shadowsocksr.$nodestring.alias`
        type=`uci get shadowsocksr.$nodestring.type`
        type=${type:0:2}
        protocol=`uci get shadowsocksr.$nodestring.v2ray_protocol`
        protocol=${protocol:0:2}
        address=`uci get shadowsocksr.$nodestring.server|cut -d "." -f 1`
        echo "proxyInfo[proxy_name]=$proxy_name&proxyInfo[isOpen]=$isOpen&proxyInfo[google_status]=$google_status&proxyInfo[nodename]=$nodename&proxyInfo[type]=$type&proxyInfo[protocol]=$protocol&proxyInfo[address]=$address"
    else
        echo "proxyInfo[proxy_name]=$proxy_name&proxyInfo[isOpen]=$isOpen&proxyInfo[google_status]=$google_status"
    fi
  fi
}
##get user's IPv4 address
function get_ipv4(){
	ip=`/usr/bin/curl ip.sb`
	if [ -z $ip ];then
    echo 'false'
  else
    echo $ip
  fi
}
function get_ipv6(){
  ip6=`/usr/bin/curl -s -6 v6.ident.me`
  if [ -z $ip6 ];then
    echo 'false'
  else
    echo $ip6
  fi
}
##get user's user dns  only shadowsockes.
function get_proxy_used_dns(){
  ## shadowscoker;
	dns=`uci get shadowsocksr.@global[0].tunnel_forward`
	echo $dns;
}
function check_google_status_ip4(){
	`/usr/bin/ssr-check www.google.com 80 3 1`
	if [ $? == 0 ]; then
		echo 'true';
	else
		echo 'false';
	fi
}
function check_google_status_ipv6(){
  	`/usr/bin/ssr-check www.google.com 80 3 1`
	if [ $? == 0 ]; then
		echo 'true';
	else
		echo 'false';
	fi
}
## proxy :passwall,shadowsocksr
function is_open_proxy(){
  passret=`uci get passwall.@global[0].enabled`
	ret=`uci get  shadowsocksr.@global[0].global_server`
	if [ $ret != nil ];then
		echo 'true';
	else
		echo 'false';
	fi
}
## 獲取當前的網絡選中的節點
function get_proxy_hostname(){
	choosePoint=`uci get shadowsocksr.@global[0].global_server`
	if [ $choosePoint != nil ]; then
	        echo `uci get shadowsocksr.${choosePoint}.server`
	else
		      echo 'false'
	fi
}

function get_system_info(){
	datetime=`date +'%Y-%m-%d %H:%M:%S'`
	loadavg=`cat /proc/loadavg`
	uptime=`cat /proc/uptime`
	echo "systeminfo[uptime]=${uptime}&systeminfo[loadavg]=${loadavg}&systeminfo[datetime]=${datetime}&systeminfo[timezone]=`uci get system.@system[0].timezone`&systeminfo[zonename]=`uci get system.@system[0].zonename`&systeminfo[hostname]=`uci get system.@system[0].hostname`"
}
function nps_status(){
	echo "npsinfo[nps]=`uci get nps.@nps[0]`&npsinfo[nps_isenabled]=`uci get nps.@nps[0].enabled`&npsinfo[nps_server_addr]=`uci get nps.@nps[0].server_addr`&npsinfo[nps_vKey]=`uci get nps.@nps[0].vkey`"
}
# 获取當前系統 運行的透明代理軟件
function get_config_InternetalProxyStatus(){
  echo ""
}
MyIP=`get_ipv4`
MyIP6=`get_ipv6`
MyPoint=`get_proxy_hostname`
MyProxySoftware=`checkProxySoftware`
TimeStamp=`date +%s`
LocalDateTime=`date`
RouterKey="fe4b2de6-f07b-11ed-ab13-001c42d546d4"
proxyMessage=`minitorNetwork`
string_data="proxySoftware=${MyProxySoftware}&LocalDateTime=${LocalDateTime}&routerKey=${RouterKey}&localTimeStamp=${TimeStamp}&ipv4=${MyIP}&ipv6=${MyIP6}&`get_system_info`&mac=`ifconfig |grep br-lan |awk '{ print $5 }'`&`nps_status`&${proxyMessage}"
string_data=`echo $string_data |base64 -i`
echo "crypt String is :${string_data}"
echo "send data to the server.";
ret=`/usr/bin/curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" --data-urlencode "data=${string_data}" ${SERVER_DOMAIN}/api/uploadOpenwrtStatus`;
echo $ret
