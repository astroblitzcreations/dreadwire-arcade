#!/usr/bin/env bash
set -u

LOG=/home/pi/artwork-recovery.log
STATUS=/home/pi/artwork-recovery.status
LISTS=/home/pi/artwork-recovery-lists

# Put the small/high-value systems first so the cabinet improves quickly.
SYSTEMS=(n64 psx dreamcast arcade gba neogeo segacd snes nes megadrive gbc gamegear mastersystem gb pcengine ngpc ngp wonderswancolor wonderswan pc)

echo "running $(date --iso-8601=seconds)" > "$STATUS"
echo "=== Dreadwire artwork recovery started $(date) ===" >> "$LOG"

for system in "${SYSTEMS[@]}"; do
    list="$LISTS/$system-missing.txt"
    [ -s "$list" ] || continue
    count=$(wc -l < "$list")
    echo "system=$system stage=import item=0 total=$count" > "$STATUS"
    echo "=== $system: preserving current metadata ($count placeholders) ===" >> "$LOG"
    Skyscraper -p "$system" -s esgamelist --flags unattend -t 1 >> "$LOG" 2>&1 || true

    echo "system=$system stage=scrape item=0 total=$count" > "$STATUS"
    echo "=== $system: ScreenScraper checksum recovery ===" >> "$LOG"
    Skyscraper -p "$system" -s screenscraper --includefrom "$list" --flags unattend -t 1 --maxfails 200 >> "$LOG" 2>&1 || true

    echo "system=$system stage=generate item=$count total=$count" > "$STATUS"
    echo "=== $system: rebuilding gamelist ===" >> "$LOG"
    Skyscraper -p "$system" --flags unattend >> "$LOG" 2>&1 || true

    # Keep a visible cover for any ROM ScreenScraper truly cannot identify.
    python3 /home/pi/generate-fallback-artwork.py >> "$LOG" 2>&1 || true
done

echo "complete $(date --iso-8601=seconds)" > "$STATUS"
echo "=== Dreadwire artwork recovery complete $(date) ===" >> "$LOG"
