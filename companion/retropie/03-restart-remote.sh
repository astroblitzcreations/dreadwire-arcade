#!/usr/bin/env bash
sudo systemctl restart dreadwire-companion.service
sleep 2
status=$(systemctl is-active dreadwire-companion.service 2>/dev/null || true)
dialog --title "Arcade Remote" --msgbox "Companion service: $status" 8 44
clear
