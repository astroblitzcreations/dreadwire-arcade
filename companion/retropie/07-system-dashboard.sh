#!/usr/bin/env bash
set -euo pipefail

if ! command -v chromium >/dev/null 2>&1 && ! command -v chromium-browser >/dev/null 2>&1; then
  dialog --title "Dreadwire System Dashboard" --msgbox "The cabinet dashboard is ready, but Chromium is not installed yet. Keep the cabinet plugged in and install the browser package before launching this entry." 11 68
  clear
  exit 0
fi

exec sudo -E xinit /opt/dreadwire/companion/cabinet-system-root-xclient.sh -- :0 vt1 -keeptty -nolisten tcp -nocursor
