#!/usr/bin/env bash
set -euo pipefail

name=Dreadwire-Hotspot
ssid=Dreadwire-Arcade
secret_file=/etc/dreadwire/hotspot-password
install -d -m 0700 /etc/dreadwire
if [[ -n "${DREADWIRE_HOTSPOT_PASSWORD:-}" ]]; then
    password="$DREADWIRE_HOTSPOT_PASSWORD"
elif [[ -s "$secret_file" ]]; then
    password=$(<"$secret_file")
else
    password="Arcade-$(python3 -c 'import secrets,string; alphabet=string.ascii_letters+string.digits; print("".join(secrets.choice(alphabet) for _ in range(12)))')"
fi
printf '%s\n' "$password" > "$secret_file"
chmod 0600 "$secret_file"

if nmcli -g NAME connection show | grep -Fxq "$name"; then
    nmcli connection modify "$name" \
        connection.autoconnect yes connection.autoconnect-priority -100 \
        802-11-wireless.mode ap 802-11-wireless.ssid "$ssid" \
        802-11-wireless.band bg ipv4.method shared ipv4.addresses 10.42.0.1/24 \
        ipv6.method disabled wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$password"
else
    nmcli connection add type wifi ifname wlan0 con-name "$name" ssid "$ssid"
    nmcli connection modify "$name" \
        connection.autoconnect yes connection.autoconnect-priority -100 \
        802-11-wireless.mode ap 802-11-wireless.band bg \
        ipv4.method shared ipv4.addresses 10.42.0.1/24 \
        ipv6.method disabled wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$password"
fi

# Prefer remembered venue/home networks whenever they are actually available.
while IFS= read -r connection; do
    [[ "$connection" == "$name" ]] && continue
    nmcli connection modify "$connection" connection.autoconnect-priority 100 || true
done < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="802-11-wireless"{print $1}')

nmcli connection reload
echo "Fallback hotspot configured but not activated while normal Wi-Fi is connected."
