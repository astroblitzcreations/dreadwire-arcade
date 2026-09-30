#!/usr/bin/env python3
"""Translate the selected Player 1 controller into Void Run keyboard events."""

import json
import os
from pathlib import Path
import subprocess
from evdev import InputDevice, ecodes, list_devices


def emit(action: str, key: str) -> None:
    env = os.environ.copy()
    env.setdefault("DISPLAY", ":0")
    subprocess.run(
        ["xdotool", action, "--clearmodifiers", key],
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )


assignments = Path("/opt/retropie/configs/all/controller-assignments.json")
fallback = "/dev/input/by-id/usb-DragonRise_Inc._Generic_USB_Joystick-event-joystick"
device_path = fallback
try:
    identity = json.loads(assignments.read_text(encoding="utf-8")).get("player1", "")
    candidate = "/dev/input/by-id/" + identity.replace("-joystick", "-event-joystick")
    if identity and Path(candidate).exists():
        device_path = candidate
except (OSError, ValueError, TypeError):
    pass
device = InputDevice(device_path)

# Linux button code -> key understood by Void Run.
buttons = {
    ecodes.BTN_TRIGGER: "space",       # cabinet button / fire
    ecodes.BTN_THUMB: "Shift_L",       # cabinet button / boost
    ecodes.BTN_THUMB2: "space",        # alternate fire
    ecodes.BTN_TOP: "Shift_L",         # alternate boost
    ecodes.BTN_BASE4: "Return",        # physical Start (code 295)
}

axis_state = {ecodes.ABS_X: None, ecodes.ABS_Y: None}
if "DragonRise" in device.name:
    # The built-in cabinet encoder is physically mounted sideways.
    axis_keys = {
        ecodes.ABS_X: ("Up", "Down"),
        ecodes.ABS_Y: ("Right", "Left"),
    }
else:
    # Ordinary USB pads use the conventional X/Y orientation.
    axis_keys = {
        ecodes.ABS_X: ("Left", "Right"),
        ecodes.ABS_Y: ("Up", "Down"),
    }

for event in device.read_loop():
    if event.type == ecodes.EV_KEY and event.code in buttons:
        emit("keydown" if event.value else "keyup", buttons[event.code])
    elif event.type == ecodes.EV_ABS and event.code in axis_keys:
        negative, positive = axis_keys[event.code]
        old = axis_state[event.code]
        new = negative if event.value < 96 else positive if event.value > 160 else None
        if new == old:
            continue
        if old:
            emit("keyup", old)
        if new:
            emit("keydown", new)
        axis_state[event.code] = new
