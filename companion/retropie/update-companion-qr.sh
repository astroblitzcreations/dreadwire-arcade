#!/usr/bin/env bash
set -euo pipefail
out=${1:-/home/pi/RetroPie/roms/companion/media/arcade-remote-qr.png}
ip=$(hostname -I | tr ' ' '\n' | grep -E '^192\.168\.|^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.' | head -1)
[[ -n "$ip" ]] || ip=192.168.0.160
url="http://${ip}:8765/"
mkdir -p "$(dirname "$out")"
qrencode -o "$out" -s 12 -m 3 -l H "$url"
chown pi:pi "$out"
printf '%s\n' "$url" > /run/dreadwire-companion-url
chown pi:pi /run/dreadwire-companion-url
