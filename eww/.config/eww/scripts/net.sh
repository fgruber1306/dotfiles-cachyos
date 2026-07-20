#!/usr/bin/env bash
# Streams JSON every 2s: down/up MB/s, VPN state, exit IP (cached 10 min)
IPCACHE=/tmp/oni-exit-ip

get_iface() {  # prefer a wireguard iface, else default route
  ip -o link show type wireguard 2>/dev/null | awk -F': ' 'NR==1{print $2}' && return
  ip route show default | awk 'NR==1{print $5}'
}

while :; do
  IF=$(get_iface); IF=${IF:-lo}
  R1=$(cat /sys/class/net/$IF/statistics/rx_bytes 2>/dev/null || echo 0)
  T1=$(cat /sys/class/net/$IF/statistics/tx_bytes 2>/dev/null || echo 0)
  sleep 2
  R2=$(cat /sys/class/net/$IF/statistics/rx_bytes 2>/dev/null || echo 0)
  T2=$(cat /sys/class/net/$IF/statistics/tx_bytes 2>/dev/null || echo 0)
  DOWN=$(awk -v a=$R1 -v b=$R2 'BEGIN{printf "%.1f",(b-a)/2/1048576}')
  UP=$(awk -v a=$T1 -v b=$T2 'BEGIN{printf "%.1f",(b-a)/2/1048576}')

  VPN=false; ip link show type wireguard 2>/dev/null | grep -q . && VPN=true

  if [ ! -f "$IPCACHE" ] || [ $(( $(date +%s) - $(stat -c %Y "$IPCACHE") )) -gt 600 ]; then
    curl -sf --max-time 4 ifconfig.me > "$IPCACHE" 2>/dev/null || true
  fi
  IP=$(cat "$IPCACHE" 2>/dev/null || echo "?")

  jq -nc --arg d "$DOWN" --arg u "$UP" --arg ip "$IP" --arg if "$IF" --argjson v $VPN \
    '{down:$d, up:$u, ip:$ip, iface:$if, vpn:$v}'
done
