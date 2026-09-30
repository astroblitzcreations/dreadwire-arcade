#!/usr/bin/env python3
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET

PATH = Path("/opt/retropie/configs/all/emulationstation/es_input.cfg")
BACKUP = PATH.with_suffix(".cfg.before-mobile-gamepad")
tree = ET.parse(PATH); root = tree.getroot()
for node in list(root.findall("inputConfig")):
    if node.get("deviceName") in ("Dreadwire Mobile Gamepad", "Dreadwire Remote Keyboard", "Keyboard"):
        root.remove(node)
config = ET.SubElement(root, "inputConfig", {
    "type": "joystick", "deviceName": "Dreadwire Mobile Gamepad",
    "vendorId": "17495", "productId": "1",
    "deviceGUID": "03000000574400000100000001000000",
})
items = {
    "a": ("button", "0", "1"), "b": ("button", "1", "1"),
    "x": ("button", "2", "1"), "y": ("button", "3", "1"),
    "leftshoulder": ("button", "4", "1"), "rightshoulder": ("button", "5", "1"),
    "lefttrigger": ("button", "6", "1"), "righttrigger": ("button", "7", "1"),
    "select": ("button", "8", "1"), "start": ("button", "9", "1"),
    # Linux's joystick API exposes ABS_HAT0X/Y as axes 4/5 on this
    # virtual pad. Axes 0/1 belong to the independent analog stick.
    "left": ("axis", "4", "-1"), "right": ("axis", "4", "1"),
    "up": ("axis", "5", "-1"), "down": ("axis", "5", "1"),
}
for name, (kind, ident, value) in items.items():
    ET.SubElement(config, "input", {"name": name, "type": kind, "id": ident, "value": value})

# EmulationStation needs an explicit keyboard profile before it will consume
# arrow events from the companion's dedicated compatibility device. These are
# SDL2 keycodes, not Linux evdev codes.
keyboard = ET.SubElement(root, "inputConfig", {
    # SDL exposes all evdev keyboards to EmulationStation as "Keyboard".
    "type": "keyboard", "deviceName": "Keyboard",
    "deviceGUID": "-1",
})
keyboard_items = {
    "up": "1073741906", "down": "1073741905",
    "left": "1073741904", "right": "1073741903",
    "a": "13", "b": "27", "start": "115", "select": "32",
}
for name, ident in keyboard_items.items():
    ET.SubElement(keyboard, "input", {
        "name": name, "type": "key", "id": ident, "value": "1",
    })
if not BACKUP.exists(): shutil.copy2(PATH, BACKUP)
ET.indent(tree, space="\t"); tree.write(PATH, encoding="utf-8", xml_declaration=True)
