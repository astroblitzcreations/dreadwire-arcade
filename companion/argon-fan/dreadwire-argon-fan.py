#!/usr/bin/env python3
"""Temperature controller for the Argon Fan HAT (I2C 0x1a)."""
import json
import signal
import time
from pathlib import Path

import smbus

ADDRESS = 0x1A
BUS = 1
STATE = Path("/run/dreadwire-argon-fan.json")
CONFIG = Path("/var/lib/dreadwire-companion/fan.json")
TEMP = Path("/sys/class/thermal/thermal_zone0/temp")
HYSTERESIS = 3.0
PROFILES = {
    "quiet": ((72.0, 100), (66.0, 55), (60.0, 30), (0.0, 0)),
    "balanced": ((65.0, 100), (60.0, 55), (55.0, 30), (0.0, 0)),
    "cool": ((60.0, 100), (55.0, 75), (50.0, 50), (0.0, 25)),
}
running = True


def temperature():
    return int(TEMP.read_text().strip()) / 1000.0


def settings():
    data = {"profile": "balanced", "manual_speed": None, "manual_until": 0}
    try: data.update(json.loads(CONFIG.read_text()))
    except (OSError, ValueError, TypeError): pass
    if data.get("profile") not in PROFILES: data["profile"] = "balanced"
    return data


def target_speed(temp, previous, curve):
    desired = next(speed for threshold, speed in curve if temp >= threshold)
    # Hold the current stage until temperature falls 3C below that profile's
    # boundary, preventing rapid fan-speed chatter.
    for threshold, stage_speed in curve:
        if threshold > 0 and stage_speed == previous and temp >= threshold-HYSTERESIS:
            return previous
    return desired


def state(temp, speed, connected, message):
    temporary = STATE.with_suffix(".tmp")
    temporary.write_text(json.dumps({"temperature":round(temp,1),"speed":speed,
        "connected":connected,"message":message,"updated":time.time()}))
    temporary.replace(STATE)


def stop(*_):
    global running
    running = False


signal.signal(signal.SIGTERM, stop)
signal.signal(signal.SIGINT, stop)
speed = -1
bus = None
while running:
    temp = temperature()
    config = settings()
    manual = config.get("manual_speed")
    manual_active = manual is not None and float(config.get("manual_until", 0)) > time.time()
    curve = PROFILES[config["profile"]]
    desired = max(0, min(100, int(manual))) if manual_active else target_speed(temp, max(0, speed), curve)
    message = (f"Manual test ({max(0, int(config['manual_until']-time.time()))}s remaining)"
               if manual_active else f"Automatic: {config['profile']}")
    try:
        if bus is None: bus = smbus.SMBus(BUS)
        if desired != speed:
            bus.write_byte(ADDRESS, desired)
            speed = desired
        state(temp, speed, True, message)
        time.sleep(5)
    except (OSError, IOError) as exc:
        state(temp, 0, False, f"HAT not responding on I2C bus {BUS}: {exc}")
        if bus is not None:
            try: bus.close()
            except Exception: pass
        bus = None; speed = -1
        time.sleep(20)

if bus is not None:
    try: bus.write_byte(ADDRESS, 0)
    except OSError: pass
    bus.close()
