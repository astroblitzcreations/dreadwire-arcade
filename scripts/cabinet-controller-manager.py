#!/usr/bin/env python3
"""Safe, persistent player assignment manager for the Dreadwire cabinet."""

import json
from html import escape
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import xml.etree.ElementTree as ET

CONFIG = Path("/opt/retropie/configs/all/controller-assignments.json")
RETROARCH = Path("/opt/retropie/configs/all/retroarch.cfg")
SYSTEM_RETROARCH = [Path("/opt/retropie/configs/dreamcast/retroarch.cfg")]
ES_INPUT = Path("/opt/retropie/configs/all/emulationstation/es_input.cfg")
FALLBACK = "usb-DragonRise_Inc._Generic_USB_Joystick-joystick"
AUTOCONFIG = Path("/opt/retropie/configs/all/retroarch/autoconfig")
CONTROLLER_MENU = Path("/home/pi/RetroPie/roms/controllers")
MOBILE_STATE = Path("/run/dreadwire/mobile-controllers.json")


def active_mobile_labels():
    try:
        records = json.loads(MOBILE_STATE.read_text()).get("controllers", {})
        return {int(slot): str(record.get("label", f"Mobile Player {slot}"))
                for slot, record in records.items()}
    except (OSError, ValueError, TypeError):
        return {}


def detected():
    result = {}
    mobile = active_mobile_labels()
    by_id = Path("/dev/input/by-id")
    for link in sorted(by_id.glob("*-joystick")) if by_id.exists() else []:
        if "event-joystick" in link.name:
            continue
        try:
            js_name = link.resolve().name
            index = int(js_name.removeprefix("js"))
            name = (Path("/sys/class/input") / js_name / "device/name").read_text().strip()
            result[link.name] = {"name": name, "index": index, "node": js_name}
        except (OSError, ValueError):
            continue
    # Bluetooth gamepads do not receive /dev/input/by-id symlinks on this
    # image. Add every remaining real js device using its Bluetooth address
    # (or a normalized name) as the persistent identity. Ignore our virtual
    # phone-player slots: those are managed by the companion app itself.
    known_nodes = {info["node"] for info in result.values()}
    for js in sorted(Path("/sys/class/input").glob("js*")):
        if js.name in known_nodes:
            continue
        try:
            index = int(js.name.removeprefix("js"))
            name = (js / "device/name").read_text().strip()
            if name.startswith("Dreadwire Player"):
                try:
                    slot = int(name.rsplit(" ", 1)[1])
                except (ValueError, IndexError):
                    continue
                if slot in mobile:
                    result[f"mobile-player-{slot}"] = {
                        "name": mobile[slot], "index": index, "node": js.name,
                    }
                continue
            try:
                unique = (js / "device/uniq").read_text().strip()
            except OSError:
                unique = ""
            stable = unique or re.sub(r"[^A-Za-z0-9_.-]+", "_", name).strip("_")
            identity = f"bluetooth-{stable}" if unique else f"gamepad-{stable}"
            result[identity] = {"name": name, "index": index, "node": js.name}
        except (OSError, ValueError):
            continue
    return result


def load():
    defaults = {"player1": FALLBACK, "player2": None, "player3": None, "player4": None}
    try:
        data = json.loads(CONFIG.read_text(encoding="utf-8"))
        defaults.update({key: data.get(key) for key in defaults})
    except (OSError, ValueError, TypeError):
        pass
    return defaults


def save(assignments):
    CONFIG.parent.mkdir(parents=True, exist_ok=True)
    temporary = CONFIG.with_suffix(".tmp")
    temporary.write_text(json.dumps(assignments, indent=2) + "\n", encoding="utf-8")
    temporary.replace(CONFIG)


def replace_setting(contents, key, value):
    line = f'{key} = "{value}"'
    pattern = rf"^\s*{re.escape(key)}\s*=.*$"
    if re.search(pattern, contents, flags=re.MULTILINE):
        return re.sub(pattern, line, contents, flags=re.MULTILINE)
    return contents.rstrip() + "\n" + line + "\n"


def remove_setting(contents, key):
    pattern = rf"^\s*{re.escape(key)}\s*=.*(?:\n|$)"
    return re.sub(pattern, "", contents, flags=re.MULTILINE)


def sync_autoconfigs():
    """Translate EmulationStation mappings for newly configured USB pads."""
    try:
        root = ET.parse(ES_INPUT).getroot()
    except (OSError, ET.ParseError):
        return
    AUTOCONFIG.mkdir(parents=True, exist_ok=True)
    names = {
        "a": "a", "b": "b", "x": "x", "y": "y", "start": "start",
        "select": "select", "leftshoulder": "l", "rightshoulder": "r",
        "lefttrigger": "l2", "righttrigger": "r2", "leftstick": "l3",
        "rightstick": "r3", "up": "up", "down": "down", "left": "left",
        "right": "right",
    }
    for pad in root.findall("inputConfig"):
        device_name = pad.get("deviceName", "").strip()
        if not device_name or "DragonRise" in device_name:
            continue  # Preserve the cabinet's carefully tested custom map.
        lines = [
            f'input_device = "{device_name}"', 'input_driver = "udev"',
            f'input_vendor_id = "{int(pad.get("vendorId", "0"))}"',
            f'input_product_id = "{int(pad.get("productId", "0"))}"',
        ]
        mapped = {}
        for item in pad.findall("input"):
            name = item.get("name", "")
            if name not in names:
                continue
            kind = item.get("type")
            number = item.get("id", "0")
            if kind == "axis":
                prefix = "+" if item.get("value", "1").startswith("1") else "-"
                lines.append(f'input_{names[name]}_axis = "{prefix}{number}"')
            elif kind == "button":
                lines.append(f'input_{names[name]}_btn = "{number}"')
                mapped[name] = number
        hotkey = next((x for x in pad.findall("input") if x.get("name") == "hotkeyenable"), None)
        if hotkey is not None and hotkey.get("type") == "button":
            lines.append(f'input_enable_hotkey_btn = "{hotkey.get("id")}"')
            if "start" in mapped:
                lines.append(f'input_exit_emulator_btn = "{mapped["start"]}"')
        (AUTOCONFIG / f"{device_name}.cfg").write_text("\n".join(lines) + "\n", encoding="utf-8")


def apply(assignments=None, quiet=False):
    sync_autoconfigs()
    assignments = assignments or load()
    if not CONFIG.exists():
        save(assignments)
    devices = detected()
    fallback = devices.get(FALLBACK)
    resolved = {}
    used = set()
    for player in range(1, 5):
        key = f"player{player}"
        requested = assignments.get(key)
        device = devices.get(requested)
        if player == 1 and device is None:
            device = fallback
        if device and device["index"] not in used:
            resolved[player] = device
            used.add(device["index"])
        else:
            resolved[player] = None

    contents = RETROARCH.read_text(encoding="utf-8")
    for player in range(1, 5):
        key = f"input_player{player}_joypad_index"
        if resolved[player]:
            contents = replace_setting(contents, key, resolved[player]["index"])
        elif player > 1:
            # This RetroArch build can segfault on a negative joypad index.
            # No override is safer: the player remains automatic/unassigned.
            contents = remove_setting(contents, key)
    temporary = RETROARCH.with_suffix(".controller-manager.tmp")
    temporary.write_text(contents, encoding="utf-8")
    temporary.replace(RETROARCH)
    # Some systems intentionally override the global player indices after
    # their #include line. Keep those overrides synchronized with the menu.
    for system_config in SYSTEM_RETROARCH:
        if not system_config.exists():
            continue
        system_contents = system_config.read_text(encoding="utf-8")
        for player in range(1, 5):
            key = f"input_player{player}_joypad_index"
            if resolved[player]:
                system_contents = replace_setting(system_contents, key, resolved[player]["index"])
            elif player > 1:
                system_contents = remove_setting(system_contents, key)
        # Let each selected controller's autoconfig provide its own button
        # numbers. The former cabinet-specific values broke Xbox Start and
        # several face/shoulder buttons in Dreamcast.
        for suffix in ("a_btn", "b_btn", "x_btn", "y_btn", "l_btn", "r_btn",
                       "l2_btn", "r2_btn", "select_btn", "start_btn"):
            system_contents = remove_setting(system_contents, f"input_player1_{suffix}")
        system_temp = system_config.with_suffix(".controller-manager.tmp")
        system_temp.write_text(system_contents, encoding="utf-8")
        system_temp.replace(system_config)
    if not quiet:
        for player, device in resolved.items():
            label = f'{device["name"]} ({device["node"]})' if device else "Disabled / not connected"
            print(f"Player {player}: {label}")
    return resolved


def dialog(*args):
    result = subprocess.run(
        ["dialog", "--stdout", "--no-mouse", *args],
        text=True, stdout=subprocess.PIPE, check=False,
    )
    return result.stdout.strip(), result.returncode


def label_for(device_id, devices):
    if not device_id:
        return "Automatic / unassigned"
    if device_id in devices:
        return f'{devices[device_id]["name"]} ({devices[device_id]["node"]})'
    if device_id == FALLBACK:
        return "Built-in cabinet controls (currently missing)"
    return f"Missing: {device_id}"


def choose_player(assignments, player):
    devices = detected()
    options = []
    if player != 1:
        options.extend(["disabled", "Automatic / unassigned"])
    for identity, info in devices.items():
        suffix = " [CABINET / FAILSAFE]" if identity == FALLBACK else ""
        options.extend([identity, f'{info["name"]} - {info["node"]}{suffix}'])
    if not options:
        dialog("--msgbox", "No USB game controllers are detected.", "8", "48")
        return
    selected, status = dialog(
        "--title", f"Assign Player {player}",
        "--menu", "Choose the controller used inside games.\nThe built-in cabinet controls always remain available for menu and recovery shortcuts.",
        "18", "76", "10", *options,
    )
    if status != 0:
        return
    identity = None if selected == "disabled" else selected
    # A physical controller may only occupy one player slot.
    if identity:
        for key in assignments:
            if assignments[key] == identity:
                assignments[key] = None
    assignments[f"player{player}"] = identity
    if player == 1 and not identity:
        assignments["player1"] = FALLBACK
    dialog("--msgbox", f"Player {player} pending:\n\n{label_for(assignments[f'player{player}'], devices)}\n\nChoose SAVE SETTINGS from the main screen to apply it.", "13", "72")


def show_status(assignments):
    devices = detected()
    lines = []
    for player in range(1, 5):
        lines.append(f"Player {player}: {label_for(assignments.get(f'player{player}'), devices)}")
    lines.extend([
        "", "Safety behavior:",
        "• The built-in cabinet joystick always controls EmulationStation.",
        "• If Player 1's USB pad is absent, the cabinet becomes Player 1.",
        "• Start + left flipper recovery shortcuts are never reassigned.",
    ])
    dialog("--title", "Controller Status", "--msgbox", "\n".join(lines), "20", "78")


def generate_menu():
    """Create a large, native EmulationStation menu for controller assignment."""
    assignments = load()
    devices = detected()
    CONTROLLER_MENU.mkdir(parents=True, exist_ok=True)
    media = CONTROLLER_MENU / "media"
    media.mkdir(exist_ok=True)
    for old in CONTROLLER_MENU.glob("*.sh"):
        old.unlink()

    entries = []

    def add(filename, name, description, command):
        path = CONTROLLER_MENU / filename
        path.write_text("#!/usr/bin/env bash\nset -e\n" + command + "\n", encoding="utf-8")
        path.chmod(0o755)
        entries.append((filename, name, description))

    summary = "   •   ".join(
        f"P{player}: {label_for(assignments.get(f'player{player}'), devices).split(' (')[0]}"
        for player in range(1, 5)
    )
    add("00-current-setup.sh", "CURRENT SETUP", summary + ". Select another card below to change it.", "sleep 0.2")

    for player in range(1, 5):
        for number, (identity, info) in enumerate(devices.items(), start=1):
            is_current = assignments.get(f"player{player}") == identity
            marker = "✓ " if is_current else ""
            cabinet = " — CABINET FAIL-SAFE" if identity == FALLBACK else ""
            add(
                f"{player}{number:02d}-p{player}-{info['node']}.sh",
                f"{marker}PLAYER {player}: {info['name']}{cabinet}",
                f"Use {info['name']} as Player {player} inside games. USB identity is remembered across reboots.",
                f"sudo /usr/local/bin/cabinet-controller-manager.py --set {player} {shlex.quote(identity)}\n"
                "sudo systemctl restart getty@tty1.service",
            )
        if player > 1:
            add(
                f"{player}90-disable-p{player}.sh", f"PLAYER {player}: AUTOMATIC / UNASSIGNED",
                f"Remove the forced assignment for Player {player}.",
                f"sudo /usr/local/bin/cabinet-controller-manager.py --disable {player}\n"
                "sudo systemctl restart getty@tty1.service",
            )

    add(
        "990-restore-cabinet-defaults.sh", "RESTORE SAFE CABINET DEFAULTS",
        "Built-in cabinet controls become Player 1; Players 2–4 are disabled.",
        "sudo /usr/local/bin/cabinet-controller-manager.py --restore\n"
        "sudo systemctl restart getty@tty1.service",
    )
    add(
        "999-refresh-connected-controllers.sh", "REFRESH CONNECTED CONTROLLERS",
        "Rescan USB ports after adding or removing a gamepad.",
        "sudo /usr/local/bin/cabinet-controller-manager.py --generate-menu\n"
        "sudo systemctl restart getty@tty1.service",
    )

    image = "/home/pi/RetroPie/roms/controllers/media/controller.svg"
    xml = ['<?xml version="1.0" encoding="UTF-8"?>', "<gameList>"]
    for filename, name, description in entries:
        xml.extend([
            "  <game>", f"    <path>./{escape(filename)}</path>",
            f"    <name>{escape(name)}</name>", f"    <desc>{escape(description)}</desc>",
            f"    <image>{image}</image>", "  </game>",
        ])
    xml.append("</gameList>")
    (CONTROLLER_MENU / "gamelist.xml").write_text("\n".join(xml) + "\n", encoding="utf-8")
    (media / "controller.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="900" height="900" viewBox="0 0 900 900">
<defs><radialGradient id="b"><stop stop-color="#26356f"/><stop offset="1" stop-color="#07091c"/></radialGradient><filter id="g"><feGaussianBlur stdDeviation="12" result="x"/><feMerge><feMergeNode in="x"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>
<rect width="900" height="900" rx="90" fill="url(#b)"/><path d="M220 330c65-75 395-75 460 0 40 48 105 235 52 291-51 55-128-37-191-88H359c-63 51-140 143-191 88-53-56 12-243 52-291z" fill="#10172f" stroke="#35efff" stroke-width="18" filter="url(#g)"/>
<path d="M300 405v120M240 465h120" stroke="#fff" stroke-width="30" stroke-linecap="round"/><circle cx="600" cy="425" r="30" fill="#ff4fc8"/><circle cx="665" cy="490" r="30" fill="#ffe34d"/><circle cx="535" cy="490" r="30" fill="#4dff89"/><text x="450" y="735" text-anchor="middle" fill="white" font-family="sans-serif" font-size="62" font-weight="bold">CONTROLLERS</text><text x="450" y="800" text-anchor="middle" fill="#35efff" font-family="sans-serif" font-size="34">PLAYER ASSIGNMENT</text></svg>''', encoding="utf-8")


def set_player(player, identity):
    assignments = load()
    if identity:
        for key in assignments:
            if assignments[key] == identity:
                assignments[key] = None
    assignments[f"player{player}"] = identity if identity else (FALLBACK if player == 1 else None)
    save(assignments)
    apply(assignments, quiet=True)
    generate_menu()


def configured_device_names():
    try:
        root = ET.parse(ES_INPUT).getroot()
        names = {item.get("deviceName", "").strip() for item in root.findall("inputConfig")}
        # SDL exposes xpadneo as "Xbox 360 Controller" to EmulationStation,
        # while sysfs retains the hardware name used by the assignment menu.
        if "Xbox 360 Controller" in names:
            names.add("Xbox Wireless Controller")
        return names
    except (OSError, ET.ParseError):
        return set()


def set_preset(name):
    devices = detected()
    mapped = configured_device_names()
    external = next(
        (identity for identity, info in devices.items() if identity != FALLBACK and info["name"] in mapped),
        None,
    )
    if name == "usb-first" and external:
        assignments = {"player1": external, "player2": FALLBACK, "player3": None, "player4": None}
    elif name == "cabinet-first" and external:
        assignments = {"player1": FALLBACK, "player2": external, "player3": None, "player4": None}
    else:
        assignments = {"player1": FALLBACK, "player2": None, "player3": None, "player4": None}
    save(assignments)
    apply(assignments, quiet=True)
    generate_menu()


def generate_simple_menu():
    """Build a compact card menu with one Player 1 choice per real pad."""
    assignments = load()
    devices = detected()
    mapped = configured_device_names()
    CONTROLLER_MENU.mkdir(parents=True, exist_ok=True)
    media = CONTROLLER_MENU / "media"
    media.mkdir(exist_ok=True)
    for old in CONTROLLER_MENU.glob("*.sh"):
        old.unlink()
    entries = []

    def add(filename, name, description, command):
        path = CONTROLLER_MENU / filename
        path.write_text("#!/usr/bin/env bash\nset -e\n" + command + "\n", encoding="utf-8")
        path.chmod(0o755)
        entries.append((filename, name, description))

    summary = "   •   ".join(
        f"P{player}: {label_for(assignments.get(f'player{player}'), devices).split(' (')[0]}"
        for player in range(1, 3)
    )
    add("00-current.sh", "CURRENT: " + summary, "This is the assignment games will use.", "sleep 0.2")
    add("10-open-settings.sh", "OPEN CONTROLLER SETTINGS", "Use left/right to assign every detected controller to Players 1–4, then explicitly Save or Cancel.", "sudo /usr/local/bin/dreadwire-controller-ui.py")
    add("20-refresh.sh", "REFRESH CONNECTED CONTROLLERS", "Rescan USB and Bluetooth gamepads without restarting EmulationStation.", "sudo /usr/local/bin/cabinet-controller-manager.py --generate-menu")

    image = "/home/pi/RetroPie/roms/controllers/media/controller.svg"
    xml = ['<?xml version="1.0" encoding="UTF-8"?>', "<gameList>"]
    for filename, name, description in entries:
        xml.extend(["  <game>", f"    <path>./{escape(filename)}</path>", f"    <name>{escape(name)}</name>", f"    <desc>{escape(description)}</desc>", f"    <image>{image}</image>", "  </game>"])
    xml.append("</gameList>")
    (CONTROLLER_MENU / "gamelist.xml").write_text("\n".join(xml) + "\n", encoding="utf-8")


def manager():
    assignments = load()
    while True:
        devices = detected()
        choices = []
        for player in range(1, 5):
            choices.extend([str(player), f"Set Player {player}  [{label_for(assignments.get(f'player{player}'), devices)}]"])
        choices.extend([
            "status", "Show assignments and safety status",
            "restore", "Restore safe cabinet defaults",
            "save", "SAVE SETTINGS and return to RetroPie",
            "cancel", "CANCEL changes and return",
        ])
        selected, status = dialog(
            "--title", "Dreadwire Controller Manager",
            "--menu", "Assign USB controllers to game players. The cabinet controls remain the fail-safe.",
            "21", "88", "12", *choices,
        )
        if status != 0 or selected == "cancel":
            break
        if selected.isdigit():
            choose_player(assignments, int(selected))
        elif selected == "status":
            show_status(assignments)
        elif selected == "restore":
            answer, code = dialog(
                "--title", "Restore Cabinet Defaults", "--yesno",
                "Make the built-in cabinet controls Player 1 and disable Players 2–4?",
                "10", "68",
            )
            if code == 0:
                assignments = {"player1": FALLBACK, "player2": None, "player3": None, "player4": None}
                dialog("--msgbox", "Safe cabinet defaults are pending. Choose SAVE SETTINGS to apply them.", "8", "62")
        elif selected == "save":
            save(assignments)
            apply(assignments, quiet=True)
            generate_menu()
            dialog("--msgbox", "Controller settings saved. They will be used when the next game starts.", "8", "64")
            break
    subprocess.run(["clear"], check=False)


if __name__ == "__main__":
    if "--set" in sys.argv:
        offset = sys.argv.index("--set")
        set_player(int(sys.argv[offset + 1]), sys.argv[offset + 2])
    elif "--disable" in sys.argv:
        offset = sys.argv.index("--disable")
        set_player(int(sys.argv[offset + 1]), None)
    elif "--restore" in sys.argv:
        defaults = {"player1": FALLBACK, "player2": None, "player3": None, "player4": None}
        save(defaults)
        apply(defaults, quiet=True)
        generate_menu()
    elif "--preset" in sys.argv:
        offset = sys.argv.index("--preset")
        set_preset(sys.argv[offset + 1])
    elif "--generate-menu" in sys.argv:
        generate_menu()
    elif "--apply" in sys.argv:
        apply(quiet="--quiet" in sys.argv)
    else:
        manager()
