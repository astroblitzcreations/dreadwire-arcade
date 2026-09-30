#!/usr/bin/env bash
sudo /usr/local/bin/update-companion-qr.sh
url=$(cat /run/dreadwire-companion-url 2>/dev/null || echo http://192.168.0.160:8765/)
status=$(systemctl is-active dreadwire-companion.service 2>/dev/null || true)
password=$(sudo cat /etc/dreadwire/hotspot-password 2>/dev/null || echo "Run hotspot setup first")
dialog --title "Dreadwire Arcade Remote" --msgbox "PHONE ADDRESS\n\n$url\n\nUsername: admin\n\nService: $status\n\nOFFLINE DIRECT NETWORK\nDreadwire-Arcade\nPassword: $password\nAddress: http://10.42.0.1:8765/\n\nAndroid: Chrome > Add to Home screen\niPhone: Safari Share > Add to Home Screen" 22 68
clear
