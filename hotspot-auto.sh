#!/bin/bash
# Hotspot تلقائي للـ Pi
# لو مش متصل بشبكة معروفة، شغّل hotspot عشان الـ Pi يوصلك

SSID="Pi-Project"
PASS="123123**"

sleep 15

CONNECTED=$(nmcli -t -f DEVICE,STATE device status 2>/dev/null | grep "^wlp0s20f3:connected" | head -1)
HOTSPOT_RUNNING=$(nmcli -t -f NAME connection show --active 2>/dev/null | grep "^Pi-Project$" | head -1)

if [ -z "$CONNECTED" ] && [ -z "$HOTSPOT_RUNNING" ]; then
  nmcli connection delete "$SSID" 2>/dev/null
  nmcli connection add type wifi ifname wlp0s20f3 con-name "$SSID" autoconnect no ssid "$SSID" \
    wifi.mode ap wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$PASS" \
    ipv4.method shared ipv6.method disabled
  nmcli connection up "$SSID"
fi
