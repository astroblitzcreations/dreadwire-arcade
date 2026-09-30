#!/usr/bin/env bash
set -u
SKY=/opt/retropie/supplementary/skyscraper/Skyscraper
for system in dreamcast pc segacd; do
  echo "===== SCRAPE $system ====="
  "$SKY" -p "$system" -s thegamesdb --flags unattend --maxfails 50 || true
  "$SKY" -p "$system" -f emulationstation --flags unattend,skipped,relative || true
done
echo "===== NEW SYSTEM SCRAPE COMPLETE ====="
