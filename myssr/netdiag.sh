#!/usr/bin/env bash
# netdiag.sh — 分层网络诊断（L3 IP / DNS / 目标准入）
# 用法: bash netdiag.sh [目标域名, 默认 dns.google]
# 无 root 时跳过需权限项并提示。结论基于可复现命令，不靠猜测。

set -u
TARGET="${1:-dns.google}"
DOH_IP="8.8.8.8"

have() { command -v "$1" >/dev/null 2>&1; }

echo "==================== 网络分层诊断 ===================="
echo "目标域名: $TARGET   时间: $(date '+%F %T')"
echo

# ---------- 0. 本机环境 ----------
echo "### [0] 本机环境"
if have ifconfig; then
  ifconfig 2>/dev/null | grep -A2 "^[a-z].*:" | grep -E "inet |flags" | head -20
elif have ip; then
  ip -br addr 2>/dev/null
fi
echo "-- 默认网关 --"
if have route; then
  route -n get default 2>/dev/null | grep gateway || netstat -rn 2>/dev/null | grep "^default"
fi
echo "-- 生效 DNS --"
if have scutil; then
  scutil --dns 2>/dev/null | grep -A2 "nameserver" | head -8
elif [ -f /etc/resolv.conf ]; then
  grep nameserver /etc/resolv.conf | head -5
fi
echo "-- 本机代理进程 --"
ps aux 2>/dev/null | grep -iE "clash|surge|v2ray|xray|sing-box|shadowsocks|mihomo|ss-redir|gost" | grep -v grep || echo "(未发现常见代理进程)"
echo "-- 本地监听(53/7890/1080) --"
if have lsof; then
  lsof -i -P -n 2>/dev/null | grep -i listen | grep -E ":(53|7890|1080)" || echo "(无)"
elif have ss; then
  ss -lntup 2>/dev/null | grep -E ":(53|7890|1080)" || echo "(无)"
fi
echo

# ---------- 1. L3 IP 转发层 ----------
echo "### [1] L3 IP 转发层 (裸 IP 连通性, 不依赖 DNS)"
if have ping; then
  if ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
    echo "[OK] ping 1.1.1.1 通"
  else
    echo "[FAIL] ping 1.1.1.1 不通 -> IP 层可能已断 (先查本地代理/网关/防火墙)"
  fi
else
  echo "[SKIP] 无 ping"
fi
if have curl; then
  code=$(curl -s -o /dev/null -m 8 -w "%{http_code}" --resolve "$TARGET:443:$DOH_IP" "https://$TARGET" 2>/dev/null)
  echo "[$TARGET] curl --resolve $TARGET:443:$DOH_IP -> HTTP $code"
  [ "$code" = "200" ] && echo "  => IP 层直连正常, 若浏览器打不开则问题在 DNS/本机代理"
else
  echo "[SKIP] 无 curl"
fi
echo

# ---------- 2. DNS 解析层 + 透明劫持探测 ----------
echo "### [2] DNS 解析层"
if have dig; then
  echo "-- 正常递归 (向 8.8.8.8 查询) --"
  dig @8.8.8.8 +time=3 +tries=1 "$TARGET" +short 2>/dev/null | head -3 || echo "(无应答/超时)"
  echo "-- 透明劫持探测: 向不可路由地址 192.0.2.1 发查询 --"
  if dig @192.0.2.1 +time=3 +tries=1 "$TARGET" +short >/dev/null 2>&1; then
    echo "[WARN] 192.0.2.1 居然有应答 -> 100% 存在 UDP/53 透明劫持! 改终端 DNS 无效, 需设备侧处理"
  else
    echo "[OK] 192.0.2.1 无应答 -> 未见透明劫持"
  fi
else
  echo "[SKIP] 无 dig (macOS 可装 bind/dnsutils; Linux 装 dnsutils)"
fi
echo

# ---------- 3. 目标准入层 (DoH 取真实 IP 后直连) ----------
echo "### [3] 目标准入层 (DoH 绕开 DNS 劫持)"
if have curl; then
  real_ip=$(curl -s -m 8 --resolve dns.google:443:$DOH_IP -H "accept: application/dns-json" \
    "https://dns.google/resolve?name=$TARGET&type=A" 2>/dev/null | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"' | head -1 | tr -d '"')
  if [ -n "$real_ip" ]; then
    echo "DoH 真实 IP: $real_ip"
    code=$(curl -s -o /dev/null -m 8 -w "%{http_code}" --resolve "$TARGET:443:$real_ip" "https://$TARGET" 2>/dev/null)
    echo "curl --resolve $TARGET:443:$real_ip -> HTTP $code"
    if [ "$code" = "200" ]; then
      echo "  => 真实 IP 可直连, 纯 DNS/劫持问题 (改解析即可)"
    else
      echo "  => 真实 IP 也连不上 -> 目标准入(白名单)/防火墙在拦, 非 DNS 问题"
    fi
  else
    echo "[FAIL] 未能从 DoH 取得真实 IP (检查本机能否直连 8.8.8.8:443)"
  fi
else
  echo "[SKIP] 无 curl"
fi
echo

# ---------- 真实出口 / GeoIP 定位 ----------
echo "### [4] 真实出口 IP (GeoIP 定位核对)"
if have curl; then
  echo "curl -s https://ip.sb -> $(curl -s -m 8 https://ip.sb 2>/dev/null || echo 失败)"
fi
echo
echo "==================== 诊断结束 ===================="
echo "报告应包含: 本机环境 + 三层实测结果 + 被证伪的假设 + 下一步去哪台设备改什么"
