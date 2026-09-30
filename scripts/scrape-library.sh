#!/usr/bin/env bash
set -u

SKY=/opt/retropie/supplementary/skyscraper/Skyscraper
LOG=/home/pi/skyscraper-library.log

run_source() {
  local source=$1
  shift
  for system in "$@"; do
    if [[ ! -d "/home/pi/RetroPie/roms/$system" ]]; then
      echo "SKIP missing system folder: $system"
      continue
    fi
    echo "===== SCRAPE $system via $source ====="
    "$SKY" -p "$system" -s "$source" --flags unattend --maxfails 200 || \
      echo "WARN scrape failed or reached source limit: $system ($source)"
    echo "===== GENERATE $system ====="
    "$SKY" -p "$system" -f emulationstation --flags unattend,skipped,relative || \
      echo "WARN gamelist generation failed: $system"
  done
}

# TheGamesDB is faster but has a 1,000-request anonymous allowance. Use it for
# systems where polished box artwork matters most and the library fits quota.
run_source thegamesdb n64 psx snes gba gbc gb

# ArcadeDB identifies short arcade set names much better than console sites.
run_source arcadedb arcade

# OpenRetro has no small daily quota. Use it for the remaining large library.
run_source openretro nes megadrive mastersystem gamegear pcengine neogeo ngp ngpc wonderswan wonderswancolor

echo "===== SCRAPE COMPLETE ====="
date
