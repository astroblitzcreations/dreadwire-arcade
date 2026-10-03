#!/usr/bin/env python3
"""Learn the cabinet discharge rate and shut down before the power bank cuts out."""

import json
import os
import subprocess
import time
from pathlib import Path


BATTERY_STATE = Path("/var/lib/dreadwire-companion/battery.json")
RUNTIME_STATE = Path("/run/dreadwire-power.json")
BOOT_ID = Path("/proc/sys/kernel/random/boot_id")
POLL_SECONDS = 20


def read_json(path):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError, TypeError):
        return {}


def publish(**state):
    state["updated"] = time.time()
    temporary = RUNTIME_STATE.with_suffix(".tmp")
    temporary.write_text(json.dumps(state, indent=2) + "\n")
    temporary.replace(RUNTIME_STATE)


def warning_for(percent, minutes):
    if percent <= 5:
        return "shutdown", "Battery at 5% — safely shutting down now"
    if percent <= 10:
        return "critical", f"Critical battery: {percent:.0f}% • about {minutes:.0f} minutes remaining"
    if percent <= 15 or minutes <= 30:
        return "warning", f"Low battery: {percent:.0f}% • about {minutes:.0f} minutes remaining"
    return "ok", "Battery protection active"


def main():
    last_notice = None
    while True:
        state = read_json(BATTERY_STATE)
        current_boot = BOOT_ID.read_text().strip()
        same_boot = state.get("boot_id") == current_boot
        mode = state.get("mode", "battery")
        rate = state.get("discharge_rate_per_hour", state.get("rate_per_hour"))
        samples = int(state.get("discharge_sample_count", state.get("sample_count", 0)))

        if not state or not same_boot or mode != "battery":
            message = "Charging — automatic shutdown paused" if mode == "charging" else "Enter a fresh battery reading to start protection"
            publish(active=False, trusted=False, level="charging" if mode == "charging" else "waiting", message=message)
            last_notice = None
            time.sleep(POLL_SECONDS)
            continue

        if not rate or float(rate) <= 0:
            percent = float(state["percent"])
            if percent <= 5:
                level = "shutdown"
                message = "Battery reading is 5% — safely shutting down now"
            elif percent <= 10:
                level = "critical"
                message = f"Critical battery: {percent:.0f}% — runtime calibration is still learning"
            elif percent <= 15:
                level = "warning"
                message = f"Low battery: {percent:.0f}% — runtime calibration is still learning"
            else:
                level = "learning"
                message = "Learning discharge rate — ETA shutdown is not armed yet"
            publish(active=True, trusted=False, level=level, percent=percent,
                    sample_count=samples, message=message)
            if level != last_notice and level in {"warning", "critical", "shutdown"}:
                subprocess.run(["logger", "-t", "dreadwire-power", message], check=False)
                subprocess.run(["wall", message], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
                last_notice = level
            if level == "shutdown":
                subprocess.run(["sync"], check=False)
                time.sleep(2)
                subprocess.run(["systemctl", "poweroff"], check=False)
                return
            time.sleep(POLL_SECONDS)
            continue

        elapsed_hours = max(0, time.time() - float(state["updated"])) / 3600
        percent = max(0.0, float(state["percent"]) - float(rate) * elapsed_hours)
        minutes = percent / float(rate) * 60
        trusted = samples >= 2
        level, message = warning_for(percent, minutes)
        if not trusted and level == "shutdown":
            level = "critical"
            message = "Estimated battery is below 5%, but shutdown is not armed until two calibration samples are saved"

        publish(active=True, trusted=trusted, level=level, message=message,
                percent=round(percent, 1), minutes=round(minutes),
                rate_per_hour=round(float(rate), 2), sample_count=samples)

        if level != last_notice and level in {"warning", "critical", "shutdown"}:
            subprocess.run(["logger", "-t", "dreadwire-power", message], check=False)
            subprocess.run(["wall", message], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
            last_notice = level

        if level == "shutdown" and trusted:
            subprocess.run(["sync"], check=False)
            time.sleep(2)
            subprocess.run(["systemctl", "poweroff"], check=False)
            return

        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    main()
