#!/usr/bin/env bash
set -euo pipefail

REPO="/home/mahmoud-dahy/FlutterProjects/graduatio_project"
BOOT="/media/mahmoud-dahy/bootfs"
ROOT="/media/mahmoud-dahy/rootfs"
PI_HOME="$ROOT/home/beso"
PI_SERVER="$PI_HOME/pi_server"
SERVICE_FILE="$ROOT/etc/systemd/system/phoenix-pi-server.service"
WANTS_DIR="$ROOT/etc/systemd/system/multi-user.target.wants"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script with sudo."
  exit 1
fi

if [[ ! -d "$BOOT" || ! -d "$ROOT" ]]; then
  echo "Raspberry Pi SD card is not mounted at bootfs/rootfs."
  exit 1
fi

mount -o remount,rw "$BOOT" || true
mount -o remount,rw "$ROOT" || true

if ! touch "$ROOT/tmp/phoenix-write-test"; then
  echo "rootfs is still read-only. Unmount/reinsert the SD card, then run again."
  exit 1
fi
rm -f "$ROOT/tmp/phoenix-write-test"

mkdir -p "$PI_SERVER"
cp -a "$REPO/pi_server/." "$PI_SERVER/"
chown -R 1000:1000 "$PI_SERVER"

cat > "$SERVICE_FILE" <<'EOF_SERVICE'
[Unit]
Description=Phoenix Raspberry Pi Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/beso/pi_server
Environment=PYTHONUNBUFFERED=1
ExecStartPre=/bin/bash -lc '/home/beso/graduation_project/venv/bin/python -c "import fastapi, uvicorn" || /home/beso/graduation_project/venv/bin/python -m pip install fastapi uvicorn'
ExecStart=/home/beso/graduation_project/venv/bin/python /home/beso/pi_server/main.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF_SERVICE

chmod 644 "$SERVICE_FILE"
mkdir -p "$WANTS_DIR"
ln -sf ../phoenix-pi-server.service "$WANTS_DIR/phoenix-pi-server.service"

cat > "$BOOT/network-config" <<'EOF_NETWORK'
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: true
      optional: true
  wifis:
    wlan0:
      dhcp4: true
      regulatory-domain: "EG"
      access-points:
        "iPhone":
          password: "Ma123123"
      optional: true
EOF_NETWORK

sync "$BOOT"
sync "$ROOT"

echo "Installed pi_server to /home/beso/pi_server and enabled phoenix-pi-server.service."
echo "After boot, test from laptop: curl http://raspaberry.local:8000/health"
