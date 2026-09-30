#!/usr/bin/env bash
set -euo pipefail
state=/var/lib/dreadwire-companion/mode.json
current=$(python3 -c 'import json; print(json.load(open("'"$state"'")).get("mode","classic"))' 2>/dev/null || echo classic)
choice=$(dialog --stdout --title "Dreadwire Arcade Mode" --default-item "$current" --menu \
  "Choose how the cabinet handles players:" 18 70 8 \
  classic "Classic — normal cabinet play" \
  party "Party — timed phone queue and chat" \
  tournament "Tournament — queue plus high-score focus" \
  freeplay "Free Play — anyone can jump in, queue optional") || exit 0
printf '{"mode":"%s"}\n' "$choice" | sudo tee "$state" >/dev/null
sudo chown root:root "$state"; sudo chmod 0644 "$state"
if [[ "$choice" == party ]]; then
  nohup sudo /usr/local/bin/dreadwire-party-overlay >/dev/null 2>&1 &
fi
dialog --title "Arcade Mode Saved" --msgbox "$choice mode is now active.\n\nPhones will see the updated mode in the Party tab." 10 55
clear
