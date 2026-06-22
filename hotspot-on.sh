#!/bin/bash
# شغل Hotspot للـ Pi (Pi-Project / 123123**)
# شغّل السكربت ده لما تكون برة البيت وعايز الـ Pi يشتغل مع اللاب

SSID="Pi-Project"
PASS="123123**"

echo "بجهز Hotspot: $SSID"

# لو في hotspot قديم، امسحه
nmcli connection delete "$SSID" 2>/dev/null

# إنشاء hotspot
nmcli connection add type wifi ifname wlp0s20f3 con-name "$SSID" autoconnect no ssid "$SSID" \
  wifi.mode ap wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$PASS" \
  ipv4.method shared ipv6.method disabled

# شغله
nmcli connection up "$SSID"

echo "Hotspot [$SSID] شغال"
echo "اللاب IP: 10.42.0.1"
echo "الـ Pi هيتصل автоматически"
