#!/usr/bin/env bash
set -u

# Wait for the long online library scrape started during this upgrade.
while kill -0 58512 2>/dev/null; do
  sleep 30
done

python3 /home/pi/generate-fallback-artwork.py > /home/pi/fallback-artwork.log 2>&1
sudo systemctl restart getty@tty1.service
