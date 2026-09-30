#!/usr/bin/env python3
"""Translate the quarter-turned cabinet encoder into Arena Brawl keys."""

import os
from pathlib import Path
import subprocess
from evdev import InputDevice, ecodes


def emit(action: str, key: str) -> None:
    env = os.environ.copy()
    env.setdefault("DISPLAY", ":0")
    subprocess.run(["xdotool", action, "--clearmodifiers", key], env=env,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)


device_path = "/dev/input/by-id/usb-DragonRise_Inc._Generic_USB_Joystick-event-joystick"
device = InputDevice(device_path)
if "DragonRise" in device.name:
    device.grab()

try:
    input_devices = Path("/proc/bus/input/devices").read_text(encoding="utf-8", errors="ignore").lower()
except OSError:
    input_devices = ""
xbox_connected = "x-box" in input_devices or "xbox" in input_devices
fire_key = "u" if xbox_connected else "space"
buttons = {
    ecodes.BTN_TRIGGER: fire_key, ecodes.BTN_THUMB: fire_key,
    ecodes.BTN_THUMB2: fire_key, ecodes.BTN_TOP: fire_key,
    ecodes.BTN_TOP2: fire_key, ecodes.BTN_BASE: fire_key,
    ecodes.BTN_BASE2: "p", ecodes.BTN_BASE3: fire_key,
    ecodes.BTN_BASE4: fire_key, ecodes.BTN_PINKIE: "Escape",
}
axis_state = {ecodes.ABS_X: None, ecodes.ABS_Y: None}
axis_keys = ({ecodes.ABS_X: (("Up", "Down") if xbox_connected else ("w", "s")),
              ecodes.ABS_Y: (("Right", "Left") if xbox_connected else ("d", "a"))}
             if "DragonRise" in device.name else
             {ecodes.ABS_X: ("a", "d"), ecodes.ABS_Y: ("w", "s")})

for event in device.read_loop():
    if event.type == ecodes.EV_KEY and event.code in buttons:
        emit("keydown" if event.value else "keyup", buttons[event.code])
    elif event.type == ecodes.EV_ABS and event.code in axis_keys:
        negative, positive = axis_keys[event.code]
        old = axis_state[event.code]
        info = device.absinfo(event.code)
        low = getattr(info, "min", getattr(info, "minimum", 0))
        high = getattr(info, "max", getattr(info, "maximum", 255))
        center = (low + high) / 2
        deadzone = max((high - low) * 0.22, 1)
        new = negative if event.value < center - deadzone else positive if event.value > center + deadzone else None
        if new == old:
            continue
        if old:
            emit("keyup", old)
        if new:
            emit("keydown", new)
        axis_state[event.code] = new
