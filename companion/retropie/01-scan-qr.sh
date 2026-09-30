#!/usr/bin/env bash
set -euo pipefail
sudo /usr/local/bin/update-companion-qr.sh
image=/home/pi/RetroPie/roms/companion/media/arcade-remote-qr.png
clear
echo "Scan the QR code with your phone. This screen closes after 60 seconds."
timeout 60s fbi -T 1 -a -noverbose "$image" >/dev/null 2>&1 || true
clear
