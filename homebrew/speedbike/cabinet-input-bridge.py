#!/usr/bin/env python3
"""Translate the selected RetroPie Player 1 controller into Speedbike keys."""

import json
import os
from pathlib import Path
import subprocess
from evdev import InputDevice, ecodes


def emit(action: str, key: str) -> None:
    env = os.environ.copy()
    env.setdefault("DISPLAY", ":0")
    subprocess.run(
        ["xdotool", action, "--clearmodifiers", key], env=env,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False,
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
# Hide only the cabinet encoder's quarter-turned raw events from Godot. Other
# USB/Bluetooth controllers remain native and retain true simultaneous axes and
# buttons. The grab is automatically released when this process exits.
if "DragonRise" in device.name:
    device.grab()
buttons = {
    ecodes.BTN_TRIGGER: "Shift_L",    # ES right shoulder / boost
    ecodes.BTN_THUMB: "Return",       # ES B / shoot
    ecodes.BTN_THUMB2: "space",       # ES A / jump
    ecodes.BTN_TOP: "Return",         # ES X / alternate shoot
    ecodes.BTN_TOP2: "Shift_L",       # ES Y / alternate boost
    ecodes.BTN_PINKIE: "Escape",      # ES Select/hotkey / pause
    ecodes.BTN_BASE: "Shift_L",       # ES left shoulder / boost
    ecodes.BTN_BASE2: "Return",       # physical Start
    ecodes.BTN_BASE3: "Return",       # ES right trigger / shoot
    ecodes.BTN_BASE4: "space",        # ES left trigger / jump
}
axis_state = {ecodes.ABS_X: None, ecodes.ABS_Y: None}
axis_keys = (
    # Physical cabinet mounting observed live:
    # The encoder is mounted a quarter-turn from its logical axes.
    # X negative=physical up, X positive=physical down,
    # Y negative=physical right, Y positive=physical left.
    {ecodes.ABS_X: ("Up", "Down"), ecodes.ABS_Y: ("Right", "Left")}
    if "DragonRise" in device.name else
    {ecodes.ABS_X: ("Left", "Right"), ecodes.ABS_Y: ("Up", "Down")}
)

for event in device.read_loop():
    if event.type == ecodes.EV_KEY and event.code in buttons:
        emit("keydown" if event.value else "keyup", buttons[event.code])
    elif event.type == ecodes.EV_ABS and event.code in axis_keys:
        negative, positive = axis_keys[event.code]
        old = axis_state[event.code]
        info = device.absinfo(event.code)
        # python-evdev exposes these fields as min/max on the cabinet's
        # Raspberry Pi OS build (newer releases also provide named aliases).
        axis_min = getattr(info, "min", getattr(info, "minimum", 0))
        axis_max = getattr(info, "max", getattr(info, "maximum", 255))
        center = (axis_min + axis_max) / 2
        deadzone = max((axis_max - axis_min) * 0.22, 1)
        new = negative if event.value < center - deadzone else positive if event.value > center + deadzone else None
        if new == old:
            continue
        if old:
            emit("keyup", old)
        if new:
            emit("keydown", new)
        axis_state[event.code] = new
